WITH dados AS (
-- Source: Movimento X Estoque
SELECT 
    CAST("Referencia Completa" AS TEXT) AS "ReferenciaCompleta",
    CAST("Material" AS TEXT) AS "Material",
    CAST("Unidade de Negócio" AS TEXT) AS "Unidade de Negócio",
    CAST("Grupo Material" AS TEXT) AS "Grupo Material",
    CAST("Especifico" AS TEXT) AS "Cod Especifico",
    MAX(CAST("Qtde Cx Master" AS DOUBLE PRECISION)) AS "QtdeCxMaster",
    MIN(CAST("Lote Minimo Realizado" AS DOUBLE PRECISION)) AS "LoteMinimoRealizado",
    MAX(CAST("Quantidade Estoque" AS DOUBLE PRECISION)) AS "QuantidadeEstoque",
    SUM(CAST("Quantidade" AS DOUBLE PRECISION)) AS "Quantidade",
    SUM(CAST("Quantidade" AS DOUBLE PRECISION))/12 AS "Quantidade Média"
FROM "ou"."fat_ou_MovimentoXEstoque" 
WHERE CAST("Periodo" AS DATE) >= DATE_TRUNC('MONTH', NOW()::DATE) - '13 MONTH'::INTERVAL AND CAST("Periodo" AS DATE) <= DATE_TRUNC('MONTH', NOW()::DATE) - '1'::INTERVAL
AND CAST("Centro Valido Planejamento" AS TEXT) = 'true'
AND CAST("Grupo Material" AS TEXT) IN
('60  - PRODUTOS ACABADOS                       '
,'61  - PRODUTOS ACABADOS GERAL                 '
,'65  -  PRODUTOS PARA REVENDA                  '
,'81  - PRODUTOS YOI REVENDA                    ')
GROUP BY 1,2,3,4,5
),

dadosMes AS (
-- Source: Movimento X Estoque
SELECT * FROM (
SELECT 
    CAST("Referencia Completa" AS TEXT) AS "ReferenciaCompleta",
    CAST("Material" AS TEXT) AS "Material",
    CAST("Unidade de Negócio" AS TEXT) AS "Unidade de Negócio",
    CAST("Grupo Material" AS TEXT) AS "Grupo Material",
    CAST("Especifico" AS TEXT) AS "Cod Especifico",
    MIN(CAST("Lote Minimo Realizado" AS DOUBLE PRECISION)) AS "LoteMinimoRealizado",
    CASE WHEN MAX(CASE WHEN TRIM(CAST("Centro Armazenagem Est" AS TEXT)) = '400' THEN CAST("Quantidade Estoque" AS DOUBLE PRECISION) ELSE NULL END) = 0 THEN NULL 
  		 ELSE MAX(CASE WHEN TRIM(CAST("Centro Armazenagem Est" AS TEXT)) = '400' THEN CAST("Quantidade Estoque" AS DOUBLE PRECISION) ELSE NULL END)
    END AS "QuantidadeEstoque"

FROM "ou"."fat_ou_MovimentoXEstoque" 
WHERE DATE_TRUNC('MONTH', CAST("Periodo" AS DATE)) = DATE_TRUNC('MONTH', NOW()::DATE)
AND CAST("Centro Valido Planejamento" AS TEXT) = 'true'
AND CAST("Grupo Material" AS TEXT) IN
('60  - PRODUTOS ACABADOS                       '
,'61  - PRODUTOS ACABADOS GERAL                 '
,'65  -  PRODUTOS PARA REVENDA                  '
,'81  - PRODUTOS YOI REVENDA                    ')
--and CAST("Referencia Completa" AS TEXT) = 'DT 500-DISPENSER PARA DETERGENTE 650 ML-PRETO FECHADO'
GROUP BY 1,2,3,4,5) X WHERE "QuantidadeEstoque" IS NOT NULL
),

