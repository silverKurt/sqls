SELECT 
        CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(cl.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(p.cd_cliente)) IS NULL OR LTRIM(RTRIM(p.cd_cliente)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_cliente)) END)
    , ')'
    ) AS "Cliente" 
    , cl.Fone AS "Cliente Fone"
    , CONCAT(cl.Endereco, ' - ', cl.Numero) AS "Cliente Endereço"
    , cl.Bairro AS "Cliente Bairro"
    , cl.Municipio AS "Cliente Municipio" 
    , cl.Dt_ultimo_movim AS "Periodo Ultima Compra"
    ,cl.Divisao AS "Divisao Cliente"

    , CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(cl2.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END)
    , ')'
    ) AS "Agrupamento Cliente"
        , CONCAT((CASE WHEN LTRIM(RTRIM(i.cd_especif1)) IS NULL OR LTRIM(RTRIM(i.cd_especif1)) = '' THEN '0' ELSE LTRIM(RTRIM(i.cd_especif1)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(c.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(c.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(c.descricao))) END)) AS "Cor" 
        , (CASE WHEN UPPER(LTRIM(RTRIM(c.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(c.descricao))) = '' THEN '0 - NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(c.descricao))) END) AS "CorD" 
        , CONCAT((CASE WHEN LTRIM(RTRIM(p.cd_unidade_de_n)) IS NULL OR LTRIM(RTRIM(p.cd_unidade_de_n)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_unidade_de_n)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(e.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(e.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(e.Nome_completo))) END)) AS "Empresa" 
        , p.cd_unidade_de_n
        , (CASE WHEN m2.codigo_estado = 'EX' THEN 'EXTERNO' ELSE 'INTERNO' END) AS "Mercado" 
        , CASE WHEN CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) = '' OR CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) IS NULL THEN '0' ELSE CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) END AS "Pedido" 

    , CAST((CASE 
      WHEN p.Dt_emissao IS NULL
      THEN '1900-01-01'
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_emissao), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_emissao) + 1), '-', DATEPART(MONTH, p.Dt_emissao),'-', DATEPART(DAY, p.Dt_emissao)) AS DATE)), 0)
    END) AS DATE) AS "Periodo" 
    , CAST((CASE 
      WHEN p.Dt_modificacao IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_modificacao), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_modificacao) + 1), '-', DATEPART(MONTH, p.Dt_modificacao),'-', DATEPART(DAY, p.Dt_modificacao)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Modificacao" 
        , CAST((CASE 
      WHEN p.Dt_romaneio IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_romaneio), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_romaneio) + 1), '-', DATEPART(MONTH, p.Dt_romaneio),'-', DATEPART(DAY, p.Dt_romaneio)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Romaneio" 
        , CAST((CASE 
      WHEN p.Dt_saida IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_saida), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_saida) + 1), '-', DATEPART(MONTH, p.Dt_saida),'-', DATEPART(DAY, p.Dt_saida)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Saida" 
    
    , CONCAT(
      (CASE WHEN RTRIM(LTRIM(prod.Referencia)) IS NULL OR RTRIM(LTRIM(prod.Referencia)) = '' THEN '0' ELSE RTRIM(LTRIM(prod.Referencia)) END)
      , ' - ',
      (CASE WHEN prod.descricao IS NULL OR prod.descricao IS NULL THEN 'NAO INFORMADO' ELSE prod.descricao END)
    ) AS "Produto"  
    , cl.atividade + ' - ' + ve.descricao AS  "Segmento"
    , prod.Cd_origem_merca AS "origem"
    /*, CONCAT(
      (CASE WHEN RTRIM(LTRIM(prodAgrupamento.Referencia)) IS NULL OR RTRIM(LTRIM(prodAgrupamento.Referencia)) = '' THEN '0' ELSE RTRIM(LTRIM(prodAgrupamento.Referencia)) END)
      , ' - ',
      (CASE WHEN prodAgrupamento.descricao IS NULL OR prodAgrupamento.descricao IS NULL THEN 'NAO INFORMADO' ELSE prodAgrupamento.descricao END)
    ) AS "Produto Agrupador" */
        , CONCAT((CASE WHEN RTRIM(LTRIM(gp.grupo_produto)) IS NULL OR RTRIM(LTRIM(gp.grupo_produto)) = '' THEN '0' ELSE RTRIM(LTRIM(gp.grupo_produto)) END), ' - ', CASE WHEN UPPER(LTRIM(RTRIM(dgp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(dgp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(dgp.descricao))) END) AS "Catalogo Produto" 
        , CONCAT((CASE WHEN LTRIM(RTRIM(gp.subgrupo_produto)) IS NULL OR LTRIM(RTRIM(gp.subgrupo_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.subgrupo_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tsgp.descicao))) IS NULL OR UPPER(LTRIM(RTRIM(tsgp.descicao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tsgp.descicao))) END)) AS "Sub Grupo Produto"
        , CONCAT((CASE WHEN LTRIM(RTRIM(gp.linha_produto)) IS NULL OR LTRIM(RTRIM(gp.linha_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.linha_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tlp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(tlp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tlp.descricao))) END)) AS "Linha Produto"   
        
    , CASE WHEN UPPER(LTRIM(RTRIM(cl.Uf))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Uf))) = '' THEN 'N/I' ELSE UPPER(LTRIM(RTRIM(cl.Uf))) END AS "UF"
        , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
        , LTRIM(RTRIM(r2.cd_empresa)) AS "Cod_Representante_Carteira"
        , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END
        ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')'
        ) AS "Representante Carteira"
    
        , CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(p.cd_representant)) = '' OR LTRIM(RTRIM(p.cd_representant)) IS NULL THEN '0' ELSE LTRIM(RTRIM(p.cd_representant)) END)
    , ')'
    ) AS "Representante"
    , p.cd_representant AS "Codigo Representante"
        , CONCAT(LTRIM(RTRIM(p.cd_transportado)), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(t.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(t.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(t.fantasia))) END)) AS "Transportador"
        , 'VENDA' AS "Tipo Faturamento"
        , CONCAT((CASE WHEN p.serie IS NULL OR p.serie = '' THEN '0' ELSE p.serie END), ' - ', CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR)) AS "Qtde Faturas"
        , 1 AS "Qtde Itens Nota Fat"
        , i.quantidade AS "Qtde Pecas Nota Fat" --as qtd_pecas --Quantidade de cada item na nota
        , i.pr_unitario AS "Vlr Unitario Fat" --as vlr_unitario
        , i.peso_total_item AS "Peso Fat"
        , i.Vl_base_subst AS "Vl_base_subst"
        , i.Vl_base_substit AS "Vl_base_substit"
        , i.Vl_desconto AS "Vlr Desc Fat"
        , i.Vl_enc_financ AS "Vl_enc_financ"
        , i.Vl_frete AS "Vlr Frete Fat"
        , i.Vl_icms AS "Vlr ICMS Fat"
        , i.Vl_ipi AS "Vlr IPI Fat"
        , i.Vl_ipi_obs AS "Vl_ipi_obs"
        , i.Vl_seguro AS "Vlr Seguro Fat"
        , i.Vl_substituicao AS "Vlr ST Fat"
        , i.Vl_suframa AS "Vlr Suf Fat"
        , (i.pr_unitario * i.quantidade) AS "Vlr Produto Fat" --AS vlr_nominal
        , i.outras_desp_aces AS "Vlr Acessorias" --AS vlr_acessorias
        , i.perc_ipi AS "perc_ipi"
        , i.perc_icms AS "perc_icms"
        , i.perc_pis AS "perc_pis"
        , i.perc_cofins AS "perc_cofins"
        , i.Ncm AS "tipi_ncm"
        , ((i.pr_unitario * i.quantidade)
                + i.Vl_substituicao
                + i.Vl_ipi
                + i.Vl_seguro
                + i.outras_desp_aces
                + i.Vl_frete
                - i.Vl_desconto
                - i.Vl_suframa) AS "Vlr Nota Fat" --AS vlr_fat_geral
    
    , (CASE WHEN (p.Dt_emissao >= '2021-01-01' AND p.cd_unidade_de_n = '1') AND i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (54)) 
                          THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item - i.Vl_icms + i.Vl_frete)*0.0925
                          
                          WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (62))
                          THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365
                          
                          WHEN p.Dt_emissao < '2021-01-01' AND i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (44))
                          THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365
                          
                          WHEN p.Dt_emissao < '2021-01-01' AND i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (45))
                          THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa
                          
                          WHEN p.Dt_emissao >= '2021-01-01' AND i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (58))
                          THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.1625
                          
                          WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (51)) 
                          THEN (i.Pr_total_item/1.1) - i.Vl_desconto
                          
                          WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (48))
                          THEN (i.Pr_total_item + i.Vl_frete) - i.Vl_suframa
                          
                          WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (52)) 
                          THEN (i.Pr_total_item + i.Vl_frete + i.Vl_seguro) - i.Vl_desconto 
                          
                          WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (53))
                          THEN (CASE WHEN (i.Nf = '158171' AND i.Serie = 'NFE') OR (i.Nf = '158530' AND i.Serie = 'NFE') OR (i.Nf = '161233' AND i.Serie = 'NFE') THEN ((i.Pr_unitario * i.Quantidade) / 1.15)
                                     WHEN (i.Nf = '158172' AND i.Serie = 'NFE') OR (i.Nf = '158531' AND i.Serie = 'NFE') OR (i.Nf = '161245' AND i.Serie = 'NFE') THEN ((i.Pr_unitario * i.Quantidade) / 1.1)
                                     ELSE (i.Pr_unitario * i.Quantidade)
                                END)
                          ELSE (i.Pr_total_item + i.Vl_frete + i.Vl_seguro + i.outras_desp_aces) - i.Vl_desconto 
                  END) AS "Vlr Gerencial Fat" 
    
    , concat(ltrim(rtrim(prod.codigo_fabrica)), '-', ltrim(rtrim(prod.descricao)), ' - ', 
        ( SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i2.cd_carac,1,CHARINDEX(';',i2.Cd_Carac,2)),0,0,prod.campo82,0,' '))
        FROM  ppident i2(nolock)
      WHERE i2.identificador = i.Cd_Especif1 AND i2.Sequencial = 1))             AS "Fabrica"

    , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
    , tg.Categoria as "Setor Leroy"
    --, ean.Categoria as "EAN"
