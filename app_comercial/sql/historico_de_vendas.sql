WITH historico_de_compras AS (
/*Necessário fazer compra anterior no lado de fora, pois se fazer dentro algumas informações são duplicadas*/
SELECT CAST(x."cod_cliente" AS TEXT)                                            AS "cod_cliente"
    , CAST(x."data" AS DATE)                                                    AS "data"
    /*É necessário trazer a data da compra anterior e a data da próxima compra para realizar 
    o preenchimento dinâmico da linha do tempo do cadastro*/
    , CAST(COALESCE(LAG(x."data",1) OVER (PARTITION BY x."cod_cliente" ORDER BY x."cod_cliente", x."data"), '1900-01-01') AS DATE) AS "compra_anterior"
    , CAST(COALESCE(LEAD(x."data",1) OVER (PARTITION BY x."cod_cliente" ORDER BY x."cod_cliente", x."data"), '2099-01-01') AS DATE) AS "proxima_compra"
FROM (
    /*Unificação das linhas do tempo sem intervalo adicional para pegar os períodos reais de venda*/
    SELECT DISTINCT *
    FROM (
    SELECT 
        CAST("cod_cliente" AS TEXT)                                             AS "cod_cliente"
       	, CAST(DATE_TRUNC('MONTH', CAST("data_cadastro" AS DATE)) AS DATE)      AS "data"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_CadastrodeClientes"

    UNION ALL

    SELECT DISTINCT
        CAST(fb."cod_cliente" AS TEXT)                                          AS "cod_cliente"
        , DATE_TRUNC('MONTH', CAST(fb."data" AS DATE))::DATE                    AS "data"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase" fb

) uniao
ORDER BY 1,2
) x

)

, representantes AS (

    SELECT DISTINCT
        CAST(fb."cod_representante" AS TEXT)                                    AS "cod_representante"
        , CAST(fb."representante" AS TEXT)                                      AS "representante"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase" fb

)

