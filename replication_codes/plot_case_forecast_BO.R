# =============================================================================================
# Daily case forecasts based on Rt 
# =============================================================================================
#
# Graficos de pronosticos de casos diarios por dia de infeccion usando la metodologia de 
# Abbott, S, J Hellewell, RN Thompson, K Sherratt, HP Gibbs, NI Bosse, JD Munday, S Meakin, 
# EL Doughty, JY Chun, YWD Chan, F Finger, P Campbell, A Endo, CAB Pearson, A Gimma, T Russell,
# S Flasche, AJ Kucharski, RM Eggo, and S Funk. 2020. 
# “Estimating the time-varying reproduction number of SARS-CoV-2 using national and subnational 
# case counts [version 1; peer review: awaiting peer review].” Wellcome Open Research, 5(112).
#
# La misma metodologia es implementada en el documento: "Monitero en Tiempo Real de COVID-19 en Bolivia"
# de Cardona, Cuba-Borda y Gonzales (2020)
#
# Codigo escrito por: Pablo Cuba-Borda. Washington, D.C. 
# Esta version: Agosto-10-2020. 
# =============================================================================================
library(RCurl)
library(tidyverse)
library(zoo)
library(ggplot2)
library(reshape)
library(ggthemes)
#require(data.table, quietly = TRUE) 

# =============================================================================================
# USER OPTIONS
# =============================================================================================
ctry    <- 'BO'
vintage <- '2020-09-26'
vintage_old <-'2020-08-13'
vintage_str <- 'Septiembre-26'

# List of department to plot
clist <- c("Santa Cruz","La Paz", "Cochabamba", "Oruro", "Potosi", "Chuquisaca", "Tarija", "Beni", "Pando")
# =============================================================================================
# HOUSE KEEPING 
# =============================================================================================

# Create subdirectories for vintage
dir.create(file.path("casesf/", vintage))
dir.create(file.path("rnot/", vintage))

#================================
# Load Vintage Estimation Data
#================================
# cases_bo_raw <- data.table::fread(paste0("raw_data/", ctry, "-", vintage, ".csv"))
cases_bo_raw <- read.csv(file=paste0("raw_data/", ctry, "-", vintage, ".csv"))
cases_bo_raw$date <-as.Date(as.character(cases_bo_raw$date),"%m/%d") 
#cases_bo_raw$date <-as.Date(cases_bo_raw[["date"]], "%Y-%m-%d")

# Create daily cases
cases_bo_raw <- cases_bo_raw %>% 
  group_by(country) %>% 
  mutate(newcases = confirmed - lag(confirmed, default = 0))

# Adjust raw data frame for use with EpiNow results
cases_bo_all <- data.frame("date" = cases_bo_raw$date, 
                       "region" = cases_bo_raw$country, 
                       "cases" = cases_bo_raw$newcases) 

# Compute moving averages of daily cases (trailing)
cases_bo_all <- cases_bo_all %>% 
  group_by(region) %>% 
  mutate(ma7=rollapply(cases,7,mean,align='right',fill=NA))

#===========================================
# Load Most Recent from Manu Foronda Github
#===========================================
x <- getURL("https://raw.githubusercontent.com/mauforonda/covid19-bolivia/master/confirmados.csv")
daily_cases <- read.csv(text = x)

# Change to date format
daily_cases$Fecha <- as.Date(daily_cases[["Fecha"]], "%Y-%m-%d")

# Re-label column names 
colnames(daily_cases)[2]<-"La Paz"
colnames(daily_cases)[4]<-"Santa Cruz"
colnames(daily_cases)[6]<-"Potosi"

# Sort ascending
daily_cases<-daily_cases[order(as.Date(daily_cases$Fecha)),]

# Transform to long format
data_long <- gather(daily_cases, region,cases, "La Paz":Pando)

data_long <- data_long %>% 
  group_by(region) %>% 
  mutate(newcases = cases - lag(cases, default = 0))

# Compute moving averages of daily cases
data_long <- data_long %>% 
  group_by(region) %>% 
  mutate(ma7=rollapply(newcases,7,mean,align='right',fill=NA))

