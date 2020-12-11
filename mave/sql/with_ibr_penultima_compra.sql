with fat_union as (
-- Source: Faturamento - Base B    
SELECT 
      CAST(B."COD_GRUPO_CLI" AS TEXT)
    , CAST(B."COD_ITEM" AS TEXT)
    , CAST(B."COD_FILIAL" AS TEXT)
    , CAST(B."DT_PENULTIMA_FAT" AS DATE)
    , CAST(B."GEO_CLI" AS TEXT)
    , SPLIT_PART(B."GEO_CLI", ',', 2) AS "ESTADO"
    , CAST(B."DT_EMISSAO" AS DATE)
    , CAST(B."SITUACAO_CLIENTES" AS TEXT)
    , CAST(B."FAIXA DE FREQUÊNCIA" AS TEXT)
    , CAST(B."EMPRESA_FANTASIA" AS TEXT)
    , CAST(B."EMPRESA_RAZÃO" AS TEXT)
    , CAST(B."Grupo" AS TEXT)
    , CAST(B."NAT_OPER" AS TEXT)
    , CAST(B."DT_ULTIMA_FAT_GEO" AS TEXT)
    , CAST(B."NUM_NF" AS TEXT)
    , CAST(B."CLIENTE" AS TEXT)
    , CAST(B."GRUPO_NAT_OPER" AS TEXT)
    , CAST(B."REPRESENTANTE" AS TEXT)
    , CAST(B."DT_ULTIMA_FAT" AS DATE)
    , CAST(B."DT_PRIMEIRA_FAT" AS DATE)
    , CAST(B."SubGrupo" AS TEXT)
    , CAST(B."CLASSIFICAÇÃO DE RECÊNCIA" AS TEXT)
    , CAST(B."FAIXA DE RECÊNCIA" AS TEXT)
    , CAST(B."GRUPO_CLI" AS TEXT)
    , CAST(B."TRANSPORTADORA" AS TEXT)
    , CAST(B."FAIXA DE VALOR" AS TEXT)
    , CAST(B."ITEM_DESCRICAO" AS TEXT)
    , CAST(B."VALOR_UNIT_MEDIO" AS DOUBLE PRECISION)
    , CAST(B."COD_CLI" AS TEXT)
    , CAST(B."FRETE" AS DOUBLE PRECISION)
    , CAST(B."PESO_LIQ" AS DOUBLE PRECISION)
    , CAST(B."COFINS" AS DOUBLE PRECISION)
 --   , CAST(B."Vlr_Custo_Unit" AS DOUBLE PRECISION)
    ,(SELECT MAX(CAST(A."Vlr_Custo_Unit" AS DOUBLE PRECISION)) FROM 
        "mave"."fat_mave_FaturamentoBaseA" A WHERE CAST(B."COD_ITEM" AS TEXT) = CAST(A."COD_ITEM" AS TEXT) LIMIT 1) AS "Vlr_Custo_Unit"
    , CAST(B."COD_REP" AS DOUBLE PRECISION)
    , CAST(B."VLR_ICMS" AS DOUBLE PRECISION)
    , CAST(B."DIAS SEM FATURAMENTO" AS DOUBLE PRECISION)
    , CAST(B."VLR_TOTAL" AS DOUBLE PRECISION)
    , CAST(B."QUANTIDADE" AS DOUBLE PRECISION)
    , CAST(B."COMISSAO" AS DOUBLE PRECISION)
    , CAST(B."PIS" AS DOUBLE PRECISION)
    , CAST(B."Custo_Total" AS DOUBLE PRECISION)
    , CAST(B."VLR_IPI" AS DOUBLE PRECISION)
    , CAST(B."QTD_NF" AS DOUBLE PRECISION)
FROM "mave"."fat_mave_FaturamentoBaseB" B
 
UNION ALL 
 
-- Source: Faturamento - Base A
SELECT 
      CAST("COD_GRUPO_CLI" AS TEXT) 
    , CAST("COD_ITEM" AS TEXT) 
    , CAST("COD_FILIAL" AS TEXT) 
    , CAST("DT_PENULTIMA_FAT" AS DATE) 
    , CAST("GEO_CLI" AS TEXT) 
    , SPLIT_PART("GEO_CLI", ',', 2) AS "ESTADO"
    , CAST("DT_EMISSAO" AS DATE) 
    , CAST("SITUACAO_CLIENTES" AS TEXT) 
    , CAST("FAIXA DE FREQUÊNCIA" AS TEXT) 
    , CAST("EMPRESA_FANTASIA" AS TEXT) 
    , CAST("EMPRESA_RAZÃO" AS TEXT) 
    , CAST("Grupo" AS TEXT) 
    , CAST("NAT_OPER" AS TEXT) 
    , CAST("DT_ULTIMA_FAT_GEO" AS TEXT) 
    , CAST("NUM_NF" AS TEXT) 
    , CAST("CLIENTE" AS TEXT) 
    , CAST("GRUPO_NAT_OPER" AS TEXT) 
    , CAST("REPRESENTANTE" AS TEXT) 
    , CAST("DT_ULTIMA_FAT" AS DATE) 
    , CAST("DT_PRIMEIRA_FAT" AS DATE) 
    , CAST("SubGrupo" AS TEXT) 
    , CAST("CLASSIFICAÇÃO DE RECÊNCIA" AS TEXT) 
    , CAST("FAIXA DE RECÊNCIA" AS TEXT) 
    , CAST("GRUPO_CLI" AS TEXT) 
    , CAST("TRANSPORTADORA" AS TEXT) 
    , CAST("FAIXA DE VALOR" AS TEXT) 
    , CAST("ITEM_DESCRICAO" AS TEXT) 
    , CAST("VALOR_UNIT_MEDIO" AS DOUBLE PRECISION) 
    , CAST("COD_CLI" AS TEXT) 
    , CAST("FRETE" AS DOUBLE PRECISION) 
    , CAST("PESO_LIQ" AS DOUBLE PRECISION) 
    , CAST("COFINS" AS DOUBLE PRECISION) 
    , CAST("Vlr_Custo_Unit" AS DOUBLE PRECISION) 
    , CAST("COD_REP" AS DOUBLE PRECISION) 
    , CAST("VLR_ICMS" AS DOUBLE PRECISION) 
    , CAST("DIAS SEM FATURAMENTO" AS DOUBLE PRECISION) 
    , CAST("VLR_TOTAL" AS DOUBLE PRECISION) 
    , CAST("QUANTIDADE" AS DOUBLE PRECISION) 
    , CAST("COMISSAO" AS DOUBLE PRECISION) 
    , CAST("PIS" AS DOUBLE PRECISION) 
    , CAST("Custo_Total" AS DOUBLE PRECISION) 
    , CAST("VLR_IPI" AS DOUBLE PRECISION) 
    , CAST("QTD_NF" AS DOUBLE PRECISION) 
FROM "mave"."fat_mave_FaturamentoBaseA"
)
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
        SELECT DISTINCT
            CAST(fu."COD_CLI" AS TEXT) AS "Cliente"
            , CAST(fu."DT_EMISSAO" AS DATE) AS "Periodo"
            , CAST("DT_ULTIMA_FAT" AS DATE) AS "data_ultima_compra"
        FROM fat_union fu
        --WHERE fu."COD_CLI" = '2275'
        ORDER BY CAST(fu."DT_EMISSAO" AS DATE)
    ) x
  ) y
WHERE DATE_TRUNC('MONTH', y."periodo") <> DATE_TRUNC('MONTH', y."compra_anterior")
ORDER BY y."Cliente", y."periodo"