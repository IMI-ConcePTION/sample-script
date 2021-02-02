# create variable added to study population

load(paste0(diroutput,"D4_study_population.RData"))
load(paste0(dirtemp,"D3_study_population_covariates.RData"))

population_var<- D4_study_population[,age_at_study_entry:=age_fast(date_of_birth,study_entry_date)] [, year_at_study_entry:=year(study_entry_date)] 
population_var<-population_var [,age_strata_at_study_entry:=cut(age_at_study_entry, breaks = Agebands,  labels = c("0-19","20-29", "30-39", "40-49","50-59","60-69", "70-79","80+"))]

D4_study_population_cov<-merge(population_var, D3_study_population_covariates[,-"study_entry_date"], by="person_id", all.x = T)

D4_study_population_cov <- D4_study_population_cov[,-c("date_of_birth","study_entry_date","study_exit_date")]


save(D4_study_population_cov,file=paste0(diroutput,"D4_study_population_cov.RData"))
rm(population_var, D4_study_population)

