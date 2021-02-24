#-----------------------------------------------
# set D3_events_ALL_OUTCOMES which contains the first outcome per person
# input: D3_events_OUTCOME_narrow, D3_events_OUTCOME_possible, for all outcomes OUTCOME; conceptsets for CONTROL_events
# output: D3_events_ALL_OUTCOMES, list_outcomes_observed.RData


print("CREATE EVENTS PER ALL OUTCOMES")

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

save(list_outcomes_observed,file=paste0(dirtemp,"list_outcomes_observed.RData"))
save(D3_events_ALL_OUTCOMES,file=paste0(dirtemp,"D3_events_ALL_OUTCOMES.RData"))

rm(D3_events_ALL_OUTCOMES, D4_study_population, list_outcomes_observed)