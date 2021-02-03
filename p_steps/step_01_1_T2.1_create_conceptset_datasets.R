
# APPLY THE FUNCTION CreateConceptSetDatasets TO CREATE ONE DATASET PER CONCEPT SET CONTAINING ONLY RECORDS WITH A CODE OF INTEREST


CreateConceptSetDatasets(concept_set_names = c(OUTCOMES_conceptssets),
                         dataset = ConcePTION_CDM_tables,
                         codvar = ConcePTION_CDM_codvar,
                         datevar= ConcePTION_CDM_datevar,
                         dateformat= "YYYYmmdd",
                         vocabulary = ConcePTION_CDM_coding_system_cols,
                         rename_col = list(person_id=person_id,date=date),
                         concept_set_domains = concept_set_domains,
                         concept_set_codes =	concept_set_codes_our_study,
                         concept_set_codes_excl = concept_set_codes_our_study_excl,
                         discard_from_environment = T,
                         dirinput = dirinput,
                         diroutput = dirfromCDM,
                         extension = c("csv"))

CreateConceptSetDatasets(concept_set_names = c(COV_conceptssets),
                         dataset = ConcePTION_CDM_tables,
                         codvar = ConcePTION_CDM_codvar,
                         datevar= ConcePTION_CDM_datevar,
                         dateformat= "YYYYmmdd",
                         vocabulary = ConcePTION_CDM_coding_system_cols,
                         rename_col = list(person_id=person_id,date=date),
                         concept_set_domains = concept_set_domains,
                         concept_set_codes =	concept_set_codes_our_study,
                         concept_set_codes_excl = concept_set_codes_our_study_excl,
                         discard_from_environment = T,
                         dirinput = dirinput,
                         diroutput = dirfromCDM,
                         extension = c("csv"))

CreateConceptSetDatasets(concept_set_names = c(DRUGS_conceptssets),
                         dataset = ConcePTION_CDM_tables,
                         codvar = ConcePTION_CDM_codvar,
                         datevar= ConcePTION_CDM_datevar,
                         dateformat= "YYYYmmdd",
                         vocabulary = ConcePTION_CDM_coding_system_cols,
                         rename_col = list(person_id=person_id,date=date),
                         concept_set_domains = concept_set_domains,
                         concept_set_codes =	concept_set_codes_our_study,
                         concept_set_codes_excl = concept_set_codes_our_study_excl,
                         discard_from_environment = T,
                         dirinput = dirinput,
                         diroutput = dirfromCDM,
                         extension = c("csv"))