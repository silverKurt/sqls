WITH dados_brutos AS (
	select "Promotor"
			, "age_id"
			, "Descrição da Ausência"
			, "Data de Início"
			, "Data de Fim"
	        , "Intervalo" AS "Intervalo Geral"
	        , "Mês de Referência Início"
	        , "Mês de Referência Fim"
			, CASE WHEN "Mês de Referência Início" = "Mês de Referência Fim" THEN "Intervalo"
	        	 ELSE NULL
	        END AS "Intervalo"
	        , CASE WHEN "Mês de Referência Início" != "Mês de Referência Fim" THEN CAST(to_char((((date_trunc('month', "Data de Início")+ '1 month'::interval) - '1 day'::interval) - "Data de Início"), 'dd') AS INTEGER) + 1
	        	 ELSE NULL
	        END AS "Intervalo Mes Um"
	        , CASE WHEN "Mês de Referência Início" != "Mês de Referência Fim" THEN CAST(to_char(("Data de Fim" - date_trunc('month', "Data de Fim")), 'dd') AS INTEGER) + 1
	        	 ELSE NULL
	        END AS "Intervalo Mes Dois"
	from (
			select 
				age.age_name as "Promotor"
			    , age.age_id as "age_id"
			    , sca.sca_description as "Descrição da Ausência"
			    , CAST(DATE_TRUNC('MONTH', sca.sca_initialdatehour) AS DATE) as "Mês de Referência Início"
			    , CAST(DATE_TRUNC('MONTH', sca.sca_finaldatehour) AS DATE) as "Mês de Referência Fim"
			    , CAST(sca.sca_initialdatehour AS DATE) as "Data de Início"
			    , CAST(sca.sca_finaldatehour AS DATE) as "Data de Fim"
			    , CAST(to_char((sca.sca_finaldatehour - sca.sca_initialdatehour), 'dd') AS INTEGER) + 1 as "Intervalo"
			from scheduledabsence sca
			inner join agent age on (sca.age_id_origin = age.age_id)
	) x
)
SELECT "Promotor"
		, "age_id"
		, "Descrição da Ausência"
		, "Mês de Referência Fim"  AS "Periodo"
		, cast(extract(days FROM date_trunc('month', "Mês de Referência Fim") + interval '1 month - 1 day') AS INTEGER) AS "Dias no Mês"
		, "Data de Início"
		, "Data de Fim"
	    , "Intervalo Mes Dois" AS "Intervalo"
	    , cast(extract(days FROM date_trunc('month', "Mês de Referência Fim") + interval '1 month - 1 day') AS INTEGER) - "Intervalo Mes Dois" AS "Dias Trabalhados"
	    , (1 - ((cast(extract(days FROM date_trunc('month', "Mês de Referência Fim") + interval '1 month - 1 day') AS INTEGER) - "Intervalo Mes Dois") / cast(extract(days FROM date_trunc('month', "Mês de Referência Fim") + interval '1 month - 1 day') AS INTEGER))) AS "Absenteísmo no Mês"
FROM dados_brutos
WHERE "Mês de Referência Início" != "Mês de Referência Fim" AND "Intervalo Mes Dois" IS NOT NULL


UNION ALL

SELECT "Promotor"
		, "age_id"
		, "Descrição da Ausência"
		, "Mês de Referência Início" AS "Periodo"
		, cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER) AS "Dias no Mês"
		, "Data de Início"
		, "Data de Fim"
	    --, "Intervalo Geral"
	    , "Intervalo Mes Um" AS "Intervalo"
	    , cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER) - "Intervalo Mes Um" AS "Dias Trabalhados"
	    , (1 - (cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER) - "Intervalo Mes Um") / cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER)) AS "Absenteísmo no Mês"
FROM dados_brutos
WHERE "Mês de Referência Início" != "Mês de Referência Fim" AND "Intervalo Mes Um" IS NOT NULL


UNION ALL

SELECT "Promotor"
		, "age_id"
		, "Descrição da Ausência"
		, "Mês de Referência Início" AS "Periodo"
		, cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER) AS "Dias no Mês"
		, "Data de Início"
		, "Data de Fim"
	    --, "Intervalo Geral"
	    , "Intervalo"
	    , cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER) - "Intervalo" AS "Dias Trabalhados"
	    , (1 - (cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER) - "Intervalo") / cast(extract(days FROM date_trunc('month', "Mês de Referência Início") + interval '1 month - 1 day') AS INTEGER)) AS "Absenteísmo no Mês"
FROM dados_brutos
WHERE "Mês de Referência Início" = "Mês de Referência Fim"

