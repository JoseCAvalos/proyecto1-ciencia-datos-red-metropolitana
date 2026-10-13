{{ config(materialized='table') }}

with abordajes as (
    select
        f.evento_uid as evento_id,
        'ABORDAJE' as tipo_evento,
        t.fecha,
        t.hora,
        t.dia_semana,
        t.es_dia_habil,
        t.es_hora_pico,
        m.codigo_modo,
        m.nombre_modo,
        z.zona_nombre,
        f.usuario_sk,
        f.monto_q,
        f.conteo_abordaje as cantidad
    from {{ ref('fact_abordaje') }} f
    left join {{ ref('dim_tiempo') }} t on f.tiempo_sk = t.tiempo_sk
    left join {{ ref('dim_modo') }} m on f.modo_sk = m.modo_sk
    left join {{ ref('dim_zona') }} z on f.zona_sk = z.zona_sk
),
metroriel as (
    select
        f.viaje_uid as evento_id,
        'VIAJE' as tipo_evento,
        t.fecha,
        t.hora,
        t.dia_semana,
        t.es_dia_habil,
        t.es_hora_pico,
        m.codigo_modo,
        m.nombre_modo,
        ep.zona_nombre,
        f.usuario_sk,
        cast(f.monto_q as double) as monto_q,
        f.conteo_viaje as cantidad
    from {{ ref('fact_viaje_metroriel') }} f
    left join {{ ref('dim_tiempo') }} t on f.tiempo_salida_sk = t.tiempo_sk
    left join {{ ref('dim_modo') }} m on f.modo_sk = m.modo_sk
    left join {{ ref('dim_estacion_parada') }} ep on f.origen_sk = ep.estacion_parada_sk
)
select * from abordajes
union all
select * from metroriel
