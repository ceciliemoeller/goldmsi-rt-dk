#######################################################
# psychTestR implementation of                        #     
#                                                     #
# - Danish GoldMSI                                    #
#                                                     #
# - basic auditory, visual and visual choice reaction #
# time tests (originally written in jsPsych)          #
#                                                     #
# - Danish version of "the mistuning perception test" #
#                                                     #
# Authors: Niels Chr. Hansen, Cecilie Møller          #
#          and Peter Harrison                         #
#                                                     #
# Date: 2019-11-13                                    #
#######################################################


###################
# INITIALIZE      #
###################

#install.packages('Rcpp') # when reinstalling packages below, R complained that Rcpp was missing. This was an easy fix. 

#install.packages('devtools')
#devtools::install_github('pmcharrison/psychTestR')
#devtools::install_github('pmcharrison/mpt')


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
                       admin_password="", # write a secret password here
                       researcher_email="Ni3lsChrHansen@gmail.com",
                       problems_info="Problemer? Kontakt venligst Niels Chr. Hansen på Ni3lsChrHansen@gmail.com.",
                       languages = "DA",
                       display = display_options(
                         full_screen = TRUE,
                         content_background_colour = "grey",
                         css = c(file.path(library_dir, "css/jspsych.css"), 
                                 "jspsych/css/RT_DK.css")
                       ))

# For GMSI
# Question text
revCode <- c(1,1,1,1,1,1,1,1,0,1,0,1,0,0,1,1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1) # Reverse coding key (1=positive, 0=negative)
GeneralCode <- c(1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0,1,1,1,0,1,0,1,1,0,1,1,0,0,0,1,0)
GeneralPercentiles <- c(32,37,41,43,46,48,50,51,53,54,55,56,57,58,59,60,61,62,63,64,64,65,66,67,67,68,69,69,70,71,71,72,73,73,74,75,75,76,76,77,77,78,79,79,80,80,81,81,82,82,83,84,84,85,85,86,86,87,87,88,89,89,90,90,91,91,92,93,93,94,94,95,96,96,97,98,98,99,100,100,101,102,103,103,104,105,106,107,107,108,109,110,111,113,114,115,117,118,121,126)
qText <- c("Jeg bruger meget af min fritid på musik-relaterede aktiviteter.",
           "Jeg vælger ofte at lytte til musik, der kan give mig gåsehud.",
           "Jeg kan godt lide at skrive om musik, for eksempel på blogs og internet-fora.",
           "Hvis nogen begynder at synge en sang, jeg ikke kender, kan jeg som regel ret hurtigt synge med.",
           "Jeg er i stand til at vurdere hvorvidt én der synger er dygtig eller ej.",
           "Jeg er for det meste bevidst om, at det er første gang, jeg hører en sang.",
           "Jeg kan synge eller spille musik udenad.",
           "Min interesse vækkes af musikalske stilarter, som jeg ikke kender til, og jeg får lyst til at lære dem bedre at kende.",
           "Musikstykker fremkalder sjældent følelser i mig.",
           "Jeg er i stand til at ramme de rigtige toner, når jeg synger med på en musikindspilning, som jeg lytter til.",
           "Jeg har svært ved at opdage fejl i en bestemt udgave af en sang, selv hvis jeg kender nummeret.",
           "Jeg kan sammenligne og diskutere forskelle mellem to opførelser eller udgaver af det samme stykke musik. ",
           "Jeg har svært ved at genkende en sang, når den spilles på en anden måde eller af en anden kunstner end den jeg kender.",
           "Jeg har aldrig fået ros for mine talenter som udøvende musiker.",
           "Jeg læser ofte om eller søger på internettet efter ting, der handler om musik.",
           "Jeg udvælger ofte en bestemt type musik, når jeg skal motiveres eller stimuleres til noget.",
           "Jeg er ikke i stand til at synge en over- eller understemme når nogen synger en velkendt melodi.",
           "Jeg kan høre, når folk synger eller spiller ude af takt.",
           "Jeg er i stand til at identificere, hvad der er særligt ved et bestemt stykke musik.",
           "Jeg er helt fint i stand til at tale om de følelser et musikstykke vækker i mig.",
           "Jeg bruger ikke mange penge på musik.",
           "Jeg kan høre, når folk synger eller spiller falsk.",
           "Når jeg synger, har jeg ingen idé om hvorvidt jeg synger falsk eller ej.",
           "Det er som om jeg er afhængig af musik - jeg ville ikke kunne leve uden.",
           "Jeg kan ikke lide at synge offentligt, fordi jeg er bange for at komme til at synge nogle forkerte toner.",
           "Når jeg hører et stykke musik, kan jeg normalt identificere genren.",
           "Jeg vil ikke betragte mig selv som musiker.",
           "Jeg bider mærke i ny musik, som jeg støder på (fx nye kunstnere eller indspilninger).",
           "Efter at have hørt en ny sang to eller tre gange, plejer jeg selv at kunne synge den.",
           "Jeg behøver kun at høre en ny melodi en enkelt gang, for at kunne synge den igen flere timer efter.",
           "Som regel vækker musik minder om mennesker, jeg har kendt eller steder, jeg har været.",
           "Jeg har regelmæssigt og dagligt øvet mig på et musikinstrument (inklusive sangstemmen) i ________.",
           "Da min interesse var på sit højeste, øvede jeg mig på mit primære instrument ______ om dagen.",
           "Jeg har været til ________ koncerter som publikum i løbet af de sidste 12 måneder.",
           "Jeg har fået undervisning i musikteori i ____________.",
           "I løbet af min levetid har jeg fået undervisning i at spille et musikinstrument (inklusive sangstemmen) i ___________.",
           "Jeg kan spille på _______ musikinstrumenter.",
           "Jeg lytter opmærksomt til musik ________ om dagen.")

