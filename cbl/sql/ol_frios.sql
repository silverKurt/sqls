SELECT
/* PROMOTOR*/
     "Promotor"
     , "Promotor Ultima Geo"
     , "Promotor Ultima Sincronização"
     , "Promotor Grupo"
     , "Gerente"
     , "Promotor Mix"
     , "Promotor Regional"
     , "Promotor Hora Inicio"
     , "Promotor Hora Fim"
     , "Promotor Salário"
     , "Supervisor"

     /* LOCAL */
     , "PDV"
     , "PDV Estado"
     , "PDV Cidade"
     , "PDV Bairro"
     , "PDV Geo"
     , "PDV Código"
     , "PDV Ativo"
     , "PDV Canal"
     , "PDV Ciclo Atendimento"
     , "PDV Rede"
     , "PDV Regional"
     , "PDV Atacado"
     , "PDV Volume Qtd Caixa"
     , "PDV Grupo"

    /*ROTA*/
     , "Promotor Rota"
     , "Rota"

    /* ITENS */
     , "ite_id"
     , "ite_integrationid"
     , "Item"
     , "Item Subgrupo"
     , "Item Categoria CBL"
     , "Item Dias Vencimento 1"
     , "Item Dias Vencimento 2"
     , "Item Dias Vencimento 3"
     , "Item Marcas CBL"
     , "Item Qtd Embalagem"
     , "Item Seções"
     --, "Código Item"

     /* TAREFAS */
     , "tsk_id"
     , "age_id"
     , "loc_id"
     , "Situação Tarefa"
     , "Data Inicio Previsto"
     , "Data Inicio Previsto Filtro"
     , "Data Fim Previsto"
     , "Data Fim Previsto Filtro"
     , "Data Inicio"
     , "Data Inicio Filtro"
     , "Data Fim"
     , "Data Fim Filtro"

     , "Data_Inicio_OL_Frios" as "Data Ini"
     , "Data_Inicio_OL_Frios" as "Data Ini Filtro"
     , "Hora_Inicio_OL_Frios"  as "Hora Inicio"
     , "observacao_inicio_frios"  as "Observação Inicio"
     , "Data_Fim_OL_Frios" as "Data F"
     , "Data_Fim_OL_Frios" as "Data F Filtro"
     , "Hora_Fim_OL_Frios" as "Hora Fim"
     , "observacao_fim_frios" as "Observação Fim"

FROM public.crosstab(
'SELECT DISTINCT

    htv.hty_id::TEXT || ite.ite_id::TEXT as "Identifier"

    /* PROMOTOR*/
    , age.age_name as "Promotor"
    , age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, ''dd/mm/yyyy hh:mi:ss'') AS "Promotor Ultima Sincronização"
    , agg.agg_description as "Promotor Grupo"
    , age.e_auditor as "Gerente"
    , age.e_agent_mix as "Promotor Mix"
    , age.e_regional as "Promotor Regional"
    , age.e_hora_inicio as "Promotor Hora Inicio"
    , age.e_hora_fim as "Promotor Hora Fim"
    , age.e_salario as "Promotor Salário"
    , age.e_supervisor as "Supervisor"

    /*12*/

    /* LOCAL */
    , loc.loc_description as "PDV"
    , loc.loc_state as "PDV Estado"
    , loc.loc_city as "PDV Cidade"
    , loc.loc_neighborhood as "PDV Bairro"
    , loc.loc_geoposition as "PDV Geo"
    , loc.loc_integrationid as "PDV Código"
    , loc.loc_active as "PDV Ativo"
    , loc.e_canal as "PDV Canal"
    , loc.e_ciclo_atendimento as "PDV Ciclo Atendimento"
    , loc.e_rede as "PDV Rede"
    , loc.e_regional as "PDV Regional"
    , loc.e_trabalha_atacado as "PDV Atacado"
    , loc.e_volumeqtd_caixah as "PDV Volume Qtd Caixa"
    , loc.e_grupo_de_lojas as "PDV Grupo"

    , art.age_name as "Promotor Rota"
    , rota.e_rota_nome as "Rota"

    /*16*/

    /* ITENS */
    , ite.ite_id
    , ite.ite_integrationid
    , ite.ite_integrationid as "Item Codigo"
    , ite.ite_description as "Item"
    , isg.isg_description as "Item Subgrupo"
    , ite.e_categoria_cbl as "Item Categoria CBL"
    , ite.e_dias_vencimento_1 as "Item Dias Vencimento 1"
    , ite.e_dias_vencimento_2 as "Item Dias Vencimento 2"
    , ite.e_dias_vencimento_3 as "Item Dias Vencimento 3"
    , ite.e_marcas_cbl as "Item Marcas CBL"
    , ite.e_quantidade_embalagem as "Item Qtd Embalagem"
    , ite.e_secoes as "Item Seções"

    /*12*/

    /* TAREFAS */
    , t.tsk_id
    , t.age_id
    , t.loc_id
    , t.tsk_situation as "Situação Tarefa"
    , t.tsk_scheduleinitialdatehour as "Data Inicio Previsto"
    , t.tsk_scheduleinitialdatehour as "Data Inicio Previsto Filtro"
    , t.tsk_schedulefinaldatehour as "Data Fim Previsto"
    , t.tsk_schedulefinaldatehour as "Data Fim Previsto Filtro"
    , t.tsk_realinitialdatehour as "Data Inicio"
    , t.tsk_realinitialdatehour as "Data Inicio Filtro"
    , t.tsk_realfinaldatehour as "Data Fim"
    , t.tsk_realfinaldatehour as "Data Fim Filtro"

    /* HISTORICO */
    , acf.acf_integrationid as campo
    , htv.htv_internalvalue as valor

    /*14*/

