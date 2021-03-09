WITH dbout_supervisores AS (

    SELECT age.age_id, age.age_name, age.age_integrationid
    FROM u28690.agent age
    LEFT JOIN u28690.agentgroup agg ON age.agg_id = agg.agg_id
    WHERE REGEXP_REPLACE(upper(agg.agg_description), '[ ]{2,}', ' ') IN ('SUPERVISOR DE VENDAS', 'SUPERVISOR MERCHAN', 'GERENTE DE VENDAS')

)
SELECT * 
       , CASE WHEN COALESCE(tempo_deslocamento, 0) < 0 THEN 'DESCONSIDERAR' ELSE 'OK' END AS "Status do Deslocamento"
       , "Hora Entrada Tarefa" as "Primeira Entrada"
       , "Hora Saida Tarefa" AS "Última Saída"
FROM (
SELECT DISTINCT
  "Qtd Tarefas"
    , tsk_integrationid
    , "Situacao Tarefa"
    , "Periodo"
    , "Promotor"
    , "Qtd Supervisor"
    , "Supervisor"
    , "Hora Entrada Tarefa"
    , "Hora Saida Tarefa"
    , CASE WHEN "Qtd PDV" = 79123492 THEN NULL
        ELSE  
        (CASE WHEN LAG("Qtd PDV", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa") = 79123492 THEN 
            ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 2) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
            ELSE ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
        END) 
    END AS tempo_deslocamento
    , CASE WHEN "Qtd PDV" = 79123492 THEN NULL
        ELSE  
        (CASE WHEN LAG("Qtd PDV", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa") = 79123492 THEN 
            ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 2) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
            ELSE ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
        END) 
    END AS tempo_deslocamento_media
    , "Qtd Promotor"
    , "Geo Promotor"
    , "Equipe"
    , "Qtd PDV"
    , "PDV"
    , CASE WHEN "PDV" = 'INTERVALO/ALMOÇO' THEN 'INTERVALO' ELSE 'OUTRO' END AS "status_local"
    , "UF"
    , "Cidade"
    , "Geo PDV"
    , "PDV Ativo"
    , "Promotor por Dia"
    , "Tempo de Trabalho"
    , "horario inicio"
    , "horario fim"
    , data_entrada
    , data_saida
    , indicador
    , status_visita
    , data_entrada_dia
    , data_saida_dia
    , qtd_entrada_dia
    , qtd_saida_dia
    , status_entrada
    , status_saida
    , geo_entrada
    , calculo_checkin AS "xx_calculo_checkin"
    , CASE
          WHEN (COALESCE(SPLIT_PART(x."Geo PDV", ',', 1), '') = '' OR COALESCE(SPLIT_PART(x."Geo PDV", ',', 2), '') = '')
          THEN 'PDV SEM COORDENADA'
          WHEN (COALESCE(SPLIT_PART(x.geo_entrada, ',', 1), '') = '' OR COALESCE(SPLIT_PART(x.geo_entrada, ',', 2), '') = '')
          THEN 'CHECK-IN SEM COORDENADA'
          ELSE (CASE WHEN x.calculo_checkin <= 0.3 THEN 'DENTRO DA ÁREA' ELSE 'FORA DA ÁREA' END)
      END AS area_checkin

FROM
(
  SELECT DISTINCT
       /* TAREFAS */
      t.tsk_id                      AS "Qtd Tarefas"
      , t.tsk_integrationid
      , CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND entrada.e_datacheckin::DATE IS NULL THEN 'REALIZOU SEM REGISTRAR PONTO'
             ELSE UPPER(TRIM(t.tsk_situation))
      END AS "Situacao Tarefa"
      , t.tsk_scheduleinitialdatehour AS "Periodo"
      /* PROMOTOR*/
      , age.age_id                    AS "Qtd Promotor"
      , age.age_name                  AS "Promotor"
      , age.age_lastgeoposition       AS "Geo Promotor"
      , tea.tea_description           AS "Equipe"
      , ags.age_id                    AS "Qtd Supervisor"
      , ags.age_name                  AS "Supervisor"
      /* LOCAL */
      , loc.loc_id                    AS "Qtd PDV"
      , CASE WHEN TRIM(UPPER(loc.loc_description)) = 'INFORMAR PARADAS' THEN 'INTERVALO/ALMOÇO' ELSE loc.loc_description END AS "PDV"
      , loc.loc_state                 AS "UF"
      , loc.loc_city                  AS "Cidade"
      , loc.loc_geoposition           AS "Geo PDV"
      , loc.loc_active                AS "PDV Ativo"
      , age.age_id::TEXT || '-' || t.tsk_scheduleinitialdatehour::DATE::TEXT || '-' || COALESCE(loc.loc_id::TEXT, 'NAO INFORMADO') AS "Promotor por Dia"
      /*TEMPOS COLOCAR CASE PARA TESTAR SOMENTE QUANDO NÃO FOR CANCELADA*/
      , CASE
          WHEN (t.tsk_situation <> 'Cancelada' AND loc.loc_id != 79123492) THEN (CASE WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL THEN (EXTRACT(EPOCH FROM t.tsk_realfinaldatehour) - EXTRACT(EPOCH FROM t.tsk_realinitialdatehour))/3600 END)
          ELSE (CASE WHEN t.tsk_situation <> 'Cancelada' AND COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NOT NULL THEN (EXTRACT(EPOCH FROM t.tsk_realfinaldatehour) - EXTRACT(EPOCH FROM t.tsk_realinitialdatehour))/3600 END)
      END AS "Tempo de Trabalho"

      , CASE
          WHEN (t.tsk_situation <> 'Cancelada' AND loc.loc_id != 79123492) THEN (CASE WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM (t.tsk_realinitialdatehour)::time)/3600 END)
          ELSE (CASE WHEN t.tsk_situation <> 'Cancelada' AND COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM (t.tsk_realinitialdatehour)::time)/3600 END)
      END AS "Hora Entrada Tarefa"

      , CASE
          WHEN (t.tsk_situation <> 'Cancelada' AND loc.loc_id != 79123492) THEN (CASE WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM (t.tsk_realfinaldatehour)::time)/3600 END)
          ELSE (CASE WHEN t.tsk_situation <> 'Cancelada' AND COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM (t.tsk_realfinaldatehour)::time)/3600 END)
      END AS "Hora Saida Tarefa"

      , CASE
          WHEN (t.tsk_situation <> 'Cancelada' AND loc.loc_id != 79123492) THEN (CASE WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM t.tsk_realinitialdatehour::TIME)/3600 END)
          ELSE (CASE WHEN t.tsk_situation <> 'Cancelada' AND COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM t.tsk_realinitialdatehour::TIME)/3600 END)
      END AS "horario inicio"

      , CASE
          WHEN (t.tsk_situation <> 'Cancelada' AND loc.loc_id != 79123492) THEN (CASE WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NOT NULL AND (TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE IS NOT NULL) THEN extract(epoch FROM t.tsk_lastexecutiondatehour::TIME)/3600 END)
          ELSE (CASE WHEN t.tsk_situation <> 'Cancelada' AND COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NOT NULL AND COALESCE(rp.e_data ::DATE, rp.hty_finaldatehour::DATE) IS NOT NULL THEN extract(epoch FROM t.tsk_lastexecutiondatehour::TIME)/3600 END)
      END AS "horario fim"

      , CASE WHEN loc.loc_id != 79123492 THEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE)
             ELSE COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE)
      END AS data_entrada

      , CASE WHEN loc.loc_id != 79123492 THEN COALESCE(TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE, saida.hty_finaldatehour::DATE)
             ELSE COALESCE(rp.e_data ::DATE, rp.hty_finaldatehour::DATE)
      END as data_saida

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND entrada.e_datacheckin::DATE IS NULL THEN '4'
                        WHEN UPPER(TRIM(t.tsk_situation)) IN ('EM CAMPO', 'PENDENTE DE ENVIO PARA CAMPO') AND entrada.e_datacheckin::DATE IS NULL THEN '5'
                        WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NULL THEN '1' --VERMELHO
                        WHEN (COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE)) = (COALESCE(TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE, saida.hty_finaldatehour::DATE)) then '3' --verde
                        ELSE '2' --amarelo
              END)
             ELSE
                  (CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND ip.e_data::DATE IS NULL THEN '4'
                        WHEN UPPER(TRIM(t.tsk_situation)) IN ('EM CAMPO', 'PENDENTE DE ENVIO PARA CAMPO') AND ip.e_data::DATE IS NULL THEN '5'
                        WHEN COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NULL THEN '1' --VERMELHO
                        WHEN (COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE)) = COALESCE(rp.e_data ::DATE, rp.hty_finaldatehour::DATE) then '3' --verde
                        ELSE '2' --amarelo
                  END)
      END AS indicador

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND entrada.e_datacheckin::DATE IS NULL THEN 'REALIZADO SEM ENTRADA OU SAÍDA'
                        WHEN UPPER(TRIM(t.tsk_situation)) IN ('EM CAMPO', 'PENDENTE DE ENVIO PARA CAMPO') AND entrada.e_datacheckin::DATE IS NULL THEN 'SENDO EXECUTADO'
                        WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NULL THEN 'CANCELADO' --VERMELHO
                        WHEN (COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE)) = (COALESCE(TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE, saida.hty_finaldatehour::DATE)) then 'TUDO OK' --verde
                        ELSE 'INCONSITÊNCIA NA SAÍDA' --amarelo
                  END)
              ELSE
                  (CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND ip.e_data::DATE IS NULL THEN 'REALIZADO SEM ENTRADA OU SAÍDA'
                        WHEN UPPER(TRIM(t.tsk_situation)) IN ('EM CAMPO', 'PENDENTE DE ENVIO PARA CAMPO') AND ip.e_data::DATE IS NULL THEN 'SENDO EXECUTADO'
                        WHEN COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NULL THEN 'CANCELADO' --VERMELHO
                        WHEN (COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE)) = COALESCE(rp.e_data ::DATE, rp.hty_finaldatehour::DATE) then 'TUDO OK' --verde
                        ELSE 'INCONSITÊNCIA NA SAÍDA' --amarelo
                  END)
      END AS status_visita

      /*, CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND entrada.e_datacheckin::DATE IS NULL THEN '4'
                        WHEN UPPER(TRIM(t.tsk_situation)) IN ('EM CAMPO', 'PENDENTE DE ENVIO PARA CAMPO') AND entrada.e_datacheckin::DATE IS NULL THEN '5'
                        WHEN COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE) IS NULL THEN '1' --VERMELHO
                        WHEN (COALESCE(entrada.e_datacheckin::DATE, entrada.hty_finaldatehour::DATE)) = (COALESCE(TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE, saida.hty_finaldatehour::DATE)) then '3' --verde
                        ELSE '2' --amarelo
                  END)
              ELSE
                  (CASE WHEN UPPER(TRIM(t.tsk_situation)) = 'RETORNADA DE CAMPO' AND ip.e_data::DATE IS NULL THEN '4'
                        WHEN UPPER(TRIM(t.tsk_situation)) IN ('EM CAMPO', 'PENDENTE DE ENVIO PARA CAMPO') AND ip.e_data::DATE IS NULL THEN '5'
                        WHEN COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE) IS NULL THEN '1' --VERMELHO
                        WHEN (COALESCE(ip.e_data::DATE, ip.hty_finaldatehour::DATE)) = COALESCE(rp.e_data ::DATE, rp.hty_finaldatehour::DATE) then '3' --verde
                        ELSE '2' --amarelo
                  END)
      END AS qtde_visitas_total*/

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN entrada.e_datacheckin::DATE IS NULL THEN '-'
                      ELSE to_char(entrada.e_datacheckin::DATE::date, 'DD/MM/YYYY')
                  END)
              ELSE
                  (CASE WHEN ip.e_data::DATE IS NULL THEN '-'
                      ELSE to_char(ip.e_data::date, 'DD/MM/YYYY')
                  END)
      END AS data_entrada_dia

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN (TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE IS NULL) THEN '-'
                        ELSE to_char(TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE::date, 'DD/MM/YYYY')
                  END)
              ELSE
                  (CASE WHEN rp.e_data::DATE IS NULL THEN '-'
                      ELSE to_char(rp.e_data::date, 'DD/MM/YYYY')
                  END)
      END AS data_saida_dia

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN (entrada.e_datacheckin::DATE IS NOT NULL)
                     THEN age.age_id::TEXT || '-' || (entrada.e_datacheckin::DATE)::TEXT || '-' || loc.loc_id::TEXT
                  END)
              ELSE
                  (CASE WHEN (ip.e_data::DATE IS NOT NULL)
                     THEN age.age_id::TEXT || '-' || (ip.e_data::DATE)::TEXT || '-' || loc.loc_id::TEXT
                  END)
      END AS qtd_entrada_dia

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN (TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE IS NOT NULL)
                         THEN age.age_id::TEXT || '-' || (TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE)::TEXT || '-' || loc.loc_id::TEXT
                  END)
              ELSE
                  (CASE WHEN (rp.e_data::DATE IS NOT NULL)
                         THEN age.age_id::TEXT || '-' || (rp.e_data::DATE)::TEXT || '-' || loc.loc_id::TEXT
                  END)
      END AS qtd_saida_dia

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN entrada.e_datacheckin::DATE IS NULL THEN 'NÃO OK'
                      ELSE 'OK'
                  END)
              ELSE
                  (CASE WHEN ip.e_data::DATE IS NULL THEN 'NÃO OK'
                      ELSE 'OK'
                  END)
      END AS status_entrada

      , CASE WHEN loc.loc_id != 79123492 THEN
                  (CASE WHEN TO_DATE(SPLIT_PART(saida.e_data_e_hora, ' ', 1), 'DD/MM/YYY')::DATE = entrada.e_datacheckin::DATE THEN 'OK'
                      ELSE 'NÃO OK'
                  END)
              ELSE
                  (CASE WHEN rp.e_data::DATE = ip.e_data::DATE THEN 'OK'
                      ELSE 'NÃO OK'
                  END)
      END AS status_saida

  --    , cd.calculo_checkout
  --    , CASE
  --        WHEN (COALESCE(cd.x_pdv, '') = '' OR COALESCE(cd.y_pdv, '') = '')
  --        THEN 'PDV SEM COORDENADA'
  --        WHEN (COALESCE(cd.x_checkout, '') = '' OR COALESCE(cd.y_checkout, '') = '')
  --        THEN 'CHECK-OUT SEM COORDENADA'
  --        ELSE (CASE WHEN cd.calculo_checkout <= 0.3 THEN 'DENTRO DA ÁREA' ELSE 'FORA DA ÁREA' END)
  --    END AS area_checkout

      , entrada.i_coordenadas AS geo_entrada
      , NULL::DOUBLE PRECISION AS calculo_checkin
      /*, CASE
          WHEN (COALESCE(SPLIT_PART(loc.loc_geoposition, ',', 1), '') = '' OR COALESCE(SPLIT_PART(loc.loc_geoposition, ',', 2), '') = '' OR COALESCE(SPLIT_PART(entrada.i_coordenadas, ',', 1), '') = '' OR COALESCE(SPLIT_PART(entrada.i_coordenadas, ',', 2), '') = '')
          THEN NULL
          ELSE (entrada.i_distancia_do_pdv::double precision *
                  acos(
                   cos(radians(SPLIT_PART(loc.loc_geoposition, ',', 1)::double precision)) *
                   cos(radians(SPLIT_PART(entrada.i_coordenadas, ',', 1)::double precision)) *
                   cos(radians(SPLIT_PART(loc.loc_geoposition, ',', 2)::double precision) - radians(SPLIT_PART(entrada.i_coordenadas, ',', 2)::double precision)) +
                   sin(radians(SPLIT_PART(loc.loc_geoposition, ',', 1)::double precision)) *
                   sin(radians(SPLIT_PART(entrada.i_coordenadas, ',', 1)::double precision))
                ))
      END AS calculo_checkin*/

