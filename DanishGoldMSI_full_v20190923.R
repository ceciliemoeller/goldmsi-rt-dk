###############################################
# Danish GoldMSI implementation in psychTestR #
# Author: Niels Chr. Hansen                   # 
# Date: 2019-09-04                            #
###############################################


###################
# INITIALIZE      #
###################
library(psychTestR)
library(tidyverse)
library(shiny)
setwd("C:/Users/nch/Desktop/pmcharrison-psychTestR-bcc0e86")    # Specify where to save output files
config <- test_options(title="Dansk Gold-MSI",
             admin_password="g0ldms1",
             researcher_email="Ni3lsChrHansen@gmail.com",
             problems_info="Problemer? Kontakt venligst Niels Chr. Hansen på Ni3lsChrHansen@gmail.com.")

# Question text
revCode <- c(1,1,1,1,1,1,1,1,0,1,0,1,0,0,1,1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1) # Reverse coding key (1=positive, 0=negative)
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
defResp <- c("Fuldstændig uenig","Meget uenig","Uenig","Hverken uenig eller enig","Enig","Meget enig","Fuldstændig enig")
specResps <- list(c("0 år","1 år","2 år","3 år","4-5 år","6-9 år","10 eller flere år"),
                  c("0 timer","1/2 time","1 time","1.5 time","2 timer","3-4 timer","5 eller flere timer"),
                  c("0","1","2","3","4-6","7-10","11 eller flere"),
                  c("0 år","0.5 år","1 år","2 år","3 år","4-6 år","7 eller flere år"),
                  c("0 år","0.5 år","1 år","2 år","3-5 år","6-9 år","10 eller flere år"),
                  c("0","1","2","3","4","5","6 eller flere"),
                  c("0-15 min.","15-30 min.","30-60 min.","60-90 min.","2 timer","2-3 timer","4 timer eller mere"))
for (i in 1:nDef) qResp[[i]] <- defResp
for (j in 1:length(specResps)) qResp[[j+nDef]] <- specResps[[j]]

# Question names
keys <- vector(mode="character")
for (k in 1:length(qText)) keys <- c(keys,paste0("GMSI_Q",k))

# Randomize stimuli inidvidually for each participant
qs <- sample(c(1:length(qText)),length(qText))      # This should be done in the participant session below and not in the server session


#####################
# DEFINE EXPERIMENT #
#####################

#####################
# INTRO QUESTIONS   #
#####################

