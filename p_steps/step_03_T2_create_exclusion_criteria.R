
# PERSONS -----------------------------------------------------

PERSONS <- fread(paste0(dirinput,"PERSONS.csv"))
OBSERVATION_PERIODS <- fread(paste0(dirinput,"OBSERVATION_PERIODS.csv"))


#STANDARDIZE THE DATE FORMAT WITH  LUBRIDATE
PERSONS<-PERSONS[,date_of_birth:=lubridate::ymd(with(PERSONS, paste(year_of_birth, month_of_birth, day_of_birth,sep="-")))]
PERSONS<-suppressWarnings(PERSONS[,date_death:=lubridate::ymd(with(PERSONS, paste(year_of_death, month_of_death, day_of_death,sep="-")))])

#CONVERT SEX to BINARY 0/1
PERSONS<-PERSONS[,sex:=as.numeric(ifelse(sex_at_instance_creation=="M",1,0))]
PERSONS<-PERSONS[,not_female:=ifelse(sex==1,1,0)] #1:M 0:F
#[,age_at_index_date:=age_fast(date_of_birth,index_date)][age_at_index_date<12 | age_at_index_date>55,age:=1]

PERSONS<-PERSONS[is.na(sex) | is.na(date_of_birth),sex_or_birth_date_missing:=1]
PERSONS<-PERSONS[year(date_of_birth)<1899 | year(date_of_birth)>2020, birth_date_absurd:=1]

# no observation period
PERSONS_in_OP<-unique(merge(PERSONS, OBSERVATION_PERIODS, all.x = T, by="person_id")[is.na(op_start_date),no_op_start_date:=1][is.na(no_op_start_date),no_op_start_date:=0][,MAXop_start_date:=max(no_op_start_date), by="person_id"][MAXop_start_date==no_op_start_date,],by="person_id")
D3_exclusion_no_op_start_date<-PERSONS_in_OP[,.(person_id,sex_or_birth_date_missing,birth_date_absurd,no_op_start_date)]

## KEEP ONLY NEED VARs
D3_inclusion_from_PERSONS <- PERSONS[,.(person_id,sex,date_of_birth,date_death)]


# OBSERVATION PERIODS -----------------------------------------------------

load(paste0(dirtemp,"output_spells_category.RData"))

output_spells_category_enriched <- merge(output_spells_category,D3_inclusion_from_PERSONS, by="person_id")

output_spells_category_enriched <- output_spells_category_enriched[,one_year_obs:=entry_spell_category+1*365]

output_spells_category_enriched <- output_spells_category_enriched[entry_spell_category<date_of_birth+60, entry_spell_category:=date_of_birth]

## CALCULATE study_entry_date
output_spells_category_enriched <- output_spells_category_enriched[,study_entry_date:=max(date_of_birth,study_start,one_year_obs),by="person_id"]
output_spells_category_enriched <- output_spells_category_enriched[date_of_birth>study_start & date_of_birth==entry_spell_category, study_entry_date:=date_of_birth]


## KEEP ONLY SPELLS THAT INCLUDE study_entry_date AND WHOSE entry_spell_category IS < exit_spell_category

output_spells_category_enriched <- output_spells_category_enriched[study_entry_date %between% list(entry_spell_category,exit_spell_category ) & entry_spell_category< exit_spell_category ,spell_contains_study_entry_date:=1, by="person_id"][is.na(spell_contains_study_entry_date),spell_contains_study_entry_date:=0]

# some children enter twice after 2017 so they have 2 spells, let's keep the first
output_spells_category_enriched <- output_spells_category_enriched[spell_contains_study_entry_date==1,][,minentry :=min(entry_spell_category),by = "person_id"]
output_spells_category_enriched <- output_spells_category_enriched[spell_contains_study_entry_date==1 & minentry==entry_spell_category,]
# if such children result having 2 spells starting at birth, let's keep the longest
output_spells_category_enriched <- output_spells_category_enriched[,maxexit :=max(exit_spell_category),by = "person_id"]
output_spells_category_enriched <- output_spells_category_enriched[maxexit==exit_spell_category,]

output_spells_category_enriched  <- output_spells_category_enriched[,countofrecord := .N, by = "person_id"] 

