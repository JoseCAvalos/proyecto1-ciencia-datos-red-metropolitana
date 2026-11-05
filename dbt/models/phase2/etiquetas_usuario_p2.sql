{{ config(materialized='table') }}

-- Etiqueta a 30 días: no confundir con las features históricas de 28 días.
-- En fase 1 solo se publica la etiqueta A. B queda reservada hasta fase 2.
-- Habilitar B únicamente tras congelar selección y parámetros del modelo:
-- dbt run --select etiquetas_usuario_p2 --vars '{p2_habilitar_etiqueta_b: true}'
{% set habilitar_b = var('p2_habilitar_etiqueta_b', false) %}

WITH cortes AS (
    SELECT DATE '2026-07-01' AS fecha_corte, 'A' AS corte
    UNION ALL SELECT DATE '2026-07-31', 'B'
    UNION ALL SELECT DATE '2026-08-30', 'C'
),
eventos AS (
    SELECT usuario_canonico AS usuario, event_ts_local AS ts
    FROM {{ ref('silver_tm_validaciones') }}
    WHERE es_valido = TRUE
    UNION ALL
    SELECT usuario_canonico, event_ts_local
    FROM {{ ref('silver_transurbano') }}
    WHERE es_valido_calidad = TRUE AND es_abordaje_exitoso = TRUE
    UNION ALL
    SELECT usuario_canonico, salida_ts_local
    FROM {{ ref('silver_metroriel') }}
    WHERE es_valido = TRUE
    UNION ALL
    SELECT usuario_canonico, event_ts_local
    FROM {{ ref('silver_aerometro') }}
    WHERE es_valido = TRUE
),
posterior AS (
    SELECT
        c.corte,
        SHA256('{{ env_var("PSEUDONYM_SALT", "CAMBIAR") }}' || e.usuario) AS usuario_pseudo,
        COUNT(*) AS abordajes_30d
    FROM cortes c
    INNER JOIN eventos e
       ON e.ts >= c.fecha_corte
      AND e.ts < c.fecha_corte + INTERVAL 30 DAY
    WHERE e.usuario IS NOT NULL
      AND (c.corte = 'A' {% if habilitar_b %} OR c.corte = 'B' {% endif %})
    GROUP BY 1, 2
)
SELECT
    f.corte,
    f.fecha_corte,
    f.usuario_pseudo,
    CASE
        WHEN f.corte = 'A' {% if habilitar_b %} OR f.corte = 'B' {% endif %}
        THEN CASE WHEN COALESCE(p.abordajes_30d, 0) = 0 THEN 1 ELSE 0 END
        ELSE NULL
    END AS abandono_30d,
    CASE
        WHEN f.corte = 'A' {% if habilitar_b %} OR f.corte = 'B' {% endif %}
        THEN COALESCE(p.abordajes_30d, 0)
        ELSE NULL
    END AS abordajes_futuros_30d
FROM {{ ref('features_usuario_p2') }} f
LEFT JOIN posterior p
    ON f.corte = p.corte AND f.usuario_pseudo = p.usuario_pseudo
