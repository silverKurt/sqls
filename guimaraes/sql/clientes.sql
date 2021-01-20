WITH DADOS_CLIENTE AS (
SELECT
	"cod_cliente" 
	, MAX("data_fatura") AS "Data Ultima Compra"
	, MIN("data_fatura") AS "Data Primeira Compra"
	, COUNT(DISTINCT "numero_nota") AS "Quantidade de Compras"
	, SUM("valor_total_produto") AS "Valor"
FROM "guimaraespl"."fat_guimaraespl_FaturamentoBase"
WHERE CAST("tipo_cliente" AS TEXT) = 'CLIENTE'
GROUP BY 
	"cod_cliente"
)

/*DETERMINAR FAIXAS DE VALOR DO CLIENTE*/
, frequencia AS (
SELECT 
  D.cod_cliente
  , CASE 
		WHEN D."Quantidade de Compras" <= 10 
		THEN'F1 - ATÉ 10 COMPRAS'
		WHEN D."Quantidade de Compras" BETWEEN 11 AND 30  
		THEN 'F2 - ENTRE 11 E 30 COMPRAS'
		WHEN D."Quantidade de Compras" BETWEEN 31 AND 50  
		THEN 'F3 - ENTRE 31 E 50 COMPRAS'
		WHEN D."Quantidade de Compras" BETWEEN 51 AND 100 
		THEN 'F4 - ENTRE 51 E 100 COMPRAS'
		WHEN D."Quantidade de Compras" > 100
		THEN 'F5 - MAIS QUE 100 COMPRAS'
		ELSE 'FORA DE FAIXA'
	END AS "Faixa de Frequência"
FROM DADOS_CLIENTE D
)

/*DETERMINAR FAIXAS DE RECÊNCIA DO CLIENTE*/
, recencia AS (
SELECT 
  x.cod_cliente
  ,CASE 
		WHEN NOW()::DATE - x."Data Ultima Compra" > 270 OR x."Data Ultima Compra" IS NULL
		THEN 'R1 - INATIVO'
		WHEN NOW()::DATE - x."Data Ultima Compra" > 180
		THEN 'R2 - DE 181 A 270 DIAS'
		WHEN NOW()::DATE - x."Data Ultima Compra" > 120
		THEN 'R3 - DE 121 A 180 DIAS'
		WHEN NOW()::DATE - x."Data Ultima Compra" > 60
		THEN 'R4 - DE 61 A 120 DIAS'
		WHEN NOW()::DATE - x."Data Ultima Compra" <= 60
		THEN 'R5 - ATÉ 60 DIAS'
	END AS "Faixa de Recência"
FROM DADOS_CLIENTE x
)
, classificacao_clientes AS (

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
            CAST(fu."cod_cliente" AS TEXT) AS "Cliente"
            , CAST("data_fatura" AS DATE) AS "Periodo"
            , CAST("Data Ultima Compra" AS DATE) AS "data_ultima_compra"
        FROM "guimaraespl"."fat_guimaraespl_FaturamentoBase" fu
        LEFT JOIN DADOS_CLIENTE dc ON (CAST(fu."cod_cliente" AS TEXT) = CAST(dc."cod_cliente" AS TEXT))
        --WHERE fu."COD_CLI" = '2275'
        ORDER BY CAST("data_fatura" AS DATE)
    ) x
  ) y
WHERE DATE_TRUNC('MONTH', y."periodo") <> DATE_TRUNC('MONTH', y."compra_anterior")
ORDER BY y."Cliente", y."periodo"

)

/* AGRUPAR DADOS */ 


-- Source: Faturamento Base
SELECT 
	CAST("data_fatura" AS DATE)                     AS "periodo"
	, CAST("cfop" AS TEXT)                            AS "cfop"
	, CAST("nome_vendedor" AS TEXT)                   AS "representante"
	, CAST("nome_cliente" AS TEXT)                    AS "cliente"
	, CAST("pais_cliente" AS TEXT)                    AS "pais"
	, CAST("estado_cliente" AS TEXT)                  AS "estado"
	, CAST("cidade_cliente" AS TEXT)                  AS "cidade"
	, CAST("geo_cliente" AS TEXT)                     AS "geo"
	, CAST("tipo_cliente" AS TEXT)                    AS "tipo_cliente"
	, CAST("tipo_faturamento" AS TEXT)                AS "tipo_faturamento"
	, CAST("cod_filial" AS TEXT)                      AS "id_empresa"
	, CAST("nome_filial" AS TEXT)                     AS "empresa"
	, CAST("cep_cliente" AS TEXT)                     AS "cep"
	, CASE
		WHEN estado_cliente IN ('RS', 'SC', 'PR')       
		THEN 'SUL'
		WHEN estado_cliente IN ('SP', 'MG', 'RJ', 'ES') 
		THEN 'SUDESTE'
		WHEN estado_cliente IN ('GO', 'MS', 'MT', 'DF') 
		THEN 'CENTRO OESTE'
		WHEN estado_cliente IN ('BA', 'PI', 'MA', 'CE', 'PE', 'SE', 'AL', 'PB','RN')                   
		THEN 'NORDESTE'
		WHEN estado_cliente IN ('AM', 'PA', 'TO', 'AP','RO', 'AC', 'RR')
		THEN 'NORTE'
	END                                             AS "regiao"
	
	, CAST("cod_supervisor" AS TEXT)                  AS "id_supervisor"
	, CAST("nome_supervisor" AS TEXT)                 AS "supervisor"
	, CAST("tipo_vendedor" AS TEXT)                   AS "tipo_representante"

