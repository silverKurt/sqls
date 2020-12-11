-- Source: Metas
WITH dbout_visitas_final AS (
    WITH dbout_visitas AS (
        SELECT 
        	DATE_TRUNC('MONTH', CAST("Periodo" AS DATE)) AS "Periodo"
            , CAST("Supervisor" AS TEXT) AS "Supervisor"
            , CAST("QtdSupervisor" AS TEXT) AS "Id_Supervisor"
            , "Status da Tarefa"
            , COUNT(DISTINCT "Qtd Tarefas") AS "Qtd Tarefas"
        FROM (
            SELECT 
                CAST("Periodo" AS DATE) AS "Periodo",
                CAST("Qtd Supervisor" AS TEXT) AS "QtdSupervisor",
                CAST("Supervisor" AS TEXT) AS "Supervisor",
                CAST("Qtd Tarefas" AS TEXT) AS "Qtd Tarefas",
                CASE WHEN CAST("status_entrada" AS TEXT) = 'OK' THEN 'REALIZADA'
                     ELSE 'NÃO REALIZADA'
                END AS "Status da Tarefa"
            FROM "britivc"."fat_britivc_Visitas"
            ORDER BY 1 DESC, 2
        ) X
        GROUP BY 1,2,3,4
    )

    SELECT "Periodo", "Supervisor",  "Id_Supervisor", ("Qtd Tarefas" / "Soma") AS "Roteiro" FROM (
    SELECT 
    	"Periodo"::DATE
        , "Supervisor"
        , "Id_Supervisor"
        , "Status da Tarefa"
        , "Qtd Tarefas"
        , (SELECT SUM("Qtd Tarefas") FROM dbout_visitas dv WHERE dv."Periodo" = dbv."Periodo" AND dbv."Supervisor" = dv."Supervisor" GROUP BY "Periodo", "Supervisor") AS "Soma"
    FROM dbout_visitas dbv
    ) X WHERE "Status da Tarefa" = 'REALIZADA'
), dbout_rupturas_final AS (
    WITH dbout_rupturas AS (
        SELECT
            DATE_TRUNC('MONTH', CAST("Data Inicio Previsto" AS DATE))::DATE AS "Periodo",
            CAST("Supervisor" AS TEXT) AS "Supervisor",
            CAST("Produto em Ruptura" AS TEXT) AS "ehRuptura",
            COUNT(DISTINCT CASE WHEN CAST("QtdFamílias" AS TEXT) = 'BELA ISCHIA' AND (CAST("QtdCategorias" AS TEXT) = 'MARACUJA' OR CAST("QtdCategorias" AS TEXT) = 'CAJU') THEN CAST("tsk_id" AS TEXT)
                    ELSE NULL
            END) AS "Ruptura Bela Ischia",
            COUNT(DISTINCT CASE WHEN CAST("QtdFamílias" AS TEXT) = 'DAFRUTA (DF)' AND (CAST("QtdCategorias" AS TEXT) = 'MARACUJA' OR CAST("QtdCategorias" AS TEXT) = 'CAJU') THEN CAST("tsk_id" AS TEXT)
                    ELSE NULL
            END) AS "Ruptura DaFruta",
            COUNT(DISTINCT CASE WHEN CAST("Grupo de Produto" AS TEXT) = 'UVA INTEGRAL' THEN CAST("tsk_id" AS TEXT)
                    ELSE NULL
            END) AS "Ruptura Uva Integral"
        FROM "britivc"."fat_britivc_RupturaDiaria"
        GROUP BY 1,2,3
        ORDER BY 1,2
    )

    SELECT 
        "Periodo"
        , "Supervisor"
        , ("Ruptura Bela Ischia" / "Soma Bela Ischia") AS "Ruptura Bela Ischia"
        , ("Ruptura DaFruta" / "Soma DaFruta") AS "Ruptura DaFruta"
        , ("Ruptura Uva Integral" / "Soma Uva Integral") AS "Ruptura Uva Integral"
    FROM (
    SELECT 
    	"Periodo"::DATE
        , "Supervisor"
        , "ehRuptura"
        , "Ruptura Bela Ischia"
        , "Ruptura DaFruta"
        , "Ruptura Uva Integral"
        , (SELECT SUM("Ruptura Bela Ischia") FROM dbout_rupturas dr WHERE dr."Periodo" = dbr."Periodo" AND dbr."Supervisor" = dr."Supervisor" GROUP BY "Periodo", "Supervisor") AS "Soma Bela Ischia"
        , (SELECT SUM("Ruptura DaFruta") FROM dbout_rupturas dr WHERE dr."Periodo" = dbr."Periodo" AND dbr."Supervisor" = dr."Supervisor" GROUP BY "Periodo", "Supervisor") AS "Soma DaFruta"
        , (SELECT SUM("Ruptura Uva Integral") FROM dbout_rupturas dr WHERE dr."Periodo" = dbr."Periodo" AND dbr."Supervisor" = dr."Supervisor" GROUP BY "Periodo", "Supervisor") AS "Soma Uva Integral"
    FROM dbout_rupturas dbr
    ) X WHERE "ehRuptura" = 'SIM'
), dbout_pontos_extras AS (
        SELECT
            DATE_TRUNC('MONTH', "DataInicioPrevisto")::DATE AS "Periodo"
            , "Supervisor"
            , COUNT(DISTINCT "Concentrado") AS "Concentrado"
            , COUNT(DISTINCT "UvaIntegral") AS "UvaIntegral"
            , COUNT(DISTINCT "BelaDaFruta") AS "BelaDaFruta"
        FROM (
            SELECT 
                CAST("Data Inicio Previsto" AS DATE) AS "DataInicioPrevisto",
                CAST("Qtd Supervisor" AS TEXT) AS "QtdSupervisor",
                CAST("Supervisor" AS TEXT) AS "Supervisor",
                CAST("Concentrado" AS TEXT) AS "Concentrado",
                CAST("UvaIntegral" AS TEXT) AS "UvaIntegral",
                CAST("BelaDaFruta" AS TEXT) AS "BelaDaFruta",
                CONCAT(CAST("Concentrado" AS TEXT), CAST("BelaDaFruta" AS TEXT), CAST("UvaIntegral" AS TEXT)) AS "index"
            FROM "britivc"."fat_britivc_PontoExtra"
        ) x
        WHERE "index" <> ''
        GROUP BY 1,2
), dbout_auditoria AS (
    SELECT 
	    DATE_TRUNC('MONTH', CAST("Periodo" AS DATE))::DATE AS "Periodo",
	    CAST("Supervisor" AS TEXT) AS "Supervisor",
	
	    COUNT(DISTINCT CASE WHEN CAST("Situacao Tarefa" AS TEXT) != 'CANCELADA' THEN CAST("Qtd Tarefas" AS TEXT) ELSE NULL END) AS "Qtd Reprovadas",
	    --CAST("Situacao Tarefa" AS TEXT) AS "SituacaoTarefa",

        COUNT(DISTINCT CASE WHEN CAST("Situação Revisitada" AS TEXT) != 'CANCELADA' THEN CAST("Qtd Tarefas Revisitadas" AS TEXT) ELSE NULL END) AS "QtdTarefasRevisitadas"
	    --CAST("Situação Revisitada" AS TEXT) AS "SituacaoRevisitada"
    FROM "britivc"."fat_britivc_AuditoriadosSupervisores"
    GROUP BY 1,2
) 
SELECT 
	CAST(mts."Atividade" AS TEXT) AS "Atividade",
	CAST(mts."Unidade_De_Medida_Meta" AS TEXT) AS "UnidadeDeMedidaMeta",
	CAST(mts."Supervisor" AS TEXT) AS "Supervisor",
	CAST(mts."ID_Supervisor" AS TEXT) AS "IDSupervisor",
	CAST(mts."Periodo" AS DATE) AS "Periodo",
	CAST(mts."Categoria" AS TEXT) AS "Categoria",
	CASE WHEN CAST(mts."Unidade_De_Medida_Meta" AS TEXT) = 'PORCENTAGEM' THEN CAST(mts."Meta" AS DOUBLE PRECISION)/100 ELSE CAST(mts."Meta" AS DOUBLE PRECISION) END AS "Meta",
	CASE WHEN CAST(mts."Atividade" AS TEXT) = 'VISITA' THEN dvf."Roteiro" 
        WHEN CAST(mts."Atividade" AS TEXT) = 'RUPTURA' AND CAST(mts."Categoria" AS TEXT) = 'BELA ISCHIA' THEN drf."Ruptura Bela Ischia"
        WHEN CAST(mts."Atividade" AS TEXT) = 'RUPTURA' AND CAST(mts."Categoria" AS TEXT) = 'DAFRUTA' THEN drf."Ruptura DaFruta"
        WHEN CAST(mts."Atividade" AS TEXT) = 'RUPTURA' AND CAST(mts."Categoria" AS TEXT) = 'UVA INTEGRAL' THEN drf."Ruptura Uva Integral"
        WHEN CAST(mts."Atividade" AS TEXT) = 'PONTO EXTRA' AND CAST(mts."Categoria" AS TEXT) = 'CONCENTRADO' THEN dpe."Concentrado"
        WHEN CAST(mts."Atividade" AS TEXT) = 'PONTO EXTRA' AND CAST(mts."Categoria" AS TEXT) = 'BELA ISCHIA E DAFRUTA' THEN dpe."BelaDaFruta"
        WHEN CAST(mts."Atividade" AS TEXT) = 'PONTO EXTRA' AND CAST(mts."Categoria" AS TEXT) = 'UVA INTEGRAL' THEN dpe."UvaIntegral"
        WHEN CAST(mts."Atividade" AS TEXT) = 'TRADE FORCE' THEN aud."Qtd Reprovadas"
        ELSE NULL 
    END AS "Realizado",
    CAST(mts."Vlr_Peso" AS DOUBLE PRECISION) AS "VlrPeso",
	CAST(mts."Peso_Perc" AS DOUBLE PRECISION) AS "PesoPerc" 
FROM "britivc"."fat_britivc_Metas" mts 
LEFT JOIN dbout_visitas_final   dvf ON (CAST(mts."Periodo" AS DATE) = dvf."Periodo" AND CAST(mts."Supervisor" AS TEXT) = dvf."Supervisor")
LEFT JOIN dbout_rupturas_final  drf ON (CAST(mts."Periodo" AS DATE) = drf."Periodo" AND CAST(mts."Supervisor" AS TEXT) = drf."Supervisor")
LEFT JOIN dbout_pontos_extras   dpe ON (CAST(mts."Periodo" AS DATE) = dpe."Periodo" AND CAST(mts."Supervisor" AS TEXT) = dpe."Supervisor")
LEFT JOIN dbout_auditoria       aud ON (CAST(mts."Periodo" AS DATE) = aud."Periodo" AND CAST(mts."Supervisor" AS TEXT) = aud."Supervisor")