WITH repres AS (
    SELECT DISTINCT ON (DATE_TRUNC('MONTH', CAST("periodo" AS DATE)), CAST("codrepresentante" AS TEXT))
        DATE_TRUNC('MONTH', CAST("periodo" AS DATE)) AS "Periodo",
        CAST("codrepresentante" AS TEXT) AS "Cod Representante",
        CAST("codunidadeempresa" AS TEXT) AS "Cod Loja",
        CAST(SUM("valorprodutos") AS DOUBLE PRECISION) AS "Vlr Produtos"
    FROM "rntintas"."fat_rntintas_ETLFaturamento"
    WHERE "periodo" >= '2017-01-01'::DATE AND "periodo" <= now()::DATE
    GROUP BY 1,2,3
    ORDER BY 1,2,4 DESC
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
LEFT JOIN repres d ON (c.empresa = CAST(d."Cod Loja" AS DOUBLE PRECISION) AND DATE_TRUNC('MONTH', c.periodo) = d."Periodo")
GROUP BY 1,2,3,4,5,6,7,8,9--,10
ORDER BY 1,2,3
), calendario AS (
SELECT
    "Cod Representante",
    empresa,
    DATE_TRUNC('MONTH', periodo) AS periodo,
    SUM(CASE
  		WHEN (dia = 24 OR dia = 31) AND mes = 12 THEN 0.5
        WHEN sabado = 1 AND util = 1 THEN 0.5
        WHEN util = 1 THEN util::DOUBLE PRECISION 
        ELSE 0
    END) as util_novo
FROM dados_cal
GROUP BY 1,2,3
)

SELECT c.*,
      CAST(f."unidadeempresa" AS TEXT) AS "unidadeempresa",
      CAST(f."representante" AS TEXT) AS "representante",
      CAST(SUM(f."valorprodutos") AS DOUBLE PRECISION) AS "Vlr Produtos",
      CAST(COUNT( DISTINCT f."coditemcont" ) AS DOUBLE PRECISION) AS "Qtde de Itens",
      CAST(COUNT( DISTINCT f."notafiscalcont" ) AS DOUBLE PRECISION) AS "Qtde de NFs",
      CAST(SUM(f."vlrdesconto") AS DOUBLE PRECISION) AS "Vlr Desconto",
      CAST(SUM(m."metavalo") AS DOUBLE PRECISION) AS "Vlr Meta"
FROM calendario c
LEFT JOIN "rntintas"."fat_rntintas_ETLFaturamento" f ON (c.empresa::TEXT = CAST(f."codunidadeempresa" AS TEXT) AND CAST(f."codrepresentante" AS TEXT) = c."Cod Representante"::TEXT AND c.periodo = DATE_TRUNC('MONTH', CAST(f."periodo" AS DATE)))
LEFT JOIN "rntintas"."fat_rntintas_ETLMETAREPRESENTANTES" m ON (c.periodo = CAST(m."periodo" AS DATE) AND CAST(m."codrepresentante" AS TEXT) = c."Cod Representante"::TEXT)
GROUP BY 1,2,3,4,5,6