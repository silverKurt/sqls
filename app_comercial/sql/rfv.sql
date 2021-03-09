WITH resumo_clientes AS (
SELECT
	f.cod_cliente
	, f.cod_representante
	, MAX(f.data) AS ultima_compra
	, MIN(f.data) AS primeira_compra
	, COUNT(DISTINCT f.nota_fiscal) AS nota_fiscal
	, SUM(f.faturamento) AS faturamento
FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase" f
WHERE
	f.data >= (DATE_TRUNC('MONTH', NOW()::DATE) - '12 MONTHS'::INTERVAL)
	AND f.tipo_faturamento = 'VENDA'
GROUP BY 
	f.cod_cliente, f.cod_representante
)

/* DETERMINAR FAIXAS DE FREQUENCIA DOS CLIENTES */
, frequencia_clientes AS (
SELECT 
	d.cod_cliente
	, d.cod_representante
	, CASE 
		WHEN d.nota_fiscal <= 10 
		THEN 'F1 - ATÉ 10 COMPRAS'
		WHEN d.nota_fiscal BETWEEN 11 AND 30  
		THEN 'F2 - ENTRE 11 E 30 COMPRAS'
		WHEN d.nota_fiscal BETWEEN 31 AND 50  
		THEN 'F3 - ENTRE 31 E 50 COMPRAS'
		WHEN d.nota_fiscal BETWEEN 51 AND 100 
		THEN 'F4 - ENTRE 51 E 100 COMPRAS'
		WHEN d.nota_fiscal > 100
		THEN 'F5 - MAIS QUE 100 COMPRAS'
		ELSE 'FORA DE FAIXA'
	END AS faixa_frequencia
FROM resumo_clientes d
)

/* DETERMINAR FAIXAS DE RECÊNCIA DOS CLIENTES */
, recencia_clientes AS (
SELECT 
	x.cod_cliente
	, x.cod_representante
	, CASE 
		WHEN NOW()::DATE - x.ultima_compra > 270 OR x.ultima_compra IS NULL
		THEN 'R1 - INATIVO'
		WHEN NOW()::DATE - x.ultima_compra > 180
		THEN 'R2 - DE 181 A 270 DIAS'
		WHEN NOW()::DATE - x.ultima_compra > 120
		THEN 'R3 - DE 121 A 180 DIAS'
		WHEN NOW()::DATE - x.ultima_compra > 60
		THEN 'R4 - DE 61 A 120 DIAS'
		WHEN NOW()::DATE - x.ultima_compra <= 60
		THEN 'R5 - ATÉ 60 DIAS'
	END AS faixa_recencia
FROM resumo_clientes x
)

, demais_dados_faturamento AS (
SELECT DISTINCT
	CAST(f.representante AS TEXT) AS representante
	, CAST(f.cliente AS TEXT) AS cliente
	, CAST(f.pais AS TEXT) AS pais
	, CAST(f.estado AS TEXT) AS estado
	, CAST(f.cidade AS TEXT) AS cidade
	, CAST(f.geo AS TEXT) AS geo
	, CAST(f.tipo_faturamento AS TEXT) AS tipo_faturamento
	, CAST(f.cod_empresa AS TEXT) AS cod_empresa
	, CAST(f.empresa AS TEXT) AS empresa
	, CAST(f.cep AS TEXT) AS cep
	, CASE
		WHEN f.estado IN ('RS', 'SC', 'PR')       
		THEN 'SUL'
		WHEN f.estado IN ('SP', 'MG', 'RJ', 'ES') 
		THEN 'SUDESTE'
		WHEN f.estado IN ('GO', 'MS', 'MT', 'DF') 
		THEN 'CENTRO OESTE'
		WHEN f.estado IN ('BA', 'PI', 'MA', 'CE', 'PE', 'SE', 'AL', 'PB','RN')                   
		THEN 'NORDESTE'
		WHEN f.estado IN ('AM', 'PA', 'TO', 'AP','RO', 'AC', 'RR')
		THEN 'NORTE'
	END AS regiao

	, CAST(f.supervisor AS TEXT) AS supervisor

	, CAST(f.cod_representante AS TEXT) AS cod_representante
	, CAST(f.cod_cliente AS TEXT) AS cod_cliente
FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase" f
WHERE 
	f.data >= (DATE_TRUNC('MONTH', NOW()::DATE) - '12 MONTHS'::INTERVAL)
	AND f.tipo_faturamento = 'VENDA'
)

