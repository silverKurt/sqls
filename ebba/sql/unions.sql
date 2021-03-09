SELECT * FROM (
SELECT DISTINCT
    /* PROMOTOR*/
      age.age_name as "Promotor"
    --, split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1)::TEXT || ' ' || regexp_replace(SUBSTRING(initcap(lower(CAST(age.age_name AS TEXT))), length(split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1))+2), '([a-z ])+', '. ', 'g') AS "Nome Abreviado"
    , age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Promotor Ultima Sincronização"
    , tea.tea_description           AS "Equipe"

     /* LOCAL */
    , loc.loc_description as "PDV"
    , loc.loc_state as "PDV Estado"
    , loc.loc_city as "PDV Cidade"
    , loc.loc_neighborhood as "PDV Bairro"
    , loc.loc_geoposition as "PDV Geo"
    , loc.loc_integrationid as "PDV Código"
    , loc.loc_active as "PDV Ativo"
    , loc.e_canal AS "PDV Canal"
    , loc.e_bandeira AS "Rede"


     /* TAREFAS */
    , t.tsk_id
    , t.age_id
    , t.loc_id
    , t.tsk_situation as "Situação Tarefa"
    , t.tsk_scheduleinitialdatehour as "Data Inicio Previsto"
    , t.tsk_schedulefinaldatehour as "Data Fim Previsto"
    , t.tsk_realinitialdatehour as "Data Inicio"
    , t.tsk_realfinaldatehour as "Data Fim"

    /*Histórico*/
    , 'CONCENTRADO' AS "Categoria"
    , sha.e_con_bi_perc::DOUBLE PRECISION/100 AS "Participacao Bela Ischia"
    , sha.e_con_df_perc::DOUBLE PRECISION/100 AS "Participacao Difruta"
    , sha.e_con_mgy_perc::DOUBLE PRECISION/100 AS "Participacao Maguary"
    , sha.e_con_total_perc::DOUBLE PRECISION/100 AS "Participacao Total"
    , sha.e_con_perc_conco::DOUBLE PRECISION/100 AS "Participacao Concorrencia"


FROM u28690.dbout_task                             t
LEFT JOIN u28690.dbout_agent                       age   ON (t.age_id = age.age_id)
LEFT JOIN u28690.dbout_local                       loc   ON (t.loc_id = loc.loc_id)
INNER JOIN u28690.dbout_history_1107383_share       sha   ON (t.tsk_id = sha.tsk_id)
LEFT JOIN u28690.teamagent				  age_tea    ON (age.age_id = age_tea.age_id)
  LEFT JOIN u28690.dbout_team                  tea       ON (age_tea.tea_id = tea.tea_id)
WHERE age.age_active = '1'
AND TRIM(upper(age.age_name)) not in ('MASTER','GERENTE', 'SUPORTEUMOV', 'SUPORTETECNICO', 'SOL7')
AND TRIM(UPPER(loc.loc_description)) != 'INFORMAR PARADAS'

  /* PARA FILTRAR TODAS AS ATIVIDADES EXCETO "Auditoria do Supervisor" */
  AND t.tsk_id NOT IN (SELECT DISTINCT i.tsk_id FROM u28690.taskactivity i WHERE i.act_id = '1104325'))X
WHERE
      "Participacao Bela Ischia" IS NOT NULL
  AND "Participacao Difruta" IS NOT NULL
  AND "Participacao Maguary" IS NOT NULL
  AND "Participacao Total" IS NOT NULL
  AND "Participacao Concorrencia" IS NOT NULL

UNION ALL

SELECT * FROM (
SELECT DISTINCT
    /* PROMOTOR*/
      age.age_name as "Promotor"
    --, split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1)::TEXT || ' ' || regexp_replace(SUBSTRING(initcap(lower(CAST(age.age_name AS TEXT))), length(split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1))+2), '([a-z ])+', '. ', 'g') AS "Nome Abreviado"
    , age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Promotor Ultima Sincronização"
    , tea.tea_description           AS "Equipe"

     /* LOCAL */
    , loc.loc_description as "PDV"
    , loc.loc_state as "PDV Estado"
    , loc.loc_city as "PDV Cidade"
    , loc.loc_neighborhood as "PDV Bairro"
    , loc.loc_geoposition as "PDV Geo"
    , loc.loc_integrationid as "PDV Código"
    , loc.loc_active as "PDV Ativo"
    , loc.e_canal AS "PDV Canal"
    , loc.e_bandeira AS "Rede"


     /* TAREFAS */
    , t.tsk_id
    , t.age_id
    , t.loc_id
    , t.tsk_situation as "Situação Tarefa"
    , t.tsk_scheduleinitialdatehour as "Data Inicio Previsto"
    , t.tsk_schedulefinaldatehour as "Data Fim Previsto"
    , t.tsk_realinitialdatehour as "Data Inicio"
    , t.tsk_realfinaldatehour as "Data Fim"

    /*Histórico*/
    , 'FruitShoot' AS "Categoria"
    , NULL::DOUBLE PRECISION AS "Participacao Bela Ischia"
    , NULL::DOUBLE PRECISION AS "Participacao Difruta"
    , NULL::DOUBLE PRECISION AS "Participacao Maguary"

    , sha.e_fs_perc::DOUBLE PRECISION/100 AS "Participacao Total"
    , sha.e_fs_perc_conco::DOUBLE PRECISION/100 AS "Participacao Concorrencia"


