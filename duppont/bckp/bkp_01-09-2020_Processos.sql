WITH meses AS (
SELECT
	GENERATE_SERIES
        ( MIN( DATE_TRUNC('MONTH', TO_DATE(proc.data_da_baixa, 'YYYY-MM-DD')))
        , NOW()
        , '1 MONTH'::INTERVAL)::DATE AS mes
FROM public.processos_baixados proc
)

, evolucao_historico_processos AS (
	SELECT
		*
--		, LAG(periodo, 1) OVER (PARTITION BY pasta ORDER BY pasta, periodo) AS penultimo_periodo
--		, LAG(status_processo, 1) OVER (PARTITION BY pasta ORDER BY pasta, periodo) AS penultimo_status
	FROM
	(
		( -- PROCESSOS ATIVOS E SUSPENSOS
		SELECT DISTINCT
			proc.pasta AS pasta
	        , meses.mes AS periodo

	        , CASE
				WHEN (meses.mes = DATE_TRUNC('MONTH', comp_proc."data_do_cadastro"::DATE))
				THEN 'NOVO'
				WHEN (meses.mes >= DATE_TRUNC('MONTH', proc."data_da_baixa"::DATE))
				THEN 'BAIXADO'
				ELSE 'ATIVO'
			END AS status_processo
		FROM public.processos proc
	    INNER JOIN public.complementos_processos comp_proc ON (proc.pasta = comp_proc.pasta)
	    INNER JOIN meses ON ( meses.mes >= DATE_TRUNC('MONTH', comp_proc."data_do_cadastro"::DATE)::DATE AND meses.mes <= DATE_TRUNC('MONTH', COALESCE(proc."data_da_baixa"::DATE, NOW()))::DATE)
	   	)

	    UNION ALL

		( -- PROCESSOS BAIXADOS E ARQUIVADOS
		SELECT DISTINCT
			proc.pasta AS pasta
	        , meses.mes AS periodo

	        , CASE
				WHEN (meses.mes = DATE_TRUNC('MONTH', comp_proc."data_do_cadastro"::DATE))
				THEN 'NOVO'
				WHEN (meses.mes >= DATE_TRUNC('MONTH', proc."data_da_baixa"::DATE))
				THEN 'BAIXADO'
				ELSE 'ATIVO'
			END AS status_processo
		FROM public.processos_baixados proc
	    INNER JOIN public.complementos_processos_baixados comp_proc ON (proc.pasta = comp_proc.pasta)
	    INNER JOIN meses ON ( meses.mes >= DATE_TRUNC('MONTH', comp_proc."data_do_cadastro"::DATE)::DATE AND meses.mes <= DATE_TRUNC('MONTH', COALESCE(proc."data_da_baixa"::DATE, NOW()))::DATE)
	    )
	) x
)

, grupos_clientes AS (
SELECT DISTINCT
	MD5(UPPER(TRIM(nome_razao_social))) AS hash_md5
	, UPPER(TRIM(nome_razao_social)) AS cliente
	, UPPER(TRIM(grupos_nome)) AS grupo
FROM grupos
)

