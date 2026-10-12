# Recomendación Fase 2

## Diagnóstico

La red integrada registró **1,647,569 eventos/viajes válidos**. El modo con mayor demanda fue **Transurbano**, con **786,398 registros (47.73%)**, seguido por **Transmetro con 362,106 (21.98%)**, **MetroRiel con 295,511 (17.94%)** y **Aerómetro con 203,554 (12.35%)**.

La demanda se concentra especialmente en **Zona 17 (148,554)**, **Zona 12 (147,903)**, **Zona 8 (147,081)**, **Zona 6 (138,899)** y **Zona 1 (137,170)**. En conjunto, estas cinco zonas representan **719,607 eventos**, aproximadamente **43.68%** de la demanda total observada.

Temporalmente, la mayor concentración aparece a las **07:00 con 197,491 eventos**, seguida por **17:00 con 167,251**, **18:00 con 139,136** y **06:00 con 132,023**. Esto confirma una concentración importante alrededor de los periodos definidos como hora pico.

De las **16 zonas residenciales analizadas, 15 tienen servicio y 1 queda sin servicio**. La zona sin cobertura es **Santa Catarina Pinula**, con **1,031 usuarios residentes** observados.

De **64,224 usuarios con actividad**, **16,849 utilizaron más de un sistema**, equivalente a aproximadamente **26.23%**. Existe por tanto integración multimodal observable, aunque cerca de tres cuartas partes de los usuarios se observan en un solo modo.

## Caso MetroRiel

Las zonas objetivo del trazado propuesto —12, 8, 1, 6 y 17— coinciden exactamente con las cinco zonas de mayor demanda observada en el dataset preparado para Tableau:

- **Zona 17:** 148,554 eventos, 43,445 usuarios distintos y 4 estaciones MetroRiel.
- **Zona 12:** 147,903 eventos, 42,304 usuarios distintos y 4 estaciones.
- **Zona 8:** 147,081 eventos, 34,996 usuarios distintos y 5 estaciones.
- **Zona 6:** 138,899 eventos, 32,556 usuarios distintos y 5 estaciones.
- **Zona 1:** 137,170 eventos, 40,911 usuarios distintos y 4 estaciones.

Con estos datos, el trazado propuesto de MetroRiel **sí está alineado con las zonas de mayor demanda observada**. Las cinco zonas que atraviesa concentran aproximadamente **43.68%** de todos los eventos válidos de la red.

## Recomendación

La red integrada presenta cobertura amplia, pero no completa. Se recomienda:

1. **Mantener como prioridad de integración el corredor MetroRiel por zonas 17, 12, 8, 6 y 1**, porque coincide con las zonas de mayor demanda observada.
2. **Priorizar una solución de cobertura o conexión alimentadora para Santa Catarina Pinula**, la única zona residencial del conjunto analizado sin servicio de ningún modo y con 1,031 usuarios residentes observados.
3. **Mejorar conexiones y facilidades de transbordo en las franjas de mayor demanda**, especialmente alrededor de 07:00 y 17:00–18:00, para favorecer el uso combinado de sistemas.

La prioridad no debería ser ampliar indiscriminadamente la infraestructura donde ya existen múltiples opciones, sino cerrar la brecha territorial restante y facilitar la integración de modos. El **26.23% de usuarios multimodales** evidencia uso combinado, pero también muestra margen para aumentar la integración operacional de la red.

## Limitaciones

La identidad entre Transmetro, Transurbano y MetroRiel se aproxima mediante el componente numérico de sus llaves. Aerómetro permanece separado porque entrega un hash sin tabla de correspondencia. Por ello, el porcentaje de usuarios multimodales puede estar subestimado cuando Aerómetro participa.
