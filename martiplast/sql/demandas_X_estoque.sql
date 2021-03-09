-- Source: Estoque
SELECT * FROM (
SELECT DISTINCT
	CAST(es."anomes" AS DATE) AS "periodo",
    CAST(es."Cod Material" AS TEXT) AS "Cod Material",
    CAST(es."Cod Especifico" AS TEXT) AS "Especificador",
    TRIM(TRIM(CAST(es."Cod Material" AS TEXT)) || TRIM(CAST(es."Cod Especifico" AS TEXT))) AS "Material_Especificador",
	RTRIM(TRIM(CAST(es."Material" AS TEXT)), ' -') AS "Material",
    CAST(es."Descricao Material" AS TEXT) AS "Descricao Material",
	CAST(es."Cor" AS TEXT) AS "Cor",
	CAST(es."Referencia" AS TEXT) AS "Referencia sem Cor",
    CAST(es."Cor Abre" AS TEXT) AS "Cor Abrev",
  	CASE WHEN (LTRIM(RTRIM(CAST(es."Cor Abre" AS TEXT))) IS NULL OR LTRIM(RTRIM(CAST(es."Cor Abre" AS TEXT))) = '') OR LTRIM(RTRIM(SPLIT_PART(CAST(es."Referencia" AS TEXT), '-', 1))) = '' THEN 'SEM COR OU REFERÊNCIA' 
    	  ELSE SPLIT_PART(CAST(es."Referencia" AS TEXT), '-', 1) || ' ' || CAST(es."Cor Abre" AS TEXT) 
    END AS "Referencia Cor",
	CAST(es."Origem Produto" AS TEXT) AS "Origem Produto",
	CAST(es."Grupo Material" AS TEXT) AS "Grupo Material",
	CAST(es."SubGrupo Material" AS TEXT) AS "SubGrupo Material",
	CAST(es."Centro de Armazenagem" AS TEXT) AS "Centro de Armazenagem",
	CAST(es."Unidade de Negócio" AS TEXT) AS "UnidadedeNegocio",
	CAST(es."Código da Fábrica" AS TEXT) AS "Código da Fábrica",
	CAST(NULL AS TEXT) AS "Centralizadora",
	CAST(es."Quantidade Estoque" AS DOUBLE PRECISION) AS "QuantidadeEstoque", 
	CAST(NULL AS DOUBLE PRECISION) AS "DemandaPedido",
	CAST(es."Sub Grupo Produto" AS TEXT) AS "Sub Grupo Produto",
	CAST(es."Linha Produto" AS TEXT) AS "Linha Produto"--,
    --CAST(tp."Pr_tabela" AS TEXT) AS "Tabela de Preços"
FROM "ou"."fat_ou_Estoque" es
--LEFT JOIN "ou"."fat_ou_TabeladePrecos" tp ON (CAST(tp."Cd_material" AS TEXT) = CAST(es."Cod Material" AS TEXT))
) X 
WHERE CAST("periodo" AS DATE) = DATE_TRUNC('MONTH', NOW())
AND "QuantidadeEstoque" <> 0
--and "Material" ilike '%100200156%'

UNION ALL

-- Source: Demandas - Completo
SELECT 
	CAST(dc."Periodo" AS DATE) AS "Periodo",
    CAST(dc."Cod Material" AS TEXT) AS "Cod Material",
    CAST(dc."Especificador" AS TEXT) AS "Especificador",
    TRIM(TRIM(CAST(dc."Cod Material" AS TEXT)) || TRIM(CAST(dc."Especificador" AS TEXT))) AS "Material_Especificador",
	CAST(dc."Material" AS TEXT) AS "Material",
    CAST(dc."Descricao Material" AS TEXT) AS "Descricao Material",
	CAST(dc."Cor" AS TEXT) AS "Cor",
	CAST(dc."Referencia sem Cor" AS TEXT) AS "Referencia sem Cor",
    CAST(dc."Cor Abre" AS TEXT) AS "Cor Abrev",
    CASE WHEN (LTRIM(RTRIM(CAST(dc."Cor Abre" AS TEXT))) IS NULL OR LTRIM(RTRIM(CAST(dc."Cor Abre" AS TEXT))) = '') OR LTRIM(RTRIM(SPLIT_PART(CAST(dc."Referencia sem Cor" AS TEXT), '-', 1))) = '' THEN 'SEM COR OU REFERÊNCIA' 
     	  ELSE SPLIT_PART(CAST(dc."Referencia sem Cor" AS TEXT), '-', 1) || ' ' || CAST(dc."Cor Abre" AS TEXT) 
    END AS "Referencia Cor",
	CAST(dc."Origem Produto" AS TEXT) AS "Origem Produto",
	CAST(dc."Grupo Material" AS TEXT) AS "Grupo Material",
	CAST(dc."SubGrupo Material" AS TEXT) AS "SubGrupo Material",
	CAST(NULL AS TEXT) AS "Centro de Armazenagem",
	CAST(dc."Unidade de Negócio" AS TEXT) AS "Unidade de Negócio",
	CAST(dc."Código da Fábrica" AS TEXT) AS "Código da Fábrica",
	CAST(dc."Centralizadora" AS TEXT) AS "Centralizadora",
	CAST(NULL AS DOUBLE PRECISION) AS "QuantidadeEstoque",
	CAST(dc."Demanda Pedido" AS DOUBLE PRECISION) AS "DemandaPedido",
	CAST(dc."Sub Grupo Produto" AS TEXT) AS "Sub Grupo Produto",
	CAST(dc."Linha Produto" AS TEXT) AS "Linha Produto"--,
    --CAST(tp."Pr_tabela" AS TEXT) AS "Tabela de Preços"
FROM "ou"."fat_ou_DemandasCompleto" dc
WHERE TRIM(CAST(dc."Liberação" AS TEXT)) <> ''
AND TRIM(CAST(dc."Tipo Demanda" AS TEXT)) <> 'DDP'
