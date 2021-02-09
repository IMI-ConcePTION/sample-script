#------------------------------------------------------------------
# create components for narrow and broad, for HOSP and PC meanings

firstyear=firstYearComponentAnalysis
secondyear=secondYearComponentAnalysis


load(paste0(diroutput,"D4_study_population.RData")) # fread(paste0(dirinput,"PERSONS.csv"))
D4_study_population <- as.data.table(D4_study_population)
COHORT_TMP <- D4_study_population[,.(person_id,study_entry_date)]

condmeaning<-list()
for (level1 in c("HOSP","PC")) {
 for (meaning in meanings_of_this_study[[level1]]) {
   if (length(condmeaning[[level1]])==0) {condmeaning[[level1]]=paste0("meaning_of_event=='",meanings_of_this_study[[level1]][[1]],"'")
   }else{
   condmeaning[[level1]]=paste0(condmeaning[[level1]], " | meaning_of_event=='",meaning,"'")
   }
 }
}


##for each OUTCOME create components
for (OUTCOME in OUTCOME_events) {
namenewvar<-c()
print(OUTCOME)
  for (type in c("narrow","possible")) {
    counter<-0
    counter2<-0
    summarystatOUTCOME<-vector(mode="list")
    addvarOUTCOME <- vector(mode="list")
    FirstJan<-vector(mode="list")
    for (year in c(firstYearComponentAnalysis,secondYearComponentAnalysis)) {
      FirstJan[[year]]<-as.Date(as.character(paste0(year,"0101")), date_format)

      for (level1 in c("HOSP","PC")) {
        namenewvar <- paste0(OUTCOME,"_",type,"_",level1,"_",year)
        counter<-counter+1
        counter2<-counter2+1
        summarystatOUTCOME[[counter2]]<-list(c("max"),namenewvar,namenewvar)
        addvarOUTCOME[[counter]]=list(c(namenewvar),"1",paste0("(",condmeaning[[level1]], ") & date<=as.Date('",FirstJan[[year]],"')+365 & date>=as.Date('",FirstJan[[year]],"')"))
        counter<-counter+1
        addvarOUTCOME[[counter]]=list(c(namenewvar),"0",paste0("is.na(",namenewvar,")"))
      }
    }
    assign(paste0("OUTCOME_",type),MergeFilterAndCollapse(list(get(load(paste0(dirfromCDM,OUTCOME, "_",type,".RData")))),
                                           condition= "date>=study_entry_date - 365",
                                           key = c("person_id"),
                                           datasetS = COHORT_TMP,
                                           additionalvar=addvarOUTCOME,
                                           saveintermediatedataset=T,
                                           nameintermediatedataset=paste0(dirtemp,'D3_events_',OUTCOME,"_",type),
                                           strata=c("person_id"),
                                           summarystat = summarystatOUTCOME
    )
    )

}
  nameobject <- paste0("D3_components_",OUTCOME)
  temp2 <- merge(COHORT_TMP,get("OUTCOME_narrow"), by="person_id",all.x  = T)
  assign("temp3",merge(temp2,get("OUTCOME_possible"), by="person_id",all.x = T))
  
  assign(nameobject, temp3)
  nameobject[is.na(nameobject)] <- 0
  
  save(nameobject,file=paste0(dirtemp,paste0(nameobject,".RData")),list=nameobject)

  rm(list=paste0(OUTCOME,"_narrow"))
  rm(list=paste0(OUTCOME,"_possible"))
  rm("OUTCOME_narrow","OUTCOME_possible")
  rm(nameobject , list=nameobject)
  rm(temp2,temp3)
}
