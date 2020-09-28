# =============================================================================================
#
# Estimación de pronosticos de casos diarios por dia de infeccion usando la metodologia de 
# Abbott, S, J Hellewell, RN Thompson, K Sherratt, HP Gibbs, NI Bosse, JD Munday, S Meakin, 
# EL Doughty, JY Chun, YWD Chan, F Finger, P Campbell, A Endo, CAB Pearson, A Gimma, T Russell,
# S Flasche, AJ Kucharski, RM Eggo, and S Funk. 2020. 
# “Estimating the time-varying reproduction number of SARS-CoV-2 using national and subnational 
# case counts [version 1; peer review: awaiting peer review].” Wellcome Open Research, 5(112).
#
# La misma metodologia es implementada en el documento: "Monitero en Tiempor Real de COVID-19 en Bolivia"
# de Cardona, Cuba-Borda y Gonzales (2020)
#
# Codigo escrito por: Pablo Cuba-Borda. Washington, D.C. 
# Primera version: Agosto 10, 2020. 
# Esta version: Septiembre 27, 2020.
# =============================================================================================

# Packages -----------------------------------------------------------------
require(future, quietly = TRUE)
require(forecastHybrid, quietly = TRUE)
require(EpiNow, quietly = TRUE)
require(forecastHybrid, quietly = TRUE)
library(tidyverse)
library(zoo)

# Define model
# ---------------------------------------------------------------
ctry <- "BO"
vintage <- "2020-09-26"

# Load data
#---------------------------------------------------------------
cases_bo_raw <- read.csv(file=paste0("raw_data/", ctry, "-", vintage, ".csv"))

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
