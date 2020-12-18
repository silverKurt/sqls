WITH REPRESENTANTES AS (
  
  SELECT DISTINCT CAST(fat."Representante Carteira" AS TEXT), CAST(fat."Regiao" AS TEXT), CAST(fat."Unidade de Negocio" AS TEXT) FROM "ou"."fat_ou_FaturamentoDiarizacao" fat
  
  
), PERIODOS AS (

  SELECT DATE_TRUNC('DAY', dd)::DATE AS "Periodo"
  FROM GENERATE_SERIES
        (NOW()::TIMESTAMP
        , (SELECT MIN(fat."Periodo")::DATE FROM "ou"."fat_ou_FaturamentoDiarizacao" fat)::TIMESTAMP
        , '- 180 DAYS'::INTERVAL) dd

), CRUZAMENTO AS (
  
  SELECT * FROM REPRESENTANTES CROSS JOIN PERIODOS-- ORDER BY 1,2,3,4
  
),  DADOS AS (-- tabela temporária para pegar datas de primeira e ultima compra
    SELECT DISTINCT 
      fat."Qtde Clientes" as id_cliente
      , MIN(fat."Periodo")::DATE as "Data Primeira Compra"
    FROM "ou"."fat_ou_FaturamentoDiarizacao" fat
    WHERE fat."Qtde Clientes" <> ' '
    GROUP BY 1
), PERIODOS_MES AS (

  SELECT DISTINCT DATE_TRUNC('MONTH', "Periodo")::DATE AS "Periodo" FROM "ou"."fat_ou_FaturamentoDiarizacao"

), CRUZAMENTO_MES AS (
  
  SELECT * FROM REPRESENTANTES CROSS JOIN PERIODOS_MES-- ORDER BY 1,2,3,4
  
)/*, FATURAMENTO_MES AS (

  WITH DEVOLUCAO_MES AS (
  SELECT DISTINCT 
      fat."Periodo"::DATE AS "Periodo"
      , fat."Representante Carteira"::VARCHAR(500)
      , fat."Regiao"::VARCHAR(500)
      , fat."Unidade de Negocio"::VARCHAR(500)
      --, fat."Tipo Faturamento"::VARCHAR(500)
      , SUM(CAST("Vlr Gerencial Fat" AS DOUBLE PRECISION))::DOUBLE PRECISION AS "Vlr de Devolucao"
  FROM "ou"."fat_ou_FaturamentoDiarizacao" fat
  WHERE CAST(fat."Tipo Faturamento" AS TEXT) IN ('DEVOLUCAO')
  GROUP BY 1,2,3,4
  ORDER BY 1,2
), FATURAMENTO_MES AS (
  SELECT DISTINCT 
      fat."Periodo"::DATE AS "Periodo"
      , fat."Representante Carteira"::VARCHAR(500)
      , fat."Regiao"::VARCHAR(500)
      , fat."Unidade de Negocio"::VARCHAR(500)
      --, fat."Tipo Faturamento"::VARCHAR(500)
      , SUM(CAST("Vlr Gerencial Fat" AS DOUBLE PRECISION))::DOUBLE PRECISION AS "Vlr de Venda"
  FROM "ou"."fat_ou_FaturamentoDiarizacao" fat
  WHERE CAST(fat."Tipo Faturamento" AS TEXT) IN ('VENDA')
  GROUP BY 1,2,3,4
  ORDER BY 1,2
)
  SELECT X.*
      , X."Vlr de Venda" - Y."Vlr de Devolucao" AS "Venda - Devolucao" 
  FROM FATURAMENTO_MES X
  INNER JOIN DEVOLUCAO_MES Y ON (X."Periodo" = Y."Periodo" AND X."Representante Carteira" = Y."Representante Carteira" AND X."Regiao" = Y."Regiao" AND X."Unidade de Negocio" = Y."Unidade de Negocio")
)*/

   SELECT
        "Cod_Representante_Carteira"
        , "Regiao"
        , "Unidade_de_Negocio"
        , "Mês"
        , "Mês" AS "MesDois"
        , CASE WHEN CAST(LAG("Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês") + '180 DAYS'::INTERVAL AS DATE) = "Mês" THEN
            COALESCE((LAG("Final do Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês")), 0::BIGINT)
            ELSE 0
        END AS "Início do Mês"
        , CASE WHEN CAST(LAG("Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês") + '180 DAYS'::INTERVAL AS DATE) = "Mês" THEN
            COALESCE((LAG("Final do Mês - Vlr", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês")), 0::BIGINT)
            ELSE 0
        END AS "Início do Mês Vlr"
        , "Final do Mês - Vlr" AS "Final do Mês Vlr" 
        , "Clientes Novos - Vlr" AS "Clientes Novos Vlr"
        --, CAST(LAG("Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês") + '1 MONTH'::INTERVAL AS DATE) AS "Mês Atual"
    --, COALESCE((LAG("Final do Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês")), 0::BIGINT) AS "Início do Mês"
      , "Clientes Novos"
      , "Final do Mês"
      , 'INTERVALO DE 180 DIAS' AS "Analisar"
  FROM (
    SELECT "Mês"
        , "Cod_Representante_Carteira"
        , "Regiao"
        , "Unidade_de_Negocio"
        , COUNT(distinct case when "Classification" = 'CLIENTE NOVO' then X."Qtde Clientes" else null end) AS "Clientes Novos"
        , COUNT(DISTINCT X."Qtde Clientes") AS "Final do Mês"
        , SUM("Vlr Venda" - "Vlr Devolucao") AS "Final do Mês - Vlr"
        , SUM(CASE WHEN "Classification" = 'CLIENTE NOVO' then "Vlr Venda" - "Vlr Devolucao" ELSE NULL END) AS "Clientes Novos - Vlr"
    FROM (
          SELECT DISTINCT
            CR."Periodo"::DATE AS "Mês"
            , CAST(CR."Representante Carteira" AS TEXT) AS "Cod_Representante_Carteira"
            , CAST(CR."Regiao" AS TEXT) AS "Regiao"
            , CAST(CR."Unidade de Negocio" AS TEXT) AS "Unidade_de_Negocio"
            , fat."Qtde Clientes"
            , COALESCE(SUM(CASE WHEN CAST(fat."Tipo Faturamento" AS TEXT) IN ('VENDA') THEN "Vlr Gerencial Fat" ELSE NULL END), 0) AS "Vlr Venda"
            , COALESCE(SUM(CASE WHEN CAST(fat."Tipo Faturamento" AS TEXT) IN ('DEVOLUCAO') THEN "Vlr Gerencial Fat" ELSE NULL END), 0) AS "Vlr Devolucao"
            , CASE WHEN MIN(fat."Periodo")::DATE = D."Data Primeira Compra" THEN 'CLIENTE NOVO' ELSE 'CLIENTE' END AS "Classification"
          FROM CRUZAMENTO CR
          LEFT JOIN "ou"."fat_ou_FaturamentoDiarizacao" fat ON ((fat."Periodo"::DATE >= (CR."Periodo" - '180 DAYS'::INTERVAL)::DATE AND fat."Periodo"::DATE <= CR."Periodo") AND CR."Representante Carteira" = fat."Representante Carteira" AND CR."Regiao" = fat."Regiao" AND CR."Unidade de Negocio" = fat."Unidade de Negocio")
          LEFT JOIN DADOS D ON (D.id_cliente = fat."Qtde Clientes")
          --LEFT JOIN FATURAMENTO_MES FM ON ((FM."Periodo"::DATE >= (CR."Periodo" - '180 DAYS'::INTERVAL)::DATE AND FM."Periodo"::DATE <= CR."Periodo") AND CR."Representante Carteira" = FM."Representante Carteira" AND CR."Regiao" = FM."Regiao" AND CR."Unidade de Negocio" = FM."Unidade de Negocio")
          --WHERE CAST(CR."Representante Carteira" AS TEXT) ILIKE '%AVON%'
          GROUP BY CR."Periodo", CAST(CR."Representante Carteira" AS TEXT), CAST(CR."Regiao" AS TEXT), CAST(CR."Unidade de Negocio" AS TEXT), D."Data Primeira Compra", fat."Qtde Clientes"
          ORDER BY 1 DESC
    ) X --WHERE "Cod_Representante_Carteira" ILIKE '%AVON%' --AND "Mês" BETWEEN '2020-01-01' AND '2020-12-31'
    GROUP BY 1,2,3,4
    --ORDER BY 2,1,3,4
  ) Y

  UNION ALL

    SELECT
        "Cod_Representante_Carteira"
        , "Regiao"
        , "Unidade_de_Negocio"
        , "Mês"
        , "Mês" AS "MesDois"
        , CASE WHEN CAST(LAG("Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês") + '1 MONTH'::INTERVAL AS DATE) = "Mês" THEN
            COALESCE((LAG("Final do Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês")), 0::BIGINT)
            ELSE 0
        END AS "Início do Mês"
        , CASE WHEN CAST(LAG("Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês") + '1 MONTH'::INTERVAL AS DATE) = "Mês" THEN
            COALESCE((LAG("Final do Mês - Vlr", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês")), 0::BIGINT)
            ELSE 0
        END AS "Início do Mês Vlr"
        , "Final do Mês - Vlr" AS "Final do Mês Vlr" 
        , "Clientes Novos - Vlr" AS "Clientes Novos Vlr"
        --, CAST(LAG("Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês") + '1 MONTH'::INTERVAL AS DATE) AS "Mês Atual"
    --, COALESCE((LAG("Final do Mês", 1) OVER (PARTITION BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio" ORDER BY "Cod_Representante_Carteira", "Regiao", "Unidade_de_Negocio", "Mês")), 0::BIGINT) AS "Início do Mês"
      , "Clientes Novos"
      , "Final do Mês"
      , 'INTERVALO DE MÊS A MÊS' AS "Analisar"
  FROM (
    SELECT "Mês"
        , "Cod_Representante_Carteira"
        , "Regiao"
        , "Unidade_de_Negocio"
        , COUNT(distinct case when "Classification" = 'CLIENTE NOVO' then X."Qtde Clientes" else null end) AS "Clientes Novos"
        , COUNT(DISTINCT X."Qtde Clientes") AS "Final do Mês"
        , SUM(COALESCE("Vlr Venda", 0) - COALESCE("Vlr Devolucao", 0)) AS "Final do Mês - Vlr"
        , SUM(CASE WHEN "Classification" = 'CLIENTE NOVO' THEN COALESCE("Vlr Venda", 0) - COALESCE("Vlr Devolucao", 0) ELSE NULL END) AS "Clientes Novos - Vlr"
    FROM (
      SELECT DISTINCT
        DATE_TRUNC('MONTH', CR."Periodo")::DATE AS "Mês"
        , CAST(CR."Representante Carteira" AS TEXT) AS "Cod_Representante_Carteira"
        , CAST(CR."Regiao" AS TEXT) AS "Regiao"
        , CAST(CR."Unidade de Negocio" AS TEXT) AS "Unidade_de_Negocio"
        , fat."Qtde Clientes"
        , CASE WHEN CAST(fat."Tipo Faturamento" AS TEXT) IN ('VENDA') THEN "Vlr Gerencial Fat" ELSE NULL END AS "Vlr Venda"
        , CASE WHEN CAST(fat."Tipo Faturamento" AS TEXT) IN ('DEVOLUCAO') THEN "Vlr Gerencial Fat" ELSE NULL END AS "Vlr Devolucao"
        , CASE WHEN fat."Periodo"::DATE = D."Data Primeira Compra" THEN 'CLIENTE NOVO' ELSE 'CLIENTE' END AS "Classification"
      FROM CRUZAMENTO_MES CR
      LEFT JOIN "ou"."fat_ou_FaturamentoDiarizacao" fat ON (CR."Periodo" = DATE_TRUNC('MONTH', fat."Periodo")::DATE AND CR."Representante Carteira" = fat."Representante Carteira" AND CR."Regiao" = fat."Regiao" AND CR."Unidade de Negocio" = fat."Unidade de Negocio")
      LEFT JOIN DADOS D ON (D.id_cliente = fat."Qtde Clientes")
      --LEFT JOIN FATURAMENTO_MES FM ON (CR."Periodo" = DATE_TRUNC('MONTH', FM."Periodo") AND CR."Representante Carteira" = FM."Representante Carteira" AND CR."Regiao" = FM."Regiao" AND CR."Unidade de Negocio" = FM."Unidade de Negocio")
      --WHERE fat."Qtde Clientes" <> ' '
      ORDER BY 1 DESC
    ) X --WHERE "Cod_Representante_Carteira" ILIKE '%AVON%' AND "Mês" BETWEEN '2020-01-01' AND '2020-12-31'
    GROUP BY 1,2,3,4
    --ORDER BY 2,1,3,4
  ) Y

  /*
  
  SELECT 
	  CAST("Vlr Gerencial Fat" AS DOUBLE PRECISION) AS "VlrGerencialFat"
  FROM "ou"."fat_ou_FaturamentoDiarizacao"
  
  
  */