var timeline_sv = [];

/* define instructions trial */
 var instructions = {
    type: "html-keyboard-response",
    stimulus: "<p><div style='font-size:25px;''><strong>Visuel simpel reaktionstid </strong></div></p>" +
    "<pclass='largegap-above'>I den følgende opgave vil du se en hvid kasse på skærmen.</p>" +          
        // "<div style='width: 900px;'>"+
          "<div class='instr-img'>" + 
            "<img src='img/blankbox.png'></img>" +
            "<p class='small'><strong>Vent!</strong></p>" + 
          "</div>" +
          "<p class='gap-above'>Hver gang du ser et <strong>kryds</strong> i kassen,</p>" +
          "<p>skal du trykke på <strong>mellemrumstasten,</strong> så hurtigt som du kan.</p>" +
          "<div class='instr-img'>" + 
            "<img src='img/cross.png'></img>" +
            "<p class='small'><strong>Tryk!</strong></p>" +
          "</div>" +
                 "<p> Du får lov til at prøve det nogle gange først.</p>"+
        "<p class='gap-above'> <strong><i>Tryk på mellemrumstasten for at starte træningsrunden.</strong></i></p>",
    choices: ['space'],
    data: {cond: 'vis_s', test_part: 'instructions'}
  };
  
  timeline_sv.push(instructions);

   /* test trials */
   var training_stimuli = [
    { 
      stimulus: "img/cross.png", 
      data: {cond: 'vis_s', test_part: 'training_test', correct_response: 'space'}
    }
  ];

  var training_fixation = {
    type: 'image-keyboard-response',
    stimulus: "img/blankbox.png", 
    choices: ['space'],
    trial_duration: function(){
      return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
    },
    data: {cond: 'vis_s', test_part: 'training_fixation', correct_response: 'null'},
    on_finish: function (data) {
      data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
    },
    response_ends_trial: false
  };

  var training_test = {
    type: "image-keyboard-response",
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['space'],
    trial_duration: 1000,
    data: jsPsych.timelineVariable('data'),
    on_finish: function(data){
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
    }
  };

  var training_procedure = {
    timeline: [training_fixation, training_test],
    timeline_variables: training_stimuli,
    repetitions: 8
  };

  timeline_sv.push(training_procedure);

  /* define training debrief */

var training_debrief_block = {
  type: "html-keyboard-response",
  stimulus: function () {

    var fixations = jsPsych.data.get().filter({ test_part: 'training_fixation' });
    var false_alarms = fixations.filter({ correct: false });
    // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
    var correct_real = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.test_part == "training_test") && (trial.key_press === 32) && (trial.rt > 100);
      }
    )
    // calculate reaction time (to correct trials excluding anticipatory responses (<100 ms))
    var rt_real = Math.round(correct_real.select('rt').mean());

    // calculate proportion of false alarms (responses to fixations only, i.e. excl. 0-100ms test-responses)
    var falsealarm_pct = Math.round(false_alarms.count() / fixations.count() * 100);

    return "<p>Din gennemsnitlige reaktionstid her i træningsrunden var </p>" +
      "<p><strong> " + rt_real + "ms </strong></p>" +
      "<p>Du trykkede for tidligt " + falsealarm_pct + " % af gangene </p>" +
      "</div>" +
      "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at fortsætte.</strong></i></p>";
  },
  choices: ['space'],
  data: { cond: 'vis_s', test_part: 'feedback_training' },

  on_finish: function (data) {
    // get data
    var trials = jsPsych.data.get().filter({ test_part: 'training_test' });
    var fixations = jsPsych.data.get().filter({ test_part: 'training_fixation' });
    var false_alarms = fixations.filter({ correct: false });
    // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
    var correct_real = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.test_part == "training_test") && (trial.key_press === 32) && (trial.rt > 100);
      }
    )
    var misses = trials.filter({ correct: false });
    
    // select trials with a response time smaller than 100 ms (considered false anticipatory responses).
    var too_fast = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.test_part == "training_test") && (trial.key_press === 32) && (trial.rt < 100);
      }
    )

    // calculate summary values to display in data
    var rt_real = Math.round(correct_real.select('rt').mean());
    var toofast = Math.round(too_fast.count() / trials.count() * 100);
    var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);
    var miss = Math.round(misses.count() / trials.count() * 100);

    data.summary = { rt_real: rt_real, ant_resp_pct: toofast, fa_pct: falsealarm, miss_pct: miss };
  }
};
timeline_sv.push(training_debrief_block);
 