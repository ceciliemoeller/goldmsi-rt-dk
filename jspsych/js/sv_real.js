
/* test trials */
var test_stimuli = [
  {
    stimulus: "img/cross.png",
    data: {cond: 'vis_s', test_part: 'test', correct_response: 'space' }
  }
];

var fixation = {
  type: 'image-keyboard-response',
  stimulus: "img/blankbox.png",
  choices: ['space'],
  trial_duration: function () {
    return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
  },
  data: {cond: 'vis_s', test_part: 'fixation', correct_response: 'null' },
  on_finish: function (data) {
    data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
  },
  response_ends_trial: false
};

var test = {
  type: "image-keyboard-response",
  stimulus: jsPsych.timelineVariable('stimulus'),
  choices: ['space'],
  trial_duration: 1000,
  data: jsPsych.timelineVariable('data'),
  on_finish: function (data) {
    data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
  }
};


var start_real = {
  type: "html-keyboard-response",
  stimulus: "<p><strong>Nu kommer den rigtige test af din reaktionstid</strong>.</p> " +
    "<p>Når du ser krydset, skal du trykke så hurtigt som du kan. </p>" +
    "<div class='instr-img'>" +
    "<div class='largegap-above'>" +
    "<img src='img/cross.png'></img>" +
    "<p class='largegap-above'>Er du klar? Opgaven handler om fart!</p>" +
    "<p class='smallgap-above'><strong><i>Tryk på mellemrumstasten for at starte</strong></i></p>",
    choices: ['space'],
    data: {cond: 'vis_s', test_part: 'instructions'},
};
timeline_sv.push(start_real);

var test_procedure = {
  timeline: [fixation, test],
  timeline_variables: test_stimuli,
  repetitions: 2
};

timeline_sv.push(test_procedure);

/* define debrief block*/
var debrief_block = {
  type: "html-keyboard-response",
  stimulus: function () {

    var fixations = jsPsych.data.get().filter({ test_part: 'fixation' });
    var false_alarms = fixations.filter({ correct: false });
    // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
    var correct_real = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.test_part == "test") && (trial.key_press === 32) && (trial.rt > 100);
      }
    )
    // calculate reaction time (to correct trials excluding anticipatory responses (<100 ms))
    var rt_real = Math.round(correct_real.select('rt').mean());

    // calculate proportion of false alarms (responses to fixations only, i.e. excl. 0-100ms test-responses)
    var falsealarm_pct = Math.round(false_alarms.count() / fixations.count() * 100);

    return "<p>Din gennemsnitlige reaktionstid var </p>" +
      "<p><strong> " + rt_real + " ms </strong></p>" +
      "<p>Du trykkede for tidligt " + falsealarm_pct + " % af gangene </p>" +
      "</div>" +
      "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at afslutte den auditive reaktionstids-test</strong></i></p>";
  },
  choices: ['space'],
  data: { cond: 'aud_s', test_part: 'feedback_real' },

  on_finish: function (data) {
    // get data
    var trials = jsPsych.data.get().filter({ test_part: 'test' });
    var fixations = jsPsych.data.get().filter({ test_part: 'fixation' });
    var false_alarms = fixations.filter({ correct: false });
    // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
    var correct_real = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.test_part == "test") && (trial.key_press === 32) && (trial.rt > 100);
      }
    )
    var misses = trials.filter({ correct: false });
    // select trials with a response time smaller than 100 ms (considered false anticipatory responses).
    var too_fast = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.test_part == "test") && (trial.key_press === 32) && (trial.rt < 100);
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
timeline_sv.push(debrief_block);