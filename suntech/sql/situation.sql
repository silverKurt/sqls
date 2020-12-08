WITH datas AS (
	SELECT 
		TRIM(CAST("Qtde Cliente" AS TEXT)) AS "Cliente"
		, MIN(CAST("Data" AS DATE)) AS "DataPrimeiraCompra"
		, MAX(CAST("Data" AS DATE)) AS "DataUltimaCompra"
		, COUNT ("Data") AS "Frequencia"
	FROM "suntech"."fat_suntech_Faturamento"
	WHERE CAST("Tipo Operação" AS TEXT) IN ('PVN')
	GROUP BY 1
), situation AS (  
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
            TRIM(CAST("Qtde Cliente" AS TEXT)) AS "Cliente"
            , CAST("Data" AS DATE)  AS "Periodo"
            , CAST("Data Ultima Compra" AS DATE) AS "data_ultima_compra"
        FROM "suntech"."fat_suntech_Faturamento" 
        --WHERE fu."COD_CLI" = '2275'
        ORDER BY CAST("Data" AS DATE)
    ) x
  ) y
WHERE DATE_TRUNC('MONTH', y."periodo") <> DATE_TRUNC('MONTH', y."compra_anterior")
ORDER BY y."Cliente", y."periodo"
)
-- Source: Faturamento
SELECT 
	DATE_TRUNC('MONTH', CAST(F."Data" AS DATE))::DATE AS "Data",
	CAST(F."Cliente" AS TEXT) AS "Cliente",
	CAST(F."Vendedor" AS TEXT) AS "Vendedor",
	CAST(F."Tipo Operação" AS TEXT) AS "TipoOperacao",
	CAST(F."Origem" AS TEXT) AS "Origem",
	CAST(F."UF" AS TEXT) AS "UF",
	TRIM(CAST(F."Qtde Cliente" AS TEXT)) AS "QtdeCliente",
	CAST(F."Valor Final" AS DOUBLE PRECISION) AS "ValorFinal",
	CAST(F."Qtde Cupom" AS TEXT) AS "QtdeCupom",
	CAST(F."Geo" AS TEXT) AS "Geo",
    TO_CHAR(CAST(D."DataUltimaCompra" AS DATE), 'DD/MM/YYYY') AS "Data da Última Compra",
    
	CASE WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) <=  30 THEN 'R1 - Últimos 30 Dias'
         WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) <=  60 THEN 'R2 - 31 A 60 Dias'
         WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) <=  90 THEN 'R3 - 61 A 90 Dias'
         WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) >=   91 THEN 'R4 - Acima de 90 Dias'
    END AS "Faixa de Recência",

    CASE WHEN D."Frequencia" >= 12 THEN 'F1 - 12 vezes ou mais'
         WHEN D."Frequencia" >= 10 THEN 'F2 - 10 a 11 vezes'
         WHEN D."Frequencia" >=  6 THEN 'F3 - 6 a 9 vezes'
         WHEN D."Frequencia" >=  2 THEN 'F4 - 2 a 5 vezes'
         WHEN D."Frequencia" >=  1 THEN 'F5 - 1 vez'
    END AS "Faixa de Frequência", 

    CASE WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) <=  30 THEN 'Bom'
         WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) <=  60 THEN 'Razoavel'
         WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) <=  90 THEN 'Ruim'
         WHEN CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) >=   91 THEN 'Inativos'
    END AS "Faixa Dias sem Compra",
    
    CAST((NOW()::DATE - D."DataUltimaCompra"::DATE) AS DOUBLE PRECISION) AS "Dias sem Compra",
    
    S."status_cliente"


FROM "suntech"."fat_suntech_Faturamento" F
LEFT JOIN datas D ON (D."Cliente" = TRIM(CAST(F."Qtde Cliente" AS TEXT)))
INNER JOIN situation S ON (TRIM(CAST(F."Qtde Cliente" AS TEXT)) = S."Cliente" AND CAST(F."Data" AS DATE) = S."periodo")
--WHERE F."Cliente" ILIKE '%A.NET PROVEDOR DE INTERNET LTDA - 48 35241011%'
ORDER BY 2, 1 DESC