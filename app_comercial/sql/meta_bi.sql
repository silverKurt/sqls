-- Source: meta
SELECT 
	CAST("cod_representante" AS TEXT)
	, CAST("supervisor" AS TEXT) 
	, CAST("cod_supervisor" AS TEXT)
	, CAST("cod_empresa" AS TEXT) 
	, CAST("representante" AS TEXT)
	, CAST("empresa" AS TEXT)
	, CAST("data" AS DATE) 
	, CAST("qtd_meta" AS DOUBLE PRECISION)
	, CAST("meta" AS DOUBLE PRECISION) 
	, CAST("volume_meta" AS DOUBLE PRECISION)  
FROM "dadosparaapp"."fat_dadosparaapp_meta"