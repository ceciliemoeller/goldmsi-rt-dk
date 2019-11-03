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
#setwd("C:/Users/au213911/Documents/jspsych")

# Configure options
config <- test_options(title="Dansk Gold-MSI",
             admin_password="g0ldms1",
             researcher_email="Ni3lsChrHansen@gmail.com",
             problems_info="Problemer? Kontakt venligst Niels Chr. Hansen p� Ni3lsChrHansen@gmail.com.")

# Question text
revCode <- c(1,1,1,1,1,1,1,1,0,1,0,1,0,0,1,1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1) # Reverse coding key (1=positive, 0=negative)
GeneralCode <- c(1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0,1,1,1,0,1,0,1,1,0,1,1,0,0,0,1,0)
GeneralPercentiles <- c(32,37,41,43,46,48,50,51,53,54,55,56,57,58,59,60,61,62,63,64,64,65,66,67,67,68,69,69,70,71,71,72,73,73,74,75,75,76,76,77,77,78,79,79,80,80,81,81,82,82,83,84,84,85,85,86,86,87,87,88,89,89,90,90,91,91,92,93,93,94,94,95,96,96,97,98,98,99,100,100,101,102,103,103,104,105,106,107,107,108,109,110,111,113,114,115,117,118,121,126)
qText <- c("Jeg bruger meget af min fritid p� musik-relaterede aktiviteter.",
           "Jeg v�lger ofte at lytte til musik, der kan give mig g�sehud.",
           "Jeg kan godt lide at skrive om musik, for eksempel p� blogs og internet-fora.",
           "Hvis nogen begynder at synge en sang, jeg ikke kender, kan jeg som regel ret hurtigt synge med.",
           "Jeg er i stand til at vurdere hvorvidt �n der synger er dygtig eller ej.",
           "Jeg er for det meste bevidst om, at det er f�rste gang, jeg h�rer en sang.",
           "Jeg kan synge eller spille musik udenad.",
           "Min interesse v�kkes af musikalske stilarter, som jeg ikke kender til, og jeg f�r lyst til at l�re dem bedre at kende.",
           "Musikstykker fremkalder sj�ldent f�lelser i mig.",
           "Jeg er i stand til at ramme de rigtige toner, n�r jeg synger med p� en musikindspilning, som jeg lytter til.",
           "Jeg har sv�rt ved at opdage fejl i en bestemt udgave af en sang, selv hvis jeg kender nummeret.",
           "Jeg kan sammenligne og diskutere forskelle mellem to opf�rsler eller udgaver af det samme stykke musik. ",
           "Jeg har sv�rt ved at genkende en sang, n�r den spilles p� en anden m�de eller af en anden kunstner end den jeg kender.",
           "Jeg har aldrig f�et ros for mine talenter som ud�vende musiker.",
           "Jeg l�ser ofte om eller s�ger p� internettet efter ting, der handler om musik.",
           "Jeg udv�lger ofte en bestemt type musik, n�r jeg skal motiveres eller stimuleres til noget.",
           "Jeg er ikke i stand til at synge en over- eller understemme n�r nogen synger en velkendt melodi.",
           "Jeg kan h�re, n�r folk synger eller spiller ude af takt.",
           "Jeg er i stand til at identificere, hvad der er s�rligt ved et bestemt stykke musik.",
           "Jeg er helt fint i stand til at tale om de f�lelser et musikstykke v�kker i mig.",
           "Jeg bruger ikke mange penge p� musik.",
           "Jeg kan h�re, n�r folk synger eller spiller falsk.",
           "N�r jeg synger, har jeg ingen id� om hvorvidt jeg synger falsk eller ej.",
           "Det er som om jeg er afh�ngig af musik - jeg ville ikke kunne leve uden.",
           "Jeg kan ikke lide at synge offentligt, fordi jeg er bange for at komme til at synge nogle forkerte toner.",
           "N�r jeg h�rer et stykke musik, kan jeg normalt identificere genren.",
           "Jeg vil ikke betragte mig selv som musiker.",
           "Jeg bider m�rke i ny musik, som jeg st�der p� (fx nye kunstnere eller indspilninger).",
           "Efter at have h�rt en ny sang to eller tre gange, plejer jeg selv at kunne synge den.",
           "Jeg beh�ver kun at h�re en ny melodi en enkelt gang, for at kunne synge den igen flere timer efter.",
           "Som regel v�kker musik minder om mennesker, jeg har kendt eller steder, jeg har v�ret.",
           "Jeg har regelm�ssigt og dagligt �vet mig p� et musikinstrument (inklusive sangstemmen) i ________.",
           "Da min interesse var p� sit h�jeste, �vede jeg mig p� mit prim�re instrument ______ om dagen.",
           "Jeg har v�ret til ________ koncerter som publikum i l�bet af de sidste 12 m�neder.",
           "Jeg har f�et undervisning i musikteori i ____________.",
           "I l�bet af min levetid har jeg f�et undervisning i at spille et musikinstrument (inklusive sangstemmen) i ___________.",
           "Jeg kan spille p� _______ musikinstrumenter.",
           "Jeg lytter opm�rksomt til musik ________ om dagen.")

