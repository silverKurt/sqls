SELECT 
    TO_DATE(('01' || '-' || dd.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO",
    TO_DATE(('01' || '-' || dd.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO_ANALITICO",
    dmemp.id_external AS "COD_EMPRESA",
    dmemp.name AS "DESC_EMPRESA",
    (dmemp.id_external||' '||dmemp.name) AS "EMPRESA",
    a.code_account AS "CONTA_CTB",
    ed.id_external AS "COD_CENTRO_DE_CUSTO", 
    COALESCE(ed.id_external ||' '||  ed.name , 'GERAL') AS "CENTRO_DE_CUSTO",
    (SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Nivel1",
    (SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Estrutural_Nivel1",
    (SELECT name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Descricao_Nivel1",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural || ' ' || a.name ) AS "Nivel2",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural) AS "Estrutural_Nivel2",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.name ) AS "Descricao_Nivel2",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural || ' ' || a.name) AS "Nivel3",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural) AS "Estrutural_Nivel3",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.name) AS "Descricao_Nivel3",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural || ' ' || a.name) AS "Nivel4",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural) AS "Estrutural_Nivel4",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.name) AS "Descricao_Nivel4",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural || ' ' || a.name) AS "Nivel5",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural) AS "Estrutural_Nivel5",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.name) AS "Descricao_Nivel5",

    null::numeric AS "HISTORICO",
    dd.value AS "ORCADO",
    null::numeric AS "REALIZADO",
    b.name as "ORCAMENTO",
    f.name as "FORMULARIO",
    CASE WHEN df.id_responsible IS NOT NULL THEN ua.name ELSE g.name END as "RESPONSAVEL"

FROM dre_data dd
INNER JOIN account a ON (dd.id_account = a.id)
LEFT JOIN form f ON (a.id_form = f.id)
INNER JOIN load_dre ld ON (dd.id_load_dre = ld.id)
LEFT JOIN execute_dimensiON ed ON (ld.id_execute_dimensiON = ed.id)
INNER JOIN dre d ON (ld.id_dre = d.id)
LEFT JOIN dre_form df ON (d.id = df.id_dre and f.id = df.id_form)
LEFT JOIN user_account ua ON (df.id_responsible = ua.id)
LEFT JOIN groups g ON (df.id_groups = g.id)
INNER JOIN budget b ON (d.id_budget = b.id) 
INNER JOIN dimensiON_member dm ON (ed.id = dm.id_execute_dimensiON)
INNER JOIN dimensiON_member dmemp ON (dm.id_parent = dmemp.id)
WHERE 
    ld.id_user IS NULL AND b.id <> 13 and
    a.code_account <> '-' AND (a.type_account <> 'SINTETICA' or a.structural in ('06','07','10','19','21', '39', '40', '45','52','54', '57', '64')) AND (dd.value is not null AND dd.value <> 0) 
UNION ALL (
SELECT 
    TO_DATE(('01' || '-' || ac.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO",
    TO_DATE(('01' || '-' || ac.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO_ANALITICO",
    dmemp.id_external AS "COD_EMPRESA",
    dmemp.name AS "DESC_EMPRESA",
    (dmemp.id_external||' '||dmemp.name) AS "EMPRESA",
    a.code_account AS "CONTA_CTB",
    ed.id_external AS "COD_CENTRO_DE_CUSTO", 
    COALESCE(ed.id_external ||' '||  ed.name , 'GERAL')AS "CENTRO_DE_CUSTO",
    (SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Nivel1",
    (SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Estrutural_Nivel1",
    (SELECT name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Descricao_Nivel1",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural || ' ' || a.name ) AS "Nivel2",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural) AS "Estrutural_Nivel2",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.name ) AS "Descricao_Nivel2",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural || ' ' || a.name) AS "Nivel3",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural) AS "Estrutural_Nivel3",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.name) AS "Descricao_Nivel3",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural || ' ' || a.name) AS "Nivel4",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural) AS "Estrutural_Nivel4",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.name) AS "Descricao_Nivel4",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural || ' ' || a.name) AS "Nivel5",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural) AS "Estrutural_Nivel5",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.name) AS "Descricao_Nivel5",

    (select (CASE WHEN ac.historic = true
    then 
        ac.value*-1 
        else null END))
    AS "HISTORICO",
    null::numeric AS "ORCADO",
    (select (CASE WHEN ac.historic = false
    then 
        ac.value*-1     
        else null END))
    AS "REALIZADO",
    b.name as "ORCAMENTO",
    f.name as "FORMULARIO",
    CASE WHEN df.id_responsible IS NOT NULL THEN ua.name ELSE g.name END as "RESPONSAVEL"
        
        
FROM accomplished_dre ac
INNER JOIN account a ON (ac.id_account = a.id)
LEFT JOIN form f ON (a.id_form = f.id)
LEFT JOIN execute_dimensiON ed ON (ac.id_execute_dimensiON = ed.id)
INNER JOIN budget b ON (ac.id_budget = b.id) 
INNER JOIN dre d ON (d.id_budget = b.id)
LEFT JOIN dre_form df ON (d.id = df.id_dre and f.id = df.id_form)
LEFT JOIN user_account ua ON (df.id_responsible = ua.id)
LEFT JOIN groups g ON (df.id_groups = g.id)
INNER JOIN dimensiON_member dm ON (ed.id = dm.id_execute_dimensiON)
INNER JOIN dimensiON_member dmemp ON (dm.id_parent = dmemp.id)
    
WHERE b.id <> 13 and
    (a.type_account <> 'SINTETICA' or a.structural in ('06','07','10','19','21', '39', '40', '45', '52', '54', '57', '64')) and a.code_account <> '-' and ed.id_external <> '1.-' and ac.value <> 0
    )
UNION ALL (
SELECT 
    TO_DATE(('01' || '-' || dd.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO",
    TO_DATE(('01' || '-' || dd.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO_ANALITICO",
    dmemp.id_external AS "COD_EMPRESA",
    dmemp.name AS "DESC_EMPRESA",
    (dmemp.id_external||' '||dmemp.name) AS "EMPRESA",
    a.code_account AS "CONTA_CTB",
    ed.id_external AS "COD_CENTRO_DE_CUSTO", 
    COALESCE(ed.id_external ||' '||  ed.name , 'GERAL') AS "CENTRO_DE_CUSTO",
    (SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Nivel1",
    (SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Estrutural_Nivel1",
    (SELECT name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Descricao_Nivel1",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural || ' ' || a.name ) AS "Nivel2",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural) AS "Estrutural_Nivel2",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.name ) AS "Descricao_Nivel2",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural || ' ' || a.name) AS "Nivel3",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural) AS "Estrutural_Nivel3",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.name) AS "Descricao_Nivel3",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural || ' ' || a.name) AS "Nivel4",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural) AS "Estrutural_Nivel4",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.name) AS "Descricao_Nivel4",

    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural || ' ' || a.name) AS "Nivel5",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural) AS "Estrutural_Nivel5",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.name) AS "Descricao_Nivel5",

    null::numeric AS "HISTORICO",
    dd.value AS "ORCADO",
    null::numeric AS "REALIZADO",
    b.name as "ORCAMENTO",
    f.name as "FORMULARIO",
    CASE WHEN df.id_responsible IS NOT NULL THEN ua.name ELSE g.name END as "RESPONSAVEL"

FROM dre_data dd
INNER JOIN account a ON (dd.id_account = a.id)
LEFT JOIN form f ON (a.id_form = f.id)
INNER JOIN load_dre ld ON (dd.id_load_dre = ld.id)
LEFT JOIN execute_dimensiON ed ON (ld.id_execute_dimensiON = ed.id)
INNER JOIN dre d ON (ld.id_dre = d.id)
LEFT JOIN dre_form df ON (d.id = df.id_dre and f.id = df.id_form)
LEFT JOIN user_account ua ON (df.id_responsible = ua.id)
LEFT JOIN groups g ON (df.id_groups = g.id)
INNER JOIN budget b ON (d.id_budget = b.id) 
INNER JOIN dimensiON_member dm ON (ed.id = dm.id_execute_dimensiON)
INNER JOIN dimensiON_member dmemp ON (dm.id_parent = dmemp.id)
WHERE 
    ld.id_user IS NULL AND b.id = 13 and
    a.code_account <> '-' AND (a.type_account <> 'SINTETICA' or a.structural in ('06','07','10','12','14','34','35','40','47','50','53')) AND (dd.value is not null AND dd.value <> 0) 
    )
UNION ALL (
SELECT 
    TO_DATE(('01' || '-' || ac.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO",
    TO_DATE(('01' || '-' || ac.MONTH|| '-' || b.YEAR),'dd-MM-yyyy') AS "PERIODO_ANALITICO",
    dmemp.id_external AS "COD_EMPRESA",
    dmemp.name AS "DESC_EMPRESA",
    (dmemp.id_external||' '||dmemp.name) AS "EMPRESA",
    a.code_account AS "CONTA_CTB",
    ed.id_external AS "COD_CENTRO_DE_CUSTO", 
    COALESCE(ed.id_external ||' '||  ed.name , 'GERAL')AS "CENTRO_DE_CUSTO",
    (SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Nivel1",
    (SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Estrutural_Nivel1",
    (SELECT name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id) WHERE  di.id = d.id AND  ai.structural = split_part(a.structural, '.', 1)) AS "Descricao_Nivel1",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural || ' ' || a.name ) AS "Nivel2",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.structural) AS "Estrutural_Nivel2",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2))), a.name ) AS "Descricao_Nivel2",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural || ' ' || a.name) AS "Nivel3",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.structural) AS "Estrutural_Nivel3",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3))), a.name) AS "Descricao_Nivel3",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural || ' ' || a.name) AS "Nivel4",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.structural) AS "Estrutural_Nivel4",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4))), a.name) AS "Descricao_Nivel4",
    
    COALESCE((SELECT structural || ' ' || name  FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural || ' ' || a.name) AS "Nivel5",
    COALESCE((SELECT structural FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.structural) AS "Estrutural_Nivel5",
    COALESCE((SELECT name FROM account ai INNER JOIN dre di ON (ai.id_dre = di.id)  WHERE  di.id = d.id AND ai.structural = (split_part(a.structural, '.', 1)||'.'||split_part(a.structural, '.', 2)||'.'||split_part(a.structural, '.', 3)||'.'||split_part(a.structural, '.', 4)||'.'||split_part(a.structural, '.', 5))), a.name) AS "Descricao_Nivel5",

    (select (CASE WHEN ac.historic = true
    then 
        ac.value*-1 
        else null END))
    AS "HISTORICO",
    null::numeric AS "ORCADO",
    (select (CASE WHEN ac.historic = false
    then 
        ac.value*-1     
        else null END))
    AS "REALIZADO",
    b.name as "ORCAMENTO",
    f.name as "FORMULARIO",
    CASE WHEN df.id_responsible IS NOT NULL THEN ua.name ELSE g.name END as "RESPONSAVEL"
        
        
FROM accomplished_dre ac
INNER JOIN account a ON (ac.id_account = a.id)
LEFT JOIN form f ON (a.id_form = f.id)
LEFT JOIN execute_dimensiON ed ON (ac.id_execute_dimensiON = ed.id)
INNER JOIN budget b ON (ac.id_budget = b.id) 
INNER JOIN dre d ON (d.id_budget = b.id)
LEFT JOIN dre_form df ON (d.id = df.id_dre and f.id = df.id_form)
LEFT JOIN user_account ua ON (df.id_responsible = ua.id)
LEFT JOIN groups g ON (df.id_groups = g.id)
INNER JOIN dimensiON_member dm ON (ed.id = dm.id_execute_dimensiON)
INNER JOIN dimensiON_member dmemp ON (dm.id_parent = dmemp.id)
    
WHERE b.id = 13 and
    (a.type_account <> 'SINTETICA' or a.structural in ('06','07','10','12','14','34','35','40','47','50','53')) and a.code_account <> '-' and ed.id_external <> '1.-' and ac.value <> 0
    )