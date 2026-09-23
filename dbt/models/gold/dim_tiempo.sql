
with ts as (
 select event_ts_local ts from {{ ref('silver_tm_validaciones') }} where es_valido
 union all select event_ts_local from {{ ref('silver_transurbano') }} where es_valido_calidad
 union all select salida_ts_local from {{ ref('silver_metroriel') }} where es_valido
 union all select event_ts_local from {{ ref('silver_aerometro') }} where es_valido
), d as (
 select distinct date_trunc('hour',ts) ts_hora from ts where ts is not null
)
select
 row_number() over(order by ts_hora) tiempo_sk,
 ts_hora,
 cast(ts_hora as date) fecha,
 extract(hour from ts_hora)::integer hora,
 extract(isodow from ts_hora)::integer dia_semana,
 extract(isodow from ts_hora) between 1 and 5 es_dia_habil,
 (extract(hour from ts_hora) between 6 and 8 or extract(hour from ts_hora) between 16 and 19) es_hora_pico
from d
