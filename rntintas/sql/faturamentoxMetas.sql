WITH lojas AS (
SELECT DISTINCT 
    CAST("codunidadeempresa" AS TEXT) AS cod,
    CAST("unidadeempresa" AS TEXT) AS loja
-- CAST("geoloja" AS TEXT) AS geoloja
FROM "rntintas"."fat_rntintas_ETLFaturamento"
), dados_cal AS (
SELECT
    c.empresa,
    d."Cod Representante",
    c.periodo AS "periodo",
    c.dia,
    c.mes,
    c.ano,
    c.feriado,
    c.sabado as "sabado",
    c.util as "util",
    --c.empresa::TEXT || '-' || d."Cod Representante" as "identifier"
    SUM(CASE WHEN c.util = 1 THEN sabado END) OVER (PARTITION BY d."Cod Representante",  c.empresa, c.mes, c.ano) as sabados,
    SUM(c.util)OVER (PARTITION BY d."Cod Representante",  c.empresa, c.mes, c.ano)   as uteis_mes
FROM rntintas."fat_rntintas_CalendarioDB" c
LEFT JOIN "rntintas"."fat_rntintas_RegistrosdeLojaseVendedores" d ON (c.empresa = CAST(d."Cod Loja" AS DOUBLE PRECISION) AND DATE_TRUNC('MONTH', c.periodo) = d."Periodo")
GROUP BY 1,2,3,4,5,6,7,8,9--,10
ORDER BY 1,2,3
), calendario AS (
SELECT
    "Cod Representante",
    empresa,
    periodo,
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
    periodo,
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
        DATE_TRUNC('MONTH', cc.periodo) as "periodo",
        cc.empresa AS "empresa",
        SUM(cc.util_novo) as "util_novo_total"
    FROM calendario_emp cc 
    GROUP BY 1,2

), uteis_do_mes_rep AS (

    SELECT 
        DATE_TRUNC('MONTH', cc.periodo) as "periodo",
        cc.empresa AS "empresa",
        "Cod Representante",
        SUM(cc.util_novo) as "util_novo_total"
    FROM calendario cc 
    GROUP BY 1,2,3

)

