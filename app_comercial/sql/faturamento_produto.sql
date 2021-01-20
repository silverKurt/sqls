-- Source: Faturamento Produto
SELECT

    DATE_TRUNC('MONTH',CAST("data" AS DATE))          AS "data"
    , CAST("representante" AS TEXT)                   AS "representante"
    , CAST("cliente" AS TEXT)                         AS "cliente"
    , CAST("pais" AS TEXT)                            AS "pais"
    , CAST("estado" AS TEXT)                          AS "estado"
    , CAST("cidade" AS TEXT)                          AS "cidade"
    , CAST("grupo_produto" AS TEXT)                   AS "grupo_produto"
    , CAST("marca_produto" AS TEXT)                   AS "marca_produto"
    , CAST("produto" AS TEXT)                         AS "produto"
    , CAST("tipo_faturamento" AS TEXT)                AS "tipo_faturamento"
    , CAST("empresa" AS TEXT)                         AS "empresa"
    , CAST("supervisor" AS TEXT)                      AS "supervisor"
    
    , CAST("cod_cliente" AS TEXT)                     AS "qtdcliente"
    , CAST("cod_produto" AS TEXT)                     AS "qtdproduto"
    , CAST("subgrupo_produto" AS TEXT)                AS "qtdmarca"
    , CAST("grupo_produto" AS TEXT)                   AS "qtdgrupoproduto"

    , CASE WHEN CAST("estado" AS TEXT) IN ('RS', 'SC', 'PR') THEN 'SUL'
           WHEN CAST("estado" AS TEXT) IN ('SP', 'MG', 'RJ', 'ES') THEN 'SUDESTE'
           WHEN CAST("estado" AS TEXT) IN ('GO', 'MS', 'MT', 'DF') THEN 'CENTRO OESTE'
           WHEN CAST("estado" AS TEXT) IN ('BA', 'PI', 'MA', 'CE', 'PE', 'SE', 'AL', 'PB','RN') THEN 'NORDESTE'
           WHEN CAST("estado" AS TEXT) IN ('AM', 'PA', 'TO', 'AP','RO', 'AC', 'RR') THEN 'NORTE'
    END AS "regiao"

    --COUNT(DISTINCT CAST("nota_fiscal" AS TEXT))   AS "qtd_notas",
    
    , SUM(CAST("qtd" AS DOUBLE PRECISION))          AS "qtd"
    , SUM(CAST("volume" AS DOUBLE PRECISION))       AS "volume"
    , SUM(CAST("faturamento" AS DOUBLE PRECISION))  AS "faturamento"

FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase"
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16