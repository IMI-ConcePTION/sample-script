
# OBSERVATION PERIODS -----------------------------------------------------

OBSERVATION_PERIODS <- fread(paste0(dirinput,"OBSERVATION_PERIODS.csv"))

#COMPUTE SPELLS AND CONSIDER ONLY THE ONE OF INTEREST FOR THE STUDY

# TO ADD: if there are two values in op_meaning, compute also overlaps

output_spells_category <- CreateSpells(
  dataset=OBSERVATION_PERIODS,
  id="person_id" ,
  start_date = "op_start_date",
  end_date = "op_end_date",
  category ="op_meaning"
  )

output_spells_category<-as.data.table(output_spells_category)
setkeyv(
  output_spells_category,
  c("person_id", "entry_spell_category", "exit_spell_category", "num_spell", "op_meaning")
  )

 
save(output_spells_category,file=paste0(dirfromCDM,"output_spells_category.RData"))