--      , saida.i_coordenadas AS geo_saida

--    , CASE
--        WHEN (COALESCE(SPLIT_PART(loc.loc_geoposition, ',', 1), '') = '' OR COALESCE(SPLIT_PART(loc.loc_geoposition, ',', 2), '') = '' OR COALESCE(SPLIT_PART(saida.i_coordenadas, ',', 1), '') = '' OR COALESCE(SPLIT_PART(saida.i_coordenadas, ',', 2), '') = '')
--        THEN NULL
--        ELSE (saida.i_distancia_do_pdv::double precision *
--                 acos(
--                 cos(radians(SPLIT_PART(loc.loc_geoposition, ',', 1)::double precision)) *
--                 cos(radians(SPLIT_PART(saida.i_coordenadas, ',', 1)::double precision)) *
--                 cos(radians(SPLIT_PART(loc.loc_geoposition, ',', 2)::double precision) - radians(SPLIT_PART(saida.i_coordenadas, ',', 2)::double precision)) +
--                 sin(radians(SPLIT_PART(loc.loc_geoposition, ',', 1)::double precision)) *
--                 sin(radians(SPLIT_PART(saida.i_coordenadas, ',', 1)::double precision))
--              ))
--    END AS calculo_checkout

  FROM u28690.dbout_task                       t
  LEFT JOIN u28690.dbout_agent                 age       ON (t.age_id = age.age_id)
  LEFT JOIN u28690.dbout_local                 loc       ON (t.loc_id = loc.loc_id)
  LEFT JOIN u28690.dbout_history_checkin       entrada   ON (t.tsk_id = entrada.tsk_id)
  LEFT JOIN u28690.dbout_history_checkout      saida     ON (t.tsk_id = saida.tsk_id)
  INNER JOIN dbout_supervisores                ags       ON (UPPER(age.i_idsupervisor) = UPPER(ags.age_integrationid))

  LEFT JOIN u28690.dbout_history_ip            ip        ON (t.tsk_id = ip.tsk_id)
  LEFT JOIN u28690.dbout_history_rp            rp        ON (t.tsk_id = rp.tsk_id)

  LEFT JOIN u28690.teamagent				  age_tea    ON (age.age_id = age_tea.age_id)
  LEFT JOIN u28690.dbout_team                  tea       ON (age_tea.tea_id = tea.tea_id)

  WHERE age.age_active = '1'
  AND TRIM(upper(age.age_name)) not in ('MASTER','GERENTE', 'SUPORTEUMOV', 'SUPORTETECNICO', 'SOL7')
  --AND loc.loc_id != 79123492

  /* PARA FILTRAR TODAS AS ATIVIDADES EXCETO "Auditoria do Supervisor" */
  AND t.tsk_id NOT IN (SELECT DISTINCT i.tsk_id FROM u28690.taskactivity i WHERE i.act_id = '1104325')

  --AND TRIM(upper(age.age_name)) ILIKE '%michelle%'
  --AND t.tsk_scheduleinitialdatehour::date = '2021-02-15'
  --AND t.tsk_scheduleinitialdatehour::DATE = '2021-02-09'

