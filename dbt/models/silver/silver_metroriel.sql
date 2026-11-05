
select
 cast(trip_id as bigint) source_event_id,
 cast(card as varchar) user_key_raw,
 {{ normalizar_usuario('card') }} AS usuario_canonico,
 cast(entry.station as varchar) origen_codigo,
 cast("exit".station as varchar) destino_codigo,
 cast(entry.ts as timestamp) salida_ts_local,
 cast("exit".ts as timestamp) llegada_ts_local,
 cast(fare_gtq as decimal(14,2)) monto_q,
 cast(duration_s as bigint) duration_s,
 'MR' operador,
 "exit" is not null es_valido,
 case when "exit" is null then 'viaje_sin_salida' end motivo_rechazo
from {{ ref('stg_metroriel') }}
