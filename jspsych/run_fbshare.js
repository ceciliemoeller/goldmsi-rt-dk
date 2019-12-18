(function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v3.0";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));


  function run_fbshare() {
    jsPsych.init({
      // timeline: timeline_audio,
      display_element: 'fb_share',
      // preload_audio: audio,
      // use_webaudio: true,
      on_finish: function() {
        var json_data = jsPsych.data.get().json();
        Shiny.onInputChange("fbshare_results", json_data);
        next_page();
      }
    });
  }
  run_fbshare();
  