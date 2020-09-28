# "Monitero en Tiempor Real de COVID-19 en Bolivia"

Los siguientes codigos reproducen la estimación de pronosticos de casos diarios por dia de infeccion "Monitero en Tiempor Real de COVID-19 en Bolivia" Cardona, Cuba-Borda y Gonzales (2020)

La metodologia esta basada en Abbott, S, J Hellewell, RN Thompson, K Sherratt, HP Gibbs, NI Bosse, JD Munday, S Meakin, EL Doughty, JY Chun, YWD Chan, F Finger, P Campbell, A Endo, CAB Pearson, A Gimma, T Russell, S Flasche, AJ Kucharski, RM Eggo, and S Funk. 2020.
“Estimating the time-varying reproduction number of SARS-CoV-2 using national and subnational
case counts [version 1; peer review: awaiting peer review].” Wellcome Open Research, 5(112).

### Como replicar los resultados
Los codigos para replicar las estimaciones se encuentran en el folder replication_codes

1) Obtener los datos ejecutando el codigo "pull_data_covid19BO.R", este codigo crea un archivo de csv en el folder rawdata en base a la información diaria disponible (ver seccion Datos para detalles)

2) Ejecutar el codigo "update_nowcasts_long_forecast_BO.R", este codigo crea un folder de nombre "national" con subfolders para cada departamento y vintage de estimacion.

3) Ejecutar el codigo "plot_case_forecast_BO.R" para generar los graficos. Este codigo guardara los graficos en un subfolder llamado "casesf/[vintage]".

### Software

* R version 3.6.3

* Es necesario tener devtools instalado

```
install.packages("devtools")
```


* El principal paquete de R es EpiNow __EpiNow__.

```
install.packages(EpiNow)
```

## Datos

* Los datos de casos diarios de Bolivia se obtienen del repositorio de COVID-19 de Mau Foronda
https://github.com/mauforonda/covid19-bolivia

## Autor

* **Pablo Cuba Borda** - *September 26, 2020*

## Nota
* Las opiniones acá presentadas son totalmente personales y no implican ni representan ninguna de las instituciones con las que estoy o estuve afiliado.
