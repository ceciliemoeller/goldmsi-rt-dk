var test_stimuli = [
    {stimulus: "sounds/452sine.mp3", data: {test_part: 'test', correct_response: 'space'}}
  ];

  var fixation = {
    type: 'html-keyboard-response',
    stimulus: '<div style="font-size:80px;">+</div>',
  //   choices: jsPsych.NO_KEYS,
    choices: ['space'],
    trial_duration: function(){
      return jsPsych.randomization.sampleWithoutReplacement([950, 1200, 1450, 1700, 1950, 2200, 2450], 1)[0];
    },
    data:{test_part: 'fixation', correct_response: 'null'},
    response_ends_trial: false
  }

  var resp = {
    type: 'html-keyboard-response',
    stimulus: " ", 
    trial_duration: 50,
    response_ends_trial: false
   }

   var test = {
    type: "audio-keyboard-response",
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['space'],
    trial_duration: 1000,
    prompt: '<div style="font-size:80px;">+</div>',
    data: jsPsych.timelineVariable('data'),
    on_finish: function(data){
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
    }
  };

  var start_real = {
    type: "html-keyboard-response",
    stimulus: "<p> Nu kommer den <strong>rigtige test af din auditive reaktionstid</strong>.</p> " +
          "<p> Når du hører lyden, skal du trykke så hurtigt som du kan. </p>" +
          "<p class='largegap-above'</p" +
          "<p><div style='font-size:80px;''>+</div></p>" +
          "<p class='largegap-above'</p" +
        "<p>Er du klar? Opgaven handler om fart!</p>" + 
        "<p class='gap-above'><strong><i>Tryk på en tast for at starte</strong></i></p>",
    post_trial_gap: 100
  };
  timeline_sa.push(start_real);

  var test_procedure = {
    timeline: [fixation, test, resp],
    timeline_variables: test_stimuli,
    randomize_order: true,
    repetitions: 4
  }

  timeline_sa.push(test_procedure);


  var debrief_block = {
    type: "html-keyboard-response",
    stimulus: function() {

      var trials = jsPsych.data.get().filter({test_part: 'test'});
      var fixations = jsPsych.data.get().filter({test_part: 'fixation'});
      
      var correct_trials = trials.filter({correct: true});
      var incorrect_trials = trials.filter({correct: false})
      var false_alarms = fixations.filter({key_press: 32});
      

      // count the number of trials with a response time smaller than 100 ms (considered false anticipatory responses).
      var too_fast = jsPsych.data.get().filterCustom(
        function(trials){
          return (trials.test_part== "test") && (trials.key_press===32) && (trials.rt < 100);
        }
      ).count()

      // count the number of trials denoted "incorrect" because of response times larger than duration (currently 1000ms).

      var too_slow = jsPsych.data.get().filterCustom(
        function(incorrect_trials){
          return (incorrect_trials.test_part== "test") && (incorrect_trials.rt === null);
        }
      ).count()
      
      var too_early = Math.round(too_fast + false_alarms.count());
      
      // calculate accuracy (% correct responses)
      var accuracy = Math.round(correct_trials.count() / trials.count() * 100);

       // calculate proportion of false alarms (responses to fixations)
      var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);
      
      // calculate reaction time
      var rt = Math.round(correct_trials.select('rt').mean());
      
      //count incorrect trials (too slow (>1000 ms) and too fast (0-150 ms))
      var no_inc = incorrect_trials.count();

      return "<p>Din gennemsnitlige reaktionstid var </p>" +
             "<p><strong> "+rt+" ms </strong></p>"+
             "<p>Du trykkede for tidligt "+too_early+" gange </p>" + 
             "</div>" + 
             "<p class='gap-above'><strong><i>Tryk på en tast for at afslutte den auditive reaktionstids-test</strong></i></p>";
    },
    on_finish: function(data, too_early, too_slow){
      // get data
      var trials = jsPsych.data.get().filter({test_part: 'test'});
      var fixations = jsPsych.data.get().filter({test_part: 'fixation'});


      var correct_trials = trials.filter({correct: true});
      var false_alarms = fixations.filter({key_press: 32});
      var too_fast = jsPsych.data.get().filterCustom(
        function(trials){
          return (trials.test_part== "test") && (trials.key_press===32) && (trials.rt < 100);
        }
      ).count()
      var too_slow = jsPsych.data.get().filterCustom(
        function(incorrect_trials){
          return (incorrect_trials.test_part== "test") && (incorrect_trials.rt === null);
        }
      ).count()
      var rt = Math.round(correct_trials.select('rt').mean());
      var too_early = Math.round(too_fast + false_alarms.count());
      var accuracy = Math.round(correct_trials.count() / trials.count() * 100);
      var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);
      
      data.summary = {RT: rt, ACC_pct: accuracy, Too_Early: too_early, Too_Slow: too_slow};
    } 
  };
  timeline_sa.push(debrief_block);

  
    // an array of paths to sound that need to be manually pre-loaded
    var audio = ['sounds/452sine.mp3'];
    
  