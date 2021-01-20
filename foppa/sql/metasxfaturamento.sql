WITH ultima_venda_cmv AS (
SELECT "CodProduto"::TEXT
		, "DataVenda"
        , "CMVUnitario"
		, "ValorLiquido"
FROM (
	SELECT * 
		, ROW_NUMBER() OVER(PARTITION BY "CodProduto" ORDER BY "DataVenda" DESC) AS "Ranking"
	FROM (
		SELECT DISTINCT
			"CodProduto"::TEXT
		    , "DataVenda"
      		, v."Hora_da_Venda"--PRECISA TER PARA MAIS VENDAS DENTRO DE 1 DIA
		    , v."CMVUnitario"
		    , v."ValorLiquido"/ "QtdeTotalItem" as "ValorLiquido"
			/*(SELECT iv."CMVUnitario" FROM "foppa"."fat_foppa_Vendas" iv WHERE CAST(iv."CodProduto" AS TEXT) = CAST(v."CodProduto" AS TEXT) ORDER BY "DataVenda" DESC LIMIT 1) AS "CMVUnitarioUC",
		    (SELECT iv."ValorLiquido" FROM "foppa"."fat_foppa_Vendas" iv WHERE CAST(iv."CodProduto" AS TEXT) = CAST(v."CodProduto" AS TEXT) ORDER BY "DataVenda" DESC LIMIT 1) AS "VlrLiquidoUC"*/
		FROM "foppa"."fat_foppa_Vendas" v
		WHERE DATE_TRUNC('MONTH', "DataVenda") >= NOW() - '1 YEAR'::INTERVAL
		ORDER BY 1,2 DESC
	) X
) Y 
WHERE "Ranking" = 1
), primeira_ultima_fatura AS (
    SELECT 
        "CodProduto"::TEXT
        , MAX("DataVenda") AS "Data Última Venda"
        , MIN("DataVenda") AS "Data Primeira Venda"
    FROM "foppa"."fat_foppa_Vendas" v
    GROUP BY 1
) , colabs AS (
SELECT DISTINCT 
      "CodFilial" as loja
    , "CodVendedor" as colab_cod
    , "Vendedor" as "Colaborador"
FROM "foppa"."fat_foppa_Vendas"
), venda_pre AS (
--Soma as Vendas até o ano anterior para base de calculo para as metas
SELECT 
    CAST("TipoVenda" AS TEXT) AS "TipoVenda",
    CAST("CodFilial" AS TEXT) AS "Loja",
    CAST("DataVenda" AS DATE) AS "Periodo",
    CAST(SUM(CASE WHEN "TipoVenda" = 'D' THEN "ValorLiquido" * (-1) ELSE "ValorLiquido" END) AS DOUBLE PRECISION) AS "Faturamento",
    CAST(CASE WHEN "TipoVenda" = 'V' THEN COUNT(DISTINCT "IdVenda") END AS DOUBLE PRECISION) AS "Qtd Vendas",
    CAST(SUM("QtdeTotalItem"*"CMVUnitario") AS DOUBLE PRECISION) AS "CMV Total"
FROM "foppa"."fat_foppa_Vendas"
WHERE CAST(DATE_TRUNC('YEAR', "DataVenda") AS DATE) <= DATE_TRUNC('YEAR', NOW()::DATE)
GROUP BY 1,2,3
), venda_pre_grupo AS (
--Soma as Vendas até o ano anterior para base de calculo para as metas
SELECT 
    CAST("TipoVenda" AS TEXT) AS "TipoVenda",
    CAST("CodFilial" AS TEXT) AS "Loja",
    CAST("DataVenda" AS DATE) AS "Periodo",
    CAST("GrupoProduto" AS TEXT) AS "GrupoProduto",
    CAST(SUM(CASE WHEN "TipoVenda" = 'D' THEN "ValorLiquido" * (-1) ELSE "ValorLiquido" END) AS DOUBLE PRECISION) AS "Faturamento",
    CAST(CASE WHEN "TipoVenda" = 'V' THEN COUNT(DISTINCT "IdVenda") END AS DOUBLE PRECISION) AS "Qtd Vendas",
    CAST(SUM("QtdeTotalItem"*"CMVUnitario") AS DOUBLE PRECISION) AS "CMV Total"
FROM "foppa"."fat_foppa_Vendas"
WHERE CAST(DATE_TRUNC('YEAR', "DataVenda") AS DATE) <= DATE_TRUNC('YEAR', NOW()::DATE)
GROUP BY 1,2,3,4
), venda_resumida AS (
--Soma as vendas para descontar a devolução e permitir a meta diária
SELECT 
    "Loja",
    "Periodo",
    SUM("Faturamento") AS "Faturamento",
    SUM("Qtd Vendas") AS "Qtd Vendas",
    SUM("CMV Total") AS "CMV Total"
FROM venda_pre
GROUP BY 1,2
), venda_mes AS (
--Soma as vendas para descontar a devolução e calcular as metas de ticket e margem
SELECT 
    "Loja",
    DATE_TRUNC('MONTH', "Periodo") AS "Periodo",
    SUM("Faturamento") AS "Faturamento Mes",
    SUM("Qtd Vendas") AS "Qtd Vendas Mes",
    SUM("CMV Total") AS "CMV Total Mes"
FROM venda_pre
GROUP BY 1,2
), metas_colab AS (
SELECT
      c."Periodo"
    , c."Loja"
    , c."Cod_Colaborador"
    , cc."Colaborador"
    , c.meta
    , SUM(c.meta) OVER (PARTITION BY c."Periodo", c."Loja") as "Meta Loja"
    , (CASE WHEN SUM(c.meta) OVER (PARTITION BY c."Periodo", c."Loja")::DOUBLE PRECISION = 0 THEN null ELSE c.meta::DOUBLE PRECISION/SUM(c.meta) OVER (PARTITION BY c."Periodo", c."Loja")::DOUBLE PRECISION END) AS perc_colab
FROM "foppa"."fat_foppa_MetaColaborador" c
LEFT JOIN colabs cc ON (c."Loja"::INTEGER = cc.loja::INTEGER AND c."Cod_Colaborador"::INTEGER = cc.colab_cod::INTEGER)
WHERE c.meta > 0
), metas_lojaXgrupoXcolab AS (
-- Source: Metas por Loja
-- Source: Metas por Grupos de  Produtos
-- Cruza as Metas das Lojas com as metas de Grupos para poder calcular os valores por Grupo.
SELECT 
    CAST(l."Periodo" AS DATE) AS "Periodo",
    CAST(l."Loja" AS TEXT) AS "Loja",
    CAST(g."Grupo" AS TEXT) AS "Grupo",
    CAST(c."Cod_Colaborador" AS TEXT) AS "Cod_Colaborador",
    CAST(c."Colaborador" AS TEXT) AS "Colaborador",
    CAST(l."Margem" AS DOUBLE PRECISION) AS "Margem",
    CAST(l."Meta" AS DOUBLE PRECISION) AS "Meta",
    CAST(l."Atendimentos" AS DOUBLE PRECISION) AS "Atendimentos",
    CAST(l."Ticket_Medio" AS DOUBLE PRECISION) AS "Ticket_Medio",
    CAST(g."Meta" AS DOUBLE PRECISION) AS "Meta Grupo",
    CAST(COALESCE(c.perc_colab,1) AS DOUBLE PRECISION) AS perc_colab
FROM "foppa"."fat_foppa_MetasporLoja" l
LEFT JOIN "foppa"."fat_foppa_MetasporGruposdeProdutos" g ON (l."Loja"::INTEGER = g."Loja"::INTEGER AND DATE_TRUNC('YEAR', l."Periodo") = DATE_TRUNC('YEAR', g."Periodo"))
LEFT JOIN metas_colab c ON (l."Loja"::INTEGER = c."Loja"::INTEGER AND DATE_TRUNC('MONTH', l."Periodo") = DATE_TRUNC('MONTH', c."Periodo"))
), venda_mes_por_grupo AS (
--Soma as vendas para descontar a devolução e calcular as metas de ticket e margem
SELECT 
    DATE_TRUNC('MONTH', "Periodo") AS "Periodo",
    "Loja",
    "GrupoProduto",
    SUM("Faturamento") AS "Faturamento Mes",
    SUM("Qtd Vendas") AS "Qtd Vendas Mes",
    SUM("CMV Total") AS "CMV Total Mes"
FROM venda_pre_grupo
GROUP BY 1,2,3
)

