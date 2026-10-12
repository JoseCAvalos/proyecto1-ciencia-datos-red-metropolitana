# Recomendación Fase 2 - borrador

> Completar únicamente con cifras medidas por scripts/10_metricas_fase2.py y el tablero Tableau.

## Diagnóstico

La red integrada registró **[DEMANDA_TOTAL]** eventos/viajes válidos. El modo con mayor demanda fue **[MODO_TOP]** con **[DEMANDA_MODO_TOP]** registros.

La demanda se concentra principalmente en **[ZONA_1]**, **[ZONA_2]** y **[ZONA_3]**. **[ZONA_SIN_SERVICIO]** aparece sin cobertura de ningún modo.

De **[USUARIOS_TOTAL]** usuarios observados, **[USUARIOS_MULTIMODALES]** utilizaron más de un sistema (**[PORCENTAJE]%**).

## Caso MetroRiel

Para zonas 12, 8, 1, 6 y 17 se comparó demanda observada con estaciones MetroRiel. Las zonas con mayor demanda fueron **[ZONAS_TOP]**. El trazado **[SI/NO/PARCIALMENTE]** coincide con la necesidad observada porque **[JUSTIFICACION]**.

## Recomendación

Se recomienda **[ACCION_CONCRETA]** en **[ZONA/CORREDOR]**, sustentado por:
- demanda: **[VALOR]**;
- cobertura: **[VALOR]**;
- multimodalidad: **[VALOR]**;
- comparación MetroRiel: **[VALOR]**.

## Limitaciones

TM/TU/MR aproximan identidad por componente numérico. Aerómetro permanece separado por usar hash sin tabla de correspondencia; por ello la multimodalidad puede quedar subestimada.
