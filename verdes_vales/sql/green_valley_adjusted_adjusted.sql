SELECT
    TRUNC(cscapas.dtfechament,'MONTH') as periodo,
    LPAD(cscapas.filial, 2, '0')||' - '||fil.apelido as filial,
    cscapas.ordemserv, --numero da ordem de serviço
    cscapas.dtfechament as dt_Fim,
    csitens.nroitem AS cs_item, --numero do item da ordem
    csitens.tpordem, --tipo da ordem de serviço
    csserexe.id_servico, --id do serviço executado
    csserexe.nroitem AS serexe_item, --numero do item dentro do serviço executado. Vinculado com a tabela csitens. Indica em qual tipo de OS está o serviço
    csserexe.unitario AS serexe_unitario, --valor unitario do serviço executado
    cntpitem.controlatempo, --se o serviço possui tempo controlado
    CASE WHEN cttptran.consumo IN ('S') THEN 'INTERNO' ELSE 'EXTERNO' END AS tipo_faturamento, --tipo do faturamento (interno/externo)
    coagente.cargo, --codigo do cargo do agente
    cocargos.descrcargo, --descricao do cargo do agente
    pes.nomeguerra as agente, --nome do agente

    SUM(cspontop.tempopadrao) as padrao, --Tempo Padrão
    SUM(cspontop.temporeal) as tempo_real, --Tempo Real
    SUM(cspontop.tempovendido) as vendido, --Tempo Vendido
    SUM((cspontop.tempovendido) * csserexe.unitario) AS total --Valor final do serviço
    
FROM cscapas
INNER JOIN csserexe ON (cscapas.id_oscapa = csserexe.id_oscapa)
LEFT JOIN csitens ON (csitens.id_oscapa=csserexe.id_oscapa AND csitens.nroitem=csserexe.nroitem)
LEFT JOIN cntpitem ON (cntpitem.tpitem=csserexe.tpitem)
LEFT JOIN cstempos ON (cstempos.id_oscapa=csserexe.id_oscapa AND cstempos.id_servico=csserexe.id_servico AND cstempos.nroitem=csitens.nroitem)
LEFT JOIN cspontop ON (cspontop.id_agente=cstempos.id_agente AND cspontop.dtinicio=cstempos.dtinicio AND cspontop.hrinicio=cstempos.hrinicio)
LEFT JOIN coagente ON (coagente.id_agente=cstempos.id_agente)
LEFT JOIN cocargos ON (cocargos.cargo=coagente.cargo)
LEFT JOIN csservic ON (csservic.id_servico=csserexe.id_servico)
LEFT JOIN cipessoa pes ON (pes.cgccpf = coagente.cgccpf)
LEFT JOIN cstipoos ON (cstipoos.tpordem = csitens.tpordem)
LEFT JOIN cttransa ON (cttransa.transacao=cstipoos.transacao)
LEFT JOIN cttptran ON (cttptran.tipotransacao=cttransa.tipotransacao)
LEFT JOIN cofilial fil ON (cscapas.filial = fil.filial)

WHERE cscapas.dtfechament>="2020-11-01"
AND cscapas.ordemserv = '39545'
AND cspontop.id_agente = '21'

GROUP BY 
    periodo,
    filial,
    cscapas.ordemserv,
    cscapas.dtfechament,
    csitens.nroitem,
    csitens.tpordem,
    csserexe.id_servico,
    csserexe.nroitem,
    csserexe.tempovendido,
    csserexe.unitario,
    cntpitem.controlatempo,
    tipo_faturamento, 
    coagente.cargo,
    cocargos.descrcargo, 
    pes.nomeguerra