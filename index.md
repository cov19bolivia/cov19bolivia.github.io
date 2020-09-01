## Monitoreo COVID-19 Bolivia

Esta página web provee actualizaciones de los resultados del documento de trabajo: __Cardona, Cuba-Borda y Gonzales (2020)__, ["Monitoreo en Tiempo Real del COVID-19 en Bolivia"](doc/COV19Bolivia-Current.pdf) que utiliza tres herramientas de monitoreo en tiempo real de la  pandemia de COVID-19 con datos  públicos  disponibles  en  Bolivia.

Los resultados se actualizan semanalmente los días sábados con la información disponible hasta el dia anterior.

**Última Actualización: 27-08-2020**

**Próxima Actualización: 08-09-2020**

## Metodología e Interpretación de los resultados

El cálculo de casos diarios y casos acumulados se basan en la estimación y pronóstico del número de reproducción efectivo __Rt__. Los resultados corresponden a las infecciones estimadas por día de infección. Debido al período de incubación y retrasos en el procesamiento de resultados de laboratorio, nuestras estimaciones se adelantan a los casos por fecha de registro oficial. El modelo de pronóstico esta basado en el programa __EpiNow__: Abbott S, Hellewell J, Thompson RN et al. Estimating the time-varying reproduction number of SARS-CoV-2 using national and subnational case counts. Wellcome Open Res 2020, 5:112 [https://doi.org/10.12688/wellcomeopenres.16006.1](https://doi.org/10.12688/wellcomeopenres.16006.1).

Para mayores detalles ver nuestro [documento de trabajo](doc/COV19Bolivia-Current.pdf)

## Pronósticos de Casos Diarios (al 20-08-2020)

En los siguientes gráficos, la linea de color verde representa la mediana de la proyección de nuevos casos diarios por fecha de infección. Las regiones con sombras claras representan el intervalo de credibilidad del 90%. Las regiones con sombrasoscuras corresponden al intervalo de credibilidad del 50%. La linea de color negro corresponde al valor estimado de infecciones por fecha de infección. Las barras azules representan el número de casos positivospor fecha oficial de confirmación. La linea vertical punteada corresponde al **27/08/2020**, la última observación de la muestra. El eje vertical se ajusta a cada departamento.

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
Beni | 7,549 | 6,755 | 8,453
Chuquisaca | 5,704 | 5,260 | 6,198
Cochabamba | 12,668 | 12,048 | 13,475
La Paz | 33,385 | 31,923 | 34,973
Oruro | 5,715 | 4,961 | 6,601
Potosi | 6,041 | 5,514 | 6,725
Santa Cruz | 40,629 | 39,533 | 42,044
Tarija | 8,795 | 7,969 | 9,666
Pando | 2,566 | 2,346 | 2,845
**Bolivia: Total Casos Confirmados** | 123,052 | 116,309 | 130,980
**Bolivia: Total Infecciones (estimado)** | 738,312 | 697,854 | 785,880

El ajuste de casos confirmados para obtener el total de infecciones, asume que existen por lo menos 6 casos no diagnosticados por cada caso confirmado. Este supuesto es solo referencial y está basado en la estimación de seroprevalencia del estudio de __Havers, et.al. “Seroprevalence  of  Antibodies  to  SARS-CoV-2 in 10 Sites  in  the  United  States, March23-May12,2020.” JAMA Internal Medicine__.

## Evolución de los Pronósticos

A continuación mostramos la evolución del pronóstico de casos acumulados por departamento para diferentes momentos de estimación del modelo. Todos los pronósticos se refieren al total de infecciones esperadas hasta el **01-09-2020**

**Departamento**| **Agosto-6** | **Agosto-13**| **Agosto-20**| **Agosto-27**
------------|---------|----------|---------|---------
Beni | 11575 | 6525 | 6787 | 7549
Chuquisaca | 10077 | 14868 | 9064 | 5704
Cochabamba | 21665 | 11001 | 12188 | 12668
La Paz | 47827 | 45873 | 34879 | 33385
Oruro | 14337 | 4109 | 5322 | 5715
Potosi | 4635 | 32358 | 21071 | 6041
Santa Cruz | 48607 | 39471 | 39193 | 40629
Tarija | 8868 | 7301 | 12675 | 8795
Pando |  | 6366 | 3531 | 2566
**Bolivia** | 167591 | 167872 | 144710 | 123052

(*) No contamos con pronósticos para Pando antes del 13 de Agosto debido a que el número de casos acumulados durante la semana previa a cada actualización fue menor a 200. 
