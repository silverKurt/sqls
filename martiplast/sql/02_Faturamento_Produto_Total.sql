SELECT
        COALESCE(a."Cliente", b."Cliente") AS "Cliente"
        , COALESCE(a."Cliente Fone", b."Cliente Fone") AS "Cliente Fone"
        , COALESCE(a."Cliente Endereço", b."Cliente Endereço") AS "Cliente Endereço"
        , COALESCE(a."Cliente Bairro", b."Cliente Bairro") AS "Cliente Bairro"
        , COALESCE(a."Cliente Municipio", b."Cliente Municipio") AS "Cliente Municipio" 
        , COALESCE(a."Periodo Ultima Compra", b."Periodo Ultima Compra") AS "Periodo Ultima Compra"
        , COALESCE(a."Periodo Ultima Compra", b."Periodo Ultima Compra") AS "Periodo Ultima Compra Filtro"
        , COALESCE(a."Divisao Cliente", b."Divisao Cliente") AS "Divisao Cliente"
        , COALESCE(a."Agrupamento Cliente", b."Agrupamento Cliente") AS "Agrupamento Cliente"
        , COALESCE(a."Cd Cliente Agrupador", b."Cd Cliente Agrupador") AS "Cd Cliente Agrupador"
        , COALESCE(a."Cor", b."Cor") AS "Cor"
        , COALESCE(a."Empresa", b."Empresa") AS "Empresa"
        , COALESCE(CASE WHEN a.cd_unidade_de_n = 1 THEN 'OU' WHEN a.cd_unidade_de_n = 2 THEN 'YOI' ELSE NULL END, CASE WHEN b.cd_unidade_de_n = 1 THEN 'OU' WHEN b.cd_unidade_de_n = 2 THEN 'YOI' ELSE NULL END) AS "Unidade de Negócio"
        , COALESCE(a."Mercado", b."Mercado") AS "Mercado"
        , a."Pedido" AS "Pedido"
        , COALESCE(a."Periodo", b."Periodo") AS "Periodo"
        , COALESCE(a."Periodo", b."Periodo") AS "Periodo Filtro"
        , COALESCE(a."Periodo Modificacao", b."Periodo Modificacao") AS "Periodo Modificacao"
        , COALESCE(a."Periodo Modificacao", b."Periodo Modificacao") AS "Periodo Modificacao Filtro"
        , COALESCE(a."Periodo Romaneio", b."Periodo Romaneio") AS "Periodo Romaneio"
        , COALESCE(a."Periodo Romaneio", b."Periodo Romaneio") AS "Periodo Romaneio Filtro"
        , COALESCE(a."Periodo Saida", b."Periodo Saida") AS "Periodo Saida"
        , COALESCE(a."Periodo Saida", b."Periodo Saida") AS "Periodo Saida Filtro"
        , COALESCE(a."Produto", b."Produto") AS "Produto"
        , COALESCE(a."tipi_ncm", b."tipi_ncm") AS "tipi_ncm"
