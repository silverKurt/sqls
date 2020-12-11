-- Source: Estoque
SELECT * FROM (
SELECT DISTINCT
	CAST("anomes" AS DATE) AS "periodo",
    CAST("Cod Material" AS TEXT) AS "Cod Material",
    CAST("Cod Especifico" AS TEXT) AS "Especificador",
    TRIM(TRIM(CAST("Cod Material" AS TEXT)) || TRIM(CAST("Cod Especifico" AS TEXT))) AS "Material_Especificador",
	RTRIM(TRIM(CAST("Material" AS TEXT)), ' -') AS "Material",
	CAST("Cor" AS TEXT) AS "Cor",
	CAST("Referencia" AS TEXT) AS "Referencia sem Cor",
	CAST("Origem Produto" AS TEXT) AS "Origem Produto",
	CAST("Grupo Material" AS TEXT) AS "Grupo Material",
	CAST("SubGrupo Material" AS TEXT) AS "SubGrupo Material",
	CAST("Centro de Armazenagem" AS TEXT) AS "Centro de Armazenagem",
	CAST("Unidade de Negócio" AS TEXT) AS "UnidadedeNegocio",
	CAST("Código da Fábrica" AS TEXT) AS "Código da Fábrica",
	CAST(NULL AS TEXT) AS "Centralizadora",
	CAST("Quantidade Estoque" AS DOUBLE PRECISION) AS "QuantidadeEstoque", 
	CAST(NULL AS DOUBLE PRECISION) AS "DemandaPedido",
	CAST(NULL AS TEXT) AS "Pedido",
	CAST(NULL AS TEXT) AS "Qtde Pedido"
FROM "ou"."fat_ou_Estoque") X 
WHERE "QuantidadeEstoque" <> 0.0
AND CAST("periodo" AS DATE) = DATE_TRUNC('MONTH', NOW())
--and "Material" ilike '%100200156%'

UNION ALL

-- Source: Demandas - Completo
SELECT 
	CAST("Periodo" AS DATE) AS "Periodo",
    CAST("Cod Material" AS TEXT) AS "Cod Material",
    CAST("Especificador" AS TEXT) AS "Especificador",
    TRIM(TRIM(CAST("Cod Material" AS TEXT)) || TRIM(CAST("Especificador" AS TEXT))) AS "Material_Especificador",
	CAST("Material" AS TEXT) AS "Material",
	CAST("Cor" AS TEXT) AS "Cor",
	CAST("Referencia sem Cor" AS TEXT) AS "Referencia sem Cor",
	CAST("Origem Produto" AS TEXT) AS "Origem Produto",
	CAST("Grupo Material" AS TEXT) AS "Grupo Material",
	CAST("SubGrupo Material" AS TEXT) AS "SubGrupo Material",
	CAST(NULL AS TEXT) AS "Centro de Armazenagem",
	CAST("Unidade de Negócio" AS TEXT) AS "Unidade de Negócio",
	CAST("Código da Fábrica" AS TEXT) AS "Código da Fábrica",
	CAST("Centralizadora" AS TEXT) AS "Centralizadora",
	CAST(NULL AS DOUBLE PRECISION) AS "QuantidadeEstoque",
	CAST("Demanda Pedido" AS DOUBLE PRECISION) AS "DemandaPedido",
	CAST(NULL AS TEXT) AS "Pedido",
	CAST(NULL AS TEXT) AS "Qtde Pedido"
FROM "ou"."fat_ou_DemandasCompleto"

UNION ALL

-- Source: Pedidos - Base
SELECT DISTINCT
	CAST("Periodo" AS DATE) AS "Periodo",
	CAST("codProduto" AS TEXT) AS "Cod Material",
	CAST("Especificador" AS TEXT) AS "Especificador",
	TRIM(TRIM(CAST("codProduto" AS TEXT)) || TRIM(CAST("Especificador" AS TEXT))) AS "Material_Especificador",
	CAST("Produto" AS TEXT) AS "Material",
	CAST("Cor" AS TEXT) AS "Cor",
	CAST(NULL AS TEXT) AS "Referencia sem Cor",
	CAST("Grupo Fabricação" AS TEXT) AS "Grupo Material",
	CAST("Sub Grupo Produto" AS TEXT) AS "SubGrupo Material",
	CAST(NULL AS TEXT) AS "Centro de Armazenagem",
	CAST("Unidade de Negócio" AS TEXT) AS "Unidade de Negócio",
	CAST("Código da Fábrica" AS TEXT) AS "Código da Fábrica",
	CAST(NULL AS TEXT) AS "Centralizadora",
	CAST(NULL AS DOUBLE PRECISION) AS "QuantidadeEstoque",
	CAST(NULL AS DOUBLE PRECISION) AS "DemandaPedido",
	CAST("Pedido" AS TEXT) AS "Pedido",
	CAST("Pedido" AS TEXT) AS "Qtde Pedido"
FROM "ou"."fat_ou_PedidosBase"
