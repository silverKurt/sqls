
SELECT * 
FROM crosstab('WITH FATURAMENTO_MES AS (
 SELECT DISTINCT 
      DATE_TRUNC(''MONTH'', fat."Periodo")::DATE AS "Periodo"
      , CAST(fat."Representante Carteira" AS TEXT)
      , CAST(fat."Regiao" AS TEXT)
      , CAST(fat."Unidade de Negocio" AS TEXT)
      , CAST(fat."Tipo Faturamento" AS TEXT)
      , SUM(CAST("Vlr Gerencial Fat" AS DOUBLE PRECISION))::DOUBLE PRECISION AS "VlrGerencialFat"
  FROM "ou"."fat_ou_FaturamentoDiarizacao" fat
  WHERE CAST(fat."Tipo Faturamento" AS TEXT) IN (''VENDA'', ''DEVOLUCAO'')
  GROUP BY 1,2,3,4,5
  ORDER BY 1,2) 
SELECT * FROM FATURAMENTO_MES', '
WITH FATURAMENTO_MES AS (
 SELECT DISTINCT 
      DATE_TRUNC(''MONTH'', fat."Periodo")::DATE AS "Periodo"
      , CAST(fat."Representante Carteira" AS TEXT)
      , CAST(fat."Regiao" AS TEXT)
      , CAST(fat."Unidade de Negocio" AS TEXT)
      , CAST(fat."Tipo Faturamento" AS TEXT)
      , SUM(CAST("Vlr Gerencial Fat" AS DOUBLE PRECISION))::DOUBLE PRECISION AS "VlrGerencialFat"
  FROM "ou"."fat_ou_FaturamentoDiarizacao" fat
  WHERE CAST(fat."Tipo Faturamento" AS TEXT) IN (''VENDA'', ''DEVOLUCAO'')
  GROUP BY 1,2,3,4,5
  ORDER BY 1,2)
SELECT DISTINCT "Tipo Faturamento" FROM FATURAMENTO_MES ORDER BY 1')
              AS ("Periodo" TIMESTAMP
                  , "Representante Carteira" VARCHAR(500)
                  , "Regiao" VARCHAR(255)
                  , "Unidade de Negocio" VARCHAR(255)
                  , "DEVOLUCAO" DOUBLE PRECISION
                  , "VENDA" DOUBLE PRECISION
                 )