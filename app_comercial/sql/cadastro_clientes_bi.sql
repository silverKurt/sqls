-- Source: cadastro_cliente
SELECT 
	CAST("segmento_cliente" AS TEXT)
	, CAST("cnpj_cliente" AS TEXT)
	, CAST("data_cadastro" AS DATE)
	, CAST("status_cliente" AS TEXT)
	, CAST("pais" AS TEXT) 
	, CAST("cliente" AS TEXT)
	, CAST("cod_representante" AS TEXT)
	, CAST("estado" AS TEXT) 
	, CAST("cidade" AS TEXT) 
	, CAST("email" AS TEXT)
	, CAST("bairro" AS TEXT) 
	, CAST("endereco" AS TEXT)
	, CAST("regiao" AS TEXT) 
	, CAST("data_inativacao" AS TEXT)
	, CAST("telefone" AS TEXT)
	, CAST("cod_cliente" AS DOUBLE PRECISION)
FROM "dadosparaapp"."fat_dadosparaapp_cadastrocliente"