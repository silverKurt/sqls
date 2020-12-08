WITH empresas AS (
-- Source: Faturamento Diarizacao
SELECT DISTINCT
    CAST("id_empresa" AS TEXT) AS id_empresa,
    CAST("empresa" AS TEXT) AS empresa
FROM "guimaraespl"."fat_guimaraespl_FaturamentoDiarizacao"

)

(SELECT  
    CAST(m.id_representante AS INTEGER) AS id_representante
    , m.representante
    , COALESCE(m.id_empresa, p.id_empresa) AS id_empresa
    , COALESCE(m.empresa, emp.empresa) AS empresa
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN 'VENDA' ELSE NULL END AS tipo_faturamento
    , p.periodo AS periodo
    , (CASE WHEN DATE_PART('DAY', p.periodo) < 21 THEN DATE_TRUNC('MONTH', p.periodo) ELSE DATE_TRUNC('MONTH', p.periodo) + '1 MONTH'::INTERVAL END) AS periodo_meta

    , m.vlr_meta / (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) AS vlr_meta 
    --, m.kg_meta / (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) AS kg_meta
    --, m.lt_meta/ (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) AS lt_meta
    , CAST(NULL AS DOUBLE PRECISION) AS qtd
    --, CAST(NULL AS DOUBLE PRECISION) AS qtd_lt
    --, CAST(NULL AS DOUBLE PRECISION) AS qtd_kg
    , CAST(NULL AS DOUBLE PRECISION) AS vlr

    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_mes
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.periodo) = DATE_TRUNC('MONTH', p.periodo) AND pi.periodo <= NOW()::DATE AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_corridos_mes
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('YEAR', pi.periodo) = DATE_TRUNC('YEAR', p.periodo) AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_ano
    , CASE WHEN COALESCE(m.vlr_meta, 0) > 0 THEN (SELECT SUM(pi.util) FROM "guimaraespl"."fat_guimaraespl_CalendarioComercial" pi WHERE DATE_TRUNC('YEAR', pi.periodo) = DATE_TRUNC('YEAR', p.periodo) AND pi.periodo <= NOW()::DATE AND pi.id_empresa::INTEGER = p.id_empresa::INTEGER) ELSE NULL END as dias_uteis_corridos_ano
FROM "guimaraespl"."fat_guimaraespl_Meta" m
LEFT JOIN "guimaraespl"."fat_guimaraespl_CalendarioComercial" p ON (DATE_TRUNC('MONTH', m.periodo) = DATE_TRUNC('MONTH', p.periodo) AND m.id_empresa = p.id_empresa AND p.util::INTEGER = 1)
LEFT JOIN empresas emp ON (p.id_empresa = emp.id_empresa))

UNION ALL

(SELECT
    CAST(qtd_representante AS INTEGER) AS id_representante
    , representante
    , id_empresa
    , empresa
    , tipo_faturamento
    , periodo AS periodo
    , periodo_meta::DATE AS periodo_meta

    , CAST(NULL AS DOUBLE PRECISION) AS vlr_meta
    --, CAST(NULL AS DOUBLE PRECISION) AS kg_meta
    --, CAST(NULL AS DOUBLE PRECISION) AS lt_meta
    , qtd
    --, qtd_lt
    --, qtd_kg
    , vlr_total_fatura as vlr

    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_mes
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_mes
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_ano
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_ano
FROM "guimaraespl"."fat_guimaraespl_FaturamentoDiarizacao")