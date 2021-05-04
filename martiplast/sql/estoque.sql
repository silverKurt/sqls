;WITH periodos as
(SELECT DISTINCT CONVERT(DATE,CONCAT(YEAR(a.Dt_movimento),'-',MONTH(a.Dt_movimento),'-01')) as "anomes"
  FROM ESMOVIME a (nolock) WHERE a.Dt_movimento >= CAST(DATEADD(dd, -DAY(GETDATE())+1, GETDATE()) AS DATE)
)

, produtos_ativos as (
  
  select distinct
       es.Cd_material as 'Cod Material',
       es.Cd_especif1 as 'Cod Cor'
from  ESESTOQU es(nolock)
inner join ESMATERI ma (nolock) ON es.Cd_material = ma.Cd_material
inner join PPCACONF conf (nolock) ON ma.Campo82 = conf.Configurador
inner join PPCCARAC ca (nolock) ON conf.Cd_caract = ca.Cd_caract
where ca.Ativo = '1' and ma.Tipo = 'A'
  
)
  

, estoque AS 
(SELECT DISTINCT
        
        (SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1',SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = a.Cd_Especif1   
                AND i.Sequencial = 1) AS "Cor"

        , LTRIM(RTRIM(b.referencia)) AS "Referencia"
        , LTRIM(RTRIM(b.descricao)) AS "Descricao Material"
        , LTRIM(RTRIM(a.cd_material)) AS "Cod Material"
        
        , CONCAT(LTRIM(RTRIM(b.referencia)), '-', LTRIM(RTRIM(b.descricao)),'-', (
                SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1', SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = a.Cd_Especif1   
                AND i.Sequencial = 1)        
        ) AS "Referencia Completa"

        , CONCAT(LTRIM(RTRIM(a.cd_material))
                , ' - '
                , LTRIM(RTRIM(b.descricao))
                , ' - '
                , (SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1',SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = a.Cd_Especif1   
                AND i.Sequencial = 1)
        ) AS "Material"
        
        , SUBSTRING(TRIM(';' FROM SUBSTRING(k.cd_carac,1,CHARINDEX(';',k.Cd_Carac,2))), 4, LEN(SUBSTRING(k.cd_carac,1,CHARINDEX(';',k.Cd_Carac,2)))) as "Cor Abre"
        
        , b.Cd_unidade_medi as "Unid. Medida"
        
        , CONCAT(LTRIM(RTRIM(b.codigo_fabrica))
                , '-'
                , LTRIM(RTRIM(b.descricao))
                , ' - '
                , (SELECT LTRIM(dbo.cg_fc_monta_descr_ident(':1',SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
                FROM    ppident i(nolock)
                WHERE   i.identificador = a.Cd_Especif1   
                AND i.Sequencial = 1)
        ) AS "Fabrica"
         
        , a.quantidade AS "Quantidade Estoque"
        , CONCAT(b.Cd_grupo, ' - ', j.descricao) AS 'Grupo Material'
        , CONCAT(b.Cd_sub_grupo, ' - ', i.descricao) AS 'SubGrupo Material'
        , a.Cd_centro_armaz AS 'Centro de Armazenagem'
        , car.campo31 as "Centro Valido Planejamento"
        , b.tipo AS 'Tipo'
        --, b.cd_origem_merca AS "Origem Produto"
        , CONCAT(b.cd_fabricante, ' - ', LTRIM(RTRIM(f.nome_completo))) AS "Fabricante"
        , a.cd_material
        , cx.Campo27 as "Qtde Cx Master"
        , pl.lote_minimo as "Lote Minimo"
        , pl.estoque_segura as "Estoque Segurança"
        , a.Cd_Especif1 as "Cod Especifico"
        , CASE 
            WHEN tg805.Cd_tg IS NOT NULL OR tg805.Cd_tg = '' THEN 'MONTAGEM ESTOQUE'
            WHEN tg705.Cd_tg IS NOT NULL OR tg705.Cd_tg = '' THEN 'MONTAGEM DEMANDA'
            WHEN tg605.Cd_tg IS NOT NULL OR tg605.Cd_tg = '' THEN 'TERCEIROS'
            WHEN tg701.Cd_tg IS NOT NULL OR tg701.Cd_tg = '' THEN 'METALIZADOS'
            WHEN tg702.Cd_tg IS NOT NULL OR tg702.Cd_tg = '' THEN 'INJETADO - INATIVOS'
            WHEN tg821.Cd_tg IS NOT NULL OR tg821.Cd_tg = '' THEN 'PLASTIZZA'
            WHEN tg950.Cd_tg IS NOT NULL OR tg950.Cd_tg = '' THEN 'INJETADO - COMPONENTE DE ESTOQUE'
            ELSE 'INJETADO' 
          END AS "Tipo de Produção"
        ,(CASE WHEN  b.Cd_unidade_nego = 1 THEN 'OU'
                   WHEN  b.Cd_unidade_nego = 2 THEN 'YOI'
                   else NULL end ) as "Unidade de Negócio"
        ,(CASE WHEN  b.Cd_unidade_nego = 1 THEN 'OU'
                   WHEN  b.Cd_unidade_nego = 2 THEN 'YOI'
                   else NULL end ) as "Unidade de Negócio Filtro"
        , (CASE 
            WHEN b.Cd_origem_merca = 1 
              THEN 'Importado' 
            WHEN b.Cd_origem_merca = 5 OR b.Cd_origem_merca = 0
              THEN 'Nacional' 
        END) AS "Origem Produto"

        , b.Codigo_fabrica                                    AS 'Código da Fábrica'

        , CONCAT((CASE WHEN LTRIM(RTRIM(g.subgrupo_produto)) IS NULL OR LTRIM(RTRIM(g.subgrupo_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(g.subgrupo_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tsgp.descicao))) IS NULL OR UPPER(LTRIM(RTRIM(tsgp.descicao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tsgp.descicao))) END)) AS "Sub Grupo Produto"
        , CONCAT((CASE WHEN LTRIM(RTRIM(g.linha_produto)) IS NULL OR LTRIM(RTRIM(g.linha_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(g.linha_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tlp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(tlp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tlp.descricao))) END)) AS "Linha Produto"  

FROM  esestoqu a (nolock)
LEFT JOIN PPIDENT k (nolock) ON a.Cd_especif1 = k.Identificador
LEFT  JOIN ESMATERI b (nolock) ON (a.Cd_material = b.Cd_material and a.Cd_unidade_de_n = b.Cd_unidade_nego)
LEFT  JOIN temateriallinha g (nolock) ON (g.material = a.Cd_material)
LEFT  JOIN ESSUBGRU i (nolock) ON (i.Cd_grupo = b.Cd_grupo AND b.Cd_sub_grupo = i.Cd_sub_grupo)
LEFT  JOIN ESGRUPO j (nolock) ON (j.Cd_grupo = b.Cd_grupo)
LEFT  JOIN GEEMPRES f (nolock) ON (f.Cd_empresa = b.Cd_fabricante)
LEFT  JOIN ESPARPLA cx (nolock) ON (cx.Cd_material = b.Cd_material and cx.Uni_neg = a.Cd_unidade_de_n and cx.Tipo = 'C' and cx.Ordem = '9999')
LEFT  JOIN ESPARPLA pl (nolock) ON (pl.Cd_material = b.Cd_material and a.Cd_Especif1 = pl.Especif1 and pl.Uni_neg = a.Cd_unidade_de_n and pl.Tipo = 'P')
LEFT  JOIN ESCARMAZ car (nolock) ON (a.Cd_centro_armaz = car.Cd_centro_armaz)
LEFT JOIN geelemen   tg805(nolock) ON (a.Cd_material = tg805.Elemento and tg805.Cd_tg = 805)
LEFT JOIN geelemen   tg705(nolock) ON (a.Cd_material = tg705.Elemento and tg705.Cd_tg = 705)
LEFT JOIN geelemen   tg605(nolock) ON (a.Cd_material = tg605.Elemento and tg605.Cd_tg = 605)
LEFT JOIN geelemen   tg701(nolock) ON (a.Cd_material = tg701.Elemento and tg701.Cd_tg = 701)
LEFT JOIN geelemen   tg821(nolock) ON (a.Cd_material = tg821.Elemento and tg821.Cd_tg = 821)
LEFT JOIN ESCMXTG    tg702(nolock) ON (a.Cd_material = tg702.Cd_material and (SELECT replace(SUBSTRING(SUBSTRING(i.cd_carac, CHARINDEX(SUBSTRING(SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),2,3), i.cd_carac)+3,  LEN(i.Cd_Carac)),1, CHARINDEX(';',SUBSTRING(i.cd_carac, CHARINDEX(SUBSTRING(SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),2,3), i.cd_carac)+3,  LEN(i.Cd_Carac)))),';','') FROM ppident i(nolock) WHERE i.identificador = a.Cd_Especif1 AND i.Sequencial = 1) = tg702.Conteudo 
                                       AND (SELECT SUBSTRING(SUBSTRING(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),2,3)
                                            FROM    ppident i(nolock)
                                            WHERE   i.identificador = a.Cd_Especif1 AND i.Sequencial = 1) = tg702.Caracteristica and tg702.Cd_tg = 702)
LEFT JOIN geelemen   tg950(nolock) ON (a.Cd_material = tg950.Elemento and tg950.Cd_tg = 950)

LEFT  JOIN tesubgrupoproduto tsgp (nolock) ON (tsgp.nome_subgrupo = g.subgrupo_produto)
LEFT  JOIN telinhaproduto tlp (nolock)     ON (tlp.linha = g.linha_produto)

 
)

SELECT 
        * 
FROM estoque 
INNER JOIN periodos on 1=1
WHERE estoque.cd_material IN (SELECT "Cod Material" FROM produtos_ativos)