dadosMesAnterior AS (
-- Source: Movimento X Estoque
SELECT 
    CAST("Referencia Completa" AS TEXT) AS "ReferenciaCompleta",
    CAST("Material" AS TEXT) AS "Material",
    CAST("Unidade de Negócio" AS TEXT) AS "Unidade de Negócio",
    CAST("Grupo Material" AS TEXT) AS "Grupo Material",
    CAST("Especifico" AS TEXT) AS "Cod Especifico",  
    MAX(CAST("Qtde Cx Master" AS DOUBLE PRECISION)) AS "QtdeCxMaster",
    SUM(CAST("Quantidade" AS DOUBLE PRECISION)) AS "Quantidade Mes Anterior"

FROM "ou"."fat_ou_MovimentoXEstoque" 
WHERE DATE_TRUNC('MONTH', CAST("Periodo" AS DATE)) = DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
AND CAST("Centro Valido Planejamento" AS TEXT) = 'true'
AND CAST("Grupo Material" AS TEXT) IN
('60  - PRODUTOS ACABADOS                       '
,'61  - PRODUTOS ACABADOS GERAL                 '
,'65  -  PRODUTOS PARA REVENDA                  '
,'81  - PRODUTOS YOI REVENDA                    ')
--and CAST("Referencia Completa" AS TEXT) = 'DT 500-DISPENSER PARA DETERGENTE 650 ML-PRETO FECHADO'
GROUP BY 1,2,3,4,5
)
--SELECT * FROM 
(SELECT
      d."ReferenciaCompleta"
    , d."Material"
    , d."Unidade de Negócio"
    , m."QtdeCxMaster"
    , dm."LoteMinimoRealizado"
    , dm."QuantidadeEstoque"
    --, ."QuantidadeEstoque"
    , d."Quantidade"
    , d."Quantidade Média"
    , d."Grupo Material"
    , d."Cod Especifico"
    , m."Quantidade Mes Anterior"
    , d."ReferenciaCompleta" as "Qtd Itens"
    , SUM(d."QuantidadeEstoque") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY d."QuantidadeEstoque" DESC) AS "Estoque ACM"
    , SUM(d."QuantidadeEstoque") OVER (PARTITION BY d."Unidade de Negócio") AS "Estoque Total"
    , SUM(d."Quantidade") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY d."Quantidade" DESC) AS "Quantidade ACM"
    , SUM(d."Quantidade") OVER (PARTITION BY d."Unidade de Negócio") AS "Quantidade Total"
    , SUM(d."Quantidade Média") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY d."Quantidade Média" DESC) AS "Quantidade Média ACM"
    , SUM(d."Quantidade Média") OVER (PARTITION BY d."Unidade de Negócio") AS "Quantidade Média Total"
    , SUM(m."Quantidade Mes Anterior") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY m."Quantidade Mes Anterior" DESC) AS "Quantidade Mes ACM"
    , SUM(m."Quantidade Mes Anterior") OVER (PARTITION BY d."Unidade de Negócio") AS "Quantidade Média Mes"
    , LPAD(COALESCE((row_number() OVER (ORDER BY d."Quantidade" DESC)), 99999)::TEXT, 5, '0') as "Ordem Itens"
    , CASE 
        WHEN SUM(m."Quantidade Mes Anterior") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY m."Quantidade Mes Anterior" DESC)/SUM(m."Quantidade Mes Anterior") OVER (PARTITION BY d."Unidade de Negócio") <= 0.7 THEN 'A'
        WHEN SUM(m."Quantidade Mes Anterior") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY m."Quantidade Mes Anterior" DESC)/SUM(m."Quantidade Mes Anterior") OVER (PARTITION BY d."Unidade de Negócio") <= 0.9 THEN 'B'
        ELSE 'C'
      END AS "Curva ABC"
    , CASE 
        WHEN SUM(d."QuantidadeEstoque") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY d."QuantidadeEstoque" DESC)/SUM(d."QuantidadeEstoque") OVER (PARTITION BY d."Unidade de Negócio") <= 0.7 THEN 'A'
        WHEN SUM(d."QuantidadeEstoque") OVER (PARTITION BY d."Unidade de Negócio" ORDER BY d."QuantidadeEstoque" DESC)/SUM(d."QuantidadeEstoque") OVER (PARTITION BY d."Unidade de Negócio") <= 0.9 THEN 'B'
        ELSE 'C'
      END AS "Curva ABC Estoque"
FROM dadosMesAnterior m 
INNER JOIN dados d ON (d."ReferenciaCompleta" = m."ReferenciaCompleta" AND d."Unidade de Negócio" = m."Unidade de Negócio")
INNER JOIN dadosMes dm ON (dm."ReferenciaCompleta" = m."ReferenciaCompleta" AND dm."Unidade de Negócio" = m."Unidade de Negócio")
WHERE  d."Quantidade" > 0 OR d."QuantidadeEstoque" > 0 OR m."Quantidade Mes Anterior" > 0
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12, d."QuantidadeEstoque"--,13
ORDER BY d."Unidade de Negócio", d."Quantidade" DESC)
--X WHERE TRIM("ReferenciaCompleta") = 'JRE 3555-JARRA VITRA C/RESFRIADOR 1,8 L.-NATURAL'