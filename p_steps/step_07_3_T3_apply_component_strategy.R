# ----------------------------------------------------
# create component datasets & figures for each outcome

firstyear=firstYearComponentAnalysis
secondyear=secondYearComponentAnalysis

for (OUTCOME in OUTCOME_events) {
  print(OUTCOME)
  nameobject <- paste0("D3_components_",OUTCOME)
  load( paste0(dirtemp,paste0(nameobject,".RData")))
  input <- as.data.table(get(nameobject))
  input[is.na(input)] <- 0
  input[,todrop:=0]
  #look at vars containing 2018 in the name
#  var2018 <- grep("2018$", names(input), value = TRUE) #dput(
  varfirstyear <- grep(paste0(firstyear,"$"), names(input), value = TRUE) #dput(
  input[,i:=.I]  
  #sum of the variables that contains 2018
  input[,sumfirstyear:= sum(.SD,na.rm=T), by = i, .SDcols=varfirstyear]  
  #reply todrop=1, for which who has sum>=1
  input<-input[sumfirstyear>=1,todrop:=1]
  input[,c('sumfirstyear','i'):=NULL]
  #keep only who didn't have event in 2018
  input<-input[todrop==0,] 
  
  name_components<-c(paste0(OUTCOME,"_narrow_HOSP_",secondyear),paste0(OUTCOME,"_narrow_PC_",secondyear),paste0(OUTCOME,"_possible_HOSP_",secondyear),paste0(OUTCOME,"_possible_PC_",secondyear))
  
  name_intermediate<-paste0(dirtemp,"D4_algorithm_comparison_",OUTCOME,"_intermediate")  
 
  figure_name<-paste0(OUTCOME,"_components")
  print(figure_name)
  
  output <- ApplyComponentStrategy(dataset = input,
                                 individual = T,         ## F -> data counts
                                 intermediate_output=T, 
                                 intermediate_output_name=name_intermediate,
                                 components=name_components,
                                 composites=list(
                                   list(1,3),
                                   list(1,2),
                                   list(3,4),
                                   list(5,2),
                                   list(5,4),
                                   list(2,4),
                                   list(5,10),
                                   list(6,7)),
                                 labels_of_components=c(
                                   "Narrow HOSP",
                                   "Narrow PC",
                                   "Possible HOSP",
                                   "Possible PC"),
                                 figure_name=figure_name,      ## optional
                                 K=1000,
                                 figure=T,
                                 aggregate=F ,
 #                                output_name=name_output
                                 )
  name_output <-paste0("D4_algorithm_comparison_",OUTCOME)
  save(output, file = paste0(diroutput,name_output,'.RData'))
  fwrite(output, file = paste0(direxp,name_output,'.csv'))
}


