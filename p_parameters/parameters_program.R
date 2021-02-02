dirbase<-getwd()
dirinput <- paste0(dirbase,"/i_input/")

# set other directories
diroutput <- paste0(thisdir,"/g_output/")
dirtemp <- paste0(thisdir,"/g_intermediate/")
direxp <- paste0(thisdir,"/g_export/")
dirmacro <- paste0(thisdir,"/p_macro/")
dirfigure <- paste0(thisdir,"/g_figure/")
extension <- c(".csv")
dirpargen <- paste0(thisdir,"/g_parameters/")
dirsmallcountsremoved <- paste0(thisdir,"/g_export_SMALL_COUNTS_REMOVED/")

# load packages
if (!require("haven")) install.packages("haven")
library(haven)
if (!require("tidyverse")) install.packages("tidyverse")
library(dplyr)
if (!require("lubridate")) install.packages("lubridate")
library(lubridate)
if (!require("data.table")) install.packages("data.table")
library(data.table)
if (!require("AdhereR")) install.packages("AdhereR")
library(AdhereR)
if (!require("stringr")) install.packages("stringr")
library(stringr)
if (!require("purrr")) install.packages("purrr")
library(purrr)
if (!require("readr")) install.packages("readr")
library(readr)
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
if (!require("survival")) install.packages("survival")
library(survival)

# load macros

source(paste0(dirmacro,"CreateConceptSetDatasets_v10.R"))
source(paste0(dirmacro,"RetrieveRecordsFromEAVDatasets.R"))
source(paste0(dirmacro,"MergeFilterAndCollapse_v5.R"))
source(paste0(dirmacro,"CreateSpells_v8DT.R"))
source(paste0(dirmacro,"CreateFlowChart.R"))
source(paste0(dirmacro,"CountPersonTimeV9.2.R"))
source(paste0(dirmacro,"ApplyComponentStrategy_v12.R"))
source(paste0(dirmacro,"CreateFigureComponentStrategy_v1.2.R"))

#other parameters

date_format <- "%Y%m%d"


#---------------------------------------
# understand which datasource the script is querying

CDM_SOURCE<- fread(paste0(dirinput,"CDM_SOURCE.csv"))
thisdatasource <- as.character(CDM_SOURCE[1,3])

#---------------------------------------
# assess datasource-specific parameters

# datasources with prescriptions instead of dispensations

datasources_prescriptions <- c('CPRD')
thisdatasource_has_prescriptions <- ifelse(thisdatasource %in% datasources_prescriptions,TRUE,FALSE)

#study_start_datasource

study_start_datasource <- vector(mode="list")

study_start_datasource[['ARS']] <- as.Date(as.character(20170101), date_format)
study_start_datasource[['FISABIO']] <- as.Date(as.character(20170101), date_format)
study_start_datasource[['CPRD']] <- as.Date(as.character(20170101), date_format)
study_start_datasource[['SIDIAP']] <- as.Date(as.character(20170101), date_format)

study_start <- study_start_datasource[[thisdatasource]]

# study_end_datasource

study_end_datasource <- vector(mode="list")

study_end_datasource[['ARS']] <- as.Date(as.character(20200531), date_format)
study_end_datasource[['FISABIO']] <- as.Date(as.character(20201130), date_format)
study_end_datasource[['CPRD']] <- as.Date(as.character(20200930), date_format)
study_end_datasource[['SDIAP']] <- as.Date(as.character(20200630), date_format)



study_end <- study_end_datasource[[thisdatasource]]


#study_years_datasource

study_years_datasource <- vector(mode="list")

study_years_datasource[['ARS']] <-  c("2017","2018","2019","2020")
study_years_datasource[['FISABIO']] <-  c("2017","2018","2019","2020")
study_years_datasource[['CPRD']] <-  c("2017","2018","2019","2020")
study_years_datasource[['SIDIAP']] <-  c("2017","2018","2019","2020")

study_years <- study_years_datasource[[thisdatasource]]


firstYearComponentAnalysis_datasource <- vector(mode="list")
secondYearComponentAnalysis_datasource <- vector(mode="list")

firstYearComponentAnalysis_datasource[['ARS']] <- '2018'
firstYearComponentAnalysis_datasource[['FISABIO']] <- '2018'
firstYearComponentAnalysis_datasource[['CPRD']] <- '2018'
firstYearComponentAnalysis_datasource[['SIDIAP']] <- '2018'

for (datas in c('ARS','FISABIO','CPRD','SIDIAP')){
  secondYearComponentAnalysis_datasource[[datas]] = as.character(as.numeric(firstYearComponentAnalysis_datasource[[datas]])+1)
}

firstYearComponentAnalysis = firstYearComponentAnalysis_datasource[[thisdatasource]]
secondYearComponentAnalysis = secondYearComponentAnalysis_datasource[[thisdatasource]]


#############################################
#SAVE METADATA TO direxp
#############################################

file.copy(paste0(dirinput,'/METADATA.csv'), direxp)
file.copy(paste0(dirinput,'/CDM_SOURCE.csv'), direxp)
file.copy(paste0(dirinput,'/INSTANCE.csv'), direxp)


#FUNCTION TO COMPUTE AGE
age_fast = function(from, to) {
  from_lt = as.POSIXlt(from)
  to_lt = as.POSIXlt(to)

  age = to_lt$year - from_lt$year

  ifelse(to_lt$mon < from_lt$mon |
           (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
         age - 1, age)
}
