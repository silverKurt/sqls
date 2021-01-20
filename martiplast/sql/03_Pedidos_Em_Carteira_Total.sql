/* SQL DO CUBO PEDIDOS EM CARTEIRA */
SELECT
    "Cliente"
    , "Cliente Razão Social"
    , "Divisão"
    , "Agrupamento Cliente"
    , "Cor"
    , "Produto"
    , "Produto" + COALESCE(' - ' + "Cor", '') AS "Produto Completo"
    , "Empresa"
    , "Mercado"
    , "Pedido"
    , "Pedido" as "Pedido Filtro" 
    , "Periodo"
    , "Qtde Dias Programação"
    , "Qtde Dias Prog Comerc"
    , "Periodo Cadastro"
    , "Periodo Cadastro Filtro"
    , "Periodo Faturado"
    , "Periodo Faturado Filtro"
    , "Periodo Liberacao"
    , "Periodo Movimento"
    , "Periodo Entrega"
    , "Periodo Programado"
    , "Periodo Programado Filtro"
    , "Representante"
    , "Representante Carteira"
    , CASE
           WHEN "UF" = 'EX'
           THEN 'EXPORTACAO'
           WHEN (
                    ("Regiao" = null) OR ("Regiao" = '.') or ("Regiao" = '') or ("Representante" = '999998' )
                    /*OR ("Cd Cliente Agrupador" = '002002' OR "Cd Cliente Agrupador" = '001593' OR "Cd Cliente Agrupador" = '001638' AND "Unidade de Negócio" = 'OU')
                    OR ("Cd Cliente Agrupador" = '029368' OR "Cd Cliente Agrupador" = '026207' OR "Cd Cliente Agrupador" = '029024' AND "Unidade de Negócio" = 'YOI')*/
             )
           THEN '* VENDA DIRETA'
           WHEN UPPER("Representante Carteira") = 'NOBRY (000129)' AND "Cd Cliente Agrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
           WHEN UPPER("Representante Carteira") = 'NOBRY (000129)' THEN 'SUL' 
           --WHEN UPPER("Representante Carteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'MA' THEN 'NORDESTE'
           --WHEN UPPER("Representante Carteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'TO' THEN 'NORTE'
           ELSE "Regiao"
    END AS "Regiao"
    , "Transportador"
    , "Transportador Agrupador"
    , "Tipo Faturamento"
    , "Tipo Evento"
    , "Qtde Pedidos"
    , "Vlr Mercadoria"
    , "Indice"
    , "Vlr Mercadoria Original"
    , "Vlr Total Pedido"
    , "Qtde Pecas Pedido"
    , "Situacao"
    , "Qtde Clientes"
    , LTRIM(RTRIM("Atividade")) AS "Atividade"
    , "Controle"
    , "Periodo Cad Cliente"
    , "Feiras"
    , "Tipo Pedido"
    , "Tipo Pedido Completo"
    , "Controle Desc"
    , "Unidade de Negócio"
    , "Ordem de Compra"
    , "Motivo"
    , "Justificativa"
    , "Observação"
    , "Remessa"
    , "Volume"
    , "Quantidade"
    , "Peso Líquido"
    , "Peso Bruto"
    , "Data de Expedicao"
    , "NF"
    , "Qtde Dias Cad e Lib"
FROM
(
SELECT  CONCAT((CASE WHEN (LTRIM(RTRIM(cl.cd_empresa)) = '' OR LTRIM(RTRIM(cl.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl.cd_empresa)) END), ' - ' , (CASE WHEN (UPPER(LTRIM(RTRIM(cl.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl.fantasia))) = '') THEN 'NAO INFORMADO CLIENTE' ELSE (UPPER(LTRIM(RTRIM(cl.fantasia)))) END)) AS "Cliente"
        , CONCAT((CASE WHEN (LTRIM(RTRIM(cl.cd_empresa)) = '' OR LTRIM(RTRIM(cl.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl.cd_empresa)) END), ' - ' , (CASE WHEN (UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '') THEN 'NAO INFORMADO CLIENTE' ELSE (UPPER(LTRIM(RTRIM(cl.Nome_completo)))) END)) AS "Cliente Razão Social"
        , cl.divisao AS "Divisão"
        , CONCAT((CASE WHEN (UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '') THEN 'NAO INFORMADO AGR CLIENTE' ELSE (UPPER(LTRIM(RTRIM(cl2.fantasia)))) END), ' (',(CASE WHEN (LTRIM(RTRIM(cl2.cd_empresa)) = '' OR LTRIM(RTRIM(cl2.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END),')') AS "Agrupamento Cliente"
        , (SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i2.cd_carac,1,CHARINDEX(';',i2.Cd_Carac,2)),0,0,b.campo82,0,' '))
            FROM ppident i2(nolock)
            WHERE i2.identificador = i.cd_especif1
                AND i2.Sequencial = 1
        ) AS "Cor"       
        , CONCAT((CASE WHEN (LTRIM(RTRIM(p.cd_unid_de_neg)) = '' OR LTRIM(RTRIM(p.cd_unid_de_neg)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(p.cd_unid_de_neg)) END), ' - ', (CASE WHEN (UPPER(LTRIM(RTRIM(e.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(e.Nome_completo))) = '') THEN 'NAO INFORMADO EMPRESA' ELSE (UPPER(LTRIM(RTRIM(e.Nome_completo)))) END)) AS "Empresa"
        , (CASE WHEN m2.codigo_estado = 'EX' THEN 'EXTERNO' ELSE 'INTERNO' END) AS "Mercado"    
        , CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) AS "Pedido"
        , CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) AS "Pedido Filtro"        
        , COALESCE(p.Dt_pedido, CAST('1900-01-01' AS DATE)) AS "Periodo"
        , CONCAT((CASE WHEN (RTRIM(LTRIM(b.referencia)) IS NULL OR RTRIM(LTRIM(b.referencia)) = '') THEN '0' ELSE RTRIM(LTRIM(b.referencia)) END), ' - ' ,(CASE WHEN UPPER(LTRIM(RTRIM(b.descricao))) = '' OR UPPER(LTRIM(RTRIM(b.descricao))) IS NULL THEN 'Produto NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(b.descricao))) END)) AS "Produto"
        , (DATEDIFF(day,p.Dt_liberacao,p.Dt_prazo_progra)) AS "Qtde Dias Programação"
        , (DATEDIFF(day,p.Dt_liberacao,p.Dt_faturado)) AS "Qtde Dias Prog Comerc"
        , COALESCE(p.Dt_cadastro, CAST('1900-01-01' AS DATE))     AS "Periodo Cadastro"
        , COALESCE(p.Dt_cadastro, CAST('1900-01-01' AS DATE))     AS "Periodo Cadastro Filtro"
        , COALESCE(p.Dt_faturado, CAST('1900-01-01' AS DATE))     AS "Periodo Faturado"
        , COALESCE(p.Dt_faturado, CAST('1900-01-01' AS DATE))     AS "Periodo Faturado Filtro"
        , COALESCE(p.Dt_liberacao, CAST('1900-01-01' AS DATE))    AS "Periodo Liberacao"
        , COALESCE(p.Dt_movimentacao, CAST('1900-01-01' AS DATE)) AS "Periodo Movimento"
        , COALESCE(p.Dt_prazo_entreg, CAST('1900-01-01' AS DATE)) AS "Periodo Entrega"
        , COALESCE(p.Dt_prazo_progra, CAST('1900-01-01' AS DATE)) AS "Periodo Programado"
        , COALESCE(p.Dt_prazo_progra, CAST('1900-01-01' AS DATE)) AS "Periodo Programado Filtro"     
        , CONCAT((CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO REPRESENTANTE' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END), ' (', (CASE WHEN LTRIM(RTRIM(p.cd_representant)) = '' OR LTRIM(RTRIM(p.cd_representant)) IS NULL THEN '0' ELSE LTRIM(RTRIM(p.cd_representant)) END), ')') AS "Representante"
        , CONCAT(CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO REP CARTEIRA' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')') AS "Representante Carteira"
        , UPPER(LTRIM(RTRIM(re.Descricao))) AS "Regiao"
        , UPPER(LTRIM(RTRIM(cl.uf))) AS "UF"        
        , CONCAT(LTRIM(RTRIM(p.cd_transportado)), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(t.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(t.fantasia))) = '' THEN 'NAO INFORMADO TRANSPORTADOR' ELSE UPPER(LTRIM(RTRIM(t.fantasia))) END)) AS "Transportador"
        , CONCAT(LTRIM(RTRIM(t2.cd_empresa)), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(t2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(t2.fantasia))) = '' THEN 'NAO INFORMADO TRANSPORTADOR' ELSE UPPER(LTRIM(RTRIM(t2.fantasia))) END)) AS "Transportador Agrupador"
        , 'VENDA' AS "Tipo Faturamento"        
        , p.Campo96 AS "Tipo Evento"
        , p.cd_pedido AS "Qtde Pedidos"
        , CAST(i.vl_total_item_l AS real) AS "Vlr Mercadoria Original" --as vlr_liquido_item
        , (SELECT TOP 1 ii.Vl_cotacao_vend FROM GEINDICE ii WHERE ii.cd_indice = p.cd_indice ORDER BY dt_indice DESC) as "Indice"
        , CASE WHEN ltrim(rtrim(p.cd_indice)) != '' and p.cd_indice IS NOT NULL THEN CAST(i.vl_total_item_l AS real)*(SELECT TOP 1 ii.Vl_cotacao_vend FROM GEINDICE ii WHERE ii.cd_indice = p.cd_indice ORDER BY dt_indice DESC) ELSE CAST(i.vl_total_item_l AS real) END AS "Vlr Mercadoria"
        , CAST(((i.vl_total_item_l + i.vl_ipi + ((p.valor_subst_trib)/COALESCE((SELECT CASE WHEN count(*) = 0 THEN NULL ELSE COUNT(*) END FROM FAITEMPE ii (nolock) where ii.cd_pedido = p.cd_pedido AND ii.cd_especie = i.cd_especie),1)))-i.qt_medida1 -(CASE WHEN i.qt_medida1 > 0 THEN (imp.valor_pis+imp.vl_cofins) ELSE 0 END)) AS real) AS "Vlr Total Pedido" --as total_pedido
        , i.quantidade as "Qtde Pecas Pedido"
        , p.situacao AS "Situacao"
        , p.cd_cliente AS "Qtde Clientes"
        , cl.atividade + ' - ' + ve.descricao AS  "Atividade"
        , p.Controle as "Controle"
        , cl.Dt_cadastro AS "Periodo Cad Cliente"
        , b.tempo_recebimen AS "Feiras"
        , p.campo143 AS "Tipo Pedido"
        , CASE WHEN p.campo143 = '1' THEN 'Venda Consumidor Final'
               WHEN p.campo143 = '2' THEN 'Brinde Consumidor Final'
               WHEN p.campo143 = '3' THEN 'Devolução Venda Consumidor Final'
               WHEN p.campo143 = '4' THEN 'Garantia e Troca Consumidor Final'
               WHEN p.campo143 = '7' THEN 'Drawback'
               WHEN p.campo143 = 'B' THEN 'Brinde'
               WHEN p.campo143 = 'G' THEN 'Garantia'
               WHEN p.campo143 = 'K' THEN 'Demonstração'
               WHEN p.campo143 = 'R' THEN 'Remessa'
               WHEN p.campo143 = 'V' THEN 'Venda a Ordem'
               WHEN p.campo143 = 'N' THEN 'Normal'
          ELSE 'NÃO INFORMADO TIPO'  
          END AS "Tipo Pedido Completo"
         , fa.Controle + ' - ' + fa.Descricao as "Controle Desc"
         , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
         , (CASE WHEN  p.cd_unid_de_neg = '1' THEN 'OU'
                   WHEN  p.cd_unid_de_neg = '2' THEN 'YOI'
                   else 'Não Informado UNI' end ) as "Unidade de Negócio"
         , p.cd_ordem_de_com as "Ordem de Compra"
         , CASE (SELECT TOP 1 jus.cd_motivo FROM GFJUSLIB jus (nolock) WHERE p.cd_pedido = jus.Documento_alpha AND p.cd_unid_de_neg = jus.Unidade_negocio AND p.cd_cliente = jus.Empresa ORDER BY jus.Sequencial DESC)
            WHEN 1 THEN 'Liberacao Financeira'
            WHEN 2 THEN 'Liberacao Gestao'
            WHEN 3 THEN 'Liberacao Direcao'
            WHEN 4 THEN 'Liberacao Gestao/Direcao'
          END AS "Motivo"
         , (SELECT TOP 1 jus.Justificativa FROM GFJUSLIB jus (nolock) WHERE p.cd_pedido = jus.Documento_alpha AND p.cd_unid_de_neg = jus.Unidade_negocio AND p.cd_cliente = jus.Empresa ORDER BY jus.Sequencial DESC) as "Justificativa"
         , p.Observacao as "Observação"
         , i.plano_mestre AS "Remessa"
         , cast(coalesce(replace(p.Volume, ',', '.'), '0.0') as float) AS "Volume"
         , CAST(p.Quantidade AS FLOAT) AS "Quantidade"
         , p.Peso_liquido AS "Peso Líquido"
         , p.Peso_bruto AS "Peso Bruto"
         , p.Campo91 AS "Data de Expedicao"
         , CAST(p.Nota_fiscal AS VARCHAR) AS "NF"
         , (DATEDIFF(day,p.Dt_cadastro,p.Dt_liberacao)) AS "Qtde Dias Cad e Lib"
FROM CGVW_FAPEDIDOS p (nolock)
INNER JOIN FAITEMPE i (nolock) ON (p.cd_pedido = i.cd_pedido)
LEFT  JOIN CGVW_FAIMOPED imp (nolock) ON (imp.pedido = i.cd_pedido AND imp.sequencia = i.sequencia)
LEFT  JOIN geempres cl (nolock) ON (p.cd_cliente = cl.cd_empresa)
LEFT  JOIN geempres r2 (nolock)  ON (r2.cd_empresa = cl.cd_representant)
LEFT  JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
LEFT  JOIN geempres cl2 (nolock) ON (cl.Cd_centralizado = cl2.cd_empresa)
LEFT  JOIN geunidne e (nolock) ON (e.Cd_unidade_de_n = p.cd_unid_de_neg)
LEFT  JOIN ESMATERI b (nolock) ON (b.Cd_material = i.Cd_material)
LEFT  JOIN geestado m2(nolock) ON (cl.uf = m2.codigo_estado and m2.Cd_unidade_de_n = p.cd_unid_de_neg)
LEFT  JOIN geempres r(nolock) ON (p.cd_representant = r.cd_empresa)
LEFT  JOIN geempres t(nolock) ON (t.cd_empresa = p.cd_transportado)
LEFT  JOIN geempres t2 (nolock) ON (t.Cd_centralizado = t2.cd_empresa)
LEFT  JOIN VEATIVID ve(nolock) ON (ve.atividade = cl.atividade)
LEFT  JOIN FACONTRO fa(nolock) on (fa.Controle = p.Controle)
LEFT  JOIN GELIBERA mot ON (p.cd_pedido = mot.Doc_Alpha AND p.cd_unid_de_neg = mot.Unidade_de_Negocio AND p.cd_cliente = mot.Empresa)
WHERE i.cd_especie = 'R' 
AND p.controle >= 01 and p.controle <= 50
AND p.Dt_pedido >= DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) - 6, 0)
) a