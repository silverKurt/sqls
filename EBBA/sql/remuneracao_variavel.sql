-- Source: Visitas
SELECT 
    CAST("Periodo" AS DATE) AS "Periodo",
    CAST("Qtd Supervisor" AS TEXT) AS "QtdSupervisor",
    CAST("Supervisor" AS TEXT) AS "Supervisor",
    CAST("Qtd Tarefas" AS TEXT) AS "QtdPromotor",
    CASE WHEN CAST("status_entrada" AS TEXT) = 'OK' THEN 'REALIZADA'
         ELSE 'NÃO REALIZADA'
    END AS "Status da Tarefa"
FROM "britivc"."fat_britivc_Visitas"
ORDER BY 1 DESC, 2


-- Source: Ruptura Diária
SELECT 
    CAST("Data Inicio Previsto" AS DATE) AS "DataInicioPrevisto",
    CAST("Qtd Supervisor" AS TEXT) AS "QtdSupervisor",
    CAST("Supervisor" AS TEXT) AS "Supervisor",
    CASE WHEN 
        CAST("QtdFamílias" AS TEXT) = 'BELA ISCHIA' AND (CAST("QtdCategorias" AS TEXT) = 'MARACUJA' OR CAST("QtdCategorias" AS TEXT) = 'CAJU') THEN CAST("tsk_id" AS TEXT)
        ELSE NULL
    END AS "Ruptura Bela Ischia",
    CASE WHEN 
        CAST("QtdFamílias" AS TEXT) = 'DAFRUTA (DF)' AND (CAST("QtdCategorias" AS TEXT) = 'MARACUJA' OR CAST("QtdCategorias" AS TEXT) = 'CAJU') THEN CAST("tsk_id" AS TEXT)
        ELSE NULL
    END AS "Ruptura DaFruta",
    CASE WHEN CAST("Grupo de Produto" AS TEXT) = 'UVA INTEGRAL' THEN CAST("tsk_id" AS TEXT)
         ELSE NULL
    END AS "Ruptura Uva Integral"
FROM "britivc"."fat_britivc_RupturaDiaria"


-- Source: Ponto Extra
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


-- Source: Auditoria dos Supervisores
SELECT 
	DATE_TRUNC('MONTH', CAST("Periodo" AS DATE))::DATE AS "Periodo",
	CAST("Supervisor" AS TEXT) AS "Supervisor",
	
	COUNT(DISTINCT CASE WHEN CAST("Situacao Tarefa" AS TEXT) != 'CANCELADA' THEN CAST("Qtd Tarefas" AS TEXT) ELSE NULL END) AS "Qtd Reprovadas",
	--CAST("Situacao Tarefa" AS TEXT) AS "SituacaoTarefa",

    COUNT(DISTINCT CASE WHEN CAST("Situação Revisitada" AS TEXT) != 'CANCELADA' THEN CAST("Qtd Tarefas Revisitadas" AS TEXT) ELSE NULL END) AS "QtdTarefasRevisitadas"
	--CAST("Situação Revisitada" AS TEXT) AS "SituacaoRevisitada"
FROM "britivc"."fat_britivc_AuditoriadosSupervisores"
GROUP BY 1,2