# Response options
qResp <- list()
nDef <- 31   # Number of questions with default response options
defResp <- str_pad(c("Fuldstændig uenig","Meget uenig","Uenig","Hverken uenig eller enig","Enig","Meget enig","Fuldstændig enig"),24,"both")
specResps <- list(str_pad(c("0 år","1 år","2 år","3 år","4-5 år","6-9 år","10 eller flere år"),24,"both"),
                  str_pad(c("0 timer","1/2 time","1 time","1.5 time","2 timer","3-4 timer","5 eller flere timer"),24,"both"),
                  str_pad(c("0","1","2","3","4-6","7-10","11 eller flere"),24,"both"),
                  str_pad(c("0 år","0.5 år","1 år","2 år","3 år","4-6 år","7 eller flere år"),24,"both"),
                  str_pad(c("0 år","0.5 år","1 år","2 år","3-5 år","6-9 år","10 eller flere år"),24,"both"),
                  str_pad(c("0","1","2","3","4","5","6 eller flere"),24,"both"),
                  str_pad(c("0-15 min.","15-30 min.","30-60 min.","60-90 min.","2 timer","2-3 timer","4 timer eller mere"),24,"both"))
for (i in 1:nDef) qResp[[i]] <- defResp
for (j in 1:length(specResps)) qResp[[j+nDef]] <- specResps[[j]]

# Question names
keys <- vector(mode="character")
for (k in 1:length(qText)) keys <- c(keys,paste0("GMSI_Q",k))

items <- tibble(id=keys,prompt=qText)
num_items <- nrow(items)


######################################
# SURVEY ELEMENTS                    #
######################################

# INTRO
intro <- one_button_page(body = div(HTML("<img src='img/au_logo.png'></img> <img src='img/mib_logo.png'></img>"),
                                    div(h4(strong("DENNE TEST ER STADIG UNDER OPBYGNING! DINE SVAR BLIVER IKKE GEMT.")),
                                        HTML("<br>"),
                                        h4(strong("Forskning har vist...")),
                                          p("...at musikalsk træning, musikalitet og reaktionstid hænger sammen."),
                                          p("Men hvad kom først: hønen eller ægget? Kan man være musikalsk, selvom man aldrig har sat sine ben i et musiklokale? Og ved du hvor musikalsk du er, sammenlignet med resten af befolkningen?"),
                                          p(strong("Tag testen og del evt. dit resultat med dine venner.")),
                                          p("Klik på knappen nedenfor og få mulighed for at deltage i en større videnskabelig undersøgelse og en lodtrækning om 12 gavekort på kr 500,- til Ticketmaster."),
                                          align="center")),
                                    button_text="Næste")