FROM u28690.dbout_task                             t
LEFT JOIN u28690.dbout_agent                       age   ON (t.age_id = age.age_id)
LEFT JOIN u28690.dbout_local                       loc   ON (t.loc_id = loc.loc_id)
INNER JOIN u28690.dbout_history_1107383_share       sha   ON (t.tsk_id = sha.tsk_id)
LEFT JOIN u28690.teamagent				  age_tea    ON (age.age_id = age_tea.age_id)
  LEFT JOIN u28690.dbout_team                  tea       ON (age_tea.tea_id = tea.tea_id)
WHERE age.age_active = '1'
AND TRIM(upper(age.age_name)) not in ('MASTER','GERENTE', 'SUPORTEUMOV', 'SUPORTETECNICO', 'SOL7')
AND TRIM(UPPER(loc.loc_description)) != 'INFORMAR PARADAS'

  /* PARA FILTRAR TODAS AS ATIVIDADES EXCETO "Auditoria do Supervisor" */
  AND t.tsk_id NOT IN (SELECT DISTINCT i.tsk_id FROM u28690.taskactivity i WHERE i.act_id = '1104325'))X
WHERE
      "Participacao Total" IS NOT NULL
  AND "Participacao Concorrencia" IS NOT NULL

UNION ALL

SELECT * FROM (
SELECT DISTINCT
    /* PROMOTOR*/
      age.age_name as "Promotor"
    --, split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1)::TEXT || ' ' || regexp_replace(SUBSTRING(initcap(lower(CAST(age.age_name AS TEXT))), length(split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1))+2), '([a-z ])+', '. ', 'g') AS "Nome Abreviado"
    , age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Promotor Ultima Sincronização"
    , tea.tea_description           AS "Equipe"

     /* LOCAL */
    , loc.loc_description as "PDV"
    , loc.loc_state as "PDV Estado"
    , loc.loc_city as "PDV Cidade"
    , loc.loc_neighborhood as "PDV Bairro"
    , loc.loc_geoposition as "PDV Geo"
    , loc.loc_integrationid as "PDV Código"
    , loc.loc_active as "PDV Ativo"
    , loc.e_canal AS "PDV Canal"
    , loc.e_bandeira AS "Rede"


     /* TAREFAS */
    , t.tsk_id
    , t.age_id
    , t.loc_id
    , t.tsk_situation as "Situação Tarefa"
    , t.tsk_scheduleinitialdatehour as "Data Inicio Previsto"
    , t.tsk_schedulefinaldatehour as "Data Fim Previsto"
    , t.tsk_realinitialdatehour as "Data Inicio"
    , t.tsk_realfinaldatehour as "Data Fim"

    /*Histórico*/
    , 'Uva Integral' AS "Categoria"
    , NULL::DOUBLE PRECISION AS "Participacao Bela Ischia"
    , NULL::DOUBLE PRECISION AS "Participacao Difruta"
    , NULL::DOUBLE PRECISION AS "Participacao Maguary"

    , sha.e_ui_mgy_perc::DOUBLE PRECISION/100 AS "Participacao Total"
    , sha.e_ui_conco_perc::DOUBLE PRECISION/100 AS "Participacao Concorrencia"



FROM u28690.dbout_task                             t
LEFT JOIN u28690.dbout_agent                       age   ON (t.age_id = age.age_id)
LEFT JOIN u28690.dbout_local                       loc   ON (t.loc_id = loc.loc_id)
INNER JOIN u28690.dbout_history_1107383_share       sha   ON (t.tsk_id = sha.tsk_id)
LEFT JOIN u28690.teamagent				  age_tea    ON (age.age_id = age_tea.age_id)
  LEFT JOIN u28690.dbout_team                  tea       ON (age_tea.tea_id = tea.tea_id)
