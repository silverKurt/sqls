WITH itens_do_portfolio AS (
    SELECT DISTINCT Elemento AS cd_material, Tb_preco, Pr_Unitario FROM GEPRECTA
    WHERE RTRIM(LTRIM(Tb_preco)) IN ('YOI204', 'YOI800')
), ocs AS (
    SELECT 
    	"Periodo Programado"
    	, "Cd_material" AS "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , SUM("Quantidade OC") AS "Quantidade OC"
    FROM (
    SELECT  
    	CAST(DATEADD(mm, DATEDIFF(mm, 0, pc.Dt_prazo_de_ent), 0) AS DATE) as "Periodo Programado"
        , pc.cd_material AS "Cd_material"
        , LTRIM(RTRIM(b.descricao)) AS "Descricao Material"
        , LTRIM(RTRIM(b.referencia)) AS "Referencia"
        
        , (SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1',SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = pc.Cd_Especif1   
                AND i.Sequencial = 1) AS "Cor"
        
        , (CASE WHEN b.Cd_origem_merca = 1 THEN 'Importado' 
                WHEN b.Cd_origem_merca = 5 OR b.Cd_origem_merca = 0 THEN 'Nacional' 
        END) AS "Origem Produto"
        
        , (CASE WHEN b.Cd_unidade_nego = 1 THEN 'OU'
                WHEN b.Cd_unidade_nego = 2 THEN 'YOI'
                else NULL 
        END) AS "Unidade de Negócio"
        , pre.Tb_preco AS "Tabela de Preço"
        , pre.Pr_Unitario AS "Preço da Tabela"
        , pc.Quantidade AS "Quantidade OC"
    FROM COIORDEM pc (NOLOCK) 
    LEFT  JOIN ESMATERI b (nolock) ON (pc.Cd_material = b.Cd_material and pc.Cd_unidade_de_n = b.Cd_unidade_nego)
    LEFT  JOIN GEPRECTA pre (nolock)  ON (pre.Elemento = b.Cd_material)
    WHERE pc.situacao in ('A','P')
    AND pc.cd_material <> ''
    AND RTRIM(LTRIM(pre.Tb_preco)) IN ('YOI204', 'YOI800')
    ) X
    GROUP BY "Periodo Programado" 
    	, "Cd_material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
), pedidos AS (

    SELECT 
        "Periodo Programado"
        , "Cd_material" AS "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , SUM("Quantidade") AS "Quantidade"
    FROM (
        SELECT 
            CAST(DATEADD(mm, DATEDIFF(mm, 0, p.Dt_prazo_progra), 0) AS DATE) AS "Periodo Programado"

            , b.Cd_material AS "Cd_material"
      		, LTRIM(RTRIM(b.descricao)) AS "Descricao Material"
        	, LTRIM(RTRIM(b.referencia)) AS "Referencia"
        
        	, (SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1',SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = ia.cd_especif1   
                AND i.Sequencial = 1) AS "Cor"
        
        	, (CASE WHEN b.Cd_origem_merca = 1 THEN 'Importado' 
                	WHEN b.Cd_origem_merca = 5 OR b.Cd_origem_merca = 0 THEN 'Nacional' 
        	END) AS "Origem Produto"
        
        	, (CASE WHEN b.Cd_unidade_nego = 1 THEN 'OU'
                	WHEN b.Cd_unidade_nego = 2 THEN 'YOI'
                	else NULL 
        	END) AS "Unidade de Negócio"
        	, ia.Pr_tabela AS "Tabela de Preço"
        	, ia.Pr_Unitario AS "Preço da Tabela"
            , ia.quantidade as "Quantidade"

        FROM CGVW_FAPEDIDOS p (nolock)
        INNER JOIN FAITEMPE ia (nolock)    ON (p.cd_pedido = ia.cd_pedido and p.cd_unid_de_neg =  ia.cd_unid_de_neg)
        LEFT  JOIN ESMATERI b (nolock)    ON (b.Cd_material = ia.Cd_material)
        --LEFT  JOIN GEPRECTA pre (nolock)  ON (pre.Elemento = ia.Cd_material AND pre.Tb_preco = ia.Pr_tabela)
        WHERE ia.cd_especie = 'R' 
        AND p.Dt_prazo_progra >= dateadd(m, datediff(m, 0, DATEADD(month , -12 , getdate())), 0)
        AND p.Controle = 26
        AND RTRIM(LTRIM(ia.Pr_tabela)) IN ('YOI204', 'YOI800')
    ) X
    GROUP BY "Periodo Programado"
        , "Cd_material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        
), estoque AS (
    SELECT 
        CAST(DATEADD(mm, DATEDIFF(mm, 0, getdate()), 0) AS DATE) AS "Periodo Programado"
        , a.cd_material AS "Cod Material"
        , LTRIM(RTRIM(b.descricao)) AS "Descricao Material"
        , LTRIM(RTRIM(b.referencia)) AS "Referencia"
        
        , (SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1',SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = a.Cd_Especif1   
                AND i.Sequencial = 1) AS "Cor"
        
        , (CASE WHEN b.Cd_origem_merca = 1 THEN 'Importado' 
                WHEN b.Cd_origem_merca = 5 OR b.Cd_origem_merca = 0 THEN 'Nacional' 
        END) AS "Origem Produto"
        
        , (CASE WHEN b.Cd_unidade_nego = 1 THEN 'OU'
                WHEN b.Cd_unidade_nego = 2 THEN 'YOI'
                else NULL 
        END) AS "Unidade de Negócio"
        , ip.Tb_preco AS "Tabela de Preço"
        , ip.Pr_Unitario AS "Preço da Tabela"
        , a.quantidade AS "Quantidade Estoque"

    FROM  esestoqu a (nolock)
    LEFT  JOIN ESMATERI b (nolock) ON (a.Cd_material = b.Cd_material and a.Cd_unidade_de_n = b.Cd_unidade_nego)
    INNER JOIN itens_do_portfolio ip ON (ip.cd_material = a.cd_material)
    WHERE a.cd_centro_armaz = '400'
    AND LTRIM(RTRIM(b.descricao)) <> ''
), demanda AS (
    SELECT
        "Periodo Programado"
        , "cd_material" AS "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , SUM("Demanda Pedido") AS "Demanda Pedido"
    FROM (
    SELECT DISTINCT
        CAST(DATEADD(mm, DATEDIFF(mm, 0, a.dt_programada), 0) AS DATE) AS 'Periodo Programado',
        a.cd_material AS "cd_material",
        ltrim(rtrim(b.descricao)) AS 'Descricao Material',
        ltrim(rtrim(b.referencia)) AS 'Referencia',
        (SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
            FROM ppident i(nolock)
            WHERE i.identificador = a.Especif1
            AND i.Sequencial = 1 ) AS 'Cor',
        
        (CASE WHEN b.Cd_origem_merca = 1 THEN 'Importado' 
              WHEN b.Cd_origem_merca = 5 OR b.Cd_origem_merca = 0 THEN 'Nacional' 
        END) AS "Origem Produto",

        (CASE WHEN a.Uni_neg = 1 THEN 'OU'
              WHEN  a.Uni_neg = 2 THEN 'YOI'
              ELSE NULL 
        END) AS "Unidade de Negócio", 
        
        ip.Tb_preco AS "Tabela de Preço",
        ip.Pr_Unitario AS "Preço da Tabela",

        a.qt_saldo AS 'Demanda Pedido'

    FROM ESDEMAND a (nolock)
    LEFT JOIN ESMATERI b(nolock) ON (b.cd_material = a.cd_material)
    INNER JOIN itens_do_portfolio ip ON (ip.cd_material = a.cd_material)
    WHERE a.dt_programada >= dateadd(m, datediff(m, 0, DATEADD(month , -12 , getdate())), 0) and a.tipo IN ('CP','DP','DDP','OPL','DCP')
    ) X
    GROUP BY "Periodo Programado"
        , "cd_material" 
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
)
    SELECT 
        "Periodo Programado"
        , "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , NULL AS "Demanda Pedido"
        , NULL AS "Quantidade Pedidos"
        , NULL AS "Quantidade OC"
        , "Quantidade Estoque"
    FROM estoque

    UNION ALL
    
    SELECT 
        "Periodo Programado"
        , "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , "Demanda Pedido"
        , NULL AS "Quantidade Pedidos"
        , NULL AS "Quantidade OC"
        , NULL AS "Quantidade Estoque"
    FROM demanda

    UNION ALL

    SELECT 
        "Periodo Programado"
        , "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , NULL AS "Demanda Pedido"
        , NULL AS "Quantidade Pedidos"
        , "Quantidade OC" AS "Quantidade OC"
        , NULL AS "Quantidade Estoque"
    FROM ocs

    UNION ALL

    SELECT 
        "Periodo Programado"
        , "Cod Material"
        , "Descricao Material"
        , "Referencia"
        , "Cor"
        , "Origem Produto"
        , "Unidade de Negócio"
        , "Tabela de Preço"
        , "Preço da Tabela"
        , NULL AS "Demanda Pedido"
        , "Quantidade" AS "Quantidade Pedidos"
        , NULL AS "Quantidade OC"
        , NULL AS "Quantidade Estoque"
    FROM pedidos