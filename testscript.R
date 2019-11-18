###################

###################
# INITIALIZE      #
###################

install.packages('devtools')
devtools::install_github('pmcharrison/psychTestR')
devtools::install_github('pmcharrison/mpt')


library(psychTestR)
library(tidyverse)
library(htmltools)
library(shiny)
library(tibble)
library(stringr)
library(varhandle)
library(mpt)

#setwd("C:/Users/nch/Desktop/pmcharrison-psychTestR-bcc0e86")    # Specify where to save output files when running locally
#setwd("C:/Users/au213911/Documents/jspsych")




# For jsPsych
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

# Configure options
config <- test_options(title="Dansk Gold-MSI",
                       admin_password="g0ldms1",
                       researcher_email="Ni3lsChrHansen@gmail.com",
                       problems_info="Problemer? Kontakt venligst Niels Chr. Hansen på Ni3lsChrHansen@gmail.com.",
                       languages = "DA",
                       display = display_options(
                         full_screen = TRUE,
                         content_background_colour = "grey",
                         css = c(file.path(library_dir, "css/jspsych.css"), 
                                 "jspsych/css/RT_DK.css")
                       ))
# INTRO
intro <- one_button_page(body = div(HTML("<img src='img/au_logo.png'></img> <img src='img/mib_logo.png'></img>"),
                                p(h4(strong("Forskning har vist...")),
                                    div(p("...at musikalsk træning, musikalitet og reaktionstid hænger sammen."),
                                        p("Men hvad kom først: hønen eller ægget? Kan man være musikalsk, selvom man aldrig har sat sine ben i et musiklokale? Og ved du hvor musikalsk du er, sammenlignet med resten af befolkningen?"),
                                        p(strong("Tag testen og del evt. dit resultat med dine venner."),
                                        HTML("<br>"),
                                        p("Klik på knappen nedenfor og få mulighed for at deltage i en større videnskabelig undersøgelse og en lodtrækning om 12 gavekort på kr 500,-"),
                                        align="center"))),
                         button_text="Næste"))

# WELCOME PAGE
welcome <- one_button_page(body = div(HTML("<img src='img/au_logo.png'></img> <img src='mib_logo.png'></img>"),
                                p(h2(strong("Hvor musikalsk er du?")),
                                      div(p("Tak for din interesse i dette videnskabelige projekt om musikalitet og mental hastighed i den generelle danske befolkning udført af Aarhus Universitet."),
                                          p("Denne undersøgelse tager ca. 25 minutter. Først skal du besvare et spørgeskema. Derefter tester vi (i vilkårlig rækkefølge) din reaktionstid og din evne til at høre om en sanger synger rent eller falsk."),
                                          p(strong("Du skal bruge en computer med tastatur og det er vigtigt, at du gennemfører lyttetesten i stille omgivelser og bruger høretelefoner."),
                                          HTML("<br>"),
                                          p("- Jeg forstår, at ved at klikke videre nedenfor giver jeg samtykke til, at min besvarelse inkluderes i studiet 'Musical sophistication and mental speed in the Danish general population'. Mine personoplysninger behandles i overensstemmelse med samtykkeerklæringen (som kan findes i fuld tekst her: [LINK til samtykkeerklæringen])."),
                                          p("- Jeg kan til enhver tid anmode om at få slettet mine data ved at kontakte den forsøgsansvarlige, Cecilie Møller på cecilie@clin.au.dk."),
                                          HTML("<br>"),
                                          p("Jeg afgiver hermed mit samtykke til, at mine persondata behandles i overensstemmelse med samtykkeerklæringen:"),
                                          align="center"))),
                           button_text="Acceptér"))

# GMSI FEEDBACK
gmsi_feedback <-   reactive_page(function(state, count, ...) {              # Feedback page
  one_button_page(div(p(paste0("Din Gold-MSI score er: ",get_global("GeneralMusicalSophistication",state=state))),
                      p(paste0("Det gør dig mere musikalsk sofistikeret end ",sum(get_global("GeneralMusicalSophistication",state=state)>=GeneralPercentiles),"% af befolkningen!")),
                      p(paste0("Nu er vi nået til de tests, hvor skal du bruge hovedtelefoner. Først skal du indstille lydniveauet på din computer."),
                      p(strong("Skru helt ned for lyden) og tage hovedtelefonerne på, inden du trykker på knappen nedenfor."))),
                  button_text="Afspil lydeksempel")
})

# THANKS, GOODBYE AND SHARE PAGE
goodbye <- final_page(div(HTML("<img src='img/au_logo.png'></img> <img src='img/mib_logo.png'></img>"),
                          p(h3(strong("Det var det. Tak for hjælpen!"))),
                          p(strong("Vinderne af lodtrækningspræmierne får direkte besked.")),
                          HTML("<br>"),
                          #p(paste0("Du har nu videnskabens ord for at du er mere musikalsk sofistikeret end ",sum(get_global("GeneralMusicalSophistication",state=state)>=GeneralPercentiles),"% af befolkningen!")),
                          
                          p("Vi håber du synes det var sjovt at være med."),
                          p("Hvis du er nysgerrig efter hvordan dine venner placerer sig, kan du dele testen ved at trykke på facebook og/eller twitter - knappen herunder."),
                          p("Det vil også være en stor hjælp for os, at så mange som muligt får mulighed for at tage testen."),
                          p("Dit eget resultat bliver ikke vist, med mindre du selv skriver det i opslaget."),
                          HTML("<br>"),
                          HTML('<iframe src="https://www.facebook.com/plugins/share_button.php?href=http%3A%2F%2Fffjenkins.uni.au.dk:3838/hvor_musikalsk_er_du%2F&layout=button&size=large&width=100&height=100&appId" width="74" height="28" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true" allow="encrypted-media"></iframe>'),
                          HTML('<a href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-size="large" data-url="http://http://ffjenkins.uni.au.dk:3838/hvor_musikalsk_er_du" data-lang="da" data-show-count="false">Tweet</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>'),
                          HTML("<br>"),
                          p("............."),
                          HTML("<br>"),
                          p("Du kan nu lukke browser-vinduet.")))
# CALIBRATION TEST  #
#####################

calibration <- volume_calibration_page(url="http://media.gold-msi.org/test_materials/MPT/training/in-tune.mp3", type="mp3",
                                       button_text="Lydniveauet er fint nu. Fortsæt",
                                       #on_complete=,
                                       #admin_ui=,
                                       prompt= div(h4(strong("Indstilling af lydniveau")), 
                                                   p(strong("Hvis du ikke allerede har gjort det, så tag venligst hovedtelefoner på nu."),
                                                     p("Indstil lyden på din computer, så lydniveauet er komfortabelt for dig."),
                                                     p("............."),   
                                                     p("Hvis ikke du hører den lyd vi afspiller nu, så check dine indstillinger på computeren."),
                                                     p("Du kan kun deltage i denne del af undersøgelsen, hvis din computer kan afspille lyden."),
                                                     p("I modsat fald er du desværre nødt til at stoppe her og lukke ned for dit browser-vindue."))))



#####################
# DEFINE EXPERIMENT #
#####################

hep <- join(
  new_timeline(join(
    intro,
    welcome,                                                # Intro page
    calibration                                            # Sound calibration page,
  ), default_lang="DA"),
    new_timeline(join(
    elt_save_results_to_disk(complete = TRUE),              # Default save function
    goodbye
  ), default_lang = "DA")
)
#####################
make_test(hep,opt=config)
#####################
