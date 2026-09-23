select
 cast(boarding_id as bigint) source_event_id,
 cast(user_hash as varchar) user_key_raw,
 'AM:' || cast(user_hash as varchar) usuario_canonico,
 cast(station_code as varchar) punto_codigo,
 cast(axis as varchar) ruta,

 cast(timestamp_utc as timestamp)
     - interval '6 hours' event_ts_local,

 cast(fare as decimal(14,2)) monto_q,
 cast(cabin_number as integer) cabin_number,
 'AM' operador,
 true es_valido,
 null::varchar motivo_rechazo

from {{ ref('stg_aerometro') }}