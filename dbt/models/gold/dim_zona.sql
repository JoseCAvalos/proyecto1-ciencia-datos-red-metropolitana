
select row_number() over(order by zona_nombre) zona_sk, zona_nombre
from (select distinct zona_nombre from {{ ref('silver_estaciones_paradas') }} where zona_nombre is not null)
