select 
    clibdata as data,
    clibdata as data_venda,
    (case when ilibpent is not null then ilibpent else clibprev end) as data_prev_entrega,
    clibdocu as cod_pedido,
    '' as cfop,
    coalesce( rep.cadacodi, 0 ) as cod_representante,
    'REPRESENTANTE-'||coalesce( rep.cadacodi, 0 )::text as representante,
    coalesce( cli.cadacodi, 0 ) as cod_cliente,
    'CLIENTE-'||coalesce( cli.cadacodi, 0 )::TEXT as cliente,
    'BRASIL' as pais,
    coalesce( cli.cadacida, 'NAO INFORMADO' ) as cidade,
    coalesce( cli.cadaesta, 'NAO INFORMADO' ) as estado,
    null::text as cep,
    null::text as geo,
    'GRUPO-'||coalesce( tip.tabecodi::TEXT, 'NAO INFORMADO' ) as grupo_produto,
    'SUBGRUPO-'||coalesce( sub.tabecodi::TEXT, 'NAO INFORMADO' ) as subgrupo_produto,
    'MARCA-'||coalesce( marccodi::TEXT, 'NAO INFORMADO' ) as marca_produto,
    prodcodi as cod_produto,
    'PRODUTO-' || prodcodi::TEXT as produto,
    (case when clibtipo = '99' then 'FATURADO' else ( case when clibtipo = '98' then 'FATURADO PARCIAL' else 'ABERTO' end)  end) as status,
    1::DOUBLE PRECISION as quantidade,
	0::DOUBLE PRECISION as volume,
    ( ilibquan * ilibprec )*1.78 as valor_pedido
from arqilib 
left join arqclib on clibempe = ilibempe and clibdocu = ilibdocu
left join arqoper on opercodi = cliboper
left join arqcfif on ilibtpro = 'M' and cfifempe = ilibempe and cfifdocu = ilibdocu and cfifseri = '' and cfifsequ = ilibsequ and cfiforig = 'ILIB'
left join arqprod on prodcodi = coalesce( cfifbase, ilibcodi )
left join arqmast on mastcodi = prodmast
left join arqtabe tip on tip.tabeindi = '100' AND tip.tabecodi = masttipo
left join arqtabe sub on sub.tabeindi = '110' AND sub.tabecodi = mastsubt
left join arqtabe lin on lin.tabeindi = '120' AND lin.tabecodi = mastgrup
left join arqmarc on marccodi = mastmarc
left join arqcfam on cfamcodi = mastfami
left join arqcipi on cipicodi = mastfisc
left join arqcada rep on rep.cadacodi = ilibvend
left join arqvend on vendcodi = rep.cadacodi
left join arqcada sup on sup.cadacodi = vendgere
left join arqcada cli on cli.cadacodi = clibclie
left join arqclie on cliecodi = cli.cadacodi 
left join arqtabe tcl on tcl.tabeindi = '10' and tcl.tabecodi = clietpcl
where clibtipo in ( '01', '20', '98', '99' ) and cliborig not in ( 'PHO', 'PHD' ) and opertipo = '1' and clibdata >= '2021-01-01'::DATE