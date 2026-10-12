{{ config(materialized='table') }}

with estaciones as (
    select operador, codigo, zona_nombre
    from {{ ref('silver_estaciones_paradas') }}
),
eventos as (
    select s.usuario_canonico, 'TM' as modo, s.event_ts_local as ts,
           cast(s.monto_q as double) as monto_q, e.zona_nombre
    from {{ ref('silver_tm_validaciones') }} s
    left join estaciones e on e.operador='TM' and e.codigo=s.punto_codigo
    where s.es_valido

    union all

    select s.usuario_canonico, 'TU' as modo, s.event_ts_local as ts,
           cast(s.monto_q as double) as monto_q, e.zona_nombre
    from {{ ref('silver_transurbano') }} s
    left join estaciones e on e.operador='TU' and e.codigo=s.punto_codigo
    where s.es_valido_calidad and s.es_abordaje_exitoso

    union all

    select s.usuario_canonico, 'MR' as modo, s.salida_ts_local as ts,
           cast(s.monto_q as double) as monto_q, e.zona_nombre
    from {{ ref('silver_metroriel') }} s
    left join estaciones e on e.operador='MR' and e.codigo=s.origen_codigo
    where s.es_valido

    union all

    select s.usuario_canonico, 'AM' as modo, s.event_ts_local as ts,
           cast(s.monto_q as double) as monto_q, e.zona_nombre
    from {{ ref('silver_aerometro') }} s
    left join estaciones e on e.operador='AM' and e.codigo=s.punto_codigo
    where s.es_valido
),
corte as (
    select max(ts) as fecha_corte from eventos
),
modo_conteo as (
    select usuario_canonico, modo, count(*) as n
    from eventos
    group by 1,2
),
modo_rank as (
    select *,
           row_number() over(
               partition by usuario_canonico
               order by n desc, modo
           ) as rn
    from modo_conteo
),
zona_conteo as (
    select usuario_canonico, zona_nombre, count(*) as n
    from eventos
    where zona_nombre is not null
    group by 1,2
),
zona_rank as (
    select *,
           row_number() over(
               partition by usuario_canonico
               order by n desc, zona_nombre
           ) as rn
    from zona_conteo
),
agregados as (
    select
        e.usuario_canonico,
        c.fecha_corte,
        count(*) as viajes_total,
        sum(case when e.ts >= c.fecha_corte - interval '7 days' then 1 else 0 end) as viajes_7d,
        sum(case when e.ts >= c.fecha_corte - interval '30 days' then 1 else 0 end) as viajes_30d,
        sum(case when e.ts >= c.fecha_corte - interval '90 days' then 1 else 0 end) as viajes_90d,
        count(distinct e.modo) as cantidad_modos_distintos,
        date_diff('day', max(e.ts), c.fecha_corte) as dias_desde_ultimo_viaje,
        avg(
            case
                when extract(hour from e.ts) between 6 and 8
                  or extract(hour from e.ts) between 16 and 19
                then 1.0 else 0.0
            end
        ) as proporcion_hora_pico,
        sum(coalesce(e.monto_q,0)) as gasto_acumulado_q,
        avg(coalesce(e.monto_q,0)) as gasto_promedio_q
    from eventos e
    cross join corte c
    group by e.usuario_canonico, c.fecha_corte
)
select
    sha256('{{ env_var("PSEUDONYM_SALT","CAMBIAR") }}' || a.usuario_canonico) as usuario_pseudo,
    a.fecha_corte,
    a.viajes_total,
    a.viajes_7d,
    a.viajes_30d,
    a.viajes_90d,
    mr.modo as modo_mas_usado,
    a.cantidad_modos_distintos,
    a.dias_desde_ultimo_viaje,
    a.proporcion_hora_pico,
    zr.zona_nombre as zona_origen_mas_frecuente,
    a.gasto_acumulado_q,
    a.gasto_promedio_q
from agregados a
left join modo_rank mr
    on a.usuario_canonico=mr.usuario_canonico and mr.rn=1
left join zona_rank zr
    on a.usuario_canonico=zr.usuario_canonico and zr.rn=1
