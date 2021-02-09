#-------------------------------------------------
# create population table with alla covariates

load(paste0(diroutput,"D3_study_population_cov_ALL.RData"))

#names_var<-c(names(D3_study_population_cov_ALL)[6:length(names(D3_study_population_cov_ALL))])
COVnames<-c("CV","COVCOPD","COVHIV","COVCKD","COVDIAB")

names_var <- c("all_covariates_non_CONTR")
for (cov in COVnames ){
  if ( cov!="CV" ){
    nameDP =  paste0("DP_",cov,"_at_study_entry")
  }
  else{
    nameDP = "DP_CVD_at_study_entry"
  }
  names_var <- c(names_var,paste0(cov,"_at_study_entry"),nameDP,paste0(cov,"_either_DX_or_DP"))
}
# D4_descriptive_dataset_ageband<-as.data.frame(table(D3_study_population_cov_ALL[,age_strata_at_study_entry]))
# colnames(D4_descriptive_dataset_ageband)<-c("age_strata_at_study_entry","frequency")
# D4_descriptive_dataset_age<-as.data.frame(t(t(summary(D3_study_population_cov_ALL[,age_at_study_entry]))))[,c(1,3)]
# colnames(D4_descriptive_dataset_age)<-c("","age_at_study_entry")

D4_descriptive_dataset_covariate_ALL<-c()
add<-as.matrix(0,0)

for (i in names_var){
  #print(i)
  tab3<-as.matrix(table(D3_study_population_cov_ALL[,get(i)]))
  colnames(tab3)<-i
  if (dim(tab3)[1]==1){
    tab3<-rbind(tab3, add)
    D4_descriptive_dataset_covariate_ALL<-cbind(D4_descriptive_dataset_covariate_ALL, tab3)  
  } else {
    D4_descriptive_dataset_covariate_ALL<-cbind(D4_descriptive_dataset_covariate_ALL, tab3)
  }
}
D4_descriptive_dataset_covariate_ALL<-as.data.frame(D4_descriptive_dataset_covariate_ALL)
row.names(D4_descriptive_dataset_covariate_ALL)<-c("0","1")

# save as 3 tables: in D4_descriptive_dataset_age, D4_descriptive_dataset_ageband, D4_descriptive_dataset_covariate_ALL
save(D4_descriptive_dataset_covariate_ALL,file=paste0(diroutput,"D4_descriptive_dataset_covariate_ALL.RData"))
# save(D4_descriptive_dataset_age,file=paste0(diroutput,"D4_descriptive_dataset_age.RData"))
# save(D4_descriptive_dataset_ageband,file=paste0(diroutput,"D4_descriptive_dataset_ageband.RData"))



# fwrite(D4_descriptive_dataset_ageband, paste0(direxp,"D4_descriptive_dataset_ageband.csv"))
# fwrite(D4_descriptive_dataset_age, paste0(direxp,"D4_descriptive_dataset_age.csv"))
fwrite(D4_descriptive_dataset_covariate_ALL, paste0(direxp,"D4_descriptive_dataset_covariate_ALL.csv"))