--  AND age.age_name = 'AUREO PEREIRA DA COSTA'
--  AND t.tsk_scheduleinitialdatehour::DATE = '2020-11-03'

--  AND age.age_name = 'MAXUEL BORGES'

  ORDER BY 6, 16
) X
ORDER BY data_entrada_dia, "Promotor", "Hora Entrada Tarefa"
) Y


    , CASE WHEN "Qtd PDV" = 79123492 THEN NULL
        ELSE  
        (CASE WHEN LAG("Qtd PDV", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa") = 79123492
        AND LAG("Hora Entrada Tarefa", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa") < LAG("Hora Saida Tarefa", 2) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")
         THEN 
            ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 2) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
            ELSE ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
        END) 
    END AS tempo_deslocamento
    , CASE WHEN "Qtd PDV" = 79123492 THEN NULL
        ELSE  
        (CASE WHEN LAG("Qtd PDV", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa") = 79123492
        AND LAG("Hora Entrada Tarefa", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa") < LAG("Hora Saida Tarefa", 2) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")
         THEN 
            ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 2) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
            ELSE ("Hora Entrada Tarefa" - LAG("Hora Saida Tarefa", 1) OVER (PARTITION BY data_entrada::DATE, "Promotor" ORDER BY "Promotor", "Hora Entrada Tarefa")) 
        END) 
    END AS tempo_deslocamento_media