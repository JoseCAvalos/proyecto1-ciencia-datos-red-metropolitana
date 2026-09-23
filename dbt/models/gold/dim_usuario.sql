with u as (

    select usuario_canonico
    from {{ ref('silver_tm_validaciones') }}
    where usuario_canonico is not null

    union

    select usuario_canonico
    from {{ ref('silver_transurbano') }}
    where usuario_canonico is not null

    union

    select usuario_canonico
    from {{ ref('silver_metroriel') }}
    where usuario_canonico is not null

    union

    select usuario_canonico
    from {{ ref('silver_aerometro') }}
    where usuario_canonico is not null

),

padron_actual as (

    select
        usuario_canonico,
        perfil,
        zona_residencia,
        activo,
        valido_desde,
        seq,

        row_number() over (
            partition by usuario_canonico
            order by valido_desde desc, seq desc
        ) as rn

    from {{ ref('silver_padron_scd2') }}

    where
        es_actual = true
        and usuario_canonico is not null

),

p as (

    select
        usuario_canonico,
        perfil,
        zona_residencia,
        activo

    from padron_actual

    where rn = 1

)

select

    row_number() over (
        order by u.usuario_canonico
    ) as usuario_sk,

    sha256(
        '{{ env_var("PSEUDONYM_SALT","CAMBIAR") }}'
        || u.usuario_canonico
    ) as usuario_pseudo,

    p.perfil,
    p.zona_residencia,
    p.activo

from u

left join p
    using (usuario_canonico)