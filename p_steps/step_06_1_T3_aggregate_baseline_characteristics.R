#-------------------------------------------------
# create population table

load(paste0(diroutput,"D4_study_population_cov.RData"))

names_var<-c(names(D4_study_population_cov)[6:length(names(D4_study_population_cov))])

D4_descriptive_dataset_ageband<-as.data.frame(table(D4_study_population_cov[,age_strata_at_study_entry]))
colnames(D4_descriptive_dataset_ageband)<-c("age_strata_at_study_entry","frequency")
D4_descriptive_dataset_age<-as.data.frame(t(t(summary(D4_study_population_cov[,age_at_study_entry]))))[,c(1,3)]
colnames(D4_descriptive_dataset_age)<-c("","age_at_study_entry")

D4_descriptive_dataset_covariate<-c()
add<-as.matrix(0,0)

for (i in names_var){
  #print(i)
  tab3<-as.matrix(table(D4_study_population_cov[,get(i)]))
  colnames(tab3)<-i
  if (dim(tab3)[1]==1){
    tab3<-rbind(tab3, add)
    D4_descriptive_dataset_covariate<-cbind(D4_descriptive_dataset_covariate, tab3)  
  } else {
    D4_descriptive_dataset_covariate<-cbind(D4_descriptive_dataset_covariate, tab3)
  }
}
D4_descriptive_dataset_covariate<-as.data.frame(D4_descriptive_dataset_covariate)
row.names(D4_descriptive_dataset_covariate)<-c("0","1")

# save as 3 tables: in D4_descriptive_dataset_age, D4_descriptive_dataset_ageband, D4_descriptive_dataset_covariate
save(D4_descriptive_dataset_covariate,file=paste0(diroutput,"D4_descriptive_dataset_covariate.RData"))
save(D4_descriptive_dataset_age,file=paste0(diroutput,"D4_descriptive_dataset_age.RData"))
save(D4_descriptive_dataset_ageband,file=paste0(diroutput,"D4_descriptive_dataset_ageband.RData"))



fwrite(D4_descriptive_dataset_ageband, paste0(direxp,"D4_descriptive_dataset_ageband.csv"))
fwrite(D4_descriptive_dataset_age, paste0(direxp,"D4_descriptive_dataset_age.csv"))
fwrite(D4_descriptive_dataset_covariate, paste0(direxp,"D4_descriptive_dataset_covariate.csv"))

