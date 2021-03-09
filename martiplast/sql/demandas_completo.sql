SELECT ltrim(rtrim(b.cd_material)) + ' - ' + ltrim(rtrim(b.descricao)) + COALESCE(' - ' +
        ( SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
         FROM ppident i(nolock)
         WHERE i.identificador = a.Especif1
         AND i.Sequencial = 1 ), ' ')                            AS 'Material',
       ltrim(rtrim(b.referencia))  + ' - ' + b.descricao + COALESCE(' - ' +
        ( SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
         FROM ppident i(nolock)
         WHERE i.identificador = a.Especif1
         AND i.Sequencial = 1 ), ' ')                            AS 'Referencia',
       ( SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
         FROM ppident i(nolock)
         WHERE i.identificador = a.Especif1
         AND i.Sequencial = 1 )                            AS 'Cor',
       substring(TRIM(';' FROM substring(k.cd_carac,1,CHARINDEX(';',k.Cd_Carac,2))), 4, LEN(substring(k.cd_carac,1,CHARINDEX(';',k.Cd_Carac,2)))) as "Cor Abre",
       ltrim(rtrim(b.referencia)) AS 'Referencia sem Cor',
       ltrim(rtrim(b.descricao))						   AS 'Descricao Material',
       a.cd_material                                       AS "Cod Material",
       a.liberacao                                         AS 'Liberação',
       (CASE WHEN a.liberacao != '' THEN 'C/Liberação' else 'S/Liberação' end) AS 'Status Liberacao',
       a.liberacao                                         AS 'Qtde Liberação',
       a.tipo                                              AS 'Tipo Demanda',
       a.dem_geral                                         AS 'Qtde Demanda Geral',
       b.Codigo_fabrica                                    AS 'Código da Fábrica',
       b.Cd_grupo          + ' - ' + j.descricao           AS 'Grupo Material',
       b.Cd_sub_grupo      + ' - ' + i.descricao           AS 'SubGrupo Material',
       e1.cd_empresa       + ' - ' + e1.nome_completo      AS 'Cliente',
       e1.cd_centralizado  + ' - ' + ee1.nome_completo     AS 'Centralizadora',
       c.situacao                                          AS 'Situação Pedido',
       e1.uf                                               AS 'UF Cliente',
       e2.cd_empresa  + ' - ' + e2.nome_completo           AS 'Representante',
       e2.uf                                               AS 'UF Representante',
       e3.cd_empresa  + ' - ' + e3.nome_completo           AS 'Transportadora',
       e3.uf                                               AS 'UF Transportadora',
       dt_programada                                       AS 'Periodo',
       dt_programada                                       AS 'Periodo Filtro',
       Dt_liberacao                                        AS "Periodo Liberacao",
       a.Especif1                                          AS "Especificador",
       (CASE WHEN ((SELECT sum(d.quantidade)
                    FROM ESESTOQU d (nolock)
                    WHERE d.cd_material = a.cd_material AND 
                          d.cd_especif1 = a.especif1) - a.qt_saldo
                   ) < 0 
             THEN 'Indisponivel'
             ELSE 'Disponivel' 
        END)                                               AS 'Status de Disponibilidade',
       a.qt_saldo                                          AS 'Demanda Pedido',
        
       (SELECT SUM(qt_saldo)
        FROM ESDEMAND t (nolock)
        LEFT JOIN FAPEDIDO c1 (nolock) ON (c1.cd_pedido   = t.liberacao)
        WHERE a.cd_material = t.cd_material  AND 
              a.especif1    = t.especif1     AND
              c1.cd_pedido  = t.liberacao    AND
              e1.cd_empresa = c1.cd_cliente AND
              t.tipo = 'CP' AND
              t.dt_programada < CONVERT (date, GETDATE()) )           AS 'Demanda Atrasada', 

       (SELECT SUM(qt_saldo)
        FROM ESDEMAND t (nolock)
        WHERE a.cd_material = t.cd_material  AND 
              a.especif1    = t.especif1     AND
              t.tipo = 'CP')           AS 'Demanda Pedido Global', 
       
       (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock)
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '400')                   AS 'Saldo Estoque',
       (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '500')                   AS 'Saldo Estoque 500',
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '401')                   AS 'Saldo Estoque 401',
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '420')                   AS 'Saldo Estoque 420',
        
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '302')                   AS 'Saldo Estoque 302',
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '600')                   AS 'Saldo Estoque 600',
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '350')                   AS 'Saldo Estoque 350',
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = '620')                   AS 'Saldo Estoque 620',
        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz = 'WMS')                   AS 'Saldo Estoque WMS',

        (SELECT SUM(d.quantidade)
        FROM ESESTOQU d (nolock) 
        WHERE d.cd_material = a.cd_material AND 
              d.cd_especif1 = a.especif1 AND 
              d.cd_centro_armaz IN (SELECT car.cd_centro_armaz FROM ESCARMAZ car (nolock) WHERE car.campo31 = 'true')) AS 'Sld Estoque Validos Planejamento',
              
       ( SELECT (SUM(pc.Quantidade) - SUM(pc.Qt_fabricada)) FROM PCORPROD pc (nolock) 
         WHERE pc.cd_material     = a.cd_material AND 
               pc.especif1     = a.especif1 AND 
               pc.situacao = 'L')                          AS 'Saldo OP',
    CASE 
        WHEN tg702.Cd_tg IS NOT NULL OR tg702.Cd_tg = '' THEN 'INJETADO - INATIVOS'
        WHEN tg805.Cd_tg IS NOT NULL OR tg805.Cd_tg = '' THEN 'MONTAGEM ESTOQUE'
        WHEN tg705.Cd_tg IS NOT NULL OR tg705.Cd_tg = '' THEN 'MONTAGEM DEMANDA'
        WHEN tg605.Cd_tg IS NOT NULL OR tg605.Cd_tg = '' THEN 'TERCEIROS'
        WHEN tg950.Cd_tg IS NOT NULL OR tg950.Cd_tg = '' THEN 'INJETADO - COMPONENTE DE ESTOQUE'
        ELSE 'INJETADO' 
    END AS "Tipo de Produção",
    c.controle                                             AS "Controle",
    (CASE 
      WHEN b.Cd_origem_merca = 1 
        THEN 'Importado' 
      WHEN b.Cd_origem_merca = 5 OR b.Cd_origem_merca = 0
        THEN 'Nacional' 
    END) AS "Origem Produto",

    (CASE WHEN  a.Uni_neg = 1 THEN 'OU'
                   WHEN  a.Uni_neg = 2 THEN 'YOI'
                   else NULL end ) as "Unidade de Negócio" 

    , CONCAT((CASE WHEN LTRIM(RTRIM(g.subgrupo_produto)) IS NULL OR LTRIM(RTRIM(g.subgrupo_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(g.subgrupo_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tsgp.descicao))) IS NULL OR UPPER(LTRIM(RTRIM(tsgp.descicao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tsgp.descicao))) END)) AS "Sub Grupo Produto"
    , CONCAT((CASE WHEN LTRIM(RTRIM(g.linha_produto)) IS NULL OR LTRIM(RTRIM(g.linha_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(g.linha_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tlp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(tlp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tlp.descricao))) END)) AS "Linha Produto"  
    
FROM ESDEMAND        a(nolock)
LEFT JOIN PPIDENT k (nolock) ON a.Especif1 = k.Identificador
LEFT JOIN ESMATERI   b(nolock) ON (b.cd_material = a.cd_material)
LEFT JOIN ESSUBGRU   i(nolock) ON (i.Cd_grupo    = b.Cd_grupo AND b.Cd_sub_grupo = i.Cd_sub_grupo)
LEFT JOIN ESGRUPO    j(nolock) ON (j.Cd_grupo    = b.Cd_grupo)
LEFT JOIN FAPEDIDO   c(nolock) ON (c.cd_pedido   = a.liberacao)
LEFT JOIN GEEMPRES  e1(nolock) ON (e1.cd_empresa = c.cd_cliente)
LEFT JOIN GEEMPRES  e2(nolock) ON (e2.cd_empresa = c.cd_representant)
LEFT JOIN GEEMPRES  e3(nolock) ON (e3.cd_empresa = c.cd_transportado)
LEFT JOIN GEEMPRES ee1(nolock) ON (ee1.cd_empresa = e1.Cd_centralizado)
LEFT JOIN geelemen   tg805(nolock) ON (a.Cd_material = tg805.Elemento and tg805.Cd_tg = 805)
LEFT JOIN geelemen   tg705(nolock) ON (a.Cd_material = tg705.Elemento and tg705.Cd_tg = 705)
LEFT JOIN geelemen   tg605(nolock) ON (a.Cd_material = tg605.Elemento and tg605.Cd_tg = 605)
LEFT JOIN ESCMXTG    tg702(nolock) ON (a.Cd_material = tg702.Cd_material and (SELECT replace(substring(substring(i.cd_carac, CHARINDEX(substring(substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),2,3), i.cd_carac)+3,  LEN(i.Cd_Carac)),1, CHARINDEX(';',substring(i.cd_carac, CHARINDEX(substring(substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),2,3), i.cd_carac)+3,  LEN(i.Cd_Carac)))),';','') FROM ppident i(nolock) WHERE i.identificador = a.Especif1 AND i.Sequencial = 1) = tg702.Conteudo 
                                       AND (SELECT substring(substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),2,3)
                                            FROM    ppident i(nolock)
                                            WHERE   i.identificador = a.Especif1 AND i.Sequencial = 1) = tg702.Caracteristica and tg702.Cd_tg = 702)
LEFT JOIN geelemen   tg950(nolock) ON (a.Cd_material = tg950.Elemento and tg950.Cd_tg = 950)

LEFT  JOIN temateriallinha g (nolock) ON (g.material = a.Cd_material)
LEFT  JOIN tesubgrupoproduto tsgp (nolock) ON (tsgp.nome_subgrupo = g.subgrupo_produto)
LEFT  JOIN telinhaproduto tlp (nolock)     ON (tlp.linha = g.linha_produto)

WHERE a.dt_programada >='01-01-2016' and a.tipo IN ('CP','DP','DDP','OPL','DCP')