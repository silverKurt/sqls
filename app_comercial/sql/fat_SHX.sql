/*FATURAMENTO BASE*/
select  biifdata as "data",         
	null as "cfop",
    biifvend AS "cod_representante",
	'REPRESENTANTE' || '-' || biifvend::TEXT as "representante",
    biifgere as "cod_supervisor",
    'SUPERVISOR' || '-' || biifgere::TEXT as "supervisor",
    biifclie as "cod_cliente",
	'CLIENTE' || '-' || biifclie::TEXT as "cliente",
	coalesce( case when cli.bi_cadaesta = 'EX' then 'EXTERIOR' else 'BRASIL' end ) as "pais",
	coalesce( cli.bi_cadaesta, null ) as "estado",
	coalesce( cli.bi_cadacida, null ) as "cidade",
    coalesce( cli.bi_cadacepa, null ) as "cep",
	(coalesce( case when cli.bi_cadaesta = 'EX' then 'EXTERIOR' else 'BRASIL' end )||','||coalesce( cli.bi_cadaesta, '' )||','||coalesce( cli.bi_cadacida, '' )||','||coalesce( cli.bi_cadacepa, '' )) as geo,
	'GRUPO' || '-' || bi_prodtipo::TEXT as "grupo_produto",
	'SUBGRUPO' || '-' || bi_prodsubt::TEXT as "subgrupo_produto",
	'MARCA' || '-' || bi_prodmarc::TEXT as "marca_produto",
	biifcodi as "cod_produto",
	'PRODUTO' || '-' || biifcodi::TEXT as "produto",
	(case when biifvtot > 0 then 'VENDA' else 'DEVOLUÇÃO' end) as "tipo_faturamento",
	biifempe as "cod_empresa",
	--coalesce( emp.bi_cadanome, null ) as empresa, bi_cadaredu
    'EMPRESA' ||'-'|| biifempe::TEXT as "empresa",
	concat(biifempe,'-',biifdocu,'/',biifseri) as "nota_fiscal",
	sum(biifvlit)*1.78 as "qtd",
    --sum(biifquan)*1.78 as "qtd",
	sum(biifvqui)*1.78 as "volume",
	sum(biifvtot)*1.78 as "faturamento"
from bi_biif
left join bi_prod on bi_prodcodi = biifcodi 
left join bi_mast on bi_mastcodi = bi_prodmast
left join bi_tabe tip on tip.bi_tabeindi = '100' AND tip.bi_tabecodi = bi_prodtipo
left join bi_tabe sub on sub.bi_tabeindi = '110' AND sub.bi_tabecodi = bi_prodsubt
left join bi_tabe lin on lin.bi_tabeindi = '120' AND lin.bi_tabecodi = bi_prodgrup
left join bi_cfam on bi_cfamcodi = bi_prodfami
left join bi_marc on bi_marccodi = bi_prodmarc
left join bi_cada emp on emp.bi_cadacodi = biifempe
left join bi_cada rep on rep.bi_cadacodi = biifvend
left join bi_cada cli on cli.bi_cadacodi = biifclie
left join bi_cada sup on sup.bi_cadacodi = biifgere
left join bi_tabe tcl on tcl.bi_tabeindi = '10' and tcl.bi_tabecodi = cli.bi_cadatpcl
left join bi_tabe reg on reg.bi_tabeindi = '15' and reg.bi_tabecodi = cli.bi_cadaregi
left join bi_tabe tre on tre.bi_tabeindi = '30' and tre.bi_tabecodi = rep.bi_cadatpvn
left join bi_cada fab on fab.bi_cadacodi = bi_prodforn
where biifdata >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL AND biifdata <= (DATE_TRUNC('YEAR', NOW()::DATE) - '1 DAY'::INTERVAL)
group by "data",
"cfop",
"cod_representante",
"representante",
"cod_supervisor",
"supervisor",
"cod_cliente",
"cliente",
"pais",
"estado",
"cidade",
"cep",
"geo",
"grupo_produto",
"subgrupo_produto",
"marca_produto",
"cod_produto",
"produto",
"tipo_faturamento",
"cod_empresa",
"empresa",
"nota_fiscal"