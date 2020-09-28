# =============================================================================================
# Codigo para obtener datos de casos de COVID-19 en Bolivia por Departamento.
#
#
# Este codigo obtiene los datos del repositorio de Manu Foronda y los transforma de formato "wide"
# a formato "long" para poder utilizar las herramientas de EpiNow y estimar Rt y pronosticos de casos de 
# de Covid19 en Bolivia.
#
# Codigo escrito por: Pablo Cuba-Borda. Federal Reserver Board. Washington, D.C. 
# Esta version: Septiembre-27-2020. 
# =============================================================================================
library(RCurl)
library(tidyverse)

# Obtener Datos
x <- getURL("https://raw.githubusercontent.com/mauforonda/covid19-bolivia/master/confirmados.csv")
daily_cases <- read.csv(text = x)

# Change to date format
daily_cases$Fecha <- as.Date(daily_cases[["Fecha"]], "%Y-%m-%d")

# Relabel column names 
colnames(daily_cases)[2]<-"La Paz"
colnames(daily_cases)[4]<-"Santa Cruz"
colnames(daily_cases)[6]<-"Potosi"

# Sort ascending
daily_cases<-daily_cases[order(as.Date(daily_cases$Fecha)),]

# Transform to long format
data_long <- gather(daily_cases, region,cases, "La Paz":Pando)

# Rename colums for Epinow
colnames(data_long)[1]<-"date"
colnames(data_long)[2]<-"country"
colnames(data_long)[3]<-"confirmed"

# Re order columns: country, date, confirmed
data_long <- data_long[,c(2,1,3)]

# Save data vintage
write.csv(data_long, file=paste0("rawdata/BO-", daily_cases$Fecha[1] ,".csv"),row.names=FALSE)
