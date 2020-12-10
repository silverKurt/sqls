SELECT *
FROM public.crosstab(

'WITH dbout_supervisores AS (

    SELECT age.age_id, age.age_name, age.age_integrationid
    FROM u28690.agent age
    LEFT JOIN u28690.agentgroup agg ON age.agg_id = agg.agg_id
    WHERE agg.agg_description IN (''Supervisor'')

)

SELECT DISTINCT
    
    his.hty_id::TEXT || ite.ite_integrationid                   AS "Identifier"

    /* PROMOTOR*/
    , age.age_name                                              AS "Promotor"
    , age.age_lastgeoposition                                   AS "Promotor Ultima Geo"
    , agg.agg_description                                       AS "Promotor Grupo"
    , ags.age_id                                                AS "Qtd Supervisor"
	, ags.age_name                                              AS "Supervisor"
	, tea.tea_description                                       AS "Equipe"
    
     /* LOCAL */
    , loc.loc_description                                       AS "PDV"
    , loc.loc_state                                             AS "PDV Estado"
    , loc.loc_city                                              AS "PDV Cidade"
    , loc.loc_neighborhood                                      AS "PDV Bairro"
    , loc.loc_geoposition                                       AS "PDV Geo"
    , loc.loc_integrationid                                     AS "PDV Código"
    , loc.e_canal                                               AS "PDV Canal"

    /* ITENS */
    , ite.ite_id
    , ite.ite_integrationid
    , ite.ite_description                                       AS "Item"

     /* TAREFAS */
    , t.tsk_id::TEXT                || 
      ite.ite_integrationid::TEXT   ||
      t.age_id                      ||
      t.loc_id                      ||
      t.tsk_scheduleinitialdatehour::DATE::TEXT                 AS "tsk_id"
      
    , t.age_id
    , t.loc_id
    , t.tsk_situation                                           AS "Situação Tarefa"
    , t.tsk_scheduleinitialdatehour                             AS "Data Inicio Previsto"
    , t.tsk_schedulefinaldatehour                               AS "Data Fim Previsto"
    , t.tsk_realinitialdatehour                                 AS "Data Inicio"
    , t.tsk_realfinaldatehour                                   AS "Data Fim"
    
    
    /* HISTORICO */
    , his.e_produto_disponivel                                  AS "Produto Disponivel"

    , INITCAP(isg.isg_description)                              AS "campo"
    , COALESCE(his.e_preco::DOUBLE PRECISION, 0)                AS "valor"

FROM u28690.dbout_task                                   t
INNER JOIN u28690.dbout_history_pesquisa_preco           his ON (t.tsk_id = his.tsk_id)
INNER JOIN u28690.dbout_local                            loc ON (t.loc_id = loc.loc_id)
INNER JOIN u28690.dbout_agent                            age ON (t.age_id = age.age_id)
INNER JOIN dbout_supervisores                            ags ON (age.i_idsupervisor = ags.age_integrationid)
LEFT JOIN u28690.agentgroup                              agg ON (age.agg_id = agg.agg_id)
LEFT JOIN u28690.dbout_item                              ite ON (his.ite_id = ite.ite_id)
LEFT JOIN u28690.itemsubgroup                            isg ON (ite.isg_id = isg.isg_id)
LEFT JOIN u28690.vw_responsible_team_recursive       age_tea ON (age.age_id = age_tea.agent)
LEFT JOIN u28690.dbout_team                              tea ON (age_tea.team = tea.tea_id)
WHERE t.tsk_situation <> ''Cancelada''
',
'SELECT DISTINCT INITCAP(isg.isg_description) AS "campo" 
FROM u28690.dbout_task                                   t
INNER JOIN u28690.dbout_history_pesquisa_preco           his ON (t.tsk_id = his.tsk_id)
INNER JOIN u28690.dbout_local                            loc ON (t.loc_id = loc.loc_id)
INNER JOIN u28690.dbout_agent                            age ON (t.age_id = age.age_id)
LEFT JOIN u28690.agentgroup                              agg ON (age.agg_id = agg.agg_id)
LEFT JOIN u28690.dbout_item                              ite ON (his.ite_id = ite.ite_id)
LEFT JOIN u28690.itemsubgroup                            isg ON (ite.isg_id = isg.isg_id)
LEFT JOIN u28690.vw_responsible_team_recursive       age_tea ON (age.age_id = age_tea.agent)
LEFT JOIN u28690.dbout_team                              tea ON (age_tea.team = tea.tea_id)
WHERE t.tsk_situation <> ''Cancelada'' ORDER BY 1'
)
AS
(

    "Identifier" VARCHAR(255)
    , "Promotor" VARCHAR(255)
    , "Promotor Ultima Geo" VARCHAR(255)
    , "Promotor Grupo" VARCHAR(255)
    , "Qtd Supervisor" VARCHAR(255)
    , "Supervisor" VARCHAR(255)
    , "Equipe" VARCHAR(255)
    , "PDV" VARCHAR(255)
    , "PDV Estado" VARCHAR(255)
    , "PDV Cidade" VARCHAR(255)
    , "PDV Bairro" VARCHAR(255)
    , "PDV Geo" VARCHAR(255)
    , "PDV Código" VARCHAR(255)
    , "PDV Canal" VARCHAR(255)
    , "ite_id" VARCHAR(255)
    , "ite_integrationid" VARCHAR(255)
    , "Item" VARCHAR(255)
    , "tsk_id" VARCHAR(255)
    , "age_id" VARCHAR(255)
    , "loc_id" VARCHAR(255)
    , "Situação Tarefa" VARCHAR(255)
    , "Data Inicio Previsto" TIMESTAMP
    , "Data Fim Previsto" TIMESTAMP
    , "Data Inicio" TIMESTAMP
    , "Data Fim" TIMESTAMP
    , "Produto Disponivel" VARCHAR(255)
    , "Concentrado" DOUBLE PRECISION
    , "Concorrente" DOUBLE PRECISION
    , "Ppb Litro" DOUBLE PRECISION
    , "Premium" DOUBLE PRECISION
    , "Tônicas" DOUBLE PRECISION
    , "Uva Integral" DOUBLE PRECISION

)