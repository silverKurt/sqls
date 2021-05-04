SELECT 
metadata as data,
coalesce( vendgere, 0 ) as cod_supervisor,
'SUPERVISOR' || '-' || CAST(coalesce( vendgere, 0 ) AS TEXT) as supervisor,
metacodi as cod_representante,
'REPRESENTANTE' || '-' || metacodi::TEXT as representante,
coalesce( vendempe, 0) AS cod_empresa,
'EMPRESA' || '-' || coalesce( vendempe, 0)::TEXT AS empresa,
metavalo as meta,		
metavalo*0.78 as volume_meta,
metalitr as qtd_meta	
from arqmeta
left join arqcada rep on rep.cadacodi = metacodi
left join arqvend on vendcodi = rep.cadacodi
left join arqcada sup on sup.cadacodi = vendgere
left join arqcada emp on emp.cadacodi = vendempe
where metatipo = 'V' and metacodi > 0  and (metavalo > 0 or metavqui > 0 or metalitr > 0)
and metadata >= '2020-01-01'