
select row_number() over(order by operador,codigo) estacion_parada_sk,
       operador,codigo,nombre,ruta,zona_nombre,lat,lon
from {{ ref('silver_estaciones_paradas') }}
