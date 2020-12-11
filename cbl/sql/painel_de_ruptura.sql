--Cruza Faturado X Ruptura
SELECT
      f."Periodo"
    , f."Periodo Filtro"
    , CASE WHEN DATE_TRUNC('WEEK', f."Periodo") >= DATE_TRUNC('WEEK', NOW())::DATE - '2 WEEK'::INTERVAL THEN TO_CHAR(DATE_TRUNC('WEEK', f."Periodo"), 'DD-MM-YYYY')
    	ELSE NULL
    END AS "Periodo Semana"
    , CASE WHEN DATE_TRUNC('WEEK', f."Periodo") >= DATE_TRUNC('WEEK', NOW())::DATE - '2 WEEK'::INTERVAL THEN TO_CHAR(DATE_TRUNC('WEEK', f."Periodo"), 'YYYY-MM-DD')
    	ELSE NULL
    END AS "Periodo Semana Filtro"
    , f."Promotor"
    , f."Promotor Rota"
    , f."Gerente"
    , f."Promotor Regional"
    , f."Supervisor"
    , f."PDV"
    , f."PDV Estado"
    , f."PDV Cidade"
    , f."PDV Bairro"
    , f."PDV Geo"
    , f."PDV Código"
    , f."PDV Código" as "Qtd PDVs"
    , f."PDV Ativo"
    , f."PDV Canal"
    , f."PDV Ciclo Atendimento"
    , f."PDV Rede"
    , f."PDV Regional"
    , f."PDV Atacado"
    , f."PDV Grupo"
    , f."Rota"
    , f."Qtd Rotas"
    , f."Item"
    , f."Item Categoria CBL"
    , f."Item Dias Vencimento 1"
    , f."Item Dias Vencimento 2"
    , f."Item Dias Vencimento 3"
    , f."Item Marcas CBL"
    , f."Item Qtd Embalagem"
    , f."Item Seções"
    , (f."PDV Código"||f.itens_fat) as "Itens Fat"
    , (r."PDV Código"||r.itens_ruptura) as "Itens Ruptura"
    , 'SIM' AS "Produto em Ruptura"
    , u."Vlr Ult Fat" AS "Vlr Ult. Faturamento"
    , COALESCE(u."Data Ult Fat", '-') AS "Data Ult. Faturamento"
    , CASE WHEN u."Periodo"::DATE >= DATE_TRUNC('WEEK',now()::DATE - '1 week'::INTERVAL)::DATE THEN 'Faturado na Última Semana' ELSE 'Sem Faturamento' END AS "Status Faturamento"
    , (SELECT MAX(f."Periodo") FROM "bicbl"."fat_bicbl_RupturaItensSeisTres" f LIMIT 1) AS "Último Periodo"
    --, MAX(f."Periodo") 
FROM "bicbl"."fat_bicbl_RupturaItensSeisTres" f
LEFT JOIN "bicbl"."fat_bicbl_ItensRupturaDia" r ON (f."Periodo" = r."Periodo" and f."PDV Código" = r."PDV Código" and f."Rota" = r."Rota" and f.itens_fat = r.itens_ruptura AND r."Produto em Ruptura" = 'SIM')
LEFT JOIN "bicbl"."fat_bicbl_ItensRupturaUltimoFaturamento" u ON (u."PDV Código" = f."PDV Código" AND u."Qtd Itens Faturados" = f.itens_fat)
WHERE DATE_TRUNC('MONTH', f."Periodo") >= DATE_TRUNC('YEAR', now()::DATE) - '4 MONTH'::INTERVAL AND DATE_TRUNC('MONTH', f."Periodo") <= DATE_TRUNC('MONTH',now())::DATE
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39