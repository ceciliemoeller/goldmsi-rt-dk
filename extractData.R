###############################################
# Extraction of data from Danish GoldMSI      #
# implementation in psychTestR                #
# Author: Niels Chr. Hansen                   # 
# Date: 2019-11-10                            #
###############################################

# INITIALIZE
library(jsonlite)

# LIST FILES IN WORKING DIRECTORY (ignoring folders and recursives)
files <- setdiff(list.files(paste0(getwd(),"/output/results"),include.dirs=F,all.files=F),list.dirs(paste0(getwd(),"/output/results"),full.names=F))

# CREATE OUTPUT FILE
output <- data.frame(id=character(),
                     gender=character(),
                     age=numeric(),
                     zip_code=character(),
                     gaming=numeric(),
                     nationality=character(),
                     residence=character(),
                     youth_country=character(),
                     employment=character(),
                     education_completed=character(),
                     education_expected=character(),
                     stringsAsFactors=F)

# EXTRACT AND SAVE VARIABLES OF INTEREST
for (i in 1:length(files)) {
  results <- readRDS(paste0(getwd(),"/output/results/",files[i]))
  output[i,"id"] <- results$session$p_id
  if ("Demographics"%in%names(results)) {
    output[i,2:10] <- results$Demographics[c("gender","age","zip_code","gaming","nationality","residence","youth_country","employment","education_completed")]
    if (output[i,"education_completed"]=="Stadig under uddannelse") output[i,"education_expected"] <- results$Demographics["education_expected"]
  }
  #session <-  results$session
  #GMSI <- results$GMSI
  #TestOrder <- results$results$TestOrder_MPT_RT
  #MPT <- results$MPT
  #RT <- fromJSON(as.character(results$RT))
}

# CHANGE VARIABLE MODES
output[,c("age","gaming")] <- lapply(output[,c("age","gaming")],as.numeric)
output[,c("id","gender","zip_code","nationality","residence","youth_country","employment","education_completed","education_expected")] <- lapply(output[,c("id","gender","zip_code","nationality","residence","youth_country","employment","education_completed","education_expected")],as.factor)

# DISPLAY DATA
par(mfrow=(c(2,2)))
barplot(table(output$gender),main="Køn")
boxplot(output$age,main="Alder",ylab="År"); points(jitter(rep(1,length(output$age)),factor=2),output$age,pch=4)
barplot(table(output$zip_code),main="Postnummer")
boxplot(output$age,main="Gaming",ylab="Timer/måned"); points(jitter(rep(1,length(output$gaming)),factor=2),output$gaming,pch=4)

# SAVE PRELIMINARY RESULTS
write.csv(output,paste0(getwd(),"/output/prelimDemographics_",Sys.Date(),".csv"))
    
