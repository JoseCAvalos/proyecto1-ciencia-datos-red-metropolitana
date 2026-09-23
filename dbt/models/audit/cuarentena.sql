
select 'TM' fuente, cast(source_event_id as varchar) source_id, motivo_rechazo motivo
from {{ ref('silver_tm_validaciones') }} where not es_valido
union all
select 'TU', cast(source_event_id as varchar), motivo_rechazo
from {{ ref('silver_transurbano') }} where not es_valido_calidad
union all
select 'MR', cast(source_event_id as varchar), motivo_rechazo
from {{ ref('silver_metroriel') }} where not es_valido
