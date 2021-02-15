# ----------------------------------
# for all covariates create binary variable drug procy OR diagnosis; also create binary 'overall'

# create variable added to study population

load(paste0(diroutput,"D4_study_population.RData"))
load(paste0(diroutput,"D4_study_population_cov.RData"))
load(paste0(dirtemp,"D3_study_population_DP.RData"))


D3_study_population_cov_ALL <- merge(D4_study_population[,-c("study_entry_date","sex")], D4_study_population_cov, by="person_id", all.x = T)

D3_study_population_cov_ALL <- merge(D3_study_population_cov_ALL, D3_study_population_DP, by="person_id", all.x = T)

D3_study_population_cov_ALL <- D3_study_population_cov_ALL[, all_covariates_non_CONTR := 0 ]

for (cov in COVnames ){
  if ( cov!="CV" ){
    nameDP =  paste0("DP_",cov,"_at_study_entry")
  }
  else{
    nameDP = "DP_CVD_at_study_entry"
  }
  D3_study_population_cov_ALL <- D3_study_population_cov_ALL[get(paste0(cov,"_at_study_entry")) == 1 | get(nameDP) == 1, namevar := 1]
  # print(nameDP)
  D3_study_population_cov_ALL <- D3_study_population_cov_ALL[namevar == 1 ,all_covariates_non_CONTR :=1]
 
  setnames(D3_study_population_cov_ALL,"namevar",paste0(cov,"_either_DX_or_DP"))
  D3_study_population_cov_ALL[is.na(D3_study_population_cov_ALL)] <- 0
}


save(D3_study_population_cov_ALL,file=paste0(diroutput,"D3_study_population_cov_ALL.RData"))
rm(D4_study_population_cov, D3_study_population_DP, D4_study_population)

