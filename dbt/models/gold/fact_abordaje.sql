
with eventos as (
 select 'TM' operador, source_event_id, usuario_canonico, punto_codigo, ruta, event_ts_local, monto_q
 from {{ ref('silver_tm_validaciones') }} where es_valido
 union all
 select 'TU', source_event_id, usuario_canonico, punto_codigo, ruta, event_ts_local, monto_q
 from {{ ref('silver_transurbano') }} where es_valido_calidad and es_abordaje_exitoso
 union all
 select 'AM', source_event_id, usuario_canonico, punto_codigo, ruta, event_ts_local, monto_q
 from {{ ref('silver_aerometro') }} where es_valido
)
select
 row_number() over(order by e.operador,e.source_event_id) abordaje_sk,
 e.operador || ':' || cast(e.source_event_id as varchar) evento_uid,
 u.usuario_sk,t.tiempo_sk,z.zona_sk,m.modo_sk,ep.estacion_parada_sk,r.ruta_sk,
 e.monto_q,1 conteo_abordaje
from eventos e
left join {{ ref('dim_usuario') }} u
  on u.usuario_pseudo=sha256('{{ env_var("PSEUDONYM_SALT","CAMBIAR") }}' || e.usuario_canonico)
left join {{ ref('dim_estacion_parada') }} ep on ep.operador=e.operador and ep.codigo=e.punto_codigo
left join {{ ref('dim_zona') }} z on z.zona_nombre=ep.zona_nombre
left join {{ ref('dim_modo') }} m on m.codigo_modo=e.operador
left join {{ ref('dim_ruta') }} r on r.operador=e.operador and r.ruta=e.ruta
left join {{ ref('dim_tiempo') }} t on t.ts_hora=date_trunc('hour',e.event_ts_local)
