# COUNT PERSON TIME PER ALL OUTCOMES
#-----------------------------------------------

print("COUNT PERSON TIME PER ALL OUTCOMES")

load(paste0(diroutput,"D4_study_population.RData")) # fread(paste0(dirinput,"PERSONS.csv"))
D4_study_population <- as.data.table(D4_study_population)


#-----------------------------------------------
# set datasetOUTCOMES which will contain the first outcome per person
datasetOUTCOMES <- D4_study_population[1,.(person_id)]
datasetOUTCOMES <- datasetOUTCOMES[,name_event := "test"] 
datasetOUTCOMES <- datasetOUTCOMES[,date_event := as.Date('20010101',date_format)] 
datasetOUTCOMES <- datasetOUTCOMES[name_event!="test",] 
list_outcomes_observed <- c()

for (OUTCOME in OUTCOME_events) {
    print(OUTCOME)
  namedatasetnarrow <- paste0('D3_events_',OUTCOME,"_narrow")
  namedatasetpossible <- paste0('D3_events_',OUTCOME,"_possible")
  load(paste0(dirtemp,namedatasetnarrow,'.RData'))
  load(paste0(dirtemp,namedatasetpossible,'.RData'))

  dataset <- vector(mode="list")
  dataset[['narrow']] <- as.data.table(get(namedatasetnarrow))
  dataset[['narrow']] <- dataset[['narrow']][,.(person_id,date)]
  dataset[['possible']] <- as.data.table(get(namedatasetpossible))
  dataset[['possible']] <- dataset[['possible']][,.(person_id,date)]
  for (type in c("narrow","possible")) {
    if ( nrow(dataset[[type]]) > 0 ) {
      dataset[[type]] <-  dataset[[type]][!is.na(person_id),]
      dataset[[type]] <-  dataset[[type]][!is.na(date),]
    }
  }  
  if ( nrow(dataset[['narrow']]) == 0){ 
    dataset[['broad']] <- dataset[['possible']]
  }
  if ( nrow(dataset[['possible']]) == 0){ 
    dataset[['broad']] <- dataset[['narrow']]
  }
  if ( nrow(dataset[['narrow']]) > 0 & nrow(dataset[['possible']]) > 0 ){
  dataset[['broad']] <- as.data.table(rbind(dataset[['narrow']],dataset[['possible']]))
  }
  
  for (type in c("narrow","broad")) {
    dataset[[type]][,name_event:=paste0(OUTCOME,'_',type)]
    if ( nrow(dataset[[type]]) > 0 ){
      dataset[[type]] <- dataset[[type]][,date_event:=min(date),by = c("person_id", "name_event")]
      dataset[[type]] <- dataset[[type]][,.(person_id,date_event,name_event)]
      dataset[[type]] <- unique(dataset[[type]])
      datasetOUTCOMES <- as.data.table(rbind(datasetOUTCOMES,dataset[[type]],fill = T))
      list_outcomes_observed <- c(list_outcomes_observed,paste0(OUTCOME,'_',type))
    }
  }
  rm(list = namedatasetnarrow)
  rm(list = namedatasetpossible)
}

start_persontime_studytime = as.character(paste0(study_years[1],"0101"))
end_persontime_studytime = as.character(paste0(study_years[length(study_years)],"1231"))
  
Output_file<-CountPersonTime(
  Dataset_events = datasetOUTCOMES,
  Dataset = D4_study_population,
  Person_id = "person_id",
  Start_study_time = start_persontime_studytime,
  End_study_time = end_persontime_studytime,
  Start_date = "study_entry_date",
  End_date = "study_exit_date",
  Birth_date = "date_of_birth",
  Strata = c("sex"),
  Name_event = "name_event",
  Date_event = "date_event",
  Age_bands = c(0,19,29,39,49,59,69,79),
  Increment="year",
  Outcomes =  list_outcomes_observed, #c("CAD_narrow","CAD_broad"),
  Unit_of_age = "year",
  include_remaning_ages = T,
  Aggregate = T
)
nameobject <- paste0("D4_persontime_ALL_OUTCOMES_year")
assign(nameobject, Output_file)
save(nameobject,file=paste0(diroutput,paste0(nameobject,".RData")),list=nameobject)
fwrite(get(nameobject),file=paste0(direxp,paste0(nameobject,".csv")))
rm(list = nameobject)
