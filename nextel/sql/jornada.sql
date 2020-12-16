SELECT DISTINCT

    /* PROMOTOR*/
     age.age_id                                                                                             AS "Qtd Promotor"
    , age.age_name                                                                                          AS "Promotor"
    , age.age_lastgeoposition                                                                               AS "Geo Promotor"
    , age.e_matricula                                                                                       AS "Matricula"
    , age.e_entrada                                                                                         AS "Entrada"
    , age.e_saida                                                                                           AS "Saida"
    , age.e_intervalo                                                                                       AS "Intervalo"
    , agg.agg_description                                                                                   AS "Tipo de Pessoas"
    , age.e_posto                                                                                           AS "CR"
    , age.e_pis                                                                                             AS "PIS"
    , age.e_ctps                                                                                            AS "CTPS"
    , 'ACAO PROMOCOES E SERVIÇOS DE EVENTOS LTDA'                                                           AS "Razão Social"
    , '20.395.437/0001-89'                                                                                  AS "CNPJ"
    , tea.tea_description                                                                                   AS "Equipe"

     /* TAREFAS */
    , tsk.tsk_id
    , tsk.tsk_situation                                                                                     AS "Situacao da Tarefa"
    , tsk.tsk_scheduleinitialdatehour::DATE                                                                 AS "Periodo"
    , TO_CHAR(tsk.tsk_scheduleinitialdatehour::DATE, 'DD/MM/YYYY')                                          AS data_prevista

    , TO_TIMESTAMP((ie.e_data || ' ' || ie.e_hora), 'yyyy-MM-dd HH24:MI:SS')                                AS "Início do Expediente"
    , TO_TIMESTAMP((si.e_data || ' ' || si.e_hora), 'yyyy-MM-dd HH24:MI:SS')                                AS "Saída do Intervalo"
    , TO_TIMESTAMP((ri.e_data || ' ' || ri.e_hora), 'yyyy-MM-dd HH24:MI:SS')                                AS "Retorno do Intervalo"
    , TO_TIMESTAMP((fe.e_data || ' ' || fe.e_hora), 'yyyy-MM-dd HH24:MI:SS')                                AS "Fim do Expediente"

    , extract(epoch FROM TO_TIMESTAMP((ie.e_data || ' ' || ie.e_hora), 'yyyy-MM-dd HH24:MI:SS')::TIME)/3600 AS inicio_expediente
    , extract(epoch FROM TO_TIMESTAMP((si.e_data || ' ' || si.e_hora), 'yyyy-MM-dd HH24:MI:SS')::TIME)/3600 AS saida_intervalo
    , extract(epoch FROM TO_TIMESTAMP((ri.e_data || ' ' || ri.e_hora), 'yyyy-MM-dd HH24:MI:SS')::TIME)/3600 AS retorno_intervalo
    , extract(epoch FROM TO_TIMESTAMP((fe.e_data || ' ' || fe.e_hora), 'yyyy-MM-dd HH24:MI:SS')::TIME)/3600 AS fim_expediente

    , extract(epoch FROM (
        (TO_TIMESTAMP((si.e_data || ' ' || si.e_hora), 'yyyy-MM-dd HH24:MI:SS') - TO_TIMESTAMP((ie.e_data || ' ' || ie.e_hora), 'yyyy-MM-dd HH24:MI:SS'))
            +
        (TO_TIMESTAMP((fe.e_data || ' ' || fe.e_hora), 'yyyy-MM-dd HH24:MI:SS') - TO_TIMESTAMP((ri.e_data || ' ' || ri.e_hora), 'yyyy-MM-dd HH24:MI:SS'))
    )::TIME)/3600 AS tempo_trabalhado

    , CASE WHEN TO_TIMESTAMP((ie.e_data || ' ' || ie.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NULL THEN 'NÃO OK'
           ELSE 'OK'
    END as status_inicio

    , CASE WHEN TO_TIMESTAMP((fe.e_data || ' ' || fe.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NULL THEN 'NÃO OK'
           ELSE 'OK'
    END as status_fim

    , CASE WHEN TO_TIMESTAMP((si.e_data || ' ' || si.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NULL THEN 'NÃO OK'
           ELSE 'OK'
    END as status_saida

    , CASE WHEN TO_TIMESTAMP((ri.e_data || ' ' || ri.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NULL THEN 'NÃO OK'
           ELSE 'OK'
    END as status_retorno

    , CASE WHEN
            (TO_TIMESTAMP((ie.e_data || ' ' || ie.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NOT NULL AND
             TO_TIMESTAMP((fe.e_data || ' ' || fe.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NOT NULL AND
             TO_TIMESTAMP((si.e_data || ' ' || si.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NOT NULL AND
             TO_TIMESTAMP((ri.e_data || ' ' || ri.e_hora), 'yyyy-MM-dd HH24:MI:SS')::DATE IS NOT NULL)
            THEN 'OK'
            ELSE 'NÃO OK'
    END AS status_expediente

FROM  u22715.dbout_task                                tsk
LEFT JOIN u22715.dbout_agent                           age             ON (tsk.age_id = age.age_id)
LEFT JOIN u22715.agentgroup                            agg             ON (age.agg_id = agg.agg_id)
LEFT JOIN u22715.dbout_local                           loc             ON (tsk.loc_id = loc.loc_id)
LEFT JOIN u22715.vw_responsible_team_recursive         age_tea         ON (age.age_id = age_tea.agent)
LEFT JOIN u22715.dbout_team                            tea             ON (age_tea.team = tea.tea_id)

INNER JOIN u22715.dbout_history_inicioexpediente       ie              ON (tsk.tsk_id = ie.tsk_id)
LEFT JOIN u22715.dbout_history_fimexpediente           fe              ON (tsk.tsk_id = fe.tsk_id)
LEFT JOIN u22715.dbout_history_saidaintervalo          si              ON (tsk.tsk_id = si.tsk_id)
LEFT JOIN u22715.dbout_history_retornointervalo        ri              ON (tsk.tsk_id = ri.tsk_id)

WHERE tsk.tsk_scheduleinitialdatehour >= date_trunc('month', now()) - '1 month'::interval
AND loc.loc_description = 'Controle de Jornada';