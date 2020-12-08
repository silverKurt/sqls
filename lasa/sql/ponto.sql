WITH dados_promotores AS (
    SELECT * 
    FROM dbout_agent
    INNER JOIN 
            (SELECT DISTINCT tsk_realinitialdatehour::DATE periodo 
            FROM task 
            WHERE tsk_realinitialdatehour::date >= '2018-01-01') dates ON (TRUE)
    WHERE age_active = '1'
    AND age_login NOT IN ('master', 'suporteumov', 'suportetecnico', 'marcos')
), ausencias as (
    SELECT
        /* PROMOTOR*/
        hty_initialdatehour::date as "Data Inicio Ausencia"
        , hty_finaldatehour::date as "Data Termino Ausencia"
        , tsk_scheduleinitialdatehour as "Data Previsao Ausencia"
        , case when e_motivo_nao_realizada = 'Outros' then e_observacoes else e_motivo_nao_realizada end as "Motivo"
        , age_id as "Promotor"
        ,(his.hty_finaldatehour::date-his.hty_initialdatehour::date) +1 as "Qtd Dias Ausência"
    FROM dbout_history_justificativa_nao_visita his
)

SELECT DISTINCT
    
    /* PROMOTOR*/
     age.age_id                                                                               AS "Qtd Promotor"
    , age.age_name                                                                            AS "Promotor"
    , age.e_888                                                                               AS "Responsavel"
    , age.e_889                                                                               AS "Regional"
    , age.age_lastgeoposition                                                                 AS "Geo Promotor"

    /*TEMPOS*/
    , extract(epoch FROM entrada.e_hora_check_in::time)/3600                                  AS hora_entrada
    , extract(epoch FROM saida.e_hora_check_out::time)/3600                                   AS hora_saida
    
     /* LOCAL */
    , loc.loc_description                                                                     AS "PDV"
    , loc.loc_state                                                                           AS "UF"
    , loc.loc_city                                                                            AS "Cidade"
    , loc.loc_neighborhood
    , loc.loc_geoposition                                                                     AS "Geolocalização"
    , loc.loc_active                                                                          AS "Status"
    , ausencias."Motivo"                                                                      AS "Motivo Ausencia"
    
     /* TAREFAS */
    , t.tsk_id
    , t.loc_id
    , t.tsk_situation
    , COALESCE(entrada.e_data_check_in::DATE, entrada.hty_finaldatehour::DATE, periodo::DATE) AS data_entrada
    , COALESCE(saida.e_data_check_out::DATE, saida.hty_finaldatehour::DATE, periodo::DATE)    AS data_saida
    , TO_CHAR(t.tsk_scheduleinitialdatehour::DATE, 'DD/MM/YYYY')                              AS data_prevista
    , t.tsk_scheduleinitialdatehour::DATE                                                     AS data_prevista_filtro

    , age.periodo AS periodo

    , extract(epoch FROM t.tsk_realinitialdatehour::TIME)/3600                                AS horario_ini
    , extract(epoch FROM t.tsk_lastexecutiondatehour::TIME)/3600                              AS horario_fim
    , extract(epoch FROM t.tsk_realinitialdatehour::TIME)/3600                                AS horario_inicial
    , extract(epoch FROM t.tsk_lastexecutiondatehour::TIME)/3600                              AS horario_final

    , CASE WHEN (COALESCE(entrada.e_data_check_in::DATE, entrada.hty_finaldatehour::DATE) IS NULL) THEN '-' 
           ELSE TO_CHAR(COALESCE(entrada.e_data_check_in::DATE, entrada.hty_finaldatehour::DATE)::DATE, 'DD/MM/YYYY') 
    END AS data_entrada_dia

    , CASE WHEN (COALESCE(entrada.e_data_check_in::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL) THEN age.age_id 
    END AS qtd_entrada_dia
    

    , CASE WHEN (COALESCE(saida.e_data_check_out::DATE, saida.hty_finaldatehour::DATE) IS NULL) THEN '-' 
           ELSE to_char(COALESCE(saida.e_data_check_out::DATE, saida.hty_finaldatehour::DATE)::DATE, 'DD/MM/YYYY') 
    END AS data_saida_dia
    
    , CASE WHEN (COALESCE(saida.e_data_check_out::DATE, saida.hty_finaldatehour::DATE) IS NOT NULL) THEN age.age_id 
    END AS qtd_saida_dia

    , CASE WHEN entrada.e_data_check_in::DATE IS NULL and ausencias."Motivo" is not null THEN 'JUSTIFICADO - '||ausencias."Motivo"
         WHEN (entrada.e_data_check_in::DATE IS NULL and ausencias."Motivo" is null) THEN 'NÃO OK'
         ELSE 'OK' 
    END as status_entrada

    , CASE WHEN entrada.e_data_check_in::DATE IS NULL and ausencias."Motivo" is not null THEN 'JUSTIFICADO - '||ausencias."Motivo"
           WHEN  (saida.e_data_check_out::DATE IS NULL and ausencias."Motivo" is null) or  saida.e_data_check_out::DATE <> entrada.e_data_check_in::DATE THEN 'NÃO OK'
           ELSE 'OK' 
    END as status_saida

    , CASE WHEN saida.e_data_check_out::DATE <> entrada.e_data_check_in::DATE THEN extract(epoch FROM (((entrada.e_data_check_in::DATE)::TEXT || ' ' || ('23:00:00'::time)::TEXT)::TIMESTAMP - ((entrada.e_data_check_in::DATE)::TEXT || ' ' || (entrada.e_hora_check_in::time)::TEXT)::TIMESTAMP)::TIME)/3600
           ELSE extract(epoch FROM (((saida.e_data_check_out::DATE)::TEXT || ' ' || (saida.e_hora_check_out::time)::TEXT)::TIMESTAMP - ((entrada.e_data_check_in::DATE)::TEXT || ' ' || (entrada.e_hora_check_in::time)::TEXT)::TIMESTAMP)::TIME)/3600
    END AS tempo_trabalho

FROM  dados_promotores age
LEFT JOIN dbout_task                            t               ON (t.age_id = age.age_id and age.periodo = COALESCE(t.tsk_realinitialdatehour::date, t.tsk_realfinaldatehour::Date) and t.tsk_situation <> 'Cancelada')
LEFT JOIN dbout_local                           loc             ON (t.loc_id = loc.loc_id)
LEFT JOIN dbout_history_check_in                entrada         ON (t.tsk_id = entrada.tsk_id)
LEFT JOIN dbout_history_check_out               saida           ON (t.tsk_id = saida.tsk_id)
LEFT JOIN ausencias                             ausencias       ON (ausencias."Promotor" = age.age_id and (periodo >= ausencias."Data Inicio Ausencia" and periodo <= "Data Termino Ausencia"))