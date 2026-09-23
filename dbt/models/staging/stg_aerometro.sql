
select
  cast(_payload.boarding_id as bigint) boarding_id,
  cast(_payload.user_hash as varchar) user_hash,
  cast(_payload.station_code as varchar) station_code,
  cast(_payload.axis as varchar) axis,
  cast(_payload.timestamp_utc as varchar) timestamp_utc,
  cast(_payload.cabin_number as integer) cabin_number,
  cast(_payload.fare as decimal(14,2)) fare,
  cast(_event_uid as varchar) event_uid,
  cast(_ingestion_ts as timestamp) ingestion_ts
from read_json_auto(
  'data/bronze/ingestion_date=*/aerometro_boardings_stream.jsonl',
  format='newline_delimited', union_by_name=true
)