FROM fanfisca p (nolock)
INNER JOIN esmovime i (nolock) ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND (p.especie_nota = 'S' OR p.especie_nota = 'N'))
INNER JOIN FANFISCA f (nolock) ON (i.Nf = f.Nf and i.serie = f.Serie AND p.cd_unidade_de_n = f.cd_unidade_de_n)
LEFT JOIN geempres cl (nolock) ON (p.cd_cliente = cl.cd_empresa)
LEFT JOIN geempres cl2 (nolock) ON (cl.cd_centralizado = cl2.cd_empresa)
LEFT JOIN geempres r (nolock) ON (p.cd_representant = r.cd_empresa)
LEFT JOIN geestado ge (nolock) ON (ge.Codigo_estado = r.Uf and ge.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN lfregiao reg (nolock) ON (ge.Cd_regiao = reg.Cd_regiao)
LEFT JOIN esmateri prod (nolock) ON (i.Cd_material = prod.cd_material)
--LEFT JOIN esmateri prodAgrupamento (nolock) ON (prod.Referencia = prodAgrupamento.Codigo_fabrica)
LEFT JOIN temateriallinha gp (nolock) ON (gp.material = i.cd_material)
LEFT JOIN tegrupoproduto dgp (nolock) ON (dgp.nome_grupo = gp.grupo_produto)
LEFT JOIN eses1 c (nolock) ON (CAST(c.cd_especif1 AS INTEGER) = i.cd_especif1)
LEFT JOIN geunidne e (nolock) ON (e.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN telinhaproduto tlp (nolock) ON (tlp.linha = gp.linha_produto)
LEFT JOIN gepais m1 (nolock) ON (m1.cd_pais = cl.cd_pais)
LEFT JOIN geestado m2 (nolock) ON (cl.uf = m2.codigo_estado and m2.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN tesubgrupoproduto tsgp (nolock) ON (tsgp.nome_subgrupo = gp.subgrupo_produto)
LEFT JOIN geempres t (nolock) ON (t.cd_empresa = p.cd_transportado)
LEFT JOIN  VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
LEFT JOIN ESGRUPO  j (nolock) ON (j.Cd_grupo = prod.Cd_grupo)
LEFT JOIN geempres r2 (nolock)  ON (r2.cd_empresa = cl.cd_representant)
LEFT JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
LEFT JOIN geelemen tg (nolock) ON (i.Cd_material = tg.Elemento and tg.Cd_tg = 632)
--LEFT JOIN geelemen ean(nolock) ON (i.Cd_material = ean.Elemento and ean.Cd_tg = 100)

WHERE 
  i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (6))
  AND p.dt_emissao >= CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0) AS DATE)
  AND p.dt_emissao <= CAST(DATEADD(YEAR, - 1, GETDATE()) AS DATE)
  AND prod.Cd_origem_merca <> ' ' AND p.cd_unidade_de_n <> ' '
  