D3_exclusion_observed_time_no_overlap<-output_spells_category_enriched[,spell_contains_study_entry_dateMAX:=max(spell_contains_study_entry_date), by="person_id"][,observed_time_no_overlap:=1-spell_contains_study_entry_dateMAX] #[,.(person_id,observed_time_no_overlap)])

D3_exclusion_observed_time_no_overlap <- D3_exclusion_observed_time_no_overlap[one_year_obs>study_end | one_year_obs> exit_spell_category,insufficient_run_in:=1]
D3_exclusion_observed_time_no_overlap[is.na(insufficient_run_in),insufficient_run_in:=0]


D3_exclusion_observed_time_no_overlap <-merge(PERSONS[,.(person_id)],D3_exclusion_observed_time_no_overlap,by="person_id", all.x = T)[is.na(observed_time_no_overlap),observed_time_no_overlap:=1]

D3_exclusion_observed_time_no_overlap <-D3_exclusion_observed_time_no_overlap[is.na(insufficient_run_in),insufficient_run_in:=1]


# compute age at study entry date
D3_exclusion_observed_time_no_overlap <- D3_exclusion_observed_time_no_overlap[,age_at_study_entry_date:=age_fast(date_birth,study_entry_date)]

# compute age non in fertile age at study entry date
D3_exclusion_observed_time_no_overlap <- D3_exclusion_observed_time_no_overlap[age_at_study_entry_date<12 | age_at_study_entry_date>55,not_in_fertile_age_at_study_entry_date := 1][is.na(not_in_fertile_age_at_study_entry_date),not_in_fertile_age_at_study_entry_date := 0]


# there is some people whose death has not been recorded in the exit_spell, let's remove them

D3_exclusion_observed_time_no_overlap <-D3_exclusion_observed_time_no_overlap[is.na(date_death),min_death_exit_spell:=min(date_death,exit_spell_category)]

D3_exclusion_observed_time_no_overlap <-D3_exclusion_observed_time_no_overlap[is.na(min_death_exit_spell) & date_death < study_entry_date ,death_before_study_entry:=1]

D3_exclusion_observed_time_no_overlap <-D3_exclusion_observed_time_no_overlap[is.na(min_death_exit_spell) & date_death < exit_spell_category ,exit_spell_category:=date_death]

D3_exclusion_observed_time_no_overlap <-D3_exclusion_observed_time_no_overlap[is.na(death_before_study_entry),death_before_study_entry:=0]

D3_exclusion_observed_time_no_overlap <-D3_exclusion_observed_time_no_overlap[,.(person_id,observed_time_no_overlap, insufficient_run_in, death_before_study_entry)]


## KEEP ONLY NEED VARs
D3_inclusion_from_OBSERVATION_PERIODS <- output_spells_category_enriched[spell_contains_study_entry_date==1,.(person_id,study_entry_date,exit_spell_category)]
 
D3_inclusion_from_OBSERVATION_PERIODS <-merge(PERSONS[,.(person_id)],D3_inclusion_from_OBSERVATION_PERIODS,by="person_id", all.x = T)


PERSONS_OP <- merge(D3_inclusion_from_PERSONS,
                    D3_exclusion_no_op_start_date,
                    by="person_id",
                    all.x = T)
PERSONS_OP2 <- merge(PERSONS_OP,
                     D3_inclusion_from_OBSERVATION_PERIODS,
                     by="person_id",
                     all.x = T)
PERSONS_OP3 <- merge(PERSONS_OP2,
                     D3_exclusion_observed_time_no_overlap,
                     by="person_id",
                     all.x = T)

coords<-c("sex_or_birth_date_missing","birth_date_absurd","insufficient_run_in","observed_time_no_overlap","no_op_start_date","death_before_study_entry")
PERSONS_OP3[, (coords) := replace(.SD, is.na(.SD), 0), .SDcols = coords]

# CREATE study_exit_date
D3_selection_criteria <- PERSONS_OP3[,study_exit_date:=min(date_death, exit_spell_category, study_end, na.rm = T), by="person_id"]


save(D3_selection_criteria,file=paste0(dirtemp,"D3_selection_criteria.RData"))

rm(output_spells_category_enriched,D3_inclusion_from_OBSERVATION_PERIODS,D3_inclusion_from_PERSONS,D3_exclusion_observed_time_no_overlap)

rm( PERSONS_OP, PERSONS_OP2, PERSONS_OP3)