# DEVICE PAGE
device <-dropdown_page(
  label = "device",
  prompt = div(HTML("<br>"),
               p(strong("Du skal bruge en computer med tastatur og det er vigtigt, at du gennemfører lyttetesten i stille omgivelser og bruger hovedtelefoner.")),
               p(strong("Du kan altså IKKE tage testen på f.eks. en smartphone med touchscreen.")),
               HTML("<br>"),
               h2(strong("Test af dit udstyr")),
               p("For at beskytte dine ører, vil vi bede dig skrue næsten helt ned for lyden på din computer nu."),
               p("Hvilken type IT-udstyr bruger du til at tage testen?")),
  save_answer=TRUE,
  choices = c("Vælg","Bærbar computer med indbygget tastatur", "Bærbar computer med eksternt tastatur", "Stationær computer"),
  alternative_choice = TRUE,
  alternative_text = "Andet (udfyld venligst)",
  next_button_text = "Næste",
  max_width_pixels = 350,
  validate = function(answer, ...) {
    if (answer=="Vælg")
      "Angiv venligst hvilken type udstyr du benytter. Hvis du ikke anvender et tastatur, kan du kun gennemføre den ene del af testen og du kan derfor ikke deltage i lodtrækningen."
    else TRUE
  },
  on_complete = function(answer, state, ...) {
    set_global(key = "device", value = answer, state = state)
  }     
)



#  AUDIO TESTS PAGE   
uia <- tags$div(
  head,
  includeScript("jspsych/run_jsaudio.js"),
  tags$div(id = "js_audio", style = "min-height: 90vh")
)

elt_jsaudio <- page(
  ui = uia,
  label = "jsaudio",
  get_answer = function(input, ...) input$jsaudio_results,
  validate = function(answer, ...) nchar(answer) > 0L,
  save_answer = TRUE
)

# WELCOME PAGE
welcome <- one_button_page(body = div(HTML("<img src='img/au_logo.png'></img> <img src='img/mib_logo.png'></img>"),
                                      div(h2(strong("Hvor musikalsk er du?")),
                                          p("Tak for din interesse i dette videnskabelige projekt om musikalitet og mental hastighed i den generelle danske befolkning udført af Aarhus Universitet."),
                                          p("Du kan deltage, hvis du er mindst 18 år gammel, og hvis du forstår de danske instruktioner, uanset om du bor i Danmark eller ej."),
                                          p("Denne undersøgelse tager ca. 20 minutter. Først skal du besvare et spørgeskema. Derefter tester vi (i vilkårlig rækkefølge) din reaktionstid og din evne til at høre om en sanger synger rent eller falsk."),
                                          HTML("<br>"),
                                          p("............."),
                                          HTML("<br>"),
                                          p("- Jeg er 18 år gammel eller ældre"),
                                          HTML("- Jeg forstår, at ved at klikke videre nedenfor giver jeg samtykke til, at min besvarelse inkluderes i studiet 'Musical sophistication and mental speed in the Danish general population'. Mine personoplysninger behandles i overensstemmelse med samtykkeerklæringen, som kan læses i sin fulde længde <A target='_blank' HREF='http://musicinthebrain.au.dk/fileadmin/Musicinthebrain/InformedconsentCecilieupdate.pdf' >HER.</A>"),
                                          p("- Jeg kan til enhver tid trække mit samtykke til behandling af personoplysninger tilbage ved at kontakte den forsøgsansvarlige, Cecilie Møller, på cecilie@clin.au.dk."),
                                          HTML("<br>"),
                                          p("Jeg afgiver hermed mit samtykke til, at mine persondata behandles i overensstemmelse med samtykkeerklæringen:"),
                                          align="center")),
                           button_text="Acceptér")


