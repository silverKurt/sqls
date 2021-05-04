SELECT
    data_pedido as data
    , null::text as cod_representante
	, null::text as representante
	, null::text as cod_supervisor
	, null::text as supervisor
    , cod_cliente
    , nome_cliente as cliente
    , null::text as pais
	, null::text as estado
	, null::text as cidade
	, null::text as cep
	, COALESCE(endereco_gps::text, 'NÃO INFORMADO') as geo
    , classe_produto as grupo_produto
    , sub_classe_produto as subgrupo_produto
    , categoria_produto as marca_produto
    , cod_produto
    , nome_produto as produto
    , 'VENDA' as tipo_faturamento
    , unidade as cod_empresa
    , unidade as empresa
    , cod_pedido as nota_fiscal
    , REPLACE(qtd_produto, ',', '.')::DOUBLE PRECISION AS qtd
    , 0::DOUBLE PRECISION AS volume
    , REPLACE(valor_total_pedido, ',', '.')::DOUBLE PRECISION AS faturamento
FROM pedidos_com_pagamento
WHERE
    UPPER(TRIM(unidade)) != 'NAO INFORMADO'
    AND UPPER(TRIM(tipo_unidade)) != 'NAO INFORMADO'
    AND data_pedido > '2020-08-01'
    AND UPPER(status_pedido) != 'ORCAMENTO'
    AND UPPER(status_pedido) != 'CANCELADO'
    AND venda_devolvido IS NULL

UNION ALL

SELECT
    data_pedido as data
    , null::text as cod_representante
	, null::text as representante
	, null::text as cod_supervisor
	, null::text as supervisor
    , cod_cliente
    , nome_cliente as cliente
    , null::text as pais
	, null::text as estado
	, null::text as cidade
	, null::text as cep
	, COALESCE(endereco_gps::text, 'NÃO INFORMADO') as geo
    , classe_produto as grupo_produto
    , sub_classe_produto as subgrupo_produto
    , categoria_produto as marca_produto
    , cod_produto
    , nome_produto as produto
    , 'DEVOLUÇÃO' as tipo_faturamento
    , unidade as cod_empresa
    , unidade as empresa
    , cod_pedido as nota_fiscal
    , REPLACE(qtd_devolvida, ',', '.')::DOUBLE PRECISION*-1 AS qtd
    , 0::DOUBLE PRECISION AS volume
    , Coalesce(REPLACE(venda_devolvido, ',', '.')::DOUBLE PRECISION,0) *-1 AS faturamento
FROM pedidos_com_pagamento
WHERE
    UPPER(TRIM(unidade)) != 'NAO INFORMADO'
    AND UPPER(TRIM(tipo_unidade)) != 'NAO INFORMADO'
    AND data_pedido > '2020-08-01'
    AND UPPER(status_pedido) != 'ORCAMENTO'
    AND UPPER(status_pedido) != 'CANCELADO'
    AND venda_devolvido IS NOT NULL

