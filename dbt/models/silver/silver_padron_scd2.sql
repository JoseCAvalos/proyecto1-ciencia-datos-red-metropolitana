
with c as (
 select
   cast(seq as bigint) seq,
   cast(commit_ts as timestamp) commit_ts,
   upper(op) op,
   tarjeta,
   nullif(perfil,'') perfil,
   nullif(zona_residencia,'') zona_residencia,
   nullif(estado,'') estado,
   case
     when regexp_matches(tarjeta,'^TC-[0-9]+$') then 'TM'
     when regexp_matches(tarjeta,'^[0-9]{10}$') then 'TU'
     when regexp_matches(tarjeta,'^MR[0-9]+$') then 'MR'
     when tarjeta='SIN-TARJETA' then 'SIN_LLAVE'
     else 'OTRO' end formato_llave,
   case
     when regexp_matches(tarjeta,'^TC-[0-9]+$') then 'N:' || lpad(regexp_extract(tarjeta,'[0-9]+'),8,'0')
     when regexp_matches(tarjeta,'^[0-9]{10}$') then 'N:' || lpad(regexp_extract(tarjeta,'[0-9]+'),8,'0')
     when regexp_matches(tarjeta,'^MR[0-9]+$') then 'N:' || lpad(regexp_extract(tarjeta,'[0-9]+'),8,'0')
     else null end usuario_canonico
 from {{ ref('stg_cdc') }}
), h as (
 select *,
   lead(commit_ts) over(partition by tarjeta order by seq) valido_hasta
 from c
)
select *,
 commit_ts valido_desde,
 valido_hasta is null es_actual,
 op <> 'DELETE' activo
from h
