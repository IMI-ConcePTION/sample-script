
# CV_narrow_string<- c("HF_narrow","MYOCARD_narrow")
# CV_possible_string<-c("HF_possible","MYOCARD_possible")
CV_string<-c("HF_narrow","HF_possible","MYOCARD_narrow","MYOCARD_possible","CAD_narrow","CAD_possible") 


#lapply(paste0(dirtemp,CV_narrow_string,".RData"),load,.GlobalEnv)
#lapply(paste0(dirtemp,CV_possible_string,".RData"),load,.GlobalEnv)
lapply(paste0(dirfromCDM,CV_string,".RData"),load,.GlobalEnv)

# CV_narrow<- rbind(HF_narrow,MYOCARD_narrow)
# CV_possible<- rbind(HF_possible,MYOCARD_possible)
CV<- rbind(HF_narrow, HF_possible,MYOCARD_narrow,MYOCARD_possible,CAD_narrow, CAD_possible)

rm(HF_narrow,MYOCARD_narrow,HF_possible,MYOCARD_possible, CAD_narrow, CAD_possible)

COVnames<-c("CV","COVCANCER","COVCOPD","COVHIV","COVCKD","COVDIAB","COVOBES","COVSICKLE")

load(paste0(diroutput,"D4_study_population.RData"))
D3_study_population_covariates<-D4_study_population[,.(person_id, study_entry_date)]




#file<-"COVCANCER_narrow"
for (file in COVnames) {
  if ( file!="CV" ){
    load(paste0(dirfromCDM,file,".RData"))
    temp<-merge(D4_study_population,get(file), all.x = T, by="person_id")[,.(person_id,study_entry_date,date)]
    temp<-temp[date>=study_entry_date-365 & date<study_entry_date,file:=1][is.na(file),file:=0]
    suppressWarnings(temp<-unique(temp[,file1:=max(file),by="person_id"][,.(person_id,file1)]))
    setnames(temp,"file1",paste0(file,"_at_study_entry"))
    D3_study_population_covariates<-merge(D3_study_population_covariates,temp,all.x = T, by="person_id")
  } else {
    temp<-merge(D4_study_population,get(file), all.x = T, by="person_id")[,.(person_id,study_entry_date,date)]
    temp<-temp[date>=study_entry_date-365 & date<study_entry_date,file:=1][is.na(file),file:=0]
    suppressWarnings(temp<-unique(temp[,file1:=max(file),by="person_id"][,.(person_id,file1)]))
    setnames(temp,"file1",paste0(file,"_at_study_entry"))
    D3_study_population_covariates<-merge(D3_study_population_covariates,temp,all.x = T, by="person_id")
  }
}
    

save(D3_study_population_covariates,file=paste0(dirtemp,"D3_study_population_covariates.RData"))

rm(CV,COVCANCER,COVCOPD,COVHIV,COVCKD,COVDIAB,COVOBES,COVSICKLE) 


