WITH dates AS (
    SELECT DISTINCT
        t.tsk_realinitialdatehour::DATE AS "Periodo"
    FROM u19947.task t
    WHERE t.tsk_situation <> 'Cancelada'
    AND DATE_TRUNC('MONTH', t.tsk_realinitialdatehour::DATE) >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
    AND DATE_TRUNC('MONTH', t.tsk_realinitialdatehour::DATE) <=  NOW()::DATE
    AND t.tsk_realinitialdatehour::DATE IS NOT NULL
    ORDER BY 1 DESC

)


SELECT DISTINCT 
    d."Periodo"
    , ite.ite_integrationid as itens_mix
    , ite.ite_description AS "Item"
    , ite.e_categoria_cbl AS "Item Categoria CBL"
    , ite.i_dias_vencimento_1 AS "Item Dias Vencimento 1"
    , ite.i_dias_vencimento_2 AS "Item Dias Vencimento 2"
    , ite.i_dias_vencimento_3 AS "Item Dias Vencimento 3"
    , ite.e_marcas_cbl AS "Item Marcas CBL"
    , ite.i_quantidade_embalagem AS "Item Qtd Embalagem"
    , ite.e_secoes AS "Item Seções"
    , m.cev_integrationid AS "PDV Código"
    , 1 as "Cont"
FROM u19947.dbout_customentity_mixitem i
INNER JOIN u19947.dbout_customentity_mix m ON (i.i_mixitem_mix::INT = m.cev_id)
LEFT JOIN u19947.dbout_item ite ON (i.i_mixitem_item::INT = ite.ite_id)
CROSS JOIN dates d
WHERE m.cet_id = 133382
AND i.cev_active = '1'