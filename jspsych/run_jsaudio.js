// Displays audio test page at beginning of experiment, to make sure participants' browsers allow audio playback (Safari rarely does)
// Nothing is written to the datafile

var timeline_audio = [];

/* audio test trial */
var soundcheck = [
  // { stimulus: "sounds/452sine.mp3", data: { test_part: 'soundcheck', correct_response: 'space' } }
  { stimulus: "sounds/452sine.mp3" }
];

var check = {
  type: "audio-keyboard-response",
  stimulus: jsPsych.timelineVariable('stimulus'),
  choices: ['space'],
  trial_duration: 600,
  prompt: "<img src='img/au_logo.png'></img> <img src='img/mib_logo.png'></img>" +
  "<p><div style='font-size:22px;''><strong>Skru nu langsomt op for lyden.</strong></div></p>" +
  "<p class='gap-above'</p" +
  "<p> Når du tydeligt hører lyden vi afspiller nu, er du klar til at tage testen.</p>" +
  "<p> <strong>Tryk på mellemrumstasten for at starte.</strong> </p>" +
  "<p class='largegap-above'</p" +
  "<p>  Hvis du ikke kan høre lyden, selvom du har skruet op på din computer, kan det skyldes problemer med din browsers standard-indstillinger.</p>" +
  "<p> Vi anbefaler, at du lukker vinduet ned og åbner testen i en anden browser." +
  "<p>Chrome, Firefox og Edge fungerer.</p>"
};

var check_procedure = {
  timeline: [check],
  loop_function: function(data){
    if(jsPsych.pluginAPI.convertKeyCharacterToKeyCode('NO_KEYS') == data.values()[0].key_press){
        return true;
    } else {
        return false;
    }
},
  timeline_variables: soundcheck,
    }

timeline_audio.push(check_procedure);



var audio = ['sounds/452sine.mp3'];

function run_jsaudio() {
  jsPsych.init({
    timeline: timeline_audio,
    display_element: 'js_audio',
    preload_audio: audio,
    use_webaudio: true,
    on_finish: function() {
      var json_data = jsPsych.data.get().json();
      Shiny.onInputChange("jsaudio_results", json_data);
      next_page();
    }
  });
}
run_jsaudio();
