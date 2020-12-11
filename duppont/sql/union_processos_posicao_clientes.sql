-- Source: Processos Base
SELECT 
	CAST(pb."tipo_de_acao_tacchini" AS TEXT) AS "tipo_de_acao_tacchini",
	CAST(pb."data_do_cadastro" AS DATE) AS "data_do_cadastro",
	CAST(pb."nro_nome_vara_turma" AS TEXT) AS "nro_nome_vara_turma",
	CAST(pb."cliente_principal" AS TEXT) AS "cliente_principal",
	CAST(pb."decisao_terceiro_grau" AS TEXT) AS "decisao_terceiro_grau",
	CAST(pb."titulo" AS TEXT) AS "titulo",
	CAST(pb."contrario_principal" AS TEXT) AS "contrario_principal",
	CAST(pb."grupo" AS TEXT) AS "grupo",
	CAST(pb."tipo_da_probabilidade_atual" AS TEXT) AS "tipo_da_probabilidade_atual",
	CAST(pb."tipo_das_custas" AS TEXT) AS "tipo_das_custas",
	CAST(pb."status_processo" AS TEXT) AS "status_processo",
	CAST(pb."cidade" AS TEXT) AS "cidade",
	CAST(pb."unidade_jbs" AS TEXT) AS "unidade_jbs",
	CAST(pb."cliente_principal_posicao" AS TEXT) AS "cliente_principal_posicao",
	CAST(pb."data_demissao" AS DATE) AS "data_demissao",
	CAST(pb."data_do_encerramento" AS DATE) AS "data_do_encerramento",
	CAST(pb."acordo_sentenca_de_obrigacao_de_fazer" AS TEXT) AS "acordo_sentenca_de_obrigacao_de_fazer",
	CAST(pb."financeira_envolvida" AS TEXT) AS "financeira_envolvida",
	CAST(pb."obra" AS TEXT) AS "obra",
	CAST(pb."nro_processo_administrativo" AS TEXT) AS "nro_processo_administrativo",
	CAST(pb."periodo" AS DATE) AS "periodo",
	CAST(pb."data_admissao" AS DATE) AS "data_admissao",
	CAST(pb."data_de_distribuicao" AS DATE) AS "data_de_distribuicao",
	CAST(pb."terceiros" AS TEXT) AS "terceiros",
	CAST(pb."marca" AS TEXT) AS "marca",
	CAST(pb."tipo_do_processo" AS TEXT) AS "tipo_do_processo",
	CAST(pb."motivo_resultado" AS TEXT) AS "motivo_resultado",
	CAST(pb."natureza" AS TEXT) AS "natureza",
	CAST(pb."classificacao_financeira_cc" AS TEXT) AS "classificacao_financeira_cc",
	CAST(pb."tipo_de_outro_numero" AS TEXT) AS "tipo_de_outro_numero",
	CAST(pb."qtd_processos" AS TEXT) AS "qtd_processos",
	CAST(pb."escritorio_correspondente" AS TEXT) AS "escritorio_correspondente",
	CAST(pb."pasta_fisica" AS TEXT) AS "pasta_fisica",
	CAST(pb."objetos_nome" AS TEXT) AS "objetos_nome",
	CAST(pb."resultado" AS TEXT) AS "resultado",
	CAST(pb."razao_da_extincao_do_processo" AS TEXT) AS "razao_da_extincao_do_processo",
	CAST(pb."data_da_sentenca" AS DATE) AS "data_da_sentenca",
	CAST(pb."empresa_envolvida_razao_social" AS TEXT) AS "empresa_envolvida_razao_social",
	CAST(pb."uf" AS TEXT) AS "uf",
	CAST(pb."complemento_de_vara_turma" AS TEXT) AS "complemento_de_vara_turma",
	CAST(pb."orgao" AS TEXT) AS "orgao",
	CAST(pb."risco" AS TEXT) AS "risco",
	CAST(pb."procedimento" AS TEXT) AS "procedimento",
	CAST(pb."pasta" AS TEXT) AS "pasta",
	CAST(pb."nro_sistema_interno" AS TEXT) AS "nro_sistema_interno",
	CAST(pb."cda" AS TEXT) AS "cda",
	CAST(pb."responsavel_principal_posicao" AS TEXT) AS "responsavel_principal_posicao",
	CAST(pb."tipo" AS TEXT) AS "tipo",
	CAST(pb."motivo_do_encerramento" AS TEXT) AS "motivo_do_encerramento",
	CAST(pb."decisao_segundo_grau" AS TEXT) AS "decisao_segundo_grau",
	CAST(pb."justica_cnj" AS TEXT) AS "justica_cnj",
	CAST(pb."escritorio_origem" AS TEXT) AS "escritorio_origem",
	CAST(pb."numero_antigo" AS TEXT) AS "numero_antigo",
	CAST(pb."profissao_reclamante" AS TEXT) AS "profissao_reclamante",
	CAST(pb."contratacao_de_honorarios" AS TEXT) AS "contratacao_de_honorarios",
	CAST(pb."subfases_recuperacao_de_credito" AS TEXT) AS "subfases_recuperacao_de_credito",
	CAST(pb."outro_numero" AS TEXT) AS "outro_numero",
	CAST(pb."instancia_cnj" AS TEXT) AS "instancia_cnj",
	CAST(pb."comarca_foro" AS TEXT) AS "comarca_foro",
	CAST(pb."data_do_resultado" AS DATE) AS "data_do_resultado",
	CAST(pb."custas_outras_despesas" AS TEXT) AS "custas_outras_despesas",
	CAST(pb."data_da_baixa" AS DATE) AS "data_da_baixa",
	CAST(pb."situacao_empresa_envolvida" AS TEXT) AS "situacao_empresa_envolvida",
	CAST(pb."escritorio_responsavel" AS TEXT) AS "escritorio_responsavel",
	CAST(pb."data_recebimento_ds" AS DATE) AS "data_recebimento_ds",
	CAST(pb."decisao_primeiro_grau" AS TEXT) AS "decisao_primeiro_grau",
	CAST(pb."numero_do_processo" AS TEXT) AS "numero_do_processo",
	CAST(pb."acao" AS TEXT) AS "acao",
	CAST(pb."fase" AS TEXT) AS "fase",
	CAST(pb."contingencia" AS TEXT) AS "contingencia",
	CAST(pb."faixa_de_probabilidade_atual" AS TEXT) AS "faixa_de_probabilidade_atual",
	CAST(pb."data_da_citacao" AS DATE) AS "data_da_citacao",
	CAST(pb."importancia_honorarios" AS TEXT) AS "importancia_honorarios",
	CAST(pb."agencia_devedor" AS TEXT) AS "agencia_devedor",
	CAST(pb."responsavel_principal" AS TEXT) AS "responsavel_principal",
	CAST(pb."subtipo_de_acao_tacchini" AS TEXT) AS "subtipo_de_acao_tacchini",
	CAST(pb."objetos_observacoes" AS TEXT) AS "objetos_observacoes",
	CAST(pb."tipo_de_resultado" AS TEXT) AS "tipo_de_resultado",
	CAST(pb."valor_pago" AS DOUBLE PRECISION) AS "valor_pago",
	CAST(pb."custas" AS DOUBLE PRECISION) AS "custas",
	CAST(pb."valor_do_acordo" AS DOUBLE PRECISION) AS "valor_do_acordo",
	CAST(pb."valor_do_acordo_condenacao_atualizado" AS DOUBLE PRECISION) AS "valor_do_acordo_condenacao_atualizado",
	CAST(pb."valor_do_acordo_condenacao" AS DOUBLE PRECISION) AS "valor_do_acordo_condenacao",
	CAST(pb."valor_envolvido_atualizado" AS DOUBLE PRECISION) AS "valor_envolvido_atualizado",
	CAST(pb."duracao_de_processo" AS DOUBLE PRECISION) AS "duracao_de_processo",
	CAST(pb."valor_de_honorarios" AS DOUBLE PRECISION) AS "valor_de_honorarios",
	CAST(pb."valor_da_causa_atualizado" AS DOUBLE PRECISION) AS "valor_da_causa_atualizado",
	CAST(pb."acordo_sentenca_de_terceiro_vlr" AS DOUBLE PRECISION) AS "acordo_sentenca_de_terceiro_vlr",
	CAST(pb."valor_envolvido" AS DOUBLE PRECISION) AS "valor_envolvido",
	CAST(pb."valor_da_causa" AS DOUBLE PRECISION) AS "valor_da_causa",
	CAST(pb."valor_envolvido_atualizado_1" AS DOUBLE PRECISION) AS "valor_envolvido_atualizado_1",
    CAST(cp."clienteposicao" AS TEXT) AS "clienteposicao"
FROM "dupontspiller"."fat_dupontspiller_ProcessosBase" pb
LEFT JOIN "dupontspiller"."fat_dupontspiller_ClientePosicaoBase" cp ON (MD5(UPPER(TRIM(CAST(pb."cliente_principal_posicao" AS TEXT)))) = MD5(UPPER(TRIM(CAST(cp."clienteprincipalposicao" AS TEXT)))))