# Response options
qResp <- list()
nDef <- 31   # Number of questions with default response options
defResp <- str_pad(c("Fuldst�ndig uenig","Meget uenig","Uenig","Hverken uenig eller enig","Enig","Meget enig","Fuldst�ndig enig"),24,"both")
specResps <- list(str_pad(c("0 �r","1 �r","2 �r","3 �r","4-5 �r","6-9 �r","10 eller flere �r"),24,"both"),
                  str_pad(c("0 timer","1/2 time","1 time","1.5 time","2 timer","3-4 timer","5 eller flere timer"),24,"both"),
                  str_pad(c("0","1","2","3","4-6","7-10","11 eller flere"),24,"both"),
                  str_pad(c("0 �r","0.5 �r","1 �r","2 �r","3 �r","4-6 �r","7 eller flere �r"),24,"both"),
                  str_pad(c("0 �r","0.5 �r","1 �r","2 �r","3-5 �r","6-9 �r","10 eller flere �r"),24,"both"),
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
                                      div(p("Tak for din interesse i dette videnskabelige projekt om musikalitet og mental hastighed i den generelle danske befolkning udf�rt af Aarhus Universitet."),
                                      p("Denne unders�gelse tager ca. 25 minutter. ",strong("Det er vigtigt, at du gennemf�rer lyttetesten i stille omgivelser og bruger h�retelefoner.")," L�s og godkend venligst samtykkeerkl�ringen p� n�ste side, f�r vi kan begynde."),align="left")),
                           button_text="N�ste")

# CONSENT FORM
consent <- one_button_page(body = div(h3("SAMTYKKEERKL�RING"),
                                      div(p("I forbindelse med dette forskningsprojekt med AU l�benummer [�.] har vi brug for dit samtykke til, at vi m� behandle dine personoplysninger i overensstemmelse med Databeskyttelsesforordningen."),
                                          p(strong("Form�l"),": The Goldsmiths Musical Sophistication Index (Gold-MSI) er et sp�rgeskema, der er udviklet af engelske forskere til at unders�ge musikalitet i den brede befolkning. Dette forskningsprojekt indsamler normer for den danske befolkning, baseret p� svar fra ca. 750 danske respondenter. I till�g indsamles basale reaktionstidsm�l, som kan bidrage til forst�elsen af �rsag og effekt af nogle af de positive karakteristika, der er associeret med formel hhv. uformel musikalsk tr�ning."),
                                          p("Du kan l�se mere om sp�rgeskemaet her (p� engelsk): ",a("https://www.gold.ac.uk/music-mind-brain/gold-msi/", href="https://www.gold.ac.uk/music-mind-brain/gold-msi/")),
                                          p(strong("Dataansvarlig"),": Aarhus Universitet (CVR nr. 31119103) er dataansvarlig for behandlingen af dine personoplysninger."),
                                          p(strong("Projektleder"),"Cecilie M�ller er leder af projektgruppen, som kan kontaktes p�: Center for Music in the Brain, Aarhus Universitet, N�rrebrogade 44, bygning 1A, 1. sal, 8000 Aarhus C,Danmark, email: ",a("cecilie@clin.au.dk",href="mailto:cecilie@clin.au.dk")),
                                          p(strong("Databeskyttelsesr�dgiver"),": Aarhus Universitets databeskyttelsesr�dgiver Michael Lund Kristensen kan kontaktes p� ",a("mlklund@au.dk",href="mailto:mlklund@au.dk"),", +4593509082."),
                                          p(strong("Personoplysninger, der behandles om dig"),": Vi behandler de personoplysninger om dig, som du afgiver via sp�rgeskemaet. Det drejer sig konkret om din e-mail. Det er tilladt at undlade at angive sin e-mail. Listen over e-mailadresser vil blive opbevaret i overensstemmelse med bestemmelserne i Databeskyttelsesforordningen og anden relevant dansk lovgivning. Listen over e-mailadresser bliver slettet efter afholdelse af lodtr�kningen med mindre du accepterer at forskerne m� gemme din e-mailadresse med henblik p� at kontakte dig i forbindelse med opf�lgning af projektet. I s� fald vil din e-mailadresse blive slettet efter 5 �r eller n�r du selv �nsker at tr�kke samtykket tilbage."),
                                          p(strong("Andre modtagere"),": Projektgruppens �vrige medlemmer modtager og behandler det indsamlede datamateriale i anonymiseret form. Det betyder, at dine data vil blive delt med vores samarbejdspartner i projektet, Goldsmiths, University of London. Goldsmiths vil ikke benytte data til andre form�l end udf�relsen af dette projekt. Dine personoplysninger bliver ikke delt med nogen tredje part."),
                                          p(strong("Mulighed for at tr�kke samtykke tilbage"),": Deltagelse er frivillig, og du kan til enhver tid uden begrundelse tr�kke dit samtykke til behandling af personoplysninger tilbage, uden at det f�r nogen konsekvenser for dig. Dette kan ske ved henvendelse til projektgruppen (se ovenfor). Hvis du tilbagetr�kker dit samtykke, f�r det f�rst virkning fra dette tidspunkt og p�virker ikke lovligheden af vores behandling op til dette tidspunkt."),
                                          p(strong("Godkendelse"),": Denne samtykkeerkl�ring godkendes elektronisk i forbindelse med besvarelsen af sp�rgeskemaet. Dette g�res ved at trykke 'Accepter' nedenfor:"),
                                          p(strong("Jeg afgiver hermed mit samtykke til, at mine persondata behandles i overensstemmelse med samtykkeerkl�ringen")),
                                          align="left")),
                           button_text="Accepter")

