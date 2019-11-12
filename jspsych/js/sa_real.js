var test_stimuli = [
  { stimulus: "sounds/452sine.mp3", data: { cond: 'aud_s', test_part: 'test', correct_response: 'space' } }
];

var fixation = {
  type: 'html-keyboard-response',
  stimulus: '<div style="font-size:80px;">+</div>',
  choices: ['space'],
  trial_duration: function () {
    return jsPsych.randomization.sampleWithoutReplacement([950, 1200, 1450, 1700, 1950, 2200, 2450], 1)[0];
  },
  data: { cond: 'aud_s', test_part: 'fixation', correct_response: 'null' },
  on_finish: function (data) {
    data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
  },
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
  on_finish: function (data) {
    data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
  }
};

var start_real = {
  type: "html-keyboard-response",
  stimulus: "<p><strong>Nu kommer den rigtige test af din auditive reaktionstid</strong>.</p> " +
    "<p> Når du hører lyden, skal du trykke så hurtigt som du kan. </p>" +
    "<p class='largegap-above'</p" +
    "<p><div style='font-size:80px;''>+</div></p>" +
    "<p class='largegap-above'</p" +
    "<p>Er du klar? Opgaven handler om fart!</p>" +
    "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at starte.</strong></i></p>",
  choices: ['space'],
  data: { cond: 'aud_s', test_part: 'instructions' },
  };
timeline_sa.push(start_real);

var test_procedure = {
  timeline: [fixation, test, resp],
  timeline_variables: test_stimuli,
  randomize_order: true,
  repetitions: 2
}

timeline_sa.push(test_procedure);

/* define debrief block*/
var debrief_block = {
  type: "html-keyboard-response",
  stimulus: function () {

    var fixations = jsPsych.data.get().filter({ cond:'aud_s', test_part: 'fixation' });
    var false_alarms = fixations.filter({ correct: false });
    // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
    var correct_real = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.cond == "aud_s") && (trial.test_part == "test") && (trial.key_press === 32) && (trial.rt > 100);
      }
    )
    // calculate reaction time (to correct trials excluding anticipatory responses (<100 ms))
    var rt_real = Math.round(correct_real.select('rt').mean());

    // calculate proportion of false alarms (responses to fixations only, i.e. excl. 0-100ms test-responses)
    var falsealarm_pct = Math.round(false_alarms.count() / fixations.count() * 100);

    return "<p>Din gennemsnitlige reaktionstid var </p>" +
      "<p><strong> " + rt_real + " ms </strong></p>" +
      "<p>Du trykkede for tidligt " + falsealarm_pct + " % af gangene. </p>" +
      "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at afslutte den auditive reaktionstids-test.</strong></i></p>";
  },
  choices: ['space'],
  data: { cond: 'aud_s', test_part: 'feedback_real' },

  on_finish: function (data) {
    // get data
    var trials = jsPsych.data.get().filter({ cond:'aud_s', test_part: 'test' });
    var fixations = jsPsych.data.get().filter({ cond:'aud_s', test_part: 'fixation' });
    var false_alarms = fixations.filter({ correct: false });
    // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
    var correct_real = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.cond=="aud_s") && (trial.test_part == "test") && (trial.key_press === 32) && (trial.rt > 100);
      }
    )
    var misses = trials.filter({ correct: false });
    // select trials with a response time smaller than 100 ms (considered false anticipatory responses).
    var too_fast = jsPsych.data.get().filterCustom(
      function (trial) {
        return (trial.cond=="aud_s") && (trial.test_part == "test") && (trial.key_press === 32) && (trial.rt < 100);
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
timeline_sa.push(debrief_block);

// an array of paths to sound that need to be manually pre-loaded
var audio = ['sounds/452sine.mp3'];

