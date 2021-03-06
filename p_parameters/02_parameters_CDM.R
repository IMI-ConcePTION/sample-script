###################################################################
# ASSIGN PARAMETERS DESCRIBING THE DATA MODEL OF THE INPUT FILES
###################################################################

# assign -ConcePTION_CDM_tables-: it is a 2-level list describing the ConcePTION CDM tables, and will enter the function as the first parameter. the first level is the data domain (in the example: 'Diagnosis' and 'Medicines') and the second level is the list of tables that has a column pertaining to that data domain 

ConcePTION_CDM_tables <- vector(mode="list")

files<-sub('\\.csv$', '', list.files(dirinput))
for (i in 1:length(files)) {
  if (str_detect(files[i],"^EVENTS"))  ConcePTION_CDM_tables[["Diagnosis"]][[(length(ConcePTION_CDM_tables[["Diagnosis"]]) + 1)]]<-files[i]
  else{if (str_detect(files[i],"^MEDICINES")) ConcePTION_CDM_tables[["Medicines"]][[(length(ConcePTION_CDM_tables[["Medicines"]]) + 1)]]<-files[i] }
}

#define tables for createconceptset
ConcePTION_CDM_EAV_tables <- vector(mode="list")
EAV_table<-c()
for (i in 1:length(files)) {
  if (str_detect(files[i],"^SURVEY_OB")) { ConcePTION_CDM_EAV_tables[["Diagnosis"]][[(length(ConcePTION_CDM_EAV_tables[["Diagnosis"]]) + 1)]]<-list(list(files[i], "so_source_table", "so_source_column"))
  EAV_table<-append(EAV_table,files[i])
  }
  else{if (str_detect(files[i],"^MEDICAL_OB")){ ConcePTION_CDM_EAV_tables[["Diagnosis"]][[(length(ConcePTION_CDM_EAV_tables[["Diagnosis"]]) + 1)]]<-list(list(files[i], "mo_source_table", "mo_source_column"))
  EAV_table<-append(EAV_table,files[i])}
  }
}

for (t in  names(ConcePTION_CDM_EAV_tables)) {
  ConcePTION_CDM_EAV_tables_retrieve = ConcePTION_CDM_EAV_tables [[t]]
}


alldomain<-names(ConcePTION_CDM_tables)

ConcePTION_CDM_codvar <- vector(mode="list")
ConcePTION_CDM_coding_system_cols <-vector(mode="list")

for (dom in alldomain) {
  for (i in 1:(length(ConcePTION_CDM_EAV_tables[["Diagnosis"]]))){
    for (ds in append(ConcePTION_CDM_tables[[dom]],ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]])) {
      if ( ds==ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]]) {
        if (str_detect(ds,"^SURVEY_OB"))  ConcePTION_CDM_codvar[["Diagnosis"]][[ds]]="so_source_value"
        if (str_detect(ds,"^MEDICAL_OB"))  ConcePTION_CDM_codvar[["Diagnosis"]][[ds]]="mo_source_value"
      }else{
        if (dom=="Medicines") ConcePTION_CDM_codvar[[dom]][[ds]]="product_ATCcode"
        if (dom=="Diagnosis") ConcePTION_CDM_codvar[[dom]][[ds]]="event_code"
      }
    }
  }
}

#coding system
for (dom in alldomain) {
  for (ds in ConcePTION_CDM_tables[[dom]]) {
    if (dom=="Diagnosis") ConcePTION_CDM_coding_system_cols[[dom]][[ds]] = "event_record_vocabulary"
    #    if (dom=="Medicines") ConcePTION_CDM_coding_system_cols[[dom]][[ds]] = "code_indication_vocabulary"
  }
}

# assign 2 more 2-level lists: -id- -date-. They encode from the data model the name of the column(s) of each data table that contain, respectively, the personal identifier and the date. Those 2 lists are to be inputted in the rename_col option of the function. 
#NB: GENERAL  contains the names columns will have in the final datasets

person_id <- vector(mode="list")
date<- vector(mode="list")


for (dom in alldomain) {
  for (i in 1:(length(ConcePTION_CDM_EAV_tables[[dom]]))){
    for (ds in append(ConcePTION_CDM_tables[[dom]],ConcePTION_CDM_EAV_tables[[dom]][[i]][[1]][[1]])) {
      person_id [[dom]][[ds]] = "person_id"
    }
  }
}


for (dom in alldomain) {
  for (i in 1:(length(ConcePTION_CDM_EAV_tables[["Diagnosis"]]))){
    for (ds in append(ConcePTION_CDM_tables[[dom]],ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]])) {
      if (ds==ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]]) {
        if (str_detect(ds,"^SURVEY_OB")) date[["Diagnosis"]][[ds]]="so_date"
        if (str_detect(ds,"^MEDICAL_OB")) date[["Diagnosis"]][[ds]]="mo_date"
      }else{
        if (dom=="Medicines") date[[dom]][[ds]]="date_dispensing"
        if (dom=="Diagnosis") date[[dom]][[ds]]="start_date_record"
      }
    }
  }
}


#FROM CMD_SOURCE
ConcePTION_CDM_EAV_attributes<-vector(mode="list")
datasources<-c("ARS")

for (dom in alldomain) {
  for (i in 1:(length(ConcePTION_CDM_EAV_tables[[dom]]))){
    for (ds in ConcePTION_CDM_EAV_tables[[dom]][[i]][[1]][[1]]) {
      for (dat in datasources) {
        if (dom=="Diagnosis") ConcePTION_CDM_EAV_attributes[[dom]][[ds]][[dat]][["ICD9"]] <-  list(list("RMR","CAUSAMORTE"))
        ConcePTION_CDM_EAV_attributes[[dom]][[ds]][[dat]][["ICD10"]] <-  list(list("RMR","CAUSAMORTE_ICDX"))
        ConcePTION_CDM_EAV_attributes[[dom]][[ds]][[dat]][["SNOMED"]] <-  list(list("AP","COD_MORF_1"),list("AP","COD_MORF_2"),list("AP","COD_MORF_3"),list("AP","COD_TOPOG"))
        #        if (dom=="Medicines") ConcePTION_CDM_EAV_attributes[[dom]][[ds]][[dat]][["ICD9"]] <-  list(list("CAP1","SETTAMEN_ARSNEW"),list("CAP1","GEST_ECO"),list("AP","COD_MORF_1"),list("AP","COD_MORF_2"),list("AP","COD_MORF_3"),list("AP","COD_TOPOG"))
      }
    }
  }
}


ConcePTION_CDM_EAV_attributes_this_datasource<-vector(mode="list")

for (t in  names(ConcePTION_CDM_EAV_attributes)) {
  for (f in names(ConcePTION_CDM_EAV_attributes[[t]])) {
    for (s in names(ConcePTION_CDM_EAV_attributes[[t]][[f]])) {
      if (s==thisdatasource ){
        ConcePTION_CDM_EAV_attributes_this_datasource[[t]][[f]]<-ConcePTION_CDM_EAV_attributes[[t]][[f]][[s]]
      }
    }
  }
}


#discard level datasource

#create ConcePTION_CDM_EAV_attributes_this_datasource

ConcePTION_CDM_datevar<-vector(mode="list")

for (dom in alldomain) {
  for (i in 1:(length(ConcePTION_CDM_EAV_tables[["Diagnosis"]]))){
    for (ds in append(ConcePTION_CDM_tables[[dom]],ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]])) {
      if (ds==ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]]) {
        if (str_detect(ds,"^SURVEY_OB")) ConcePTION_CDM_datevar[["Diagnosis"]][[ds]]="so_date"
        if (str_detect(ds,"^MEDICAL_OB"))  ConcePTION_CDM_datevar[["Diagnosis"]][[ds]]="mo_date"
      }else{
        if (dom=="Medicines") ConcePTION_CDM_datevar[[dom]][[ds]]= list("date_dispensing","date_prescription")
        if (dom=="Diagnosis") ConcePTION_CDM_datevar[[dom]][[ds]]=list("start_date_record","end_date_record")
      }
    }
  }
}


ConcePTION_CDM_datevar_retrieveA<-list()
for (i in 1:(length(ConcePTION_CDM_EAV_tables[["Diagnosis"]]))){
  for (ds in ConcePTION_CDM_EAV_tables[["Diagnosis"]][[i]][[1]][[1]]) {
    ConcePTION_CDM_datevar_retrieveA = ConcePTION_CDM_datevar [["Diagnosis"]]
  }
}

ConcePTION_CDM_datevar_retrieve<-ConcePTION_CDM_datevar_retrieveA