WHERE age.age_active = '1'
AND TRIM(upper(age.age_name)) not in ('MASTER','GERENTE', 'SUPORTEUMOV', 'SUPORTETECNICO', 'SOL7')
AND TRIM(UPPER(loc.loc_description)) != 'INFORMAR PARADAS'

  /* PARA FILTRAR TODAS AS ATIVIDADES EXCETO "Auditoria do Supervisor" */
  AND t.tsk_id NOT IN (SELECT DISTINCT i.tsk_id FROM u28690.taskactivity i WHERE i.act_id = '1104325'))X
WHERE
      "Participacao Total" IS NOT NULL
  AND "Participacao Concorrencia" IS NOT NULL

UNION ALL

SELECT * FROM (
SELECT DISTINCT
    /* PROMOTOR*/
      age.age_name as "Promotor"
    --, split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1)::TEXT || ' ' || regexp_replace(SUBSTRING(initcap(lower(CAST(age.age_name AS TEXT))), length(split_part(initcap(lower(CAST(age.age_name AS TEXT))), ' ', 1))+2), '([a-z ])+', '. ', 'g') AS "Nome Abreviado"
    , age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, 'dd/mm/yyyy hh:mi:ss') AS "Promotor Ultima Sincronização"
  	, tea.tea_description           AS "Equipe"

     /* LOCAL */
    , loc.loc_description as "PDV"
    , loc.loc_state as "PDV Estado"
    , loc.loc_city as "PDV Cidade"
    , loc.loc_neighborhood as "PDV Bairro"
    , loc.loc_geoposition as "PDV Geo"
    , loc.loc_integrationid as "PDV Código"
    , loc.loc_active as "PDV Ativo"
    , loc.e_canal AS "PDV Canal"
    , loc.e_bandeira AS "Rede"


     /* TAREFAS */
    , t.tsk_id
    , t.age_id
    , t.loc_id
    , t.tsk_situation as "Situação Tarefa"
    , t.tsk_scheduleinitialdatehour as "Data Inicio Previsto"
    , t.tsk_schedulefinaldatehour as "Data Fim Previsto"
    , t.tsk_realinitialdatehour as "Data Inicio"
    , t.tsk_realfinaldatehour as "Data Fim"

    /*Histórico*/
    , 'PPB' AS "Categoria"

    , sha.e_ppb_bi_perc::DOUBLE PRECISION/100 AS "Participacao Bela Ischia"
    , sha.e_ppb_df_perc::DOUBLE PRECISION/100 AS "Participacao Difruta"
    , sha.e_ppb_mgy_perc::DOUBLE PRECISION/100 AS "Participacao Maguary"

    , sha.e_ppb_total_perc::DOUBLE PRECISION/100 AS "Participacao Total"
    , sha.e_ppb_conco_perc::DOUBLE PRECISION/100 AS "Participacao Concorrencia"


FROM u28690.dbout_task                             t
LEFT JOIN u28690.dbout_agent                       age   ON (t.age_id = age.age_id)
LEFT JOIN u28690.dbout_local                       loc   ON (t.loc_id = loc.loc_id)
INNER JOIN u28690.dbout_history_1107383_share       sha   ON (t.tsk_id = sha.tsk_id)
LEFT JOIN u28690.teamagent				  age_tea    ON (age.age_id = age_tea.age_id)
LEFT JOIN u28690.dbout_team                  tea       ON (age_tea.tea_id = tea.tea_id)
WHERE age.age_active = '1'
AND TRIM(upper(age.age_name)) not in ('MASTER','GERENTE', 'SUPORTEUMOV', 'SUPORTETECNICO', 'SOL7')
AND TRIM(UPPER(loc.loc_description)) != 'INFORMAR PARADAS'

  /* PARA FILTRAR TODAS AS ATIVIDADES EXCETO "Auditoria do Supervisor" */
  AND t.tsk_id NOT IN (SELECT DISTINCT i.tsk_id FROM u28690.taskactivity i WHERE i.act_id = '1104325'))X
WHERE
      "Participacao Bela Ischia" IS NOT NULL
  AND "Participacao Difruta" IS NOT NULL
  AND "Participacao Maguary" IS NOT NULL
  AND "Participacao Total" IS NOT NULL
  AND "Participacao Concorrencia" IS NOT NULL