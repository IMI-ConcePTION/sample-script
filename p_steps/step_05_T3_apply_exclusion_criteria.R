# FLOWCHART ---------------------------------------------------------------

load(paste0(dirtemp,"D3_selection_criteria.RData"))

#USE THE FUNCTION CREATEFLOWCHART TO SELECT THE SUBJECTS IN POPULATION

selected_population <- CreateFlowChart(
  dataset = D3_selection_criteria,
  listcriteria = c("sex_or_birth_date_missing","birth_date_absurd","no_op_start_date","death_before_study_entry","observed_time_no_overlap","insufficient_run_in"),
  flowchartname = "FlowChart" )


# D4_study_population contains the starting information on age and days of follow up per each patient
D4_study_population <- unique(selected_population[,.(person_id,sex,date_of_birth,study_entry_date,study_exit_date)])
#Cohort0[,index_date:=index_date]

fwrite(FlowChart, paste0(direxp,"FlowChart.csv"))

save(D4_study_population,file=paste0(diroutput,"D4_study_population.RData"))

# rm(PERSONS, OBSERVATION_PERIODS)
