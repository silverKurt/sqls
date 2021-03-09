(
SELECT
    /* AUDITOR */
      age.age_name as "Auditor"
    , null as "Auditor Rota"
    , age.age_lastgeoposition as "Auditor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Auditor Ultima Sincronização"
    , agg.agg_description as "Auditor Grupo"
    , age.e_agent_mix as "Auditor Mix"
    , age.e_regional as "Auditor Regional"
    , age.e_hora_inicio as "Auditor Hora Inicio"
    , (extract(epoch FROM (age.e_hora_inicio)::TIME)/3600) as "Hora Inicio"
    , age.e_hora_fim as "Auditor Hora Fim"
    , age.e_salario as "Auditor Salário"
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
    , null as "Rota"
     /* TAREFAS */
    , null as act_id
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
    /* PREVISAO E EXECUCAO */
    , t.tsk_id as "Qtd Tarefas Previstas"
    , checkin.tsk_id as "Qtd Tarefas Executadas"
    , t.loc_id as "Qtd PDVs Previstos"
    , CASE WHEN checkout.tsk_id IS NOT NULL THEN t.loc_id END as "Qtd PDVs Executados"
    /* TEMPOS*/
    , (extract(epoch FROM (age.e_hora_fim::TIME - age.e_hora_inicio::TIME)::TIME)/3600)-2 AS tempo_previsto
    , extract(epoch FROM (checkout.hty_initialdatehour - checkin.hty_initialdatehour)::TIME)/3600 AS tempo_trabalho
    , extract(epoch FROM (intervalo.hty_finaldatehour - intervalo.hty_initialdatehour)::TIME)/3600 AS tempo_intervalo
    , NULL::DOUBLE PRECISION AS tempo_execucao
    , NULL::DOUBLE PRECISION AS tempo_acoes
    , NULL::DOUBLE PRECISION AS tempo_correcoes
    /* HORARIOS */
    , extract(epoch FROM checkin.hty_initialdatehour::TIME)/3600 AS checkin_hora
    , case when extract(epoch FROM checkin.hty_initialdatehour::TIME)/3600 <= 12
      then extract(epoch FROM checkin.hty_initialdatehour::TIME)/3600 end AS checkin_hora1
    , case when extract(epoch FROM checkin.hty_initialdatehour::TIME)/3600 > 12
      then extract(epoch FROM checkin.hty_initialdatehour::TIME)/3600 end AS checkin_hora2
    , extract(epoch FROM checkout.hty_initialdatehour::TIME)/3600 AS checkout_hora
    , extract(epoch FROM intervalo.hty_initialdatehour::TIME)/3600 AS intervalo_i_hora
    , extract(epoch FROM intervalo.hty_finaldatehour::TIME)/3600 AS intervalo_f_hora
    , NULL::DOUBLE PRECISION AS execucao_i_hora
    , NULL::DOUBLE PRECISION AS execucao_f_hora
    , NULL::DOUBLE PRECISION AS acoes_i_hora
    , NULL::DOUBLE PRECISION AS acoes_f_hora
    , NULL::DOUBLE PRECISION AS correcoes_i_hora
    , NULL::DOUBLE PRECISION AS correcoes_f_hora

FROM u19947.dbout_task t
INNER JOIN u19947.dbout_local                            loc            ON (t.loc_id = loc.loc_id)
--LEFT  JOIN dbout_customentity_brb                 rota           ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', t.tsk_scheduleinitialdatehour)::DATE)
--LEFT  JOIN dbout_agent                            art            ON (rota.i_rota_promotor_codigo = art.age_integrationid)
INNER JOIN u19947.dbout_agent                            age            ON (t.age_id = age.age_id)
LEFT  JOIN u19947.agentgroup                             agg            ON (age.agg_id = agg.agg_id)
LEFT  JOIN u19947.history                                checkin        ON (t.tsk_id = checkin.tsk_id AND checkin.act_id = 536385)
LEFT  JOIN u19947.history                                checkout       ON (t.tsk_id = checkout.tsk_id AND checkout.act_id = 536408)
LEFT  JOIN u19947.history                                intervalo      ON (t.tsk_id = intervalo.tsk_id AND intervalo.act_id = 575265)
INNER JOIN u19947.taskactivity                           tsa            ON (tsa.tsk_id = t.tsk_id AND tsa.act_id = 536385)
WHERE (t.tsk_situation <> 'Cancelada' OR (t.tsk_situation = 'Cancelada' AND t.tsk_modulelastupdate = 'Integration'))
AND agg.agg_description ilike 'AUDITOR'
AND t.tsk_scheduleinitialdatehour::DATE >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL
)
UNION ALL
/* EXECUÇÃO */
(
SELECT
    /* AUDITOR */
      age.age_name as "Auditor"
    , null as "Auditor Rota"
    , age.age_lastgeoposition as "Auditor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Auditor Ultima Sincronização"
    , agg.agg_description as "Auditor Grupo"
    , age.e_agent_mix as "Auditor Mix"
    , age.e_regional as "Auditor Regional"
    , age.e_hora_inicio as "Auditor Hora Inicio"
    , (extract(epoch FROM (age.e_hora_inicio)::TIME)/3600) as "Hora Inicio"
    , age.e_hora_fim as "Auditor Hora Fim"
    , age.e_salario as "Auditor Salário"
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
    , null as "Rota"
     /* TAREFAS */
    , null as act_id
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
    /* PREVISAO E EXECUCAO */
    , t.tsk_id as "Qtd Tarefas Previstas"
    , NULL::bigint as "Qtd Tarefas Executadas"
    , t.loc_id as "Qtd PDVs Previstos"
    , NULL::bigint as "Qtd PDVs Executados"
    /* TEMPOS*/
    , NULL::DOUBLE PRECISION AS tempo_previsto
    , NULL::DOUBLE PRECISION AS tempo_trabalho
    , NULL::DOUBLE PRECISION AS tempo_intervalo
    , extract(epoch FROM (checkout.hty_initialdatehour - checkin.hty_initialdatehour)::TIME)/3600 AS tempo_execucao
    , NULL::DOUBLE PRECISION AS tempo_acoes
    , NULL::DOUBLE PRECISION AS tempo_correcoes
    /* HORARIOS */
    , NULL::DOUBLE PRECISION AS checkin_hora
    , NULL::DOUBLE PRECISION AS checkout_hora
    , NULL::DOUBLE PRECISION AS checkin_hora1
    , NULL::DOUBLE PRECISION AS checkin_hora2
    , NULL::DOUBLE PRECISION  AS intervalo_i_hora
    , NULL::DOUBLE PRECISION  AS intervalo_f_hora
    , extract(epoch FROM checkin.hty_initialdatehour::TIME)/3600 AS execucao_i_hora
    , extract(epoch FROM checkout.hty_initialdatehour::TIME)/3600 AS execucao_f_hora
    , NULL::DOUBLE PRECISION AS acoes_i_hora
    , NULL::DOUBLE PRECISION AS acoes_f_hora
    , NULL::DOUBLE PRECISION AS correcoes_i_hora
    , NULL::DOUBLE PRECISION AS correcoes_f_hora

FROM u19947.dbout_task t
INNER JOIN u19947.dbout_local                            loc            ON (t.loc_id = loc.loc_id)
--LEFT  JOIN dbout_customentity_brb                 rota           ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', t.tsk_scheduleinitialdatehour)::DATE)
--LEFT  JOIN dbout_agent                            art            ON (rota.i_rota_promotor_codigo = art.age_integrationid)
INNER JOIN u19947.dbout_agent                            age            ON (t.age_id = age.age_id)
LEFT  JOIN u19947.agentgroup                             agg            ON (age.agg_id = agg.agg_id)
INNER JOIN u19947.history                                checkin        ON (t.tsk_id = checkin.tsk_id AND checkin.act_id = 632516)
LEFT  JOIN u19947.history                                checkout       ON (t.tsk_id = checkout.tsk_id AND checkout.act_id = 632517)
WHERE (t.tsk_situation <> 'Cancelada' OR (t.tsk_situation = 'Cancelada' AND t.tsk_modulelastupdate = 'Integration'))
AND agg.agg_description ilike 'AUDITOR'
AND t.tsk_scheduleinitialdatehour::DATE >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL
)

