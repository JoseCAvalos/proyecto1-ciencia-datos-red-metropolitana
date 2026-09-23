# Definiciones del modelo dimensional Gold

## fact_abordaje

**Grano:** una fila por abordaje o validación exitosa de Transmetro, Transurbano o Aerómetro para un usuario, punto y momento determinado.

Esta tabla representa eventos de abordaje individuales.

## fact_viaje_metroriel

**Grano:** una fila por viaje completo de MetroRiel con origen, destino y tiempos asociados.

MetroRiel se modela en una tabla de hechos separada porque su fuente representa un trayecto completo y no únicamente un abordaje.

## Dimensiones conformadas

El modelo Gold utiliza las siguientes dimensiones:

- dim_usuario
- dim_tiempo
- dim_modo
- dim_zona
- dim_ruta
- dim_estacion_parada

## Clasificación de medidas

| Medida | Clasificación | Justificación |
|---|---|---|
| conteo_abordaje | Aditiva | Puede sumarse a través de las dimensiones |
| conteo_viaje | Aditiva | Puede sumarse a través de las dimensiones |
| monto_q | Aditiva | Los cobros pueden acumularse |
| usuarios_distintos | No aditiva | COUNT DISTINCT no puede sumarse entre particiones |
| tarifa_promedio | No aditiva | Los promedios no son directamente sumables |

## Medidas semi-aditivas

No se implementó una medida semi-aditiva porque las fuentes entregadas no contienen saldos, inventarios ni snapshots temporales.

Agregar una medida de este tipo implicaría inventar información que no existe en los datos fuente.
