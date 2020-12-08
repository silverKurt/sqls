SELECT DISTINCT
    
    /* PROMOTOR*/
     age.age_id                                                                               AS "Qtd Promotor"
    , age.age_name                                                                            AS "Promotor"
    , age.e_888                                                                               AS "Responsavel"
    , age.e_889                                                                               AS "Regional"
    , age.age_lastgeoposition                                                                 AS "Geo Promotor"
    
     /* TAREFAS */
    , tsk.tsk_id
    , tsk.tsk_situation                                                                       AS "Situacao da Tarefa"
    , tsk.tsk_scheduleinitialdatehour::DATE                                                   AS "Periodo"
    , TO_CHAR(tsk.tsk_scheduleinitialdatehour::DATE, 'DD/MM/YYYY')                            AS data_prevista
              
    , ie.e_data_e_hora                                                                        AS "Início do Expediente"
    , si.e_data_e_hora                                                                        AS "Saída do Intervalo"
    , ri.e_data_e_hora                                                                        AS "Retorno do Intervalo"
    , fe.e_data_e_hora                                                                        AS "Fim do Expediente"

    , extract(epoch FROM tsk.tsk_realinitialdatehour::TIME)/3600                              AS horario_ini
    , extract(epoch FROM tsk.tsk_lastexecutiondatehour::TIME)/3600                            AS horario_fim
    , extract(epoch FROM tsk.tsk_realinitialdatehour::TIME)/3600                              AS horario_inicial
    , extract(epoch FROM tsk.tsk_lastexecutiondatehour::TIME)/3600                            AS horario_final




FROM  u13408.dbout_task                                tsk
LEFT JOIN u13408.dbout_agent                           age             ON (tsk.age_id = age.age_id)
LEFT JOIN u13408.dbout_local                           loc             ON (tsk.loc_id = loc.loc_id)

LEFT JOIN u13408.dbout_history_inicioexpediente        ie              ON (tsk.tsk_id = ie.tsk_id)
LEFT JOIN u13408.dbout_history_fimexpediente           fe              ON (tsk.tsk_id = fe.tsk_id)
LEFT JOIN u13408.dbout_history_saidaintervalo          si              ON (tsk.tsk_id = si.tsk_id)
LEFT JOIN u13408.dbout_history_retornointervalo        ri              ON (tsk.tsk_id = ri.tsk_id)

WHERE tsk.tsk_scheduleinitialdatehour >= date_trunc('month', now()) - '1 month'::interval
AND tsk.tsk_situation <> 'Cancelada'
AND loc.loc_description = 'Controle de Jornada'