# Collect recent observation beyond estimation vintage
outofsample_all <- subset(data_long, Fecha > as.Date(vintage) )

# =============================================================================================
#  PLOT CASES FORECAST BY ESTIMATED REPORTING DATE
# =============================================================================================

# Loop over regions
for (i in clist){
  
  filename = i
  
# Load forecasts
df <- readRDS(paste0("national/", filename, "/", vintage, "/case_forecast.rds"))
dfold <- readRDS(paste0("national/", filename, "/", vintage_old, "/case_forecast.rds"))

# Load nowcasts
df2 <- readRDS(paste0("national/", filename, "/", vintage, "/summarised_nowcast.rds"))

# Offset 10 days to get average delay from symptom onset to reporting
df$date <- df$date + 10
df2$date <- df2$date + 10

# Select region
#cases_bo_raw <- cases_bo_raw[country %in% c(filename)]
cases_bo <- cases_bo_all[cases_bo_all$region==c(filename),]


# Out of sample observations
outofsample <- outofsample_all[outofsample_all$region==c(filename), ]

# Plotting options
ylab <- c(5, 50, 500,5000)
pop = 1

# Start plot
p1 <-ggplot() + 
  geom_bar(data=cases_bo, aes(x=date, y=cases), stat="identity", fill="steelblue3",alpha=0.15)+
  geom_line(data=df2[df2$type=="nowcast",], aes(x=date, y=median/pop), color='black', lwd = 1) + 
  geom_line(data=df2[df2$type=="nowcast",], aes(x=date, y=top), linetype='dashed',color='black', lwd = 0.5) + 
  geom_line(data=df2[df2$type=="nowcast",], aes(x=date, y=bottom), linetype='dashed', color='black', lwd = 0.5) + 
  geom_ribbon(aes(x=df$date, ymax = df$top/pop, ymin = df$bottom/pop), alpha = 0.3,
              fill = "darkseagreen3", color = "transparent")+
  geom_ribbon(aes(x=df$date, ymax = df$upper/pop, ymin = df$lower/pop), alpha = 0.7,
              fill = "darkseagreen3", color = "transparent")+  
  geom_line(data=df, aes(x=date, y=median/pop), color = "aquamarine4", lwd = 1) +
  geom_line(data=df, aes(x=date, y=top, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
  geom_line(data=df, aes(x=date, y=bottom, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
  # print old vintage:
  #geom_line(data=dfold, aes(x=date, y=median/pop), color = "red3", lwd = 0.8, linetype="dashed") +
  geom_line(data=cases_bo, aes(x=date, y=ma7), color = "red3",linetype="solid", lwd = 0.5) +
  geom_vline(xintercept = as.Date(vintage), linetype="solid",lwd=0.5, 
             color = "black", size=0.7)+
  geom_point() +
  annotate("point", x = outofsample$Fecha, y = outofsample$ma7, colour = "red3",size=0.5,shape=21,fill = NA)+
  annotate("text", x = as.Date(c(outofsample$Fecha[length(outofsample$Fecha)]+5)), y = outofsample$ma7[length(outofsample$Fecha)], label = format(outofsample$Fecha[1], format="%m/%d"), size = 1.5)+
  scale_x_date(date_breaks = "months" ,date_labels = "%b",limits = as.Date(c("2020-04-01","2020-10-10")))+
  labs(title = filename,
       subtitle = paste0("Casos confirmados por día", " (",vintage_str,")"),
       x = "",
       y= "", 
       caption = "Linea y puntos rojos corresponden al promedio movil semanal de casos diarios.\nBarras transparentes son los datos observados y utilizados en la estimación del modelo.\nLinea negra solida muestra la mediana de casos estimados por fecha de confirmación.\nLas lineas punteadas corresponden al intervalo de credibilidad del 90%.\nEl area sombreada en verde oscuro es el intervalo de pronóstico con probabilidad de 50%.\nEl area sombreada en verde claro es el intervalo de pronóstico con probabilidad 90%." ) +
  theme_clean() +
  theme(plot.background = element_rect(color = "white")) +  
  theme(axis.text.x = element_text(colour = "grey20", size = 12, angle = 0,
                                   hjust = 0.5, vjust = 0.5),
        axis.text.y = element_text(colour = "grey20", size = 10),
        text = element_text(size = 16))+
  theme(plot.subtitle=element_text(size=10, color="black"))+
  theme(plot.caption=element_text(size=4, color="black",hjust = 0))+
  coord_cartesian(ylim = c(0, min(750,max(max(cases_bo$cases[cases_bo$date>"2020-04-01"]),max(df$top[df$date<"2020-09-30"]))))) 
p1

print(p1)

# SAVE FIGURE TO FOLDER 
# Save for website
#ggsave(filename = paste0("casesf/", vintage, "/", gsub("\\s+","",filename), "casefv2.png"), plot = p1, width = 12, height =8, dpi = 300, units = "cm")

# Save for gif
#ggsave(filename = paste0("casesf/", vintage, "/", gsub("\\s+","",filename), "casefv2.png"), plot = p1, width = 10, height = 6, dpi = 300, units = "cm")


# Save for tweet
#ggsave(filename = paste0("casesf/", vintage, "/", gsub("\\s+","",filename), "casefv3.png"), plot = p1, width = 12, height =6, dpi = 300, units = "cm")

}


# 
# 
# # =============================================================================================z
# #  PLOT EFFECTIVE REPRODUCTION NUMBER AND STORE FIGURES
# # =============================================================================================z
# 
# # Loop over deparments
# for (i in clist){
# 
#   filename = i
# 
# 
# 
# # # BO: Reproduction number
#  df3 <- readRDS(paste0("national/", filename,"/", vintage,"/bigr_estimates.rds"))
# 
# # Offset by average delay
# # #df3$date <- df$date + 9
# 
# 
#  p2 <-ggplot() +
#    geom_line(data=df3[df3$type=="nowcast",], aes(x=date, y=median), color='black', lwd = 1) +
#    geom_ribbon(aes(x=df3$date, ymax = df3$top, ymin = df3$bottom), alpha = 0.4,
#                fill = "lightsteelblue3", color = "transparent")+
#    geom_ribbon(aes(x=df3$date, ymax = df3$upper, ymin = df3$lower/pop), alpha = 0.7,
#                fill = "lightsteelblue3", color = "transparent")+
#    #geom_line(data=df, aes(x=date, y=median), color = "aquamarine4", lwd = 1) +
#    #geom_xline(Lintercept = 1, linetype="dashed",
#    #           color = "black", size=0.7)+
#    geom_hline(yintercept=1, linetype="solid", color = "red3",size=0.4)+
#    scale_x_date(date_breaks = "months" ,date_labels = "%b",limits = as.Date(c("2020-03-5",vintage))) +
#    labs(title = filename,
#         subtitle = "Número de reproducción efectivo",
#         x = "",
#         y= "") +
#    #caption = "The shaded area represents the 50% credible interval. The dashed vertical line represent the forecast origin.") +
#    theme_clean() +
#    theme(plot.background = element_rect(color = "white")) +
#    theme(axis.text.x = element_text(colour = "grey20", size = 12, angle = 0,
#                                     hjust = 0.5, vjust = 0.5),
#          axis.text.y = element_text(colour = "grey20", size = 10),
#          text = element_text(size = 16))+
#    theme(plot.subtitle=element_text(size=10, color="black"))+
#    theme(plot.caption=element_text(size=5, color="black"))+
#    coord_cartesian(ylim = c(0, 4))+
#    scale_y_continuous(breaks = c(0,1,2,3,4))
# 
#  print(p2)
# 
# # SAVE FIGURE TO FOLDER
# ggsave(filename = paste0("rnot/", vintage, "/",gsub("\\s+","",filename), "r0.png"), plot = p2, width = 12, height = 8, dpi = 300, units = "cm")
# 
# }
