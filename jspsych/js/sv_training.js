var timeline_sv = [];

/* define instructions trial */
 var instructions = {
    type: "html-keyboard-response",
    stimulus: "<p><div style='font-size:25px;''><strong>Visuel simpel reaktionstid </strong></div></p>" +
    "<pclass='gap-above'>I den følgende opgave vil du se en hvid kasse på skærmen.</p>" +          
        "<div style='width: 900px;'>"+
          "<div class='instr-img'>" + 
            "<img src='img/blankbox.png'></img>" +
            "<p class='small'><strong>Vent!</strong></p>" + 
          "</div>" +
          "<p> Hver gang du ser et <strong>kryds</strong> i kassen, " +
          "skal du trykke på <strong>mellemrumstasten,</strong> så hurtigt som du kan.</p>" +
          "<div class='instr-img'>" + 
            "<img src='img/cross.png'></img>" +
            "<p class='small'><strong>Tryk!</strong></p>" +
          "</div>" +
                 "<p> Du får lov til at prøve det nogle gange først.</p>"+
        "<p class='gap-above'> <strong><i>Tryk på mellemrumstasten for at starte træningsrunden.</strong></i></p>",
    choices: ['space'],
    post_trial_gap: 100
  };
  
  timeline_sv.push(instructions);

   /* test trials */
   var test_stimuli = [
    { 
      stimulus: "img/cross.png", 
      data: {test_part: 'trainingtest', correct_response: 'space'}
    }
  ];

  var fixation = {
    type: 'image-keyboard-response',
    stimulus: "img/blankbox.png", 
    choices: ['space'],
    trial_duration: function(){
      return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
    },
    data:{test_part: 'trainingfixation', correct_response: 'null'},
    response_ends_trial: false
  };

  var test = {
    type: "image-keyboard-response",
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['space'],
    trial_duration: 1000,
    data: jsPsych.timelineVariable('data'),
    on_finish: function(data){
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
    }
  };

  var test_procedure = {
    timeline: [fixation, test],
    timeline_variables: test_stimuli,
    repetitions: 3
  };

  timeline_sv.push(test_procedure);

  // define debrief_block;
  var debrief_block = {
    type: "html-keyboard-response",
    stimulus: function() {

      var trials = jsPsych.data.get().filter({test_part: 'trainingtest'});
      var fixations = jsPsych.data.get().filter({test_part: 'trainingfixation'});
      
      var correct_trials = trials.filter({correct: true});
      var incorrect_trials = trials.filter({correct: false});
      var false_alarms = fixations.filter({key_press: 32});
      

      // count the number of trials with a response time smaller than 100 ms (considered false anticipatory responses).
      var too_fast = jsPsych.data.get().filterCustom(
        function(trials){
          return (trials.test_part== "trainingtest") && (trials.key_press===32) && (trials.rt < 100);
        }
      ).count();

      // count the number of trials denoted "incorrect" because of lack of response within trial duration (currently 1000ms).

      var too_slow = jsPsych.data.get().filterCustom(
        function(incorrect_trials){
          return (incorrect_trials.test_part== "trainingtest") && (incorrect_trials.rt === null);
        }
      ).count();
      
      var too_early = Math.round(too_fast + false_alarms.count());
      
       // calculate proportion of false alarms (responses to fixations)
      var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);
      
      // calculate reaction time
      var rt = Math.round(correct_trials.select('rt').mean());
           
      return "<p>Din gennemsnitlige reaktionstid her i træningsrunden var </p>" +
      "<p><strong> "+rt+" ms </strong></p>"+
      "<p>Du trykkede for tidligt "+too_early+" gange </p>" + 
      "</div>" + 
      "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at fortsætte</strong></i></p>";
    },
      choices: ['space'],

    on_finish: function(data){
      // get data
      var trials = jsPsych.data.get().filter({test_part: 'trainingtest'});
      var fixations = jsPsych.data.get().filter({test_part: 'trainingfixation'});


      var correct_trials = trials.filter({correct: true});
      var false_alarms = fixations.filter({key_press: 32});
      var too_fast = jsPsych.data.get().filterCustom(
        function(trials){
          return (trials.test_part== "trainingtest") && (trials.key_press===32) && (trials.rt < 100);
        }
      ).count();

      var too_slow = jsPsych.data.get().filterCustom(
        function(incorrect_trials){
          return (incorrect_trials.test_part== "trainingtest") && (incorrect_trials.rt === null);
        }
      ).count();
      var rt = Math.round(correct_trials.select('rt').mean());
      var too_early = Math.round(too_fast + false_alarms.count());
      // calculate all hits between 1 and 1000 ms
      var hits = Math.round(correct_trials.count() / trials.count() * 100);
      var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);
      
      data.summary = {RT: rt, HITSinPCT: hits, FALSE_AND_EARLY_RESPONSES: too_early, MISSES: too_slow};
    } 
  };
  timeline_sv.push(debrief_block);
 