
select * from (values
 (1,'TM','Transmetro'),(2,'TU','Transurbano'),(3,'MR','MetroRiel'),(4,'AM','Aerómetro')
) as t(modo_sk,codigo_modo,nombre_modo)