SELECT * FROM (
SELECT 
    CAST(f."periodo" AS DATE) AS "Periodo",
    CAST(f."periodo" AS DATE) AS "Periodo Filtro",
    CAST(f."codunidadeempresa" AS TEXT) AS "Cod Loja",
    CAST(f."unidadeempresa" AS TEXT) AS "Loja",
    -- CAST("geoloja" AS TEXT) AS "Geo Loja",
    CAST(f."codrepresentante" AS TEXT) AS "Cod Representante",
    CAST(f."representante" AS TEXT) AS "Representante",
    CAST(SUM(f."vlrimpostos") AS DOUBLE PRECISION) AS "Vlr Impostos",
    CAST(SUM(f."valorprodutos") AS DOUBLE PRECISION) AS "Vlr Produtos",
    CAST(SUM(f."vlrdesconto") AS DOUBLE PRECISION) AS "Vlr Desconto",
    CAST(SUM(f."vlrnfitem") AS DOUBLE PRECISION) AS "Vlr NF Item",
    CAST(SUM(f."cmv") AS DOUBLE PRECISION) AS "CMV",
    CAST(SUM(f."qtdeitensvendidoskg") AS DOUBLE PRECISION) AS "Qtd Itens Vendidos KG",
    CAST(SUM(f."valoresacessorios") AS DOUBLE PRECISION) AS "Vlr Acessorios",
    CAST(SUM(f."precoitem") AS DOUBLE PRECISION) AS "Preço Item",
    CAST(SUM(f."qtdetotalitem") AS DOUBLE PRECISION) AS "Qtd Total Item",
    CAST(SUM(f."vlrmercadoria") AS DOUBLE PRECISION) AS "Vlr Mercadoria",
    CAST(null AS DOUBLE PRECISION) AS "dia",
    CAST(null AS DOUBLE PRECISION) AS "mes",
    CAST(null AS DOUBLE PRECISION) AS "ano",
    CAST(null AS DOUBLE PRECISION) AS "util",
    CAST(null AS DOUBLE PRECISION) AS "Meta Loja KG",
    CAST(null AS DOUBLE PRECISION) AS "Meta Loja",
    CAST(null AS DOUBLE PRECISION) AS "Meta Loja LT",
    CAST(null AS DOUBLE PRECISION) AS "Meta Repre KG",
    CAST(null AS DOUBLE PRECISION) AS "Meta Repre",
    CAST(null AS DOUBLE PRECISION) AS "Meta Repre LT",
    CAST(null AS DOUBLE PRECISION) AS "Dias Uteis Mês",
    --CAST(null AS DOUBLE PRECISION) AS "Dias Uteis Corridos",
    CAST(COUNT(DISTINCT f."coditemcont") AS DOUBLE PRECISION) AS "Qtd Itens",
    CAST(COUNT(DISTINCT f."notafiscalcont") AS DOUBLE PRECISION) AS "Qtd NFs"
FROM "rntintas"."fat_rntintas_ETLFaturamento" f
GROUP BY 1,2,3,4,5,6
) X 
WHERE DATE_TRUNC('YEAR', CAST(X."Periodo" AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '2 YEAR'::INTERVAL

UNION ALL 

-- Source: ETL-METALOJA
SELECT 
CAST(COALESCE(c.periodo,m."periodo") AS DATE) AS "Periodo",
CAST(COALESCE(c.periodo,m."periodo") AS DATE) AS "Periodo Filtro",
CAST(m."codloja" AS TEXT) AS "Cod Loja",
CAST(m.UnidadeEmpresa AS TEXT) AS "Loja",
-- CAST(l.geoloja AS TEXT) AS "Geo Loja",
CAST(null AS TEXT) AS "Cod Representante",
CAST(null AS TEXT) AS "Representante",
CAST(null AS DOUBLE PRECISION) AS "Vlr Impostos",
CAST(null AS DOUBLE PRECISION) AS "Vlr Produtos",
CAST(null AS DOUBLE PRECISION) AS "Vlr Desconto",
CAST(null AS DOUBLE PRECISION) AS "Vlr NF Item",
CAST(null AS DOUBLE PRECISION) AS "CMV",
CAST(null AS DOUBLE PRECISION) AS "Qtd Itens Vendidos KG",
CAST(null AS DOUBLE PRECISION) AS "Vlr Acessorios",
CAST(null AS DOUBLE PRECISION) AS "Preço Item",
CAST(null AS DOUBLE PRECISION) AS "Qtd Total Item",
CAST(null AS DOUBLE PRECISION) AS "Vlr Mercadoria",
CAST(c."dia" AS DOUBLE PRECISION) AS "dia",
CAST(c."mes" AS DOUBLE PRECISION) AS "mes",
CAST(c."ano" AS DOUBLE PRECISION) AS "ano",
CAST(c."util" AS DOUBLE PRECISION) AS "util",
CAST("metavqui" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/um."util_novo_total"),1) AS "Meta Loja KG",
CAST("metavalo" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/um."util_novo_total"),1) AS "Meta Loja",
CAST("metalitr" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/um."util_novo_total"),1) AS "Meta Loja LT",
CAST(null AS DOUBLE PRECISION) AS "Meta Repre KG",
CAST(null AS DOUBLE PRECISION) AS "Meta Repre",
CAST(null AS DOUBLE PRECISION) AS "Meta Repre LT",
um."util_novo_total" as "Dias Uteis Mês",
--(SELECT SUM(cc.util) FROM calendario cc where DATE_TRUNC('MONTH', cc.periodo) = DATE_TRUNC('MONTH', c.periodo) AND cc.periodo::DATE <= NOW()::DATE AND cc.empresa = c.empresa) as "Dias Uteis Corridos",
CAST(null AS DOUBLE PRECISION) AS "Qtd Itens",
CAST(null AS DOUBLE PRECISION) AS "Qtd NFs"
FROM "rntintas"."fat_rntintas_ETLMETALOJA" m
LEFT JOIN calendario_emp c ON (m."codloja"::INTEGER = c.empresa AND DATE_TRUNC('MONTH', m."periodo") = DATE_TRUNC('MONTH', c.periodo) AND c.util > 0)
LEFT JOIN uteis_do_mes um ON (m."codloja"::INTEGER = um.empresa AND DATE_TRUNC('MONTH', m."periodo") = DATE_TRUNC('MONTH', um.periodo))
WHERE DATE_TRUNC('YEAR', CAST(COALESCE(c.periodo,m."periodo") AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '2 YEAR'::INTERVAL


UNION ALL 

-- Source: ETL-METAREPRESENTANTES
SELECT 
CAST(COALESCE(c.periodo,m."periodo") AS DATE) AS "Periodo",
CAST(COALESCE(c.periodo,m."periodo") AS DATE) AS "Periodo Filtro",
CAST(null AS TEXT) AS "Cod Loja",
CAST(null AS TEXT) AS "Loja",
-- CAST(null AS TEXT) AS "Geo Loja",
CAST("codrepresentante" AS TEXT) AS "Cod Representante",
CAST("representante" AS TEXT) AS "Representante",
CAST(null AS DOUBLE PRECISION) AS "Vlr Impostos",
CAST(null AS DOUBLE PRECISION) AS "Vlr Produtos",
CAST(null AS DOUBLE PRECISION) AS "Vlr Desconto",
CAST(null AS DOUBLE PRECISION) AS "Vlr NF Item",
CAST(null AS DOUBLE PRECISION) AS "CMV",
CAST(null AS DOUBLE PRECISION) AS "Qtd Itens Vendidos KG",
CAST(null AS DOUBLE PRECISION) AS "Vlr Acessorios",
CAST(null AS DOUBLE PRECISION) AS "Preço Item",
CAST(null AS DOUBLE PRECISION) AS "Qtd Total Item",
CAST(null AS DOUBLE PRECISION) AS "Vlr Mercadoria",
CAST("dia" AS DOUBLE PRECISION) AS "dia",
CAST("mes" AS DOUBLE PRECISION) AS "mes",
CAST("ano" AS DOUBLE PRECISION) AS "ano",
CAST("util" AS DOUBLE PRECISION) AS "util",
CAST(null AS DOUBLE PRECISION) AS "Meta Loja KG",
CAST(null AS DOUBLE PRECISION) AS "Meta Loja",
CAST(null AS DOUBLE PRECISION) AS "Meta Loja LT",
CAST("metavqui" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/ur."util_novo_total"),1) AS "Meta Repre KG",
CAST("metavalo" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/ur."util_novo_total"),1) AS "Meta Repre",
CAST("metalitr" AS DOUBLE PRECISION)*COALESCE(((c.util_novo)/ur."util_novo_total"),1) AS "Meta Repre LT",
ur."util_novo_total" as "Dias Uteis Mês",
--(SELECT SUM(cc.util) FROM calendario cc where DATE_TRUNC('MONTH', cc.periodo) = DATE_TRUNC('MONTH', c.periodo) AND cc.periodo::DATE <= NOW()::DATE AND cc."Cod Representante" = c."Cod Representante") as "Dias Uteis Corridos",
CAST(null AS DOUBLE PRECISION) AS "Qtd Itens",
CAST(null AS DOUBLE PRECISION) AS "Qtd NFs"
FROM "rntintas"."fat_rntintas_ETLMETAREPRESENTANTES" m
LEFT JOIN calendario c ON (DATE_TRUNC('MONTH', m."periodo") = DATE_TRUNC('MONTH', c.periodo) AND c.util > 0 AND c."Cod Representante" = m."codrepresentante")
LEFT JOIN uteis_do_mes_rep ur ON (DATE_TRUNC('MONTH', m."periodo") = DATE_TRUNC('MONTH', ur.periodo) AND ur."Cod Representante" = m."codrepresentante")
WHERE DATE_TRUNC('YEAR', CAST(COALESCE(c.periodo,m."periodo") AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '2 YEAR'::INTERVAL