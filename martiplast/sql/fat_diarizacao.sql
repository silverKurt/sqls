SELECT    "Periodo"
        , "Periodo" AS "Periodo Filtro"
        , "Cliente"
        , "Cliente CNPJ"
        , "Cliente Agrupador CNPJ"
        , "Periodo Ultima Compra"
        , MIN("Dias Sem Faturamento") AS "Dias Sem Faturamento"
        , "Divisao Cliente"
        , "Cd Cliente Agrupador"
        , "Agrupamento Razao Social"
        , (CASE WHEN  "Cd Cliente Agrupador" = '000632' THEN 'SIM'
             ELSE 'NAO' end) as 'Somente Leroy'
        , "Agrupamento Cliente"
        , (CASE  WHEN "UF" = 'EX' THEN 'EXPORTACAO'
                WHEN "Cod_Representante_Carteira" = '000129' AND "Cd Cliente Agrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
                WHEN "Cod_Representante_Carteira" = '000129' THEN 'SUL'
                WHEN "Cod_Representante_Carteira" = '038240' AND "UF" IN ('MA') THEN 'NORDESTE'
                WHEN "Cod_Representante_Carteira" = '038240' AND "UF" IN ('TO') THEN 'NORTE'
                WHEN (("Regiao" = null) OR ("Regiao"  ='.') or ("Regiao" = '') or ("Cod_Representante_Carteira" = '' ) or ("Representante" = '999998' ))  THEN '* VENDA DIRETA'
                ELSE  "Regiao"
        END) AS  "Regiao"
        , "UF"
        , "Cod_Representante"
        , "Cod_Representante_Carteira"
        , "Representante" 
        , "Representante Carteira" 
        , "Responsavel" 
        , "Tipo Faturamento" 
        , "Periodo Cad Cliente"
        , "Periodo Cad Cliente" as "Periodo Cad Cliente Filtro"
        , "CFOP"
        , "Segmento"
        , "GEO_CLIENTE"
        , "GEO_CLIENTE_AGRUPADOR"
        , "Municipio Cliente"
        , "Municipio Agrupador"
        
        , (CASE WHEN DATEDIFF ( MONTH , "Periodo" , "Periodo Cad Cliente" ) = 0 THEN 'Novos Cliente'
              ELSE 'Carteria Consolidada' 
        END) AS "Tipo de Carteria"
        
        , "Cod_Cliente" AS "Qtde Clientes"
        
        , (CASE
              WHEN "Tipo devoluções" = 1 then 'Avarias na embalagem' --INATIVAR
              WHEN "Tipo devoluções" = 2 then 'Quebra em loja'
              WHEN "Tipo devoluções" = 3 then 'Falta caixa lacrada'
              WHEN "Tipo devoluções" = 4 then 'Divergência cor'
              WHEN "Tipo devoluções" = 5 then 'Divergência de Produto - ALMOX'
              WHEN "Tipo devoluções" = 6 then 'Divergência de Pedido - COML'
              WHEN "Tipo devoluções" = 7 then 'Divergência cadastro do cliente'
              WHEN "Tipo devoluções" = 8 then 'Divergência EAN / DUN'--INATIVAR
              WHEN "Tipo devoluções" = 9 then 'Acordo Comercial'
              WHEN "Tipo devoluções" = 10 then 'Falta de volumes'
              WHEN "Tipo devoluções" = 11 then 'Erro digitação representante'--INATIVAR
              WHEN "Tipo devoluções" = 12 then 'Nota fiscal emitida sem autorização'--INATIVAR
              WHEN "Tipo devoluções" = 13 then 'Pedido cancelado pelo cliente'
              WHEN "Tipo devoluções" = 14 then 'Avaria Produto'
              WHEN "Tipo devoluções" = 15 then 'Pedido em duplicidade'
              WHEN "Tipo devoluções" = 16 then 'Perda de agendamento'
              WHEN "Tipo devoluções" = 17 then 'Defeito de fabricação'
              WHEN "Tipo devoluções" = 18 then 'Prazo limite de entrega excedido'
              WHEN "Tipo devoluções" = 19 then 'Divergência de Produto - VENDAS'
              WHEN "Tipo devoluções" = 35 then 'Avaria transporte'
              WHEN "Tipo devoluções" = 36 then 'Divergência de pedido - VENDAS'
              WHEN "Tipo devoluções" = 37 then 'Acordo Comercial - LEROY'
              WHEN "Tipo devoluções" = 104 then 'Divergência de pedido - TNF (VENDAS)'
              WHEN "Tipo devoluções" = 105 then 'Divergência de pedido - TNF (ALMOX)'
              WHEN "Tipo devoluções" = 106 then 'Divergência de pedido - TNF (ALMOX)'
              WHEN "Tipo devoluções" = 107 then 'Divergência de pedido - TNF (COML)'
              WHEN "Tipo devoluções" = 109 then 'Acordo Comercial - TNF'
              WHEN "Tipo devoluções" = 110 then 'Falta de volumes - TNF'
              WHEN "Tipo devoluções" = 118 then 'Prazo limite de entrega excedido - TNF'
        else 'Outros' end) AS "Tipo devoluções"
            
            , "NF_Serie"                       AS "NF Serie"
            , SUM(Base_Difal) AS "Base_Difal"
            , SUM(Vr_Difal_Orig) AS "Vr_Difal_Orig"
            , SUM(Vr_Difal_Des) AS "Vr_Difal_Des"
            , SUM(Perc_Difal_Orig) AS "Perc_Difal_Orig"
            , SUM("Qtde Cxs")                 AS "Qtde Cxs"
            , SUM("Qtde Pecas")               AS "Qtde Pecas"
            , COUNT(DISTINCT "NF_Serie")      AS "Qtde Faturas"
            , SUM(Vl_base_subst)              AS "Vl_base_subst"
            , SUM(Vl_base_substit)            AS "Vl_base_substit"
            , SUM("Vlr Desc Fat")             AS "Vlr Desc Fat"
            , SUM(Vl_enc_financ)              AS "Vl_enc_financ"
            , SUM("Vlr Frete Fat")            AS "Vlr Frete Fat"
            , SUM("Vlr ICMS Fat")             AS "Vlr ICMS Fat"
            , SUM("Vlr IPI Fat")              AS "Vlr IPI Fat"
            , SUM(Vl_ipi_obs)                 AS "Vl_ipi_obs"
            , SUM("Vlr Seguro Fat")           AS "Vlr Seguro Fat"
            , SUM("Vlr ST Fat")               AS "Vlr ST Fat"
            , SUM("Vlr Suf Fat")              AS "Vlr Suf Fat"
            , SUM("Vlr Acessorias")           AS "Vlr Acessorias"
            , SUM("Vlr Nota Fat")             AS "Vlr Nota Fat"
            , SUM("Vlr Gerencial Fat")        AS "Vlr Gerencial Fat"
            , SUM("Vlr Entrada Bonificacao")  AS "Vlr Entrada Bonificacao"
            , "Unidade de Negocio"
            , "Ordem de Compra" 
            , "NCM"
