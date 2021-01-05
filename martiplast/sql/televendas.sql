SELECT 
    MEXFAT."Periodo"
  , MEXFAT."Periodo" AS "Periodo Filtro"
  , MEXFAT."Regiao"
  , MEXFAT."Regiao" AS "Regiao Filtro"
  , MEXFAT."Controle"
  , MEXFAT."Representante"
  , MEXFAT."Representante Carteira"
  , MEXFAT."Responsavel"
  , MEXFAT."Tipo Faturamento"
  , MEXFAT."Unidade de Negócio"
  , MEXFAT."Qtde Faturas"
  , MEXFAT."Vlr Meta"
  , MEXFAT."Mercado"
    , CASE  WHEN CAST(DATE_PART('month', MEXFAT."Periodo") AS INTEGER) IN  (1,2,3,4,5,6) and MEXFAT."Tipo Faturamento" <> 'BONIFICACAO' THEN MEXFAT."Vlr Gerencial Fat"
            ELSE MEXFAT."Vlr Meta"
    END AS "2019B"
  , MEXFAT."Vlr Nota Fat"
  , MEXFAT."Vlr Acessorias"
  , MEXFAT."Vlr Gerencial Fat"
  , MEXFAT."Vlr Carteira"
  , MEXFAT."Agrupamento Cliente"
  , MEXFAT."Dias Uteis"
  , MEXFAT."Dias Percorridos"
  , MEXFAT."Segmento"
  
  ,(CASE 
    WHEN (MEXFAT."Regiao" IN ('NORTE','NORDESTE')) THEN 'Marney Lucena'
    WHEN (MEXFAT."Regiao" IN ('SUDESTE 1')) THEN 'Renato Santos'
    WHEN (MEXFAT."Regiao" IN ('SUDESTE 2','CENTRO-OESTE')) THEN 'Vitor Lenz'
    WHEN (MEXFAT."Regiao" IN ('SUDESTE 3')) THEN 'Marcelo Freitas'
    WHEN (MEXFAT."Regiao" = ('SUL') OR MEXFAT."Representante Carteira" IN ('(Novo) Sul do RS (000000) (000000)','JJ PICCINI REPRES (017519)')) THEN 'Silvana Doncatto'
    WHEN (MEXFAT."Regiao" = ('EXPORTACAO')) THEN 'Marcelo Jahns'
    ELSE 'Maurício Moraes' 
  END) AS "Supervisor"
  
  , (CASE 
    WHEN (MEXFAT."Mercado" = 'NAO INFORMADO' AND MEXFAT."Representante Carteira" = 'NOBRY (000129)') THEN 'NOBRY 1 (000129)'
    WHEN (MEXFAT."Mercado" = 'INTERNO' AND MEXFAT."Representante Carteira" = 'NOBRY (000129)') THEN 'NOBRY 2 (000129)'
    ELSE MEXFAT."Representante Carteira" 
  END) AS "Representantes Personalizados"
