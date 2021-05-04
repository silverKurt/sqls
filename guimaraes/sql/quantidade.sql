with dados as (
SELECT 
	CAST("subgrupo_produto" AS TEXT) AS "subgrupoproduto",
	CAST("grupo_produto" AS TEXT) AS "grupoproduto",
	CAST("nome_cliente" AS TEXT) AS "nomecliente",
	CAST("geo_cliente" AS TEXT) AS "geocliente",
	CAST("nome_filial" AS TEXT) AS "nomefilial",
	CAST("litros_vendidos" AS TEXT) AS "litrosvendidos",
	CAST("cod_produto" AS TEXT) AS "codproduto",
	CAST("linha_produto" AS TEXT) AS "linhaproduto",
	CAST("data_fatura" AS DATE) AS "datafatura",
	CAST("tipo_faturamento" AS TEXT) AS "tipofaturamento",
	CAST("nome_vendedor" AS TEXT) AS "nomevendedor",
	CAST("pais_cliente" AS TEXT) AS "paiscliente",
	CAST("tipo_vendedor" AS TEXT) AS "tipovendedor",
	CAST("cep_cliente" AS TEXT) AS "cepcliente",
	CAST("kilos_vendidos" AS TEXT) AS "kilosvendidos",
	CAST("estado_cliente" AS TEXT) AS "estadocliente",
	CAST("cfop" AS TEXT) AS "cfop",
	CAST("data_meta" AS TEXT) AS "datameta",
	CAST("familia_produto" AS TEXT) AS "familiaproduto",
	CAST("cod_filial" AS TEXT) AS "codfilial",
	CAST("cidade_cliente" AS TEXT) AS "cidadecliente",
	CAST("nome_supervisor" AS TEXT) AS "nomesupervisor",
	CAST("tipo_cliente" AS TEXT) AS "tipocliente",
	CAST("produto" AS TEXT) AS "produto",
	CAST("marca_produto" AS TEXT) AS "marcaproduto",
	CAST("valor_frete_fatura" AS DOUBLE PRECISION) AS "valorfretefatura",
	CAST("cod_cliente" AS DOUBLE PRECISION) AS "codcliente",
	CAST("valor_margem" AS DOUBLE PRECISION) AS "valormargem",
	CAST("numero_documento" AS DOUBLE PRECISION) AS "numerodocumento",
	CAST("custo_total_produto" AS DOUBLE PRECISION) AS "custototalproduto",
	CAST("valor_margem_gerencial" AS DOUBLE PRECISION) AS "valormargemgerencial",
	CAST("valor_acrescimo_produto" AS DOUBLE PRECISION) AS "valoracrescimoproduto",
	CAST("cod_supervisor" AS DOUBLE PRECISION) AS "codsupervisor",
	CAST("numero_nota" AS DOUBLE PRECISION) AS "numeronota",
	CAST("quantidade_vendida" AS DOUBLE PRECISION) AS "quantidadevendida",
	CAST("cod_vendedor" AS DOUBLE PRECISION) AS "codvendedor",
	CAST("valor_desconto_fatura" AS DOUBLE PRECISION) AS "valordescontofatura",
	CAST("valor_venda_liquida" AS DOUBLE PRECISION) AS "valorvendaliquida",
	CAST("valor_total_produto" AS DOUBLE PRECISION) AS "valortotalproduto",
	CAST("preco_produto" AS DOUBLE PRECISION) AS "precoproduto" 
FROM "guimaraespl"."fat_guimaraespl_FaturamentoBaseBelLimp"
 
UNION ALL 
 
-- Source: Faturamento Base
SELECT 
	CAST("subgrupo_produto" AS TEXT) AS "subgrupoproduto",
	CAST("grupo_produto" AS TEXT) AS "grupoproduto",
	CAST("nome_cliente" AS TEXT) AS "nomecliente",
	CAST("geo_cliente" AS TEXT) AS "geocliente",
	CAST("nome_filial" AS TEXT) AS "nomefilial",
	CAST("litros_vendidos" AS TEXT) AS "litrosvendidos",
	CAST("cod_produto" AS TEXT) AS "codproduto",
	CAST("linha_produto" AS TEXT) AS "linhaproduto",
	CAST("data_fatura" AS DATE) AS "datafatura",
	CAST("tipo_faturamento" AS TEXT) AS "tipofaturamento",
	CAST("nome_vendedor" AS TEXT) AS "nomevendedor",
	CAST("pais_cliente" AS TEXT) AS "paiscliente",
	CAST("tipo_vendedor" AS TEXT) AS "tipovendedor",
	CAST("cep_cliente" AS TEXT) AS "cepcliente",
	CAST("kilos_vendidos" AS TEXT) AS "kilosvendidos",
	CAST("estado_cliente" AS TEXT) AS "estadocliente",
	CAST("cfop" AS TEXT) AS "cfop",
	CAST("data_meta" AS TEXT) AS "datameta",
	CAST("familia_produto" AS TEXT) AS "familiaproduto",
	CAST("cod_filial" AS TEXT) AS "codfilial",
	CAST("cidade_cliente" AS TEXT) AS "cidadecliente",
	CAST("nome_supervisor" AS TEXT) AS "nomesupervisor",
	CAST("tipo_cliente" AS TEXT) AS "tipocliente",
	CAST("produto" AS TEXT) AS "produto",
	CAST("marca_produto" AS TEXT) AS "marcaproduto",
	CAST("valor_frete_fatura" AS DOUBLE PRECISION) AS "valorfretefatura",
	CAST("cod_cliente" AS DOUBLE PRECISION) AS "codcliente",
	CAST("valor_margem" AS DOUBLE PRECISION) AS "valormargem",
	CAST("numero_documento" AS DOUBLE PRECISION) AS "numerodocumento",
	CAST("custo_total_produto" AS DOUBLE PRECISION) AS "custototalproduto",
	CAST("valor_margem_gerencial" AS DOUBLE PRECISION) AS "valormargemgerencial",
	CAST("valor_acrescimo_produto" AS DOUBLE PRECISION) AS "valoracrescimoproduto",
	CAST("cod_supervisor" AS DOUBLE PRECISION) AS "codsupervisor",
	CAST("numero_nota" AS DOUBLE PRECISION) AS "numeronota",
	CAST("quantidade_vendida" AS DOUBLE PRECISION) AS "quantidadevendida",
	CAST("cod_vendedor" AS DOUBLE PRECISION) AS "codvendedor",
	CAST("valor_desconto_fatura" AS DOUBLE PRECISION) AS "valordescontofatura",
	CAST("valor_venda_liquida" AS DOUBLE PRECISION) AS "valorvendaliquida",
	CAST("valor_total_produto" AS DOUBLE PRECISION) AS "valortotalproduto",
	CAST("preco_produto" AS DOUBLE PRECISION) AS "precoproduto" 
FROM "guimaraespl"."fat_guimaraespl_FaturamentoBase")