# DEMOGRAPHICS
demographics <- c(
  
  
  # ZIP CODE
  text_input_page(
    label = "zip_code",
    prompt = div(p("Først vil vi lige bede om lidt baggrundsinfo. Vi bruger denne information til at sikre, at vi modtager besvarelser fra et bredt udsnit af den danske befolkning."),
                 p("Hvad er dit 4-cifrede postnummer? (Skriv 0000 hvis du ikke bor i Danmark)")),
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
       if (answer==""|!check.numeric(answer,only.integer=T)|nchar(answer)!=4)
         "Skriv venligst dit 4-cifrede postnummer i hele tal uden andre tegn."
       else TRUE
     },
    on_complete = function(answer, state, ...) {
      set_global(key = "zip_code", value = answer, state = state)
    }),
  
  # AGE
  text_input_page(
    label = "age",
    prompt = "Hvad er din alder (i år)?",
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
      if (answer==""|!check.numeric(answer,only.integer=T))
        "Skriv venligst din alder i et helt tal uden ord som 'år', 'måneder', kommaer eller andre specialtegn."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "age", value = answer, state = state)
    }),
  
  # GENDER
  NAFC_page(
    label = "gender",
    prompt = "Hvad er dit køn?", 
    choices = c("Kvinde","Mand","Andet / ønsker ikke at oplyse"),
    on_complete = function(answer, state, ...) {
      set_global(key = "gender", value = answer, state = state)
    }),
  
  # NATIONALITY
  dropdown_page(
    label = "nationality",
    prompt = "Hvad er din nationalitet?",
    save_answer=TRUE,
    choices = c("Vælg", "Dansk", "Finsk", "Færøsk", "Grønlandsk", "Islandsk", "Norsk", "Svensk"),
    alternative_choice = TRUE,
    alternative_text = "Andet (skriv venligst hvilket)",
    next_button_text = "Næste",
    max_width_pixels = 250,
    validate = function(answer, ...) {
      if (answer=="Vælg")
        "Skriv venligst din nationalitet."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "nationality", value = answer, state = state)
    }     
  ),
  
 
  # RESIDENCE
  dropdown_page(
    label = "residence",
    prompt = "I hvilket land bor du?",
    save_answer=TRUE,
    choices = c("Vælg", "Danmark", "Finland", "Færøerne", "Grønland", "Island", "Norge", "Sverige"),
    alternative_choice = TRUE,
    alternative_text = "Andet (skriv venligst hvilket)",
    next_button_text = "Næste",
    max_width_pixels = 250,
    validate = function(answer, ...) {
      if (answer=="Vælg")
        "Skriv venligst, hvor du bor."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "residence", value = answer, state = state)
    }     
  ),
 
  
  # CHILDHOOD/YOUTH COUNTRY
  dropdown_page(
    label = "youth_country",
    prompt = "I hvilket land har du tilbragt størstedelen af din barndom/ungdom?",
    save_answer=TRUE,
    choices = c("Vælg", "Danmark", "Finland", "Færøerne", "Grønland", "Island", "Norge", "Sverige"),
    alternative_choice = TRUE,
    alternative_text = "Andet (skriv venligst hvilket)",
    next_button_text = "Næste",
    max_width_pixels = 250,
    validate = function(answer, ...) {
      if (answer=="Vælg")
        "Besvar venligst spørgsmålet."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "youth_country", value = answer, state = state)
    }     
  ),
  
 
  # EMPLOYMENT
  NAFC_page(
    label = "employment",
    prompt = "Hvad er din nuværende beskæftigelse?", 
    choices = c("0.-10. klasse",
                "Elev på gymnasial uddannelse (fx gymnasium, HF, HTX, HHX)",
                "Studerende på videregående uddannelse",
                "Fuldtidsbeskæftiget lønmodtager",
                "Deltidsbeskæftiget lønmodtager",
                "Selvstændig",
                "Hjemmegående",
                "Ledig",
                "Pensionist/efterlønsmodtager"),
    on_complete = function(answer, state, ...) {
      set_global(key = "employment", value = answer, state = state)
    }),
    
  # EDUCATION
  NAFC_page(
    label = "education_completed",
    prompt = "Hvad er det højeste uddannelsesniveau, du har opnået?", 
    choices = c("9. eller 10. klasse",
                "Gymnasial uddannelse (fx gymnasium, HF, HTX, HHX)",
                "Faglært",
                "Kort videregående uddannelse",
                "Mellemlang videregående uddannelse (3-4 år)",
                "Lang videregående uddannelse (min. 5 år)",
                "Stadig under uddannelse"),
    on_complete = function(answer, state, ...) {
      set_global(key = "education_completed", value = answer, state = state)
      if (answer!="Stadig under uddannelse") skip_n_pages(state,1)
    }),

  # EXPECTED EDUCATION
  NAFC_page(
    label = "education_expected",
    prompt = "Hvad er det højeste uddannelsesniveau, du forventer at opnå?",
    choices = c("9. eller 10. klasse",
                "Gymnasial uddannelse (fx gymnasium, HF, HTX, HHX)",
                "Faglært",
                "Kort videregående uddannelse",
                "Mellemlang videregående uddannelse (3-4 år)",
                "Lang videregående uddannelse (min. 5 år)",
                "Ikke relevant"),
    on_complete = function(answer, state, ...) {
      set_global(key = "education_expected", value = answer, state = state)
    }),

  # # PREFERRED MUSICAL GENRE
  # NAFC_page(
  #   label = "genre",
  #   prompt = "Hvilken musikalsk genre lytter du mest til?", 
  #   choices = c("Rock/pop",
  #               "Jazz",
  #               "Klassisk"),
  #   on_complete = function(answer, state, ...) {
  #     set_global(key = "genre", value = answer, state = state)
  #   }),
  
    #GAMING HABITS
  text_input_page(
    label = "gaming",
    prompt = "Hvor mange timer om måneden bruger du typisk på at spille action-spil på computer? Medregn kun spil, som kræver, at du reagerer hurtigt. Angiv et helt tal her:",
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
      if (answer==""|!check.numeric(answer,only.integer=T))
        "Skriv venligst et helt tal for hvor mange timer du spiller action-spil om måneden - uden ord som 'timer', 'minutter', kommaer eller andre specialtegn. Skriv '0' hvis du slet ikke spiller."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "gaming", value = answer, state = state)
    })
)


