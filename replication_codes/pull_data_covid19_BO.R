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

# Read data

x <- getURL("https://raw.githubusercontent.com/mauforonda/covid19-bolivia-udape/master/confirmados_diarios.csv")
y <- read.csv(text = x)
colnames(y)[1]<-"Fecha"

# Date format
y$Fecha <- as.Date(y[["Fecha"]], "%Y-%m-%d")

# Load daily data depto
daily_cases <- y 

# Relabel column names
colnames(daily_cases)[3]<-"La Paz"
colnames(daily_cases)[8]<-"Santa Cruz"
colnames(daily_cases)[6]<-"Potosi"

daily_cases<-daily_cases[order(as.Date(daily_cases$Fecha)),]

# Get latest observation
last_point <-tail(daily_cases, n=1)

# Transform to long format
data_long <- gather(daily_cases, region,cases, Chuquisaca:Pando)

# Rename colums for Epinow
colnames(data_long)[1]<-"date"
colnames(data_long)[2]<-"country"
colnames(data_long)[3]<-"confirmed"

# Re order columns: country, date, confirmed
data_long <- data_long[,c(2,1,3)]

# Cumulative case counts by department
data_long <- data_long %>%
  group_by(country) %>%
  mutate(confirmed = cumsum(confirmed))

# Save data vintage
write.csv(data_long, file=paste0("rawdata/BO-", tail(daily_cases$Fecha,n=1) ,".csv"),row.names=FALSE)
