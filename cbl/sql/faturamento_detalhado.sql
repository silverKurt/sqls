-- Source: Faturamento sem os CDs e Redes
SELECT 
      age.age_name as "Promotor"
    , age.age_name as "Promotor Rota"
    , age.e_auditor as "Auditor"
    , age.e_agent_mix as "Promotor Mix"
    , age.e_regional as "Promotor Regional"
    , age.e_hora_inicio as "Promotor Hora Inicio"
    , age.e_hora_fim as "Promotor Hora Fim"
    , age.e_salario as "Promotor Salário"
    , age.e_supervisor as "Supervisor"
    , COALESCE(loc.loc_description, fat."Cliente")::TEXT as "PDV"
    , loc.loc_state::TEXT as "PDV Estado"
    , loc.loc_city::TEXT as "PDV Cidade"
    , loc.loc_neighborhood::TEXT as "PDV Bairro"
    , loc.loc_geoposition::TEXT as "PDV Geo"
    , COALESCE(loc.loc_integrationid, fat."Codigo_Cliente")::TEXT as "PDV Código"
    , COALESCE(loc.loc_integrationid, fat."Codigo_Cliente")::TEXT as "Qtd PDVs Faturados"
    , loc.loc_active::TEXT as "PDV Ativo"
    , loc.e_canal::TEXT as "PDV Canal"
    , loc.e_ciclo_atendimento::TEXT as "PDV Ciclo Atendimento"
    , loc.e_rede::TEXT as "PDV Rede"
    , loc.e_regional::TEXT as "PDV Regional"
    , loc.e_trabalha_atacado::TEXT as "PDV Atacado"
    , loc.e_volumeqtd_caixah::TEXT as "PDV Volume Qtd Caixa" 
    , loc.e_grupo_de_lojas::TEXT as "PDV Grupo"
    , rot.e_rota_nome::TEXT as "Rota"
    , rot.e_rota_nome::TEXT AS "Qtd Rotas"
    , ite.ite_id::TEXT
    , COALESCE(ite.ite_integrationid::TEXT, fat."Codigo_Produto"::INTEGER::TEXT) AS "Qtd Itens Faturados"
    , COALESCE(ite.ite_description, (fat."Produto"||' (Cód '||fat."Codigo_Produto"::INTEGER::TEXT||')'))::TEXT as "Item"
    , ite.e_categoria_cbl::TEXT as "Item Categoria CBL"
    , ite.e_dias_vencimento_1::TEXT as "Item Dias Vencimento 1"
    , ite.e_dias_vencimento_2::TEXT as "Item Dias Vencimento 2"
    , ite.e_dias_vencimento_3::TEXT as "Item Dias Vencimento 3"
    , ite.e_marcas_cbl::TEXT as "Item Marcas CBL"
    , ite.e_quantidade_embalagem::TEXT as "Item Qtd Embalagem"
    , ite.e_secoes::TEXT as "Item Seções"
    , loc.loc_id::TEXT as "Qtd PDVs"
    , fat."Data_da_Fatura"::DATE AS "Periodo"
    , fat."Data_da_Fatura"::DATE AS "Periodo Filtro"
    , fat."VL_FAT"::DOUBLE PRECISION AS "Valor Faturado"
    , fat."VL_DEV"::DOUBLE PRECISION AS "Valor Devolvido"
    , fat."VL_DEV_ACORDO"::DOUBLE PRECISION AS "Valor Devolvido Acordo"
    , fat."QT_FAT"::DOUBLE PRECISION AS "Qtd Faturada"
    , fat."QT_DEV"::DOUBLE PRECISION AS "Qtd Devolvida"
    , fat."QT_DEV_ACORDO"::DOUBLE PRECISION AS "Qtd Devolvida Acordo"
