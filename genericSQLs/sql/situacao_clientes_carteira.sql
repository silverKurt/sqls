	/*UNIR COM ESTRUTURA PRINCIPAL TRUNCANDO A DATA EMISSÃO (PERÍODO) E CÓDIGO DE CLIENTE*/
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
			/*EDITAR APENAS AQUI*/
        	SELECT DISTINCT
            	CAST(fu."Qtde Clientes" AS TEXT) AS "Cliente"
            	, CAST(fu."Periodo" AS DATE) AS "Periodo"
            	, CAST(fu."Periodo Ultima Compra" AS DATE) AS "data_ultima_compra"
        	FROM "ou"."fat_ou_FaturamentoDiarizacao" fu
        	--WHERE fu."COD_CLI" = '2275'
        	ORDER BY CAST(fu."Periodo" AS DATE)
    	) x
  	) y
	WHERE DATE_TRUNC('MONTH', y."periodo") <> DATE_TRUNC('MONTH', y."compra_anterior")
	ORDER BY y."Cliente", y."periodo"