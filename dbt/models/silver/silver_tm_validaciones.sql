
with src as (
 select *,
        row_number() over(partition by validacion_id order by validacion_id) rn
 from {{ ref('stg_tm_validaciones') }}
)
select
 cast(validacion_id as bigint) source_event_id,
 cast(tarjeta as varchar) user_key_raw,
 'N:' || lpad(regexp_extract(cast(tarjeta as varchar),'[0-9]+'),8,'0') usuario_canonico,
 cast(estacion_id as varchar) punto_codigo,
 cast(linea as varchar) ruta,
 cast(fecha_hora as timestamp) event_ts_local,
 cast(tarifa as decimal(14,2)) monto_q,
 cast(tipo as varchar) tipo_evento,
 'TM' operador,
 rn=1 es_valido,
 case when rn>1 then 'duplicado_evento' end motivo_rechazo
from src
