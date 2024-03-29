
var sub_experiments = [timeline_sv, timeline_cv, timeline_sa];
var shuffledArray = jsPsych.randomization.repeat(sub_experiments, 1);

// timeline = timeline.concat(shuffledArray)

var arrayLength = shuffledArray.length;
for (var i = 0; i < arrayLength; i++) {
    //console.dir(shuffledArray[i]);
    for (var key in shuffledArray[i]) {
      if (shuffledArray[i].hasOwnProperty(key)) {
        console.log(key + " -> " + shuffledArray[i][key]);
        console.dir(shuffledArray[i][key]);
        timeline.push(shuffledArray[i][key]);
      }
    }
}

// an array of paths to sound and images that need to be manually pre-loaded
var images = ['img/cross.png','img/blankbox.png','img/cRT_fix.png', 'img/cRT1.png', 'img/cRT2.png', 'img/cRT3.png', 'img/cRT4.png', 'img/reminder.png', 'img/choicetask.png', 'img/mib_logo.png', 'img/au_logo.png'];
var audio = ['sounds/452sine.mp3'];

function run_jspsych() {
  jsPsych.init({
    timeline: timeline,
    display_element: 'js_psych',
    preload_images: images,
    preload_audio: audio,
    use_webaudio: true,
    on_finish: function() {
      var json_data = jsPsych.data.get().json();
      Shiny.onInputChange("jspsych_results", json_data);
      next_page();
    }
  });
}
run_jspsych();