/*                            CLASSIFICAÇÕES DE CLIENTES                   */
	, cc."status_cliente" AS "Classificação Cliente"

	, rec."Faixa de Recência" AS "Faixa de Recência"
	, freq."Faixa de Frequência"


	, CASE WHEN ((freq."Faixa de Frequência" = 'F5 - MAIS QUE 100 COMPRAS' OR freq."Faixa de Frequência" = 'F4 - ENTRE 51 E 100 COMPRAS') AND (rec."Faixa de Recência" = 'R5 - ATÉ 60 DIAS'))
			THEN 'Clientes Campeões'
		WHEN ((freq."Faixa de Frequência" = 'F3 - ENTRE 31 E 50 COMPRAS' OR freq."Faixa de Frequência" = 'F2 - ENTRE 11 E 30 COMPRAS') AND (rec."Faixa de Recência" = 'R5 - ATÉ 60 DIAS' OR rec."Faixa de Recência" = 'R4 - DE 61 A 120 DIAS'))
			THEN 'Clientes potencial de lealdade'
		WHEN ((freq."Faixa de Frequência" = 'F1 - ATÉ 10 COMPRAS') AND (rec."Faixa de Recência" = 'R5 - ATÉ 60 DIAS')) --novos
			THEN 'Clientes Novos'
		WHEN ((freq."Faixa de Frequência" = 'F1 - ATÉ 10 COMPRAS') AND (rec."Faixa de Recência" = 'R4 - DE 61 A 120 DIAS')) --promissores
			THEN 'Clientes Promissores'
		WHEN ((freq."Faixa de Frequência" = 'F5 - MAIS QUE 100 COMPRAS' OR freq."Faixa de Frequência" = 'F4 - ENTRE 51 E 100 COMPRAS') AND (rec."Faixa de Recência" = 'R4 - DE 61 A 120 DIAS' OR rec."Faixa de Recência" = 'R3 - DE 121 A 180 DIAS'))
			THEN 'Clientes Leais'
		WHEN ((freq."Faixa de Frequência" = 'F3 - ENTRE 31 E 50 COMPRAS') AND (rec."Faixa de Recência" = 'R3 - DE 121 A 180 DIAS')) --atenção
			THEN 'Clientes Precisam Atenção'
		WHEN ((freq."Faixa de Frequência" = 'F1 - ATÉ 10 COMPRAS' OR freq."Faixa de Frequência" = 'F2 - ENTRE 11 E 30 COMPRAS') AND (rec."Faixa de Recência" = 'R3 - DE 121 A 180 DIAS'))
			THEN 'Clientes em pré-hibernação'
		WHEN ((freq."Faixa de Frequência" = 'F1 - ATÉ 10 COMPRAS' OR freq."Faixa de Frequência" = 'F2 - ENTRE 11 E 30 COMPRAS') AND (rec."Faixa de Recência" = 'R2 - DE 181 A 270 DIAS' OR rec."Faixa de Recência" = 'R1 - INATIVO'))
			THEN 'Clientes Hibernando'
		WHEN ((freq."Faixa de Frequência" = 'F3 - ENTRE 31 E 50 COMPRAS' OR freq."Faixa de Frequência" = 'F4 - ENTRE 51 E 100 COMPRAS') AND (rec."Faixa de Recência" = 'R2 - DE 181 A 270 DIAS' OR rec."Faixa de Recência" = 'R1 - INATIVO'))
			THEN 'Clientes em risco'
		WHEN ((freq."Faixa de Frequência" = 'F5 - MAIS QUE 100 COMPRAS') AND (rec."Faixa de Recência" = 'R2 - DE 181 A 270 DIAS' OR rec."Faixa de Recência" = 'R1 - INATIVO'))
			THEN 'Clientes não podemos perder'
	ELSE 'fora de faixa' END AS "Faixa de RFV"

   , CASE 
		WHEN "Valor" < 10000
		THEN 'V1 - Menor que 10 mil'
		WHEN "Valor" BETWEEN 10000 AND 30000
		THEN 'V2 - Enter 10 e 30 mil'
		WHEN "Valor" BETWEEN 30000 AND 50000
		THEN 'V3 - Entre 30 e 50 mil'
		WHEN "Valor" BETWEEN 50000 AND 100000
		THEN 'V4 - Entre 50 e 100 mil'
		WHEN "Valor" > 100000
		THEN 'V5 - Mais que 100 mil'
		ELSE 'Fora de Faixa'
	END AS "Faixa de Valor"

    /*MEDIDAS DE CONTAGEM*/
	, CAST(F."cod_vendedor" AS TEXT)                    AS "qtd_representante"
	, CAST(F."cod_cliente" AS TEXT)                     AS "qtd_clientes"
	

    /*MEDIDAS MONETÁRIAS*/
	, SUM("valor_total_produto")                      AS "vlr_total_fatura"
	

FROM "guimaraespl"."fat_guimaraespl_FaturamentoBase" F
LEFT JOIN DADOS_CLIENTE D ON (MD5(D."cod_cliente"::TEXT) = MD5(F."cod_cliente"::TEXT))
LEFT JOIN recencia rec ON (MD5(F."cod_cliente"::TEXT) = MD5(rec."cod_cliente"::TEXT))
LEFT JOIN frequencia freq ON (MD5(F."cod_cliente"::TEXT) = MD5(freq."cod_cliente"::TEXT))
LEFT JOIN classificacao_clientes cc ON (cc."Cliente"::TEXT = F."cod_cliente"::TEXT AND DATE_TRUNC('MONTH', CAST(F."data_fatura" AS DATE)) = DATE_TRUNC('MONTH', "periodo"))
WHERE  CAST("tipo_cliente" AS TEXT) = 'CLIENTE'
--AND "data_fatura" >= DATE_TRUNC('MONTH', NOW()::DATE)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24