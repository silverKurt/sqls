-- Source: Faturamento Base
SELECT 
    CAST("data" AS DATE)                            AS "data"
    , CAST("representante" AS TEXT)                 AS "representante"
    , CAST("cliente" AS TEXT)                       AS "cliente"
    , CAST("pais" AS TEXT)                          AS "pais"
    , CAST("estado" AS TEXT)                        AS "estado"
    , CAST("cidade" AS TEXT)                        AS "cidade"
    , CAST("geo" AS TEXT)                           AS "geo"
    , CAST("tipo_faturamento" AS TEXT)              AS "tipo_faturame"
    , CAST("empresa" AS TEXT)                       AS "empresa"
    , CAST("cep" AS TEXT)                           AS "cep"
    , CAST("cod_supervisor" AS TEXT)                AS "cod_supervisor"
    , CAST("supervisor" AS TEXT)                    AS "supervisor"
    , CAST("cod_representante" AS TEXT)             AS "cod_represent"
    , CAST("cod_cliente" AS TEXT)                   AS "cod_cliente"
    , CAST("nota_fiscal" AS TEXT)                   AS "nota_fiscal"
    
    , CASE WHEN CAST("estado" AS TEXT) IN ('RS', 'SC', 'PR') THEN 'SUL'
           WHEN CAST("estado" AS TEXT) IN ('SP', 'MG', 'RJ', 'ES') THEN 'SUDESTE'
           WHEN CAST("estado" AS TEXT) IN ('GO', 'MS', 'MT', 'DF') THEN 'CENTRO OESTE'
           WHEN CAST("estado" AS TEXT) IN ('BA', 'PI', 'MA', 'CE', 'PE', 'SE', 'AL', 'PB','RN') THEN 'NORDESTE'
           WHEN CAST("estado" AS TEXT) IN ('AM', 'PA', 'TO', 'AP','RO', 'AC', 'RR') THEN 'NORTE'
    END AS "regiao"
    
    /*MEDIDAS FÍSICAS*/
    , SUM(CAST("qtd" AS DOUBLE PRECISION))          AS "qtd"
    , SUM(CAST("volume" AS DOUBLE PRECISION))       AS "volume"

    /*MEDIDAS MONETÁRIAS*/
    , SUM(CAST("faturamento" AS DOUBLE PRECISION))  AS "faturamento"

FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase"
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17