FROM bicbl."fat_bicbl_Faturamento" fat
LEFT JOIN bicbl."fat_bicbl_CadastrodeLocais" loc ON (loc.loc_integrationid = fat."Codigo_Cliente"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_CadastrodeItens" ite ON (ite.ite_integrationid = fat."Codigo_Produto"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_BasedeRotas" rot ON (loc.loc_integrationid = rot.i_rota_pdv_codigo  AND to_date(rot.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', fat."Data_da_Fatura")::DATE)
LEFT JOIN bicbl."fat_bicbl_CadastrodePromotores" age ON (age.age_integrationid = rot.i_rota_promotor_codigo)
WHERE fat."Codigo_Cliente"::INTEGER::TEXT NOT IN (SELECT DISTINCT trim(cad.i_codigo_cd) FROM bicbl."fat_bicbl_CadastrodeLocais" cad WHERE cad.i_codigo_cd is not null)
AND fat."Codigo_Cliente"::INTEGER::TEXT NOT IN (SELECT DISTINCT trim(cad.i_codigo_rede) FROM bicbl."fat_bicbl_CadastrodeLocais" cad WHERE cad.i_codigo_rede is not null)
AND fat."Data_da_Fatura"::DATE >= DATE_TRUNC('MONTH', NOW()::DATE) - '8 MONTHS'::INTERVAL

UNION ALL

-- Source: Faturamento CDs
SELECT 
      age.age_name as "Promotor"
    , age.age_name as "Promotor Rota"
    , age.e_auditor as "Gerente"
    , age.e_agent_mix as "Promotor Mix"
    , age.e_regional as "Promotor Regional"
    , age.e_hora_inicio as "Promotor Hora Inicio"
    , age.e_hora_fim as "Promotor Hora Fim"
    , age.e_salario as "Promotor Salário"
    , age.e_supervisor as "Supervisor"
    , COALESCE(loc.loc_description, fat."Cliente")::TEXT as "PDV"
    , loc.loc_state::TEXT as "PDV Estado"
    , loc.loc_city::TEXT as "PDV Cidade"
    , loc.loc_neighborhood::TEXT as "PDV Bairro"
    , loc.loc_geoposition::TEXT as "PDV Geo"
    , COALESCE(loc.loc_integrationid, fat."Codigo_Cliente")::TEXT as "PDV Código"
    , COALESCE(loc.loc_integrationid, fat."Codigo_Cliente")::TEXT as "Qtd PDVs Faturados"
    , loc.loc_active::TEXT as "PDV Ativo"
    , loc.e_canal::TEXT as "PDV Canal"
    , loc.e_ciclo_atendimento::TEXT as "PDV Ciclo Atendimento"
    , loc.e_rede::TEXT as "PDV Rede"
    , loc.e_regional::TEXT as "PDV Regional"
    , loc.e_trabalha_atacado::TEXT as "PDV Atacado"
    , loc.e_volumeqtd_caixah::TEXT as "PDV Volume Qtd Caixa"
    , loc.e_grupo_de_lojas::TEXT as "PDV Grupo"
    , rot.e_rota_nome::TEXT as "Rota"
    , rot.e_rota_nome::TEXT AS "Qtd Rotas"
    , ite.ite_id::TEXT
    , COALESCE(ite.ite_integrationid::TEXT, fat."Codigo_Produto"::INTEGER::TEXT) AS "Qtd Itens Faturados"
    , COALESCE(ite.ite_description, (fat."Produto"||' (Cód '||fat."Codigo_Produto"::INTEGER::TEXT||')'))::TEXT as "Item"
    , ite.e_categoria_cbl::TEXT as "Item Categoria CBL"
    , ite.e_dias_vencimento_1::TEXT as "Item Dias Vencimento 1"
    , ite.e_dias_vencimento_2::TEXT as "Item Dias Vencimento 2"
    , ite.e_dias_vencimento_3::TEXT as "Item Dias Vencimento 3"
    , ite.e_marcas_cbl::TEXT as "Item Marcas CBL"
    , ite.e_quantidade_embalagem::TEXT as "Item Qtd Embalagem"
    , ite.e_secoes::TEXT as "Item Seções"
    , loc.loc_id::TEXT 
    , fat."Data_da_Fatura"::DATE AS "Periodo"
    , fat."Data_da_Fatura"::DATE AS "Periodo Filtro"
    , (fat."VL_FAT"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv_cd,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Valor Faturado"
    , (fat."VL_DEV"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv_cd,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Valor Devolvido"
    , (fat."VL_DEV_ACORDO"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv_cd,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Valor Devolvido Acordo"
    , (fat."QT_FAT"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv_cd,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Qtd Faturada"
    , (fat."QT_DEV"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv_cd,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Qtd Devolvida"
    , (fat."QT_DEV_ACORDO"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv_cd,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Qtd Devolvida Acordo"
FROM bicbl."fat_bicbl_Faturamento" fat
LEFT JOIN bicbl."fat_bicbl_CadastrodeLocais" cd ON (cd.loc_integrationid = fat."Codigo_Cliente"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_CadastrodeLocais" loc ON (loc.i_codigo_cd = fat."Codigo_Cliente"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_CadastrodeItens" ite ON (ite.ite_integrationid = fat."Codigo_Produto"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_BasedeRotas" rot ON (loc.loc_integrationid = rot.i_rota_pdv_codigo AND to_date(rot.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', fat."Data_da_Fatura")::DATE)
LEFT JOIN bicbl."fat_bicbl_CadastrodePromotores" age ON (age.age_integrationid = rot.i_rota_promotor_codigo)
WHERE fat."Codigo_Cliente"::INTEGER::TEXT IN (SELECT DISTINCT trim(cad.i_codigo_cd) FROM bicbl."fat_bicbl_CadastrodeLocais" cad WHERE cad.i_codigo_cd is not null)
AND fat."Data_da_Fatura"::DATE >= DATE_TRUNC('MONTH', NOW()::DATE) - '8 MONTHS'::INTERVAL

UNION ALL

-- Source: Faturamento Redes
SELECT 
      age.age_name as "Promotor"
    , age.age_name as "Promotor Rota"
    , age.e_auditor as "Gerente"
    , age.e_agent_mix as "Promotor Mix"
    , age.e_regional as "Promotor Regional"
    , age.e_hora_inicio as "Promotor Hora Inicio"
    , age.e_hora_fim as "Promotor Hora Fim"
    , age.e_salario as "Promotor Salário"
    , age.e_supervisor as "Supervisor"
    , COALESCE(loc.loc_description, fat."Cliente")::TEXT as "PDV"
    , loc.loc_state::TEXT as "PDV Estado"
    , loc.loc_city::TEXT as "PDV Cidade"
    , loc.loc_neighborhood::TEXT as "PDV Bairro"
    , loc.loc_geoposition::TEXT as "PDV Geo"
    , COALESCE(loc.loc_integrationid, fat."Codigo_Cliente")::TEXT as "PDV Código"
    , COALESCE(loc.loc_integrationid, fat."Codigo_Cliente")::TEXT as "Qtd PDVs Faturados"
    , loc.loc_active::TEXT as "PDV Ativo"
    , loc.e_canal::TEXT as "PDV Canal"
    , loc.e_ciclo_atendimento::TEXT as "PDV Ciclo Atendimento"
    , loc.e_rede::TEXT as "PDV Rede"
    , loc.e_regional::TEXT as "PDV Regional"
    , loc.e_trabalha_atacado::TEXT as "PDV Atacado"
    , loc.e_volumeqtd_caixah::TEXT as "PDV Volume Qtd Caixa" 
      , loc.e_grupo_de_lojas::TEXT AS "PDV Grupo"
    , rot.e_rota_nome::TEXT as "Rota"
    , rot.e_rota_nome::TEXT AS "Qtd Rotas"
    , ite.ite_id::TEXT
    , COALESCE(ite.ite_integrationid::TEXT, fat."Codigo_Produto"::INTEGER::TEXT) AS "Qtd Itens Faturados"
    , COALESCE(ite.ite_description, (fat."Produto"||' (Cód '||fat."Codigo_Produto"::INTEGER::TEXT||')'))::TEXT as "Item"
    , ite.e_categoria_cbl::TEXT as "Item Categoria CBL"
    , ite.e_dias_vencimento_1::TEXT as "Item Dias Vencimento 1"
    , ite.e_dias_vencimento_2::TEXT as "Item Dias Vencimento 2"
    , ite.e_dias_vencimento_3::TEXT as "Item Dias Vencimento 3"
    , ite.e_marcas_cbl::TEXT as "Item Marcas CBL"
    , ite.e_quantidade_embalagem::TEXT as "Item Qtd Embalagem"
    , ite.e_secoes::TEXT as "Item Seções"
    , loc.loc_id::TEXT 
    , fat."Data_da_Fatura"::DATE AS "Periodo"
    , fat."Data_da_Fatura"::DATE AS "Periodo Filtro"
    , (fat."VL_FAT"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Valor Faturado"
    , (fat."VL_DEV"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Valor Devolvido"
    , (fat."VL_DEV_ACORDO"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Valor Devolvido Acordo"
    , (fat."QT_FAT"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Qtd Faturada"
    , (fat."QT_DEV"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Qtd Devolvida"
    , (fat."QT_DEV_ACORDO"::DOUBLE PRECISION * (REPLACE(REPLACE(loc.i_perc_pdv,'%',''),',','.')::DOUBLE PRECISION/100)) AS "Qtd Devolvida Acordo"
FROM bicbl."fat_bicbl_Faturamento" fat
LEFT JOIN bicbl."fat_bicbl_CadastrodeLocais" red ON (red.loc_integrationid = fat."Codigo_Cliente"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_CadastrodeLocais" loc ON (loc.i_codigo_rede = fat."Codigo_Cliente"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_CadastrodeItens" ite ON (ite.ite_integrationid = fat."Codigo_Produto"::INTEGER::TEXT)
LEFT JOIN bicbl."fat_bicbl_BasedeRotas" rot ON (loc.loc_integrationid = rot.i_rota_pdv_codigo AND to_date(rot.i_rota_periodo, 'DD/MM/YYYY')::DATE = DATE_TRUNC('MONTH', fat."Data_da_Fatura")::DATE)
LEFT JOIN bicbl."fat_bicbl_CadastrodePromotores" age ON (age.age_integrationid = rot.i_rota_promotor_codigo)
WHERE fat."Codigo_Cliente"::INTEGER::TEXT IN (SELECT DISTINCT trim(cad.i_codigo_rede) FROM bicbl."fat_bicbl_CadastrodeLocais" cad WHERE cad.i_codigo_rede is not null)
AND fat."Data_da_Fatura"::DATE >= DATE_TRUNC('MONTH', NOW()::DATE) - '8 MONTHS'::INTERVAL