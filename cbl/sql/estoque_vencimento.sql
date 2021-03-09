SELECT
/* PROMOTOR*/
     "Promotor"  
    -- , "Promotor Ultima Geo"  
    -- , "Promotor Ultima Sincronização" 
    -- , "Promotor Grupo" 
     , "Gerente" 
    -- , "Promotor Mix" 
     /*, "Promotor Regional" 
     , "Promotor Hora Inicio" 
     , "Promotor Hora Fim" 
     , "Promotor Salário" */
     , "Supervisor" 
    
     /* LOCAL */
     , "PDV"
     , "PDV Estado" 
     --, "PDV Cidade" 
     --, "PDV Bairro" 
     --, "PDV Geo" 
     , "PDV Código"
     --, "PDV Ativo" 
     , "PDV Canal" 
     --, "PDV Ciclo Atendimento" 
     , "PDV Rede" 
     , "PDV Regional" 
     --, "PDV Atacado" 
     --, "PDV Volume Qtd Caixa" 
     --, "PDV Grupo" 
     --, "Qtd PDV Rota" 
    
    /*ROTA*/
     , "Promotor Rota" 
     , "Rota" 
    
    /* ITENS */
     , "ite_id"
     , "ite_integrationid"
     , "Item Codigo"
     , "Item"
     --, "Item Subgrupo"
     , "Item Categoria CBL"
     --, "Item Dias Vencimento 1"
     --, "Item Dias Vencimento 2"
     --, "Item Dias Vencimento 3"
     , "Item Marcas CBL"
     --, "Item Qtd Embalagem"
     , "Item Seções"
     --, "Código Item"
    
     /* TAREFAS */
     , "tsk_id" 
     , "age_id" 
     , "loc_id" 
     --, "Situação Tarefa" 
     , "Data Inicio Previsto" 
     --, "Data Inicio Previsto Filtro" 
     , "Data Fim Previsto" 
     --, "Data Fim Previsto Filtro" 
     , "Data Inicio" 
     --, "Data Inicio Filtro" 
     , "Data Fim" 
     --, "Data Fim Filtro" 

     , "Data Validade" as "Data Validade"
     --, "Data Validade" as "Data Validade Filtro"
     , to_char("Data Validade"::DATE, 'dd/mm/yyyy') as "Data Validade Dia"
     , "Motivo" as "Motivo"
     , "Quantidade Estoque" as "Qtd Estoque"
     , CASE
        WHEN ("Data Validade"::DATE - NOW()::DATE) >= 0 AND ("Data Validade"::DATE - NOW()::DATE) <= "Item Dias Vencimento 3"::INTEGER THEN lpad("Item Dias Vencimento 3",2,'0') || ' Dias'
        WHEN ("Data Validade"::DATE - NOW()::DATE) >= 0 AND ("Data Validade"::DATE - NOW()::DATE) <= "Item Dias Vencimento 2"::INTEGER THEN lpad("Item Dias Vencimento 2",2,'0') || ' Dias'
        WHEN ("Data Validade"::DATE - NOW()::DATE) >= 0 AND ("Data Validade"::DATE - NOW()::DATE) <= "Item Dias Vencimento 1"::INTEGER THEN lpad("Item Dias Vencimento 1",2,'0') || ' Dias'
        WHEN ("Data Validade"::DATE - NOW()::DATE) < 0 THEN 'Vencido'
        ELSE 'A Vencer'
      END as "Faixas Vencimento"

