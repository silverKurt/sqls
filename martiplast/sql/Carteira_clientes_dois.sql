WITH ultimas_faturas AS (
SELECT
	CAST("Qtde Clientes" AS TEXT) AS "Cod_Cliente",
	MAX("Periodo") AS "Ultima Fatura",
    MIN("Periodo") AS "Primeira Fatura",
	SUM( CAST("Vlr Gerencial Fat" AS DOUBLE PRECISION) ) AS "Valor",
	COUNT(DISTINCT "NF Serie") AS "Qtde NF"
FROM "ou"."fat_ou_FaturamentoDiarizacao"
WHERE 
	/*CAST("Periodo" AS DATE) >= DATE_TRUNC('MONTH', NOW() - '12 MONTHS'::INTERVAL)
	AND */"Tipo Faturamento" IN ('VENDA', 'DEVOLUCAO')
GROUP BY 1

), situacao_cliente AS (
	SELECT 
  		y."Cliente"
  		, y."periodo" AS "periodo"
    	, y."compra_anterior" AS "compra_anterior"
  		, CASE WHEN "compra_anterior" = '1900-01-01' THEN 'CLIENTE NOVO'
      			WHEN (y."periodo"::DATE - "compra_anterior"::DATE) > 180 THEN 'CLIENTE RECAPTURADO'
        		WHEN y."periodo"::DATE = "ultima_compra" AND (NOW()::DATE - "ultima_compra"::DATE) > 180 THEN 'INATIVO'
        		ELSE 'ATIVO'
    	END AS "status_cliente"
	FROM (
    	SELECT DISTINCT 
      		x."Cliente"
      		,  x."Periodo" as "periodo"
        	, "data_ultima_compra" AS "ultima_compra"
      		, COALESCE(LAG(x."Periodo",1) OVER (PARTITION BY x."Cliente" ORDER BY x."Cliente", x."Periodo"), '1900-01-01') AS "compra_anterior"
    	FROM (
        	SELECT DISTINCT
            	CAST(fu."Qtde Clientes" AS TEXT) AS "Cliente"
            	, CAST(fu."Periodo" AS DATE) AS "Periodo"
            	, CAST(fu."Periodo Ultima Compra" AS DATE) AS "data_ultima_compra"
        	FROM "ou"."fat_ou_FaturamentoDiarizacao" fu
        	--WHERE fu."COD_CLI" = '2275'
        	ORDER BY CAST(fu."Periodo" AS DATE)
    	) x
  	) y
	WHERE DATE_TRUNC('MONTH', y."periodo") <> DATE_TRUNC('MONTH', y."compra_anterior")
	ORDER BY y."Cliente", y."periodo"
)

SELECT *
	, CASE WHEN ((freq."Faixa de Frequência" = 'F5 - 12 vezes ou mais' OR freq."Faixa de Frequência" = 'F4 - 10 a 11 vezes') AND (freq."Faixa de Recência" = 'R5 - Últimos 30 Dias'))
			THEN 'Clientes Campeões'
		WHEN ((freq."Faixa de Frequência" = 'F3 - 6 a 9 vezes' OR freq."Faixa de Frequência" = 'F2 - 2 a 5 vezes') AND (freq."Faixa de Recência" = 'R5 - Últimos 30 Dias' OR freq."Faixa de Recência" = 'R4 - 31 A 60 Dias'))
			THEN 'Clientes potencial de lealdade'
		WHEN ((freq."Faixa de Frequência" = 'F1 - 1 vez') AND (freq."Faixa de Recência" = 'R5 - Últimos 30 Dias')) --novos
			THEN 'Clientes Novos'
		WHEN ((freq."Faixa de Frequência" = 'F1 - 1 vez') AND (freq."Faixa de Recência" = 'R4 - 31 A 60 Dias')) --promissores
			THEN 'Clientes Promissores'
		WHEN ((freq."Faixa de Frequência" = 'F5 - 12 vezes ou mais' OR freq."Faixa de Frequência" = 'F4 - 10 a 11 vezes') AND (freq."Faixa de Recência" = 'R4 - 31 A 60 Dias' OR freq."Faixa de Recência" = 'R3 - 61 A 120 Dias'))
			THEN 'Clientes Leais'
		WHEN ((freq."Faixa de Frequência" = 'F3 - 6 a 9 vezes') AND (freq."Faixa de Recência" = 'R3 - 61 A 120 Dias')) --atenção
			THEN 'Clientes Precisam Atenção'
		WHEN ((freq."Faixa de Frequência" = 'F1 - 1 vez' OR freq."Faixa de Frequência" = 'F2 - 2 a 5 vezes') AND (freq."Faixa de Recência" = 'R3 - 61 A 120 Dias'))
			THEN 'Clientes em pré-hibernação'
		WHEN ((freq."Faixa de Frequência" = 'F1 - 1 vez' OR freq."Faixa de Frequência" = 'F2 - 2 a 5 vezes') AND (freq."Faixa de Recência" = 'R2 - 121 A 180 Dias' OR freq."Faixa de Recência" = 'R1 - 181 A 360 Dias'))
			THEN 'Clientes Hibernando'
		WHEN ((freq."Faixa de Frequência" = 'F3 - 6 a 9 vezes' OR freq."Faixa de Frequência" = 'F4 - 10 a 11 vezes') AND (freq."Faixa de Recência" = 'R2 - 121 A 180 Dias' OR freq."Faixa de Recência" = 'R1 - 181 A 360 Dias'))
			THEN 'Clientes em risco'
		WHEN ((freq."Faixa de Frequência" = 'F5 - 12 vezes ou mais') AND (freq."Faixa de Recência" = 'R2 - 121 A 180 Dias' OR freq."Faixa de Recência" = 'R1 - 181 A 360 Dias'))
			THEN 'Clientes não podemos perder'
	ELSE 'fora de faixa' END AS "Faixa de RFV"
