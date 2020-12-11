SELECT
    /* PROMOTOR*/
      age.age_name as "Promotor"
	, art.age_name as "Promotor Rota"
    , age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Promotor Ultima Sincronização"
    , agg.agg_description as "Promotor Grupo"
    , age.e_auditor as "Gerente"
    , age.e_agent_mix as "Promotor Mix"
    , age.e_regional as "Promotor Regional"
    , age.e_hora_inicio as "Promotor Hora Inicio"
    , age.e_hora_fim as "Promotor Hora Fim"
    , age.e_salario as "Promotor Salário"
    , age.e_supervisor as "Supervisor"
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
	, rota.e_rota_nome as "Rota"
    /* ITENS */
    , ite.ite_id
    , ite.ite_description as "Item"
    , isg.isg_description as "Item Subgrupo"
    , ite.e_categoria_cbl as "Item Categoria CBL"
    , ite.e_dias_vencimento_1 as "Item Dias Vencimento 1"
    , ite.e_dias_vencimento_2 as "Item Dias Vencimento 2"
    , ite.e_dias_vencimento_3 as "Item Dias Vencimento 3"
    , ite.e_marcas_cbl as "Item Marcas CBL"
    , ite.e_quantidade_embalagem as "Item Qtd Embalagem"
    , ite.e_secoes as "Item Seções"
    /* TAREFAS */
    , t.tsk_id
    , t.age_id
    , t.loc_id
    , t.tsk_situation as "Situação Tarefa"
    , t.tsk_realinitialdatehour as "Data Inicio"
    , t.tsk_realinitialdatehour as "Data Inicio Filtro"
    , t.tsk_realfinaldatehour as "Data Fim"
    , t.tsk_realfinaldatehour as "Data Fim Filtro"
    /* HISTORICO */
    , his.e_acoes_giro as "Ações do Giro"
    , his.e_observacoes as "Observações"
    , ini.e_observacoes as "Observações Inicio"

FROM u19947.dbout_task t
INNER JOIN u19947.dbout_history_giro_acoes_fim           his ON (t.tsk_id = his.tsk_id)
LEFT JOIN u19947.dbout_history_giro_inicio            ini ON (t.tsk_id = ini.tsk_id)
INNER JOIN u19947.dbout_local                            loc ON (t.loc_id = loc.loc_id)
LEFT  JOIN u19947.dbout_customentity_brb                 rota ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', t.tsk_realinitialdatehour)::DATE)
LEFT  JOIN u19947.dbout_agent                            art ON (rota.i_rota_promotor_codigo = art.age_integrationid)
INNER JOIN u19947.dbout_agent                            age ON (t.age_id = age.age_id)
LEFT  JOIN u19947.agentgroup                             agg ON (age.agg_id = agg.agg_id)
LEFT  JOIN u19947.dbout_item                             ite ON (his.ite_id = ite.ite_id)
LEFT  JOIN u19947.itemsubgroup                           isg ON (ite.isg_id = isg.isg_id)
WHERE t.tsk_situation <> 'Cancelada'
AND DATE_TRUNC('MONTH',  t.tsk_realinitialdatehour::DATE) >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL