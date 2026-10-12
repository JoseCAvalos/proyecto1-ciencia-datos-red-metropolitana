{{ config(materialized='table') }}

with uso_modo as (
    select f.usuario_sk, m.codigo_modo
    from {{ ref('fact_abordaje') }} f
    join {{ ref('dim_modo') }} m on f.modo_sk = m.modo_sk
    where f.usuario_sk is not null

    union all

    select f.usuario_sk, m.codigo_modo
    from {{ ref('fact_viaje_metroriel') }} f
    join {{ ref('dim_modo') }} m on f.modo_sk = m.modo_sk
    where f.usuario_sk is not null
)
select
    usuario_sk,
    count(distinct codigo_modo) as cantidad_modos,
    string_agg(distinct codigo_modo, ', ' order by codigo_modo) as modos_usados,
    count(distinct codigo_modo) > 1 as usa_mas_de_un_sistema
from uso_modo
group by usuario_sk
