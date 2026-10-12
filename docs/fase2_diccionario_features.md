# Diccionario de features - Fase 2

**Entidad:** usuario  
**Grano:** una fila por usuario.  
**Fuente:** exclusivamente Silver.  
**Fecha de corte:** timestamp máximo observado en los eventos válidos de Silver.

| Feature | Definición |
|---|---|
| usuario_pseudo | Identificador seudonimizado. |
| fecha_corte | Fecha/timestamp de referencia. |
| viajes_total | Total histórico de eventos válidos. |
| viajes_7d | Eventos en últimos 7 días. |
| viajes_30d | Eventos en últimos 30 días. |
| viajes_90d | Eventos en últimos 90 días. |
| modo_mas_usado | Modo con mayor frecuencia. |
| cantidad_modos_distintos | Número de modos usados. |
| dias_desde_ultimo_viaje | Recencia en días. |
| proporcion_hora_pico | Proporción de eventos en hora pico. |
| zona_origen_mas_frecuente | Zona más frecuente de origen/abordaje. |
| gasto_acumulado_q | Gasto acumulado en quetzales. |
| gasto_promedio_q | Gasto promedio por evento. |

## Uso potencial

Puede alimentar un modelo de propensión a abandono o disminución de uso del transporte integrado, porque resume recencia, frecuencia, diversidad modal, patrones horarios y gasto. La Agencia podría priorizar análisis de usuarios con menor recurrencia o detectar segmentos que dependen de un solo modo.

No se entrena ningún modelo en esta fase.