FROM 
( 
  (SELECT 
      fat."Periodo" AS "Periodo"
    , fat."Regiao" AS "Regiao"
    , NULL::TEXT AS "Controle"
/*    , fat."Regiao" AS "Regiao Filtro" */
    , fat."Representante" AS "Representante"
    , fat."Representante Carteira" AS "Representante Carteira"
    , CAST("Segmento" AS TEXT) AS "Segmento"
    , fat."Responsavel"
    , fat."Tipo Faturamento" AS "Tipo Faturamento"
    , fat."Unidade de Negocio" AS "Unidade de Negócio"
    , fat."Qtde Faturas" AS "Qtde Faturas"
    , null::DOUBLE PRECISION AS "Vlr Meta"
    , (CASE WHEN fat."Regiao" = 'EXPORTACAO' then 'EXTERNO' 
           ELSE 'INTERNO' END) AS "Mercado"
    , fat."Vlr Nota Fat"::DOUBLE PRECISION AS "Vlr Nota Fat"
    , fat."Vlr Acessorias"::DOUBLE PRECISION AS "Vlr Acessorias"
    , fat."Vlr Gerencial Fat"::DOUBLE PRECISION AS "Vlr Gerencial Fat"
    , fat."Agrupamento Cliente"::TEXT AS "Agrupamento Cliente"
    , (SELECT SUM(a.util) FROM ou."fat_ou_Calendario" a WHERE DATE_TRUNC('MONTH', a.periodo) = DATE_TRUNC('MONTH', fat."Periodo"))::DOUBLE PRECISION AS "Dias Uteis"
    , (SELECT SUM(a.util) FROM ou."fat_ou_Calendario" a WHERE a.periodo <= NOW()::DATE AND DATE_TRUNC('MONTH', a.periodo) = DATE_TRUNC('MONTH', fat."Periodo"))::DOUBLE PRECISION AS "Dias Percorridos" 
    , NULL::DOUBLE PRECISION AS "Vlr Carteira"
  FROM 
    ou."fat_ou_FaturamentoDiarizacao" fat
  WHERE 
    DATE_TRUNC('MONTH', fat."Periodo") >= DATE_TRUNC('MONTH', NOW()::DATE)
    --WHERE DATE_TRUNC('MONTH', orc."Periodo") >= DATE_TRUNC('MONTH', NOW()::DATE)

  ) 

  UNION ALL
  --Metas de todos representantes exceto TELEVENDAS (022221) que é buscado em outro union para dividir a meta por responsavel (operador) do televendas
  (SELECT 
    cl.periodo AS periodo
    , (CASE 
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) IN ('EXPORTACAO (000000) (000000)','EXPORTAO (000000)')) THEN 'EXPORTACAO'
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) IN ('(NOVO) MEIO DE SC (000000)','(NOVO) OESTE DE SC (000000)','(NOVO) OESTE DE SC (000000) (000000)','(NOVO) SUL DO RS (000000) (000000)')) THEN 'SUL'

      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'ALIANCA (014246)') THEN 'SUDESTE 1'
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) IN ('(NOVO) AREA NORTE - 02 (000000)','(NOVO) AREA SUL - 07 (000000)','(NOVO) AREA SUL - 10 (000000)')) THEN 'SUDESTE 1'

      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) = 'SILVA E CHAVES (007376)') THEN 'NORDESTE'
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'C.G.C. REPRESENTACOE (000139)') THEN 'SUDESTE 2'
      WHEN (orc."Regiao" ILIKE '%SUDESTE') THEN TRIM(REPLACE(orc."Regiao", 'REGIAO', ''))||' 1'
      WHEN (repres."Regiao" IS NULL) THEN TRIM(REPLACE(orc."Regiao", 'REGIAO', ''))
      ELSE repres."Regiao" 
    END) AS "Regiao"
    , NULL::text as "Controle"
    , COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) AS "Representante"
    , (CASE 
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'SILVA E CHAVES (007376)') THEN 'FORMULA REPRESENTACO (016963)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) IN ('NOVO OESTE DE SC (000000) (000000)','(NOVO) OESTE DE SC (000000) (000000)')) THEN 'JJ PICCINI REPRES (017519)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'FORTES E SOEIRO (010393)') THEN 'F E S REPRESENTACOES (010393)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'ALIANCA (014246)') THEN 'A.W.L. (000108)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'C.G.C. REPRESENTACOE (000139)') THEN 'FDS REPRESENTACOES (017699)'
      ELSE COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) 
    END) AS "Representante Carteira"
    , 'NAO INFORMADO'::TEXT AS "Segmento"
    , 'NAO INFORMADO (0)'::TEXT AS "Responsavel"
    , 'NAO INFORMADO'::TEXT AS "Tipo Faturamento"
    , orc."Unidade de Negócio" AS "Unidade de Negócio"
    , null::DOUBLE PRECISION AS "Qtde Faturas"
    , CASE 
        WHEN orc."Unidade de Negócio" = 'OU' AND (SELECT SUM(ii.perc_meta_ou) FROM ou."fat_ou_Calendario" ii WHERE DATE_TRUNC('month', ii.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE) > 0 THEN orc."Vlr_Meta"*(cl.perc_meta_ou/100)
        WHEN orc."Unidade de Negócio" = 'YOI' AND (SELECT SUM(ii.perc_meta_yoi) FROM ou."fat_ou_Calendario" ii WHERE DATE_TRUNC('month', ii.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE) > 0 THEN orc."Vlr_Meta"*(cl.perc_meta_yoi/100)
        ELSE orc."Vlr_Meta"/(SELECT SUM(i.util) FROM ou."fat_ou_Calendario" i WHERE DATE_TRUNC('month', i.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE)::DOUBLE PRECISION 
      END AS "Vlr Meta"
    , orc."Mercado"::TEXT AS "Mercado"
    , null::DOUBLE PRECISION AS "Vlr Nota Fat"
    , null::DOUBLE PRECISION AS "Vlr Acessorias"
    , null::DOUBLE PRECISION AS "Vlr Gerencial Fat"
    , null::TEXT AS "Agrupamento Cliente"
    , NULL::DOUBLE PRECISION AS "Dias Uteis"
    , NULL::DOUBLE PRECISION AS "Dias Percorridos"
    , NULL::DOUBLE PRECISION AS "Vlr Carteira"
  FROM 
    ou."fat_ou_MetasFaturamentoPlanning" AS orc
  LEFT JOIN (SELECT DISTINCT "Cod_Representante_Carteira", "Representante Carteira", "Regiao" FROM ou."fat_ou_FaturamentoDiarizacao") repres ON (repres."Cod_Representante_Carteira"::INT = orc."Cod_Representante"::INT AND TRIM(REPLACE(orc."Regiao", 'REGIAO', '')) = TRIM(repres."Regiao"))
  INNER JOIN  ou."fat_ou_Calendario" cl ON (DATE_TRUNC('month', cl.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE AND cl.util = 1)
  WHERE DATE_TRUNC('MONTH', orc."Periodo") >= DATE_TRUNC('MONTH', NOW()::DATE)
  AND orc."Cod_Representante"::INT <> 22221
  )
  
  UNION ALL
  --Metas do TELEVENDAS (022221) dividindo igualmente por operador
  (SELECT 
    cl.periodo AS periodo
    , (CASE 
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) IN ('EXPORTACAO (000000) (000000)','EXPORTAO (000000)')) THEN 'EXPORTACAO'
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) IN ('(NOVO) MEIO DE SC (000000)','(NOVO) OESTE DE SC (000000)','(NOVO) OESTE DE SC (000000) (000000)','(NOVO) SUL DO RS (000000) (000000)')) THEN 'SUL'

      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'ALIANCA (014246)') THEN 'SUDESTE 1'
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) IN ('(NOVO) AREA NORTE - 02 (000000)','(NOVO) AREA SUL - 07 (000000)','(NOVO) AREA SUL - 10 (000000)')) THEN 'SUDESTE 1'

      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0')||')')) = 'SILVA E CHAVES (007376)') THEN 'NORDESTE'
      WHEN (COALESCE(repres."Representante Carteira",(orc."Representante" ||' ('|| LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'C.G.C. REPRESENTACOE (000139)') THEN 'SUDESTE 2'
      WHEN (orc."Regiao" ILIKE '%SUDESTE') THEN TRIM(REPLACE(orc."Regiao", 'REGIAO', ''))||' 1'
      WHEN (repres."Regiao" IS NULL) THEN TRIM(REPLACE(orc."Regiao", 'REGIAO', ''))
      ELSE repres."Regiao" 
    END) AS "Regiao"
    , NULL::TEXT AS "Controle"
    , COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) AS "Representante"
    , (CASE 
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'SILVA E CHAVES (007376)') THEN 'FORMULA REPRESENTACO (016963)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) IN ('NOVO OESTE DE SC (000000) (000000)','(NOVO) OESTE DE SC (000000) (000000)')) THEN 'JJ PICCINI REPRES (017519)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'FORTES E SOEIRO (010393)') THEN 'F E S REPRESENTACOES (010393)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'ALIANCA (014246)') THEN 'A.W.L. (000108)'
      WHEN (COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) = 'C.G.C. REPRESENTACOE (000139)') THEN 'FDS REPRESENTACOES (017699)'
      ELSE COALESCE(repres."Representante Carteira", (orc."Representante" || ' (' || LPAD(orc."Cod_Representante", 6, '0') ||')')) 
    END) AS "Representante Carteira"
    , 'NAO INFORMADO'::TEXT AS "Segmento"
    , resp."Responsavel"
    , 'NAO INFORMADO'::TEXT AS "Tipo Faturamento"
    , orc."Unidade de Negócio" AS "Unidade de Negócio"
    , null::DOUBLE PRECISION AS "Qtde Faturas"
    , (
      CASE 
        WHEN orc."Unidade de Negócio" = 'OU' AND (SELECT SUM(ii.perc_meta_ou) FROM ou."fat_ou_Calendario" ii WHERE DATE_TRUNC('month', ii.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE) > 0 THEN orc."Vlr_Meta"*(cl.perc_meta_ou/100)
        WHEN orc."Unidade de Negócio" = 'YOI' AND (SELECT SUM(ii.perc_meta_yoi) FROM ou."fat_ou_Calendario" ii WHERE DATE_TRUNC('month', ii.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE) > 0 THEN orc."Vlr_Meta"*(cl.perc_meta_yoi/100)
        ELSE orc."Vlr_Meta"/(SELECT SUM(i.util) FROM ou."fat_ou_Calendario" i WHERE DATE_TRUNC('month', i.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE)::DOUBLE PRECISION 
      END
      )/(SELECT COUNT(DISTINCT fat."Responsavel") FROM ou."fat_ou_FaturamentoDiarizacao" fat WHERE fat."Cod_Representante_Carteira" = '022221' )::DOUBLE PRECISION AS "Vlr Meta"
    , orc."Mercado"::TEXT AS "Mercado"
    , null::DOUBLE PRECISION AS "Vlr Nota Fat"
    , null::DOUBLE PRECISION AS "Vlr Acessorias"
    , null::DOUBLE PRECISION AS "Vlr Gerencial Fat"
    , null::TEXT AS "Agrupamento Cliente"
    , NULL::DOUBLE PRECISION AS "Dias Uteis"
    , NULL::DOUBLE PRECISION AS "Dias Percorridos"
    , NULL::DOUBLE PRECISION AS "Vlr Carteira"
  FROM 
    ou."fat_ou_MetasFaturamentoPlanning" AS orc
  LEFT JOIN (SELECT DISTINCT "Cod_Representante_Carteira", "Representante Carteira", "Regiao" FROM ou."fat_ou_FaturamentoDiarizacao") repres ON (repres."Cod_Representante_Carteira"::INT = orc."Cod_Representante"::INT AND TRIM(REPLACE(orc."Regiao", 'REGIAO', '')) = TRIM(repres."Regiao"))
  INNER JOIN  ou."fat_ou_Calendario" cl ON (DATE_TRUNC('month', cl.periodo)::DATE = DATE_TRUNC('month', orc."Periodo")::DATE AND cl.util = 1)
  INNER JOIN (SELECT DISTINCT fat."Responsavel" FROM ou."fat_ou_FaturamentoDiarizacao" fat WHERE fat."Cod_Representante_Carteira" = '022221' ) resp ON (1=1)
  WHERE DATE_TRUNC('MONTH', orc."Periodo") >= DATE_TRUNC('MONTH', NOW()::DATE)
  AND orc."Cod_Representante"::INT = 22221
  )

  UNION ALL 

SELECT CAST("Periodo Programado Filtro" AS DATE) AS "Periodo",
       CAST("Regiao" AS TEXT)                 AS "Regiao",
       CAST("Controle" AS TEXT)               AS "Controle",
       CAST("Representante" AS TEXT)          AS "Representante",
       CAST("Representante Carteira" AS TEXT) AS "Representante Carteira",
       CAST("Atividade" AS TEXT) AS "Segmento",
       'NAO INFORMADO (0)'::TEXT AS "Responsavel",
      'NAO INFORMADO'::TEXT                   AS "Tipo Faturamento",
       CAST("Unidade de Negócio" AS TEXT)     AS "Unidadede Negocio",
       null::DOUBLE PRECISION                 AS "Qtde Faturas",
       null::DOUBLE PRECISION                 AS "Vlr Meta",
       CAST("Mercado" AS TEXT)                AS "Mercado",
       null::DOUBLE PRECISION                 AS "Vlr Nota Fat",
       null::DOUBLE PRECISION                 AS "Vlr Acessorias",
       null::DOUBLE PRECISION                 AS "Vlr Gerencial Fat",
       CAST("Agrupamento Cliente" AS TEXT)    AS "Agrupamento Cliente",
       NULL::DOUBLE PRECISION                 AS "Dias Uteis",
       NULL::DOUBLE PRECISION                 AS "Dias Percorridos",
       CAST("Vlr Mercadoria" AS DOUBLE PRECISION) AS "Vlr Carteira"
FROM   "ou"."fat_ou_PedidosemCarteira"
WHERE  CAST("Controle" AS TEXT)    in ('31','41','46','50','01','05') and 
       CAST("Tipo Pedido" AS TEXT) in ('1','N','V','7') and
       CAST("Periodo Programado Filtro" AS DATE) >= DATE_TRUNC('MONTH', NOW()::DATE)
  
) MEXFAT

SELECT
NON EMPTY {[Measures].[ValorProdutos], [Measures].[% Share], [Measures].[Pos. Atual]} ON COLUMNS,
NON EMPTY TopCount(NonEmptyCrossJoin([ClienteMatriz].[Todos].Children, [RepresentanteCadastro].[Todos].Children), 50.0, [Measures].[ValorProdutos]) ON ROWS
FROM [Pedidos]
WHERE NonEmptyCrossJoin(NonEmptyCrossJoin({[Status].[BLOQUEADOS], [Status].[PROCESSADOS EM NF], [Status].[LIBERADOS], [Status].[TOTALMENTE ATENDIDOS]}, {([GeraFaturamento].[SIM], [Tipo].[VENDAS], [Mercado].[INTERNO])}), [BIMFPeriodoAprovacao.CurrentMonth])