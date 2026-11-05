
{{ config(materialized='table') }}

WITH cortes AS (
    SELECT DATE '2026-07-01' AS fecha_corte, 'A' AS corte
    UNION ALL
    SELECT DATE '2026-07-31', 'B'
    UNION ALL
    SELECT DATE '2026-08-30', 'C'
),

estaciones AS (
    SELECT
        operador,
        codigo,
        MAX(zona_nombre) AS zona_nombre
    FROM {{ ref('silver_estaciones_paradas') }}
    GROUP BY 1, 2
),

eventos AS (
    SELECT
        s.usuario_canonico AS usuario,
        'TM' AS modo,
        s.event_ts_local AS ts,
        CAST(s.monto_q AS DECIMAL(18, 2)) AS monto_q,
        e.zona_nombre
    FROM {{ ref('silver_tm_validaciones') }} s
    LEFT JOIN estaciones e
      ON e.operador = 'TM'
     AND e.codigo = s.punto_codigo
    WHERE s.es_valido = TRUE

    UNION ALL

    SELECT
        s.usuario_canonico,
        'TU',
        s.event_ts_local,
        CAST(s.monto_q AS DECIMAL(18, 2)),
        e.zona_nombre
    FROM {{ ref('silver_transurbano') }} s
    LEFT JOIN estaciones e
      ON e.operador = 'TU'
     AND e.codigo = s.punto_codigo
    WHERE s.es_valido_calidad = TRUE
      AND s.es_abordaje_exitoso = TRUE

    UNION ALL

    SELECT
        s.usuario_canonico,
        'MR',
        s.salida_ts_local,
        CAST(s.monto_q AS DECIMAL(18, 2)),
        e.zona_nombre
    FROM {{ ref('silver_metroriel') }} s
    LEFT JOIN estaciones e
      ON e.operador = 'MR'
     AND e.codigo = s.origen_codigo
    WHERE s.es_valido = TRUE

    UNION ALL

    SELECT
        s.usuario_canonico,
        'AM',
        s.event_ts_local,
        CAST(s.monto_q AS DECIMAL(18, 2)),
        e.zona_nombre
    FROM {{ ref('silver_aerometro') }} s
    LEFT JOIN estaciones e
      ON e.operador = 'AM'
     AND e.codigo = s.punto_codigo
    WHERE s.es_valido = TRUE
),

historial AS (
    SELECT
        c.corte,
        c.fecha_corte,
        e.*
    FROM cortes c
    INNER JOIN eventos e
      ON e.ts >= c.fecha_corte - INTERVAL 28 DAY
     AND e.ts < c.fecha_corte
    WHERE e.usuario IS NOT NULL
),

actividad AS (
    SELECT
        corte,
        fecha_corte,
        usuario,
        COUNT(*) AS viajes_28d,
        COUNT(*) FILTER (
            WHERE ts >= fecha_corte - INTERVAL 7 DAY
        ) AS viajes_7d,
        COUNT(*) FILTER (
            WHERE ts >= fecha_corte - INTERVAL 14 DAY
        ) AS viajes_14d,
        COUNT(DISTINCT modo) AS cantidad_modos_distintos,
        DATE_DIFF(
            'day',
            CAST(MAX(ts) AS DATE),
            fecha_corte
        ) AS dias_desde_ultimo_viaje,
        AVG(
            CASE
                WHEN EXTRACT(HOUR FROM ts) BETWEEN 6 AND 8
                  OR EXTRACT(HOUR FROM ts) BETWEEN 16 AND 19
                THEN 1.0 ELSE 0.0
            END
        ) AS proporcion_hora_pico,
        SUM(COALESCE(monto_q, 0)) AS gasto_28d_q,
        ROUND(AVG(COALESCE(monto_q, 0)), 2) AS gasto_promedio_q
    FROM historial
    GROUP BY 1, 2, 3
    HAVING COUNT(*) >= 2
),

cdc_ultimo AS (
    SELECT
        c.corte,
        p.usuario_canonico AS usuario,
        p.op,
        ROW_NUMBER() OVER (
            PARTITION BY c.corte, p.usuario_canonico
            ORDER BY p.commit_ts DESC, p.seq DESC
        ) AS rn
    FROM cortes c
    INNER JOIN {{ ref('silver_padron_scd2') }} p
      ON p.commit_ts < c.fecha_corte
    WHERE p.usuario_canonico IS NOT NULL
),

poblacion AS (
    SELECT a.*
    FROM actividad a
    LEFT JOIN cdc_ultimo p
      ON a.corte = p.corte
     AND a.usuario = p.usuario
     AND p.rn = 1
    WHERE p.op IS DISTINCT FROM 'DELETE'
),

modos AS (
    SELECT
        corte,
        usuario,
        modo,
        COUNT(*) AS viajes,
        ROW_NUMBER() OVER (
            PARTITION BY corte, usuario
            ORDER BY COUNT(*) DESC, modo
        ) AS rn
    FROM historial
    GROUP BY 1, 2, 3
),

zonas AS (
    SELECT
        corte,
        usuario,
        zona_nombre,
        COUNT(*) AS viajes,
        ROW_NUMBER() OVER (
            PARTITION BY corte, usuario
            ORDER BY COUNT(*) DESC, zona_nombre
        ) AS rn
    FROM historial
    WHERE zona_nombre IS NOT NULL
    GROUP BY 1, 2, 3
)

SELECT
    p.corte,
    p.fecha_corte,
    SHA256(
        '{{ env_var("PSEUDONYM_SALT", "CAMBIAR") }}'
        || p.usuario
    ) AS usuario_pseudo,
    p.viajes_7d,
    p.viajes_14d,
    p.viajes_28d,
    p.cantidad_modos_distintos,
    p.dias_desde_ultimo_viaje,
    p.proporcion_hora_pico,
    p.gasto_28d_q,
    p.gasto_promedio_q,
    m.modo AS modo_mas_usado,
    z.zona_nombre AS zona_origen_mas_frecuente
FROM poblacion p
LEFT JOIN modos m
  ON m.corte = p.corte
 AND m.usuario = p.usuario
 AND m.rn = 1
LEFT JOIN zonas z
  ON z.corte = p.corte
 AND z.usuario = p.usuario
 AND z.rn = 1