--      , COALESCE(a."Produto Agrupador", b."Produto Agrupador") AS "Produto Agrupador"
        , CASE 
      WHEN (ltrim(rtrim(a."Produto")) || ' - ' || ltrim(rtrim(a."CorD"))) IS NULL
      THEN (ltrim(rtrim(b."Produto")) || ' - ' || ltrim(rtrim(b."CorD")))
      ELSE (ltrim(rtrim(a."Produto")) || ' - ' || ltrim(rtrim(a."CorD")))
        END AS "Produto COR"
        , COALESCE(a."Catalogo Produto", b."Catalogo Produto") AS "Catalogo Produto"
        , COALESCE(a."Sub Grupo Produto", b."Sub Grupo Produto") AS "Sub Grupo Produto"
        , COALESCE(a."Linha Produto", b."Linha Produto") AS "Linha Produto"
        , COALESCE(a."UF", b."UF") AS "UF"
    , (CASE 
        WHEN COALESCE(a."UF", b."UF") = 'EX' THEN 'EXPORTACAO'
        WHEN (
              (COALESCE(a."Regiao", b."Regiao") = null) 
              OR (COALESCE(a."Regiao", b."Regiao") = '.')
              OR (COALESCE(a."Regiao", b."Regiao") = '')
              OR (COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '' ) 
              OR (COALESCE(a."Representante", b."Representante")= '999998')
              ) 
        THEN '* VENDA DIRETA'
        WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '000129' AND COALESCE(a."Cd Cliente Agrupador", b."Cd Cliente Agrupador") IN ('002002', '001593', '001638', '026207', '029024', '029368') THEN '* VENDA DIRETA'
        WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '000129' THEN 'SUL'
        --WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '038240' AND COALESCE(a."UF", b."UF") = 'MA' THEN 'NORDESTE'
        --WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '038240' AND COALESCE(a."UF", b."UF") = 'TO' THEN 'NORTE'
        ELSE COALESCE(a."Regiao", b."Regiao")
    END) AS  "Regiao"
    , COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") AS "Cod_Representante_Carteira"
    , COALESCE(a."Representante Carteira", b."Representante Carteira") AS "Representante Carteira"
        , COALESCE(a."Representante", b."Representante") AS "Representante"
    , COALESCE(a."Codigo Representante", b."Codigo Representante") AS "Codigo Representante"
        , COALESCE(a."Transportador", b."Transportador") AS "Transportador"
        , COALESCE(a."Tipo Faturamento", b."Tipo Faturamento") AS "Tipo Faturamento"
        , COALESCE(a."Segmento", b."Segmento") AS "Segmento"
        , (CASE 
      WHEN COALESCE(a."origem", b."origem") = 1
        THEN 'Importado' 
      WHEN COALESCE(a."origem", b."origem") = 5 OR COALESCE(a."origem", b."origem") = 0
        THEN 'Nacional' 
    END) AS "Origem Produto"
    , COALESCE(a."Fabrica", b."Fabrica") AS "Fabrica"
  , COALESCE(a."Setor Leroy", b."Setor Leroy") AS "Setor Leroy"
  --, COALESCE(a."EAN", b."EAN") AS "EAN"
  , SUM(a."Qtde Pecas Nota Fat") AS "Qtde Pecas Nota Fat"
  , SUM(b."Qtde Pecas Nota Fat") AS "Qtde Pecas Nota Fat Ant"
  , SUM(a."Vl_base_subst") AS Vl_base_subst
  , SUM(a."Vl_base_substit") AS Vl_base_substit
  , SUM(a."Vlr Desc Fat") AS "Vlr Desc Fat"
  , SUM(a."Vl_enc_financ") AS Vl_enc_financ
  , SUM(a."Vlr Frete Fat") AS "Vlr Frete Fat"
  , SUM(a."Vlr ICMS Fat") AS "Vlr ICMS Fat"
  , SUM(a."Vlr IPI Fat") AS "Vlr IPI Fat"
  , SUM(a."Vl_ipi_obs") AS Vl_ipi_obs
  , SUM(a."Vlr Seguro Fat") AS "Vlr Seguro Fat"
  , SUM(a."Vlr ST Fat") AS "Vlr ST Fat"
  , SUM(a."Vlr Suf Fat") AS "Vlr Suf Fat"
  , SUM(a."Vlr Acessorias") AS "Vlr Acessorias"
  , SUM(a."Vlr Nota Fat") AS "Vlr Nota Fat" 
  , SUM(cast(a."Vlr Gerencial Fat" as DOUBLE PRECISION)) AS "Vlr Gerencial Fat"  
  , SUM(cast(b."Vlr Gerencial Fat" as DOUBLE PRECISION)) AS "Vlr Gerencial Fat Ant"
FROM "ou"."fat_ou_FatProdutoAnoAtual" a
FULL JOIN "ou"."fat_ou_FatProdutoAnoAnterior" b ON 
        (a."Cliente" = b."Cliente"
        AND a."Cliente Fone" = b."Cliente Fone"
        AND a."Cliente Endereço" = b."Cliente Endereço"
        AND a."Cliente Bairro" = b."Cliente Bairro"
        AND a."Cliente Municipio" = b."Cliente Municipio" 
        AND a."Periodo Ultima Compra" = b."Periodo Ultima Compra"
        AND a."Divisao Cliente" = b."Divisao Cliente"
        AND a."Agrupamento Cliente" = b."Agrupamento Cliente"
        AND a."Cd Cliente Agrupador" = b."Cd Cliente Agrupador"
        AND a."Cor" = b."Cor"
        AND a."Empresa" = b."Empresa"
        AND a.cd_unidade_de_n = b.cd_unidade_de_n
        AND a."Mercado" = b."Mercado"
        AND a."Periodo" = b."Periodo" 
        AND a."Periodo Modificacao" = b."Periodo Modificacao"
        AND a."Periodo Romaneio" = b."Periodo Romaneio"
        AND a."Periodo Saida" = b."Periodo Saida"
        AND a."Produto" = b."Produto"
        AND a."tipi_ncm" = b."tipi_ncm"
--      AND a."Produto Agrupador" = b."Produto Agrupador"
        AND (ltrim(rtrim(a."Produto")) || ' - ' || ltrim(rtrim(a."CorD"))) = (ltrim(rtrim(b."Produto")) || ' - ' || ltrim(rtrim(b."CorD")))
        AND a."Catalogo Produto" = b."Catalogo Produto"
        AND a."Sub Grupo Produto" = b."Sub Grupo Produto"
        AND a."Linha Produto" = b."Linha Produto"
        AND a."UF" = b."UF"
    AND a."Regiao" = b."Regiao"
    AND a."Cod_Representante_Carteira" = b."Cod_Representante_Carteira"
    AND a."Representante Carteira" = b."Representante Carteira"
        AND a."Representante" = b."Representante"
    AND a."Codigo Representante" = b."Codigo Representante"
        AND a."Transportador" = b."Transportador"
        AND a."Tipo Faturamento" = b."Tipo Faturamento"
        AND a."Segmento" = b."Segmento"
        AND a."origem" = b."origem"
    AND a."Fabrica" = b."Fabrica")
