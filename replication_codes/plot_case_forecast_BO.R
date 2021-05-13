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
  # Primera version: Agosto 10, 2020
  # Ultima actuaizacion: Diciembre 25, 2020
  # =============================================================================================
  library(RCurl)
  library(tidyverse)
  library(zoo)
  library(ggplot2)
  library(reshape)
  library(ggthemes)
  
  # Get most recent data
  x <- getURL("https://raw.githubusercontent.com/mauforonda/covid19-bolivia-udape/master/confirmados_diarios.csv")
  daily_cases <- read.csv(text = x)
  
  # Change to date format
  daily_cases$X <- as.Date(daily_cases[["X"]], "%Y-%m-%d")

  # =============================================================================================
  # USER OPTIONS
  # =============================================================================================
  ctry    <- 'BO'
  vintage <- '2021-05-06'

  # List of department to plot
  clist <- c("Santa Cruz","La Paz", "Cochabamba", "Oruro", "Potosi", "Chuquisaca", "Tarija", "Beni", "Pando")
  # =============================================================================================
  # HOUSE KEEPING
  # =============================================================================================

  # Create subdirectories for vintage
  dir.create(file.path("casesf/", vintage))

  #================================
  # Load Vintage Estimation Data
  #================================
  cases_bo_raw <- read.csv(file=paste0("rawdata/", ctry, "-", vintage, ".csv"))
  cases_bo_raw$date <-as.Date(cases_bo_raw[["date"]], "%Y-%m-%d")

  # Compute daily cases
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
  # Re-label column names
  colnames(daily_cases)[1]<-"Fecha"
  colnames(daily_cases)[3]<-"La Paz"
  colnames(daily_cases)[8]<-"Santa Cruz"
  colnames(daily_cases)[6]<-"Potosi"

  # Sort ascending
  daily_cases<-daily_cases[order(as.Date(daily_cases$Fecha)),]
  
  # Transform to long format
  data_long <- gather(daily_cases, region,cases, "Chuquisaca":Pando)

  data_long <- data_long %>%
    group_by(region) %>%
    mutate(newcases = cases)

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
  
  # Offset 10 days to get average delay from symptom onset to reporting
  df$date <- df$date + 10
  
  # Load nowcasts
  df2 <- readRDS(paste0("national/", filename, "/", vintage, "/summarised_nowcast.rds"))
  df2$date <- df2$date + 10

  # Select region
    cases_bo <- cases_bo_all[cases_bo_all$region==c(filename),]

  # Out of sample observations
  outofsample <- outofsample_all[outofsample_all$region==c(filename), ]

  # Plotting options
  ylab <- c(5, 50, 500,5000)
  pop = 1

  peakwave <-max(cases_bo$ma7[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-05-31"])
  
  # Get peak value of MA7
  peakvalue <- max(cases_bo$ma7[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-05-10"])
  peakdate_loc <- which.max(cases_bo$ma7[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-05-10"])
  peakdate <- cases_bo$date[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-05-10"]
  
  
  # Start plot
  p1 <-ggplot() +
    geom_bar(data=cases_bo, aes(x=date, y=cases), stat="identity", fill="steelblue3",alpha=0.30)+
    geom_ribbon(aes(x=df$date, ymax = df$top/pop, ymin = df$bottom/pop), alpha = 0.3,
                fill = "darkseagreen3", color = "transparent")+
    geom_ribbon(aes(x=df$date, ymax = df$upper/pop, ymin = df$lower/pop), alpha = 0.7,
                fill = "darkseagreen3", color = "transparent")+
    geom_line(data=df, aes(x=date, y=median/pop), color = "aquamarine4", lwd = 1) +
    geom_line(data=df, aes(x=date, y=top, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
    geom_line(data=df, aes(x=date, y=bottom, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
    geom_line(data=cases_bo, aes(x=date, y=ma7), color = "red3",linetype="solid", lwd = 1) +
    geom_bar(data=outofsample, aes(x=Fecha, y=cases), stat="identity", fill="steelblue3",alpha=0.30) +    
    geom_vline(xintercept = as.Date(vintage)+1, linetype="solid",lwd=0.35,
                color = "gray", size=0.7)+
    geom_line(data=outofsample, aes(x=Fecha, y=ma7), color = "red3",linetype="solid", lwd = 0.4) +    
    geom_point() +
    annotate("point", x = outofsample$Fecha, y = outofsample$ma7, colour = "red3",size=0.5,shape=21,fill = NA)+
    annotate("text", x = as.Date(c(outofsample$Fecha[length(outofsample$Fecha)]+6)), y = outofsample$ma7[length(outofsample$Fecha)]*0.97, label = format(outofsample$Fecha[length(outofsample$Fecha)], format="%b/%d"), size = 1.75)+
    annotate("text", x = as.Date(peakdate[peakdate_loc])-2, y = peakvalue*1.01, label = "promedio móvil 7-días",size = 2.15,  color="red3",hjust = 1)+
    annotate("text", x = as.Date(peakdate[peakdate_loc])-2, y = peakwave*0.2, label = "Casos diarios",size = 2.15,  color="blue3",hjust = 1)+
    annotate("text", x = as.Date(vintage)+5, y = max(df$top[df$date<as.Date(vintage)+21]), label = "Pronósticos",size = 2.15,  color="black",hjust = 0)+
    scale_x_date(date_breaks = "3 weeks" ,date_labels = "%b %d",limits = as.Date(c("2020-12-01",format(as.Date(vintage)+21,"%Y-%m-%d"))))+
    labs(title = paste0(filename,': casos diarios de Covid-19'),
         subtitle = paste0("Pronósticos del ", format(as.Date(vintage)+1,"%d/%b"), ' al ', format(as.Date(vintage)+21,"%d/%b")),
         x = "",
         y= "",
         caption = "El área sombreada en verde oscuro es el intervalo de pronóstico con probabilidad de 50%.\nEl área sombreada en verde claro es el intervalo de pronóstico con probabilidad 90%." ) +
    theme_clean() +
    theme(plot.background = element_rect(color = "white")) +
    theme(axis.text.x = element_text(colour = "grey20", size = 8, angle = 0,
                                     hjust = 0.5, vjust = 0.5),
          axis.text.y = element_text(colour = "grey20", size = 8),
          text = element_text(size = 14))+
    theme(plot.title=element_text(size=10, color="black"))+
    theme(plot.subtitle=element_text(size=8, color="black"))+
    theme(plot.caption=element_text(size=6, color="black",hjust = 0))+
    coord_cartesian(ylim = c(0,min(1500, max(200,max(max(df$top[df$date<as.Date(vintage)+21]),peakwave)))))
    
  p1


  print(p1)

  # Save for website
  ggsave(filename = paste0("casesf/", vintage, "/", gsub("\\s+","",filename), "casefv4.png"), plot = p1, width = 14, height =8, dpi = 300, units = "cm")

  }

