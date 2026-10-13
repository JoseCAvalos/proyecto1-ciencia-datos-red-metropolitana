with zonas as (
    select zona_nombre from {{ ref('silver_estaciones_paradas') }}
    union all
    select zona_residencia as zona_nombre from {{ ref('silver_padron_scd2') }}
),
duplicados_case as (
    select lower(trim(zona_nombre)) as zona_key, count(distinct zona_nombre) as variantes
    from zonas
    where zona_nombre is not null
    group by 1
    having count(distinct zona_nombre) > 1
),
casos_esperados as (
    select zona_nombre
    from zonas
    where zona_nombre in (
        'MIXCO',
        'VILLA NUEVA',
        'SAN MIGUEL PETAPA',
        'SANTA CATARINA PINULA'
    )
)
select * from duplicados_case
union all
select lower(trim(zona_nombre)) as zona_key, 1 as variantes
from casos_esperados
