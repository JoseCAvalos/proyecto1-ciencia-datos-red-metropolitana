
with tm as (
 select 'TM' operador, cast(estacion_id as varchar) codigo, nombre,
        linea ruta, zona zona_raw, zona zona_nombre, lat, lon
 from {{ ref('stg_tm_estaciones') }}
), tu as (
 select 'TU' operador, cast(cod_parada as varchar) codigo, descripcion nombre,
        ruta,
        sector zona_raw,
        case when regexp_matches(sector,'^Z[0-9]+$')
             then 'Zona ' || regexp_extract(sector,'[0-9]+')
             else sector 
        end zona_nombre,
        null::double lat, null::double lon
 from {{ ref('stg_tu_paradas') }}
), mr as (
 select 'MR' operador, cast(id_estacion as varchar) codigo, nombre_estacion nombre,
        null::varchar ruta, zona_nombre zona_raw, zona_nombre,
        null::double lat, null::double lon
 from {{ ref('stg_mr_estaciones') }}
), am as (
 select 'AM' operador, cast(station_code as varchar) codigo, station_name nombre,
        axis ruta, district zona_raw,
        case when regexp_matches(district,'^Z[0-9]+$')
             then 'Zona ' || regexp_extract(district,'[0-9]+')
             else district end zona_nombre,
        null::double lat, null::double lon
 from {{ ref('stg_am_estaciones') }}
)
select * from tm union all by name select * from tu
union all by name select * from mr union all by name select * from am
