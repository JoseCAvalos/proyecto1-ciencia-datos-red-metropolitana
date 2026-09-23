
with x as (
 select
   cast(num_tarjeta as varchar) user_key_raw,
   cast(cod_parada as varchar) cod_parada,
   cast(ruta as varchar) ruta,
   try_strptime(fecha || ' ' || hora,'%d/%m/%Y %H:%M:%S') event_ts_local,
   try_cast(monto_centavos as decimal(14,2))/100 monto_q,
   try_cast(cod_estado as integer) cod_estado,
   fecha, hora,
   sha256(
     coalesce(fecha,'') || '|' || coalesce(hora,'') || '|' ||
     coalesce(num_tarjeta,'') || '|' || coalesce(cod_parada,'') || '|' ||
     coalesce(ruta,'') || '|' || coalesce(monto_centavos,'') || '|' ||
     coalesce(cod_estado,'')
   ) source_event_id
 from {{ ref('stg_transurbano') }}
)
select
 source_event_id,
 user_key_raw,
 'N:' || lpad(regexp_extract(user_key_raw,'[0-9]+'),8,'0') usuario_canonico,
 cod_parada punto_codigo,
 ruta,
 event_ts_local,
 monto_q,
 cod_estado,
 'TU' operador,
 not ((cod_parada is null or trim(cod_parada)='') or event_ts_local > current_timestamp) es_valido_calidad,
 cod_estado in (1,2,3) es_abordaje_exitoso,
 trim(both ';' from
   (case when cod_parada is null or trim(cod_parada)='' then 'parada_nula;' else '' end) ||
   (case when event_ts_local > current_timestamp then 'fecha_futura;' else '' end)
 ) motivo_rechazo
from x