( /* PROCESSOS ATIVOS E SUSPENSOS */
SELECT DISTINCT
	proc.escritorio_origem
	, proc.escritorio_responsavel
	, proc.pasta
	, proc.contratacao_de_honorarios
	, proc.titulo
	, proc.tipo
	, proc.numero_do_processo
	, proc.numero_antigo
	, proc.tipo_de_outro_numero
	, proc.outro_numero
--	, proc.status /* UTILIZAR A COLUNA "status_processo" */
	, TO_DATE(proc.data_de_distribuicao, 'YYYY-MM-DD') AS data_de_distribuicao
	, proc.acao
	, proc.natureza
	, proc.procedimento
	, proc.fase
	, proc.uf
	, proc.cidade
	, proc.orgao
	, proc.justica_cnj
	, proc.instancia_cnj
	, proc.nro_da_vara_turma_nome_da_vara_turma AS nro_nome_vara_turma
	, proc.complemento_de_vara_turma
	, proc.comarca_foro
	, proc.cliente_principal
	, proc.cliente_principal_posicao
	, proc.responsavel_principal
	, proc.responsavel_principal_posicao
	, proc.contrario_principal
	, proc.objetos_nome
	, proc.objetos_observacoes
	, REPLACE(proc.valor_da_causa, ',', '.')::DOUBLE PRECISION AS valor_da_causa
	, REPLACE(proc.valor_da_causa_atualizado, ',', '.')::DOUBLE PRECISION AS valor_da_causa_atualizado
	, REPLACE(proc.valor_do_acordo, ',', '.')::DOUBLE PRECISION AS valor_do_acordo
	, REPLACE(proc.valor_do_acordo_condenacao, ',', '.')::DOUBLE PRECISION AS valor_do_acordo_condenacao
	, REPLACE(proc.valor_do_acordo_condenacao_atualizado, ',', '.')::DOUBLE PRECISION AS valor_do_acordo_condenacao_atualizado
	, REPLACE(proc.valor_envolvido, ',', '.')::DOUBLE PRECISION AS valor_envolvido
	, REPLACE(proc.valor_envolvido_atualizado, ',', '.')::DOUBLE PRECISION AS valor_envolvido_atualizado
	, REPLACE(proc.valor_envolvido_atualizado_1, ',', '.')::DOUBLE PRECISION AS valor_envolvido_atualizado_1
	, REPLACE(proc.valor_de_honorarios, ',', '.')::DOUBLE PRECISION AS valor_de_honorarios
	, REPLACE(proc.custas, ',', '.')::DOUBLE PRECISION AS custas
	, proc.custas_outras_despesas
	, proc.tipo_das_custas
	, proc.centros_de_custo_classificacao_financeira_centro_de_custo AS classificacao_financeira_cc
	, proc.contingencia
	, proc.faixa_de_probabilidade_atual
	, proc.tipo_da_probabilidade_atual
	, proc.risco
	, TO_DATE(proc.data_do_resultado, 'YYYY-MM-DD') AS data_do_resultado
	, proc.motivo_resultado
	, proc.tipo_de_resultado
	, proc.resultado
	, TO_DATE(proc.data_da_sentenca, 'YYYY-MM-DD') AS data_da_sentenca
	, TO_DATE(proc.data_da_baixa, 'YYYY-MM-DD') AS data_da_baixa
	, TO_DATE(proc.data_do_encerramento, 'YYYY-MM-DD') AS data_do_encerramento
	, proc.motivo_do_encerramento
	, comp_proc.nro_sistema_interno
	, comp_proc.cda
	, array_to_string(ARRAY(SELECT DISTINCT * FROM unnest(string_to_array(replace( regexp_replace(comp_proc.empresa_envolvida_razao_social, '\r|\n', ' - ', 'g'), '/ - ', ' - '),' - ')) x),', ') AS empresa_envolvida_razao_social
	, TO_DATE(comp_proc.data_recebimento_ds, 'YYYY-MM-DD') AS data_recebimento_ds
	, TO_DATE(comp_proc.data_admissao, 'YYYY-MM-DD') AS data_admissao
	, TO_DATE(comp_proc.data_demissao, 'YYYY-MM-DD') AS data_demissao
	, TO_DATE(comp_proc.data_da_citacao, 'YYYY-MM-DD') AS data_da_citacao
	, REPLACE(comp_proc.acordo_sentenca_de_terceiro_vlr, ',', '.')::DOUBLE PRECISION AS acordo_sentenca_de_terceiro_vlr
	, comp_proc.acordo_sentenca_de_obrigacao_de_fazer
	, comp_proc.situacao_empresa_envolvida
	, REPLACE(comp_proc.valor_pago, ',', '.')::DOUBLE PRECISION AS valor_pago
	, comp_proc.razao_da_extincao_do_processo
	, comp_proc.tipo_do_processo
	, comp_proc.obra
	, comp_proc.financeira_envolvida
	, comp_proc.pasta_fisica
 	, comp_proc.profissao_reclamante
 	, comp_proc.decisao_primeiro_grau
	, comp_proc.decisao_segundo_grau
	, comp_proc.decisao_terceiro_grau
	, comp_proc.subfases_recuperacao_de_credito
	, comp_proc.marca
	, comp_proc.unidade_jbs
	, comp_proc.agencia_devedor
	, comp_proc.tipo_de_acao_tacchini
	, comp_proc.subtipo_de_acao_tacchini
	, comp_proc.escritorio_correspondente
 	, comp_proc.terceiros
	, comp_proc.nro_processo_administrativo
	, comp_proc.importancia_honorarios
	, CASE WHEN proc.pasta NOT ILIKE '%/%' THEN proc.pasta ELSE NULL END AS qtd_processos
	, comp_proc.data_do_cadastro::DATE AS data_do_cadastro

	, x.periodo
	, x.status_processo

	, gc.grupo
FROM public.processos proc
LEFT JOIN public.complementos_processos comp_proc ON (proc.pasta = comp_proc.pasta)
LEFT JOIN evolucao_historico_processos x ON (proc.pasta = x.pasta)
LEFT JOIN grupos_clientes gc ON (gc.hash_md5 = MD5(UPPER(TRIM(proc.cliente_principal))))
WHERE
	TRIM(UPPER(proc.envolvidos_posicao)) != 'CONTROLADORIA'
	AND TRIM(UPPER(proc.envolvidos_situacao)) != 'OUTROS'
	AND x.periodo >= DATE_TRUNC('MONTH', (NOW() - '1 MONTH'::INTERVAL))
)