FROM 
(SELECT 
	DATE_TRUNC('MONTH', CAST(f."Periodo" AS DATE)) AS "Periodo",
    CAST(uf."Ultima Fatura" AS DATE) AS "Período de Última Fatura",
    CAST(uf."Primeira Fatura" AS DATE) AS "Período de Primeira Fatura",

	CAST(f."Qtde Clientes" AS TEXT) AS "Qtde Clientes",
	CAST(f."Cliente" AS TEXT) AS "Cliente",
	CAST(f."Representante Carteira" AS TEXT) AS "Representante Carteira",
	CAST(f."Segmento" AS TEXT) AS "Segmento",
	CAST(f."Regiao" AS TEXT) AS "Regiao",
	CAST(f."UF" AS TEXT) AS "Estado",
	CAST(f."Municipio Cliente" AS TEXT) AS "Cidade",
	CAST(f."Responsavel" AS TEXT) AS "Responsavel",
	CAST(f."Tipo Faturamento" AS TEXT) AS "Tipo de Faturamento",
	CAST(f."Unidade de Negocio" AS TEXT) AS "Unidade de Negocio",
	CAST(f."GEO_CLIENTE" AS TEXT) AS "Geo Cliente",
    
    sc."status_cliente" AS "Status do Cliente",

	CASE
        WHEN (NOW()::DATE - uf."Ultima Fatura") <=  30 THEN 'R5 - Últimos 30 Dias'
        WHEN (NOW()::DATE - uf."Ultima Fatura") <=  60 THEN 'R4 - 31 A 60 Dias'
        WHEN (NOW()::DATE - uf."Ultima Fatura") <= 120 THEN 'R3 - 61 A 120 Dias'
        WHEN (NOW()::DATE - uf."Ultima Fatura") <= 180 THEN 'R2 - 121 A 180 Dias'
        WHEN (NOW()::DATE - uf."Ultima Fatura") <= 999 THEN 'R1 - 181 A 360 Dias'
    END AS "Faixa de Recência",

    CASE 
        WHEN uf."Qtde NF" >= 12 THEN 'F5 - 12 vezes ou mais'
        WHEN uf."Qtde NF" >= 10 THEN 'F4 - 10 a 11 vezes'
        WHEN uf."Qtde NF" >=  6 THEN 'F3 - 6 a 9 vezes'
        WHEN uf."Qtde NF" >=  2 THEN 'F2 - 2 a 5 vezes'
        WHEN uf."Qtde NF" >=  1 THEN 'F1 - 1 vez'
    END AS "Faixa de Frequência",

    CASE 
        WHEN uf."Valor" >= 1000000 THEN 'M1 - 1 Milhão ou mais'
        WHEN uf."Valor" >=  500000 THEN 'M2 - 500 mil a 999 mil'
        WHEN uf."Valor" >=  250000 THEN 'M3 - 250 Mil a 499 mil'
        WHEN uf."Valor" >=  100000 THEN 'M4 - 100 mil a 249 mil'
        WHEN uf."Valor" >=       0 THEN 'M5 - 99 mil ou menos'
    END AS "Faixa Monetaria",

	SUM( CAST(f."Vlr Gerencial Fat" AS DOUBLE PRECISION) ) AS "Vlr Gerencial Fat",
	SUM( CAST(f."Qtde Pecas" AS DOUBLE PRECISION) ) AS "Qtde Pecas",
	SUM( CAST(f."Qtde Cxs" AS DOUBLE PRECISION) ) AS "Qtde Cxs"

FROM 
	"ou"."fat_ou_FaturamentoDiarizacao" f
INNER JOIN ultimas_faturas uf ON (f."Qtde Clientes" = uf."Cod_Cliente")
LEFT JOIN situacao_cliente sc ON (DATE_TRUNC('MONTH', CAST(f."Periodo" AS DATE)) = DATE_TRUNC('MONTH', sc."periodo") AND CAST(f."Qtde Clientes" AS TEXT) = CAST(sc."Cliente" AS TEXT))
WHERE 
	/*CAST(f."Periodo" AS DATE) >= DATE_TRUNC('MONTH', NOW() - '12 MONTHS'::INTERVAL)
	AND */f."Tipo Faturamento" IN ('VENDA', 'DEVOLUCAO')
GROUP BY
	DATE_TRUNC('MONTH', CAST(f."Periodo" AS DATE))
	, CAST(uf."Ultima Fatura" AS DATE)
    , CAST(uf."Primeira Fatura" AS DATE)
	, CAST(f."Qtde Clientes" AS TEXT)
	, CAST(f."Cliente" AS TEXT)
	, CAST(f."Representante Carteira" AS TEXT)
	, CAST(f."Segmento" AS TEXT)
	, CAST(f."Regiao" AS TEXT)
	, CAST(f."UF" AS TEXT)
	, CAST(f."Municipio Cliente" AS TEXT)
	, CAST(f."Responsavel" AS TEXT)
	, CAST(f."Tipo Faturamento" AS TEXT)
	, CAST(f."Unidade de Negocio" AS TEXT)
	, CAST(f."GEO_CLIENTE" AS TEXT)
    , sc."status_cliente"
	, uf."Qtde NF"
	, uf."Valor"
) freq