# RANDOMISER
randomiser <- code_block(function(state, ...) {
  item_order <- sample(x = num_items, 
                       size = num_items,
                       replace = FALSE)
  save_result(place = state, 
              label = "item_order", 
              value = item_order)
  set_local(key = "item_order",
            value = item_order,
            state = state)
})


# GMSI ITEMS
# Function for generating items
item <- function(id, prompt, choices, qNo) {
  NAFC_page(
    label = id,
    prompt = prompt, 
    choices = choices,
    on_complete = function(state, answer, ...) {
      set_local("item_pos", 
                1L + get_local("item_pos", state),
                state)
      set_global(key = qNo, value = which(choices==answer), state = state) #which(choices==answer)
    })
}

# Generate GMSI items
show_items <- c(
  code_block(function(state, ...) set_local("item_pos", 1L, state)),
  while_loop(
    test = function(state, ...) get_local("item_pos", state) <= num_items,
    logic = reactive_page(function(state, ...) {
      item_pos <- get_local("item_pos", state)
      item_id <- get_local("item_order", state)[item_pos]
      item(id = items$id[item_id], prompt = items$prompt[item_id], choices = qResp[[item_id]], qNo = keys[item_id])
    }))
)


# INSTRUMENT INPUT
instrument <-dropdown_page(
  label = "instrument",
  prompt = "Det instrument (inklusive sangstemmen) som jeg er bedst til at spille på er:", 
  save_answer=TRUE,
  choices = c("Vælg","Basguitar", "Basun", "Blokfløjte", "Bratch", "Cello", "Fagot", "Guitar (rytmisk, rock/pop/folk etc.)", "Guitar (klassisk)", "Horn", "Klarinet", "Klaver/Keyboard", "Kontrabas", "Obo", "Orgel", "Saxofon", "Sang", "Slagtøj", "Trommer", "Trompet", "Tuba", "Tværfløjte", "Violin", "Jeg kan hverken spille eller synge"),
  alternative_choice = TRUE,
  alternative_text = "Andet (skriv venligst hvilket)",
  next_button_text = "Næste",
  max_width_pixels = 300,
  validate = function(answer, ...) {
    if (answer=="Vælg")
      "Besvar venligst spørgsmålet."
    else TRUE
  },
  on_complete = function(answer, state, ...) {
    set_global(key = "instrument", value = answer, state = state)
  
 
    # Compute response table
    responses <- data.frame(Qid=1:length(keys),RevCode=revCode,GeneralCode=GeneralCode,ResponseVal=integer(length(keys)),NormVal=integer(length(keys)),row.names=keys)
    for (l in 1:length(keys)) {
      responses[l,"ResponseVal"] <- get_global(keys[l],state=state)
      if (responses[l,"RevCode"]==0) responses[l,"NormVal"] <- (responses[l,"ResponseVal"]-8)*-1 else responses[l,"NormVal"] <- responses[l,"ResponseVal"]
    }
    set_global("responses",value=responses,state=state)
    set_global("GeneralMusicalSophistication",value=sum(responses$NormVal[GeneralCode==1],na.rm=T),state=state)
   })

