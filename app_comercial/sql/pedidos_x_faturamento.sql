WITH empresas AS (
    --ESSA ESTRUTURA SERVE PÁRA TRAZER O NOME DA EMPRESA DO ARQUVIO DE METAS, CASO NÃO HAJA NA TABELA DE FATURAMENTO
    SELECT DISTINCT
        CAST("cod_empresa" AS TEXT) AS "cod_empresa",
        CAST("empresa" AS TEXT) AS "empresa"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase"
)

, dias_uteis_mes AS (
    --ESSA ESTRUTURA SERVE PARA TRAZER OS DIAS UTEIS DO MÊS, QUE SERVIRÃO PARA A DIARIZAÇÃO DE META E CÁLCULO DE TENDÊNCIA
    SELECT
        CAST(DATE_TRUNC('MONTH', "data") AS DATE) AS "mes_referencia"
        , CAST("cod_empresa" AS TEXT) AS "cod_empresa"
        , SUM("util") AS "dias_uteis_mes"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Calendario"
    GROUP BY 1,2
)
, dias_uteis_corridos_mes AS (
    -- ESSA ESTRUTURA TRAZ OS DIAS UTEIS CORRIDOS NO MÊS, CONSIDERANDO O DIA DA CARGA COMO DIA ATUAL
    SELECT
        CAST(DATE_TRUNC('MONTH', "data") AS DATE) AS "mes_referencia"
        , CAST("cod_empresa" AS TEXT) AS "cod_empresa"
        , SUM("util") AS "dias_uteis_corridos"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Calendario"
    WHERE "data" <= now()::date
    GROUP BY 1,2
)

SELECT 
    CAST(p."data" AS DATE)                                                                                          AS "data"
    , COALESCE(CAST(m."empresa" AS TEXT), CAST(emp."empresa" AS TEXT))                                              AS "empresa"
    --, CAST(m."cod_representante" AS TEXT)                                                                         AS "cod_representante"
    , CAST(m."representante" AS TEXT)                                                                               AS "representante"
    , CASE WHEN COALESCE(CAST(m."meta" AS DOUBLE PRECISION), 0) > 0 THEN 'VENDA' ELSE NULL END                      AS "tipo_faturamento"
    --, CAST(m."cod_supervisor" AS TEXT)                                                                              AS "codsupervisor" 
    , CAST(m."supervisor" AS TEXT)                                                                                  AS "supervisor"

    , (CAST(m."meta" AS DOUBLE PRECISION) / CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION))                         AS "meta" 
    , (CAST(m."qtd_meta" AS DOUBLE PRECISION) / CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION))                     AS "qtd_meta"
    , (CAST(m."volume_meta" AS DOUBLE PRECISION) / CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION))                  AS "volume_meta"

    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "qtd"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "volume"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "faturamento"

    , CASE WHEN COALESCE(m."meta", 0) > 0 THEN CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION) ELSE NULL END         AS "dias_uteis_mes"
    , CASE WHEN COALESCE(m."meta", 0) > 0 THEN CAST(dcm."dias_uteis_corridos" AS DOUBLE PRECISION) ELSE NULL END    AS "dias_uteis_corridos_mes"
    
    , CAST(NULL AS TEXT)                                                                                            AS "cod_pedido"
    , CAST(NULL AS TEXT)                                                                                            AS "cliente"
    , CAST(NULL AS DATE)                                                                                            AS "data_prev_entrega"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "valor_pedido"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "quantidade_pedido"

    /*, CASE WHEN COALESCE(m."meta", 0) > 0 THEN dua."DIAS_UTEIS_ANO" ELSE NULL END as "dias_uteis_ano"
    , CASE WHEN COALESCE(m."meta", 0) > 0 THEN dca."DIAS_UTEIS_CORRIDOS_ANO" ELSE NULL END as "dias_uteis_corridos_ano"*/
FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Metas" m
LEFT JOIN "appgestaocomercialv3"."fat_appgestaocomercialv3_Calendario" p ON (CAST(DATE_TRUNC('MONTH', m."data") AS DATE) = CAST(DATE_TRUNC('MONTH', p."data") AS DATE) AND p."util"::INTEGER = 1)

