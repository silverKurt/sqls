WITH linha_do_tempo AS (
/*Unificamos as linhas do tempo de Contas a Pagar, Receber, Saldos Bancários e Previsão de receita para analisarmos o fluxo por dia.*/
    SELECT DISTINCT * FROM (
        /*Linha do tempo do Saldo Bancário*/
        SELECT CAST(NOW() AS DATE) as "data"

        UNION ALL
        
        SELECT 
        	CAST("data_vencimento" AS DATE) AS "data"
        FROM "dadosparaapp"."fat_dadosparaapp_contasapagar"
        WHERE UPPER(CAST("situacao_baixa" AS TEXT)) IN ('ABERTO', 'BAIXADO PARCIAL')
        AND CAST("data_vencimento" AS DATE) >= NOW()::DATE
        
        UNION ALL
        
        SELECT 
        	CAST("data_vencimento" AS DATE) AS "data"
        FROM "dadosparaapp"."fat_dadosparaapp_contasareceber"
        WHERE UPPER(CAST("situacao_baixa" AS TEXT)) IN ('ABERTO', 'BAIXADO PARCIAL')
        AND CAST("data_vencimento" AS DATE) >= NOW()::DATE
        
        UNION ALL
        
        SELECT 
        	CAST("data" AS DATE) AS "data"
        FROM "dadosparaapp"."fat_dadosparaapp_previsaodereceitasbase"
        WHERE CAST("data" AS DATE) >= NOW()::DATE
    ) unification
), ultimo_saldo_bancario AS (

  -- Source: saldos_bancarios
  SELECT 
	  NOW()::DATE AS "data"
    , SUM(saldo::DOUBLE PRECISION) AS "saldo"
  FROM "dadosparaapp"."fat_dadosparaapp_saldosbancariosbase"
  WHERE data::DATE = (SELECT MAX(data::DATE) FROM "dadosparaapp"."fat_dadosparaapp_saldosbancariosbase")

)
SELECT "data"
		, CASE WHEN linha = 1 THEN "saldo_inicial" ELSE "total_linha" END AS "saldo_corrente"
        , CASE WHEN "contas_a_pagar" = 0 THEN NULL ELSE "contas_a_pagar" * (-1) END AS "contas_a_pagar"
        , CASE WHEN "contas_a_receber" = 0 THEN NULL ELSE "contas_a_receber" END AS "contas_a_receber"
        , CASE WHEN "previsao_vendas" = 0 THEN NULL ELSE "previsao_vendas" END AS "previsao_vendas"
        , CASE WHEN linha = 1 THEN "saldo_inicial" - "contas_a_pagar" + "contas_a_receber" + "previsao_vendas"
        	   ELSE (LAG("total_linha", 1) OVER (ORDER BY "data")) - "contas_a_pagar" + "contas_a_receber" + "previsao_vendas"
        end as "saldo_projetado"
FROM (
SELECT 
  lt."data" AS "data"
  , COALESCE(SUM(CAST(usb."saldo" AS DOUBLE PRECISION)), 0) AS "saldo_inicial"
  , COALESCE(SUM(CAST(cp."saldo" AS DOUBLE PRECISION)), 0) AS "contas_a_pagar"
  , COALESCE(SUM(CAST(cr."saldo" AS DOUBLE PRECISION)), 0) AS "contas_a_receber"
  , COALESCE(SUM(CAST(pr."valor" AS DOUBLE PRECISION)), 0) AS "previsao_vendas"
  , COALESCE(SUM(CAST(usb."saldo" AS DOUBLE PRECISION)), 0) 
  - COALESCE(SUM(CAST(cp."saldo" AS DOUBLE PRECISION)), 0) 
  + COALESCE(SUM(CAST(cr."saldo" AS DOUBLE PRECISION)), 0) 
  + COALESCE(SUM(CAST(pr."valor" AS DOUBLE PRECISION)), 0) AS "total_linha"
  , RANK () OVER ( 
		ORDER BY lt."data" 
	) linha 
FROM linha_do_tempo lt
LEFT JOIN ultimo_saldo_bancario usb ON (lt."data" = usb."data")
LEFT JOIN "dadosparaapp"."fat_dadosparaapp_contasapagar" cp ON (lt."data" = cp."data_vencimento" AND UPPER(CAST(cp."situacao_baixa" AS TEXT)) IN ('ABERTO', 'BAIXADO PARCIAL'))
LEFT JOIN "dadosparaapp"."fat_dadosparaapp_contasareceber" cr ON (lt."data" = cr."data_vencimento" AND UPPER(CAST(cr."situacao_baixa" AS TEXT)) IN ('ABERTO', 'BAIXADO PARCIAL'))
LEFT JOIN "dadosparaapp"."fat_dadosparaapp_previsaodereceitasbase" pr ON (lt."data" = pr."data")
GROUP BY lt."data"
ORDER BY lt."data") fluxo