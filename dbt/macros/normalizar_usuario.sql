
{% macro normalizar_usuario(campo) %}
    CASE
        WHEN TRY_CAST(
            REGEXP_EXTRACT(
                CAST({{ campo }} AS VARCHAR),
                '[0-9]+'
            ) AS BIGINT
        ) IS NOT NULL
        THEN 'N:' || LPAD(
            CAST(
                TRY_CAST(
                    REGEXP_EXTRACT(
                        CAST({{ campo }} AS VARCHAR),
                        '[0-9]+'
                    ) AS BIGINT
                ) AS VARCHAR
            ),
            8,
            '0'
        )
        ELSE NULL
    END
{% endmacro %}