UNION ALL
/* AÇÕES */
(SELECT
    /* AUDITOR */
      age.age_name as "Auditor"
    , null as "Auditor Rota"
    , age.age_lastgeoposition as "Auditor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Auditor Ultima Sincronização"
    , agg.agg_description as "Auditor Grupo"
    , age.e_agent_mix as "Auditor Mix"
    , age.e_regional as "Auditor Regional"
    , age.e_hora_inicio as "Auditor Hora Inicio"
    , (extract(epoch FROM (age.e_hora_inicio)::TIME)/3600) as "Hora Inicio"
    , age.e_hora_fim as "Auditor Hora Fim"
    , age.e_salario as "Auditor Salário"
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
    , null as "Rota"
     /* TAREFAS */
    , null as act_id
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
    /* PREVISAO E EXECUCAO */
    , t.tsk_id as "Qtd Tarefas Previstas"
    , NULL::bigint as "Qtd Tarefas Executadas"
    , t.loc_id as "Qtd PDVs Previstos"
    , NULL::bigint as "Qtd PDVs Executados"
    /* TEMPOS*/
    , NULL::DOUBLE PRECISION AS tempo_previsto
    , NULL::DOUBLE PRECISION AS tempo_trabalho
    , NULL::DOUBLE PRECISION AS tempo_intervalo
    , NULL::DOUBLE PRECISION AS tempo_execucao
    , extract(epoch FROM (acoes.hty_finaldatehour - acoes.hty_initialdatehour)::TIME)/3600 AS tempo_acoes
    , NULL::DOUBLE PRECISION AS tempo_correcoes
    /* HORARIOS */
    , NULL::DOUBLE PRECISION AS checkin_hora
    , NULL::DOUBLE PRECISION AS checkout_hora
    , NULL::DOUBLE PRECISION AS checkin_hora1
    , NULL::DOUBLE PRECISION AS checkin_hora2
    , NULL::DOUBLE PRECISION  AS intervalo_i_hora
    , NULL::DOUBLE PRECISION  AS intervalo_f_hora
    , NULL::DOUBLE PRECISION AS execucao_i_hora
    , NULL::DOUBLE PRECISION AS execucao_f_hora
    , extract(epoch FROM acoes.hty_initialdatehour::TIME)/3600 AS acoes_i_hora
    , extract(epoch FROM acoes.hty_finaldatehour::TIME)/3600 AS acoes_f_hora
    , NULL::DOUBLE PRECISION AS correcoes_i_hora
    , NULL::DOUBLE PRECISION AS correcoes_f_hora

FROM u19947.dbout_task t
INNER JOIN u19947.dbout_local                            loc            ON (t.loc_id = loc.loc_id)
--LEFT  JOIN dbout_customentity_brb                 rota           ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', t.tsk_scheduleinitialdatehour)::DATE)
--LEFT  JOIN dbout_agent                            art            ON (rota.i_rota_promotor_codigo = art.age_integrationid)
INNER JOIN u19947.dbout_agent                            age            ON (t.age_id = age.age_id)
LEFT  JOIN u19947.agentgroup                             agg            ON (age.agg_id = agg.agg_id)
INNER JOIN u19947.history                                acoes          ON (t.tsk_id = acoes.tsk_id AND acoes.act_id = 616216)
WHERE (t.tsk_situation <> 'Cancelada' OR (t.tsk_situation = 'Cancelada' AND t.tsk_modulelastupdate = 'Integration'))
AND agg.agg_description ilike 'AUDITOR'
AND t.tsk_scheduleinitialdatehour::DATE >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL
)