UNION ALL

(--Bonificação
SELECT 
        CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(cl.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(p.cd_cliente)) IS NULL OR LTRIM(RTRIM(p.cd_cliente)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_cliente)) END)
    , ')'
    ) AS "Cliente"
    , cl.Fone AS "Cliente Fone"
    , CONCAT(cl.Endereco, ' - ', cl.Numero) AS "Cliente Endereço"
    , cl.Bairro AS "Cliente Bairro"
    , cl.Municipio AS "Cliente Municipio"  
    , cl.Dt_ultimo_movim AS "Periodo Ultima Compra"
    ,cl.Divisao AS "Divisao Cliente"
    , CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(cl2.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END)
    , ')'
    ) AS "Agrupamento Cliente" 
    
        , CONCAT((CASE WHEN LTRIM(RTRIM(i.cd_especif1)) IS NULL OR LTRIM(RTRIM(i.cd_especif1)) = '' THEN '0' ELSE LTRIM(RTRIM(i.cd_especif1)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(c.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(c.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(c.descricao))) END)) AS "Cor" 
        , (CASE WHEN UPPER(LTRIM(RTRIM(c.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(c.descricao))) = '' THEN '0 - NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(c.descricao))) END) AS "CorD" 
        , CONCAT((CASE WHEN LTRIM(RTRIM(p.cd_unidade_de_n)) IS NULL OR LTRIM(RTRIM(p.cd_unidade_de_n)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_unidade_de_n)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(e.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(e.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(e.Nome_completo))) END)) AS "Empresa"
        , p.cd_unidade_de_n
        , (CASE WHEN m2.codigo_estado = 'EX' THEN 'EXTERNO' ELSE 'INTERNO' END) AS "Mercado" 
        , (CASE WHEN CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(p.cd_pedido)) AS VARCHAR) END) AS "Pedido"        
    
    , CAST((CASE 
      WHEN p.Dt_emissao IS NULL
      THEN '1900-01-01'
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_emissao), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_emissao) + 1), '-', DATEPART(MONTH, p.Dt_emissao),'-', DATEPART(DAY, p.Dt_emissao)) AS DATE)), 0)
    END) AS DATE) AS "Periodo" 
    , CAST((CASE 
      WHEN p.Dt_modificacao IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_modificacao), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_modificacao) + 1), '-', DATEPART(MONTH, p.Dt_modificacao),'-', DATEPART(DAY, p.Dt_modificacao)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Modificacao" 
        , CAST((CASE 
      WHEN p.Dt_romaneio IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_romaneio), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_romaneio) + 1), '-', DATEPART(MONTH, p.Dt_romaneio),'-', DATEPART(DAY, p.Dt_romaneio)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Romaneio" 
        , CAST((CASE 
      WHEN p.Dt_saida IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_saida), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_saida) + 1), '-', DATEPART(MONTH, p.Dt_saida),'-', DATEPART(DAY, p.Dt_saida)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Saida" 
    
    , CONCAT(
     (CASE WHEN RTRIM(LTRIM(prod.Referencia)) IS NULL OR RTRIM(LTRIM(prod.Referencia)) = '' THEN '0' ELSE RTRIM(LTRIM(prod.Referencia)) END)
     , ' - ' ,
    (CASE WHEN prod.descricao IS NULL OR prod.descricao IS NULL THEN 'NAO INFORMADO' ELSE prod.descricao END)
    ) AS "Produto" 
    , cl.atividade + ' - ' + ve.descricao AS  "Segmento"
    , prod.Cd_origem_merca AS "origem"
    /*, CONCAT(
      (CASE WHEN RTRIM(LTRIM(prodAgrupamento.Referencia)) IS NULL OR RTRIM(LTRIM(prodAgrupamento.Referencia)) = '' THEN '0' ELSE RTRIM(LTRIM(prodAgrupamento.Referencia)) END)
      , ' - ',
      (CASE WHEN prodAgrupamento.descricao IS NULL OR prodAgrupamento.descricao IS NULL THEN 'NAO INFORMADO' ELSE prodAgrupamento.descricao END)
    ) AS "Produto Agrupador" */
        , CONCAT((CASE WHEN RTRIM(LTRIM(gp.grupo_produto)) IS NULL OR RTRIM(LTRIM(gp.grupo_produto)) = '' THEN '0' ELSE RTRIM(LTRIM(gp.grupo_produto)) END), ' - ', CASE WHEN UPPER(LTRIM(RTRIM(dgp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(dgp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(dgp.descricao))) END) AS "Catalogo Produto" 
        , CONCAT((CASE WHEN LTRIM(RTRIM(gp.subgrupo_produto)) IS NULL OR LTRIM(RTRIM(gp.subgrupo_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.subgrupo_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tsgp.descicao))) IS NULL OR UPPER(LTRIM(RTRIM(tsgp.descicao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tsgp.descicao))) END)) AS "Sub Grupo Produto"
        , CONCAT((CASE WHEN LTRIM(RTRIM(gp.linha_produto)) IS NULL OR LTRIM(RTRIM(gp.linha_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.linha_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tlp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(tlp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tlp.descricao))) END)) AS "Linha Produto"   
                
    , CASE WHEN UPPER(LTRIM(RTRIM(cl.Uf))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Uf))) = '' THEN 'N/I' ELSE UPPER(LTRIM(RTRIM(cl.Uf))) END AS "UF"
        , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
        , LTRIM(RTRIM(r2.cd_empresa)) AS "Cod_Representante_Carteira"
        , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END
        ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')'
        ) AS "Representante Carteira"
    
    , CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(p.cd_representant)) IS NULL OR LTRIM(RTRIM(p.cd_representant)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_representant)) END)
    , ')'
    ) AS "Representante"
        , p.cd_representant AS "Codigo Representante"
        , CONCAT((CASE WHEN LTRIM(RTRIM(p.cd_transportado)) IS NULL OR LTRIM(RTRIM(p.cd_transportado)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_transportado)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(t.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(t.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(t.fantasia))) END)) AS "Transportador"
    , 'BONIFICACAO' AS "Tipo Faturamento"
    , CONCAT((CASE WHEN p.serie IS NULL OR p.serie = '' THEN '0' ELSE p.serie END), ' - ', CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR)) AS "Qtde Faturas"
    , 1 AS "Qtde Itens Nota Fat"
        , i.quantidade AS "Qtde Pecas Nota Fat" --as qtd_pecas --Quantidade de cada item na nota
        , i.pr_unitario AS "Vlr Unitario Fat" --as vlr_unitario
        , i.peso_total_item AS "Peso Fat"
        , i.Vl_base_subst AS "Vl_base_subst"
    , i.Vl_base_substit AS "Vl_base_substit"
    , i.Vl_desconto AS "Vlr Desc Fat"
    , i.Vl_enc_financ AS "Vl_enc_financ"
    , i.Vl_frete AS "Vlr Frete Fat"
    , i.Vl_icms AS "Vlr ICMS Fat"
    , i.Vl_ipi AS "Vlr IPI Fat"
    , i.Vl_ipi_obs AS "Vl_ipi_obs"
    , i.Vl_seguro AS "Vlr Seguro Fat"
    , i.Vl_substituicao AS "Vlr ST Fat"
    , i.Vl_suframa AS "Vlr Suf Fat"
    , (i.pr_unitario * i.quantidade) AS "Vlr Produto Fat" --AS vlr_nominal
    , i.outras_desp_aces AS "Vlr Acessorias" --AS vlr_acessorias
    , i.perc_ipi AS "perc_ipi"
    , i.perc_icms AS "perc_icms"
    , i.perc_pis AS "perc_pis"
    , i.perc_cofins AS "perc_cofins"
    , i.Ncm AS "tipi_ncm"
        , ((i.pr_unitario * i.quantidade)
            + i.Vl_substituicao
            + i.Vl_ipi
            + i.Vl_seguro
            + i.outras_desp_aces
            + i.Vl_frete
            - i.Vl_desconto
            - i.Vl_suframa) AS "Vlr Nota Fat" --AS vlr_fat_geral
    , CASE
            WHEN p.especie_nota != 'E'
            THEN (CASE 
                    WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (51))
                        THEN (i.Pr_total_item/1.1) - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (45))
                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (44)) 
                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (48))
                        THEN (i.Pr_total_item + i.Vl_frete) - i.Vl_suframa - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (52)) 
                        THEN (i.Pr_total_item + i.Vl_frete + i.Vl_seguro) - i.Vl_desconto 
                    ELSE     (i.Pr_total_item + i.Vl_frete + i.Vl_seguro + i.outras_desp_aces) - i.Vl_desconto 
              END)
            ELSE NULL 
          END AS "Vlr Gerencial Fat" --AS vlr_gerencial
    
    , concat(ltrim(rtrim(prod.codigo_fabrica)), '-', ltrim(rtrim(prod.descricao)), ' - ', 
        ( SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i2.cd_carac,1,CHARINDEX(';',i2.Cd_Carac,2)),0,0,prod.campo82,0,' '))
        FROM  ppident i2(nolock)
      WHERE i2.identificador = i.Cd_Especif1 AND i2.Sequencial = 1))             AS "Fabrica"
    , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
    , tg.Categoria as "Setor Leroy"
    --, ean.Categoria as "EAN"
