
OWM_API_KEY= "86daa06743a3c7591436928b2d8ca1af"

library(owmr)

# first of all you have to set up your api key
owmr_settings(OWM_API_KEY)

# or store it in an environment variable called OWM_API_KEY (recommended)
Sys.setenv(OWM_API_KEY = OWM_API_KEY) # if not set globally

# get current weather data by city name
(res <- get_current("Netherlands", units = "metric") %>%
    owmr_as_tibble()) %>% names()
res[, 1:6]


# get forecast
forecast <- get_forecast("Netherlands", units = "metric") %>%
  owmr_as_tibble()
Weather.data = data.frame(forecast)
 

#subset data by Date, temp and weather description

Weather.data = Weather.data[ , c(1, 2, 9)]
rhandsontable(Weather.data)
#rename columns
colnames(Weather.data) <- c( "Date (3hr interval)","Temperature","Weather Description")  
#Weather.data[Weather.data$`Date (3hr interval)`>=Sys.Date() &Weather.data$`Date (3hr interval)`<=Sys.Date()+1,]

library(readxl) 
getwd()
MyCalendr <- read_excel("calendr_folder/MyCalendr.xls")
colnames(MyCalendr) <- c( "Date (3hr interval)","activiteit")  

library(plyr)

#Joining by: Date (3hr interval)
merged.data = join(Weather.data, MyCalendr,
                   type = "inner")
merged.data [is.na(merged.data )] <- ""

#show good time to jog if theres no activity on the calender and the tempterature if >15
merged.data["jogging decision"] = ifelse(merged.data$Temperature>15 & 
                                           merged.data$activiteit =="","joggen","niet joggen")
merged.data 