FROM public.crosstab( 
'SELECT DISTINCT
    
    htv.hty_id::TEXT || ite.ite_id::TEXT as "Identifier"

    /* PROMOTOR*/
    , age.age_name as "Promotor"
    /*, age.age_lastgeoposition as "Promotor Ultima Geo"
    , to_char(age.age_datehourlastsync, ''dd/mm/yyyy hh:mi:ss'') AS "Promotor Ultima Sincronização"
    , agg.agg_description as "Promotor Grupo"*/
    , age.e_auditor as "Gerente"
    /*, age.e_agent_mix as "Promotor Mix"
    , age.e_regional as "Promotor Regional"
    , age.e_hora_inicio as "Promotor Hora Inicio"
    , age.e_hora_fim as "Promotor Hora Fim"
    , age.e_salario as "Promotor Salário"*/
    , age.e_supervisor as "Supervisor"
    
    /* LOCAL */
    , loc.loc_description as "PDV"
    , loc.loc_state as "PDV Estado"
    /*, loc.loc_city as "PDV Cidade"
    , loc.loc_neighborhood as "PDV Bairro"
    , loc.loc_geoposition as "PDV Geo"*/
    , loc.loc_integrationid as "PDV Código"
    --, loc.loc_active as "PDV Ativo"
    , loc.e_canal as "PDV Canal"
    --, loc.e_ciclo_atendimento as "PDV Ciclo Atendimento"
    , loc.e_rede as "PDV Rede"
    , loc.e_regional as "PDV Regional"
    /*, loc.e_trabalha_atacado as "PDV Atacado"
    , loc.e_volumeqtd_caixah as "PDV Volume Qtd Caixa"
    , loc.e_grupo_de_lojas as "PDV Grupo"
    , loc.loc_integrationid as "Qtd PDV Rota"*/
    
    , art.age_name as "Promotor Rota"
    , rota.e_rota_nome as "Rota"
    
    /* ITENS */
    , ite.ite_id
    , ite.ite_integrationid
    , ite.ite_integrationid as "Item Codigo"
    , ite.ite_description as "Item"
    --, isg.isg_description as "Item Subgrupo"
    , ite.e_categoria_cbl as "Item Categoria CBL"
    , ite.e_dias_vencimento_1 as "Item Dias Vencimento 1"
    , ite.e_dias_vencimento_2  as "Item Dias Vencimento 2"
    , ite.e_dias_vencimento_3 as "Item Dias Vencimento 3"
    , ite.e_marcas_cbl as "Item Marcas CBL"
    --, ite.e_quantidade_embalagem as "Item Qtd Embalagem"
    , ite.e_secoes as "Item Seções"
    
    /* TAREFAS */
    , tsk.tsk_id
    , tsk.age_id 
    , tsk.loc_id 
    , tsk.tsk_situation as "Situação Tarefa"
    , tsk.tsk_scheduleinitialdatehour as "Data Inicio Previsto"
    , tsk.tsk_schedulefinaldatehour as "Data Fim Previsto"
    , tsk.tsk_realinitialdatehour as "Data Inicio"
    , tsk.tsk_realfinaldatehour as "Data Fim"
    
    /* HISTORICO */
    , acf.acf_description as campo
    , htv.htv_internalvalue as valor

FROM u19947.task tsk
INNER JOIN u19947.history           hty ON (hty.tsk_id = tsk.tsk_id)
INNER JOIN u19947.historyvalue      htv ON (htv.hty_id = hty.hty_id)
INNER JOIN u19947.activityfield     acf ON (acf.acf_id = htv.acf_id)
INNER JOIN u19947.activitysection   acs ON (acs.acs_id = htv.acs_id AND acs.acs_id = htv.acs_id)
INNER JOIN u19947.activity          act ON (act.act_id = acs.act_id)
INNER JOIN u19947.activitytype      aty ON (aty.aty_id = act.aty_id)
INNER JOIN u19947.dbout_agent       age ON (age.age_id = tsk.age_id)
LEFT JOIN u19947.agentgroup         agg ON (agg.agg_id = age.agg_id)
LEFT JOIN u19947.dbout_item         ite ON (ite.ite_id = htv.ite_id)
LEFT JOIN u19947.itemsubgroup       isg ON (isg.isg_id = ite.isg_id)
LEFT JOIN u19947.dbout_local        loc ON (loc.loc_id = tsk.loc_id)
LEFT JOIN u19947.dbout_customentity_brb rota ON (loc.loc_integrationid = rota.i_rota_pdv_codigo AND to_date(rota.i_rota_periodo, ''DD/MM/YYYY'')::DATE = DATE_TRUNC(''MONTH'', tsk.tsk_realinitialdatehour)::DATE)
LEFT JOIN u19947.dbout_agent        art ON (rota.i_rota_promotor_codigo = art.age_integrationid)
WHERE tsk.tsk_situation <> ''Cancelada''
AND tsk.tsk_scheduleinitialdatehour::DATE  >= (NOW()::DATE - ''7 DAY''::INTERVAL)
AND act.act_id in (536391)
ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32--,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55',
'SELECT DISTINCT acf.acf_description as campo FROM u19947.activityfield acf INNER JOIN u19947.activitysection acs ON (acs.acs_id = acf.acs_id) INNER JOIN u19947.activity act ON (act.act_id = acs.act_id)
WHERE act.act_id in (536391)
/*AND acf.acf_active = ''1''*/ order by 1'
)
AS
(
    "Identifier" VARCHAR(255)
    /* PROMOTOR*/
     , "Promotor"  VARCHAR(255)
     /*, "Promotor Ultima Geo"  VARCHAR(255)
     , "Promotor Ultima Sincronização" VARCHAR(255)
     , "Promotor Grupo" VARCHAR(255)*/
     , "Gerente" VARCHAR(255)
     /*, "Promotor Mix" VARCHAR(255)
     , "Promotor Regional" VARCHAR(255)
     , "Promotor Hora Inicio" VARCHAR(255)
     , "Promotor Hora Fim" VARCHAR(255)
     , "Promotor Salário" VARCHAR(255)*/
     , "Supervisor" VARCHAR(255)
    
     /* LOCAL */
     , "PDV" VARCHAR(255)
     , "PDV Estado" VARCHAR(255)
     /*, "PDV Cidade" VARCHAR(255)
     , "PDV Bairro" VARCHAR(255)
     , "PDV Geo" VARCHAR(255)*/
     , "PDV Código" VARCHAR(255)
     --, "PDV Ativo" VARCHAR(255)
     , "PDV Canal" VARCHAR(255)
     --, "PDV Ciclo Atendimento" VARCHAR(255)
     , "PDV Rede" VARCHAR(255)
     , "PDV Regional" VARCHAR(255)
     /*, "PDV Atacado" VARCHAR(255)
     , "PDV Volume Qtd Caixa" VARCHAR(255)
     , "PDV Grupo" VARCHAR(255) 
     , "Qtd PDV Rota" VARCHAR(255)*/
    
     , "Promotor Rota" VARCHAR(255)
     , "Rota" VARCHAR(255)
    
    /* ITENS */
     , "ite_id" VARCHAR(255)
     , "ite_integrationid" VARCHAR(255)
     , "Item Codigo" VARCHAR(255)
     , "Item" VARCHAR(255)
     --, "Item Subgrupo" VARCHAR(255)
     , "Item Categoria CBL" VARCHAR(255)
     , "Item Dias Vencimento 1" VARCHAR(255)
     , "Item Dias Vencimento 2" VARCHAR(255)
     , "Item Dias Vencimento 3" VARCHAR(255)
     , "Item Marcas CBL" VARCHAR(255)
     --, "Item Qtd Embalagem" VARCHAR(255)
     , "Item Seções" VARCHAR(255)
     --, "Código Item" VARCHAR(255)
    
     /* TAREFAS */
     , "tsk_id" VARCHAR(255)
     , "age_id" VARCHAR(255)
     , "loc_id" VARCHAR(255)
     , "Situação Tarefa" VARCHAR(255)
     , "Data Inicio Previsto" TIMESTAMP
     --, "Data Inicio Previsto Filtro" TIMESTAMP
     , "Data Fim Previsto" TIMESTAMP
     --, "Data Fim Previsto Filtro" TIMESTAMP
     , "Data Inicio" TIMESTAMP
     --, "Data Inicio Filtro" TIMESTAMP
     , "Data Fim" TIMESTAMP
     --, "Data Fim Filtro" TIMESTAMP

     , "Data Atual" TIMESTAMP
     , "Data Validade" TIMESTAMP
     , "Horário de Trabalho" VARCHAR(255)
     , "Informe o preço da Bandeja" VARCHAR(255)
     , "Informe o preço do leite em pó" VARCHAR(255)
     , "Motivo" VARCHAR(255)
     , "Nº Pedido" VARCHAR(255)
     , "Quantidade Estoque" DOUBLE PRECISION
)