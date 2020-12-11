
SELECT 
	DATE_TRUNC('MONTH', CAST("Periodo Emissão" AS DATE)) AS "PeriodoEmissao",
	CAST("Familia" AS TEXT) AS "Familia",
	CAST("Cliente Agrupador" AS TEXT) AS "ClienteAgrupador",
	CAST("Tipo Frente" AS TEXT) AS "TipoFrente",
	CAST("Apresentacao" AS TEXT) AS "Apresentacao",
	CAST("Tipo Faturamento" AS TEXT) AS "TipoFaturamento",
	CAST("Novos Canais Geograficos" AS TEXT) AS "NovosCanaisGeograficos",
	
	SUM(CAST("Qtde Unitaria" AS DOUBLE PRECISION)) AS "QtdeUnitaria",
	SUM(CAST("Vlr  Produtos" AS DOUBLE PRECISION)) AS "VlrProdutos",
	SUM(CAST("DESC_ZF" AS DOUBLE PRECISION)) AS "DESCZF",
	SUM(CAST("Vlr Desconto" AS DOUBLE PRECISION)) AS "VlrDesconto"

FROM "miolo"."fat_miolo_Faturamento"
GROUP BY 1,2,3,4,5,6,7