FROM (
    SELECT
       "Periodo"
           , "Cliente"
           , "Cliente CNPJ"
           , "Cliente Agrupador CNPJ"
           , "Periodo Ultima Compra"
           , MIN("Dias Sem Faturamento") AS "Dias Sem Faturamento"
           , "Divisao Cliente"
           , "Cd Cliente Agrupador"
           , "Agrupamento Cliente"
           , "Agrupamento Razao Social"
           , "Responsavel" 
           , "CFOP"
           , "Regiao"
           , "Cod_Representante_Carteira"
           , "UF"
           , "Cod_Representante"
           , "Representante" 
           , "Representante Carteira"
           , "Tipo Faturamento" 
           , "Periodo Cad Cliente"
           , "Cod_Cliente"
           , "Tipo devoluções"
           , "Segmento"
           , "GEO_CLIENTE"
           , "GEO_CLIENTE_AGRUPADOR"
           , "Municipio Cliente"
           , "Municipio Agrupador"
           , SUM(Base_Difal) AS "Base_Difal"
           , SUM(Vr_Difal_Orig) AS "Vr_Difal_Orig"
           , SUM(Vr_Difal_Des) AS "Vr_Difal_Des"
           , SUM(Perc_Difal_Orig) AS "Perc_Difal_Orig"
           , SUM( CAST("Qtde Cxs" AS BIGINT) ) as "Qtde Cxs"
           , CONCAT("NF", ' - ', "Serie NF") AS "NF_Serie"
           , SUM("Qtde Pecas")  as "Qtde Pecas"
           , SUM(Vl_base_subst) AS Vl_base_subst
           , SUM(Vl_base_substit) AS Vl_base_substit
           , SUM("Vlr Desc Fat") AS "Vlr Desc Fat"
           , SUM(Vl_enc_financ) AS Vl_enc_financ
           , SUM("Vlr Frete Fat") AS "Vlr Frete Fat"
           , SUM("Vlr ICMS Fat") AS "Vlr ICMS Fat"
           , SUM("Vlr IPI Fat") AS "Vlr IPI Fat"
           , SUM(Vl_ipi_obs) AS Vl_ipi_obs
           , SUM("Vlr Seguro Fat") AS "Vlr Seguro Fat"
           , SUM("Vlr ST Fat") AS "Vlr ST Fat"
           , SUM("Vlr Suf Fat") AS "Vlr Suf Fat"
           , SUM("Vlr Acessorias") AS "Vlr Acessorias"
           , SUM("Vlr Nota Fat") AS "Vlr Nota Fat"
           , SUM("Vlr Gerencial Fat") AS "Vlr Gerencial Fat"
           , SUM("Vlr Entrada Bonificacao") AS "Vlr Entrada Bonificacao" 
           , "Unidade de Negócio" AS "Unidade de Negocio"
           , "Ordem de Compra"
           , "tipi_ncm" as "NCM"
        FROM (
        -- Venda
               (SELECT
                    concat('Brasil',',',cl.Uf,',',cl.Municipio,',',cl.Bairro,',',cl.Endereco) as GEO_CLIENTE
                    , concat('Brasil',',',cl2.Uf,',',cl2.Municipio,',',cl2.Bairro,',',cl2.Endereco) as GEO_CLIENTE_AGRUPADOR
                    , cl.Municipio as "Municipio Cliente"
                    , cl2.Municipio as "Municipio Agrupador"
                    , p.Dt_emissao AS "Periodo"
                    , CONCAT(
                            (CASE WHEN UPPER(LTRIM(RTRIM(cl3.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl3.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl3.Nome_completo))) END)
                            , ' ('
                            , (CASE WHEN LTRIM(RTRIM(cl3.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl3.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl3.cd_empresa)) END)
                            , ')'
                            ) AS "Responsavel" 
                    , CONCAT(
                            (CASE WHEN UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.Nome_completo))) END)
                            , ' ('
                            , (CASE WHEN LTRIM(RTRIM(p.cd_cliente)) IS NULL OR LTRIM(RTRIM(p.cd_cliente)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_cliente)) END)
                            , ')'
                            ) AS "Cliente"
                    , CONCAT(
                            (CASE WHEN LTRIM(RTRIM(cl.cnpj_cpf)) IS NULL OR LTRIM(RTRIM(cl.cnpj_cpf)) = '' THEN '0' ELSE LTRIM(RTRIM(cl.cnpj_cpf)) END)
                            , ' - '
                            , (CASE WHEN UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.Nome_completo))) END)
                            ) AS "Cliente CNPJ"
                    , CONCAT(
                            (CASE WHEN LTRIM(RTRIM(cl2.cnpj_cpf)) IS NULL OR LTRIM(RTRIM(cl2.cnpj_cpf)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cnpj_cpf)) END)
                            , ' - '
                            , (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
                            ) AS "Cliente Agrupador CNPJ"
                    , cl.campo70 AS "Periodo Ultima Compra" 
                    , DATEDIFF(DAY, CAST(cl.campo70 AS DATE), CAST(GETDATE() AS DATE)) AS "Dias Sem Faturamento"
                    , cl.Divisao AS "Divisao Cliente"
                  , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
                    , CONCAT(
                             (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
                             , ' ('
                             , (CASE WHEN LTRIM(RTRIM(cl2.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END)
                             , ')'
                             ) AS "Agrupamento Cliente"
                    ,  UPPER(LTRIM(RTRIM(cl2.Nome_completo))) AS "Agrupamento Razao Social"
                    , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
                    , CASE WHEN UPPER(LTRIM(RTRIM(cl.Uf))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Uf))) = '' THEN 'N/I' ELSE UPPER(LTRIM(RTRIM(cl.Uf))) END AS "UF"
                    , LTRIM(RTRIM(r.cd_empresa)) AS "Cod_Representante"
                    , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END
                        , ' ('
                        , CASE WHEN LTRIM(RTRIM(r.cd_empresa)) IS NULL OR LTRIM(RTRIM(r.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r.cd_empresa)) END
                        , ')'
                        ) AS "Representante"
                        
                    , LTRIM(RTRIM(r2.cd_empresa)) AS "Cod_Representante_Carteira"
                        
                    , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END
                            ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')'
                    ) AS "Representante Carteira"
                    , 'VENDA' AS "Tipo Faturamento"
                    , CASE WHEN CAST(LTRIM(RTRIM(p.serie)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(p.serie)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(p.serie)) AS VARCHAR) END AS "Serie NF"
                    , CASE WHEN CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR) END AS "NF"
                , ltrim(rtrim(cl.atividade)) + ' - ' + ltrim(rtrim(ve.descricao)) AS  "Segmento"
                    , i.cfop as "CFOP"
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
                    , i.outras_desp_aces AS "Vlr Acessorias" --AS vlr_acessorias
                    , i.perc_ipi AS "perc_ipi"
                    , i.perc_icms AS "perc_icms"
                    , i.perc_pis AS "perc_pis"
                    , i.perc_cofins AS "perc_cofins"
                    , i.Ncm AS "tipi_ncm"
                    , i.quantidade as "Qtde Pecas"
                    , RTRIM(LTRIM(p.Quantidade)) as "Qtde Cxs"
                    , ((i.pr_unitario * i.quantidade)
                                      + i.Vl_substituicao
                                      + i.Vl_ipi
                                      + i.Vl_seguro
                                      + i.outras_desp_aces
                                      + i.Vl_frete
                                      - i.Vl_desconto
                                      - i.Vl_suframa) AS "Vlr Nota Fat" --AS vlr_fat_geral
                         /*,(CASE 
                                WHEN i.Cd_tp_operacao = '6113A'  
                                        THEN (i.Pr_total_item/1.1) - i.Vl_desconto
                                WHEN i.Cd_tp_operacao IN ('6109A', '6109B') 
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa
                                WHEN i.Cd_tp_operacao IN ('6109C','6109F') 
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365
                                WHEN i.Cd_tp_operacao IN ('6110A', '6110B', '6110C', '6110F', '6110G', '6102O') 
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_desconto
                                WHEN i.Cd_tp_operacao IN ('6109D', '6109E')
                                        THEN (i.Pr_total_item + i.Vl_frete) - i.Vl_suframa
                                WHEN i.Cd_tp_operacao = '6113B'
                                        THEN (i.Pr_total_item + i.Vl_frete + i.Vl_seguro) - i.Vl_desconto 
                                ELSE         (i.Pr_total_item + i.Vl_frete + i.Vl_seguro + i.outras_desp_aces) - i.Vl_desconto 
                          END) AS "Vlr Gerencial Fat" --AS vlr_gerencial */
                    , (CASE 
                            WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (51)) 
                                    THEN (i.Pr_total_item/1.1) - i.Vl_desconto
                            WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (45)) 
                                    THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa
                            WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (44)) 
                                    THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365
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
                    END) AS "Vlr Gerencial Fat" --AS vlr_gerencial
                , NULL AS "Vlr Entrada Bonificacao"
                    , cl.Dt_cadastro AS "Periodo Cad Cliente"
                    , LTRIM(RTRIM(cl.cd_empresa)) AS "Cod_Cliente"
                , '' as "Tipo devoluções"
                , fa.Base_Difal
                , fa.Vr_Difal_Orig
                , fa.Vr_Difal_Des
                , fa.Perc_Difal_Orig
                , (CASE WHEN  p.cd_unidade_de_n = 1 THEN 'OU'
                         WHEN  p.cd_unidade_de_n = 2 THEN 'YOI'
                         else NULL 
                   end) as "Unidade de Negócio"
                , p.Cd_ordem_compra as "Ordem de Compra"
                --, ncm.ncm as "NCM"
                FROM fanfisca p (nolock)
                INNER JOIN esmovime i (nolock) ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND (p.especie_nota = 'S' OR p.especie_nota = 'N'))
                INNER JOIN FANFISCA f (nolock) ON (i.Nf = f.Nf and i.serie = f.Serie AND p.cd_unidade_de_n = f.cd_unidade_de_n)
                LEFT JOIN geempres r (nolock) ON (r.cd_empresa  = p.cd_representant )
                LEFT JOIN geempres cl (nolock) ON (cl.cd_empresa = p.cd_cliente)
                LEFT JOIN geempres r2 (nolock) ON (r2.cd_empresa = cl.cd_representant)
                LEFT JOIN geempres cl2 (nolock) ON (cl.cd_centralizado = cl2.cd_empresa )
                LEFT JOIN geempres cl3 (nolock) ON (cl.Cd_responsavel = cl3.cd_empresa)
                LEFT JOIN vemercad re (nolock)  ON (r2.cd_mercado = re.cd_mercado)
                LEFT JOIN VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
                LEFT JOIN facomple fa (nolock)  ON (fa.nf = i.nf and fa.sequencia =0 and fa.serie = i.serie and p.cd_unidade_de_n = fa.uni_negocio)
                --LEFT JOIN ESCLASFI ncm (nolock) ON (i.ncm = ncm.Classificacao_f)
                WHERE i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (6))
                AND p.dt_emissao >= '2011-01-01'
                AND f.Especie_nota <> 'N'
                )
                
                UNION ALL

                --Bonificação
                (SELECT  
                    concat('Brasil',',',cl.Uf,',',cl.Municipio,',',cl.Bairro,',',cl.Endereco) as GEO_CLIENTE
                        , concat('Brasil',',',cl2.Uf,',',cl2.Municipio,',',cl2.Bairro,',',cl2.Endereco) as GEO_CLIENTE_AGRUPADOR
                        , cl.Municipio as "Municipio Cliente"
                        , cl2.Municipio as "Municipio Agrupador"
                        , p.Dt_emissao AS "Periodo"
                        , CONCAT(
                                (CASE WHEN UPPER(LTRIM(RTRIM(cl3.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl3.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl3.Nome_completo))) END)
                                , ' ('
                                , (CASE WHEN LTRIM(RTRIM(cl3.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl3.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl3.cd_empresa)) END)
                                , ')'
                                ) AS "Responsavel" 
                        , CONCAT(
                                (CASE WHEN UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.Nome_completo))) END)
                                , ' ('
                                , (CASE WHEN LTRIM(RTRIM(p.cd_cliente)) IS NULL OR LTRIM(RTRIM(p.cd_cliente)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_cliente)) END)
                                , ')'
                                ) AS "Cliente"
                        , CONCAT(
                                (CASE WHEN LTRIM(RTRIM(cl.cnpj_cpf)) IS NULL OR LTRIM(RTRIM(cl.cnpj_cpf)) = '' THEN '0' ELSE LTRIM(RTRIM(cl.cnpj_cpf)) END)
                                , ' - '
                                , (CASE WHEN UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.Nome_completo))) END)
                                ) AS "Cliente CNPJ"
                        , CONCAT(
                                (CASE WHEN LTRIM(RTRIM(cl2.cnpj_cpf)) IS NULL OR LTRIM(RTRIM(cl2.cnpj_cpf)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cnpj_cpf)) END)
                                , ' - '
                                , (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
                                ) AS "Cliente Agrupador CNPJ"
                        , cl.campo70 AS "Periodo Ultima Compra" 
                        , CAST(NULL AS DOUBLE PRECISION) AS "Dias Sem Faturamento"
                        , cl.Divisao AS "Divisao Cliente"
                    , LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
                        , CONCAT(
                                (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
                                , ' ('
                                , (CASE WHEN LTRIM(RTRIM(cl2.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END)
                                , ')'
                                ) AS "Agrupamento Cliente"
                        , UPPER(LTRIM(RTRIM(cl2.Nome_completo))) AS "Agrupamento Razao Social"
                        , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"
                        , CASE WHEN UPPER(LTRIM(RTRIM(cl.Uf))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Uf))) = '' THEN 'N/I' ELSE UPPER(LTRIM(RTRIM(cl.Uf))) END AS "UF"
                        , LTRIM(RTRIM(r.cd_empresa)) AS "Cod_Representante"
                        , CONCAT(
                            CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END
                            , ' ('
                            , CASE WHEN LTRIM(RTRIM(r.cd_empresa)) IS NULL OR LTRIM(RTRIM(r.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r.cd_empresa)) END
                            , ')'
                            ) AS "Representante"
                        , LTRIM(RTRIM(r2.cd_empresa)) AS "Cod_Representante_Carteira"
                        , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END
                          ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')'
                        ) AS "Representante Carteira"
                        , 'BONIFICACAO' AS "Tipo Faturamento"
                        , CASE WHEN CAST(LTRIM(RTRIM(p.serie)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(p.serie)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(p.serie)) AS VARCHAR) END AS "Serie NF"
                        , CASE WHEN CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(p.nf)) AS VARCHAR) END AS "NF"
                  , ltrim(rtrim(cl.atividade)) + ' - ' + ltrim(rtrim(ve.descricao)) AS  "Segmento"
                        , i.cfop as "CFOP"
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
                        , i.outras_desp_aces AS "Vlr Acessorias" --AS vlr_acessorias
                        , i.perc_ipi AS "perc_ipi"
                        , i.perc_icms AS "perc_icms"
                        , i.perc_pis AS "perc_pis"
                        , i.perc_cofins AS "perc_cofins"
                        , i.Ncm AS "tipi_ncm"
                  , i.quantidade as "Qtde Pecas"
                  , RTRIM(LTRIM(p.Quantidade)) as "Qtde Cxs"
                        , ((i.pr_unitario * i.quantidade)
                                          + i.Vl_substituicao
                                          + i.Vl_ipi
                                          + i.Vl_seguro
                                          + i.outras_desp_aces
                                          + i.Vl_frete
                                          - i.Vl_desconto
                                          - i.Vl_suframa) AS "Vlr Nota Fat" --AS vlr_fat_geral
             /*   , CASE
            WHEN p.especie_nota != 'E'
            THEN (CASE 
                    WHEN i.Cd_tp_operacao = '6113A'  
                        THEN (i.Pr_total_item/1.1) - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN ('6109A', '6109B') 
                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN ('6109C','6109F') 
                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365
                    WHEN i.Cd_tp_operacao IN ('6110A', '6110B', '6110C', '6110F', '6110G', '6102O') 
                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_desconto
                    WHEN i.Cd_tp_operacao IN ('6109D', '6109E')
                        THEN (i.Pr_total_item + i.Vl_frete) - i.Vl_suframa - i.Vl_desconto
                    WHEN i.Cd_tp_operacao = '6113B'
                        THEN (i.Pr_total_item + i.Vl_frete + i.Vl_seguro) - i.Vl_desconto 
                    ELSE     (i.Pr_total_item + i.Vl_frete + i.Vl_seguro + i.outras_desp_aces) - i.Vl_desconto 
              END)
            ELSE NULL 
          END AS "Vlr Gerencial Fat" --AS vlr_gerencial */

                , CASE
                      WHEN p.especie_nota != 'E'
                    THEN (CASE 
                              WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (51))
                                  THEN (i.Pr_total_item/1.1) - i.Vl_desconto
                              WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (45))
                                  THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa - i.Vl_desconto
                              WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (44)) 
                                  THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365
                              WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (48))
                                  THEN (i.Pr_total_item + i.Vl_frete) - i.Vl_suframa - i.Vl_desconto
                              WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (52)) 
                                  THEN (i.Pr_total_item + i.Vl_frete + i.Vl_seguro) - i.Vl_desconto 
                              --WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (53))
                                    --THEN  (p.Total_mercadori)
                              ELSE     (i.Pr_total_item + i.Vl_frete + i.Vl_seguro + i.outras_desp_aces) - i.Vl_desconto 
                            END)
                    ELSE NULL 
                END AS "Vlr Gerencial Fat" --AS vlr_gerencial
          
              , CASE
                  WHEN p.especie_nota = 'E'
                  THEN ((i.pr_unitario * i.quantidade)
                                              + i.Vl_substituicao
                                              + i.Vl_ipi
                                              + i.Vl_seguro
                                              + i.outras_desp_aces
                                              + i.Vl_frete
                                    + i.outras_desp_aces
                                              - i.Vl_desconto
                                              - i.Vl_suframa)
                  ELSE NULL 
                END AS "Vlr Entrada Bonificacao" --AS vlr_gerencial
          
                    , cl.Dt_cadastro AS "Periodo Cad Cliente"
                    , LTRIM(RTRIM(cl.cd_empresa)) AS "Cod_Cliente"
                  , '' as "Tipo devoluções"
                  , fa.Base_Difal
                , fa.Vr_Difal_Orig
                , fa.Vr_Difal_Des
                , fa.Perc_Difal_Orig
                , (CASE WHEN  p.cd_unidade_de_n = 1 THEN 'OU'
                       WHEN  p.cd_unidade_de_n = 2 THEN 'YOI'
                       else NULL end ) as "Unidade de Negócio" 
                , p.Cd_ordem_compra as "Ordem de Compra"
                --, ncm.ncm as "NCM"
                FROM fanfisca p (nolock)
                INNER JOIN esmovime i (nolock) ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND (p.especie_nota = 'S' OR p.especie_nota = 'N' OR p.especie_nota = 'E'))
                INNER JOIN FANFISCA f (nolock) ON (i.Nf = f.Nf and i.serie = f.Serie AND p.cd_unidade_de_n = f.cd_unidade_de_n)
                LEFT JOIN geempres r (nolock) ON (r.cd_empresa  = p.cd_representant )
                LEFT JOIN geempres cl (nolock) ON (cl.cd_empresa = p.cd_cliente)
                LEFT JOIN geempres r2 (nolock) ON (r2.cd_empresa = cl.cd_representant)
                LEFT JOIN geempres cl2 (nolock) ON (cl.cd_centralizado = cl2.cd_empresa)
                LEFT JOIN geempres cl3 (nolock) ON (cl.Cd_responsavel = cl3.cd_empresa)
                LEFT JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
                LEFT JOIN  VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
                LEFT JOIN facomple fa (nolock) ON (fa.nf = i.nf and fa.sequencia =0 and fa.serie = i.serie and p.cd_unidade_de_n = fa.uni_negocio)
                --LEFT JOIN ESCLASFI ncm (nolock) ON (i.ncm = ncm.Classificacao_f)
                WHERE i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (803))
                AND p.dt_emissao >= '2011-01-01'
                AND f.Especie_nota <> 'N'
                )
                
                UNION ALL
                
                -- Devolucao
                (SELECT  
                    concat('Brasil',',',cl.Uf,',',cl.Municipio,',',cl.Bairro,',',cl.Endereco) as GEO_CLIENTE
                        , concat('Brasil',',',cl2.Uf,',',cl2.Municipio,',',cl2.Bairro,',',cl2.Endereco) as GEO_CLIENTE_AGRUPADOR
                        , cl.Municipio as "Municipio Cliente"
                        , cl2.Municipio as "Municipio Agrupador"        
                        , p.Dt_entrada AS "Periodo"
                        , CONCAT(
                                (CASE WHEN UPPER(LTRIM(RTRIM(cl3.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl3.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl3.Nome_completo))) END)
                                , ' ('
                                , (CASE WHEN LTRIM(RTRIM(cl3.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl3.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl3.cd_empresa)) END)
                                , ')'
                                ) AS "Responsavel" 
                        , CONCAT(
                                (CASE WHEN UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.Nome_completo))) END)
                                , ' ('
                                , (CASE WHEN LTRIM(RTRIM(p.cd_fornecedor)) IS NULL OR LTRIM(RTRIM(p.cd_fornecedor)) = '' THEN '0' ELSE LTRIM(RTRIM(p.cd_fornecedor)) END)
                                , ')'
                                ) AS "Cliente" 
                        , CONCAT(
                                (CASE WHEN LTRIM(RTRIM(cl.cnpj_cpf)) IS NULL OR LTRIM(RTRIM(cl.cnpj_cpf)) = '' THEN '0' ELSE LTRIM(RTRIM(cl.cnpj_cpf)) END)
                                , ' - '
                                , (CASE WHEN UPPER(LTRIM(RTRIM(cl.Nome_completo))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Nome_completo))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl.Nome_completo))) END)
                                ) AS "Cliente CNPJ"
                        , CONCAT(
                                (CASE WHEN LTRIM(RTRIM(cl2.cnpj_cpf)) IS NULL OR LTRIM(RTRIM(cl2.cnpj_cpf)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cnpj_cpf)) END)
                                , ' - '
                                , (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
                                ) AS "Cliente Agrupador CNPJ"
                                , cl.campo70 AS "Periodo Ultima Compra"
                                , CAST(NULL AS DOUBLE PRECISION) AS "Dias Sem Faturamento"
                                , cl.Divisao AS "Divisao Cliente"
                    ,LTRIM(RTRIM(cl2.cd_empresa)) as "Cd Cliente Agrupador"
                        , CONCAT(
                                (CASE WHEN UPPER(LTRIM(RTRIM(cl2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(cl2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(cl2.fantasia))) END)
                                , ' ('
                                , (CASE WHEN LTRIM(RTRIM(cl2.cd_empresa)) IS NULL OR LTRIM(RTRIM(cl2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(cl2.cd_empresa)) END)
                                , ')'
                                ) AS "Agrupamento Cliente"
                        , UPPER(LTRIM(RTRIM(cl2.Nome_completo))) AS "Agrupamento Razao Social"
                        , CASE WHEN UPPER(LTRIM(RTRIM(re.Descricao))) IS NULL OR UPPER(LTRIM(RTRIM(re.Descricao))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(re.Descricao))) END AS "Regiao"                        
                        , CASE WHEN UPPER(LTRIM(RTRIM(cl.Uf))) IS NULL OR UPPER(LTRIM(RTRIM(cl.Uf))) = '' THEN 'N/I' ELSE UPPER(LTRIM(RTRIM(cl.Uf))) END AS "UF"
                        , LTRIM(RTRIM(r.cd_empresa)) AS "Cod_Representante"
                        , CONCAT(
                            CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END
                            , ' ('
                            , LTRIM(RTRIM((select CASE WHEN gei.cd_representant IS NULL OR gei.cd_representant = '' THEN '0' ELSE gei.cd_representant END from geempres gei (nolock) where gei.cd_empresa = p.cd_fornecedor)))
                            , ')'
                            ) AS "Representante"
                        , LTRIM(RTRIM(r2.cd_empresa)) AS "Cod_Representante_Carteira"
                        , CONCAT( CASE WHEN UPPER(LTRIM(RTRIM(r2.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r2.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r2.fantasia))) END
                            ,' (', CASE WHEN LTRIM(RTRIM(r2.cd_empresa)) IS NULL OR LTRIM(RTRIM(r2.cd_empresa)) = '' THEN '0' ELSE LTRIM(RTRIM(r2.cd_empresa)) END, ')'
                            ) AS "Representante Carteira"
                        , 'DEVOLUCAO' AS "Tipo Faturamento"
                        , CASE WHEN CAST(LTRIM(RTRIM(i.serie)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(i.serie)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(i.serie)) AS VARCHAR) END AS "Serie NF"
                        , CASE WHEN CAST(LTRIM(RTRIM(i.nf)) AS VARCHAR) IS NULL OR CAST(LTRIM(RTRIM(i.nf)) AS VARCHAR) = '' THEN '0' ELSE CAST(LTRIM(RTRIM(i.nf)) AS VARCHAR) END AS "NF"
                  , ltrim(rtrim(cl.atividade)) + ' - ' + ltrim(rtrim(ve.descricao)) AS  "Segmento"
                        , i.cfop as "CFOP"
                        , i.Vl_base_subst*-1 as "Vl_base_subst"
                        , i.Vl_base_substit*-1 as "Vl_base_substit"
                        , i.Vl_desconto*-1 AS "Vlr Desc Fat" --as Vl_desconto
                        , i.Vl_enc_financ*-1 as "Vl_enc_financ"
                        , i.Vl_frete*-1 AS "Vlr Frete Fat" --as Vl_frete
                        , i.Vl_icms*-1 AS "Vlr ICMS Fat" --as Vl_icms
                        , i.Vl_ipi*-1 AS "Vlr IPI Fat" --as Vl_ipi
                        , i.Vl_ipi_obs*-1 as "Vl_ipi_obs"
                        , i.Vl_seguro*-1 AS "Vlr Seguro Fat" --as Vl_seguro
                        , i.Vl_substituicao*-1 AS "Vlr ST Fat" --as Vl_substituicao
                        , i.Vl_suframa*-1 AS "Vlr Suf Fat" --as Vl_suframa
                        , i.outras_desp_aces*-1 AS "Vlr Acessorias" --AS vlr_acessorias
                        , i.perc_ipi*-1 as "perc_ipi"
                        , i.perc_icms*-1 as "perc_icms"
                        , i.perc_pis*-1 as "perc_pis"
                        , i.perc_cofins*-1 as "perc_cofins"
                        , i.Ncm AS "tipi_ncm"
                  , i.quantidade as "Qtde Pecas"
                  , null as "Qtde Cxs"
                        , (((i.pr_unitario * i.quantidade)
                                           + i.Vl_substituicao
                                           + i.Vl_ipi
                                           + i.Vl_seguro
                                           + i.outras_desp_aces
                                           + i.Vl_frete
                                           - i.Vl_desconto
                                           - i.Vl_suframa) * -1) AS "Vlr Nota Fat" --AS vlr_fat_geral
                        /*,((CASE 
                                WHEN i.Cd_tp_operacao IN ('2203A','2203B','2203C') 
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa
                                WHEN i.Cd_tp_operacao IN ('2204A','2204B','2204C') 
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete) * 0.0365
                                WHEN i.Cd_tp_operacao IN ('2203D') 
                                        THEN ((i.Pr_total_item + i.Vl_frete) -i.Vl_suframa)
                                ELSE (i.Pr_total_item +  i.Vl_frete) - i.Vl_desconto END
                          )*-1) AS "Vlr Gerencial Fat" --AS vlr_gerencial */
                        , ((CASE 
                                WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (47))
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete)*0.0365 - i.Vl_suframa
                                WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (46))
                                        THEN (i.Pr_total_item + i.Vl_frete) - (i.Pr_total_item + i.Vl_frete) * 0.0365
                                WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (49))
                                        THEN ((i.Pr_total_item + i.Vl_frete) -i.Vl_suframa)
                                --WHEN i.Cd_tp_operacao IN (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (53))
                              --  THEN  (p.Total_mercadori)
                                ELSE (i.Pr_total_item +  i.Vl_frete) - i.Vl_desconto END
                          )*-1) AS "Vlr Gerencial Fat" --AS vlr_gerencial
              
                  , NULL AS "Vlr Entrada Bonificacao"  
                        , cl.Dt_cadastro AS "Periodo Cad Cliente"
                        , LTRIM(RTRIM(cl.cd_empresa)) AS "Cod_Cliente"
                  , documento_compl as "Tipo devoluções"
                  , fa.Base_Difal
                  , fa.Vr_Difal_Orig
                  , fa.Vr_Difal_Des
                  , fa.Perc_Difal_Orig
                  , (CASE WHEN  p.cd_unidade_de_n = 1 THEN 'OU'
                          WHEN  p.cd_unidade_de_n = 2 THEN 'YOI'
                          else NULL
                      end) as "Unidade de Negócio" 
                  , NULL as "Ordem de Compra"
             --, ncm.ncm as "NCM"
                FROM coentrad p (NOLOCK)
                LEFT JOIN esmovime i (nolock) ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND p.Cd_fornecedor = i.Cd_empresa)
                LEFT JOIN geempres r (nolock) ON (r.cd_empresa = (select gei.cd_representant from geempres gei (nolock) where gei.cd_empresa = p.cd_fornecedor) and p.cd_unidade_de_n = r.cd_unidade_de_n)
                LEFT JOIN geempres cl (nolock) ON (cl.cd_empresa = p.cd_fornecedor)
                LEFT JOIN geempres r2 (nolock) ON (r2.cd_empresa = cl.cd_representant)
                LEFT JOIN geempres cl2 (nolock) ON (cl.cd_centralizado = cl2.cd_empresa)
                LEFT JOIN geempres cl3 (nolock) ON (cl.Cd_responsavel = cl3.cd_empresa)
                LEFT JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
                LEFT JOIN  VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
                LEFT JOIN facomple fa (nolock) ON (fa.nf = i.nf and fa.sequencia =0 and fa.serie = i.serie and p.cd_unidade_de_n = fa.uni_negocio)
                --LEFT JOIN ESCLASFI ncm (nolock) ON (i.ncm = ncm.Classificacao_f)
                WHERE RTRIM(LTRIM(p.tipo_nota)) in ('D','3')
                AND i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (6,803))
                AND p.Dt_entrada >= '2011-01-01')
        ) faturamento
        GROUP BY
                  "Periodo"
                , "Cliente"
                , "Cliente CNPJ"
                , "Cliente Agrupador CNPJ"
                , "Periodo Ultima Compra"
                , "Divisao Cliente"
                , "Cd Cliente Agrupador"
                , "Agrupamento Cliente"
                , "Agrupamento Razao Social"
                , "CFOP"
                , "Regiao"
                , "Cod_Representante_Carteira"
                , "UF"
                , "Cod_Representante"
                , "Representante"
                , "Representante Carteira"
                , "Responsavel" 
                , "Tipo Faturamento"
                , "Segmento"
                , "GEO_CLIENTE"   
                , "GEO_CLIENTE_AGRUPADOR"
                , "Municipio Cliente"
                , "Municipio Agrupador"
                , "NF"
                , "Serie NF"
                , "Periodo Cad Cliente"
                , "Cod_Cliente"
                ,  "Tipo devoluções"
                , "Unidade de Negócio"
                , "Ordem de Compra"
                , "tipi_ncm"
) x
GROUP BY
          "Periodo"
          , "Periodo"
          , "CFOP"
          , "Cliente"
          , "Cliente CNPJ"
          , "Cliente Agrupador CNPJ"
          , "Periodo Ultima Compra"
          , "Divisao Cliente"
          , "Cd Cliente Agrupador"
          , "Agrupamento Cliente" 
          , "Agrupamento Razao Social"
          , (CASE  WHEN "UF" = 'EX' THEN 'EXPORTACAO'
                WHEN "Cod_Representante_Carteira" = '000129' AND "Cd Cliente Agrupador" IN ('001593', '001638', '002002', '026207', '029024', '029368') THEN '* VENDA DIRETA'
                WHEN "Cod_Representante_Carteira" = '000129' THEN 'SUL'
                WHEN "Cod_Representante_Carteira" = '038240' AND "UF" IN ('MA') THEN 'NORDESTE'
                WHEN "Cod_Representante_Carteira" = '038240' AND "UF" IN ('TO') THEN 'NORTE'
                WHEN (("Regiao" = null) OR ("Regiao"  ='.') or ("Regiao" = '') or ("Cod_Representante_Carteira" = '' ) or ("Representante" = '999998' ))  THEN '* VENDA DIRETA'
                ELSE  "Regiao"
        END)
          , "UF"
          , "Cod_Representante"
          , "Cod_Representante_Carteira"
          , "Representante" 
          , "Representante Carteira"
          , "Responsavel" 
          , "Tipo Faturamento"
          , "Segmento"
          , "GEO_CLIENTE"
          , "GEO_CLIENTE_AGRUPADOR"
          , "Municipio Cliente"
          , "Municipio Agrupador"
          , "Periodo Cad Cliente"
          , ( CASE WHEN DATEDIFF ( MONTH , "Periodo" , "Periodo Cad Cliente" ) = 0 
                          THEN 'Novos Cliente'
           ELSE   'Carteria Consolidada' END )
          , "Cod_Cliente"
          , "NF_Serie"
          ,  "Tipo devoluções"
          , "Unidade de Negocio"
          , "Ordem de Compra"
          , "NCM"