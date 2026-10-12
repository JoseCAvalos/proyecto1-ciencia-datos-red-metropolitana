# Recomendación Fase 2

## Diagnóstico

La red integrada registró **1,647,569 eventos/viajes válidos**. El modo con mayor demanda fue **Transurbano**, con **786,398** registros, seguido por **Transmetro (362,106)**, **MetroRiel (295,511)** y **Aerómetro (203,554)**.

La demanda se concentra principalmente en **Zona 17 (148,554)**, **Zona 12 (147,903)**, **Zona 8 (147,081)**, **Zona 6 (138,899)** y **Zona 1 (137,170)**. De las 16 zonas residenciales analizadas, **15 tienen servicio y 1 queda sin servicio de ningún modo**.

De **64,224 usuarios observados**, **16,849 utilizaron más de un sistema**, equivalente a aproximadamente **26.23%**. Esto muestra que existe integración multimodal observable, aunque todavía la mayoría de los usuarios utiliza un solo modo.

## Caso MetroRiel

En las zonas objetivo del trazado propuesto —12, 8, 1, 6 y 17— se observa una concentración alta de demanda. Las cinco zonas aparecen entre las de mayor demanda de toda la red y todas están atendidas por estaciones de MetroRiel:

- Zona 17: 148,554 eventos y 4 estaciones.
- Zona 12: 147,903 eventos y 4 estaciones.
- Zona 8: 147,081 eventos y 5 estaciones.
- Zona 6: 138,899 eventos y 5 estaciones.
- Zona 1: 137,170 eventos y 4 estaciones.

Con estos datos, el trazado propuesto de MetroRiel **sí está alineado con zonas de alta demanda observada**. Sin embargo, esto no implica que la red completa resuelva todas las necesidades de movilidad, porque todavía existe al menos una zona residencial sin cobertura y la multimodalidad observada es limitada.

## Recomendación

Se recomienda priorizar dos acciones:

1. **Mantener como prioridad de integración las zonas 17, 12, 8, 6 y 1**, porque concentran la mayor demanda observada y coinciden con el corredor MetroRiel.
2. **Identificar y atender la zona sin cobertura** antes de ampliar capacidad en zonas que ya cuentan con varios modos.

La red integrada muestra una cobertura amplia, pero no total. El principal problema ya no parece ser únicamente la existencia de modos, sino **cerrar la brecha de cobertura restante y mejorar la integración entre sistemas**. El 26.23% de usuarios multimodales indica que existe uso combinado, pero todavía hay margen importante para mejorar conexiones y transbordos.

## Limitaciones

La identidad entre Transmetro, Transurbano y MetroRiel se aproxima mediante el componente numérico de sus llaves. Aerómetro permanece separado porque entrega un hash sin tabla de correspondencia. Por ello, el porcentaje de usuarios multimodales puede estar subestimado cuando Aerómetro participa.