, notasRepetidasUm AS (
  	
	SELECT DISTINCT X."numeronota" FROM (
	SELECT DISTINCT "numeronota" from dados where "codfilial" = '1/1') X
    INNER JOIN (SELECT DISTINCT "numeronota" from dados where "codfilial" = '65/1') Y ON (X.numeronota = Y.numeronota)


)

/*, notasRepetidasDois AS (
	
	SELECT DISTINCT X."numeronota" FROM (
	SELECT DISTINCT "numeronota" from dados where "codfilial" = '1/2') X
    INNER JOIN (SELECT DISTINCT "numeronota" from dados where "codfilial" = '65/2') Y ON (X.numeronota = Y.numeronota)
  
)*/

select 

date_trunc('month', "datafatura") as periodo,
"nomevendedor" as representante,
"nomecliente" as cliente,
"paiscliente" as pais,
"estadocliente" as estado,
"cidadecliente" as cidade,
"grupoproduto" as grupo,
"linhaproduto" as linha,
"subgrupoproduto" as subgrupo,
"produto",
"tipocliente",
"tipofaturamento",
"codfilial" as "idempresa",
CASE WHEN CAST("codfilial" AS TEXT) = '1/1' OR CAST("codfilial" AS TEXT) = '65/1' THEN 'MATRIZ' ELSE CAST("codfilial" AS TEXT) END AS "empresa",
CASE
        WHEN estadocliente IN ('RS', 'SC', 'PR')       
        THEN 'SUL'
        WHEN estadocliente IN ('SP', 'MG', 'RJ', 'ES') 
        THEN 'SUDESTE'
        WHEN estadocliente IN ('GO', 'MS', 'MT', 'DF') 
        THEN 'CENTRO OESTE'
        WHEN estadocliente IN ('BA', 'PI', 'MA', 'CE', 'PE', 'SE', 'AL', 'PB','RN')                   
        THEN 'NORDESTE'
        WHEN estadocliente IN ('AM', 'PA', 'TO', 'AP','RO', 'AC', 'RR')
        THEN 'NORTE'
END                                             AS "regiao",
"codsupervisor" as "idsupervisor",
"nomesupervisor" as supervisor,
"tipovendedor" as "tiporepresentante",
/* contagens distintas */
CAST("codvendedor" AS TEXT) AS "qtdrepresentante",
CAST("codcliente" AS TEXT) AS "qtdcliente",
CAST("codproduto" AS TEXT) AS "qtdproduto",
CAST("subgrupoproduto" AS TEXT) AS "qtdsubgrupoproduto",
CAST("grupoproduto" AS TEXT) AS "qtdgrupoproduto",
	
/* medidas */ 
	
COUNT(DISTINCT "numeronota") 		AS "qtd_notas",
SUM("valormargemgerencial")					AS "vlr",
SUM(CAST("litrosvendidos" AS DOUBLE PRECISION))				AS "qtdlt",
SUM("custototalproduto")			AS "vlrcusto",
(case when "codfilial" = '65/1' then (case when "numeronota" in (select "numeronota" from notasRepetidasUm) then null else "quantidadevendida" end) 
    --when "codfilial" = '65/2' then (case when "numeronota" in (select "numeronota" from notasRepetidasDois) then null else "quantidadevendida" end)
      else "quantidadevendida" 
end) as "qtd",
SUM("valorvendaliquida")	AS "vlrvendaliquida",
AVG("precoproduto")		AS "vlrmercadoria",
sum("valormargem") as "vlr_margem_contribuicao"

from dados
GROUP BY
1,2,3,4,5,6,7,8,9,10,11
,12,13,14,15,16,17,18,19
,20,21,22,23, 24, 25,26