# OLLENS BRIEF
ollen <- NAFC_page(
  label = "ollen",
  prompt = "Hvilken titel beskriver dig bedst?", 
  choices = c("Ikke-musiker",
              "Musikelskende ikke-musiker", 
              "Amatørmusiker", 
              "Seriøs amatørmusiker",
              "Semi-professionel musiker", 
              "Professionel musiker"),
  on_complete = function(answer, state, ...) {
    set_global(key = "ollen", value = answer, state = state)
  })


# EMAIL
email <- c(text_input_page(
  label = "email_future_res",
  prompt = div("(Frivilligt:) Indtast din e-mail-adresse her, hvis vi må kontakte dig med henblik på evt.",
  p(strong("DELTAGELSE I FREMTIDIG FORSKNING:"))),
  save_answer = T,
  button_text = "Næste",
  validate = function(answer, ...) {
        if (answer!=""&!grepl(".*@.*\\.",answer))
          "Skriv venligst en gyldig e-mail-adresse."
    else TRUE
  },
  on_complete = function(answer, state, ...) {
    set_global(key = "email_futureres", value = answer, state = state)
  }),
  
  text_input_page(
    label = "email_prize",
    prompt = div("(Frivilligt:) Når du har gennemført hele denne undersøgelse, har du mulighed for at",
    p(strong("DELTAGE I LODTRÆKNINGEN om et gavekort på kr. 500,- til Ticketmaster.")),
    p("Indtast din e-mail-adresse her, hvis du vil deltage i lodtrækningen:")),
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
      if (answer!=""&!grepl(".*@.*\\.",answer))
        "Skriv venligst en gyldig e-mail-adresse."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "email_prize", value = answer, state = state)
    }))
  

# SAVE GMSI DATA
save_GMSI <- code_block(function(state, ...) {
  save_result(place=state,label="responses",value=get_global("responses",state))
  save_result(place=state,label="GeneralMusicalSophistication",value=get_global("GeneralMusicalSophistication",state))
  })



# GMSI FEEDBACK
gmsi_feedback <-   reactive_page(function(state, count, ...) {              # Feedback page
  one_button_page(div(p(paste0("På en skala fra 18 til 126 er din Gold-MSI score: ",get_global("GeneralMusicalSophistication",state=state))),
                      p(paste0("Det gør dig mere musikalsk sofistikeret end ",sum(get_global("GeneralMusicalSophistication",state=state)>=GeneralPercentiles),"% af befolkningen!")),
                      HTML("<br>"),
                      p("............."),
                      HTML("<br>"),
                      p("Nu er vi nået til de tests, hvor du skal bruge hovedtelefoner. Først skal du indstille lydniveauet på din computer."),
                      p(strong("Skru helt ned for lyden"),"og tag hovedtelefonerne på, inden du trykker på knappen nedenfor.")),
                  button_text="Afspil lydeksempel")
})
# THANKS, GOODBYE AND SHARE PAGE
goodbye <- reactive_page(function(state, ...) {
  final_page(div(HTML("<img src='img/au_logo.png'></img> <img src='img/mib_logo.png'></img>"),
                          p(h3(strong("Det var det. Tak for hjælpen!"))),
                          p(strong("Vinderne af lodtrækningspræmierne får direkte besked.")),
                          HTML("<br>"),
                          p(paste0("Du har nu videnskabens ord for, at du er mere musikalsk sofistikeret end ",sum(get_global("GeneralMusicalSophistication",state=state)>=GeneralPercentiles),"% af befolkningen!")),
                          
                          p("Vi håber du synes det var sjovt at være med."),
                          HTML("<br>"),
                          p("Hvis du er nysgerrig efter hvordan dine venner placerer sig, kan du dele testen ved at trykke på facebook og/eller twitter - knappen herunder."),
                          p("Det vil også være en stor hjælp for os, at så mange som muligt får mulighed for at tage testen."),
                          p("Dit eget resultat bliver ikke vist, med mindre du selv skriver det i opslaget."),
                          HTML("<br>"),
                          HTML('<iframe src="https://www.facebook.com/plugins/share_button.php?href=https%3A%2F%2Fcmb-onlinetest.au.dk%2Fhvor_musikalsk_er_du&layout=button&size=large&width=77&height=28&appId" width="77" height="28" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true" allow="encrypted-media"></iframe>'),
                          HTML('<a href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-size="large" data-text="Jeg har lige deltaget i dette online forskningsprojekt på Center for Music in the Brain. Hvor musikalsk er du?" data-url="https://cmb-onlinetest.au.dk/hvor_musikalsk_er_du" data-via="musicbrainAU" data-lang="da" data-show-count="false">Tweet</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>'),
                          p("............."),
                          HTML("<br>"),
                          p("Du kan nu lukke browser-vinduet.")))
})  


#####################
# CALIBRATION TEST  #
#####################

calibration <- volume_calibration_page(url="https://media.gold-msi.org/test_materials/MPT/training/in-tune.mp3", type="mp3",
                                       button_text="Lydniveauet er fint nu. Start den første test!",
                                       btn_play_prompt = "Klik her for at afspille lyden",
                                       #on_complete=,
                                       #admin_ui=,
                                       prompt= div(p("Hvis du ikke allerede har gjort det, så tag venligst hovedtelefoner på nu."), 
                                       h4(strong("Indstil lyden på din computer, så lydniveauet er komfortabelt for dig.")),
                                       p("............."),
                                       p("Hvis ikke du hører den lyd vi afspiller nu, så check dine indstillinger i browseren eller på computeren."),
                                       p("Du kan kun deltage i denne del af undersøgelsen, hvis din computer kan afspille lyden."),
                                       p("I modsat fald er du desværre nødt til at stoppe her og lukke ned for dit browser-vindue.")))
                                       

#######################
# REACTION TIME TESTS #
#######################
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


################################
# MISTUNING PERCEPTION TEST    #
################################

mistuning <- mpt(num_items=15,
                 dict=mpt::mpt_dict,
                 feedback=psychTestRCAT::cat.feedback.graph("MPT",
                                                            text_finish = "Flot klaret!",
                                                            next_button = "Næste",
                                                            text_score = "I denne 'Mistuning Perception'- test kan man score fra -3 til +3. Din endelige score er:",
                                                            text_rank = "Din placering (tallet før skråstregen) i forhold til tidligere deltagere (tallet efter skråstregen):",
                                                            x_axis = "'Mistuning perception'-score for alle tidligere deltagere (din score er markeret med en rød linje)",
                                                                     # "Hvis du har lyst, kan du downloade figuren her ved at føre musen henover og klikke på kameraet i menulinien over figuren.",
                                                            y_axis = "Antal deltagere",
                                                            explain_IRT = FALSE),
               take_training = T)




#####################
# DEFINE EXPERIMENT #
#####################

experiment <- join(
   new_timeline(join(
   intro,                                                  # Intro page
   device,                                                 # Device page (laptop/PC w.internal/external keyboard)
   elt_jsaudio,                                            # Audio test page (sound/no sound)
   welcome,                                                # Welcome page, incl. consent
   begin_module("Demographics"),                           # Begin Demographics module
   demographics,                                           # Demographics questions
   end_module(),                                           # End Demographics module
   elt_save_results_to_disk(complete = FALSE),             # Default save function
   begin_module("GMSI"),                                   # Begin GMSI module
   randomiser,                                             # Randomise GMSI questions
   show_items,                                             # Show GMSI questions
   instrument,                                             # Instrument input page
   ollen,                                                  # Ollen's MSI (brief)
   email,                                                  # Email
   save_GMSI,                                              # Save GMSI data
   elt_save_results_to_disk(complete = FALSE),             # Default save function
   gmsi_feedback,                                          # GSMI last page with percentile feedback
   end_module(),                                           # End GMSI module
    calibration                                            # Sound calibration page ,
   ), default_lang="DA"),
   randomise_at_run_time("TestOrder_MPT_RT",
                          list(c(begin_module("MPT"),mistuning,elt_save_results_to_disk(complete = TRUE),end_module()),
                               c(begin_module("RT"),elt_jspsych,elt_save_results_to_disk(complete = TRUE),end_module()))),
    new_timeline(join(
    elt_save_results_to_disk(complete = TRUE),              # Default save function
   goodbye
  #final_page(div(p("Tak for interessen. Vi forventer, at testen bliver tilgængelig til december."),p("Du kan nu lukke vinduet.")))
   ), default_lang = "DA")
)


#########################
# RUN EXPERIMENT        #
#########################

make_test(experiment,opt=config)
#make_test(c(elt_jsaudio, welcome, final_page(div(p("Tak for hjælpen"),p("Du kan nu lukke vinduet.")))), opt=config)

#shiny::runApp(".")


  
