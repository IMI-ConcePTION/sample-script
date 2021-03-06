#-------------------------------
# ConcePTION TOY SCRIPT IR
# # authors: Claudia Bartolini, Rosa Gini, Olga Paoletti


rm(list=ls(all.names=TRUE))

#set the directory where the file is saved as the working directory
if (!require("rstudioapi")) install.packages("rstudioapi")
thisdir<-setwd(dirname(rstudioapi::getSourceEditorContext()$path))
thisdir<-setwd(dirname(rstudioapi::getSourceEditorContext()$path))


#load parameters
source(paste0(thisdir,"/p_parameters/01_parameters_program.R"))
source(paste0(thisdir,"/p_parameters/02_parameters_CDM.R"))
source(paste0(thisdir,"/p_parameters/03_concept_sets.R"))
source(paste0(thisdir,"/p_parameters/04_algorithms.R"))


#run scripts

# 01 RETRIEVE RECORDS FRM CDM

source(paste0(thisdir,"/p_steps/step_01_1_T2.1_create_conceptset_datasets.R"))
source(paste0(thisdir,"/p_steps/step_01_2_T2.1_create_spells.R"))

# 02 COUNT CODES 
source(paste0(thisdir,"/p_steps/step_02_T2.2_count_codes.R"))
  
# 03 CREATE EXCLUSION CRITERIA
source(paste0(thisdir,"/p_steps/step_03_T2_create_exclusion_criteria.R"))

# 04 APPLY EXCLUSION CRITERIA
source(paste0(thisdir,"/p_steps/step_04_T3_apply_exclusion_criteria.R"))

# 05 CREATE STUDY VARIABLES
source(paste0(thisdir,"/p_steps/step_05_1_T2.2_components.R"))
source(paste0(thisdir,"/p_steps/step_05_2_T2.2_covariates.R"))
source(paste0(thisdir,"/p_steps/step_05_3_T2.3_baseline_characteristics.R"))
source(paste0(thisdir,"/p_steps/step_05_4_T2.2_components_beyond_HOSP_and_PC.R"))
source(paste0(thisdir,"/p_steps/step_05_5_T2.2_DP_at_baseline.R"))
source(paste0(thisdir,"/p_steps/step_05_6_T2.3_ALL_covariates_at_baseline.R"))


# 06 CREATE D4s
source(paste0(thisdir,"/p_steps/step_06_1_T3_aggregate_baseline_characteristics.R"))
#source(paste0(thisdir,"/p_steps/step_06_2_T3_aggregate_baseline_characteristics_ALL.R"))
source(paste0(thisdir,"/p_steps/step_06_2_T3_apply_component_strategy.R"))
source(paste0(thisdir,"/p_steps/step_06_3_T3_create_events_all_outcomes.R"))
source(paste0(thisdir,"/p_steps/step_06_4_T3_create_person_time.R"))

print("End of the script")


