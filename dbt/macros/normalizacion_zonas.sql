{% macro normalizar_zona(expr) -%}
case
    when {{ expr }} is null or trim(cast({{ expr }} as varchar)) = '' then null
    when regexp_matches(upper(trim(cast({{ expr }} as varchar))), '^Z[ ]*[0-9]+$')
        then 'Zona ' || regexp_extract(upper(trim(cast({{ expr }} as varchar))), '[0-9]+')
    when regexp_matches(upper(trim(cast({{ expr }} as varchar))), '^ZONA[ ]+[0-9]+$')
        then 'Zona ' || regexp_extract(upper(trim(cast({{ expr }} as varchar))), '[0-9]+')
    when upper(trim(cast({{ expr }} as varchar))) = 'MIXCO' then 'Mixco'
    when upper(trim(cast({{ expr }} as varchar))) = 'VILLA NUEVA' then 'Villa Nueva'
    when upper(trim(cast({{ expr }} as varchar))) = 'SAN MIGUEL PETAPA' then 'San Miguel Petapa'
    when upper(trim(cast({{ expr }} as varchar))) = 'SANTA CATARINA PINULA' then 'Santa Catarina Pinula'
    else trim(cast({{ expr }} as varchar))
end
{%- endmacro %}