-- Source: Vendas
SELECT 
    CAST(v."TipoVenda" AS TEXT) AS "TipoVenda",
    CAST(v."CodFilial" AS TEXT) AS "Loja",
    CAST(v."DataVenda" AS DATE) AS "Periodo",
    CAST(v."GrupoProduto" AS TEXT) AS "Grupo",
    CAST(v."CodProduto" AS TEXT) || ' - ' || CAST(v."Produto" AS TEXT) AS "Produto",
    CAST(v."Hora_da_Venda" AS TEXT) AS "HoradaVenda",
    CAST(v."CodVendedor" AS TEXT) AS "Cod_Colaborador",
    CAST(v."Vendedor" AS TEXT) AS "Colaborador",
    CAST(null AS DOUBLE PRECISION) AS "Meta",
    CAST(null AS DOUBLE PRECISION) AS "Meta Ticket Medio",
    CAST(NULL AS DOUBLE PRECISION) AS "Meta Ticket Medio Grupo",
    CAST(null AS DOUBLE PRECISION) AS "Meta Margem",
    CAST(NULL AS DOUBLE PRECISION) AS "Meta Margem Grupo",
    CAST(null AS DOUBLE PRECISION) AS "Meta Atendimentos",
    CAST(null AS DOUBLE PRECISION) AS "DiasUteis",
    CAST(v."ValorLiquido" AS DOUBLE PRECISION) AS "VlrLiquido",
    CAST(v."QtdeTotalItem"*v."CMVUnitario" AS DOUBLE PRECISION) AS "CMV Total",
    CAST(v."IdVenda" AS DOUBLE PRECISION) AS "Qtd Vendas",
    CAST(v."Qtd_Favorecido" AS DOUBLE PRECISION) AS "Qtd Favorecido",
    CAST(v."ValorBruto" AS DOUBLE PRECISION) AS "ValorBruto",
    CAST(null AS DOUBLE PRECISION) AS "Meta Grupo",
    CAST(iv."CMVUnitario" AS DOUBLE PRECISION) AS "CMVUnitarioUC",
    CAST(iv."ValorLiquido" AS DOUBLE PRECISION) AS "VlrLiquidoUC",
    CASE WHEN DATE_TRUNC('MONTH', CAST(v."DataVenda" AS DATE)) = DATE_TRUNC('MONTH', pu."Data Primeira Venda") THEN 'PRODUTO NOVO' ELSE 'VENDIDO ANTERIORMENTE' END AS "Status Produto"