FROM u19947.task t
INNER JOIN u19947.history           hty ON (hty.tsk_id = t.tsk_id)
INNER JOIN u19947.historyvalue      htv ON (htv.hty_id = hty.hty_id)
INNER JOIN u19947.activityfield     acf ON (acf.acf_id = htv.acf_id)
INNER JOIN u19947.activitysection   acs ON (acs.acs_id = htv.acs_id AND acs.acs_id = htv.acs_id)
INNER JOIN u19947.activity          act ON (act.act_id = acs.act_id)
INNER JOIN u19947.activitytype      aty ON (aty.aty_id = act.aty_id)
INNER JOIN u19947.dbout_agent       age ON (age.age_id = t.age_id)
LEFT JOIN u19947.agentgroup         agg ON (agg.agg_id = age.agg_id)
LEFT JOIN u19947.dbout_item         ite ON (ite.ite_id = htv.ite_id)
LEFT JOIN u19947.itemsubgroup       isg ON (isg.isg_id = ite.isg_id)
LEFT JOIN u19947.dbout_local        loc ON (loc.loc_id = t.loc_id)
LEFT JOIN u19947.dbout_customentity_brb rota ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, ''DD/MM/YYYY'')::DATE = DATE_TRUNC(''MONTH'', t.tsk_realinitialdatehour)::DATE)
LEFT JOIN u19947.dbout_agent        art ON (rota.i_rota_promotor_codigo = art.age_integrationid)
WHERE t.tsk_situation <> ''Cancelada''
AND t.tsk_scheduleinitialdatehour::DATE  >= DATE_TRUNC(''MONTH'', NOW()::DATE)
AND act.act_id in (536399, 536400)
ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54',
'SELECT DISTINCT acf.acf_integrationid as campo
FROM u19947.activityfield acf
         INNER JOIN u19947.activitysection acs ON (acs.acs_id = acf.acs_id)
         INNER JOIN u19947.activity act ON (act.act_id = acs.act_id)
WHERE act.act_id in (536399, 536400)
  AND acf.acf_integrationid != ''''
  AND acf.acf_active = ''1''
order by 1'
)
AS
(
    "Identifier" VARCHAR(1000)
    /* PROMOTOR*/
     , "Promotor"  VARCHAR(1000)
     , "Promotor Ultima Geo"  VARCHAR(1000)
     , "Promotor Ultima Sincronização" VARCHAR(1000)
     , "Promotor Grupo" VARCHAR(1000)
     , "Gerente" VARCHAR(1000)
     , "Promotor Mix" VARCHAR(1000)
     , "Promotor Regional" VARCHAR(1000)
     , "Promotor Hora Inicio" VARCHAR(1000)
     , "Promotor Hora Fim" VARCHAR(1000)
     , "Promotor Salário" VARCHAR(1000)
     , "Supervisor" VARCHAR(1000)

     /* LOCAL */
     , "PDV" VARCHAR(1000)
     , "PDV Estado" VARCHAR(1000)
     , "PDV Cidade" VARCHAR(1000)
     , "PDV Bairro" VARCHAR(1000)
     , "PDV Geo" VARCHAR(1000)
     , "PDV Código" VARCHAR(1000)
     , "PDV Ativo" VARCHAR(1000)
     , "PDV Canal" VARCHAR(1000)
     , "PDV Ciclo Atendimento" VARCHAR(1000)
     , "PDV Rede" VARCHAR(1000)
     , "PDV Regional" VARCHAR(1000)
     , "PDV Atacado" VARCHAR(1000)
     , "PDV Volume Qtd Caixa" VARCHAR(1000)
     , "PDV Grupo" VARCHAR(1000)

    /*ROTA*/
     , "Promotor Rota" VARCHAR(1000)
     , "Rota" VARCHAR(1000)

    /* ITENS */
     , "ite_id" VARCHAR(1000)
     , "ite_integrationid" VARCHAR(1000)
     , "Item Codigo" VARCHAR(1000)
     , "Item" VARCHAR(1000)
     , "Item Subgrupo" VARCHAR(1000)
     , "Item Categoria CBL" VARCHAR(1000)
     , "Item Dias Vencimento 1" VARCHAR(1000)
     , "Item Dias Vencimento 2" VARCHAR(1000)
     , "Item Dias Vencimento 3" VARCHAR(1000)
     , "Item Marcas CBL" VARCHAR(1000)
     , "Item Qtd Embalagem" VARCHAR(1000)
     , "Item Seções" VARCHAR(1000)
     --, "Código Item" VARCHAR(1000)

     /* TAREFAS */
     , "tsk_id" VARCHAR(1000)
     , "age_id" VARCHAR(1000)
     , "loc_id" VARCHAR(1000)
     , "Situação Tarefa" VARCHAR(1000)
     , "Data Inicio Previsto" TIMESTAMP
     , "Data Inicio Previsto Filtro" TIMESTAMP
     , "Data Fim Previsto" TIMESTAMP
     , "Data Fim Previsto Filtro" TIMESTAMP
     , "Data Inicio" TIMESTAMP
     , "Data Inicio Filtro" TIMESTAMP
     , "Data Fim" TIMESTAMP
     , "Data Fim Filtro" TIMESTAMP

     , "Data_Fim_OL_Frios" TIMESTAMP
     , "Data_Inicio_OL_Frios" TIMESTAMP
     , "foto_camara_fria" VARCHAR(1000)
	 --, "foto_epi" VARCHAR(1000) /*removido*/
     , "Hora_Fim_OL_Frios" VARCHAR(1000)
     , "Hora_Inicio_OL_Frios" VARCHAR(1000)
     , "observacao_fim_frios" VARCHAR(1000)
     , "observacao_inicio_frios" VARCHAR(1000)
)