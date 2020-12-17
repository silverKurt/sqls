-- Devolucao
(SELECT  
        p.Dt_entrada AS "Periodo"

--        , p.cd_fornecedor AS cod_cliente_coentrad
--        , cl.cd_empresa AS cod_cliente_geempres_cl

--        , cl.cd_representant AS cod_representante_geempres_cl
--        , r.cd_empresa AS cod_representante_geempres_r

        /*ADD A INFORMAÇÃO DA NOVA CONEXÃO QUANDO FOR NULO*/
        , CONCAT(
            CASE WHEN UPPER(LTRIM(RTRIM(r.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r.fantasia))) END
            , ' ('
            , LTRIM(RTRIM((select CASE WHEN gei.cd_representant IS NULL OR gei.cd_representant = '' THEN '0' ELSE gei.cd_representant END from geempres gei (nolock) where gei.cd_empresa = p.cd_fornecedor)))
            , ')'
            ) AS "Representante"

--        , r_semunid.cd_empresa AS cod_representante_geempres_r_semUnid

        , CONCAT(
            CASE WHEN UPPER(LTRIM(RTRIM(r_semunid.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r_semunid.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r_semunid.fantasia))) END
            , ' ('
            , LTRIM(RTRIM((select CASE WHEN gei.cd_representant IS NULL OR gei.cd_representant = '' THEN '0' ELSE gei.cd_representant END from geempres gei (nolock) where gei.cd_empresa = p.cd_fornecedor)))
            , ')'
            ) AS "Representante sem Unidade"

--        , CONCAT(
--            CASE WHEN UPPER(LTRIM(RTRIM(r_semunid.fantasia))) IS NULL OR UPPER(LTRIM(RTRIM(r_semunid.fantasia))) = '' THEN 'NAO INFORMADO' ELSE UPPER(LTRIM(RTRIM(r_semunid.fantasia))) END
--            , ' ('
--            , LTRIM(RTRIM((select CASE WHEN gei.cd_representant IS NULL OR gei.cd_representant = '' THEN '0' ELSE gei.cd_representant END from geempres gei (nolock) where gei.cd_empresa = p.cd_fornecedor)))
--            , ')'
--            ) AS "Representante sem Unidade"

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

FROM coentrad p (NOLOCK)
LEFT JOIN esmovime i (nolock) ON (p.cd_unidade_de_n = i.uni_neg AND p.serie = i.serie AND p.nf = i.nf AND p.Cd_fornecedor = i.Cd_empresa)
LEFT JOIN geempres cl (nolock) ON (cl.cd_empresa = p.cd_fornecedor)
LEFT JOIN geempres r (nolock) ON (r.cd_empresa = cl.cd_representant AND p.cd_unidade_de_n = r.cd_unidade_de_n)
/*NOVO JOIN*/
LEFT JOIN geempres r_semunid (nolock) ON (r_semunid.cd_empresa = cl.cd_representant and RTRIM(LTRIM(r_semunid.cd_unidade_de_n)) = '')
LEFT JOIN geempres r2 (nolock) ON (r2.cd_empresa = cl.cd_representant)
LEFT JOIN geempres cl2 (nolock) ON (cl.cd_centralizado = cl2.cd_empresa)
LEFT JOIN geempres cl3 (nolock) ON (cl.Cd_responsavel = cl3.cd_empresa)
LEFT JOIN vemercad re (nolock) ON (r2.cd_mercado = re.cd_mercado)
LEFT JOIN  VEATIVID ve (nolock) ON (ve.atividade = cl.atividade)
LEFT JOIN facomple fa (nolock) ON (fa.nf = i.nf and fa.sequencia =0 and fa.serie = i.serie and p.cd_unidade_de_n = fa.uni_negocio)
--LEFT JOIN ESCLASFI ncm (nolock) ON (i.ncm = ncm.Classificacao_f)
WHERE RTRIM(LTRIM(p.tipo_nota)) in ('D','3')
AND i.cd_tp_operacao in (SELECT DISTINCT t.cd_tipo_operaca FROM getopera t (nolock) INNER JOIN geelemen e (nolock) ON (e.elemento = t.cd_tipo_operaca) WHERE e.cd_tg in (6,803))
AND p.Dt_entrada >= '2020-01-01')