FROM fanfisca p (nolock)
INNER JOIN esmovime i (nolock)   ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND (p.especie_nota = 'S' OR p.especie_nota = 'N'))
INNER JOIN FANFISCA f (nolock)   ON (i.Nf = f.Nf and i.serie = f.Serie AND p.cd_unidade_de_n = f.cd_unidade_de_n)
LEFT JOIN geempres cl (nolock)   ON (p.cd_cliente = cl.cd_empresa)
LEFT JOIN geempres cl2 (nolock)  ON (cl.cd_centralizado = cl2.cd_empresa)
LEFT JOIN geempres r (nolock)    ON (p.cd_representant = r.cd_empresa)
LEFT JOIN geestado ge (nolock)   ON (ge.Codigo_estado = r.Uf and ge.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN lfregiao reg (nolock)  ON (ge.Cd_regiao = reg.Cd_regiao)
LEFT JOIN esmateri prod (nolock) ON (i.Cd_material = prod.cd_material)
--LEFT JOIN esmateri prodAgrupamento (nolock) ON (prod.Referencia = prodAgrupamento.Codigo_fabrica)
LEFT JOIN temateriallinha gp (nolock) ON (gp.material = i.cd_material)
LEFT JOIN tegrupoproduto dgp (nolock) ON (dgp.nome_grupo = gp.grupo_produto)
LEFT JOIN eses1 c (nolock) ON (CAST(c.cd_especif1 AS INTEGER) = i.cd_especif1)
LEFT JOIN geunidne e (nolock) ON (e.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN telinhaproduto tlp (nolock) ON (tlp.linha = gp.linha_produto)
LEFT JOIN gepais m1 (nolock) ON (m1.cd_pais = cl.cd_pais)
LEFT JOIN geestado m2 (nolock) ON (cl.uf = m2.codigo_estado and m2.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN tesubgrupoproduto tsgp (nolock) ON (tsgp.nome_subgrupo = gp.subgrupo_produto)
LEFT JOIN geempres t (nolock) ON (t.cd_empresa = p.cd_transportado)
LEFT JOIN  VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
LEFT JOIN ESGRUPO  j (nolock) ON (j.Cd_grupo = prod.Cd_grupo)
LEFT JOIN geempres r2 (nolock)  ON (r2.cd_empresa = cl.cd_representant)
LEFT JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
LEFT JOIN geelemen tg (nolock) ON (i.Cd_material = tg.Elemento and tg.Cd_tg = 632)
--LEFT JOIN geelemen ean(nolock) ON (i.Cd_material = ean.Elemento and ean.Cd_tg = 100)
WHERE 
    i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (803))
    AND p.dt_emissao >= CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0) AS DATE)
    AND p.dt_emissao <= CAST(DATEADD(YEAR, - 1, GETDATE()) AS DATE)
	AND prod.Cd_origem_merca <> ' ' AND p.cd_unidade_de_n <> ' ')
    
