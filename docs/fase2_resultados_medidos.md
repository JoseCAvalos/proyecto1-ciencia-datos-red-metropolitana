# Resultados medidos - Fase 2

## Validación dbt

- Modelos Fase 2: **5/5 PASS**
- Tests Fase 2: **11/11 PASS**
- Tiempo de construcción de modelos: **1.16 s**
- Tiempo de tests: **0.16 s**

## Volúmenes exportados

| Dataset | Filas |
|---|---:|
| mart_demanda_dashboard | 1,647,569 |
| mart_cobertura_zona | 16 |
| mart_transbordo_usuario | 64,224 |
| mart_metroriel_zonas | 5 |
| features_usuario | 64,224 |

## Indicadores principales

| Métrica | Valor |
|---|---:|
| Demanda total | 1,647,569 |
| Usuarios con modo registrado | 64,224 |
| Usuarios multimodales | 16,849 |
| Porcentaje multimodal | 26.23% |
| Zonas con servicio | 15 |
| Zonas sin servicio | 1 |

## Demanda por modo

| Modo | Demanda |
|---|---:|
| Transurbano | 786,398 |
| Transmetro | 362,106 |
| MetroRiel | 295,511 |
| Aerómetro | 203,554 |

## Top zonas por demanda

| Zona | Demanda |
|---|---:|
| Zona 17 | 148,554 |
| Zona 12 | 147,903 |
| Zona 8 | 147,081 |
| Zona 6 | 138,899 |
| Zona 1 | 137,170 |
| Zona 7 | 117,431 |
| Zona 13 | 94,131 |
| Zona 18 | 91,842 |
| Zona 11 | 85,943 |
| Mixco | 82,170 |

## MetroRiel

| Zona | Demanda | Usuarios distintos | Estaciones | Atendida |
|---|---:|---:|---:|---|
| Zona 17 | 148,554 | 43,445 | 4 | Sí |
| Zona 12 | 147,903 | 42,304 | 4 | Sí |
| Zona 8 | 147,081 | 34,996 | 5 | Sí |
| Zona 6 | 138,899 | 32,556 | 5 | Sí |
| Zona 1 | 137,170 | 40,911 | 4 | Sí |

## Demanda por hora

| Hora | Demanda |
|---:|---:|
| 07:00 | 197,491 |
| 17:00 | 167,251 |
| 18:00 | 139,136 |
| 06:00 | 132,023 |
| 08:00 | 99,271 |

## Cobertura faltante

La única zona residencial sin servicio de ningún modo es **Santa Catarina Pinula**, con **1,031 usuarios residentes** observados.

## Conclusión técnica

Las zonas objetivo de MetroRiel coinciden con las cinco zonas de mayor demanda observada en el dataset preparado para Tableau. La red cubre 15 de 16 zonas residenciales analizadas, y 16,849 usuarios muestran uso multimodal observable.