UNION ALL

( /* PROCESSOS ARQUIVADOS E BAIXADOS */
SELECT DISTINCT
	proc.escritorio_origem
	, proc.escritorio_responsavel
	, proc.pasta
	, proc.contratacao_de_honorarios
	, proc.titulo
	, proc.tipo
	, proc.numero_do_processo
	, proc.numero_antigo
	, proc.tipo_de_outro_numero
	, proc.outro_numero
--	, proc.status /* UTILIZAR A COLUNA "status_processo" */
	, TO_DATE(proc.data_de_distribuicao, 'YYYY-MM-DD') AS data_de_distribuicao
	, proc.acao
	, proc.natureza
	, proc.procedimento
	, proc.fase
	, proc.uf
	, proc.cidade
	, proc.orgao
	, proc.justica_cnj
	, proc.instancia_cnj
	, proc.nro_da_vara_turma_nome_da_vara_turma AS nro_nome_vara_turma
	, proc.complemento_de_vara_turma
	, proc.comarca_foro
	, proc.cliente_principal
	, proc.cliente_principal_posicao
	, proc.responsavel_principal
	, proc.responsavel_principal_posicao
	, proc.contrario_principal
	, proc.objetos_nome
	, proc.objetos_observacoes
	, REPLACE(proc.valor_da_causa, ',', '.')::DOUBLE PRECISION AS valor_da_causa
	, REPLACE(proc.valor_da_causa_atualizado, ',', '.')::DOUBLE PRECISION AS valor_da_causa_atualizado
	, REPLACE(proc.valor_do_acordo, ',', '.')::DOUBLE PRECISION AS valor_do_acordo
	, REPLACE(proc.valor_do_acordo_condenacao, ',', '.')::DOUBLE PRECISION AS valor_do_acordo_condenacao
	, REPLACE(proc.valor_do_acordo_condenacao_atualizado, ',', '.')::DOUBLE PRECISION AS valor_do_acordo_condenacao_atualizado
	, REPLACE(proc.valor_envolvido, ',', '.')::DOUBLE PRECISION AS valor_envolvido
	, REPLACE(proc.valor_envolvido_atualizado, ',', '.')::DOUBLE PRECISION AS valor_envolvido_atualizado
	, REPLACE(proc.valor_envolvido_atualizado_1, ',', '.')::DOUBLE PRECISION AS valor_envolvido_atualizado_1
	, REPLACE(proc.valor_de_honorarios, ',', '.')::DOUBLE PRECISION AS valor_de_honorarios
	, REPLACE(proc.custas, ',', '.')::DOUBLE PRECISION AS custas
	, proc.custas_outras_despesas
	, proc.tipo_das_custas
	, proc.centros_de_custo_classificacao_financeira_centro_de_custo AS classificacao_financeira_cc
	, proc.contingencia
	, proc.faixa_de_probabilidade_atual
	, proc.tipo_da_probabilidade_atual
	, proc.risco
	, TO_DATE(proc.data_do_resultado, 'YYYY-MM-DD') AS data_do_resultado
	, proc.motivo_resultado
	, proc.tipo_de_resultado
	, proc.resultado
	, TO_DATE(proc.data_da_sentenca, 'YYYY-MM-DD') AS data_da_sentenca
	, TO_DATE(proc.data_da_baixa, 'YYYY-MM-DD') AS data_da_baixa
	, TO_DATE(proc.data_do_encerramento, 'YYYY-MM-DD') AS data_do_encerramento
	, proc.motivo_do_encerramento
	, comp_proc.nro_sistema_interno
	, comp_proc.cda
	, array_to_string(ARRAY(SELECT DISTINCT * FROM unnest(string_to_array(replace( regexp_replace(comp_proc.empresa_envolvida_razao_social, '\r|\n', ' - ', 'g'), '/ - ', ' - '),' - ')) x),', ') AS empresa_envolvida_razao_social

	, TO_DATE(comp_proc.data_recebimento_ds, 'YYYY-MM-DD') AS data_recebimento_ds
	, TO_DATE(comp_proc.data_admissao, 'YYYY-MM-DD') AS data_admissao
	, TO_DATE(comp_proc.data_demissao, 'YYYY-MM-DD') AS data_demissao
	, TO_DATE(comp_proc.data_da_citacao, 'YYYY-MM-DD') AS data_da_citacao
	, REPLACE(comp_proc.acordo_sentenca_de_terceiro_vlr, ',', '.')::DOUBLE PRECISION AS acordo_sentenca_de_terceiro_vlr
	, comp_proc.acordo_sentenca_de_obrigacao_de_fazer
	, comp_proc.situacao_empresa_envolvida
	, REPLACE(comp_proc.valor_pago, ',', '.')::DOUBLE PRECISION AS valor_pago
	, comp_proc.razao_da_extincao_do_processo
	, comp_proc.tipo_do_processo
	, comp_proc.obra
	, comp_proc.financeira_envolvida
	, comp_proc.pasta_fisica
 	, comp_proc.profissao_reclamante
 	, comp_proc.decisao_primeiro_grau
	, comp_proc.decisao_segundo_grau
	, comp_proc.decisao_terceiro_grau
	, comp_proc.subfases_recuperacao_de_credito
	, comp_proc.marca
	, comp_proc.unidade_jbs
	, comp_proc.agencia_devedor
	, comp_proc.tipo_de_acao_tacchini
	, comp_proc.subtipo_de_acao_tacchini
	, comp_proc.escritorio_correspondente
 	, comp_proc.terceiros
	, comp_proc.nro_processo_administrativo
	, comp_proc.importancia_honorarios
	, CASE WHEN proc.pasta NOT ILIKE '%/%' THEN proc.pasta ELSE NULL END AS qtd_processos
	, comp_proc.data_do_cadastro::DATE AS data_do_cadastro

	, x.periodo
	, x.status_processo

	, gc.grupo
FROM public.processos_baixados proc
LEFT JOIN public.complementos_processos_baixados comp_proc ON (proc.pasta = comp_proc.pasta)
LEFT JOIN evolucao_historico_processos x ON (proc.pasta = x.pasta)
LEFT JOIN grupos_clientes gc ON (gc.hash_md5 = MD5(UPPER(TRIM(proc.cliente_principal))))
WHERE
	TRIM(UPPER(proc.envolvidos_posicao)) != 'CONTROLADORIA'
	AND TRIM(UPPER(proc.envolvidos_situacao)) != 'OUTROS'
	AND x.periodo >= DATE_TRUNC('MONTH', (NOW() - '1 MONTH'::INTERVAL))
)