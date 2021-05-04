WITH lojas AS (
SELECT DISTINCT 
    CAST("cod_empresa" AS TEXT) AS cod_empresa,
    CAST("empresa" AS TEXT) AS empresa
-- CAST("geoloja" AS TEXT) AS geoloja
FROM "rntintasng"."fat_rntintasng_FaturamentoBase"
), dados_cal AS (
SELECT
    c.empresa,
    d."cod_vendedor",
    c.periodo AS "data",
    c.dia,
    c.mes,
    c.ano,
    c.feriado,
    c.sabado as "sabado",
    c.util as "util",
    --c.empresa::TEXT || '-' || d."Cod Representante" as "identifier"
    SUM(CASE WHEN c.util = 1 THEN sabado END) OVER (PARTITION BY d."cod_vendedor",  c.empresa, c.mes, c.ano) as sabados,
    SUM(c.util)OVER (PARTITION BY d."cod_vendedor",  c.empresa, c.mes, c.ano)   as uteis_mes
FROM "rntintasng"."fat_rntintasng_CalendarioComercialBase" c
LEFT JOIN "rntintasng"."fat_rntintasng_RegistrosdeVendedoreseLojas" d ON (c.empresa = CAST(d."cod_empresa" AS DOUBLE PRECISION) AND DATE_TRUNC('MONTH', c.periodo) = d."data")
GROUP BY 1,2,3,4,5,6,7,8,9--,10
ORDER BY 1,2,3
), calendario AS (
SELECT
    "cod_vendedor",
    empresa,
    data,
    dia,
    mes,
    ano,
    util,
    CASE
        WHEN (dia = 24 OR dia = 31) AND mes = 12 THEN 0.5
        WHEN sabado = 1 AND util = 1 THEN 0.5
        WHEN util = 1 THEN util::DOUBLE PRECISION 
        ELSE 0
    END as util_novo
FROM dados_cal
), calendario_emp AS (
SELECT DISTINCT 
    --"Cod Representante",
    empresa,
    data,
    dia,
    mes,
    ano,
    util,
    CASE
        WHEN (dia = 24 OR dia = 31) AND mes = 12 THEN 0.5
        WHEN sabado = 1 AND util = 1 THEN 0.5
        WHEN util = 1 THEN util::DOUBLE PRECISION 
        ELSE 0
    END as util_novo
FROM dados_cal
), uteis_do_mes AS (

    SELECT 
        DATE_TRUNC('MONTH', cc.data) as "data",
        cc.empresa AS "empresa",
        SUM(cc.util_novo) as "util_novo_total"
    FROM calendario_emp cc 
    GROUP BY 1,2

), uteis_do_mes_rep AS (

    SELECT 
        DATE_TRUNC('MONTH', cc.data) as "data",
        cc.empresa AS "empresa",
        "cod_vendedor",
        SUM(cc.util_novo) as "util_novo_total"
    FROM calendario cc 
    GROUP BY 1,2,3

)

SELECT * FROM (
SELECT 
    CAST(f."data" AS DATE) AS "data",
    CAST(f."cod_empresa" AS TEXT) AS "cod_empresa",
    CAST(f."empresa" AS TEXT) AS "empresa",
    -- CAST("geoloja" AS TEXT) AS "Geo Loja",
    CAST(f."cod_vendedor" AS TEXT) AS "cod_vendedor",
    CAST(f."vendedor" AS TEXT) AS "vendedor",
    CAST(SUM(f."vlr_impostos") AS DOUBLE PRECISION) AS "vlr_impostos",
    CAST(SUM(f."faturamento") AS DOUBLE PRECISION) AS "faturamento",
    CAST(SUM(f."vlr_desconto") AS DOUBLE PRECISION) AS "vlr_desconto",
    CAST(SUM(f."cmv") AS DOUBLE PRECISION) AS "cmv",
    CAST(SUM(f."valor_custo_fixo") AS DOUBLE PRECISION) AS "valor_custo_fixo",
    CAST(null AS DOUBLE PRECISION) AS "dia",
    CAST(null AS DOUBLE PRECISION) AS "mes",
    CAST(null AS DOUBLE PRECISION) AS "ano",
    CAST(null AS DOUBLE PRECISION) AS "util",
    CAST(null AS DOUBLE PRECISION) AS "meta_loja",
    CAST(null AS DOUBLE PRECISION) AS "litragem_meta_loja",
    CAST(null AS DOUBLE PRECISION) AS "meta_repre",
    CAST(null AS DOUBLE PRECISION) AS "litragem_meta_repre",
    CAST(null AS DOUBLE PRECISION) AS "Dias Uteis Mês",
    --CAST(null AS DOUBLE PRECISION) AS "Dias Uteis Corridos",
    CAST(COUNT(DISTINCT f."cod_produto") AS DOUBLE PRECISION) AS "cod_produto",
    CAST(COUNT(DISTINCT f."qtde_notas") AS DOUBLE PRECISION) AS "qtde_notas"
FROM "rntintasng"."fat_rntintasng_FaturamentoBase" f
  WHERE CAST(f."natureza" AS TEXT) IN ('DEV. SIMPLES FATURAMENTO', 'DEV.VENDA MERC.AD.RECEB.TERC.','SIMPLES FATURAMENTO', 'VENDA MERC.REC.TERC.')
GROUP BY 1,2,3,4,5
) X 
WHERE CAST(X."data" AS DATE) >= (DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)

