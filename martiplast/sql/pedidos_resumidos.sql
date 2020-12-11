SELECT "Cliente"
        , "AgrupamentoCliente"
        , "Responsavel"
        , "Empresa"
        , "Mercado"
        , "Pedido"
        , "Periodo"
        , "PeriodoCadastro"
        , "PeriodoFaturado"
        , "PeriodoLiberacao"
        , "PeriodoMovimento"
        , "PeriodoEntrega"
        , "PeriodoProgramado"
        , "PeriodoCadCliente"
        , "UF" AS "UF"
        , CASE 
             WHEN "UF" = 'EX' 
             THEN 'EXPORTACAO' 
             WHEN ("CdClienteAgrupador" = '029368' OR "CdClienteAgrupador" = '026207' OR "CdClienteAgrupador" = '029024' AND "UnidadedeNegocio" = 'YOI')
             THEN '* VENDA DIRETA'
             WHEN UPPER("RepresentanteCarteira") = 'NOBRY (000129)' AND "CdClienteAgrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
             WHEN UPPER("RepresentanteCarteira") = 'NOBRY (000129)' THEN 'SUL'
             WHEN UPPER("RepresentanteCarteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'MA' THEN 'NORDESTE'
             WHEN UPPER("RepresentanteCarteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'TO' THEN 'NORTE'
             ELSE "Regiao" 
        END AS "Regiao"
        , cast(coalesce(replace("Volume", ',', '.'), '0.0') as float) AS "Volume"
        , CAST("Quantidade" AS FLOAT) AS "Quantidade"
        , "PesoLiquido"
        , "PesoBruto"
        , "DatadeExpedicao"
        , "NF"
        , "Representante"
        , "RepresentanteCarteira"
        , "TipoFaturamento"
        , "Transportador"
        , "TipoEvento"
        , "QtdePedidos"
        , "Situacao"
        , "QtdeClientes"
        , "TipoPedido"
        , "TipoPedidoCompleto"
        , "ControleDesc"
        , "Divisao"
        , "UnidadedeNegocio"
        , "OrdemdeCompra"
        , "TipodeCarteira"
        , "Motivo"
        , "Justificativa"
        , SUM(CAST("VlrTotalPedido" as REAL)) AS "VlrTotalPedido"
        , SUM(CAST("VlrMercadoria" as REAL))   AS "VlrMercadoria"
  FROM( 
  SELECT 
    CONCAT((CASE WHEN (LTRIM(RTRIM(cl.cd_empresa)) = '' OR LTRIM(RTRIM(cl.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl.cd_empresa)) END), ' - ' , (CASE WHEN (UPPER(LTRIM(RTRIM(cl.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl.fantasia))) = '') THEN 'NAO INFORMADO' ELSE (UPPER(LTRIM(RTRIM(cl.fantasia)))) END)) AS "Cliente"
    , CONCAT((CASE WHEN (UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '') THEN 'NAO INFORMADO' ELSE (UPPER(LTRIM(RTRIM(cl2.fantasia)))) END), ' (', (CASE WHEN (LTRIM(RTRIM(cl2.cd_empresa)) = '' OR LTRIM(RTRIM(cl2.cd_empresa)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END), ')') AS "AgrupamentoCliente"
    , CONCAT((CASE WHEN UPPER(LTRIM(RTRIM(cl3.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl3.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl3.Nome_completo))) END), ' (' , (CASE WHEN LTRIM(RTRIM(cl3.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl3.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl3.cd_empresa)) END), ')') AS "Responsavel"
    , CONCAT((CASE WHEN (LTRIM(RTRIM(p.cd_unid_de_neg)) = '' OR LTRIM(RTRIM(p.cd_unid_de_neg)) IS NULL) THEN '0' ELSE LTRIM(RTRIM(p.cd_unid_de_neg)) END), ' - ', (CASE WHEN (UPPER(LTRIM(RTRIM(e.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(e.Nome_completo))) = '') THEN 'NAO INFORMADO' ELSE (UPPER(LTRIM(RTRIM(e.Nome_completo)))) END)) AS "Empresa"
    , (CASE WHEN m2.codigo_estado = 'EX' THEN 'EXTERNO' ELSE 'INTERNO' END) AS "Mercado"  
    , CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) AS "Pedido"     
    , COALESCE(p.Dt_pedido, CAST('1900-01-01' AS DATE)) AS "Periodo"
    , p.Dt_cadastro     AS "PeriodoCadastro"
    , p.Dt_faturado     AS "PeriodoFaturado"
    , p.Dt_liberacao    AS "PeriodoLiberacao"
    , p.Dt_movimentacao AS "PeriodoMovimento"
    , p.Dt_prazo_entreg AS "PeriodoEntrega"
    , p.Dt_prazo_progra AS "PeriodoProgramado"
    , cl.Dt_cadastro AS "PeriodoCadCliente"
    , UPPER(LTRIM(RTRIM(cl.uf))) AS "UF"
    , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
    /*Adicionado no dia 25-05*/
    , p.Volume AS "Volume"
    , p.Quantidade AS "Quantidade"
    , p.Peso_liquido AS "PesoLiquido"
    , p.Peso_bruto AS "PesoBruto"
    , p.Campo91 AS "DatadeExpedicao"
    , p.Nota_fiscal AS "NF"  
    , CONCAT((CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END), ' (', (CASE WHEN LTRIM(RTRIM(p.cd_representant)) = '' OR LTRIM(RTRIM(p.cd_representant)) IS NULL THEN '0' ELSE LTRIM(RTRIM(p.cd_representant)) END), ')') AS "Representante"
    , CONCAT(CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')') AS "RepresentanteCarteira"
    , 'VENDA' AS "TipoFaturamento"        
    , CONCAT(LTRIM(RTRIM(p.cd_transportado)), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(t.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(t.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(t.fantasia))) END)) AS "Transportador"
    , p.Campo96 AS "TipoEvento"
    , p.cd_pedido AS "QtdePedidos"
    , p.situacao AS "Situacao"
    , p.cd_cliente AS "QtdeClientes"
    , p.campo143 AS "TipoPedido"
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
    END AS "TipoPedidoCompleto"
    , fa.Controle + ' - ' + fa.Descricao as "ControleDesc"
    , cl."Divisao" as "Divisao"
    , (CASE WHEN  p.cd_unid_de_neg = 1 THEN 'OU' 
        WHEN  p.cd_unid_de_neg = 2 THEN 'YOI'
        else 'Não Informado' end) 
    AS "UnidadedeNegocio"
    , p.cd_ordem_de_com as "OrdemdeCompra"
    , CASE 
        WHEN cl.campo80 = 'R' THEN 'REATIVADO'
        WHEN cl.campo80 = 'P' THEN 'PROSPECÇÃO'
        WHEN cl.campo80 = 'A' THEN 'ATIVO'
    END AS "TipodeCarteira"
    , CASE (SELECT TOP 1 jus.cd_motivo FROM GFJUSLIB jus (nolock) WHERE p.cd_pedido = jus.Documento_alpha AND p.cd_unid_de_neg = jus.Unidade_negocio AND p.cd_cliente = jus.Empresa ORDER BY jus.Sequencial DESC)
            WHEN 1 THEN 'Liberacao Financeira'
            WHEN 2 THEN 'Liberacao Gestao'
            WHEN 3 THEN 'Liberacao Direcao'
            WHEN 4 THEN 'Liberacao Gestao/Direcao'
    END AS "Motivo"
    , (SELECT TOP 1 jus.Justificativa FROM GFJUSLIB jus (nolock) WHERE p.cd_pedido = jus.Documento_alpha AND p.cd_unid_de_neg = jus.Unidade_negocio AND p.cd_cliente = jus.Empresa ORDER BY jus.Sequencial DESC) as "Justificativa"
    , LTRIM(RTRIM(cl2.cd_empresa)) as "CdClienteAgrupador"
    , CAST(i.vl_total_item_l AS real) AS "VlrMercadoria" --as vlr_liquido_item
    , CAST(((i.vl_total_item_l + i.vl_ipi + ((p.valor_subst_trib)/COALESCE((SELECT CASE WHEN count(*) = 0 THEN NULL ELSE count(*) END FROM FAITEMPE ii (nolock) where ii.cd_pedido = p.cd_pedido AND ii.cd_especie = i.cd_especie),1)))-i.qt_medida1 -(CASE WHEN i.qt_medida1 > 0 THEN (imp.valor_pis+imp.vl_cofins) ELSE 0 END)) AS real) AS "VlrTotalPedido" --as total_pedido
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
  LEFT  JOIN geestado m2 (nolock)   ON (cl.uf = m2.codigo_estado AND m2.Cd_unidade_de_n = p.Cd_unid_de_neg)
  LEFT  JOIN geempres r (nolock)    ON (p.cd_representant = r.cd_empresa)
  LEFT  JOIN geempres t (nolock)    ON (t.cd_empresa = p.cd_transportado)
  LEFT  JOIN FACONTRO fa (nolock)   ON (fa.Controle = p.Controle)
  WHERE i.cd_especie = 'R' and  p.Dt_pedido >= dateadd(m, datediff(m, 0, DATEADD(month , -12 , getdate())), 0)) x
  GROUP BY  "Cliente"
        , "AgrupamentoCliente"
        , "Responsavel"
        , "Empresa"
        , "Mercado"
        , "Pedido"
        , "Periodo"
        , "PeriodoCadastro"
        , "PeriodoFaturado"
        , "PeriodoLiberacao"
        , "PeriodoMovimento"
        , "PeriodoEntrega"
        , "PeriodoProgramado"
        , "PeriodoCadCliente"
        , "UF"
        , CASE 
             WHEN "UF" = 'EX' 
             THEN 'EXPORTACAO' 
             WHEN ("CdClienteAgrupador" = '029368' OR "CdClienteAgrupador" = '026207' OR "CdClienteAgrupador" = '029024' AND "UnidadedeNegocio" = 'YOI')
             THEN '* VENDA DIRETA'
             WHEN UPPER("RepresentanteCarteira") = 'NOBRY (000129)' AND "CdClienteAgrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
             WHEN UPPER("RepresentanteCarteira") = 'NOBRY (000129)' THEN 'SUL'
             WHEN UPPER("RepresentanteCarteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'MA' THEN 'NORDESTE'
             WHEN UPPER("RepresentanteCarteira") = 'MATOPA COM E REP LTD (038240)' AND "UF" = 'TO' THEN 'NORTE'
             ELSE "Regiao" 
        END
        , cast(coalesce(replace("Volume", ',', '.'), '0.0') as float)
        , CAST("Quantidade" AS FLOAT)
        , "PesoLiquido"
        , "PesoBruto"
        , "DatadeExpedicao"
        , "NF"
        , "Representante"
        , "RepresentanteCarteira"
        , "TipoFaturamento"
        , "Transportador"
        , "TipoEvento"
        , "QtdePedidos"
        , "Situacao"
        , "QtdeClientes"
        , "TipoPedido"
        , "TipoPedidoCompleto"
        , "ControleDesc"
        , "Divisao"
        , "UnidadedeNegocio"
        , "OrdemdeCompra"
        , "TipodeCarteira"
        , "Motivo"
        , "Justificativa"