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

, dias_uteis_ano AS (
    -- ESSA ESTRUTURA TRAZ OS DIAS UTEIS NO ANO, PODE SERVIR PARA CÁLCULO DE TENDÊNCIA NO ANO CASO OPTE POR "util"IZAR OS DIAS ÚTEIS
    SELECT
        CAST(DATE_TRUNC('YEAR', "data") AS DATE) AS "ano_referencia"
        , CAST("cod_empresa" AS TEXT) AS "cod_empresa"
        , SUM("util") AS "dias_uteis_ano"
     FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Calendario"
     GROUP BY 1,2
)

, dias_uteis_corridos_ano AS (
    --ESSA ESTRUTURA TRAZ OS DIAS UTEIS CORRIDOS NO ANO
    SELECT
        CAST(DATE_TRUNC('YEAR', "data") AS DATE) AS "ano_referencia"
        , CAST("cod_empresa" AS TEXT) AS "cod_empresa"
        , SUM("util")  AS "dias_uteis_corridos_ano"
    FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Calendario"
    WHERE "data" <= NOW()::DATE
    GROUP BY 1,2
)

SELECT 
    CAST(m."cod_representante" AS TEXT) AS "cod_representante"
    , CAST(m."representante" AS TEXT) AS "representante"
    , COALESCE(CAST(m."empresa" AS TEXT), CAST(emp."empresa" AS TEXT)) AS "empresa"
    , CASE WHEN COALESCE(CAST(m."meta" AS DOUBLE PRECISION), 0) > 0 THEN 'VENDA' ELSE NULL END AS "tipo_faturamento"
    , CAST(p."data" AS DATE) AS "data"

    , (CAST(m."meta" AS DOUBLE PRECISION) / CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION)) AS "meta" 
    , (CAST(m."qtd_meta" AS DOUBLE PRECISION) / CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION)) AS "qtd_meta"
    , (CAST(m."volume_meta" AS DOUBLE PRECISION) / CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION)) AS "volume_meta"

    , CAST(NULL AS DOUBLE PRECISION) AS "qtd"
    , CAST(NULL AS DOUBLE PRECISION) AS "volume"
    , CAST(NULL AS DOUBLE PRECISION) AS "faturamento"

    , CASE WHEN COALESCE(m."meta", 0) > 0 THEN CAST(dum."dias_uteis_mes" AS DOUBLE PRECISION) ELSE NULL END as "dias_uteis_mes"
    , CASE WHEN COALESCE(m."meta", 0) > 0 THEN CAST(dcm."dias_uteis_corridos" AS DOUBLE PRECISION) ELSE NULL END as "dias_uteis_corridos_mes"
    
    /*, CASE WHEN COALESCE(m."meta", 0) > 0 THEN dua."DIAS_UTEIS_ANO" ELSE NULL END as "dias_uteis_ano"
    , CASE WHEN COALESCE(m."meta", 0) > 0 THEN dca."DIAS_UTEIS_CORRIDOS_ANO" ELSE NULL END as "dias_uteis_corridos_ano"*/
FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_Metas" m
LEFT JOIN "appgestaocomercialv3"."fat_appgestaocomercialv3_Calendario" p ON (
    CAST(DATE_TRUNC('MONTH', m."data") AS DATE) = CAST(DATE_TRUNC('MONTH', p."data") AS DATE)
AND p."util"::INTEGER = 1)

LEFT JOIN empresas emp ON ((p."cod_empresa"::TEXT)= (emp."cod_empresa"::TEXT))
LEFT JOIN dias_uteis_mes dum ON (CAST(DATE_TRUNC('MONTH', p."data") AS DATE) = CAST(dum."mes_referencia" AS DATE))
LEFT JOIN dias_uteis_corridos_mes dcm ON (CAST(DATE_TRUNC('MONTH', p."data") AS DATE) = CAST(dcm."mes_referencia" AS DATE))

WHERE DATE_TRUNC('YEAR', CAST(p."data" AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL
/*LEFT JOIN dias_uteis_ano dua ON (CAST(DATE_TRUNC('YEAR', p."data") AS DATE) = CAST(dua."ano_referencia" AS DATE))
LEFT JOIN dias_uteis_corridos_ano dca ON (CAST(DATE_TRUNC('YEAR', p."data") AS DATE) = CAST(dca."ano_referencia" AS DATE))*/

UNION ALL

SELECT
    CAST("cod_representante" AS TEXT) AS "cod_representante"
    , CAST("representante" AS TEXT) AS "representante"
    , CAST("empresa" AS TEXT) AS "empresa"
    , CAST("tipo_faturamento" AS TEXT) AS "tipo_faturamento"
    , CAST("data" AS DATE) AS "data"
    
    , CAST(NULL AS DOUBLE PRECISION) AS "meta"
    , CAST(NULL AS DOUBLE PRECISION) AS "qtd_meta"
    , CAST(NULL AS DOUBLE PRECISION) AS "volume_meta"

    , CAST("qtd" AS DOUBLE PRECISION) AS "qtd"
    , CAST("volume" AS DOUBLE PRECISION) AS "volume"
    , CAST("faturamento" AS DOUBLE PRECISION) AS "faturamento"

    , CAST(NULL AS DOUBLE PRECISION) AS "dias_uteis_mes"
    , CAST(NULL AS DOUBLE PRECISION) AS "dias_uteis_corridos_mes"

    /*, CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_ano
    , CAST(NULL AS DOUBLE PRECISION) AS dias_uteis_corridos_ano*/
FROM "appgestaocomercialv3"."fat_appgestaocomercialv3_FaturamentoBase"
WHERE DATE_TRUNC('YEAR', CAST("data" AS DATE)) >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL