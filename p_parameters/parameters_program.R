dirbase<-getwd()
dirinput <- paste0(dirbase,"/i_input/")

# set other directories
diroutput <- paste0(thisdir,"/g_output/")
dirtemp <- paste0(thisdir,"/g_intermediate/")
dirfromCDM <- paste0(thisdir,"/g_fromCDM/")
direxp <- paste0(thisdir,"/g_export/")
dirmacro <- paste0(thisdir,"/p_macro/")
dirfigure <- paste0(thisdir,"/g_figure/")
extension <- c(".csv")
#dirpargen <- paste0(thisdir,"/g_parameters/")
dirsmallcountsremoved <- paste0(thisdir,"/g_export_SMALL_COUNTS_REMOVED/")


#create folders
suppressWarnings(if (!file.exists(diroutput)) dir.create(file.path( diroutput)))
suppressWarnings(if (!file.exists(dirtemp)) dir.create(file.path( dirtemp)))
suppressWarnings(if (!file.exists(direxp)) dir.create(file.path( direxp)))
suppressWarnings(if (!file.exists(dirfigure)) dir.create(file.path( dirfigure)))
#suppressWarnings(if (!file.exists(dirpargen)) dir.create(file.path( dirpargen)))
suppressWarnings(if (!file.exists(dirsmallcountsremoved)) dir.create(file.path(dirsmallcountsremoved)))
suppressWarnings(if (!file.exists(dirfromCDM)) dir.create(file.path(dirfromCDM)))


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

#---------------------------------------
# understand which datasource the script is querying

CDM_SOURCE<- fread(paste0(dirinput,"CDM_SOURCE.csv"))
thisdatasource <- as.character(CDM_SOURCE[1,3])

#other parameters

date_format <- "%Y%m%d"

#---------------------------------------
# assess datasource-specific parameters

# datasources with prescriptions instead of dispensations

datasources_prescriptions <- c('CPRD')
thisdatasource_has_prescriptions <- ifelse(thisdatasource %in% datasources_prescriptions,TRUE,FALSE)

#study_start

study_start <- as.Date(as.character(20180101), date_format)

# study_end

study_end <- as.Date(as.character(20181231), date_format)

#study_years

study_years <- c("2018")

# years component analysis

firstYearComponentAnalysis = '2017'
secondYearComponentAnalysis = '2018'


#############################################
#SAVE METADATA TO direxp
#############################################

file.copy(paste0(dirinput,'/METADATA.csv'), direxp)
file.copy(paste0(dirinput,'/CDM_SOURCE.csv'), direxp)
file.copy(paste0(dirinput,'/INSTANCE.csv'), direxp)


# load macros

source(paste0(dirmacro,"CreateConceptSetDatasets_v10.R"))
source(paste0(dirmacro,"RetrieveRecordsFromEAVDatasets.R"))
source(paste0(dirmacro,"MergeFilterAndCollapse_v5.R"))
source(paste0(dirmacro,"CreateSpells_v8DT.R"))
source(paste0(dirmacro,"CreateFlowChart.R"))
source(paste0(dirmacro,"CountPersonTimeV9.2.R"))
<<<<<<< HEAD
source(paste0(dirmacro,"ApplyComponentStrategy_v13_2.R"))
source(paste0(dirmacro,"CreateFigureComponentStrategy_v3.R"))

=======
#source(paste0(dirmacro,"ApplyComponentStrategy_v12.R"))
#source(paste0(dirmacro,"CreateFigureComponentStrategy_v1.2.R"))
source(paste0(dirmacro,"ApplyComponentStrategy_v13_1.R"))
source(paste0(dirmacro,"CreateFigureComponentStrategy_v3.R"))
>>>>>>> development

#FUNCTION TO COMPUTE AGE
age_fast = function(from, to) {
  from_lt = as.POSIXlt(from)
  to_lt = as.POSIXlt(to)

  age = to_lt$year - from_lt$year

  ifelse(to_lt$mon < from_lt$mon |
           (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
         age - 1, age)
}

Agebands =c(-1, 19, 29, 39, 49, Inf)
