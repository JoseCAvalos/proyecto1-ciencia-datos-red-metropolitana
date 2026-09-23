
select
 row_number() over(order by v.source_event_id) viaje_sk,
 'MR:' || cast(v.source_event_id as varchar) viaje_uid,
 u.usuario_sk,ts.tiempo_sk tiempo_salida_sk,tl.tiempo_sk tiempo_llegada_sk,
 eo.estacion_parada_sk origen_sk,ed.estacion_parada_sk destino_sk,m.modo_sk,
 v.monto_q,v.duration_s,1 conteo_viaje
from {{ ref('silver_metroriel') }} v
left join {{ ref('dim_usuario') }} u
  on u.usuario_pseudo=sha256('{{ env_var("PSEUDONYM_SALT","CAMBIAR") }}' || v.usuario_canonico)
left join {{ ref('dim_estacion_parada') }} eo on eo.operador='MR' and eo.codigo=v.origen_codigo
left join {{ ref('dim_estacion_parada') }} ed on ed.operador='MR' and ed.codigo=v.destino_codigo
left join {{ ref('dim_modo') }} m on m.codigo_modo='MR'
left join {{ ref('dim_tiempo') }} ts on ts.ts_hora=date_trunc('hour',v.salida_ts_local)
left join {{ ref('dim_tiempo') }} tl on tl.ts_hora=date_trunc('hour',v.llegada_ts_local)
where v.es_valido