UNION ALL
/* CORREÇÕES */
(SELECT
   /* AUDITOR */
      age.age_name as "Auditor"
    , null as "Auditor Rota"
    , age.age_lastgeoposition as "Auditor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Auditor Ultima Sincronização"
    , agg.agg_description as "Auditor Grupo"
    , age.e_agent_mix as "Auditor Mix"
    , age.e_regional as "Auditor Regional"
    , age.e_hora_inicio as "Auditor Hora Inicio"
    , (extract(epoch FROM (age.e_hora_inicio)::TIME)/3600) as "Hora Inicio"
    , age.e_hora_fim as "Auditor Hora Fim"
    , age.e_salario as "Auditor Salário"
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
    , null as "Rota"
     /* TAREFAS */
    , null as act_id
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
    /* PREVISAO E EXECUCAO */
    , t.tsk_id as "Qtd Tarefas Previstas"
    , NULL::bigint as "Qtd Tarefas Executadas"
    , t.loc_id as "Qtd PDVs Previstos"
    , NULL::bigint as "Qtd PDVs Executados"
    /* TEMPOS*/
    , NULL::DOUBLE PRECISION AS tempo_previsto
    , NULL::DOUBLE PRECISION AS tempo_trabalho
    , NULL::DOUBLE PRECISION AS tempo_intervalo
    , NULL::DOUBLE PRECISION AS tempo_execucao
    , NULL::DOUBLE PRECISION AS tempo_acoes
    , extract(epoch FROM (acc.hty_finaldatehour - acc.hty_initialdatehour)::TIME)/3600 AS tempo_correcoes
    /* HORARIOS */
    , NULL::DOUBLE PRECISION AS checkin_hora
    , NULL::DOUBLE PRECISION AS checkout_hora
    , NULL::DOUBLE PRECISION AS checkin_hora1
    , NULL::DOUBLE PRECISION AS checkin_hora2
    , NULL::DOUBLE PRECISION  AS intervalo_i_hora
    , NULL::DOUBLE PRECISION  AS intervalo_f_hora
    , NULL::DOUBLE PRECISION AS execucao_i_hora
    , NULL::DOUBLE PRECISION AS execucao_f_hora
    , NULL::DOUBLE PRECISION AS acoes_i_hora
    , NULL::DOUBLE PRECISION AS acoes_f_hora
    , extract(epoch FROM acc.hty_initialdatehour::TIME)/3600 AS correcoes_i_hora
    , extract(epoch FROM acc.hty_finaldatehour::TIME)/3600 AS correcoes_f_hora

FROM u19947.dbout_task t
INNER JOIN u19947.dbout_local                            loc            ON (t.loc_id = loc.loc_id)
--LEFT JOIN  dbout_customentity_brb                 rota           ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', t.tsk_scheduleinitialdatehour)::DATE)
--left JOIN  dbout_agent                            art            ON (rota.i_rota_promotor_codigo = art.age_integrationid)
INNER JOIN u19947.dbout_agent                            age            ON (t.age_id = age.age_id)
LEFT  JOIN u19947.agentgroup                             agg            ON (age.agg_id = agg.agg_id)
INNER JOIN u19947.history                                acc            ON (t.tsk_id = acc.tsk_id AND acc.act_id = 616214)
WHERE (t.tsk_situation <> 'Cancelada' OR (t.tsk_situation = 'Cancelada' AND t.tsk_modulelastupdate = 'Integration'))
AND agg.agg_description ilike 'AUDITOR'
AND t.tsk_scheduleinitialdatehour::DATE >= DATE_TRUNC('YEAR', NOW()::DATE) - '1 YEAR'::INTERVAL
)