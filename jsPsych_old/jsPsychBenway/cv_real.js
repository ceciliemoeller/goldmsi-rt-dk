
/* test trials */

var test_stimuli = [
    { stimulus: "img/cRT1.png", data: { test_part: 'test', correct_response: 'z' } },
    { stimulus: "img/cRT2.png", data: { test_part: 'test', correct_response: 'x' } },
    { stimulus: "img/cRT3.png", data: { test_part: 'test', correct_response: ',' } },
    { stimulus: "img/cRT4.png", data: { test_part: 'test', correct_response: '.' } }
];

var fixation = {
    type: 'image-keyboard-response',
    stimulus: "img/cRT_fix.png",
    choices: ['z', 'x', ',', '.'],
    trial_duration: function () {
        return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
    },
    data: { test_part: 'fixation', correct_response: 'null' },
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
    stimulus: "<p> Nu kommer den <strong>rigtige test af din reaktionstid</strong>.</p> " +
        "<p> Når du ser krydset, skal du trykke på den tilhørende tast så hurtigt som du kan. </p>" +
        "<div class='instr-img'>" +
        "     <img src='img/reminder.png'></img>" +

        "<p>Er du klar? Opgaven handler om fart!</p>" +
        "<p class='gap-above'><strong><i>Tryk på en tast for at starte</strong></i></p>",
    post_trial_gap: 100
};
timeline_cv.push(start_real);

var test_procedure = {
    timeline: [fixation, test],
    timeline_variables: test_stimuli,
    randomize_order: true,
    repetitions: 8
};

timeline_cv.push(test_procedure);

var debrief_block = {
    type: "html-keyboard-response",
    stimulus: function () {

        var trials = jsPsych.data.get().filter({ test_part: 'test' });
        var fixations = jsPsych.data.get().filter({ test_part: 'fixation' });

        var correct_trials = trials.filter({ correct: true });
        var incorrect_trials = trials.filter({ correct: false })
        var false_alarms = fixations.filter({ key_press: 32 });


        // count the number of trials with a response time smaller than 100 ms (considered false anticipatory responses).
        var too_fast = jsPsych.data.get().filterCustom(
            function (trials) {
                return (trials.test_part == "test") && (trials.key_press === 32) && (trials.rt < 100);
            }
        ).count();

        // count the number of trials denoted "incorrect" because of lack of response within trial duration (currently 1000ms).

        var too_slow = jsPsych.data.get().filterCustom(
            function (incorrect_trials) {
                return (incorrect_trials.test_part == "test") && (incorrect_trials.rt === null);
            }
        ).count();

        var too_early = Math.round(too_fast + false_alarms.count());

        // calculate proportion of false alarms (responses to fixations)
        var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);

        // calculate reaction time
        var rt = Math.round(correct_trials.select('rt').mean());

        return "<p>Din gennemsnitlige reaktionstid var </p>" +
            "<p><strong> " + rt + " ms </strong></p>" +
            "<p>Du trykkede for tidligt " + too_early + " gange </p>" +
            "</div>" +
            "<p class='gap-above'><strong><i>Tryk på en tast for at afslutte denne reaktionstids-test</strong></i></p>";
    },
    on_finish: function (data) {
        // get data
        var trials = jsPsych.data.get().filter({ test_part: 'test' });
        var fixations = jsPsych.data.get().filter({ test_part: 'fixation' });


        var correct_trials = trials.filter({ correct: true });
        var false_alarms = fixations.filter({ key_press: 32 });
        var too_fast = jsPsych.data.get().filterCustom(
            function (trials) {
                return (trials.test_part == "test") && (trials.key_press === 32) && (trials.rt < 100);
            }
        ).count();

        var too_slow = jsPsych.data.get().filterCustom(
            function (incorrect_trials) {
                return (incorrect_trials.test_part == "test") && (incorrect_trials.rt === null);
            }
        ).count();
        var rt = Math.round(correct_trials.select('rt').mean());
        var too_early = Math.round(too_fast + false_alarms.count());
        // calculate all hits between 1 and 1000 ms
        var hits = Math.round(correct_trials.count() / trials.count() * 100);
        var falsealarm = Math.round(false_alarms.count() / fixations.count() * 100);

        data.summary = { RT: rt, HITSinPCT: hits, FALSE_AND_EARLY_RESPONSES: too_early, MISSES: too_slow };
    }
};
timeline_cv.push(debrief_block);