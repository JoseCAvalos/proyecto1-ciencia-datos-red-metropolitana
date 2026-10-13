# Resultados medidos - Fase 2

## Validación dbt

- Modelos seleccionados (`silver gold phase2`): **19/19 PASS**
- Tests seleccionados: **20/20 PASS**, incluido `assert_zonas_normalizadas`.
- Tiempo de construcción de los 19 modelos: **3.19 s**
- Tiempo de los 20 tests: **0.31 s**
- Advertencias y errores: **0**

Fuente: salida de la ejecución local aportada por el responsable del proyecto después de actualizar a `a344a92` y reconstruir Silver, Gold y Fase 2. Entorno reportado: dbt 1.12.5, adaptador DuckDB 1.11.0, target `dev`, 4 threads. Las exportaciones y métricas se generaron después de la reconstrucción. Esta ejecución valida las condiciones de la prueba de normalización sobre los datos disponibles; no representa una comprobación de todas las posibles variantes geográficas.

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
| Mixco | 132,768 |
| Zona 7 | 117,431 |
| Zona 13 | 94,131 |
| Villa Nueva | 93,005 |
| Zona 18 | 91,842 |

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

## Rendimiento y almacenamiento

Los tiempos de consulta y tamaños de artefactos se generan con:

```bash
python scripts/10_metricas_fase2.py
```

Salidas esperadas:

- `data/outputs/fase2/metricas_fase2.csv`
- `data/outputs/fase2/almacenamiento_fase2.csv`

Mediciones locales reportadas para esta ejecución:

| Consulta | Tiempo (ms) |
|---|---:|
| demanda_total_red | 0.591 |
| usuarios_multimodales | 0.328 |
| usuarios_con_modo_registrado | 0.103 |
| zonas_sin_servicio | 0.248 |
| zonas_con_servicio | 0.135 |

Son tiempos de una ejecución por consulta, sin repeticiones ni control de caché; no constituyen un benchmark general ni permiten concluir rendimiento en otras máquinas.

| Artefacto | Bytes | MiB |
|---|---:|---:|
| red_metropolitana.duckdb | 314,585,088 | 300.012 |
| Directorio fase2 | 185,567,299 | 176.971 |
| features_usuario.csv | 8,687,568 | 8.285 |
| mart_cobertura_zona.csv | 684 | 0.001 |
| mart_demanda_dashboard.csv | 175,712,956 | 167.573 |
| mart_metroriel_zonas.csv | 226 | <0.001 |
| mart_transbordo_usuario.csv | 1,165,664 | 1.112 |
| metricas_fase2.csv | 201 | <0.001 |

Fuente: contenido de `almacenamiento_fase2.csv` aportado por el responsable. Aunque la columna se llama `mb`, el script divide entre 1,048,576, por lo que la unidad es MiB. Los CSV individuales forman parte del directorio: sus tamaños no deben sumarse nuevamente al total del directorio. La medición del directorio se toma durante la escritura del informe de almacenamiento, por lo que no incluye necesariamente el tamaño final de ese informe. Los bytes representan tamaños de archivo, no espacio físico asignado en disco; no se midió Bronze.

## Conclusión técnica

Las zonas objetivo de MetroRiel coinciden con las cinco zonas de mayor demanda observada en el dataset preparado para Tableau. La red cubre 15 de 16 zonas residenciales analizadas, y 16,849 usuarios muestran uso multimodal observable.