experiment <- list(
  
  # Intro page
  one_button_page(
    body="Velkommen til vores test!",
    on_complete=function(state, ...) {
      set_global(key = "order", value = qs, state = state)
    }),
  
  ## WORKS, BUT THEN qs CANNOT BE RETRIEVED BELOW (state is missing!?):
  ## Randomize stimuli separately for each participant 
  #code_block(function(state, ...) { set_global(key = "qs", value = sample(c(1:length(qText)),length(qText)), state = state) }),
  
  # Begin module
  begin_module("demographics"),

  # Name insert page
  text_input_page(
    label = "name", 
    prompt = "Hvad er dit navn?", 
    save_answer = T,
    validate = function(answer, ...) {
      if (answer == "")
        "Navnefeltet skal udfyldes, før du kan fortsætte."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "name", value = answer, state = state)
    }),
  
  # Email address insert page
  text_input_page(
    label = "email", 
    prompt = "Hvad er din e-mail-adresse?",
    save_answer = T,
    validate = function(answer, ...) {
      if (!grepl(".*@.*\\.",answer))
        "Skriv venligst en gyldig e-mail-adresse."
      else TRUE
    },
    on_complete = function(answer, state, ...) {
      set_global(key = "email", value = answer, state = state)
    }),
  
  # End module
  end_module(),
  
  ###################
  # GMSI QUESTIONS  #
  ###################
  
  # Begin module
  begin_module("GMSI"),
  
  # NOT WORKING:
  # # GMSI_Q1
  # NAFC_page(
  #   label = paste0("GMSI_Q",get_global("qs",state)[1]),
  #   prompt = qText[get_global("qs",state)[1]],
  #   choices = qResp[[get_global("qs",state)[1]]],
  #   save_answer = T,
  #   on_complete = function(answer, state, ...) {
  #     set_global(key = keys[get_global("qs",state)[1]], value = which(qResp[[get_global("qs",state)[1]]]==answer), state = state)
  #   }),
  
  # GMSI_Q1
  NAFC_page(
    label = paste0("GMSI_Q",qs[1]),
    prompt = qText[qs[1]],
    choices = qResp[[qs[1]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[1]], value = which(qResp[[qs[1]]]==answer), state = state)
    }),
  
  # GMSI_Q2
  NAFC_page(
    label = paste0("GMSI_Q",qs[2]),
    prompt = qText[qs[2]],
    choices = qResp[[qs[2]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[2]], value = which(qResp[[qs[2]]]==answer), state = state)
    }),

  # GMSI_Q3
  NAFC_page(
    label = paste0("GMSI_Q",qs[3]),
    prompt = qText[qs[3]],
    choices = qResp[[qs[3]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[3]], value = which(qResp[[qs[3]]]==answer), state = state)
    }),

  # GMSI_Q4
  NAFC_page(
    label = paste0("GMSI_Q",qs[4]),
    prompt = qText[qs[4]],
    choices = qResp[[qs[4]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[4]], value = which(qResp[[qs[4]]]==answer), state = state)
    }),

  # GMSI_Q5
  NAFC_page(
    label = paste0("GMSI_Q",qs[5]),
    prompt = qText[qs[5]],
    choices = qResp[[qs[5]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[5]], value = which(qResp[[qs[5]]]==answer), state = state)
    }),

  # GMSI_Q6
  NAFC_page(
    label = paste0("GMSI_Q",qs[6]),
    prompt = qText[qs[6]],
    choices = qResp[[qs[6]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[6]], value = which(qResp[[qs[6]]]==answer), state = state)
    }),

  # GMSI_Q7
  NAFC_page(
    label = paste0("GMSI_Q",qs[7]),
    prompt = qText[qs[7]],
    choices = qResp[[qs[7]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[7]], value = which(qResp[[qs[7]]]==answer), state = state)
    }),

  # GMSI_Q8
  NAFC_page(
    label = paste0("GMSI_Q",qs[8]),
    prompt = qText[qs[8]],
    choices = qResp[[qs[8]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[8]], value = which(qResp[[qs[8]]]==answer), state = state)
    }),

  # GMSI_Q9
  NAFC_page(
    label = paste0("GMSI_Q",qs[9]),
    prompt = qText[qs[9]],
    choices = qResp[[qs[9]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[9]], value = which(qResp[[qs[9]]]==answer), state = state)
    }),

  # GMSI_Q10
  NAFC_page(
    label = paste0("GMSI_Q",qs[10]),
    prompt = qText[qs[10]],
    choices = qResp[[qs[10]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[10]], value = which(qResp[[qs[10]]]==answer), state = state)
    }),

  # GMSI_Q11
  NAFC_page(
    label = paste0("GMSI_Q",qs[11]),
    prompt = qText[qs[11]],
    choices = qResp[[qs[11]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[11]], value = which(qResp[[qs[11]]]==answer), state = state)
    }),

  # GMSI_Q12
  NAFC_page(
    label = paste0("GMSI_Q",qs[12]),
    prompt = qText[qs[12]],
    choices = qResp[[qs[12]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[12]], value = which(qResp[[qs[12]]]==answer), state = state)
    }),

  # GMSI_Q13
  NAFC_page(
    label = paste0("GMSI_Q",qs[13]),
    prompt = qText[qs[13]],
    choices = qResp[[qs[13]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[13]], value = which(qResp[[qs[13]]]==answer), state = state)
    }),

  # GMSI_Q14
  NAFC_page(
    label = paste0("GMSI_Q",qs[14]),
    prompt = qText[qs[14]],
    choices = qResp[[qs[14]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[14]], value = which(qResp[[qs[14]]]==answer), state = state)
    }),

  # GMSI_Q15
  NAFC_page(
    label = paste0("GMSI_Q",qs[15]),
    prompt = qText[qs[15]],
    choices = qResp[[qs[15]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[15]], value = which(qResp[[qs[15]]]==answer), state = state)
    }),

  # GMSI_Q16
  NAFC_page(
    label = paste0("GMSI_Q",qs[16]),
    prompt = qText[qs[16]],
    choices = qResp[[qs[16]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[16]], value = which(qResp[[qs[16]]]==answer), state = state)
    }),

  # GMSI_Q17
  NAFC_page(
    label = paste0("GMSI_Q",qs[17]),
    prompt = qText[qs[17]],
    choices = qResp[[qs[17]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[17]], value = which(qResp[[qs[17]]]==answer), state = state)
    }),

  # GMSI_Q18
  NAFC_page(
    label = paste0("GMSI_Q",qs[18]),
    prompt = qText[qs[18]],
    choices = qResp[[qs[18]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[18]], value = which(qResp[[qs[18]]]==answer), state = state)
    }),

  # GMSI_Q19
  NAFC_page(
    label = paste0("GMSI_Q",qs[19]),
    prompt = qText[qs[19]],
    choices = qResp[[qs[19]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[19]], value = which(qResp[[qs[19]]]==answer), state = state)
    }),

  # GMSI_Q20
  NAFC_page(
    label = paste0("GMSI_Q",qs[20]),
    prompt = qText[qs[20]],
    choices = qResp[[qs[20]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[20]], value = which(qResp[[qs[20]]]==answer), state = state)
    }),

  # GMSI_Q21
  NAFC_page(
    label = paste0("GMSI_Q",qs[21]),
    prompt = qText[qs[21]],
    choices = qResp[[qs[21]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[21]], value = which(qResp[[qs[21]]]==answer), state = state)
    }),

  # GMSI_Q22
  NAFC_page(
    label = paste0("GMSI_Q",qs[22]),
    prompt = qText[qs[22]],
    choices = qResp[[qs[22]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[22]], value = which(qResp[[qs[22]]]==answer), state = state)
    }),

  # GMSI_Q23
  NAFC_page(
    label = paste0("GMSI_Q",qs[23]),
    prompt = qText[qs[23]],
    choices = qResp[[qs[23]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[23]], value = which(qResp[[qs[23]]]==answer), state = state)
    }),

  # GMSI_Q24
  NAFC_page(
    label = paste0("GMSI_Q",qs[24]),
    prompt = qText[qs[24]],
    choices = qResp[[qs[24]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[24]], value = which(qResp[[qs[24]]]==answer), state = state)
    }),

  # GMSI_Q25
  NAFC_page(
    label = paste0("GMSI_Q",qs[25]),
    prompt = qText[qs[25]],
    choices = qResp[[qs[25]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[25]], value = which(qResp[[qs[25]]]==answer), state = state)
    }),

  # GMSI_Q26
  NAFC_page(
    label = paste0("GMSI_Q",qs[26]),
    prompt = qText[qs[26]],
    choices = qResp[[qs[26]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[26]], value = which(qResp[[qs[26]]]==answer), state = state)
    }),

  # GMSI_Q27
  NAFC_page(
    label = paste0("GMSI_Q",qs[27]),
    prompt = qText[qs[27]],
    choices = qResp[[qs[27]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[27]], value = which(qResp[[qs[27]]]==answer), state = state)
    }),

  # GMSI_Q28
  NAFC_page(
    label = paste0("GMSI_Q",qs[28]),
    prompt = qText[qs[28]],
    choices = qResp[[qs[28]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[28]], value = which(qResp[[qs[28]]]==answer), state = state)
    }),

  # GMSI_Q29
  NAFC_page(
    label = paste0("GMSI_Q",qs[29]),
    prompt = qText[qs[29]],
    choices = qResp[[qs[29]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[29]], value = which(qResp[[qs[29]]]==answer), state = state)
    }),

  # GMSI_Q30
  NAFC_page(
    label = paste0("GMSI_Q",qs[30]),
    prompt = qText[qs[30]],
    choices = qResp[[qs[30]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[30]], value = which(qResp[[qs[30]]]==answer), state = state)
    }),

  # GMSI_Q31
  NAFC_page(
    label = paste0("GMSI_Q",qs[31]),
    prompt = qText[qs[31]],
    choices = qResp[[qs[31]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[31]], value = which(qResp[[qs[31]]]==answer), state = state)
    }),

  # GMSI_Q32
  NAFC_page(
    label = paste0("GMSI_Q",qs[32]),
    prompt = qText[qs[32]],
    choices = qResp[[qs[32]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[32]], value = which(qResp[[qs[32]]]==answer), state = state)
    }),

  # GMSI_Q33
  NAFC_page(
    label = paste0("GMSI_Q",qs[33]),
    prompt = qText[qs[33]],
    choices = qResp[[qs[33]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[33]], value = which(qResp[[qs[33]]]==answer), state = state)
    }),

  # GMSI_Q34
  NAFC_page(
    label = paste0("GMSI_Q",qs[34]),
    prompt = qText[qs[34]],
    choices = qResp[[qs[34]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[34]], value = which(qResp[[qs[34]]]==answer), state = state)
    }),

  # GMSI_Q35
  NAFC_page(
    label = paste0("GMSI_Q",qs[35]),
    prompt = qText[qs[35]],
    choices = qResp[[qs[35]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[35]], value = which(qResp[[qs[35]]]==answer), state = state)
    }),

  # GMSI_Q36
  NAFC_page(
    label = paste0("GMSI_Q",qs[36]),
    prompt = qText[qs[36]],
    choices = qResp[[qs[36]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[36]], value = which(qResp[[qs[36]]]==answer), state = state)
    }),

  # GMSI_Q37
  NAFC_page(
    label = paste0("GMSI_Q",qs[37]),
    prompt = qText[qs[37]],
    choices = qResp[[qs[37]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[37]], value = which(qResp[[qs[37]]]==answer), state = state)
    }),

  # GMSI_Q38
  NAFC_page(
    label = paste0("GMSI_Q",qs[38]),
    prompt = qText[qs[38]],
    choices = qResp[[qs[38]]],
    on_complete = function(answer, state, ...) {
      set_global(key = keys[qs[38]], value = which(qResp[[qs[38]]]==answer), state = state)
    }),

  
  # Preferred instrument page
  text_input_page(
    label = "instrument", 
    prompt = "Det instrument (inklusive sangstemmen) som jeg er bedst til at spille på er:", 
    on_complete = function(answer, state, ...) {
      set_global(key = "instrument", value = answer, state = state)
      
      # Compute response table
      responses <- data.frame(Qid=1:length(keys),RevCode=revCode,ResponseVal=integer(length(keys)),NormVal=integer(length(keys)),row.names=keys)
      for (l in 1:length(keys)) {
        responses[l,"ResponseVal"] <- get_global(keys[l],state=state)
        if (responses[l,"RevCode"]==0) responses[l,"NormVal"] <- (responses[l,"ResponseVal"]-8)*-1 else responses[l,"NormVal"] <- responses[l,"ResponseVal"]
        #set_global(key="GMSIscore",value=sum(get_global(key="GMSIscore",state=state),get_global(keys[l],state=state)),state=state)
      }
      set_global("responses",value=responses,state=state)
    }),
  
  code_block(function(state, ...) save_result(place=state,label="responses",value=get_global("responses",state))),
  
  # End module
  end_module(),
  
  #########################
  # SURVEY END & FEEDBACK #
  #########################
  
  # Save data
  elt_save_results_to_disk(complete = TRUE),
  
  # Final page
  reactive_page(function(state, count, ...) {
    final_page(paste0("Tak for hjælpen, ", get_global("name", state), "!\n","Din samlede Gold-MSI score er: ",sum(get_global("responses",state=state)$NormVal,na.rm=T),"."))
  }))


#########################
# RUN EXPERIMENT        #
#########################

make_test(experiment,opt=config)