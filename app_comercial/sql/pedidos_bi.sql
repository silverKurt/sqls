-- Source: pedidos
SELECT 
	CAST("cliente" AS TEXT) 
	, CAST("marca_produto" AS TEXT)
	, CAST("representante" AS TEXT) 
	, CAST("subgrupo_produto" AS TEXT)
	, CAST("pais" AS TEXT) 
	, CAST("estado" AS TEXT) 
	, CAST("cod_pedido" AS TEXT)
	, CAST("produto" AS TEXT)
	, CAST("cfop" AS TEXT) 
	, CAST("cod_cliente" AS TEXT)
	, CAST("data" AS DATE) 
	, CAST("data_prev_entrega" AS DATE)
	, CAST("status" AS TEXT)
	, CAST("data_venda" AS DATE)
	, CAST("cidade" AS TEXT)
	, CAST("cod_produto" AS TEXT)
	, CAST("cod_representante" AS TEXT)
	, CAST("cep" AS TEXT) 
	, CAST("geo" AS TEXT) 
	, CAST("grupo_produto" AS TEXT) 
	, CAST("quantidade" AS DOUBLE PRECISION)
	, CAST("volume" AS DOUBLE PRECISION) 
	, CAST("valor_pedido" AS DOUBLE PRECISION) 
FROM "dadosparaapp"."fat_dadosparaapp_pedidos"