# DEMOGRAPHICS
demographics <- c(
  
  # ZIP CODE
  text_input_page(
    label = "zip_code",
    prompt = div(p("F�rst vil vi lige bede om lidt baggrundsinfo. Vi bruger denne information til at sikre, at vi modtager besvarelser fra et bredt udsnit af den danske befolkning."),
                 p("Hvad er dit postnummer?")),
    save_answer = T,
    button_text = "N�ste",
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
    prompt = "Hvad er din alder (i �r)?",
    save_answer = T,
    button_text = "N�ste",
    validate = function(answer, ...) {
      if (answer==""|!check.numeric(answer,only.integer=T))
        "Skriv venligst din alder i et helt tal uden ord som '�r', 'm�neder', kommaer eller andre specialtegn."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "age", value = answer, state = state)
    }),
  
  # GENDER
  NAFC_page(
    label = "gender",
    prompt = "Hvad er dit k�n?", 
    choices = c("Kvinde","Mand","Andet / �nsker ikke at oplyse"),
    on_complete = function(answer, state, ...) {
      set_global(key = "gender", value = answer, state = state)
    }),
  
  # NATIONALITET
  text_input_page(
    label = "nationality",
    prompt = "Hvad er din nationalitet?",
    save_answer = T,
    button_text = "N�ste",
    validate = function(answer, ...) {
      if (answer=="")
        "Skriv venligst din nationalitet."
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
    button_text = "N�ste",
    validate = function(answer, ...) {
      if (answer=="")
        "Skriv venligst, hvor du bor."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "residence", value = answer, state = state)
    }),
  
  # CHILDHOOD/YOUTH COUNTRY
  text_input_page(
    label = "youth_country",
    prompt = "I hvilket land har du tilbragt st�rstedelen af din barndon/ungdom?",
    save_answer = T,
    button_text = "N�ste",
    validate = function(answer, ...) {
      if (answer=="")
        "Besvar venligst sp�rgsm�let."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "youth_country", value = answer, state = state)
    }),
  
  # EMPLOYMENT
  NAFC_page(
    label = "employment",
    prompt = "Hvad er din nuv�rende besk�ftigelse?", 
    choices = c("0.-10. klasse",
                "Elev p� gymnasial uddannelse (fx gymnasium, HF, HTX, HHX)",
                "Studerende p� videreg�ende uddannelse",
                "Fuldtidsbesk�ftiget l�nmodtager",
                "Deltidsbesk�ftiget l�nmodtager",
                "Selvst�ndig",
                "Hjemmeg�ende",
                "Ledig",
                "Pensionist/efterl�nsmodtager"),
    on_complete = function(answer, state, ...) {
      set_global(key = "employment", value = answer, state = state)
    }),
    
  # EDUCATION
  NAFC_page(
    label = "education_completed",
    prompt = "Hvad er det h�jeste uddannelsesniveau, du har opn�et?", 
    choices = c("9. eller 10. klasse",
                "Gymnasial uddannelse (fx gymnasium, HF, HTX, HHX)",
                "Fagl�rt",
                "Kort videreg�ende uddannelse",
                "Mellemlang videreg�ende uddannelse (3-4 �r)",
                "Lang videreg�ende uddannelse (min. 5 �r)",
                "Stadig under uddannelse"),
    on_complete = function(answer, state, ...) {
      set_global(key = "education_completed", value = answer, state = state)
      if (answer!="Stadig under uddannelse") skip_n_pages(state,1)
    }),

  # EXPECTED EDUCATION
  NAFC_page(
    label = "education_expected",
    prompt = "Hvad er det h�jeste uddannelsesniveau, du forventer at opn�?",
    choices = c("9. eller 10. klasse",
                "Gymnasial uddannelse (fx gymnasium, HF, HTX, HHX)",
                "Fagl�rt",
                "Kort videreg�ende uddannelse",
                "Mellemlang videreg�ende uddannelse (3-4 �r)",
                "Lang videreg�ende uddannelse (min. 5 �r)",
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
    }),
  
    #GAMING HABITS
  text_input_page(
    label = "gaming",
    prompt = "Hvor mange timer om m�neden bruger du typisk p� at spille action-spil p� computer? Medregn kun spil, som kr�ver, at du reagerer hurtigt. Angiv et helt tal her:",
    save_answer = T,
    button_text = "N�ste",
    validate = function(answer, ...) {
      if (answer==""|!check.numeric(answer,only.integer=T))
        "Skriv venligst et helt tal for hvor mange timer du spiller action-spil om m�neden - uden ord som 'timer', 'minutter', kommaer eller andre specialtegn."
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
instrument <- text_input_page(
  label = "instrument", 
  prompt = "Det instrument (inklusive sangstemmen) som jeg er bedst til at spille p� er:", 
  validate = function(answer, ...) {
    if (answer=="")
      "Besvar venligst sp�rgsm�let."
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

# EMAIL
email <- c(text_input_page(
  label = "email_futureres",
  prompt = "(Frivilligt:) Indtast din e-mail-adresse her, hvis vi m� kontakte dig med henblik p� evt. deltagelse i fremtidig forskning:",
  save_answer = T,
  button_text = "N�ste",
  # validate = function(answer, ...) {
  #   if (!grepl(".*@.*\\.",answer))
  #     "Skriv venligst en gyldig e-mail-adresse."
  #   else TRUE
  # },
  on_complete = function(answer, state, ...) {
    set_global(key = "email_futureres", value = answer, state = state)
  }),
  
  text_input_page(
    label = "email_prize",
    prompt = "(Frivilligt:) N�r du har gennemf�rt hele denne unders�gelse, har du mulighed for at deltage i lodtr�kningen om et gavekort p� kr. 500,- . Indtast din e-mail-adresse her, hvis du vil deltage i lodtr�kningen:",
    save_answer = T,
    button_text = "N�ste",
    # validate = function(answer, ...) {
    #   if (!grepl(".*@.*\\.",answer))
    #     "Skriv venligst en gyldig e-mail-adresse."
    #   else TRUE
    # },
    on_complete = function(answer, state, ...) {
      set_global(key = "email_prize", value = answer, state = state)
    }))
  

# SAVE GMSI DATA
save_GMSI <- code_block(function(state, ...) {
  save_result(place=state,label="responses",value=get_global("responses",state))
  save_result(place=state,label="GeneralMusicalSophistication",value=get_global("GeneralMusicalSophistication",state))
  })

# LAST PAGE
last_page_gmsi <-   reactive_page(function(state, count, ...) {              # Feedback page
                final_page(div(p(paste0("Tak for hj�lpen! Din Gold-MSI score er: ",get_global("GeneralMusicalSophistication",state=state))),
                               p(paste0("Det g�r dig mere musikalsk sofistikeret end ",sum(get_global("GeneralMusicalSophistication",state=state)>=GeneralPercentiles),"% af befolkningen!"))))
                               p(paste0("Vi skal nu teste din reaktionstid og dine lyttef�rdigheder. Hvis du ikke allerede har gjort det, s� tag venligst hovedtelefoner p� nu."))
  })


#####################
# CALIBRATION TEST  #
#####################

calibration <- volume_calibration_page(url="https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3", type="mp3",
                                       button_text="Lydniveauet er fint nu. Forts�t",
                                       #on_complete=,
                                       #admin_ui=,
                                       prompt="Vi skal nu teste din reaktionstid og dine lyttef�rdigheder. Hvis du ikke allerede har gjort det, s� tag venligst hovedtelefoner p� nu. Indstil lyden p� din computer, s� lydniveauet er komfortabelt for dig. Hvis ikke du h�rer den lyd vi afspiller nu, s� check dine indstillinger p� computeren. Du kan kun deltage i denne del af unders�gelsen, hvis din computer kan afspille lyden.")


################################
# MISTUNING PERCEPTION TEST    #
################################

mistuning <- mpt(num_items=2,
                 dict=mpt::mpt_dict,#languages="DA",
                 feedback=psychTestRCAT::cat.feedback.graph("MPT",
                                                            text_finish = "Flot klaret!",
                                                            next_button = "N�ste",
                                                            text_score = "Din endelige score:",
                                                            text_rank = "Din placering i forhold til tidligere deltagere:",
                                                            x_axis = "Score",
                                                            y_axis = "Antal",
                                                            explain_IRT = FALSE), 
                 take_training = T)
#####################
# DEFINE EXPERIMENT #
#####################

experiment <- c(
  welcome,                                                 # Intro page
  #consent,                                                 # Consent page
  #begin_module("Demographics"),                            # Begin Demographics module
  #demographics,                                            # Demographics questions
  ##demographics1,                                          # 1st part, Demographics questions
  ##demographics_extra,                                     # Extra question if relevant
  ##demographics2,                                          # 2nd part, Demographics questions
  #end_module(),                                            # End Demographics module
  #elt_save_results_to_disk(complete = TRUE),               # Default save function 
  begin_module("GMSI"),                                    # Begin GMSI module
  randomiser,                                              # Randomise GMSI questions  
  show_items,                                              # Show GMSI questions 
  instrument,                                              # Instrument input page
  email,                                                   # Email
  save_GMSI,                                               # Save GMSI data
  end_module(),                                            # End GMSI module
  elt_save_results_to_disk(complete = TRUE),               # Default save function
  calibration,                                             # Sound calibration page
  #mistuning,                                              # Mistuning perception test
  elt_save_results_to_disk(complete = TRUE),               # Default save function
  last_page_gmsi)                                          # Last page with Gold-MSI percentile feedback
  
#########################
# RUN EXPERIMENT        #
#########################

make_test(experiment,opt=config)

# #########HERFRA??????????????????????????????????????????????????????????????????????##########################
# #####################
# # DEFINE EXPERIMENT #
# #####################
# 
# experiment <- c(
#   welcome,                                                 # Intro page
#   consent,                                                 # Consent page
#   begin_module("Demographics"),                            # Begin Demographics module
#   demographics,                                            # Demographics questions
#   #demographics1,                                          # 1st part, Demographics questions
#   #demographics_extra,                                     # Extra question if relevant
#   #demographics2,                                          # 2nd part, Demographics questions
#   end_module(),                                            # End Demographics module
#   begin_module("GMSI"),                                    # Begin GMSI module
#   randomiser,                                              # Randomise GMSI questions  
#   show_items,                                              # Show GMSI questions 
#   instrument,                                              # Instrument input page
#   email,                                                   # Email
#   save_GMSI,                                               # Save GMSI data
#   end_module(),                                            # End GMSI module
#   elt_save_results_to_disk(complete = TRUE),               # Default save function 
#   last_page)                                               # Last page with percentile feedback
# 
# #########################
# # RUN EXPERIMENT        #
# #########################
# 
# make_test(experiment,opt=config)
# 



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
  #       "Navnefeltet skal udfyldes, f�r du kan forts�tte."
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
  #   prompt = "Det instrument (inklusive sangstemmen) som jeg er bedst til at spille p� er:", 
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
  #   final_page(paste0("Tak for hj�lpen, ", get_global("name", state), "!\n","Din samlede Gold-MSI score er: ",sum(get_global("responses",state=state)$NormVal,na.rm=T),"."))
  # }))
