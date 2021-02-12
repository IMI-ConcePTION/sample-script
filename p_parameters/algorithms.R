#---------------------------------
# DETAILS ON ALGORITHMS


# we need to create two groups of meanings: one referring to hospitals HOSP (excluding emergency care) and one referring to primary care PC
meanings_of_this_study<-vector(mode="list")
meanings_of_this_study[["HOSP"]]=c("hospitalisation_primary","hospitalisation_secondary","hospital_diagnosis","hopitalisation_diagnosis_unspecified","episode_primary_diagnosis","episode_secondary_diagnosis","diagnosis_procedure","hospitalisation_associated","hospitalisation_linked")
meanings_of_this_study[["PC"]]=c("primary_care_event","primary_care_diagnosis")