GROUP BY
          COALESCE(a."Cliente", b."Cliente")
        , COALESCE(a."Cliente Fone", b."Cliente Fone")
        , COALESCE(a."Cliente Endereço", b."Cliente Endereço")
        , COALESCE(a."Cliente Bairro", b."Cliente Bairro")
        , COALESCE(a."Cliente Municipio", b."Cliente Municipio")
        , COALESCE(a."Periodo Ultima Compra", b."Periodo Ultima Compra")
        , COALESCE(a."Divisao Cliente", b."Divisao Cliente")
        , COALESCE(a."Agrupamento Cliente", b."Agrupamento Cliente")
        , COALESCE(a."Cd Cliente Agrupador", b."Cd Cliente Agrupador")
        , COALESCE(a."Cor", b."Cor")
        , COALESCE(a."Empresa", b."Empresa")
        , COALESCE(CASE WHEN a.cd_unidade_de_n = 1 THEN 'OU' WHEN a.cd_unidade_de_n = 2 THEN 'YOI' ELSE NULL END, CASE WHEN b.cd_unidade_de_n = 1 THEN 'OU' WHEN b.cd_unidade_de_n = 2 THEN 'YOI' ELSE NULL END)
        , COALESCE(a."Mercado", b."Mercado")
        , COALESCE(a."Periodo", b."Periodo")
        , COALESCE(a."Periodo Modificacao", b."Periodo Modificacao")
        , COALESCE(a."Periodo Romaneio", b."Periodo Romaneio")
        , COALESCE(a."Periodo Saida", b."Periodo Saida")
        , COALESCE(a."Produto", b."Produto")
        , COALESCE(a."tipi_ncm", b."tipi_ncm")
        , COALESCE(a."Regiao", b."Regiao")
--        , COALESCE(a."Produto Agrupador", b."Produto Agrupador")
        , CASE 
      WHEN (ltrim(rtrim(a."Produto")) || ' - ' || ltrim(rtrim(a."CorD"))) IS NULL
      THEN (ltrim(rtrim(b."Produto")) || ' - ' || ltrim(rtrim(b."CorD")))
      ELSE (ltrim(rtrim(a."Produto")) || ' - ' || ltrim(rtrim(a."CorD")))
        END
        , COALESCE(a."Catalogo Produto", b."Catalogo Produto")
        , COALESCE(a."Sub Grupo Produto", b."Sub Grupo Produto")
        , COALESCE(a."Linha Produto", b."Linha Produto")
        , COALESCE(a."UF", b."UF")
    , (CASE 
        WHEN COALESCE(a."UF", b."UF") = 'EX' THEN 'EXPORTACAO'
        WHEN (
              (COALESCE(a."Regiao", b."Regiao") = null) 
              OR (COALESCE(a."Regiao", b."Regiao") = '.')
              OR (COALESCE(a."Regiao", b."Regiao") = '')
              OR (COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '' ) 
              OR (COALESCE(a."Representante", b."Representante")= '999998')
              ) 
        THEN '* VENDA DIRETA'
        WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '000129' AND COALESCE(a."Cd Cliente Agrupador", b."Cd Cliente Agrupador") IN ('002002', '001593', '001638', '026207', '029024', '029368') THEN '* VENDA DIRETA'
        WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '000129' THEN 'SUL'
        --WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '038240' AND COALESCE(a."UF", b."UF") = 'MA' THEN 'NORDESTE'
        --WHEN COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira") = '038240' AND COALESCE(a."UF", b."UF") = 'TO' THEN 'NORTE'
        ELSE COALESCE(a."Regiao", b."Regiao")
    END)
    , COALESCE(a."Cod_Representante_Carteira", b."Cod_Representante_Carteira")
    , COALESCE(a."Representante Carteira", b."Representante Carteira")
        , COALESCE(a."Representante", b."Representante")
    , COALESCE(a."Codigo Representante", b."Codigo Representante")
        , COALESCE(a."Transportador", b."Transportador")
        , COALESCE(a."Tipo Faturamento", b."Tipo Faturamento")
        , COALESCE(a."Segmento", b."Segmento")
        , ( CASE 
      WHEN COALESCE(a."origem", b."origem") = 1 
        THEN 'Importado' 
      WHEN COALESCE(a."origem", b."origem") = 5 OR COALESCE(a."origem", b."origem") = 0
        THEN 'Nacional' 
       END )
        , a."Pedido"
    , COALESCE(a."Fabrica", b."Fabrica")
    , COALESCE(a."Setor Leroy", b."Setor Leroy")
    --, COALESCE(a."EAN", b."EAN")