UNION ALL

--Devolução
SELECT
    CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(cl.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(p.cd_fornecedor)) IS NULL OR LTRIM(RTRIM(p.cd_fornecedor)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_fornecedor)) END)
    , ')'
    ) AS "Cliente"
    , cl.Fone AS "Cliente Fone"
    , CONCAT(cl.Endereco, ' - ', cl.Numero) AS "Cliente Endereço"
    , cl.Bairro AS "Cliente Bairro"
    , cl.Municipio AS "Cliente Municipio"  
    , cl.Dt_ultimo_movim AS "Periodo Ultima Compra"
    ,cl.Divisao AS "Divisao Cliente"
    , CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(cl2.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END)
    , ')'
    ) AS "Agrupamento Cliente"
        
        , CONCAT((CASE WHEN LTRIM(RTRIM(i.cd_especif1)) IS NULL OR LTRIM(RTRIM(i.cd_especif1)) = '' THEN '0' ELSE LTRIM(RTRIM(i.cd_especif1)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(c.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(c.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(c.descricao))) END)) AS "Cor" 
        , (CASE WHEN UPPER(LTRIM(RTRIM(c.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(c.descricao))) = '' THEN '0 - NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(c.descricao))) END) AS "CorD" 
        , CONCAT((CASE WHEN LTRIM(RTRIM(p.cd_unidade_de_n)) IS NULL OR LTRIM(RTRIM(p.cd_unidade_de_n)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_unidade_de_n)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(e.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(e.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(e.Nome_completo))) END)) AS "Empresa" 
        , p.cd_unidade_de_n
        , (CASE WHEN m2.codigo_estado = 'EX' THEN 'EXTERNO' ELSE 'INTERNO' END) AS "Mercado" 
    , '0' AS "Pedido"
    
    , CAST((CASE 
      WHEN p.Dt_entrada IS NULL
      THEN '1900-01-01'
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_entrada), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_entrada) + 1), '-', DATEPART(MONTH, p.Dt_entrada),'-', DATEPART(DAY, p.Dt_entrada)) AS DATE)), 0)
    END) AS DATE) AS "Periodo" 
    , CAST((CASE 
      WHEN p.Dt_modificacao IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_modificacao), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_modificacao) + 1), '-', DATEPART(MONTH, p.Dt_modificacao),'-', DATEPART(DAY, p.Dt_modificacao)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Modificacao" 
        , CAST(NULL AS DATE) AS "Periodo Romaneio" 
        , CAST((CASE 
      WHEN p.Dt_emissao IS NULL
      THEN NULL
      ELSE DATEADD(yy, 1, DATEADD(mm, DATEDIFF(mm, 0, p.Dt_emissao), 0))
--      ELSE DATEADD(mm, DATEDIFF(mm, 0, CAST( CONCAT( (DATEPART(YEAR, p.Dt_emissao) + 1), '-', DATEPART(MONTH, p.Dt_emissao),'-', DATEPART(DAY, p.Dt_emissao)) AS DATE)), 0)
    END) AS DATE) AS "Periodo Saida" 
    
    , CONCAT(
      (CASE WHEN RTRIM(LTRIM(prod.Referencia)) IS NULL OR RTRIM(LTRIM(prod.Referencia)) = '' THEN '0' ELSE RTRIM(LTRIM(prod.Referencia)) END)
      , ' - ',
      (CASE WHEN prod.descricao IS NULL OR prod.descricao IS NULL THEN 'NAO INFORMADO' ELSE prod.descricao END)
    ) AS "Produto" 
    , cl.atividade + ' - ' + ve.descricao AS  "Segmento"
      , prod.Cd_origem_merca AS "origem"
