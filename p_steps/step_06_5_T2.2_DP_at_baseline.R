#--------------------------------------------
# create a covariate for each drug proxy in DRUGS_conceptssets
# covaria : =1 if there are at least 2 records during 365 days of lookback

load(paste0(diroutput,"D4_study_population.RData"))
COHORT_TMP <- D4_study_population[,.(person_id, study_entry_date)]
D3_study_population_DP <- COHORT_TMP

for (conceptset in DRUGS_conceptssets) {
    load(paste0(dirtemp,conceptset,".RData"))
    output <- MergeFilterAndCollapse(list(get(conceptset)),
                                     condition= "date >= study_entry_date - 365 & date<=study_entry_date",
                                     key = c("person_id"),
                                     datasetS = COHORT_TMP,
                                     additionalvar = list(
                                     list(c("n"),"1","date <= study_entry_date")
                                     ),
                                     saveintermediatedataset= F,
                                     strata=c("person_id"),
                                     summarystat = list(
                                       list(c("sum"),"n","howmanyrecords")
                                       )
    )
    output <- output[howmanyrecords > 1 ,namevar := 1]
    output <- output[,.(person_id,namevar)]
    setnames(output,"namevar",paste0(conceptset,"_at_study_entry"))
    D3_study_population_DP <- merge(D3_study_population_DP,output,all.x = T, by="person_id")
    D3_study_population_DP[is.na(D3_study_population_DP)] <- 0
    rm(list = conceptset)
    rm(output)
}

save(D3_study_population_DP,file=paste0(dirtemp,"D3_study_population_DP.RData"))

rm(COHORT_TMP, D3_study_population_DP, D4_study_population)



