var timeline_sa = [];
/* define instructions trial */
var instructions = {
  type: "html-keyboard-response",
  stimulus: "<p><div style='font-size:25px;''><strong>Auditiv reaktionstid </strong></div></p>" +
    "<p class='gap-above'</p" +
    "<p>I den følgende opgave skal du lytte godt efter.</p>" +
    "<p>  Hver gang du hører en <strong>bip-lyd</strong>, " +
    "skal du trykke på <strong>mellemrumstasten,</strong> så hurtigt som du kan.</p>" +
    "<p class='largegap-above'</p" +
    "<p><div style='font-size:80px;''>+</div></p>" +
    "<p class='largegap-above'</p" +
    "<p> Du får lov til at prøve det nogle gange først.</p>" +
    "<p class='gap-above'> <strong><i>Kig på krydset i midten og tryk på en mellemrumstasten for at starte træningsrunden.</strong></i></p>",
    choices: ['space'],
};
timeline_sa.push(instructions);

/* training trials */
var training_stimuli = [
  { stimulus: "sounds/452sine.mp3", data: { test_part: 'training_test', correct_response: 'space' } }
];

var training_fixation = {
  type: 'html-keyboard-response',
  stimulus: '<div style="font-size:80px;">+</div>',
  //   choices: jsPsych.NO_KEYS,
  choices: ['space'],
  trial_duration: function () {
    return jsPsych.randomization.sampleWithoutReplacement([950, 1200, 1450, 1700, 1950, 2200, 2450], 1)[0];
  },
  data: { test_part: 'training_fixation', correct_response: 'null' },
  response_ends_trial: false
}

var training_resp = {
  type: 'html-keyboard-response',
  stimulus: " ",
  trial_duration: 50,
  response_ends_trial: false
}

var training = {
  type: "audio-keyboard-response",
  stimulus: jsPsych.timelineVariable('stimulus'),
  choices: ['space'],
  trial_duration: 1000,
  prompt: '<div style="font-size:80px;">+</div>',
  data: jsPsych.timelineVariable('data'),
  on_finish: function (data) {
    data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
  }
};

var training_procedure = {
  timeline: [training_fixation, training, training_resp],
  timeline_variables: training_stimuli,
  repetitions: 3
}

timeline_sa.push(training_procedure);
/* define training debrief */

var training_debrief_block = {
  type: "html-keyboard-response",
  stimulus: function () {

    var tr_trials = jsPsych.data.get().filter({ test_part: 'training_test' });
    var tr_fixations = jsPsych.data.get().filter({ test_part: 'training_fixation' });

    var correct_trials = tr_trials.filter({ correct: true });
    var incorrect_trials = tr_trials.filter({ correct: false })
    var false_alarms = tr_fixations.filter({ key_press: 32 });


    // count the number of trials with a response time smaller than 100 ms (considered false anticipatory responses).
    var too_fast = jsPsych.data.get().filterCustom(
      function (tr_trials) {
        return (tr_trials.test_part == "training_test") && (tr_trials.key_press === 32) && (tr_trials.rt < 100);
      }
    ).count()

    // count the number of trials denoted "incorrect" because of response times larger than duration of trial (currently 1000ms).

    var too_slow = jsPsych.data.get().filterCustom(
      function (incorrect_trials) {
        return (incorrect_trials.test_part == "training_test") && (incorrect_trials.rt === null);
      }
    ).count()

    var too_early = Math.round(too_fast + false_alarms.count());

    // calculate accuracy (% correct responses)
    var tr_accuracy = Math.round(correct_trials.count() / tr_trials.count() * 100);

    // calculate proportion of false alarms (responses to fixations)
    var tr_falsealarm = Math.round(false_alarms.count() / tr_fixations.count() * 100);

    // calculate reaction time
    var tr_rt = Math.round(correct_trials.select('rt').mean());

    //count incorrect trials (too slow (>1000 ms) and too fast (0-100 ms))
    var no_inc = incorrect_trials.count();

    return "<p>Din gennemsnitlige reaktionstid her i træningsrunden var </p>" +
      "<p><strong> " + tr_rt + " ms </strong></p>" +
      "<p>Du trykkede for tidligt " + too_early + " gange </p>" +
      "</div>" +
      "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at fortsætte</strong></i></p>";
  },
  choices: ['space'],

  on_finish: function (data, too_early, too_slow) {
    // get data
    var tr_trials = jsPsych.data.get().filter({ test_part: 'training_test' });
    var tr_fixations = jsPsych.data.get().filter({ test_part: 'training_fixation' });


    var tr_correct_trials = tr_trials.filter({ correct: true });
    var tr_false_alarms = tr_fixations.filter({ key_press: 32 });
    var tr_too_fast = jsPsych.data.get().filterCustom(
      function (tr_trials) {
        return (tr_trials.test_part == "training_test") && (tr_trials.key_press === 32) && (tr_trials.rt < 100);
      }
    ).count()
    var tr_too_slow = jsPsych.data.get().filterCustom(
      function (incorrect_trials) {
        return (incorrect_trials.test_part == "training_test") && (incorrect_trials.rt === null);
      }
    ).count()
    var tr_rt = Math.round(tr_correct_trials.select('rt').mean());
    var tr_too_early = Math.round(tr_too_fast + tr_false_alarms.count());
    var tr_accuracy = Math.round(tr_correct_trials.count() / tr_trials.count() * 100);
    var tr_falsealarm = Math.round(tr_false_alarms.count() / tr_fixations.count() * 100);

    data.summary = { RT: tr_rt, ACC_pct: tr_accuracy, Too_Early: tr_too_early, Too_Slow: tr_too_slow, Too_fast: tr_too_fast };
  }
};
timeline_sa.push(training_debrief_block);