/*               , CONCAT(
      (CASE WHEN RTRIM(LTRIM(prodAgrupamento.Referencia)) IS NULL OR RTRIM(LTRIM(prodAgrupamento.Referencia)) = '' THEN '0' ELSE RTRIM(LTRIM(prodAgrupamento.Referencia)) END)
      , ' - ',
      (CASE WHEN prodAgrupamento.descricao IS NULL OR prodAgrupamento.descricao IS NULL THEN 'NAO INFORMADO' ELSE prodAgrupamento.descricao END)
    ) AS "Produto Agrupador" */
    , CONCAT((CASE WHEN RTRIM(LTRIM(gp.grupo_produto)) IS NULL OR RTRIM(LTRIM(gp.grupo_produto)) = '' THEN '0' ELSE RTRIM(LTRIM(gp.grupo_produto)) END), ' - ', CASE WHEN UPPER(LTRIM(RTRIM(dgp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(dgp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(dgp.descricao))) END) AS "Catalogo Produto" 
    , CONCAT((CASE WHEN LTRIM(RTRIM(gp.subgrupo_produto)) IS NULL OR LTRIM(RTRIM(gp.subgrupo_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.subgrupo_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tsgp.descicao))) IS NULL OR UPPER(LTRIM(RTRIM(tsgp.descicao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tsgp.descicao))) END)) AS "Sub Grupo Produto"
    , CONCAT((CASE WHEN LTRIM(RTRIM(gp.linha_produto)) IS NULL OR LTRIM(RTRIM(gp.linha_produto)) = '' THEN '0' ELSE LTRIM(RTRIM(gp.linha_produto)) END), ' - ', (CASE WHEN UPPER(LTRIM(RTRIM(tlp.descricao))) IS NULL OR UPPER(LTRIM(RTRIM(tlp.descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(tlp.descricao))) END)) AS "Linha Produto"   
            
    , CASE WHEN UPPER(LTRIM(RTRIM(cl.Uf))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Uf))) = '' THEN 'N/I' ELSE UPPER(LTRIM(RTRIM(cl.Uf))) END AS "UF"
        , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
        , LTRIM(RTRIM(r2.cd_empresa)) AS "Cod_Representante_Carteira"
        , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END
        ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')'
        ) AS "Representante Carteira"
    
    , CONCAT(
    (CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END)
    , ' ('
    , (CASE WHEN LTRIM(RTRIM(r.cd_representant)) IS NULL OR LTRIM(RTRIM(r.cd_representant)) = '' THEN '0' ELSE LTRIM(RTRIM(r.cd_representant)) END)
    , ')'
    ) AS "Representante"
    , r.cd_representant AS "Codigo Representante"
    , '0 - NAO INFORMADO' AS "Transportador"
    , 'DEVOLUCAO' AS "Tipo Faturamento"
    , CONCAT((CASE WHEN i.serie IS NULL OR i.serie = '' THEN '0' ELSE i.serie END), ' - ', CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR)) AS "Qtde Faturas"
    , -1 AS "Qtde Itens Nota Fat" --as qtde_itens_nota --Quntidade de itens diferentes na nota
    , i.quantidade*-1 AS "Qtde Pecas Nota Fat" --as qtd_pecas --Quantidade de cada item na nota
    , i.pr_unitario*-1 AS "Vlr Unitario Fat" --as vlr_unitario
    , i.peso_total_item*-1 AS "Peso Fat" --as peso_total_item
    , i.Vl_base_subst*-1 AS "Vl_base_subst"
    , i.Vl_base_substit*-1 AS "Vl_base_substit"
    , i.Vl_desconto*-1 AS "Vlr Desc Fat" --as Vl_desconto
    , i.Vl_enc_financ*-1 AS "Vl_enc_financ"
    , i.Vl_frete*-1 AS "Vlr Frete Fat" --as Vl_frete
    , i.Vl_icms*-1 AS "Vlr ICMS Fat" --as Vl_icms
    , i.Vl_ipi*-1 AS "Vlr IPI Fat" --as Vl_ipi
    , i.Vl_ipi_obs*-1 as Vl_ipi_obs
    , i.Vl_seguro*-1 AS "Vlr Seguro Fat" --as Vl_seguro
    , i.Vl_substituicao*-1 AS "Vlr ST Fat" --as Vl_substituicao
    , i.Vl_suframa*-1 AS "Vlr Suf Fat" --as Vl_suframa
    , ((i.pr_unitario * i.quantidade)*-1) AS "Vlr Produto Fat" --AS vlr_nominal
    , i.outras_desp_aces*-1 AS "Vlr Acessorias" --AS vlr_acessorias
    , i.perc_ipi*-1 as perc_ipi
    , i.perc_icms*-1 as perc_icms
    , i.perc_pis*-1 as perc_pis
    , i.perc_cofins*-1 as perc_cofins
    , i.Ncm AS tipi_ncm
    , (((i.pr_unitario * i.quantidade)
            + i.Vl_substituicao
            + i.Vl_ipi
            + i.Vl_seguro
            + i.outras_desp_aces
            + i.Vl_frete
            - i.Vl_desconto
            - i.Vl_suframa) * -1) AS "Vlr Nota Fat" --AS vlr_fat_geral
    
    , ((CASE WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (47))
                             THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa
                                 
                             WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (46))
                             THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item - i.Vl_icms + i.Vl_frete)*0.0925
                             
                             WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (49))
                             THEN ((i.Pr_total_item + i.Vl_frete) -i.Vl_suframa)
                             
                             WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (59))
                             THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item - i.Vl_icms + i.Vl_frete)*0.0925
                             
                             WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (61))
                             THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.1625 - i.Vl_suframa

                             WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (63))
                             THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete) * 0.0365

                             ELSE (i.Pr_total_item +  i.Vl_frete) - i.Vl_desconto END
                    )*-1) AS "Vlr Gerencial Fat" --AS vlr_gerencial
    
    , concat(ltrim(rtrim(prod.codigo_fabrica)), '-', ltrim(rtrim(prod.descricao)), ' - ', 
        ( SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i2.cd_carac,1,CHARINDEX(';',i2.Cd_Carac,2)),0,0,prod.campo82,0,' '))
        FROM  ppident i2(nolock)
      WHERE i2.identificador = i.Cd_Especif1 AND i2.Sequencial = 1))             AS "Fabrica"
    , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
    , tg.Categoria as "Setor Leroy"
    --, ean.Categoria as "EAN"
