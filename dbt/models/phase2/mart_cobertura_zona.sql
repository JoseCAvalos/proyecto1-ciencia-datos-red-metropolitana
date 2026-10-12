{{ config(materialized='table') }}

with zonas_residencia as (
    select
        trim(zona_residencia) as zona_nombre,
        count(*) as usuarios_residentes
    from {{ ref('dim_usuario') }}
    where zona_residencia is not null
      and trim(zona_residencia) <> ''
    group by 1
),
servicio as (
    select
        zona_nombre,
        count(distinct operador) as cantidad_modos,
        string_agg(distinct operador, ', ' order by operador) as modos_disponibles,
        count(*) as puntos_servicio
    from {{ ref('dim_estacion_parada') }}
    where zona_nombre is not null
    group by 1
)
select
    z.zona_nombre,
    z.usuarios_residentes,
    coalesce(s.cantidad_modos, 0) as cantidad_modos,
    coalesce(s.modos_disponibles, 'SIN SERVICIO') as modos_disponibles,
    coalesce(s.puntos_servicio, 0) as puntos_servicio,
    coalesce(s.cantidad_modos, 0) > 0 as tiene_servicio
from zonas_residencia z
left join servicio s on z.zona_nombre = s.zona_nombre
order by z.zona_nombre
