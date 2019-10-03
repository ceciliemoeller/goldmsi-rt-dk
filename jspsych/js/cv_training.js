var timeline_cv = [];
/* define instructions trial */
var instructions_1 = {
    type: "html-keyboard-response",
    stimulus: "<p><div style='font-size:25px;'><strong>Visuel kompleks reaktionstids-test </strong></div></p>" +
        "<p class='gap-above'>I den følgende opgave skal du bruge fire fingre. </p>" +
        "<p>Placer dem nu som vist på billedet her. </p>" +
        "<p> <img src='img/choicetask.png'></img>" +
        "<p class='gap-above'> <strong><i>Tryk på mellemrumstasten for at læse instruktionen.</strong></i></p>",

    choices: ['space'],
    data: { cond: 'vis_ch', test_part: 'instructions' },
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
    choices: ['space'],
    data: { cond: 'vis_ch', test_part: 'instructions' },
};
timeline_cv.push(instructions_1);
timeline_cv.push(instructions_2);

/* training trials */
var training_stimuli = [
    { stimulus: "img/cRT1.png", data: { cond: 'vis_ch', test_part: 'training_test', correct_response: 'z' } },
    { stimulus: "img/cRT2.png", data: { cond: 'vis_ch', test_part: 'training_test', correct_response: 'x' } },
    { stimulus: "img/cRT3.png", data: { cond: 'vis_ch', test_part: 'training_test', correct_response: ',' } },
    { stimulus: "img/cRT4.png", data: { cond: 'vis_ch', test_part: 'training_test', correct_response: '.' } }
];

var training_fixation = {
    type: 'image-keyboard-response',
    stimulus: "img/cRT_fix.png",
    choices: ['z', 'x', ',', '.'],
    trial_duration: function () {
        return jsPsych.randomization.sampleWithoutReplacement([1000, 1250, 1500, 1750, 2000, 2250, 2500], 1)[0];
    },
    data: { cond: 'vis_ch', test_part: 'training_fixation', correct_response: 'null' },
    on_finish: function (data) {
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response);
    },
    response_ends_trial: false
};


var training_test = {
    type: "image-keyboard-response",
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: ['z', 'x', ',', '.'],
    trial_duration: 1000,
    data: jsPsych.timelineVariable('data'),
    on_finish: function (data) {
        data.correct = data.key_press == jsPsych.pluginAPI.convertKeyCharacterToKeyCode(data.correct_response) && data.rt > 100
    }
};
// // Fix i morgen:
// https://www.jspsych.org/overview/trial/#dynamic-parameters:
// var feedback = {
//     type: 'html-keyboard-response',
//     stimulus: function(){
//       var last_trial_correct = jsPsych.data.get().last(1).values()[0].correct;
//       if(last_trial_correct){
//         return "<p>Correct!</p>";
//       } else {
//         return "<p>Wrong.</p>"
//       }
//     }
//   }
// ... og add feedback var to timeine below

var feedback_inc = {
    type: 'html-keyboard-response',
    stimulus: function(){
      return "<p><div style='font-size:40px;'><strong>FORKERT TAST </strong></div></p>" +
      "<p class='largegap-above'><div class='instr-img'>" +
      "<img src='img/reminder.png'></img>" +
      "<p class='smallgap-above'> <strong><i>Tryk på mellemrumstasten for at fortsætte træningsrunden...</strong></i></p>" 
     },
     choices: ['space']
  }

  var feedback_slow = {
    type: 'html-keyboard-response',
    stimulus: function(){
      return "<p><div style='font-size:40px;'><strong>FOR LANGSOMT </strong></div></p>" +
      "<p><div style='font-size:25 px;'><strong>Husk, det handler om fart! </strong></div></p>" +
      "<p class='largegap-above'><div class='instr-img'>" +
      "<img src='img/reminder.png'></img>" +
      "<p class='gap-above'> <strong><i>Tryk på mellemrumstasten for at fortsætte træningsrunden...</strong></i></p>" 
     },
     choices: ['space']
  }
 


var if_node_inc = {
    timeline: [feedback_inc],
    conditional_function: function(){
        // get the data from the previous trial,
        // and shout if it was incorrect
        var result = ((jsPsych).data.get().last(1).values()[0].correct === false) && 
          ((jsPsych).data.get().last(1).values()[0].key_press != null);
        return result;
    }
}

var if_node_slow = {
    timeline: [feedback_slow],
    conditional_function: function(){
        // get the data from the previous trial,
        // and shout if there was no response
        return jsPsych.data.get().last(1).values()[0].key_press === null;
    }
}


var training_procedure = {
    timeline: [training_fixation, training_test, if_node_inc, if_node_slow],
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

        var trials = jsPsych.data.get().filter({ test_part: 'training_test' });
        var fixations = jsPsych.data.get().filter({ test_part: 'training_fixation' });

        var correct_trials = trials.filter({ correct: true });

        // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
        var correct_real = jsPsych.data.get().filterCustom(
            function (trial) {
                return (trial.test_part == "training_test") && (trial.correct == true) && (trial.rt > 100);
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
            "<p>og din gennemsnitlige reaktionstid her i træningsrunden var </p>" +
            "<p><strong> " + rt_real + "ms </strong></p>" +

            "<p>Du trykkede for tidligt " + falsealarm_pct + " % af gangene </p>" +
            "</div>" +
            "<p class='gap-above'><strong><i>Tryk på mellemrumstasten for at fortsætte</strong></i></p>";
    },
    choices: ['space'],
    data: { cond: 'vis_ch', test_part: 'feedback_training' },

    on_finish: function (data) {
        // get data
        var trials = jsPsych.data.get().filter({ test_part: 'training_test' });
        var fixations = jsPsych.data.get().filter({ test_part: 'training_fixation' });
        var false_alarms = fixations.filter({ correct: false });
        // exclude trials with response time smaller than 100 ms (considered false anticipatory responses)
        var correct_real = jsPsych.data.get().filterCustom(
            function (trial) {
                return (trial.test_part == "training_test") && (trial.correct == true) && (trial.rt > 100);
            }
        )
        var mistakes = trials.filter({ correct: false });

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
        var count_mistakes = mistakes.count();
        var accuracy = Math.round(correct_real.count() / trials.count() * 100);

        data.summary = { rt_real: rt_real, ant_resp_pct: toofast, fa_pct: falsealarm, mistakes: count_mistakes, ACC: accuracy };
    }
};

timeline_cv.push(training_debrief_block);