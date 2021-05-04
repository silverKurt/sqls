-- FECHADAS, ENCERRADAS, FATURADAS, INTERNAS
SELECT 
 LPAD(cscapas.filial, 2, '0')||' - '||fil.apelido as Filial,
 cscapas.ordemserv as OrdemServico,
 cscapas.ordemserv||cscapas.filial as Qtd_OS, 
 cscapas.dtabertura as Dt_Inicio, 
 cscapas.dtfechament as Dt_Fim,
 cscapas.dtfechament as Periodo, 
 cscapas.id_agente||' - '||pes.nomeguerra as Agente,
 cscapas.chassis as Chassis, 
 cscapas.quilometr as KmRodado, 
 csserexe.id_servico as IdServico,
 tpi.tpitem as Cod_TipoItem, 
 tpi.descrtipoitem as TipoItem,
 cipessoa.nomepessoa as Cliente, 
 csitens.tpordem as TipoOS, 
 csitens.descritem as DescricaoTipoOS,
 
 CASE WHEN csitens.tpordem IN ('ATI','CAA','CAB','CBA','CBB','CCA','CHE','CMA','CMB','CSE','COF','POC','POM','POP','POS','POT','PSE','PSH','PSP','REV','RPC','SPO','SPT','SRC')
 	  THEN 'Clientes Externos' 
 	  WHEN csitens.tpordem IN ('HVG','KLM')
 	  THEN 'Deslocamentos' 
 	  WHEN csitens.tpordem IN ('MOF','TRE','CPM','CST','GEC','GST','IST','PLC')
 	  THEN 'Outros (com receita)' 
 	  WHEN csitens.tpordem IN ('AGD','ASI','ASR','CCM','IAC','IAD','IMN','IMU','IOF','IPC','RET')
 	  THEN 'Internas' 
 	  WHEN csitens.tpordem IN ('GAU','GBA','GES','GNO','GPC','KMG','PMP','RGA','RVF')
 	  THEN 'John Deere'ELSE csitens.tpordem END as GrupoOS,
 
 CASE WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 10 THEN '03'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 59 THEN '02'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) >= 60 THEN '01' END AS FaixaDiasOSOrdem,
 
 CASE WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 10 THEN 'Até 10 Dias'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 59 THEN 'De 11 até 59 Dias'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) >= 60 THEN 'Mais de 60 Dias' END AS FaixaDiasOS,

 cnnfcapa.nronota as NrNota, 
 cnnfcapa.serienf as SerieNota,
 cnnfcapa.transacao as Transacao,
 CAST(cscapas.dtfechament - cscapas.dtabertura AS INTEGER) as DiasOS,
 csserexe.quantidade as Qtd, 
 csserexe.unitario as VlrUnit, 
 csserexe.descunit as VlrDescUnit, 
 csserexe.tempopadrao as TempoPadrao, 
 csserexe.temporeal as TempoRealizado, 
 csserexe.tempovendido as TempoVendido, 
 serv.valordesc as VlrDesconto, 
 serv.valoracresc as VlrAcrescimo,
 serv.valoriss as VlrIss,
 (csserexe.unitario*csserexe.tempovendido-csserexe.descunit) as VlrTotalOS,
 CASE WHEN csitens.tpordem IN ('AGD','ASI','ASR','CCM','IAC','IAD','IMN','IMU','IOF','IPC','RET')
 	  THEN 'ENCERRADA' ELSE 'FATURADA' END AS Status

FROM cscapas
 LEFT JOIN csserexe ON (csserexe.id_oscapa = cscapas.id_oscapa)
 LEFT JOIN csitens ON (csitens.id_oscapa = csserexe.id_oscapa AND csitens.nroitem = csserexe.nroitem)
 LEFT JOIN ciendere ON (ciendere.nro_endere = csitens.nro_endere)
 LEFT JOIN cipessoa ON (cipessoa.cgccpf = ciendere.cgccpf)
 LEFT JOIN cnnfcapa ON (cscapas.ordemserv = cnnfcapa.ordemserv AND (cnnfcapa.serienf <> '1' OR cnnfcapa.serienf IS NULL) AND csitens.tpordem = cnnfcapa.tpordem AND cnnfcapa.filial = cscapas.filial AND cnnfcapa.cancelada="N")
 LEFT JOIN cofilial fil ON (cscapas.filial = fil.filial)
 LEFT JOIN coagente age ON (age.id_agente = cscapas.id_agente)
 LEFT JOIN cipessoa pes ON (pes.cgccpf = age.cgccpf)
 LEFT JOIN cnnfserv serv ON (serv.id_nfcapa = cnnfcapa.id_nfcapa AND serv.id_servico = csserexe.id_servico AND serv.tpordem = csitens.tpordem)
 LEFT JOIN cntpitem tpi ON (csserexe.tpitem = tpi.tpitem)