FROM "foppa"."fat_foppa_Vendas" v
LEFT JOIN ultima_venda_cmv iv ON (CAST(iv."CodProduto" AS TEXT) = CAST(v."CodProduto" AS TEXT) AND DATE_TRUNC('MONTH', iv."DataVenda") = DATE_TRUNC('MONTH', v."DataVenda"))
LEFT JOIN primeira_ultima_fatura pu ON (CAST(pu."CodProduto" AS TEXT) = CAST(v."CodProduto" AS TEXT))

UNION ALL

/*

    As metas são calculadas de modo que o faturamento do 

*/
--Calculo das Metas por loja
SELECT
      'V' AS "TipoVenda"
    , m."Loja"
    , COALESCE(v."Periodo" + '1 year'::INTERVAL, m."Periodo") as "Periodo"
    , CAST("Grupo" AS TEXT) AS "Grupo"
    , CAST(NULL AS TEXT) AS "Produto"
    , CAST(null AS TEXT) AS "HoradaVenda"
    , "Cod_Colaborador"
    , "Colaborador"
    , ((1+(m."Meta"/10000)) * v."Faturamento")*(m."Meta Grupo"/10000)*(m.perc_colab) as "Meta"
    , (1+(m."Ticket_Medio"/10000)) * (a."Faturamento Mes"/a."Qtd Vendas Mes") AS "Meta Ticket Medio"
    , (1+(m."Ticket_Medio"/10000)) * (vg."Faturamento Mes"/vg."Qtd Vendas Mes") AS "Meta Ticket Medio Grupo"
    , (1+(m."Margem"/10000)) * (((a."CMV Total Mes"/a."Faturamento Mes")-1)*-1) AS "Meta Margem"
    , (1+(m."Margem"/10000)) * (((vg."CMV Total Mes"/vg."Faturamento Mes")-1)*-1) AS "Meta Margem Grupo"
--    , (((1+(m."Meta"/10000)) * v."Faturamento")/((1+(m."Ticket_Medio"/10000)) * (v."Faturamento"/v."Qtd Vendas")))*(m."Meta Grupo"/10000)*(m.perc_colab) AS "Meta Atendimentos" --calculo antigo base ticket medio X vendas
    , ((1+(m."Atendimentos"/10000)) * v."Qtd Vendas")*(m."Meta Grupo"/10000)*(m.perc_colab) AS "Meta Atendimentos"
    , CAST(null AS DOUBLE PRECISION) AS "DiasUteis"
    , CAST(null AS DOUBLE PRECISION) AS "VlrLiquido"
    , CAST(null AS DOUBLE PRECISION) AS "CMV Total"
    , CAST(null AS DOUBLE PRECISION) AS "Qtd Vendas"
    , CAST(null AS DOUBLE PRECISION) AS "Qtd Favorecido"
    , CAST(NULL AS DOUBLE PRECISION) AS "ValorBruto"
    , CAST((m."Meta Grupo"/10000) AS DOUBLE PRECISION) AS "Meta Grupo"
    , NULL::DOUBLE PRECISION AS "CMVUnitarioUC"
    , NULL::DOUBLE PRECISION AS "VlrLiquidoUC"
    , NULL::TEXT AS "Status Produto"
