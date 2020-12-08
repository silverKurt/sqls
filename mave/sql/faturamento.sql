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
), primeira_ultima AS (
    SELECT 
        MAX(CAST("DT_EMISSAO" AS DATE)) AS "max_data_emissao"
        , MIN(CAST("DT_EMISSAO" AS DATE)) AS "min_data_emissao"
        , CAST("COD_CLI" AS TEXT)
    FROM fat_union
    GROUP BY "COD_CLI"
), penultima AS (
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
), frequencia AS (
    SELECT count("DT_EMISSAO") AS "count_emissao"
           , CAST("NUM_NF" AS TEXT)
    FROM fat_union
    GROUP BY "NUM_NF"
)


SELECT 
    CAST(u."COD_GRUPO_CLI" AS TEXT) AS "CODGRUPOCLI",
    CAST(u."COD_ITEM" AS TEXT) AS "CODITEM",
    CAST(u."COD_FILIAL" AS TEXT) AS "CODFILIAL",
    CAST(pe."compra_anterior" AS DATE) AS "DTPENULTIMAFAT",
    CAST(u."GEO_CLI" AS TEXT) AS "GEOCLI",
    SPLIT_PART(u."GEO_CLI", ',', 2) AS "ESTADO",
    CAST(u."DT_EMISSAO" AS DATE) AS "DTEMISSAO",
    CAST(pe."status_cliente" AS TEXT) AS "SITUACAOCLIENTES",
    CASE
        WHEN CAST(fr."count_emissao" AS INTEGER) >=  5 THEN 'F1 - 5 vezes ou mais'
        WHEN CAST(fr."count_emissao" AS INTEGER) >=  4 THEN 'F2 - 4 vezes'
        WHEN CAST(fr."count_emissao" AS INTEGER) >=  3 THEN 'F3 - 3 vezes'
        WHEN CAST(fr."count_emissao" AS INTEGER) >=  2 THEN 'F4 - 2 vezes'
        WHEN CAST(fr."count_emissao" AS INTEGER) >=  1 THEN 'F5 - 1 vez' 
    END AS "FAIXADEFREQUENCIA",
    CAST(u."EMPRESA_FANTASIA" AS TEXT) AS "EMPRESAFANTASIA",
    CAST(u."EMPRESA_RAZÃO" AS TEXT) AS "EMPRESARAZAO",
    CAST(u."Grupo" AS TEXT) AS "Grupo",
    CAST(u."NAT_OPER" AS TEXT) AS "NATOPER",
    CAST(u."DT_ULTIMA_FAT_GEO" AS TEXT) AS "DTULTIMAFATGEO",
    CAST(u."NUM_NF" AS TEXT) AS "NUMNF",
    CAST(u."CLIENTE" AS TEXT) AS "CLIENTE",
    CAST(u."GRUPO_NAT_OPER" AS TEXT) AS "GRUPONATOPER",
    CAST(u."REPRESENTANTE" AS TEXT) AS "REPRESENTANTE",
    CAST(pu."max_data_emissao" AS DATE) AS "DTULTIMAFAT",
    CAST(pu."min_data_emissao" AS DATE) AS "DTPRIMEIRAFAT",
    CAST(u."SubGrupo" AS TEXT) AS "SubGrupo",
    CASE
        WHEN CAST((NOW()::DATE - CAST(pu."max_data_emissao" AS DATE)) AS INTEGER) <=  30  THEN 'Bom'
        WHEN CAST((NOW()::DATE - CAST(pu."max_data_emissao" AS DATE)) AS INTEGER) <=  90  THEN 'Razoavel'
        WHEN CAST((NOW()::DATE - CAST(pu."max_data_emissao" AS DATE)) AS INTEGER) <=  180 THEN 'Ruim'
        WHEN CAST((NOW()::DATE - CAST(pu."max_data_emissao" AS DATE)) AS INTEGER) >   180 THEN 'Inativos' 
    END AS "CLASSIFICACAODERECENCIA",
    CASE
        WHEN CAST((NOW()::DATE - pu."max_data_emissao"::DATE) AS INTEGER) <=  30 THEN 'R1 - Últimos 30 Dias'
        WHEN CAST((NOW()::DATE - pu."max_data_emissao"::DATE) AS INTEGER) <=  60 THEN 'R2 - 31 A 60 Dias'
        WHEN CAST((NOW()::DATE - pu."max_data_emissao"::DATE) AS INTEGER) <=  90 THEN 'R3 - 61 A 90 Dias'
        WHEN CAST((NOW()::DATE - pu."max_data_emissao"::DATE) AS INTEGER) <= 120 THEN 'R4 - 91 A 120 Dias'
        WHEN CAST((NOW()::DATE - pu."max_data_emissao"::DATE) AS INTEGER) <= 180 THEN 'R5 - 121 A 180 Dias'
        WHEN CAST((NOW()::DATE - pu."max_data_emissao"::DATE) AS INTEGER) >  180 THEN 'R6 - Acima de 180 Dias' 
    END AS "FAIXADERECENCIA",
    CAST(u."GRUPO_CLI" AS TEXT) AS "GRUPOCLI",
    CAST(u."TRANSPORTADORA" AS TEXT) AS "TRANSPORTADORA",
    CAST(u."FAIXA DE VALOR" AS TEXT) AS "FAIXADEVALOR",
    CAST(u."ITEM_DESCRICAO" AS TEXT) AS "ITEMDESCRICAO",
    CAST(u."VALOR_UNIT_MEDIO" AS DOUBLE PRECISION) AS "VALORUNITMEDIO",
    CAST(u."COD_CLI" AS text) AS "CODCLI", 
    CAST(u."FRETE" AS DOUBLE PRECISION) AS "FRETE",
    CAST(u."PESO_LIQ" AS DOUBLE PRECISION) AS "PESOLIQ",
    CAST(u."COFINS" AS DOUBLE PRECISION) AS "COFINS",
    CAST(u."Vlr_Custo_Unit" AS DOUBLE PRECISION) AS "VlrCustoUnit",
    CAST(u."COD_REP" AS DOUBLE PRECISION) AS "CODREP",
    CAST(u."VLR_ICMS" AS DOUBLE PRECISION) AS "VLRICMS",
    CAST(NOW()::DATE - pu."max_data_emissao"::DATE AS INTEGER) AS "DIASSEMFATURAMENTO",
    CAST(u."VLR_TOTAL" AS DOUBLE PRECISION) AS "VLRTOTAL",
    CAST(u."QUANTIDADE" AS DOUBLE PRECISION) AS "QUANTIDADE",
    CAST(u."COMISSAO" AS DOUBLE PRECISION) AS "COMISSAO",
    CAST(u."PIS" AS DOUBLE PRECISION) AS "PIS",
    CAST(u."Custo_Total" AS DOUBLE PRECISION) AS "CustoTotalOriginal",
    CASE WHEN CAST(L."Fator_de_Multiplicacao" AS DOUBLE PRECISION) IS NULL 
         THEN CAST(u."Custo_Total" AS DOUBLE PRECISION) 
         ELSE CAST(((u."QUANTIDADE") * (L."Fator_de_Multiplicacao" * L."USS")) AS DOUBLE PRECISION) END AS "CustoTotal",


    CAST(u."VLR_IPI" AS DOUBLE PRECISION) AS "VLRIPI",
    CAST(u."QTD_NF" AS DOUBLE PRECISION) AS "QTDNF"  
FROM fat_union u
LEFT JOIN primeira_ultima pu ON (u."COD_CLI"::TEXT = pu."COD_CLI"::TEXT)
LEFT JOIN penultima pe ON (u."COD_CLI"::TEXT = pe."Cliente"::TEXT AND DATE_TRUNC('MONTH', pe."periodo") = DATE_TRUNC('MONTH', u."DT_EMISSAO"))
LEFT JOIN frequencia fr ON (u."NUM_NF"::TEXT = fr."NUM_NF"::TEXT)

LEFT JOIN "mave"."fat_mave_ListaPrecos" L ON (CAST(u."COD_ITEM" AS TEXT) = CAST(L."Cod_Mave" AS TEXT))

--where CAST(U."DT_EMISSAO" AS DATE) >= '2020-01-01' AND CAST(U."DT_EMISSAO" AS DATE) <= '2020-01-31'
--where CAST(u."CLIENTE" AS TEXT) like '%EMIR%JOAO%BAGATINI'