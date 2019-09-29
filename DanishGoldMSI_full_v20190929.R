###############################################
# Danish GoldMSI implementation in psychTestR #
# Author: Niels Chr. Hansen                   # 
# Date: 2019-09-28                            #
###############################################


###################
# INITIALIZE      #
###################
library(psychTestR)
library(tidyverse)
library(htmltools)
library(shiny)
library(tibble)
library(stringr)
library(varhandle)

#setwd("C:/Users/nch/Desktop/pmcharrison-psychTestR-bcc0e86")    # Specify where to save output files when running locally

# Configure options
config <- test_options(title="Dansk Gold-MSI",
             admin_password="g0ldms1",
             researcher_email="Ni3lsChrHansen@gmail.com",
             problems_info="Problemer? Kontakt venligst Niels Chr. Hansen på Ni3lsChrHansen@gmail.com.")

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
           "Jeg kan sammenligne og diskutere forskelle mellem to opførsler eller udgaver af det samme stykke musik. ",
           "Jeg har svært ved at genkende en sang, når den spilles på en anden måde eller af en anden kunstner end den jeg kender.",
           "Jeg har aldrig fået ros for mine talenter som udøvende musiker.",
           "Jeg læser ofte om eller søger på internettet efter ting, der handler om musik.",
           "Jeg udvælger meget ofte bestemt musik for at motivere eller stimulere mig.",
           "Jeg er ikke i stand til at synge en over- eller under-stemme når nogen synger en velkendt melodi.",
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

# WELCOME PAGE
welcome <- one_button_page(body = div(h2(strong("Hvor musikalsk er du?")),
                                      div(p("Tak for din interesse i dette videnskabelige projekt om musikalitet og mental hastighed i den generelle danske befolkning udført af Aarhus Universitet."),
                                      p("Denne undersøgelse tager ca. 25 minutter. ",strong("Det er vigtigt, at du gennemfører lyttetesten i stille omgivelser og bruger høretelefoner.")," Læs og godkend venligst samtykkeerklæringen på næste side, før vi kan begynde."),align="left")),
                           button_text="Næste")

# CONSENT FORM
consent <- one_button_page(body = div(h3("SAMTYKKEERKLÆRING"),
                                      div(p("I forbindelse med dette forskningsprojekt med AU løbenummer [….] har vi brug for dit samtykke til, at vi må behandle dine personoplysninger i overensstemmelse med Databeskyttelsesforordningen."),
                                          p(strong("Formål"),": The Goldsmiths Musical Sophistication Index (Gold-MSI) er et spørgeskema, der er udviklet af engelske forskere til at undersøge musikalitet i den brede befolkning. Dette forskningsprojekt indsamler normer for den danske befolkning, baseret på svar fra ca. 750 danske respondenter. I tillæg indsamles basale reaktionstidsmål, som kan bidrage til forståelsen af årsag og effekt af nogle af de positive karakteristika, der er associeret med formel hhv. uformel musikalsk træning."),
                                          p("Du kan læse mere om spørgeskemaet her (på engelsk): ",a("https://www.gold.ac.uk/music-mind-brain/gold-msi/", href="https://www.gold.ac.uk/music-mind-brain/gold-msi/")),
                                          p(strong("Dataansvarlig"),": Aarhus Universitet (CVR nr. 31119103) er dataansvarlig for behandlingen af dine personoplysninger."),
                                          p(strong("Projektleder"),"Cecilie Møller er leder af projektgruppen, som kan kontaktes på: Center for Music in the Brain, Aarhus Universitet, Nørrebrogade 44, bygning 1A, 1. sal, 8000 Aarhus C,Danmark, email: ",a("cecilie@clin.au.dk",href="mailto:cecilie@clin.au.dk")),
                                          p(strong("Databeskyttelsesrådgiver"),": Aarhus Universitets databeskyttelsesrådgiver Michael Lund Kristensen kan kontaktes på ",a("mlklund@au.dk",href="mailto:mlklund@au.dk"),", +4593509082."),
                                          p(strong("Personoplysninger, der behandles om dig"),": Vi behandler de personoplysninger om dig, som du afgiver via spørgeskemaet. Det drejer sig konkret om din e-mail. Det er tilladt at undlade at angive sin e-mail. Listen over e-mailadresser vil blive opbevaret i overensstemmelse med bestemmelserne i Databeskyttelsesforordningen og anden relevant dansk lovgivning. Listen over e-mailadresser bliver slettet efter afholdelse af lodtrækningen med mindre du accepterer at forskerne må gemme din e-mailadresse med henblik på at kontakte dig i forbindelse med opfølgning af projektet. I så fald vil din e-mailadresse blive slettet efter 5 år eller når du selv ønsker at trække samtykket tilbage."),
                                          p(strong("Andre modtagere"),": Projektgruppens øvrige medlemmer modtager og behandler det indsamlede datamateriale i anonymiseret form. Det betyder, at dine data vil blive delt med vores samarbejdspartner i projektet, Goldsmiths, University of London. Goldsmiths vil ikke benytte data til andre formål end udførelsen af dette projekt. Dine personoplysninger bliver ikke delt med nogen tredje part."),
                                          p(strong("Mulighed for at trække samtykke tilbage"),": Deltagelse er frivillig, og du kan til enhver tid uden begrundelse trække dit samtykke til behandling af personoplysninger tilbage, uden at det får nogen konsekvenser for dig. Dette kan ske ved henvendelse til projektgruppen (se ovenfor). Hvis du tilbagetrækker dit samtykke, får det først virkning fra dette tidspunkt og påvirker ikke lovligheden af vores behandling op til dette tidspunkt."),
                                          p(strong("Godkendelse"),": Denne samtykkeerklæring godkendes elektronisk i forbindelse med besvarelsen af spørgeskemaet. Dette gøres ved at trykke 'Accepter' nedenfor:"),
                                          p(strong("Jeg afgiver hermed mit samtykke til, at mine persondata behandles i overensstemmelse med samtykkeerklæringen")),
                                          align="left")),
                           button_text="Accepter")

# DEMOGRAPHICS
demographics <- c(
  
  # AGE
  text_input_page(
    label = "age",
    prompt = div(p("Først vil vi lige bede om lidt baggrundsinfo:"),
                 p("Hvad er din alder (i år)?")),
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
       if (!check.numeric(answer,only.integer=T))
         "Skriv venligst din alder i tal (uden komma og ord som 'år' eller 'måneder')."
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
  
  # NATIONALITET
  text_input_page(
    label = "nationality",
    prompt = "Hvad er din nationalitet?",
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
      if (answer=="")
        "Skriv venligst din nationalitet.)."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "nationality", value = answer, state = state)
    }),
  
  # RESIDENCE
  text_input_page(
    label = "residence",
    prompt = "I hvilket land bor du?",
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
      if (answer=="")
        "Skriv venligst, hvor du bor.)."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "residence", value = answer, state = state)
    }),
  
  # CHILDHOOD/YOUTH COUNTRY
  text_input_page(
    label = "youth_country",
    prompt = "I hvilket land har du tilbragt størstedelen af din barndon/ungdom?",
    save_answer = T,
    button_text = "Næste",
    validate = function(answer, ...) {
      if (answer=="")
        "Besvar venligst spørgsmålet.)."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "youth_country", value = answer, state = state)
    }),
  
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
    #validate = function(answer, state, ...) {
    #  if (answer!="Stadig under uddannelse") skip_n_pages(state,1)
    #},
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
                "Stadig under uddannelse"),
    on_complete = function(answer, state, ...) {
      set_global(key = "education_expected", value = answer, state = state)
    }),

  # PREFERRED MUSICAL GENRE
  NAFC_page(
    label = "genre",
    prompt = "Hvilken musikalsk genre lytter du mest til?", 
    choices = c("Rock/pop",
                "Jazz",
                "Klassisk"),
    on_complete = function(answer, state, ...) {
      set_global(key = "genre", value = answer, state = state)
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
instrument <- text_input_page(
  label = "instrument", 
  prompt = "Det instrument (inklusive sangstemmen) som jeg er bedst til at spille på er:", 
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

# EMAIL
email <- text_input_page(
  label = "email",
  prompt = div(p("Hvis vi må kontakte dig med henblik på evt. deltagelse i fremtidig forskning, har vi brug for din emailadresse. Ved deltager du også i lodtrækningen om et gavekort på kr. 500"),
               p("Hvad er din e-mail-adresse?")),
  save_answer = T,
  button_text = "Næste",
  # validate = function(answer, ...) {
  #   if (!grepl(".*@.*\\.",answer))
  #     "Skriv venligst en gyldig e-mail-adresse."
  #   else TRUE
  # },
  on_complete = function(answer, state, ...) {
    set_global(key = "email", value = answer, state = state)
  })

# SAVE GMSI DATA
save_GMSI <- code_block(function(state, ...) {
  save_result(place=state,label="responses",value=get_global("responses",state))
  save_result(place=state,label="GeneralMusicalSophistication",value=get_global("GeneralMusicalSophistication",state))
  })

# LAST PAGE
last_page <-   reactive_page(function(state, count, ...) {              # Feedback page
                final_page(div(p(paste0("Tak for hjælpen! Din Gold-MSI score er: ",get_global("GeneralMusicalSophistication",state=state))),
                               p(paste0("Det gør dig mere musikalsk sofistikeret end ",sum(get_global("GeneralMusicalSophistication",state=state)>=GeneralPercentiles),"% af befolkningen!"))))
  })


#####################
# DEFINE EXPERIMENT #
#####################

experiment <- c(
  welcome,                                                 # Intro page
  consent,                                                 # Consent page
  begin_module("Demographics"),                            # Begin Demographics module
  demographics,                                            # Demographics questions
  #demographics1,                                          # 1st part, Demographics questions
  #demographics_extra,                                     # Extra question if relevant
  #demographics2,                                          # 2nd part, Demographics questions
  end_module(),                                            # End Demographics module
  begin_module("GMSI"),                                    # Begin GMSI module
  randomiser,                                              # Randomise GMSI questions  
  show_items,                                              # Show GMSI questions 
  instrument,                                              # Instrument input page
  email,                                                   # Email
  save_GMSI,                                               # Save GMSI data
  end_module(),                                            # End GMSI module
  elt_save_results_to_disk(complete = TRUE),               # Default save function 
  last_page)                                               # Last page with percentile feedback

#########################
# RUN EXPERIMENT        #
#########################

make_test(experiment,opt=config)




#########################
# OUTTAKES              #
#########################

  # # Begin module
  # begin_module("demographics"),
  # 
  # # Name insert page
  # text_input_page(
  #   label = "name", 
  #   prompt = "Hvad er dit navn?", 
  #   save_answer = T,
  #   validate = function(answer, ...) {
  #     if (answer == "")
  #       "Navnefeltet skal udfyldes, før du kan fortsætte."
  #     else TRUE
  #   },
  #   on_complete = function(answer, state, ...) {
  #     set_global(key = "name", value = answer, state = state)
  #   }),
  # 
  # 
  # # End module
  # end_module(),
  
  ###################
  # GMSI QUESTIONS  #
  ###################
  
  # # Begin module
  # begin_module("GMSI"),
  # 
  # # Preferred instrument page
  # text_input_page(
  #   label = "instrument", 
  #   prompt = "Det instrument (inklusive sangstemmen) som jeg er bedst til at spille på er:", 
  #   on_complete = function(answer, state, ...) {
  #     set_global(key = "instrument", value = answer, state = state)
  #     
  #     # Compute response table
  #     responses <- data.frame(Qid=1:length(keys),RevCode=revCode,ResponseVal=integer(length(keys)),NormVal=integer(length(keys)),row.names=keys)
  #     for (l in 1:length(keys)) {
  #       responses[l,"ResponseVal"] <- get_global(keys[l],state=state)
  #       if (responses[l,"RevCode"]==0) responses[l,"NormVal"] <- (responses[l,"ResponseVal"]-8)*-1 else responses[l,"NormVal"] <- responses[l,"ResponseVal"]
  #       #set_global(key="GMSIscore",value=sum(get_global(key="GMSIscore",state=state),get_global(keys[l],state=state)),state=state)
  #     }
  #     set_global("responses",value=responses,state=state)
  #   }),
  # 
  # code_block(function(state, ...) save_result(place=state,label="responses",value=get_global("responses",state))),
  # 
  # # End module
  # end_module(),
  # 
  # #########################
  # # SURVEY END & FEEDBACK #
  # #########################
  # 
  # # Save data
  # elt_save_results_to_disk(complete = TRUE),
  # 
  # # Final page
  # reactive_page(function(state, count, ...) {
  #   final_page(paste0("Tak for hjælpen, ", get_global("name", state), "!\n","Din samlede Gold-MSI score er: ",sum(get_global("responses",state=state)$NormVal,na.rm=T),"."))
  # }))
