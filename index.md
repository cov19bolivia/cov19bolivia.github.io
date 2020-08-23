## Monitoreo COVID-19 Bolivia

Esta página web provee actualizaciones de los resultados del documento de trabajo: __Cardona, Cuba-Borda y Gonzales (2020)__, ["Monitoreo en Tiempo Real del COVID-19 en Bolivia"](doc/COV19Bolivia-Current.pdf) que utiliza tres herramientas de monitoreo en tiempo real de la  pandemia de COVID-19 con datos  públicos  disponibles  en  Bolivia.

Los resultados se actualizan semanalmente los días sábados con la información disponible hasta el dia anterior.

**Última Actualización: 21-08-2020**

**Próxima Actualización: 28-08-2020**

## Metodología e Interpretación de los resultados

El cálculo de casos diarios y casos acumulados se basan en la estimación y pronóstico del número de reproducción efectivo __Rt__. Los resultados corresponden a las infecciones estimadas por día de infección. Debido al período de incubación y retrasos en el procesamiento de resultados de laboratorio, nuestras estimaciones se adelantan a los casos por fecha de registro oficial. El modelo de pronóstico esta basado en el programa __EpiNow__: Abbott S, Hellewell J, Thompson RN et al. Estimating the time-varying reproduction number of SARS-CoV-2 using national and subnational case counts. Wellcome Open Res 2020, 5:112 [https://doi.org/10.12688/wellcomeopenres.16006.1](https://doi.org/10.12688/wellcomeopenres.16006.1).

Para mayores detalles ver nuestro [documento de trabajo](doc/COV19Bolivia-Current.pdf)

## Pronósticos de Casos Diarios (al 20-08-2020)

En los siguientes gráficos, la linea de color verde representa la mediana de la proyección de nuevos casos diarios por fecha de infección. Las regiones con sombras claras representan el intervalo de credibilidad del 90%. Las regiones con sombrasoscuras corresponden al intervalo de credibilidad del 50%. La linea de color negro corresponde al valor estimado de infecciones por fecha de infección. Las barras azules representan el número de casos positivospor fecha oficial de confirmación. La linea vertical punteada corresponde al **20/08/2020**, la última observación de la muestra. El eje vertical se ajusta a cada departamento.

<img src="casesf/Benicasef.png" width="100%"> 
<img src="casesf/Chuquisacacasef.png" width="100%">
<img src="casesf/Cochabambacasef.png" width="100%">
<img src="casesf/LaPazcasef.png" width="100%">
<img src="casesf/Orurocasef.png" width="100%">
<img src="casesf/Potosicasef.png" width="100%">
<img src="casesf/SantaCruzcasef.png" width="100%">
<img src="casesf/Tarijacasef.png" width="100%">
<img src="casesf/Pandocasef.png" width="100%">

### Pronóstico de Casos, Totales Acumulados hasta 01-09-2020

Los resultados corresponden al total de casos según la fecha de infección y proveen información adelantada con respecto a los casos por fecha de diagnóstico.

**Departamento**| **Proyección Central** | **Banda Inferior**| **Banda Superior**
------------|---------|----------|---------
Beni | 6.787 | 6.195 | 7.784
Chuquisaca | 9.064 | 6.179 | 12.203
Cochabamba | 12.188 | 11.507 | 12.952
La Paz | 34.879 | 32.234 | 37.561
Oruro | 5.322 | 4.508 | 11.308
Potosi | 21.071 | 7.948 | 36.387
Santa Cruz | 39.193 | 38.283 | 40.095
Tarija | 12.675 | 8.809 | 17.163
Pando | 3.531 | 2.296 | 5.238
**Bolivia: Total Casos Confirmados** | 144.710 | 117.959 | 180.691
**Bolivia: Total Infecciones (estimado)** | 868.260 | 707.754 | 1.084.146

El ajuste de casos confirmados para obtener el total de infecciones, asume que existen por lo menos 6 casos no diagnosticados por cada caso confirmado. Este supuesto es solo referencial y está basado en la estimación de seroprevalencia del estudio de __Havers, et.al. “Seroprevalence  of  Antibodies  to  SARS-CoV-2 in 10 Sites  in  the  United  States, March23-May12,2020.” JAMA Internal Medicine__.

## Evolución de los Pronósticos

A continuación mostramos la evolución del pronóstico de casos acumulados por departamento para diferentes momentos de estimación del modelo. Todos los pronósticos se refieren al total de infecciones esperadas hasta el **01-09-2020**
**Departmento** | **Julio-26** | **Agosto-6** | **Agosto-13** | **Agosto-20**
----------------|--------------|--------------|---------------|---------------     
Beni | 6.389 | 11.575 | 6.525 | 6.787
Chuquisaca | 3.130 | 10.077 | 14.868 | 9.064
Cochabamba | 15.970 | 21.665 | 11.001 | 12.188
La Paz | 116.669 | 47.827 | 45.873 | 34.879
Oruro | 7.062 | 14.337 | 4.109 | 5.322
Potosi | 5.755 | 4.635 | 32.358 | 21.071
Santa Cruz | 37.095 | 48.607 | 39.471 | 39.193
Tarija | 5732 | 8.868 | 7.301 | 12.675
Pando |  |  | 6.366 | 3.531
**Bolivia** | 197.802 | 167.591 | 167.872 | 144.710

(*) No contamos con pronósticos para Pando antes del 13 de Agosto debido a que el número de casos acumulados durante la semana previa a cada actualización fue menor a 200. 