UNION ALL 

SELECT 
CAST(COALESCE(c.data,m."data") AS DATE) AS "data",
CAST(m."cod_empresa" AS TEXT) AS "cod_empresa",
CAST(m.empresa AS TEXT) AS "empresa",
-- CAST(l.geoloja AS TEXT) AS "Geo Loja",
CAST(null AS TEXT) AS "cod_vendedor",
CAST(null AS TEXT) AS "vendedor",
CAST(null AS DOUBLE PRECISION) AS "vlr_impostos",
CAST(null AS DOUBLE PRECISION) AS "faturamento",
CAST(null AS DOUBLE PRECISION) AS "vlr_desconto",
CAST(null AS DOUBLE PRECISION) AS "cmv",
CAST(null AS DOUBLE PRECISION) AS "valor_custo_fixo",
CAST(c."dia" AS DOUBLE PRECISION) AS "dia",
CAST(c."mes" AS DOUBLE PRECISION) AS "mes",
CAST(c."ano" AS DOUBLE PRECISION) AS "ano",
CAST(c."util" AS DOUBLE PRECISION) AS "util",
CAST("meta" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/um."util_novo_total"),1) AS "meta_loja",
CAST("litragem_meta" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/um."util_novo_total"),1) AS "litragem_meta_loja",
CAST(null AS DOUBLE PRECISION) AS "meta_repre",
CAST(null AS DOUBLE PRECISION) AS "litragem_meta_repre",
um."util_novo_total" as "Dias Uteis Mês",
--(SELECT SUM(cc.util) FROM calendario cc where DATE_TRUNC('MONTH', cc.periodo) = DATE_TRUNC('MONTH', c.periodo) AND cc.periodo::DATE <= NOW()::DATE AND cc.empresa = c.empresa) as "Dias Uteis Corridos",
CAST(null AS DOUBLE PRECISION) AS "cod_produto",
CAST(null AS DOUBLE PRECISION) AS "qtde_notas"
FROM "rntintasng"."fat_rntintasng_MetadeLojas" m
LEFT JOIN calendario_emp c ON (m."cod_empresa"::INTEGER = c.empresa AND DATE_TRUNC('MONTH', m."data") = DATE_TRUNC('MONTH', c.data) AND c.util > 0)
LEFT JOIN uteis_do_mes um ON (m."cod_empresa"::INTEGER = um.empresa AND DATE_TRUNC('MONTH', m."data") = DATE_TRUNC('MONTH', um.data))
WHERE CAST(COALESCE(c.data,m."data") AS DATE) >= (DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)


UNION ALL 

-- Source: ETL-METAREPRESENTANTES
SELECT 
CAST(COALESCE(c.data,m."data") AS DATE) AS "data",
CAST(null AS TEXT) AS "cod_empresa",
CAST(null AS TEXT) AS "empresa",
-- CAST(null AS TEXT) AS "Geo Loja",
CAST(m."cod_vendedor" AS TEXT) AS "cod_vendedor",
CAST("vendedor" AS TEXT) AS "vendedor",
CAST(null AS DOUBLE PRECISION) AS "vlr_impostos",
CAST(null AS DOUBLE PRECISION) AS "faturamento",
CAST(null AS DOUBLE PRECISION) AS "vlr_desconto",
CAST(null AS DOUBLE PRECISION) AS "cmv",
CAST(null AS DOUBLE PRECISION) AS "valor_custo_fixo",
CAST("dia" AS DOUBLE PRECISION) AS "dia",
CAST("mes" AS DOUBLE PRECISION) AS "mes",
CAST("ano" AS DOUBLE PRECISION) AS "ano",
CAST("util" AS DOUBLE PRECISION) AS "util",
CAST(null AS DOUBLE PRECISION) AS "meta_loja",
CAST(null AS DOUBLE PRECISION) AS "litragem_meta_loja",
CAST("meta" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/ur."util_novo_total"),1) AS "meta_repre",
CAST("litragem_meta" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/ur."util_novo_total"),1) AS "litragem_meta_repre",
ur."util_novo_total" as "Dias Uteis Mês",
--(SELECT SUM(cc.util) FROM calendario cc where DATE_TRUNC('MONTH', cc.periodo) = DATE_TRUNC('MONTH', c.periodo) AND cc.periodo::DATE <= NOW()::DATE AND cc."Cod Representante" = c."Cod Representante") as "Dias Uteis Corridos",
CAST(null AS DOUBLE PRECISION) AS "cod_produto",
CAST(null AS DOUBLE PRECISION) AS "qtde_notas"
FROM "rntintasng"."fat_rntintasng_MetadeVendedoresBase" m
LEFT JOIN calendario c ON (DATE_TRUNC('MONTH', m."data") = DATE_TRUNC('MONTH', c.data) AND c.util > 0 AND c."cod_vendedor" = m."cod_vendedor")
LEFT JOIN uteis_do_mes_rep ur ON (DATE_TRUNC('MONTH', m."data") = DATE_TRUNC('MONTH', ur.data) AND ur."cod_vendedor" = m."cod_vendedor")
WHERE CAST(COALESCE(c.data,m."data") AS DATE) >= (DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)