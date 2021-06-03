options(shiny.trace = F)  

#####---base
library(shiny)
library(shiny.semantic)    
library(semantic.dashboard) 
library(rhandsontable)
library(owmr)
library(leaflet)
library(readxl) 
library(plyr)

source("modules/Dashboard_file.R",local=TRUE)  
#sourced API
OWM_API_KEY= "86daa06743a3c7591436928b2d8ca1af"

# first of all you have to set up your api key
owmr_settings(OWM_API_KEY)

# or store it in an environment variable called OWM_API_KEY (recommended)
Sys.setenv(OWM_API_KEY = OWM_API_KEY) # if not set globally


#-----------------------------
#How to use https://openweathermap.org/ to retrieve weather forecasts for a particular region
#R library package is library(owmr)
#click API tab

#------------------------------
#google translate
#You will need to subscribe to google translate api
#guidance article
#I could not subscribe to it as it charges
#Once you have it activated, you just need to convert all text in the description column to "de"
#All the words in the table will then be converted to Dutch
#https://vladdsm.github.io/myblog_attempt/topics/topics-AutotranslateGoogleAPI.html

#Theres then a list of API lists you can select from.
#I selected the hourly forecast 4 days (clieck subscibe)

#I selected the free one which only offers 3-hour forecast
#The hourly 4 day forecast you must select the developer package for 180 USD/Month
#For reference :https://openweathermap.org/full-price#current

#Once you have subscribed, you can change my OWM_API_KEY= "86daa06743a3c7591436928b2d8ca1af" API Key
#with the new one you are given