, linha_do_tempo_cadastro AS (
    /*A linha do tempo do cadastro é aquela responsável por regulamentar 
    os meses em que o cliente permaneceu como cadastrado no histórico da empresa*/
    SELECT DISTINCT
        CAST("cod_cliente" AS TEXT)                                             AS "cod_cliente"
   	    , CAST(DATE_TRUNC('MONTH', CAST("data_cadastro" AS DATE)) AS DATE)      AS "data_cadastro"
        , CAST(GENERATE_SERIES(
      	    CAST(DATE_TRUNC('MONTH', CAST("data_cadastro" AS DATE)) AS DATE), 
            DATE_TRUNC('MONTH', COALESCE((CASE WHEN "data_inativacao"::TEXT = '' THEN NULL ELSE "data_inativacao" END), NOW()::DATE::TEXT)::DATE), 
            '1 MONTH'::INTERVAL
        ) AS DATE)                                                              AS "data"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_CadastrodeClientes"


), classificacao_clientes AS (
    SELECT 
      *
      /*Primeiramente verificamos se a data de cadastro do cliente é 
      a mesma da linha do tempo para classificarmos como primeira vez que o cliente comprou*/
      , CASE WHEN "linha_tempo_cad" = "data_cadastro" THEN 'CLIENTE NOVO'
             /*A data da venda é aquela da linha do tempo de Faturamento Base, ou seja, são as compras que o cliente fez.
             Para testarmos a recaptura, devido a junção do JOIN abaixo, primeiro precisamos verificar se a linha do tempo de cadastro
             corresponde a linha do tempo do faturamento. Após isso, verificamos a compra anterior em relação a data de venda.*/
             WHEN ("data_venda" = "linha_tempo_cad") AND (("data_venda"::DATE - "compra_anterior"::DATE) > 180) THEN 'CLIENTE RECAPTURADO'
             WHEN ("linha_tempo_cad" - "data_venda") <= 180 THEN 'CLIENTE ATIVO'
             WHEN ("linha_tempo_cad" - "data_venda") >= 180 THEN 'CLIENTE INATIVO'
        END AS "status_cliente"
    FROM (
        SELECT 
            CAST(ltc."data" AS DATE)                                        AS "linha_tempo_cad"
            , CAST(ltc."cod_cliente" AS TEXT)                               AS "cod_cliente" 
            , CAST(ltc."data_cadastro" AS DATE)                             AS "data_cadastro"
            , CAST(hc."compra_anterior" AS DATE)                            AS "compra_anterior"
            , CAST(hc."data" AS DATE)                                       AS "data_venda"
        FROM linha_do_tempo_cadastro ltc
        /*Essa junção é necessária para fazer os ATIVOS e INATIVOS corretamente, 
        eu preciso dos valores em todas as linhas e com a igualdade de datas não é possível fazer*/
        LEFT JOIN historico_de_compras hc ON ((CAST(ltc."data" AS DATE) >= CAST(hc."data" AS DATE) AND CAST(ltc."data" AS DATE) < CAST("proxima_compra" AS DATE)) AND CAST(ltc."cod_cliente" AS TEXT) = CAST(hc."cod_cliente" AS TEXT))
        ORDER BY 1,2

    ) y
    --WHERE "cod_cliente" = '1002'
), clientes AS(
    SELECT DISTINCT 
        CAST(cc."cod_cliente" AS TEXT)                                      AS "cod_cliente"
        , CAST(cc."cliente" AS TEXT)                                        AS "cliente"
        , CAST(cc."cidade" AS TEXT)                                         AS "cidade"
        , CAST(cc."estado" AS TEXT)                                         AS "estado"
        , CAST(cc."pais" AS TEXT)                                           AS "pais"
        , CAST(cc."bairro" AS TEXT)                                         AS "bairro"
        , CAST(cc."endereco" AS TEXT)                                       AS "endereco"
        , CAST(cc."segmento_cliente" AS TEXT)                               AS "segmento_cliente"
        , CAST(cc."email" AS TEXT)                                          AS "email"
        , CAST(cc."telefone" AS TEXT)                                       AS "telefone"
        --, CAST(r."representante" AS TEXT)                                   AS "representante"
        , CAST(cc."regiao" AS TEXT)                                         AS "regiao"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_CadastrodeClientes" cc
)
SELECT 
    CAST(cc."linha_tempo_cad" AS DATE)                                      AS "data"
    , CAST(cc."cod_cliente" AS TEXT)                                        AS "cod_cliente"
    , CAST(cc."status_cliente" AS TEXT)                                     AS "status"
    , CAST(c."cliente" AS TEXT)                                             AS "cliente"
    , CAST(c."cidade" AS TEXT)                                              AS "cidade"
    , CAST(c."estado" AS TEXT)                                              AS "estado"
    , CAST(c."pais" AS TEXT)                                                AS "pais"
    , CAST(c."bairro" AS TEXT)                                              AS "bairro"
    , CAST(c."endereco" AS TEXT)                                            AS "endereco"
    , CAST(c."segmento_cliente" AS TEXT)                                    AS "segmento_cliente"
    , CAST(fb."cod_representante" AS TEXT)                                  AS "cod_representante"
    , CAST(fb."representante" AS TEXT)                                      AS "representante"
    , CAST(fb."empresa" AS TEXT)                                            AS "empresa"
    , CAST(c."regiao" AS TEXT)                                              AS "regiao"
    , CASE WHEN SUM(CAST("faturamento" AS DOUBLE PRECISION)) IS NULL THEN 0 ELSE SUM(CASE WHEN CAST("tipo_faturamento" AS TEXT) = 'VENDA' THEN CAST("faturamento" AS DOUBLE PRECISION) ELSE NULL END) END AS "faturamento" 
    , CASE WHEN SUM(CAST("faturamento" AS DOUBLE PRECISION)) IS NULL THEN 'NÃO' ELSE 'SIM' END AS "houve_faturamento" 
FROM classificacao_clientes cc
LEFT JOIN clientes c ON (c."cod_cliente" = cc."cod_cliente")
LEFT JOIN "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase" fb ON (c."cod_cliente" = fb."cod_cliente" AND DATE_TRUNC('MONTH', fb."data") = cc."linha_tempo_cad")
--WHERE CAST(cc."linha_tempo_cad" AS DATE) >= '2020-01-01'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14