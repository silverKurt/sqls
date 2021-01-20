WITH empresas AS (
-- Source: Faturamento Diarizacao
SELECT DISTINCT
    CAST("id_empresa" AS TEXT) AS id_empresa,
    CAST("empresa" AS TEXT) AS empresa
FROM "guimaraespl"."fat_guimaraespl_FaturamentoDiarizacao"

), representantes AS (
    SELECT DISTINCT
        CAST(qtd_representante AS INTEGER) AS id_representante
        , representante
    FROM "guimaraespl"."fat_guimaraespl_FaturamentoDiarizacao"
)

(SELECT  
    p.periodo AS periodo
    , CAST(null AS INTEGER) AS id_representante
    , CAST(null AS TEXT) AS representante
    , COALESCE(m.codigo_empresa, p.id_empresa) AS id_empresa
    , COALESCE(m.empresa, emp.empresa) AS empresa
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN 'VENDA' ELSE NULL END AS tipo_faturamento
    , 'GERAL' AS grupo_vendedores

    , CAST(NULL AS TEXT) AS numpedido
    , CAST(NULL AS TEXT) AS cliente
    , CAST(NULL AS DATE) AS dtapreventrega

    , m.vlr_meta / (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) AS vlr_meta_empresa
    , CAST(NULL AS DOUBLE PRECISION) AS qtd
    , CAST(NULL AS DOUBLE PRECISION) AS vlr

    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_mes
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.periodo <= NOW()::DATE AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_corridos_mes
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('YEAR', pi.periodo) = DATE_TRUNC('YEAR', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_ano
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('YEAR', pi.periodo) = DATE_TRUNC('YEAR', p.periodo) AND pi.periodo <= NOW()::DATE AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_corridos_ano

    , NULL::DOUBLE PRECISION AS vlrpedidos
	, NULL::TEXT AS qtdepedidos

FROM "guimaraespl"."fat_guimaraespl_Meta" m
LEFT JOIN "guimaraespl"."fat_guimaraespl_CalendarioComercial" p ON (DATE_TRUNC('MONTH', CAST(m."data_da_meta" AS DATE)) = DATE_TRUNC('MONTH', p.periodo) AND m.codigo_empresa = p.id_empresa AND p.util::INTEGER = 1)
LEFT JOIN empresas emp ON (p.id_empresa = emp.id_empresa)
ORDER BY 1
)

UNION ALL

(SELECT
    periodo AS periodo
    , CAST(qtd_representante AS INTEGER) AS id_representante
    , representante
    , id_empresa
    , empresa
    , tipo_faturamento
    , gv.grupo_vendedores AS grupo_vendedor

    , CAST(NULL AS TEXT) AS numpedido
    , CAST(NULL AS TEXT) AS cliente
    , CAST(NULL AS DATE) AS dtapreventrega

    , CAST(NULL AS DOUBLE PRECISION) AS vlr_meta_empresa

    , qtd
    , vlr_margem_gerencial as vlr

    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_mes
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_mes
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_ano
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_ano

    , NULL::DOUBLE PRECISION AS vlrpedidos
	, NULL::TEXT AS qtdepedidos
FROM "guimaraespl"."fat_guimaraespl_FaturamentoDiarizacao" f
LEFT JOIN "guimaraespl"."fat_guimaraespl_GruposdeVendedores" gv ON (f.qtd_representante::TEXT = gv.codigo_vendedor::TEXT))

UNION ALL 

SELECT 
    CAST(p."periodo" AS DATE) AS periodo
    , CAST(p."codrepresentante" AS INTEGER) AS id_representante
    , CAST(f.representante AS TEXT) AS representante
    , NULL::TEXT AS id_empresa
    , NULL::TEXT AS empresa
    , NULL::TEXT AS tipo_faturamento
    , gv.grupo_vendedores AS grupo_vendedor
    
    , CAST(p."numpedido" AS TEXT) AS numpedido
    , CAST(p."nomeabrev" AS TEXT) AS cliente
    , CAST(p."dtapreventrega" AS DATE) AS dtapreventrega

    , CAST(NULL AS DOUBLE PRECISION) AS vlr_meta_empresa

    , NULL::DOUBLE PRECISION AS qtd
    , NULL::DOUBLE PRECISION AS vlr

    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_mes
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_mes
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_ano
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_ano

	, CAST(p."vlrpedidos" AS DOUBLE PRECISION) AS vlrpedidos
	, CAST(p."qtdepedidos" AS TEXT) AS qtdepedidos

FROM "guimaraespl"."fat_guimaraespl_PedidosemAberto" p
LEFT JOIN representantes f ON (CAST(p."codrepresentante" AS INTEGER) = f.id_representante::INTEGER)
LEFT JOIN "guimaraespl"."fat_guimaraespl_GruposdeVendedores" gv ON (f.id_representante::TEXT = gv.codigo_vendedor::TEXT)