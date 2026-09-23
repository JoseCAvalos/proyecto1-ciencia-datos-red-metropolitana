
select
  cast(_payload.validacion_id as bigint) validacion_id,
  cast(_payload.tarjeta as varchar) tarjeta,
  cast(_payload.estacion_id as varchar) estacion_id,
  cast(_payload.linea as varchar) linea,
  cast(_payload.fecha_hora as varchar) fecha_hora,
  cast(_payload.tarifa as decimal(14,2)) tarifa,
  cast(_payload.tipo as varchar) tipo,
  cast(_event_uid as varchar) event_uid,
  cast(_ingestion_ts as timestamp) ingestion_ts
from read_json_auto(
  'data/bronze/ingestion_date=*/transmetro_validaciones_stream.jsonl',
  format='newline_delimited', union_by_name=true
)
