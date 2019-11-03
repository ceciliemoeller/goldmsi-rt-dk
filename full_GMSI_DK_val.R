# INITIALIZE

install.packages('devtools')

# Install the MPT:
  
devtools::install_github('pmcharrison/mpt')



# library(devtools)
library(htmltools)
library(psychTestR)
library(shiny)
library(mpt)

is.scalar.character <- function(x) {
  is.character(x) && is.scalar(x)
}

is.scalar.numeric <- function(x) {
  is.numeric(x) && is.scalar(x)
}

is.scalar.logical <- function(x) {
  is.logical(x) && is.scalar(x)
}

is.scalar <- function(x) {
  identical(length(x), 1L)
}

is.integerlike <- function(x) {
  all(round(x) == x)
}

is.scalar.integerlike <- function(x) {
  is.scalar(x) && is.integerlike(x)
}


DK_full <- function(title = "Musikalitet og mental hastighed",
                           admin_password = "replace-with-secure-password",
                           researcher_email = NULL,
                           languages = mpt_languages(),
                           dict = mpt::mpt_dict,
                           ...) {
  elts <- c(
            # experiment,
            mpt(...),
            elt_jspsych,
            psychTestR::new_timeline(
            dict = dict
    ),
    elt_save_results_to_disk(complete = TRUE),
    final_page("Det kører!")
  )
 
  
  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = languages))
}

#herfra?

standalone_mpt <- function(title = "Hej",
                           admin_password = "replace-with-secure-password",
                           researcher_email = NULL,
                           languages = mpt_languages(),
                           dict = mpt::mpt_dict,
                           ...) {
  elts <- c(
    experiment,
    mpt(...),
    elt_jspsych,
    elt_save_results_to_disk(complete = FALSE),
    final_page("Du har nu klaret de tre reaktionstidstests!\\Your final scores are plotted below, with reference to the general population")
  )
  
  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = hej,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = EN))
}

fra NC:
  
  standalone_mpt(num_items=1,
                 dict=mpt::mpt_dict,languages="DA",
                 feedback=psychTestRCAT::cat.feedback.graph("MPT",
                                                            text_finish = "Flot klaret!",
                                                            next_button = "Næste",
                                                            text_score = "Din endelige score:",
                                                            text_rank = "Din placering (se den røde linie) i forhold til tidligere deltagere:",
                                                            x_axis = "Score",
                                                            y_axis = "Antal deltagere",
                                                            explain_IRT = FALSE), # FALSE for testing
                 take_training = F)
                         
