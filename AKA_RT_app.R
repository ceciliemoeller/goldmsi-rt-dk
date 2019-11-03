library(htmltools)
library(psychTestR)

library_dir <- "jspsych/jspsych-6.1.0"
custom_dir <- "jspsych/js"

head <- tags$head(
  # jsPsych library files
  includeScript(file.path(library_dir, "jspsych.js")),
  includeScript(file.path(library_dir, "plugins/jspsych-html-keyboard-response.js")),
  includeScript(file.path(library_dir, "plugins/jspsych-image-keyboard-response.js")),
  includeScript(file.path(library_dir, "plugins/jspsych-audio-keyboard-response.js")),
  # Custom files
  includeScript(file.path(custom_dir, "welcome.js")),
  includeScript(file.path(custom_dir,"sv_training.js")),
  includeScript(file.path(custom_dir,"sv_real.js")),
  includeScript(file.path(custom_dir,"cv_training.js")),
  includeScript(file.path(custom_dir,"cv_real.js")),
  includeScript(file.path(custom_dir,"sa_training.js")),
  includeScript(file.path(custom_dir,"sa_real.js")),
  includeCSS(file.path(library_dir, "css/jspsych.css")),
  includeCSS("jspsych/css/RT_DK.css")
)

ui <- tags$div(
  head,
  includeScript("jspsych/run_jspsych.js"),
  tags$div(id = "js_psych", style = "min-height: 90vh")
)

elt_jspsych <- page(
  ui = ui,
  label = "jspsych",
  get_answer = function(input, ...) input$jspsych_results,
  validate = function(answer, ...) nchar(answer) > 0L,
  save_answer = TRUE
)

if (FALSE) {
  # To launch the test manually, run the following command.
  # Note that other ways of launching the app may fail to provide access to
  # the required media files.
  shiny::runApp(".")
}

make_test(
  elts = list(
    elt_jspsych,
    elt_save_results_to_disk(complete = TRUE),
    cont<- one_button_page(body = div(h2(strong("Hvor musikalsk er du?")),
                                          div(p("Tak for din interesse i dette videnskabelige projekt om musikalitet og mental hastighed i den generelle danske befolkning udf�rt af Aarhus Universitet."),
                                              p("Denne unders�gelse tager ca. 25 minutter. ",strong("Det er vigtigt, at du gennemf�rer lyttetesten i stille omgivelser og bruger h�retelefoner.")," L�s og godkend venligst samtykkeerkl�ringen p� n�ste side, f�r vi kan begynde."),align="left")),
                               button_text="N�ste"),
   final_page("Du har nu klaret de tre reaktionstidstests!\\Your final scores are plotted below, with reference to the general population")
  ), 
  opt = demo_options(display = display_options(
    full_screen = TRUE,
    content_background_colour = "grey",
    css = c(file.path(library_dir, "css/jspsych.css"), 
            "jspsych/css/RT_DK.css")
  )))