-- Source: Faturamento Base
SELECT
	f.representante
	, f.cliente
	, f.pais
	, f.estado
	, f.cidade
	, f.geo
	, f.tipo_faturamento
	, f.empresa
	, f.cep
	, f.regiao
	, f.supervisor

    , TO_CHAR(r.primeira_compra, 'dd/MM/yyyy') AS primeira_compra
    , TO_CHAR(r.ultima_compra, 'dd/MM/yyyy') AS ultima_compra

	, rec.faixa_recencia AS faixa_recencia
	, freq.faixa_frequencia AS faixa_frequencia

	, CASE 
		WHEN r.faturamento < 10000
		THEN 'V1 - Menor que 10 mil'
		WHEN r.faturamento BETWEEN 10000 AND 30000
		THEN 'V2 - Enter 10 e 30 mil'
		WHEN r.faturamento BETWEEN 30000 AND 50000
		THEN 'V3 - Entre 30 e 50 mil'
		WHEN r.faturamento BETWEEN 50000 AND 100000
		THEN 'V4 - Entre 50 e 100 mil'
		WHEN r.faturamento > 100000
		THEN 'V5 - Mais que 100 mil'
		ELSE 'Fora de Faixa'
	END AS faixa_valor

	, CASE WHEN (freq."faixa_frequencia" IN ('F4 - ENTRE 51 E 100 COMPRAS', 'F5 - MAIS QUE 100 COMPRAS') AND rec."faixa_recencia" IN ('R4 - DE 61 A 120 DIAS', 'R5 - ATÉ 60 DIAS')) THEN 'Cliente Assíduo'
		   WHEN (freq."faixa_frequencia" = 'F3 - ENTRE 31 E 50 COMPRAS' AND rec."faixa_recencia" = 'R5 - ATÉ 60 DIAS') THEN 'Cliente Assíduo'
	 	   
		   WHEN (freq."faixa_frequencia" IN ('F2 - ENTRE 11 E 30 COMPRAS', 'F1 - ATÉ 10 COMPRAS') AND rec."faixa_recencia" IN ('R4 - DE 61 A 120 DIAS', 'R5 - ATÉ 60 DIAS')) THEN 'Cliente Promissor'
		   WHEN (freq."faixa_frequencia" = 'F3 - ENTRE 31 E 50 COMPRAS' AND rec."faixa_recencia" = 'R4 - DE 61 A 120 DIAS') THEN 'Cliente Promissor'
	 	   /*CLIENTES LEAIS*/
		   WHEN rec."faixa_recencia" = 'R3 - DE 121 A 180 DIAS' THEN 'Cliente Leal'
	  	   /*CLIENTES EM RISCO*/
		   WHEN (freq."faixa_frequencia" IN ('F2 - ENTRE 11 E 30 COMPRAS', 'F1 - ATÉ 10 COMPRAS') AND rec."faixa_recencia" IN ('R1 - INATIVO', 'R2 - DE 181 A 270 DIAS')) THEN 'Cliente Risco'
		   WHEN (freq."faixa_frequencia" = 'F3 - ENTRE 31 E 50 COMPRAS' AND rec."faixa_recencia" = 'R2 - DE 181 A 270 DIAS') THEN 'Cliente Risco'
	 	   /*CLIENTES QUE NÃO PODEMOS PERDER*/
		   WHEN (freq."faixa_frequencia" IN ('F4 - ENTRE 51 E 100 COMPRAS', 'F4 - ENTRE 51 E 100 COMPRAS') AND rec."faixa_recencia" IN ('R1 - INATIVO', 'R2 - DE 181 A 270 DIAS')) THEN 'Cliente Não Podemos Perder'
		   WHEN (freq."faixa_frequencia" = 'F3 - ENTRE 31 E 50 COMPRAS' AND rec."faixa_recencia" = 'R1 - INATIVO') THEN 'Cliente Não Podemos Perder'
	 	   ELSE 'FORA DA FAIXA'
	END AS faixa_rfv

	, f.cod_cliente AS qtd_clientes
	, r.faturamento
	, r.nota_fiscal
FROM demais_dados_faturamento f
LEFT JOIN resumo_clientes r ON (MD5(f.cod_cliente::TEXT) = MD5(r.cod_cliente::TEXT) AND MD5(f.cod_representante::TEXT) = MD5(r.cod_representante::TEXT))
LEFT JOIN recencia_clientes rec ON (MD5(f.cod_cliente::TEXT) = MD5(rec.cod_cliente::TEXT) AND MD5(f.cod_representante::TEXT) = MD5(rec.cod_representante::TEXT))
LEFT JOIN frequencia_clientes freq ON (MD5(f.cod_cliente::TEXT) = MD5(freq.cod_cliente::TEXT) AND MD5(f.cod_representante::TEXT) = MD5(freq.cod_representante::TEXT))