FROM coentrad p (NOLOCK)
LEFT JOIN esmovime i (nolock) ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND p.Cd_fornecedor = i.Cd_empresa)
LEFT JOIN geempres cl (nolock) ON (p.cd_fornecedor = cl.cd_empresa)
LEFT JOIN geempres cl2 (nolock) ON (cl.cd_centralizado = cl2.cd_empresa)
LEFT JOIN geempres r (nolock) ON (r.cd_empresa = (select gei.cd_representant from geempres gei (NOLOCK) where gei.cd_empresa = p.cd_fornecedor) and p.cd_unidade_de_n = r.cd_unidade_de_n)
LEFT JOIN geestado ge (nolock) ON (ge.Codigo_estado = r.Uf and ge.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN lfregiao reg (nolock) ON (ge.Cd_regiao = reg.Cd_regiao)
LEFT JOIN eses1 c (nolock) ON (CAST(c.cd_especif1 AS INTEGER) = i.cd_especif1)
LEFT JOIN geunidne e (nolock) ON (e.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN gepais m1 (nolock) ON (m1.cd_pais = cl.cd_pais)
LEFT JOIN geestado m2 (nolock) ON (cl.uf = m2.codigo_estado and m2.Cd_unidade_de_n = p.cd_unidade_de_n)
LEFT JOIN esmateri prod (nolock) ON (i.Cd_material = prod.cd_material)
--LEFT JOIN esmateri prodAgrupamento (nolock) ON (prod.Referencia = prodAgrupamento.Codigo_fabrica)
LEFT JOIN temateriallinha gp (nolock) ON (gp.material = i.cd_material)
LEFT JOIN tegrupoproduto dgp (nolock) ON (dgp.nome_grupo = gp.grupo_produto)
LEFT JOIN tesubgrupoproduto tsgp (nolock) ON (tsgp.nome_subgrupo = gp.subgrupo_produto)
LEFT JOIN telinhaproduto tlp (nolock)     ON (tlp.linha = gp.linha_produto)
LEFT JOIN  VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
LEFT JOIN ESGRUPO  j (nolock) ON (j.Cd_grupo = prod.Cd_grupo)
LEFT JOIN geempres r2 (nolock)  ON (r2.cd_empresa = cl.cd_representant)
LEFT JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
LEFT JOIN geelemen tg(nolock) ON (i.Cd_material = tg.Elemento and tg.Cd_tg = 632)
--LEFT JOIN geelemen ean(nolock) ON (i.Cd_material = ean.Elemento and ean.Cd_tg = 100)

WHERE RTRIM(LTRIM(p.tipo_nota)) = 'D'
    AND i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (6,803))
    AND p.Dt_entrada >= CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0) AS DATE)
    AND p.Dt_entrada <= CAST(DATEADD(YEAR, - 1, GETDATE()) AS DATE)
    AND prod.Cd_origem_merca <> ' ' AND p.cd_unidade_de_n <> ' '