WHERE cscapas.dtabertura >= "2019-01-01"
  AND cscapas.id_oscapa NOT IN (SELECT csmotca.id_oscapa FROM csmotca)
  AND cscapas.dtfechament IS NOT NULL
  AND csserexe.tpitem IN (2, 3, 4, 7)

UNION ALL

-- ABERTAS SEM FINALIZAR
SELECT 
 LPAD(cscapas.filial, 2, '0')||' - '||fil.apelido as Filial,
 cscapas.ordemserv as OrdemServico,
 cscapas.ordemserv||cscapas.filial as Qtd_OS,
 cscapas.dtabertura as Dt_Inicio, 
 cscapas.dtfechament as Dt_Fim,
 cscapas.dtabertura as Periodo, 
 cscapas.id_agente||' - '||pes.nomeguerra as Agente,
 cscapas.chassis as Chassis, 
 cscapas.quilometr as KmRodado, 
 csserexe.id_servico as IdServico,
 tpi.tpitem as Cod_TipoItem, 
 tpi.descrtipoitem as TipoItem,
 cipessoa.nomepessoa as Cliente, 
 csitens.tpordem as TipoOS, 
 csitens.descritem as DescricaoTipoOS,
 CASE WHEN csitens.tpordem IN ('ATI','CAA','CAB','CBA','CBB','CCA','CHE','CMA','CMB','CSE','COF','POC','POM','POP','POS','POT','PSE','PSH','PSP','REV','RPC','SPO','SPT','SRC')
 	  THEN 'Clientes Externos' 
 	  WHEN csitens.tpordem IN ('HVG','KLM')
 	  THEN 'Deslocamentos' 
 	  WHEN csitens.tpordem IN ('MOF','TRE','CPM','CST','GEC','GST','IST','PLC')
 	  THEN 'Outros (com receita)' 
 	  WHEN csitens.tpordem IN ('AGD','ASI','ASR','CCM','IAC','IAD','IMN','IMU','IOF','IPC','RET')
 	  THEN 'Internas' 
 	  WHEN csitens.tpordem IN ('GAU','GBA','GES','GNO','GPC','KMG','PMP','RGA','RVF')
 	  THEN 'John Deere'ELSE csitens.tpordem END as GrupoOS,

 CASE WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 10 THEN '03'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 59 THEN '02'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) >= 60 THEN '01' END AS FaixaDiasOSOrdem,
 
 CASE WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 10 THEN 'Até 10 Dias'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 59 THEN 'De 11 até 59 Dias'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) >= 60 THEN 'Mais de 60 Dias' END AS FaixaDiasOS,

 cnnfcapa.nronota as NrNota, 
 cnnfcapa.serienf as SerieNota,
 cnnfcapa.transacao as Transacao,
 CAST((TODAY) - cscapas.dtabertura AS INTEGER) as DiasOS,
 csserexe.quantidade as Qtd, 
 csserexe.unitario as VlrUnit, 
 csserexe.descunit as VlrDescUnit, 
 csserexe.tempopadrao as TempoPadrao, 
 csserexe.temporeal as TempoRealizado, 
 csserexe.tempovendido as TempoVendido, 
 serv.valordesc as VlrDesconto, 
 serv.valoracresc as VlrAcrescimo,
 serv.valoriss as VlrIss,
 (csserexe.unitario*csserexe.tempovendido-csserexe.descunit) as VlrTotalOS,
 'ABERTAS' AS Status

FROM cscapas
 LEFT JOIN csserexe ON (csserexe.id_oscapa = cscapas.id_oscapa)
 LEFT JOIN csitens ON (csitens.id_oscapa = csserexe.id_oscapa AND csitens.nroitem = csserexe.nroitem)
 LEFT JOIN ciendere ON (ciendere.nro_endere = csitens.nro_endere)
 LEFT JOIN cipessoa ON (cipessoa.cgccpf = ciendere.cgccpf)
 LEFT JOIN cnnfcapa ON (cscapas.ordemserv = cnnfcapa.ordemserv AND (cnnfcapa.serienf <> '1' OR cnnfcapa.serienf IS NULL) AND csitens.tpordem = cnnfcapa.tpordem AND cnnfcapa.filial = cscapas.filial AND cnnfcapa.cancelada="N")
 LEFT JOIN cofilial fil ON (cscapas.filial = fil.filial)
 LEFT JOIN coagente age ON (age.id_agente = cscapas.id_agente)
 LEFT JOIN cipessoa pes ON (pes.cgccpf = age.cgccpf)
 LEFT JOIN cnnfserv serv ON (serv.id_nfcapa = cnnfcapa.id_nfcapa AND serv.id_servico = csserexe.id_servico AND serv.tpordem = csitens.tpordem)
 LEFT JOIN cntpitem tpi ON (csserexe.tpitem = tpi.tpitem)

