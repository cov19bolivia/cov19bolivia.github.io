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

    x <- getURL("https://raw.githubusercontent.com/mauforonda/covid19-bolivia-udape/master/confirmados_diarios.csv")

    daily_cases <- read.csv(text = x)

    # Change to date format
    daily_cases$X <- as.Date(daily_cases[["X"]], "%Y-%m-%d")

    # =============================================================================================
    # USER OPTIONS
    # =============================================================================================


    # List of department to plot
    clist <- c("Santa Cruz","La Paz", "Cochabamba", "Oruro", "Potosi", "Chuquisaca", "Tarija", "Beni", "Pando")

      # =============================================================================================
    # HOUSE KEEPING
    # =============================================================================================

    # Create subdirectories for vintage
    dir.create(file.path("casesf/"))

    #================================
    # Load Vintage Estimation Data
    #================================
    cases_bo_raw <- read.csv(file=paste0("data/latest.csv"))
    cases_bo_raw$date <-as.Date(cases_bo_raw[["date"]], "%Y-%m-%d")
    vintage <- tail(cases_bo_raw$date,n=1)


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
    # Re-label column names
    colnames(daily_cases)[1]<-"Fecha"
    colnames(daily_cases)[3]<-"La Paz"
    colnames(daily_cases)[8]<-"Santa Cruz"
    colnames(daily_cases)[6]<-"Potosi"

    # Sort ascending
    daily_cases<-daily_cases[order(as.Date(daily_cases$Fecha)),]

    # Add most recent observation
    last_point <-tail(daily_cases, n=1)

    most_recent<- last_point
    most_recent$Fecha=as.Date(c("2021-1-1"),"%Y-%m-%d")
    most_recent$`La Paz`=396
    most_recent$Cochabamba=48
    most_recent$`Santa Cruz`=183
    most_recent$Oruro=60
    most_recent$Potosi=12
    most_recent$Tarija=39
    most_recent$Chuquisaca=73
    most_recent$Beni=16
    most_recent$Pando=34
    daily_cases<-rbind(daily_cases,most_recent)

    last_point <-tail(daily_cases, n=1)

    most_recent<- last_point
    most_recent$Fecha=as.Date(c("2021-1-2"),"%Y-%m-%d")
    most_recent$`La Paz`=386
    most_recent$Cochabamba=92
    most_recent$`Santa Cruz`=426
    most_recent$Oruro=11
    most_recent$Potosi=1
    most_recent$Tarija=63
    most_recent$Chuquisaca=74
    most_recent$Beni=0
    most_recent$Pando=17
    daily_cases<-rbind(daily_cases,most_recent)


    # Transform to long format
    data_long <- gather(daily_cases, region,cases, "Chuquisaca":Pando)

    data_long <- data_long %>%
      group_by(region) %>%
      mutate(newcases = cases)

    # data_long <- data_long %>%
    #   group_by(region) %>%
    #   mutate(newcases = cases - lag(cases, default = 0))

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
    df <- readRDS(paste0("results/", filename, "/latest/case_forecast.rds"))

    # Offset 10 days to get average delay from symptom onset to reporting
    df$date <- df$date + 10

    # Load nowcasts
    df2 <- readRDS(paste0("results/", filename, "/latest/summarised_nowcast.rds"))
    df2$date <- df2$date + 10

    # Select region
    cases_bo <- cases_bo_all[cases_bo_all$region==c(filename),]


    # Out of sample observations
    outofsample <- outofsample_all[outofsample_all$region==c(filename), ]

    # Plotting options
    ylab <- c(5, 50, 500,5000)
    pop = 1

    # Start plot
    p1 <-ggplot() +
      geom_bar(data=cases_bo, aes(x=date, y=cases), stat="identity", fill="steelblue3",alpha=0.45)+
      geom_line(data=df2[df2$type=="nowcast",], aes(x=date, y=top), linetype='dashed',color='black', lwd = 0.5) +
      geom_line(data=df2[df2$type=="nowcast",], aes(x=date, y=bottom), linetype='dashed', color='black', lwd = 0.5) +
      geom_ribbon(aes(x=df$date, ymax = df$top/pop, ymin = df$bottom/pop), alpha = 0.3,
                  fill = "darkseagreen3", color = "transparent")+
      geom_ribbon(aes(x=df$date, ymax = df$upper/pop, ymin = df$lower/pop), alpha = 0.7,
                  fill = "darkseagreen3", color = "transparent")+
      geom_line(data=df, aes(x=date, y=median/pop), color = "aquamarine4", lwd = 1) +
      geom_line(data=df, aes(x=date, y=top, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
      geom_line(data=df, aes(x=date, y=bottom, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
      geom_line(data=cases_bo, aes(x=date, y=ma7), color = "red3",linetype="solid", lwd = 1) +
      geom_vline(xintercept = as.Date(vintage), linetype="solid",lwd=0.5,
                 color = "black", size=0.7)+
      geom_point() +
      annotate("point", x = outofsample$Fecha, y = outofsample$ma7, colour = "red3",size=0.5,shape=21,fill = NA)+
      annotate("text", x = as.Date(c(outofsample$Fecha[length(outofsample$Fecha)]+2)), y = outofsample$ma7[length(outofsample$Fecha)], label = format(outofsample$Fecha[length(outofsample$Fecha)], format="%m/%d"), size = 1.5)+
      scale_x_date(date_breaks = "week" ,date_labels = "%b %d",limits = as.Date(c("2020-11-01",format(as.Date(vintage)+8,"%Y-%m-%d"))))+
      labs(title = paste0(filename,': casos diarios de Covid-19'),
           subtitle = paste0("Pronósticos del ", format(as.Date(vintage)+1,"%d/%m"), ' al ', format(as.Date(vintage)+8,"%d/%m"), ' (promedios semanales)'),
           x = "",
           y= "",
           caption = "Linea y puntos rojos corresponden al promedio movil semanal de casos diarios. Barras transparentes son los datos observados y utilizados en la estimación del modelo.\nLas lineas punteadas corresponden al intervalo de credibilidad del 90%.\nEl area sombreada en verde oscuro es el intervalo de pronóstico con probabilidad de 50%.\nEl area sombreada en verde claro es el intervalo de pronóstico con probabilidad 90%." ) +
      theme_clean() +
      theme(plot.background = element_rect(color = "white")) +
      theme(axis.text.x = element_text(colour = "grey20", size = 8, angle = 0,
                                       hjust = 0.5, vjust = 0.5),
            axis.text.y = element_text(colour = "grey20", size = 8),
            text = element_text(size = 14))+
      theme(plot.title=element_text(size=10, color="black"))+
      theme(plot.subtitle=element_text(size=8, color="black"))+
      theme(plot.caption=element_text(size=3.5, color="black",hjust = 0))+
      #coord_cartesian(ylim = c(0, 500))
      coord_cartesian(ylim = c(0,min(800, max(100,max(max(cases_bo$ma7[cases_bo$date>"2020-11-01"]),max(df$top[df$date<"2021-01-05"]))))))
    p1





    #print(p1)

    # SAVE FIGURE TO FOLDER

    # Save in website folder
    # webdir = "/Users/pcb/Documents/GitPages/cov19bolivia.github.io/"
    ggsave(filename = paste0("casesf/", gsub("\\s+","",filename), "casefv4.png"), plot = p1, width = 11, height =6.5, dpi = 300, units = "cm")


    }
