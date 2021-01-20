SELECT    "Cliente"
        , "Agrupamento Cliente"
        , "Responsavel"
        , "Cor"
        , "Empresa"
        , "Mercado"
        , "Pedido"
        , "Periodo" AS "Periodo"
        , "Periodo" as "Periodo Filtro"
        , "Periodo Cadastro" AS "Periodo Cadastro"
        , "Periodo Cadastro Filtro" AS "Periodo Cadastro Filtro"
        , "Periodo Faturado" AS "Periodo Faturado"
        , "Periodo Faturado Filtro" AS "Periodo Faturado Filtro"
        , "Periodo Liberacao" AS "Periodo Liberacao"
        , "Periodo Movimento" AS "Periodo Movimento"
        , "Periodo Entrega" AS "Periodo Entrega"
        , "Periodo Programado" AS "Periodo Programado"
        , "Periodo Programado" as "Periodo Programado Filtro"
        , "Periodo Cad Cliente" AS "Periodo Cad Cliente"
        , "Produto"
        , "codProduto"
        , "Especificador"
        , "Código da Fábrica"
        , CASE WHEN "Unidade de Negócio" = 'YOI' then "Produto" ELSE "Produto" + ' - ' + "Cor" end AS "Produto Completo"
        , "Produto" + ' - ' + "Cor" AS "Qtde Produtos Completo"
        , "Produto"                 AS "Qtde Mix Produtos YOI"
        , "Catalogo Produto" AS "Catalogo Produto"
        , "Sub Grupo Produto" AS "Sub Grupo Produto"
        , "Linha Produto" AS "Linha Produto"
        , "UF" AS "UF"
        , CASE 
             WHEN "UF" = 'EX' 
             THEN 'EXPORTACAO' 
             WHEN ("Cd Cliente Agrupador" = '029368' OR "Cd Cliente Agrupador" = '026207' OR "Cd Cliente Agrupador" = '029024' AND "Unidade de Negócio" = 'YOI')
             THEN '* VENDA DIRETA'
             WHEN UPPER("Representante Carteira") = 'NOBRY (000129)' AND "Cd Cliente Agrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
             WHEN UPPER("Representante Carteira") = 'NOBRY (000129)' THEN 'SUL'
             --WHEN UPPER("Representante Carteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'MA' THEN 'NORDESTE'
             --WHEN UPPER("Representante Carteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'TO' THEN 'NORTE'
             ELSE "Regiao" 
        END AS "Regiao"
        , "Representante"
        , "Representante Carteira"
        , "Tipo Faturamento"
        , "Transportador"
        , "Tipo Evento"
        , "Situacao"
        , "Controle"
        , "Qtde Clientes" AS "Qtde Clientes"
        , "Qtde Pedidos" as "Qtde Pedidos"
        , "Atividade" as "Segmento"
        , "Feiras"
        , "Tipo Pedido"
        , "Tipo Pedido Completo"
        , "Controle Desc"
        , "Divisao"
        , "Grupo Fabricação"
        , CASE 
            WHEN SUM("Qtde de Desvio Prazo Prog") > 0 THEN 'Atrasado'
            WHEN SUM("Qtde de Desvio Prazo Prog") < 0 THEN 'Antecipado'
            ELSE 'No Prazo' 
          END AS "Status Desvio Prazo Prog"
        , "Unidade de Negócio"
        , "Unidade de Negócio Filtro"
        , "Ordem de Compra"
        , "Tipo de Carteira"
        , "Tabela de Preços"
        , "Preço Tabela"
        , "Validade Inicial Tabela"
        , "Validade Inicial Tabela Filtro"
        , "Validade Final Tabela"
        , "Validade Final Tabela Filtro"
        , "Motivo"
        , "Justificativa"
        
        , "Data de Expedicao"
        , "NF"

        , SUM(cast(coalesce(replace("Volume", ',', '.'), '0.0') as float)) AS "Volume"
        , SUM(CAST("Quantidade" AS FLOAT)) AS "Quantidade"
        , SUM("Peso Líquido") AS "Peso Líquido"
        , SUM("Peso Bruto") AS "Peso Bruto"
        , MIN("Qtde Dias Cad e Lib") AS "Qtde Dias Cad e Lib"

        , SUM("Qtde Cx Master")                 AS "Qde Maxima Cx Master"
        , SUM("Qtde Dias Programação")          AS "Qtde Dias Programação"
        , SUM("Qtde Dias Prog Comerc")          AS "Qtde Dias Prog Comerc"
        , SUM("Qtde Dias 41-45")                AS "Qtde Dias 41-45"
        , SUM("Qtde Dias Atraso/Antec")         AS "Qtde Dias Atraso/Antec"
        , SUM("Qtde de Desvio Prazo Prog")      AS "Qtde de Desvio Prazo Prog"
        , SUM("Qtde Dias Entrega")              AS "Qtde Dias Entrega"
        , SUM("Dias Analise Comercial")         AS "Dias Analise Comercial"
        , SUM(CAST("Vlr Total Pedido" as REAL)) AS "Vlr Total Pedido"
        , SUM(CAST("Vlr Mercadoria" as REAL))   AS "Vlr Mercadoria"
        , SUM("Qtde Pecas Pedido")              AS "Qtde Pecas Pedido"
        , SUM("Qtde Caixas Total")              AS "Qtde Caixas Total"
        , SUM("Qtde Caixas Fechadas")           AS "Qtde Caixas Fechadas"
        , SUM("Qtde Pedidos Cx Fechado")        AS "Qtde Pedidos Cx Fechado"
  FROM( 
  SELECT 
    CONCAT((CASE WHEN (LTRIM(RTRIM(cl.cd_empresa)) = '' OR LTRIM(RTRIM(cl.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl.cd_empresa)) END), ' - ' , (CASE WHEN (UPPER(LTRIM(RTRIM(cl.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl.fantasia))) = '') THEN 'NAO INFORMADO' ELSE (UPPER(LTRIM(RTRIM(cl.fantasia)))) END)) AS "Cliente"
    , CONCAT((CASE WHEN (UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '') THEN 'NAO INFORMADO' ELSE (UPPER(LTRIM(RTRIM(cl2.fantasia)))) END), ' (', (CASE WHEN (LTRIM(RTRIM(cl2.cd_empresa)) = '' OR LTRIM(RTRIM(cl2.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END), ')') AS "Agrupamento Cliente"
    , CONCAT((CASE WHEN UPPER(LTRIM(RTRIM(cl3.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl3.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl3.Nome_completo))) END), ' (' , (CASE WHEN LTRIM(RTRIM(cl3.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl3.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl3.cd_empresa)) END), ')') AS "Responsavel"
    , (SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i2.cd_carac,1,CHARINDEX(';',i2.Cd_Carac,2)),0,0,b.campo82,0,' '))
       FROM ppident i2(nolock)
       WHERE i2.identificador = i.cd_especif1
        AND i2.Sequencial = 1) AS "Cor" 
    , CONCAT((CASE WHEN (LTRIM(RTRIM(p.cd_unid_de_neg)) = '' OR LTRIM(RTRIM(p.cd_unid_de_neg)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(p.cd_unid_de_neg)) END), ' - ', (CASE WHEN (UPPER(LTRIM(RTRIM(e.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(e.Nome_completo))) = '') THEN 'NAO INFORMADO' ELSE (UPPER(LTRIM(RTRIM(e.Nome_completo)))) END)) AS "Empresa"
    , (CASE WHEN m2.codigo_estado = 'EX' THEN 'EXTERNO' ELSE 'INTERNO' END) AS "Mercado"  
    , CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) AS "Pedido"     
    , COALESCE(p.Dt_pedido, CAST('1900-01-01' AS DATE)) AS "Periodo"
    , p.Dt_cadastro     AS "Periodo Cadastro"
    , p.Dt_cadastro     AS "Periodo Cadastro Filtro"
    , p.Dt_faturado     AS "Periodo Faturado"
    , p.Dt_faturado     AS "Periodo Faturado Filtro"
    , p.Dt_liberacao    AS "Periodo Liberacao"
    , p.Dt_movimentacao AS "Periodo Movimento"
    , p.Dt_prazo_entreg AS "Periodo Entrega"
    , p.Dt_prazo_progra AS "Periodo Programado"
    , p.Dt_prazo_progra AS "Periodo Programado Filtro"
    , (DATEDIFF(day,p.Dt_cadastro,p.Dt_faturado))      AS "Qtde Dias Entrega"
    , (DATEDIFF(day,p.Dt_cadastro,p.Dt_liberacao ))    AS "Dias Analise Comercial"
    , (DATEDIFF(day,p.Dt_liberacao,p.Dt_prazo_progra)) AS "Qtde Dias Programação"
    , (DATEDIFF(day,p.Dt_liberacao,p.Dt_faturado))     AS "Qtde Dias Prog Comerc"
    , (DATEDIFF(day,p.Dt_liberacao,p.Dt_movimentacao)) AS "Qtde Dias 41-45"
    , (DATEDIFF(day,p.Dt_prazo_entreg,p.Dt_prazo_progra)) AS "Qtde Dias Atraso/Antec"
    , (DATEDIFF(day,COALESCE(p.Dt_prazo_entreg, GETDATE()),p.Dt_prazo_progra))  AS "Qtde de Desvio Prazo Prog"
    /*Adicionado no dia 25-05*/
    , p.Volume AS "Volume"
    , p.Quantidade AS "Quantidade"
    , p.Peso_liquido AS "Peso Líquido"
    , p.Peso_bruto AS "Peso Bruto"
    , p.Campo91 AS "Data de Expedicao"
    , p.Nota_fiscal AS "NF"
    , (DATEDIFF(day,p.Dt_cadastro,p.Dt_liberacao)) AS "Qtde Dias Cad e Lib"
    /*  , (CASE WHEN p.Controle in ('41','46','50') THEN (DATEDIFF(day,GETDATE(),p.Dt_prazo_progra)) 
          ELSE (DATEDIFF(day,p.Dt_faturado,p.Dt_prazo_progra)) END)  AS "Qtde de Desvio Prazo Prog" */
    , CONCAT((CASE WHEN (RTRIM(LTRIM(prod.referencia)) IS NULL OR RTRIM(LTRIM(prod.referencia)) = '') THEN '0' ELSE RTRIM(LTRIM(prod.referencia)) END), ' - ' , (CASE WHEN UPPER(LTRIM(RTRIM(prod.descricao))) = '' OR UPPER(LTRIM(RTRIM(prod.descricao))) IS NULL THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(prod.descricao))) END)) AS "Produto"
    , prod.Cd_material AS "codProduto"
    , i.cd_especif1 AS "Especificador"
    , prod.Codigo_fabrica AS "Código da Fábrica"
    , CONCAT((CASE WHEN RTRIM(LTRIM(gp.grupo_produto)) IS NULL OR RTRIM(LTRIM(gp.grupo_produto)) = '' THEN '0' ELSE RTRIM(LTRIM(gp.grupo_produto)) END), ' - ', CASE WHEN UPPER(LTRIM(RTRIM(dgp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(dgp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(dgp.descricao))) END) AS "Catalogo Produto" 
    , CONCAT((CASE WHEN LTRIM(RTRIM(gp.subgrupo_produto)) IS NULL OR LTRIM(RTRIM(gp.subgrupo_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.subgrupo_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tsgp.descicao))) IS NULL OR UPPER(LTRIM(RTRIM(tsgp.descicao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tsgp.descicao))) END)) AS "Sub Grupo Produto"
    , CONCAT((CASE WHEN LTRIM(RTRIM(gp.linha_produto)) IS NULL OR LTRIM(RTRIM(gp.linha_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.linha_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tlp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(tlp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tlp.descricao))) END)) AS "Linha Produto"  
    , CONCAT((CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END), ' (', (CASE WHEN LTRIM(RTRIM(p.cd_representant)) = '' OR LTRIM(RTRIM(p.cd_representant)) IS NULL THEN '0' ELSE LTRIM(RTRIM(p.cd_representant)) END), ')') AS "Representante"
    , CONCAT(CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')') AS "Representante Carteira"
    , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
    , UPPER(LTRIM(RTRIM(cl.uf))) AS "UF"
    , CONCAT(LTRIM(RTRIM(p.cd_transportado)), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(t.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(t.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(t.fantasia))) END)) AS "Transportador"
    , 'VENDA' AS "Tipo Faturamento"        
    , p.Campo96 AS "Tipo Evento"
    , p.cd_pedido AS "Qtde Pedidos"
    , CAST(i.vl_total_item_l AS real) AS "Vlr Mercadoria" --as vlr_liquido_item
    , CAST(((i.vl_total_item_l + i.vl_ipi + ((p.valor_subst_trib)/COALESCE((SELECT CASE WHEN count(*) = 0 THEN NULL ELSE count(*) END FROM FAITEMPE ii (nolock) where ii.cd_pedido = p.cd_pedido AND ii.cd_especie = i.cd_especie),1)))-i.qt_medida1 -(CASE WHEN i.qt_medida1 > 0 THEN (imp.valor_pis+imp.vl_cofins) ELSE 0 END)) AS real) AS "Vlr Total Pedido" --as total_pedido
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
            ELSE 'NÃO INFORMADO'  
    END AS "Tipo Pedido Completo",
    fa.Controle + ' - ' + fa.Descricao as "Controle Desc",
    cx.Campo27 as "Qtde Cx Master",
    CASE WHEN p.situacao = 'F' THEN      i.quantidade / (CASE WHEN cx.Campo27 = 0 THEN NULL ELSE cx.Campo27 END) ELSE 0 END as "Qtde Caixas Total",
    CASE WHEN p.situacao = 'F' THEN CAST(i.quantidade / (CASE WHEN cx.Campo27 = 0 THEN NULL ELSE cx.Campo27 END)  as INT) ELSE 0 END as "Qtde Caixas Fechadas",
    CASE WHEN p.situacao = 'F' AND  CAST(i.quantidade / (CASE WHEN cx.Campo27 = 0 THEN NULL ELSE cx.Campo27 END)  as INT) = (i.quantidade / (CASE WHEN cx.Campo27 = 0 THEN NULL ELSE cx.Campo27 END))  THEN 1 else 0 end "Qtde Pedidos Cx Fechado"  , 
    cl."Divisao" as "Divisao",
    prod.Cd_grupo     + ' - ' + e2.descricao as 'Grupo Fabricação'
    , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
    ,(CASE WHEN  p.cd_unid_de_neg = 1 THEN 'OU' 
        WHEN  p.cd_unid_de_neg = 2 THEN 'YOI'
        else 'Não Informado' end) 
    AS "Unidade de Negócio"
    ,(CASE WHEN  p.cd_unid_de_neg = 1 THEN 'OU'
            WHEN  p.cd_unid_de_neg = 2 THEN 'YOI'
            else 'Não Informado' end ) as "Unidade de Negócio Filtro"
    , p.cd_ordem_de_com as "Ordem de Compra"
    , CASE 
        WHEN cl.campo80 = 'R' THEN 'REATIVADO'
        WHEN cl.campo80 = 'P' THEN 'PROSPECÇÃO'
        WHEN cl.campo80 = 'A' THEN 'ATIVO'
    END AS "Tipo de Carteira"
    , i.Pr_tabela as "Tabela de Preços"
    , pre.Pr_Unitario as "Preço Tabela"
    , pre.Val_Inicial as "Validade Inicial Tabela"
    , pre.Val_Inicial as "Validade Inicial Tabela Filtro"
    , pre.Val_Final as "Validade Final Tabela"
    , pre.Val_Final as "Validade Final Tabela Filtro"
    , CASE (SELECT TOP 1 jus.cd_motivo FROM GFJUSLIB jus (nolock) WHERE p.cd_pedido = jus.Documento_alpha AND p.cd_unid_de_neg = jus.Unidade_negocio AND p.cd_cliente = jus.Empresa ORDER BY jus.Sequencial DESC)
            WHEN 1 THEN 'Liberacao Financeira'
            WHEN 2 THEN 'Liberacao Gestao'
            WHEN 3 THEN 'Liberacao Direcao'
            WHEN 4 THEN 'Liberacao Gestao/Direcao'
    END AS "Motivo"
    , (SELECT TOP 1 jus.Justificativa FROM GFJUSLIB jus (nolock) WHERE p.cd_pedido = jus.Documento_alpha AND p.cd_unid_de_neg = jus.Unidade_negocio AND p.cd_cliente = jus.Empresa ORDER BY jus.Sequencial DESC) as "Justificativa"
  FROM CGVW_FAPEDIDOS p (nolock)
  INNER JOIN FAITEMPE i (nolock)        ON (p.cd_pedido      = i.cd_pedido and p.cd_unid_de_neg =  i.cd_unid_de_neg)
  LEFT  JOIN CGVW_FAIMOPED imp (nolock) ON (imp.pedido       = i.cd_pedido AND 
                                            imp.sequencia    = i.sequencia)
  LEFT  JOIN geempres cl (nolock)   ON (p.cd_cliente = cl.cd_empresa)
  LEFT  JOIN geempres cl3 (nolock)  ON (cl.Cd_responsavel = cl3.cd_empresa)
  LEFT  JOIN geempres r2 (nolock)   ON (r2.cd_empresa = cl.cd_representant)
  LEFT  JOIN vemercad re (nolock)   ON (r2.cd_mercado = re.cd_mercado)
  LEFT  JOIN geempres cl2 (nolock)  ON (cl.Cd_centralizado = cl2.cd_empresa)
  LEFT  JOIN geunidne e (nolock)    ON (e.Cd_unidade_de_n = p.cd_unid_de_neg)
  LEFT  JOIN ESMATERI b (nolock)    ON (b.Cd_material = i.Cd_material)
  LEFT  JOIN GEPRECTA pre (nolock)  ON (pre.Elemento = i.Cd_material AND pre.Tb_preco = i.Pr_tabela)
  LEFT  JOIN geestado m2 (nolock)   ON (cl.uf = m2.codigo_estado AND m2.Cd_unidade_de_n = p.Cd_unid_de_neg)
  LEFT  JOIN geempres r (nolock)    ON (p.cd_representant = r.cd_empresa)
  LEFT  JOIN geempres t (nolock)    ON (t.cd_empresa = p.cd_transportado)
  LEFT  JOIN VEATIVID ve (nolock)   ON (ve.atividade = cl.atividade)
  LEFT  JOIN FACONTRO fa (nolock)   ON (fa.Controle = p.Controle)
  LEFT  JOIN esmateri prod (nolock) ON (i.Cd_material = prod.cd_material)
  LEFT  JOIN temateriallinha gp (nolock)     ON (gp.material = i.cd_material)
  LEFT  JOIN tegrupoproduto dgp (nolock)     ON (dgp.nome_grupo = gp.grupo_produto)
  LEFT  JOIN tesubgrupoproduto tsgp (nolock) ON (tsgp.nome_subgrupo = gp.subgrupo_produto)
  LEFT  JOIN telinhaproduto tlp (nolock)     ON (tlp.linha = gp.linha_produto)
  LEFT  JOIN ESGRUPO  e2 (nolock)            ON (e2.Cd_grupo = prod.Cd_grupo)
  LEFT  JOIN ESPARPLA  cx (nolock)           ON (cx.Cd_material = i.Cd_material and cx.Tipo = 'C' and cx.Ordem = '9999')
  LEFT  JOIN GELIBERA mot ON (p.cd_pedido = mot.Doc_Alpha AND p.cd_unid_de_neg = mot.Unidade_de_Negocio AND p.cd_cliente = mot.Empresa)
  WHERE i.cd_especie = 'R' and  p.Dt_pedido >= dateadd(m, datediff(m, 0, DATEADD(month , -12 , getdate())), 0)
  --DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) --mes atual
  ) x
  GROUP BY  "Cliente"
      , "Agrupamento Cliente"
      , "Responsavel"
      , "Cor"
      , "Empresa"
      , "Mercado"
      , "Pedido"
      , "Periodo"
      , "Periodo"
      , "Periodo Cadastro"
      , "Periodo Faturado"
      , "Periodo Liberacao"
      , "Periodo Movimento"
      , "Periodo Entrega"
      , "Periodo Programado"
      , "Produto"
      , "codProduto"
      , "Especificador"
      , "Código da Fábrica"
      , "Produto" + ' - ' + "Cor"
      , "Catalogo Produto"
      , "Sub Grupo Produto"
      , "Linha Produto" 
      , CASE 
             WHEN "UF" = 'EX' 
             THEN 'EXPORTACAO' 
             WHEN ("Cd Cliente Agrupador" = '029368' OR "Cd Cliente Agrupador" = '026207' OR "Cd Cliente Agrupador" = '029024' AND "Unidade de Negócio" = 'YOI')
             THEN '* VENDA DIRETA'
             WHEN UPPER("Representante Carteira") = 'NOBRY (000129)' AND "Cd Cliente Agrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
             WHEN UPPER("Representante Carteira") = 'NOBRY (000129)' THEN 'SUL'
             --WHEN UPPER("Representante Carteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'MA' THEN 'NORDESTE'
             --WHEN UPPER("Representante Carteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'TO' THEN 'NORTE'
             ELSE "Regiao" 
        END
      , "Representante"
      , "Representante Carteira"
      , "Tipo Faturamento"
      , "Transportador"
      , "Tipo Evento"
      , "Situacao"
      , "UF"
      , "Qtde Clientes"
      , "Controle"
      , "Qtde Pedidos"
      ,"Periodo Cad Cliente"
      ,"Periodo Cadastro Filtro"
      ,"Periodo Faturado Filtro"
      ,"Atividade"
      ,"Feiras"
      ,"Tipo Pedido"
      ,"Tipo Pedido Completo"
      ,"Controle Desc"
      , "UF"
      ,"Divisao"
      ,"Grupo Fabricação"
      ,"Unidade de Negócio"
      ,"Unidade de Negócio Filtro"
      ,"Ordem de Compra"
      ,"Tipo de Carteira"
      ,"Tabela de Preços"
      ,"Preço Tabela"
      ,"Validade Inicial Tabela"
      ,"Validade Inicial Tabela Filtro"
      ,"Validade Final Tabela"
      ,"Validade Final Tabela Filtro"
      ,"Motivo"
      ,"Justificativa"
      , "Data de Expedicao"
      , "NF"