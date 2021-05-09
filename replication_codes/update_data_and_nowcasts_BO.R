# =============================================================================================
#
# COVID-19 case count forecasts using EpiEstim and EpiNow from: 
# Abbott, S, J Hellewell, RN Thompson, K Sherratt, HP Gibbs, NI Bosse, JD Munday, S Meakin, 
# EL Doughty, JY Chun, YWD Chan, F Finger, P Campbell, A Endo, CAB Pearson, A Gimma, T Russell,
# S Flasche, AJ Kucharski, RM Eggo, and S Funk. 2020. 
# “Estimating the time-varying reproduction number of SARS-CoV-2 using national and subnational 
# case counts [version 1; peer review: awaiting peer review].” Wellcome Open Research, 5(112).
#
# References: "Monitero en Tiempor Real de COVID-19 en Bolivia" Cardona, Cuba-Borda y Gonzales (2020)
#
# Written by: Pablo Cuba-Borda. Washington, D.C. 
# First version: Agosto 10, 2020. 
# This version: Mayo 7, 2021.
# =============================================================================================

# Packages -----------------------------------------------------------------
require(future, quietly = TRUE)
require(forecastHybrid, quietly = TRUE)
require(EpiNow, quietly = TRUE)
require(forecastHybrid, quietly = TRUE)
library(tidyverse)
library(zoo)
library(ggthemes)

# Load data
# ---------------------------------------------------------------
source("pull_data_covid19BO.R")

# Define model
# ---------------------------------------------------------------
ctry <- "BO"
vintage <- last_point$Fecha

# Load data
#---------------------------------------------------------------
cases_bo_raw <- read.csv(file=paste0("rawdata/", ctry, "-", vintage, ".csv"))

# Transform data format
cases_bo_raw$date <-as.Date(cases_bo_raw[["date"]], "%Y-%m-%d")

#----------------------------------------------------
# Create daily cases
#---------------------------------------------------------------
cases_bo_raw <- cases_bo_raw %>% 
  group_by(country) %>% 
  mutate(newcases = confirmed - lag(confirmed, default = 0))

#----------------------------------------------------
# Data frame for use with EpiNow
#---------------------------------------------------------------
cases_bo <- data.frame("date" = cases_bo_raw$date, 
                       "region" = cases_bo_raw$country, 
                       "cases" = cases_bo_raw$newcases) 

cases_bo <- data.table::setDT(cases_bo)[!is.na(region)][, 
                                                  `:=`(local = cases, imported = 0)][, cases := NULL]

cases_bo <- data.table::melt(cases_bo, measure.vars = c("local", "imported"),
                          variable.name = "import_status",
                          value.name = "confirm")

#----------------------------------------------------
# Get linelist for delay distributions
#---------------------------------------------------------------
linelist <- 
  data.table::fread("https://raw.githubusercontent.com/epiforecasts/NCoVUtils/master/data-raw/linelist.csv")


delays <- linelist[!is.na(date_onset_symptoms)][, 
                   .(report_delay = as.numeric(lubridate::dmy(date_confirmation) - 
                                                 as.Date(lubridate::dmy(date_onset_symptoms))))]

delays <- delays$report_delay

#----------------------------------------------------
# Set up cores 
#---------------------------------------------------------------
if (!interactive()){
  options(future.fork.enable = TRUE)
}

future::plan("multiprocess", gc = TRUE, earlySignal = TRUE)

#----------------------------------------------------
# Fit the reporting delay
#---------------------------------------------------------------

delay_defs <- EpiNow::get_dist_def(delays,
                                    bootstraps = 100, 
                                    samples = 1000)

#----------------------------------------------------
# Fit the incubation period 
#---------------------------------------------------------------

## Mean delay
exp(EpiNow::covid_incubation_period[1, ]$mean)

