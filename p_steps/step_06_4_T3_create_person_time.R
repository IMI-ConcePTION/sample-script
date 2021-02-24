# COUNT PERSON TIME PER ALL OUTCOMES
#-----------------------------------------------

print("COUNT PERSON TIME PER ALL OUTCOMES")

load(paste0(diroutput,"D4_study_population.RData")) # fread(paste0(dirinput,"PERSONS.csv"))
load(paste0(dirtemp,"list_outcomes_observed.RData")) 
load(paste0(dirtemp,"D3_events_ALL_OUTCOMES.RData")) 


D4_study_population <- as.data.table(D4_study_population)

start_persontime_studytime = as.character(paste0(study_years[1],"0101"))
end_persontime_studytime = as.character(paste0(study_years[length(study_years)],"1231"))
  
Output_file<-CountPersonTime(
  Dataset_events = datasetOUTCOMES,
  Dataset = D4_study_population,
  Person_id = "person_id",
  Start_study_time = start_persontime_studytime,
  End_study_time = end_persontime_studytime,
  Start_date = "study_entry_date",
  End_date = "study_exit_date",
  Birth_date = "date_of_birth",
  Strata = c("sex"),
  Name_event = "name_event",
  Date_event = "date_event",
  Age_bands = c(0,19,29,39,49,59,69,79),
  Increment="year",
  Outcomes =  list_outcomes_observed, #c("CAD_narrow","CAD_broad"),
  Unit_of_age = "year",
  include_remaning_ages = T,
  Aggregate = T
)
nameobject <- paste0("D4_persontime_ALL_OUTCOMES_year")
assign(nameobject, Output_file)
save(nameobject,file=paste0(diroutput,paste0(nameobject,".RData")),list=nameobject)
fwrite(get(nameobject),file=paste0(direxp,paste0(nameobject,".csv")))
rm(list = nameobject)
