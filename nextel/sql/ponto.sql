WITH dados_promotores AS (
    SELECT * 
    FROM u22715.dbout_agent 
    INNER JOIN (
                SELECT DISTINCT tsk_realinitialdatehour::DATE periodo 
                FROM u22715.task 
                WHERE tsk_realinitialdatehour >= '2018-01-01'
                ) dates ON (TRUE) 
    WHERE age_active = '1' 
    AND TRIM(upper(age_name)) not in ('MASTER', 'BIMACHINE', 'MASTER TOP', 'TESTE', 'TESTE RENAN')
)
SELECT DISTINCT
     /* TAREFAS */
      t.tsk_id AS "Qtd Tarefas"
    , t.tsk_integrationid
    , t.tsk_situation AS "Situacao Tarefa"
    /* PROMOTOR*/
    , age.age_id AS "Qtd Promotor"
    , age.age_name AS "Promotor"
    , age.e_f466566 AS "Regional"
    , age.e_supervisor AS "Supervisor"
    , age.e_supervisor_nextel AS "Supervisor Nextel"
    , age.age_lastgeoposition AS "Geo Promotor"
    /* LOCAL */
    , loc.loc_id AS "Qtd PDV"
    , loc.loc_description AS "PDV"
    , loc.loc_state AS "UF"
    , loc.loc_city AS "Cidade"
    , loc.loc_geoposition AS "Geo PDV"
    , loc.loc_active AS "PDV Ativo"
    /*TEMPOS*/

    , extract(epoch FROM (t.tsk_realinitialdatehour)::time)/3600 AS "Hora Entrada Tarefa"
    , extract(epoch FROM (t.tsk_realfinaldatehour)::time)/3600 AS "Hora Saida Tarefa"
    , extract(epoch FROM t.tsk_realinitialdatehour::TIME)/3600 AS "horario inicio"
    , extract(epoch FROM t.tsk_lastexecutiondatehour::TIME)/3600 AS "horario fim"
    , COALESCE(entrada.e_f4184033::DATE, entrada.hty_finaldatehour::DATE, periodo::Date) as data_entrada
    , COALESCE(saida.e_f4184266::DATE, saida.hty_finaldatehour::DATE,periodo::Date) as data_saida
    , age.periodo AS periodo
    , age.periodo AS periodo_filtro
    /* CASE*/
    , CASE WHEN (COALESCE(entrada.e_f4184033::DATE, entrada.hty_finaldatehour::DATE) IS NULL) THEN '1' -- 1=VERMELHO
        WHEN (COALESCE(entrada.e_f4184033::DATE, entrada.hty_finaldatehour::DATE)) = (COALESCE(saida.e_f4184266::DATE, saida.hty_finaldatehour::DATE)) then '3' --verde
        ELSE '2' --amarelo
    END AS indicador
    
    , CASE WHEN (COALESCE(entrada.e_f4184033::DATE, entrada.hty_finaldatehour::DATE,periodo::DATE) IS NULL) THEN '-'
  	  	   ELSE to_char(COALESCE(entrada.e_f4184033::DATE, entrada.hty_finaldatehour::DATE,periodo::DATE)::date, 'DD/MM/YYYY') 
    END AS data_entrada_dia
  	
    , CASE WHEN (COALESCE(entrada.e_f4184033::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL) THEN age.age_id 
    END AS qtd_entrada_dia
    
    , CASE WHEN (COALESCE(saida.e_f4184266::DATE, saida.hty_finaldatehour::DATE, periodo::Date) IS NULL) THEN '-'
      	   ELSE to_char(COALESCE(saida.e_f4184266::DATE, saida.hty_finaldatehour::DATE, periodo::Date)::date, 'DD/MM/YYYY') 
    END AS data_saida_dia
  	
    , CASE WHEN (COALESCE(saida.e_f4184266::DATE, saida.hty_finaldatehour::DATE) IS NOT NULL) THEN age.age_id 
    END AS qtd_saida_dia

	, CASE WHEN saida.e_f4184266::DATE <> entrada.e_f4184033::DATE OR entrada.e_f4184033::DATE IS NULL THEN 'NÃO OK' 
           ELSE 'OK' 
    END AS status_entrada

    , CASE WHEN saida.e_f4184266::DATE = entrada.e_f4184033::DATE THEN 'OK' ELSE 'NÃO OK' END as status_saida
 	
    , CASE WHEN saida.e_f4184266::DATE <> entrada.e_f4184033::DATE THEN extract(epoch FROM (((entrada.e_f4184033::DATE)::TEXT || ' ' || ('23:00:00'::time)::TEXT)::TIMESTAMP - ((entrada.e_f4184033::DATE)::TEXT || ' ' || (entrada.e_f4184013::time)::TEXT)::TIMESTAMP)::TIME)/3600
    	   WHEN saida.e_f4184266::DATE = entrada.e_f4184033::DATE THEN extract(epoch FROM (((saida.e_f4184266::DATE)::TEXT || ' ' || (saida.e_f4184016::time)::TEXT)::TIMESTAMP - ((entrada.e_f4184033::DATE)::TEXT || ' ' || (entrada.e_f4184013::time)::TEXT)::TIMESTAMP)::TIME)/3600
    	   ELSE '0' 
    END AS tempo_trabalho

FROM  dados_promotores age
LEFT JOIN u22715.dbout_task                     t       ON (t.age_id = age.age_id and age.periodo = COALESCE(t.tsk_realfinaldatehour::date, t.tsk_realinitialdatehour::Date) and t.tsk_situation <> 'Cancelada')
LEFT JOIN u22715.dbout_local                  loc       ON (t.loc_id = loc.loc_id)
LEFT JOIN u22715.dbout_history_check_in       entrada   ON (t.tsk_id = entrada.tsk_id)
LEFT JOIN u22715.dbout_history_check_out      saida     ON (t.tsk_id = saida.tsk_id)