## Get incubation defs
incubation_defs <- EpiNow::lognorm_dist_def(mean = EpiNow::covid_incubation_period[1, ]$mean,
                                            mean_sd = EpiNow::covid_incubation_period[1, ]$mean_sd,
                                            sd = EpiNow::covid_incubation_period[1, ]$sd,
                                            sd_sd = EpiNow::covid_incubation_period[1, ]$sd_sd,
                                            max_value = 30, samples = 1000)

#----------------------------------------------------
# Run regions nested 
#------------------------------------------------------

cores_per_region <- 1
future::plan(list(tweak("multiprocess", 
                        workers = floor(future::availableCores() / cores_per_region)),
                  tweak("multiprocess", workers = cores_per_region)),
                  gc = TRUE, earlySignal = TRUE)

#----------------------------------------------------
# Run pipeline 
#----------------------------------------------------
EpiNow::regional_rt_pipeline(
  cases = cases_bo,
  delay_defs = delay_defs,
  incubation_defs = incubation_defs,
  target_folder = "national",
  case_limit = 10,
  horizon = 30,
  nowcast_lag = 10,
  approx_delay = TRUE,
  report_forecast = TRUE, 
  forecast_model = function(y, ...){EpiSoon::forecastHybrid_model(
    y = y[max(1, length(y) - 21):length(y)],
    model_params = list(models = "aefz", weights = "equal"),
    forecast_params = list(PI.combination = "mean"), ...)},
    min_forecast_cases = 50
)

future::plan("sequential")


# =============================================================================================
# PLOT FIGURES
# =============================================================================================

# List of department to plot
clist <- c("Santa Cruz","La Paz", "Cochabamba", "Oruro", "Potosi", "Chuquisaca", "Tarija", "Beni", "Pando")

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
  
  # Plotting options
  ylab <- c(5, 50, 500,5000)
  pop = 1
  
  peakwave <-max(cases_bo$ma7[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-05-31"])
  
  
  # Get peak value of MA7
  peakvalue <- max(cases_bo$ma7[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-03-1"])
  peakdate_loc <- which.max(cases_bo$ma7[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-03-1"])
  peakdate <- cases_bo$date[cases_bo$date>"2020-12-01" & cases_bo$date<"2021-03-1"]
  
  
  # Start plot
  p1 <-ggplot() +
    geom_bar(data=cases_bo, aes(x=date, y=cases), stat="identity", fill="steelblue3",alpha=0.45)+
    geom_ribbon(aes(x=df$date, ymax = df$top/pop, ymin = df$bottom/pop), alpha = 0.3,fill = "darkseagreen3", color = "transparent")+
    geom_ribbon(aes(x=df$date, ymax = df$upper/pop, ymin = df$lower/pop), alpha = 0.7,fill = "darkseagreen3", color = "transparent")+
    geom_line(data=df, aes(x=date, y=median/pop), color = "aquamarine4", lwd = 1) +
    geom_line(data=df, aes(x=date, y=top, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
    geom_line(data=df, aes(x=date, y=bottom, linetype='dashed'), color = "aquamarine4", lwd = 0.5,linetype="dashed",alpha=0.7) +
    geom_vline(xintercept = as.Date(vintage), linetype="solid",lwd=0.5,color = "gray", size=0.7)+
    geom_line(data=cases_bo, aes(x=date, y=ma7), color = "red3",linetype="solid", lwd = 1) +
    annotate("text", x = as.Date(peakdate[peakdate_loc])+3, y = peakvalue*1.05, label = "promedio móvil 7-días",size = 2.5,  color="red3")+
    annotate("text", x = as.Date(peakdate[peakdate_loc])+3, y = peakwave*0.2, label = "Casos diarios",size = 2.5,  color="blue3")+
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
    #coord_cartesian(ylim = c(0, 500))
    coord_cartesian(ylim = c(0,min(1500, max(200,max(max(df$top[df$date<as.Date(vintage)+21]),peakwave)))))
  p1
  
  print(p1)
  
  # Save for website
  ggsave(filename = paste0("casesf/", vintage, "/", gsub("\\s+","",filename), "casefv4.png"), plot = p1, width = 12, height =8, dpi = 300, units = "cm")
  
}


