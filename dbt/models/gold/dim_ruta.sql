
select row_number() over(order by operador,ruta) ruta_sk, operador,ruta
from (select distinct operador,ruta from {{ ref('silver_estaciones_paradas') }} where ruta is not null)