WHERE cscapas.dtabertura >= "2019-01-01"
  AND cscapas.id_oscapa NOT IN (SELECT csmotca.id_oscapa FROM csmotca)
  AND cscapas.dtfechament IS NULL
  AND csserexe.tpitem IN (2, 3, 4, 7)

UNION ALL

-- CANCELADAS
SELECT 
 LPAD(cscapas.filial, 2, '0')||' - '||fil.apelido as Filial,
 cscapas.ordemserv as OrdemServico,
 cscapas.ordemserv||cscapas.filial as Qtd_OS,
 cscapas.dtabertura as Dt_Inicio, 
 cscapas.dtfechament as Dt_Fim, 
 cscapas.dtfechament as Periodo,
 cscapas.id_agente||' - '||pes.nomeguerra as Agente,
 cscapas.chassis as Chassis, 
 cscapas.quilometr as KmRodado, 
 NULL::INTEGER as IdServico,
 NULL::INTEGER as Cod_TipoItem, 
 NULL::VARCHAR as TipoItem,
 cipessoa.nomepessoa as Cliente, 
 csitens.tpordem as TipoOS, 
 csitens.descritem as DescricaoTipoOS,
 CASE WHEN csitens.tpordem IN ('ATI','CAA','CAB','CBA','CBB','CCA','CHE','CMA','CMB','CSE','COF','POC','POM','POP','POS','POT','PSE','PSH','PSP','REV','RPC','SPO','SPT','SRC')
 	  THEN 'Clientes Externos' 
 	  WHEN csitens.tpordem IN ('HVG','KLM')
 	  THEN 'Deslocamentos' 
 	  WHEN csitens.tpordem IN ('MOF','TRE', 'CPM', 'CST', 'GEC', 'GST', 'IST', 'PLC')
 	  THEN 'Outros (com receita)' 
 	  WHEN csitens.tpordem IN ('AGD','ASI','ASR','CCM','IAC','IAD','IMN','IMU','IOF','IPC','RET')
 	  THEN 'Internas' 
 	  WHEN csitens.tpordem IN ('GAU','GBA','GES','GNO','GPC','KMG','PMP','RGA','RVF')
 	  THEN 'John Deere'ELSE csitens.tpordem END as GrupoOS,

 CASE WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 10 THEN '03'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 59 THEN '02'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) >= 60 THEN '01' END AS FaixaDiasOSOrdem,
 
 CASE WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 10 THEN 'Até 10 Dias'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) <= 59 THEN 'De 11 até 59 Dias'
 	  WHEN CAST(COALESCE(cscapas.dtfechament, TODAY) - cscapas.dtabertura AS INTEGER) >= 60 THEN 'Mais de 60 Dias' END AS FaixaDiasOS,

 NULL::INTEGER as NrNota, 
 NULL::VARCHAR as SerieNota,
 NULL::VARCHAR as Transacao,
 CAST(cscapas.dtfechament - cscapas.dtabertura AS INTEGER) as DiasOS,
 NULL::DOUBLE PRECISION as Qtd, 
 NULL::DOUBLE PRECISION as VlrUnit, 
 NULL::DOUBLE PRECISION as VlrDescUnit, 
 NULL::DOUBLE PRECISION as TempoPadrao, 
 NULL::DOUBLE PRECISION as TempoRealizado, 
 NULL::DOUBLE PRECISION as TempoVendido, 
 NULL::DOUBLE PRECISION as VlrDesconto, 
 NULL::DOUBLE PRECISION as VlrAcrescimo,
 NULL::DOUBLE PRECISION as VlrIss,
 NULL::DOUBLE PRECISION as VlrTotalOS,
 'CANCELADAS' AS Status

FROM cscapas
 LEFT JOIN csitens ON (csitens.id_oscapa = cscapas.id_oscapa)
 LEFT JOIN ciendere ON (ciendere.nro_endere = csitens.nro_endere)
 LEFT JOIN cipessoa ON (cipessoa.cgccpf = ciendere.cgccpf)
 LEFT JOIN cofilial fil ON (cscapas.filial = fil.filial)
 LEFT JOIN coagente age ON (age.id_agente = cscapas.id_agente)
 LEFT JOIN cipessoa pes ON (pes.cgccpf = age.cgccpf)

WHERE cscapas.dtabertura >= "2019-01-01"
  AND cscapas.id_oscapa IN (SELECT csmotca.id_oscapa FROM csmotca)