LEFT JOIN empresas emp ON ((p."cod_empresa"::TEXT)= (emp."cod_empresa"::TEXT))
LEFT JOIN dias_uteis_mes dum ON (CAST(DATE_TRUNC('MONTH', p."data") AS DATE) = CAST(dum."mes_referencia" AS DATE))
LEFT JOIN dias_uteis_corridos_mes dcm ON (CAST(DATE_TRUNC('MONTH', p."data") AS DATE) = CAST(dcm."mes_referencia" AS DATE))

WHERE DATE_TRUNC('YEAR', CAST(p."data" AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL
/*LEFT JOIN dias_uteis_ano dua ON (CAST(DATE_TRUNC('YEAR', p."data") AS DATE) = CAST(dua."ano_referencia" AS DATE))
LEFT JOIN dias_uteis_corridos_ano dca ON (CAST(DATE_TRUNC('YEAR', p."data") AS DATE) = CAST(dca."ano_referencia" AS DATE))*/

UNION ALL

SELECT
    CAST("data" AS DATE)                                                                                            AS "data"
    , CAST("empresa" AS TEXT)                                                                                       AS "empresa"
    --, CAST("cod_representante" AS TEXT)                                                                           AS "cod_representante"
    , CAST("representante" AS TEXT)                                                                                 AS "representante"
    , CAST("tipo_faturamento" AS TEXT)                                                                              AS "tipo_faturamento"
    --, CAST("cod_supervisor" AS TEXT)                                                                                AS "codsupervisor" 
    , CAST("supervisor" AS TEXT)                                                                                    AS "supervisor"

    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "meta"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "qtd_meta"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "volume_meta"

    , CAST("qtd" AS DOUBLE PRECISION)                                                                               AS "qtd"
    , CAST("volume" AS DOUBLE PRECISION)                                                                            AS "volume"
    , CAST("faturamento" AS DOUBLE PRECISION)                                                                       AS "faturamento"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "dias_uteis_mes"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "dias_uteis_corridos_mes"

    , CAST(NULL AS TEXT)                                                                                            AS "cod_pedido"
    , CAST(NULL AS TEXT)                                                                                            AS "cliente"
    , CAST(NULL AS DATE)                                                                                            AS "data_prev_entrega"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "valor_pedido"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "quantidade_pedido"

    /*, CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_ano
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_ano*/
FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase"
WHERE DATE_TRUNC('YEAR', CAST("data" AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL

UNION ALL

-- Source: Pedidos
SELECT 
    CAST("data" AS DATE)                                                                                            AS "data"
    , CAST(NULL AS TEXT)                                                                                            AS "empresa"
    --, CAST("cod_representante" AS TEXT)                                                                           AS "cod_representante" 
    , CAST("representante" AS TEXT)                                                                                 AS "representante"
    , CAST(NULL AS TEXT)                                                                                            AS "tipo_faturamento"
    --, CAST(NULL AS TEXT)                                                                                            AS "codsupervisor" 
    , CAST(NULL AS TEXT)                                                                                            AS "supervisor"

    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "meta"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "qtd_meta"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "volume_meta"

    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "qtd"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "volume"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "faturamento"

    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "dias_uteis_mes"
    , CAST(NULL AS DOUBLE PRECISION)                                                                                AS "dias_uteis_corridos_mes"

    , CAST("cod_pedido" AS TEXT)                                                                                    AS "cod_pedido"
    , CAST("cliente" AS TEXT)                                                                                       AS "cliente"
    , CAST("data_prev_entrega" AS DATE)                                                                             AS "data_prev_entrega"
    , CAST("valor_pedido" AS DOUBLE PRECISION)                                                                      AS "valor_pedido"
    , CAST("quantidade" AS DOUBLE PRECISION)                                                                        AS "quantidade_pedido"

FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Pedidos"
WHERE DATE_TRUNC('YEAR', CAST("data" AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL