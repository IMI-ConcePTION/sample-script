# create a dataset for each pair concept set,year, containing code counts
meaning<-c()
FirstJan <- list()
conditionYear <- list()
for (year in study_years) {
  FirstJan[[year]] <- as.Date(as.character(paste0(year,"0101")), date_format)
  conditionYear[[year]] <- paste0("date<=as.Date('",FirstJan[[year]],"')+365 & date>=as.Date('",FirstJan[[year]],"')")
}


for (conceptset in concept_sets_of_our_study ) {
  print(conceptset)
  if (concept_set_domains[[conceptset]]=="Diagnosis") meaning<-"meaning_of_event"
  else{ meaning<-"meaning_of_drug_record"
  }
  for (year in study_years) {
    nameobject <- paste0("D4_",conceptset,"code_counts",year)
    assign(nameobject, MergeFilterAndCollapse(list(get(load(paste0(dirfromCDM,conceptset,".RData")))),
                                          condition = conditionYear[[year]],
                                          additionalvar = list(list(c("n"),1)),
                                          strata=c("codvar",meaning),
                                          summarystat = list(
                                            list(c("count"),"n")
                                            )
                                          )
    )
  save(nameobject,file = paste0(diroutput,"D4_",conceptset,"code_counts",year,".RData"),list = nameobject )
  fwrite(get(nameobject),file=paste0(direxp,"D4_",conceptset,"code_counts",year,".csv"))
  
  rm(list = nameobject)
  rm(list = conceptset)
  }
}


