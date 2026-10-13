{{ config(materialized='table') }}

with zonas_objetivo(zona_nombre) as (
    values ('Zona 1'), ('Zona 6'), ('Zona 8'), ('Zona 12'), ('Zona 17')
),
demanda as (
    select
        zona_nombre,
        sum(cantidad) as demanda_total,
        count(distinct usuario_sk) as usuarios_distintos
    from {{ ref('mart_demanda_dashboard') }}
    where zona_nombre is not null
    group by 1
),
servicio_mr as (
    select
        zona_nombre,
        count(*) as estaciones_metroriel
    from {{ ref('dim_estacion_parada') }}
    where operador = 'MR'
      and zona_nombre is not null
    group by 1
)
select
    z.zona_nombre,
    coalesce(d.demanda_total, 0) as demanda_total,
    coalesce(d.usuarios_distintos, 0) as usuarios_distintos,
    coalesce(m.estaciones_metroriel, 0) as estaciones_metroriel,
    coalesce(m.estaciones_metroriel, 0) > 0 as atendida_por_metroriel
from zonas_objetivo z
left join demanda d using (zona_nombre)
left join servicio_mr m using (zona_nombre)
order by demanda_total desc
