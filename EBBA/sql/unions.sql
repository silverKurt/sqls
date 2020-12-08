WITH dbout_pontos_extras AS (
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
)