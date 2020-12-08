--Faturado X Ruptura
WITH datas AS (
  SELECT DISTINCT "Periodo" 
  FROM "bicbl"."fat_bicbl_ItensRupturaDia" 
  WHERE DATE_TRUNC('MONTH', "Periodo")::DATE >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL

), cruzamento AS (
  SELECT 
    d."Periodo"
    , CAST(mr."itens_mix" AS TEXT) AS "itens_mix"
    , mr."PDV Código"
    , mr."Item"
    , mr."Item Categoria CBL"
    , mr."Item Dias Vencimento 1"
    , mr."Item Dias Vencimento 2"
    , mr."Item Dias Vencimento 3"
    , mr."Item Marcas CBL"
    , mr."Item Qtd Embalagem"
    , mr."Item Seções"
  FROM "bicbl"."fat_bicbl_MixdeProdutosRuptura" mr
  CROSS JOIN datas d
)
SELECT
      r."Periodo"
    , r."Promotor"
    , r."Promotor Rota"
    , r."Gerente"
    , r."Promotor Regional"
    , r."Supervisor"
    , r."PDV"
    , r."PDV Estado"
    , r."PDV Cidade"
    , r."PDV Bairro"
    , r."PDV Geo"
    , r."PDV Código"
    , r."PDV Ativo"
    , r."PDV Canal"
    , r."PDV Ciclo Atendimento"
    , r."PDV Rede"
    , r."PDV Regional"
    , r."PDV Atacado"
    , r."PDV Grupo"
    , r."Rota"
    , r."Qtd Rotas"
    , CAST(mr."itens_mix" AS TEXT) AS "itens_mix"
    , mr."Item"
    , mr."Item Categoria CBL"
    , mr."Item Dias Vencimento 1"
    , mr."Item Dias Vencimento 2"
    , mr."Item Dias Vencimento 3"
    , mr."Item Marcas CBL"
    , mr."Item Qtd Embalagem"
    , mr."Item Seções"
    , 1 as "cont"
FROM cruzamento mr
INNER JOIN "bicbl"."fat_bicbl_ItensRupturaDia" r ON (r."Periodo"::DATE = CAST(mr."Periodo" AS DATE) AND r."PDV Código" = mr."PDV Código")
WHERE DATE_TRUNC('MONTH', r."Periodo"::DATE) <= DATE_TRUNC('MONTH',now())::DATE
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30