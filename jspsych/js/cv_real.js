
/* test trials */

var test_stimuli = [
    { stimulus: "img/cRT1.png", data: { cond: 'vis_ch', test_part: 'test', correct_response: 'z' } },
    { stimulus: "img/cRT2.png", data: { cond: 'vis_ch', test_part: 'test', correct_response: 'x' } },
    { stimulus: "img/cRT3.png", data: { cond: 'vis_ch', test_part: 'test', correct_response: ',' } },
    { stimulus: "img/cRT4.png", data: { cond: 'vis_ch', test_part: 'test', correct_response: '.' } }
];

var fixation = {
    type: 'image-keyboard-response',
    stimulus: "img/cRT_fix.png",
    choices: ['z', 'x', ',', '.'],
    trial_duration: function () {
        return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
    },
    data: {cond: 'vis_ch', test_part: 'fixation', correct_response: 'null' },
    on_finish: function (data) {
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
      },
    response_ends_trial: false
};

var test = {
    type: "image-keyboard-response",
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['z', 'x', ',', '.'],
    trial_duration: 1000,
    data: jsPsych.timelineVariable('data'),
    on_finish: function (data) {
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
    }
};


var start_real = {
    type: "html-keyboard-response",
    stimulus: "<p><strong>Nu kommer den rigtige test af din reaktionstid</strong>.</p> " +
        "<p>Når du ser krydset, skal du trykke på den tilhørende tast så hurtigt som du kan. </p>" +
        "<p>Du får ikke at vide, om du laver fejl. </p>" +
        "<p class='gap-above'> Husk: </p>" +
        "<div class='instr-img'>" +
        "     <img src='img/reminder.png'></img>" +

        "<p class='largegap-above'>Er du klar? Opgaven handler om fart!</p>" +
        "<p class='smallgap-above'><strong><i>Tryk på mellemrumstasten for at starte.</strong></i></p>",
        choices: ['space'],
        data: {cond: 'vis_ch', test_part: 'instructions'},
};
timeline_cv.push(start_real);

var test_procedure = {
    timeline: [fixation, test],
    sample: {
        type: 'fixed-repetitions',
        size: 10, // 10 repetitions of each trial, 40 total trials, order is randomized.
    },
    timeline_variables: test_stimuli    
};

timeline_cv.push(test_procedure);

var debrief_block = {
    type: "html-keyboard-response",
    stimulus: function () {

        var trials = jsPsych.data.get().filter({ test_part: 'test' });
        var fixations = jsPsych.data.get().filter({ test_part: 'fixation' });

        var correct_trials = trials.filter({ correct: true });

        // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
        var correct_real = jsPsych.data.get().filterCustom(
            function (trial) {
                return (trial.test_part == "test") && (trial.correct == true) && (trial.rt > 100);
            }
        )

        // calculate reaction time (to correct trials excluding anticipatory responses (<100 ms))
        var rt_real = Math.round(correct_real.select('rt').mean());

        var incorrect_trials = trials.filter({ correct: false })
        var false_alarms = fixations.filter({ key_press: 32 });

        // calculate proportion of false alarms (responses to fixations only, i.e. excl. 0-100ms test-responses)
        var falsealarm_pct = Math.round(false_alarms.count() / fixations.count() * 100);
        // calculate accuracy (% correct responses)
        var accuracy = Math.round(correct_real.count() / trials.count() * 100);


        return "<p>Du svarede rigtigt " + accuracy + " % af gangene </p>" +
            "<p>og din gennemsnitlige reaktionstid var </p>" +
            "<p><strong> " + rt_real + "ms </strong></p>" +

            "<p>Du trykkede for tidligt " + falsealarm_pct + " % af gangene </p>" +
            "</div>" +
            "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at afslutte denne reaktionstids-test</strong></i></p>";
    },
      choices: ['space'],
    data:{cond: 'vis_ch', test_part: 'feedback_real'},

    on_finish: function (data) {
        // get data
        var trials = jsPsych.data.get().filter({ test_part: 'test' });
        var fixations = jsPsych.data.get().filter({ test_part: 'fixation' });
        var false_alarms = fixations.filter({ correct: false });
        // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
        var correct_real = jsPsych.data.get().filterCustom(
            function (trial) {
                return (trial.test_part == "test") && (trial.correct == true) && (trial.rt > 100);
            }
        )
        var mistakes = trials.filter({ correct: false });

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
        var count_mistakes = mistakes.count();
        var accuracy = Math.round(correct_real.count() / trials.count() * 100);

        data.summary = { rt_real: rt_real, ant_resp_pct: toofast, fa_pct: falsealarm, mistakes: count_mistakes, ACC: accuracy };
    }
};

timeline_cv.push(debrief_block);