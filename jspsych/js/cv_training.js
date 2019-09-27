var timeline_cv = [];
/* define instructions trial */
var instructions_1 = {
    type: "html-keyboard-response",
    stimulus: "<p><div style='font-size:25px;'><strong>Visuel kompleks reaktionstids-test </strong></div></p>" +
        "<p class='gap-above'>I den følgende opgave skal du bruge fire fingre. </p>" +
        "<p>Placer dem nu som vist på billedet her. </p>" +
            "<p> <img src='img/choicetask.png'></img>" +
        "<p class='gap-above'> <strong><i>Tryk på mellemrumstasten for at læse instruktionen</strong></i></p>",
    
        choices: ['space']
};


var instructions_2 = {
    type: "html-keyboard-response",
    stimulus: "<p>Du vil se fire hvide kasser på skærmen.</p>" +
        // "<div style='width: 900px;'>" +
        "<div class='instr-img'>" +
        "<img src='img/cRT_fix.png'></img>" +
        
        "<p class='smallgap-above'class='small'><strong>Vent!</strong></p>" +
        "</div>" +
        "<p class='gap-above'>Hver gang du ser et kryds i én af kasserne, " +
        "skal du trykke på den </p>" +
        "<p>tilhørende tastatur-tast så hurtigt som du kan:</p>" +
        "<div class='instr-img'>" +
        "<img src='img/reminder.png'></img>" +
        "</div>" +
        "<p class='gap-above'> Du får lov til at prøve det nogle gange først.</p>" +
        "<p class='smallgap-above'> <strong><i>Tryk på mellemrumstasten for at starte træningsrunden.</strong></i></p>",
        choices: ['space']
};
timeline_cv.push(instructions_1);
timeline_cv.push(instructions_2);

/* training trials */
var training_stimuli = [
    { stimulus: "img/cRT1.png", data: { test_part: 'test', correct_response: 'z' } },
    { stimulus: "img/cRT2.png", data: { test_part: 'test', correct_response: 'x' } },
    { stimulus: "img/cRT3.png", data: { test_part: 'test', correct_response: ',' } },
    { stimulus: "img/cRT4.png", data: { test_part: 'test', correct_response: '.' } }
];

var training_fixation = {
    type: 'image-keyboard-response',
    stimulus: "img/cRT_fix.png",
    choices: ['z', 'x', ',', '.'],
    trial_duration: function () {
        return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
    },
    data: { test_part: 'training_fixation', correct_response: 'null' },
    response_ends_trial: false
};


var training = {
    type: "image-keyboard-response",
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['z', 'x', ',', '.'],
    trial_duration: 1000,
    data: jsPsych.timelineVariable('data'),
    on_finish: function (data) {
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response) && data.rt > 100
    }
};

var training_procedure = {
    timeline: [training_fixation, training],
    sample: {
        type: 'fixed-repetitions',
        size: 2, // 2 repetitions of each trial, 8 total trials, order is randomized.
    },
    timeline_variables: training_stimuli
}

timeline_cv.push(training_procedure);

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

        //count incorrect trials (too slow (>1000 ms) and too fast (0-150 ms))
        var no_inc = incorrect_trials.count();

        return "<p>Din gennemsnitlige reaktionstid her i træningsrunden var </p>" +
            "<p><strong> " + tr_rt + " ms </strong></p>" +
            "<p>Du trykkede for tidligt " + too_early + " gange </p>" +
            "</div>" +
            "<p class='gap-above'><strong><i>Tryk på en tast for at fortsætte</strong></i></p>";
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

        data.summary = { RT: tr_rt, ACC_pct: tr_accuracy, Too_Early: tr_too_early, Too_Slow: tr_too_slow };
    }
};
timeline_cv.push(training_debrief_block);