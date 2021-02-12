# PERSONS -----------------------------------------------------

PERSONS <- fread(paste0(dirinput,"PERSONS.csv"))

#STANDARDIZE THE DATE FORMAT WITH  LUBRIDATE
PERSONS<-PERSONS[,study_entry_date:= study_start]

PERSONS<-PERSONS[,date_of_birth:=lubridate::ymd(with(PERSONS, paste(year_of_birth, month_of_birth, day_of_birth,sep="-")))]
PERSONS<-suppressWarnings(PERSONS[,date_of_death:=lubridate::ymd(with(PERSONS, paste(year_of_death, month_of_death, day_of_death,sep="-")))])

#CONVERT SEX to BINARY 0/1
PERSONS<-PERSONS[,sex:=as.numeric(ifelse(sex_at_instance_creation=="M",1,0))]
PERSONS<-PERSONS[,not_female:=ifelse(sex==1,1,0)] #1:M 0:F
PERSONS<-PERSONS[,age_at_study_entry:=age_fast(date_of_birth,study_entry_date)][age_at_study_entry<12 | age_at_study_entry>55,not_in_fertile_age_at_study_entry_date:=1]

PERSONS<-PERSONS[is.na(sex) | is.na(date_of_birth),sex_or_birth_date_missing:=1]
PERSONS<-PERSONS[year(date_of_birth)<1899 | year(date_of_birth)>2020, birth_date_absurd:=1]

## KEEP ONLY NEED VARs
D3_inclusion_from_PERSONS <- PERSONS[,.(person_id,sex,not_female, date_of_birth,sex_or_birth_date_missing,birth_date_absurd, age_at_study_entry,not_in_fertile_age_at_study_entry_date,study_entry_date,date_of_death)]


# OBSERVATION PERIODS -----------------------------------------------------

load(paste0(dirfromCDM,"output_spells_category.RData"))

D3_selection_criteria <- merge(output_spells_category,D3_inclusion_from_PERSONS, by="person_id")

D3_selection_criteria<-D3_selection_criteria[entry_spell_category<=study_entry_date & (is.na(exit_spell_category) | exit_spell_category>=study_entry_date),lookback_days:=study_entry_date-entry_spell_category][lookback_days<365*5 | is.na(lookback_days),insufficient_run_in:=1]

D3_selection_criteria <-D3_selection_criteria[date_of_death < study_entry_date ,death_before_study_entry:=1]

coords<-c("sex_or_birth_date_missing","birth_date_absurd","not_female","not_in_fertile_age_at_study_entry_date","insufficient_run_in","death_before_study_entry")
D3_selection_criteria[, (coords) := replace(.SD, is.na(.SD), 0), .SDcols = coords]

# # CREATE study_exit_date
D3_selection_criteria <- D3_selection_criteria[,study_exit_date:=min(date_of_death, exit_spell_category, study_end, na.rm = T), by="person_id"]

D3_selection_criteria<-D3_selection_criteria[,-c("op_meaning","num_spell","entry_spell_category","exit_spell_category", "lookback_days", "date_of_death" )]

save(D3_selection_criteria,file=paste0(dirtemp,"D3_selection_criteria.RData"))

rm(output_spells_category)

