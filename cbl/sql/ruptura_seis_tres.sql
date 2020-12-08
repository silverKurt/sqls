--Faturado X Ruptura
SELECT
      r."Periodo"
    , r."Periodo Filtro"
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
    , f."Qtd Itens Faturados" AS itens_fat
    , f."Item"
    , f."Item Categoria CBL"
    , f."Item Dias Vencimento 1"
    , f."Item Dias Vencimento 2"
    , f."Item Dias Vencimento 3"
    , f."Item Marcas CBL"
    , f."Item Qtd Embalagem"
    , f."Item Seções"
FROM "bicbl"."fat_bicbl_ItensRuptura" r
INNER JOIN "bicbl"."fat_bicbl_ItensFaturados" f ON (f."Periodo" < r."Periodo" and f."Periodo" >= (r."Periodo" - (CASE WHEN r."Item Seções" = 'FRIOS' THEN ('3 months'::INTERVAL) ELSE ('6 months'::INTERVAL) END))::DATE and r."PDV Código" = f."PDV Código")
WHERE DATE_TRUNC('MONTH', r."Periodo") <= DATE_TRUNC('MONTH',now())::DATE
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31