FROM metas_lojaXgrupoXcolab m
LEFT JOIN venda_resumida v ON (DATE_TRUNC('MONTH', m."Periodo" - '1 year'::INTERVAL) = DATE_TRUNC('MONTH', v."Periodo") AND m."Loja"::INTEGER = v."Loja"::INTEGER)
LEFT JOIN venda_mes a ON (DATE_TRUNC('MONTH', m."Periodo" - '1 year'::INTERVAL) = DATE_TRUNC('MONTH', a."Periodo") AND m."Loja"::INTEGER = a."Loja"::INTEGER)
LEFT JOIN venda_mes_por_grupo vg ON (DATE_TRUNC('MONTH', m."Periodo" - '1 year'::INTERVAL) = DATE_TRUNC('MONTH', vg."Periodo") AND m."Loja"::INTEGER = vg."Loja"::INTEGER AND m."Grupo" = vg."GrupoProduto")

UNION ALL

-- Source: Metas Lojas Novas
SELECT 
    CAST(null AS TEXT) AS "TipoVenda",
    CAST(m."Loja" AS TEXT) AS "Loja",
    CAST(c.data AS DATE) AS "Periodo",
    CAST(g."Grupo" AS TEXT) AS "Grupo",
    CAST(NULL AS TEXT) AS "Produto",
    CAST(null AS TEXT) AS "HoradaVenda",
    CAST(col."Cod_Colaborador" AS TEXT) AS "Cod_Colaborador",
    CAST(col."Colaborador" AS TEXT) AS "Colaborador",
   -- CAST("Meta" AS DOUBLE PRECISION) AS "Meta",
    (m."Meta" / (SELECT SUM(pi.util) FROM "foppa"."fat_foppa_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.data) = DATE_TRUNC('MONTH', c.data)))*(COALESCE(col.perc_colab,1))*(COALESCE((g."Meta"/10000),1))  AS "Meta",
    CAST(m."Ticket_Medio" AS DOUBLE PRECISION) AS "Meta Ticket Medio",
    CAST(m."Ticket_Medio" AS DOUBLE PRECISION) AS "Meta Ticket Medio Grupo",
    CAST((m."Margem"/100) AS DOUBLE PRECISION) AS "Meta Margem",
    CAST((m."Margem"/100) AS DOUBLE PRECISION) AS "Meta Margem Grupo",
    (m."Clientes_Atendidos" / (SELECT SUM(pi.util) FROM "foppa"."fat_foppa_CalendarioComercial" pi WHERE DATE_TRUNC('MONTH', pi.data) = DATE_TRUNC('MONTH', c.data)))*(COALESCE(col.perc_colab,1))*(COALESCE((g."Meta"/10000),1)) AS "Meta Atendimentos",
    CAST(null AS DOUBLE PRECISION) AS "DiasUteis",
    CAST(null AS DOUBLE PRECISION) AS "VlrLiquido",
    CAST(null AS DOUBLE PRECISION) AS "CMV Total",
    CAST(null AS DOUBLE PRECISION) AS "Qtd Vendas",
    CAST(null AS DOUBLE PRECISION) AS "Qtd Favorecido",
    CAST(NULL AS DOUBLE PRECISION) AS "ValorBruto",
    CAST((g."Meta"/10000) AS DOUBLE PRECISION) AS "Meta Grupo",
    NULL::DOUBLE PRECISION AS "CMVUnitarioUC",
    NULL::DOUBLE PRECISION AS "VlrLiquidoUC",
    NULL::TEXT AS "Status Produto"
FROM "foppa"."fat_foppa_MetasLojasNovas" m
LEFT JOIN "foppa"."fat_foppa_CalendarioComercial" c ON (DATE_TRUNC('MONTH', m."Periodo") = DATE_TRUNC('MONTH', c.data) AND c.util::INTEGER = 1)
LEFT JOIN metas_colab col ON (m."Loja"::INTEGER = col."Loja"::INTEGER AND DATE_TRUNC('MONTH', m."Periodo") = DATE_TRUNC('MONTH', col."Periodo"))
LEFT JOIN "foppa"."fat_foppa_MetasporGruposdeProdutos" g ON (m."Loja"::INTEGER = g."Loja"::INTEGER AND DATE_TRUNC('YEAR', m."Periodo") = DATE_TRUNC('YEAR', g."Periodo"))
WHERE CAST(c.data AS DATE) <= '2020-10-31'::DATE