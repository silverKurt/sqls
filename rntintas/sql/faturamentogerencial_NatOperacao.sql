SELECT
       VENDGERE as CodGerente,
       VENDEMPE as CodEmpresaRepresentante,
       MASTCODI as CodMaster,
       MASTDESC as DescricaoMaster,
       FORN.CADACODI as codFornecedor,
       FORN.CADANOME as NomeFornecedor,
       LINH.TABEDESC AS Linha,
       CFATREPR      as CodRepresentante,
       CFATDFOR as formaPagamento,
       coalesce(( select sum( fagrvalo*fagrdias ) / sum(fagrvalo )
          from arqfagr
          where fagrorig = 'CFAT'
          and fagrempe = CFATEORI
          and fagrdocu = cfatdocu
          and fagrseri = cfatseri
          and fagrvalo > 0 ),0) as prazoMedio,
        replace( coalesce(PAISNOME,'BRASIL')||','||CLI.CADAESTA||','||CLI.CADACIDA||','||CLI.CADABAIR||','||CLI.CADAENDE,'\"' , '') as GeoCliente ,
        CFATDOCU      as NotaFiscal,
        cast (CFATEORI as varchar) ||'-'|| cast (CFATCLIE as varchar) ||'-'|| cast (CFATDOCU as varchar)     as NotaFiscalCont,
    	cast (CFATEORI as varchar) ||'-'|| cast (CFATDOCU as varchar)     as NotaFiscalUnica,
        CFATPEDI      as Pedido,
        cast (CFATEORI as varchar) ||'-'|| cast (CFATCLIE as varchar) ||'-'|| cast (CFATPEDI as varchar)     as PedidoCont,
        CASE WHEN CFATTIPO = 'VD' THEN 'Venda' ELSE 'Devolução' END as TipoNotaFiscal,
        CFATOPER 	as CodNaturezaOperacao,
        OPERDESC 	as DescricaoNaturezaOperacao,
        CFATDATA      as Periodo,
        CFATDATA      as DataMovimento,
        CINADATA      as DataUltimaCompra,
        ( select cfatdata
          from arqcfat
          where cfattipo = 'VD'
          and cfatstat <> 'C'
          and cfatclie = nota.cfatclie
          order by cfatclie, cfatdata
          limit 1) as DataPrimeiraCompra,
        REG.TABEDESC   as Regiao,
        CLI.CADAESTA   as Estado,
        CLI.CADACIDA   as Cidade,
        CFATEORI       as CodUnidadeEmpresa,
        EMP.CADANOME   as UnidadeEmpresa,
        CFATREPR       as CodRepresentanteCont,
        REP.CADANOME   as Representante,
        CFATCLIE       as CodClienteCont,
        CLI.CADANOME   as Cliente,
        CASE  WHEN CFATCLIE = 5000 then 'Consumidor Final' else 'Cliente' end as TipoCliente,
      	replace(replace( coalesce(PAISNOME, 'BRASIL')||','||EMP.CADAESTA||','||EMP.CADACIDA||','||EMP.CADABAIR||','||EMP.CADAENDE,'\"' , ''),'\"', '') as GeoLoja,
        IFATCODI      as CodItemCont,
       	CASE WHEN IFATTPRO = 'M' then CFIFDESC ELSE PRODDESC END as Item,
        CASE WHEN CFATTIPO = 'VD' THEN         (PRODPESB * IFATQUAN) else  (PRODPESB * IFATQUAN)*-1             end AS QtdeItensVendidosKG,
        CASE WHEN CFATTIPO = 'VD' THEN         (PRODLITR * IFATQUAN) else  (PRODLITR * IFATQUAN)*-1             end AS QtdeItensVendidosLT,
        CASE WHEN CFATTIPO = 'VD' THEN         IFATQUAN       else (IFATQUAN)*-1                     end  as QtdeTotalItem,
        CASE WHEN CFATTIPO = 'VD' THEN         IFATPTAB     else (IFATPTAB)*-1                        end as PrecoItem,
        CASE WHEN CFATTIPO = 'VD' THEN         IFATQUAN * IFATPTAB else  (IFATQUAN * IFATPTAB)*-1            end as VlrMercadoria,
        CASE WHEN CFATTIPO = 'VD' THEN         IFATVARI + IFATICMC else  (IFATVARI + IFATICMC)*-1            end as VlrImpostos,
        CASE WHEN CFATTIPO = 'VD' THEN (IFATPTAB - IFATPREC)*IFATQUAN+IFATRDES else  ((IFATPTAB - IFATPREC)*IFATQUAN+IFATRDES)*-1            end as VlrDesconto,
        CASE WHEN CFATTIPO = 'VD' THEN IFATPLIQ - IFATVARI - IFATICMC     else  ( IFATPLIQ - IFATVARI - IFATICMC)*-1      end as VlrNFItem,
        CASE WHEN CFATTIPO = 'VD' THEN IFATRFRE+IFATRSEG+IFATRODE  else (IFATRFRE+IFATRSEG+IFATRODE)*-1     end as ValoresAcessorios,
        CASE WHEN CFATTIPO = 'VD' THEN         IFATPLIQ     else (IFATPLIQ)*-1                        end as ValorProdutos ,
    	CASE WHEN CFATTIPO = 'VD' THEN         IFATFIXO     else (IFATFIXO)*-1                        end as ValorCustoFixo ,
        TPVN.TABEDESC as RepresentanteNI,
        TPCL.TABEDESC as ClienteNI,
        SUBT.TABEDESC as ClienteNII,
        TIPO.TABEDESC as ItemNI,
        SBTP.TABEDESC as ItemNII,
        CFAMDESC as FAMILIA,
        MARCDESC as ItemNIII,
        CASE WHEN CFATTIPO = 'VD' THEN
        COALESCE( ( SELECT SUM( ShxGetCustoItemV10( IFATEMPE,IFATDOCU,IFATSERI,
                                                    IFATSEQU,
                                                    COALESCE( IFIFPROD, IFATCODI),
                                                    'CMED',
                                                    FALSE,
                                                    (IFATTIPO = 'DC' OR IFATTIPO = 'DL'),
                                                    CFATFUTU = 'S') )
                    FROM ARQIFAT AS A
                    LEFT JOIN ARQIFIF ON IFATEMPE = IFIFEMPE AND
                                         IFATDOCU = IFIFDOCU AND
                                         IFATSERI = IFIFSERI AND
                                         IFATSEQU = IFIFSEQU AND
                                         IFIFORIG = 'IFAT'
                    WHERE ITEM.IFATCPRI = A.IFATCPRI), 0 )
         ELSE
         COALESCE( ( SELECT SUM( ShxGetCustoItemV10( IFATEMPE,IFATDOCU,IFATSERI,
                                                    IFATSEQU,
                                                    COALESCE( IFIFPROD, IFATCODI),
                                                    'CMED',
                                                    FALSE,
                                                    (IFATTIPO = 'DC' OR IFATTIPO = 'DL'),
                                                    CFATFUTU = 'S') )
                    FROM ARQIFAT AS A
                    LEFT JOIN ARQIFIF ON IFATEMPE = IFIFEMPE AND
                                         IFATDOCU = IFIFDOCU AND
                                         IFATSERI = IFIFSERI AND
                                         IFATSEQU = IFIFSEQU AND
                                         IFIFORIG = 'IFAT'
                    WHERE ITEM.IFATCPRI = A.IFATCPRI), 0 ) end as CMV,
    CASE WHEN ( select date_trunc('MONTH',cfatdata)
         from arqcfat
         where cfattipo = 'VD'
         and cfatstat <> 'C'
         and cfatclie = nota.cfatclie
         order by cfatclie, cfatdata
         limit 1) = date_trunc('MONTH', CFATDATA) THEN CFATCLIE END as QtdClientesNovos     
FROM   ARQIFAT ITEM
LEFT JOIN     ARQCFAT nota ON CFATCPRI = IFATCFAT
LEFT JOIN     ARQOPER ON OPERCODI = CFATOPER
LEFT JOIN     ARQCADA EMP ON EMP.CADACODI = CFATEORI
LEFT JOIN     ARQCADA REP ON REP.CADACODI = CFATREPR
LEFT JOIN     ARQCADA CLI ON CLI.CADACODI = CFATCLIE
LEFT JOIN     ARQCLIE on CLIECODI = CFATCLIE
LEFT JOIN     ARQVEND on VENDCODI = CFATREPR
LEFT JOIN     ARQTABE TPVN ON TPVN.TABEINDI = 30 AND TPVN.TABECODI = VENDTPVN
LEFT JOIN     ARQTABE TPCL ON TPCL.TABEINDI = 10 AND TPCL.TABECODI = CLIETPCL
LEFT JOIN     ARQTABE SUBT ON SUBT.TABEINDI = 11 AND SUBT.TABECODI = CLIESUBT
LEFT JOIN     ARQPAIS ON CLI.CADACPAI = PAISCPRI
LEFT JOIN     ARQTABE REG ON REG.TABEINDI = 15 AND REG.TABECODI = CLI.CADAREGI
LEFT JOIN     ARQCFIF ON CFIFEMPE = IFATEMPE and CFIFDOCU = IFATDOCU and CFIFSERI = IFATSERI AND CFIFSEQU = IFATSEQU AND CFIFORIG = 'IFAT'
LEFT JOIN     ARQPROD ON PRODCODI = case when IFATTPRO = 'P' THEN IFATCODI ELSE CFIFBASE END
LEFT JOIN     ARQMAST ON MASTCODI = PRODMAST
LEFT JOIN     ARQTABE TIPO ON TIPO.TABEINDI = 100 AND TIPO.TABECODI = MASTTIPO
LEFT JOIN     ARQTABE SBTP ON SBTP.TABEINDI = 110 AND SBTP.TABECODI = MASTSUBT
LEFT JOIN     ARQTABE LINH ON LINH.TABEINDI = 120 AND LINH.TABECODI = MASTGRUP
LEFT JOIN     ARQMARC ON MARCCODI = MASTMARC
LEFT JOIN     ARQCINA ON CINACLIE= CFATCLIE
LEFT JOIN     ARQCFAM ON CFAMCODI = MASTFAMI
LEFT JOIN     ARQCADA FORN ON FORN.CADACODI = MASTFORN
WHERE  CFATTIPO IN ( 'VD', 'DC' )
AND CFATDATA BETWEEN '2021-01-01' AND '2021-01-31'
AND CFATSTAT <> 'C'
AND IFATTPRO <> 'M'
AND CFATEORI not in (099,101,899,900,901,902,903) --empresas inativas

UNION ALL

SELECT
       VENDGERE as CodGerente,
       VENDEMPE as CodEmpresaRepresentante,
       MASTCODI as CodMaster,
       MASTDESC as DescricaoMaster,
       FORN.CADACODI as codFornecedor,
       FORN.CADANOME as NomeFornecedor,
       LINH.TABEDESC AS Linha,
       CFATREPR      as CodRepresentante,
       CFATDFOR as formaPagamento,
        coalesce(( select sum( fagrvalo*fagrdias ) / sum(fagrvalo )
        from arqfagr
        where fagrorig = 'CFAT'
        and fagrempe = CFATEORI
        and fagrdocu = cfatdocu
        and fagrseri = cfatseri
        and fagrvalo > 0 ),0) as prazoMedio,
         replace( coalesce(PAISNOME,'BRASIL')||','||CLI.CADAESTA||','||CLI.CADACIDA||','||CLI.CADABAIR||','||CLI.CADAENDE,'\"' , '') as GeoCliente ,
        CFATDOCU      as NotaFiscal,
        cast (CFATEORI as varchar) ||'-'|| cast (CFATCLIE as varchar) ||'-'|| cast (CFATDOCU as varchar)     as NotaFiscalCont,
        cast (CFATEORI as varchar) ||'-'|| cast (CFATDOCU as varchar)     as NotaFiscalUnica,
    	CFATPEDI      as Pedido,
        cast (CFATEORI as varchar) ||'-'|| cast (CFATCLIE as varchar) ||'-'|| cast (CFATPEDI as varchar)     as PedidoCont,
        CASE WHEN CFATTIPO = 'VD' THEN 'Venda' ELSE 'Devolução' END as TipoNotaFiscal,
        CFATOPER 	as CodNaturezaOperacao,
        OPERDESC 	as DescricaoNaturezaOperacao,
        CFATDATA      as Periodo,
        CFATDATA      as DataMovimento,
        CINADATA      as DataUltimaCompra,
        ( select cfatdata
          from arqcfat
          where cfattipo = 'VD'
          and cfatstat <> 'C'
          and cfatclie = nota.cfatclie
          order by cfatclie, cfatdata
          limit 1) as DataPrimeiraCompra,
        REG.TABEDESC   as Regiao,
        CLI.CADAESTA   as Estado,
        CLI.CADACIDA   as Cidade,
        CFATEORI      as CodUnidadeEmpresa,
        EMP.CADANOME   as UnidadeEmpresa,
        CFATREPR      as CodRepresentanteCont,
        REP.CADANOME   as Representante,
        CFATCLIE      as CodClienteCont,
        CLI.CADANOME   as Cliente,
        CASE  WHEN CFATCLIE = 5000 then 'Consumidor Final' else 'Cliente' end as TipoCliente,  
	replace(replace( coalesce(PAISNOME,'BRASIL')||','||EMP.CADAESTA||','||EMP.CADACIDA||','||EMP.CADABAIR||','||EMP.CADAENDE,'\"' , ''),'\"', '') as GeoLoja,
        IFIFPROD      as CodItemCont,
        PRODDESC  as Item,
        CASE WHEN CFATTIPO = 'VD' THEN (PRODPESB * IFATQUAN* IFIFQBAX)  else (PRODPESB * IFATQUAN* IFIFQBAX)*-1 end AS QtdeItensVendidosKG,
        CASE WHEN CFATTIPO = 'VD' THEN (PRODLITR * IFATQUAN* IFIFQBAX)  else (PRODLITR * IFATQUAN* IFIFQBAX)*-1 end AS QtdeItensVendidosLT,
        CASE WHEN CFATTIPO = 'VD' THEN IFATQUAN*IFIFQBAX else (IFATQUAN*IFIFQBAX)*-1                end as QtdeTotalItem,
        CASE WHEN CFATTIPO = 'VD' THEN IFIFPTAB    else IFIFPTAB*-1                                  end     as PrecoItem,
        CASE WHEN CFATTIPO = 'VD' THEN IFATQUAN * IFIFQBAX * IFIFPTAB   else  IFATQUAN * IFIFQBAX *IFIFPTAB  *-1  end as VlrMercadoria,
        CASE WHEN CFATTIPO = 'VD' THEN IFIFVARI + IFIFICMC  else (IFIFVARI + IFIFICMC)*-1  end as VlrImpostos,
        CASE WHEN CFATTIPO = 'VD' THEN ( IFIFPTAB *IFIFQBAX *IFATQUAN ) - IFIFPLIQ else (( IFIFPTAB *IFIFQBAX *IFATQUAN ) - IFIFPLIQ)*-1 end as VlrDesconto,
        CASE WHEN CFATTIPO = 'VD' THEN    ( IFIFPLIQ - (IFIFVARI + IFIFICMC))     else (( IFIFPLIQ - (IFIFVARI + IFIFICMC )))*-1 end as VlrNFItem,
        CASE WHEN CFATTIPO = 'VD' THEN    IFIFRFRE+IFIFRSEG+IFIFRODE  else  ( IFIFRFRE+IFIFRSEG+IFIFRODE) *-1 end as ValoresAcessorios,
        CASE WHEN CFATTIPO = 'VD' THEN    IFIFPLIQ             else (IFIFPLIQ)*-1   end as ValorProdutos,
    	CASE WHEN CFATTIPO = 'VD' THEN         IFIFFIXO     else (IFIFFIXO)*-1                        end as ValorCustoFixo ,
        TPVN.TABEDESC as RepresentanteNI,
        TPCL.TABEDESC as ClienteNI,
        SUBT.TABEDESC as ClienteNII,
        TIPO.TABEDESC as ItemNI,
        SBTP.TABEDESC as ItemNII,
        CFAMDESC as FAMILIA,
        MARCDESC as ItemNIII,
        CASE WHEN CFATTIPO = 'VD' THEN     ShxGetCustoItemV10( IFATEMPE,IFATDOCU,IFATSERI, IFATSEQU,
                            IFIFPROD,
                            'CMED',
                            FALSE,
                            (IFATTIPO = 'DC' OR IFATTIPO = 'DL'),
                            CFATFUTU = 'S')

     else  (ShxGetCustoItemV10( IFATEMPE,IFATDOCU,IFATSERI, IFATSEQU,
                            IFIFPROD,
                            'CMED',
                            FALSE,
                            (IFATTIPO = 'DC' OR IFATTIPO = 'DL'),
                            CFATFUTU = 'S')) end AS CMV, 
    CASE WHEN ( select date_trunc('MONTH',cfatdata)
         from arqcfat
         where cfattipo = 'VD'
         and cfatstat <> 'C'
         and cfatclie = nota.cfatclie
         order by cfatclie, cfatdata
         limit 1) = date_trunc('MONTH', CFATDATA) THEN CFATCLIE END as QtdClientesNovos
FROM   ARQCFAT NOTA
LEFT JOIN     ARQIFAT ITEM ON CFATCPRI = IFATCFAT
LEFT JOIN     ARQOPER ON OPERCODI = CFATOPER
LEFT JOIN     ARQIFIF ON IFATEMPE = IFIFEMPE AND
                          IFATDOCU = IFIFDOCU AND
                          IFATSERI = IFIFSERI AND
                          IFATSEQU = IFIFSEQU AND
                          IFIFORIG = 'IFAT'
LEFT JOIN     ARQCADA EMP ON EMP.CADACODI = CFATEORI
LEFT JOIN     ARQCADA REP ON REP.CADACODI = CFATREPR
LEFT JOIN     ARQCADA CLI ON CLI.CADACODI = CFATCLIE
LEFT JOIN     ARQCLIE on CLIECODI = CFATCLIE
LEFT JOIN     ARQVEND on VENDCODI = CFATREPR
LEFT JOIN     ARQTABE TPVN ON TPVN.TABEINDI = 30 AND TPVN.TABECODI = VENDTPVN
LEFT JOIN     ARQTABE TPCL ON TPCL.TABEINDI = 10 AND TPCL.TABECODI = CLIETPCL
LEFT JOIN     ARQTABE SUBT ON SUBT.TABEINDI = 11 AND SUBT.TABECODI = CLIESUBT
LEFT JOIN     ARQPAIS ON CLI.CADACPAI = PAISCPRI
LEFT JOIN     ARQTABE REG ON REG.TABEINDI = 15 AND REG.TABECODI = CLI.CADAREGI
LEFT JOIN     ARQCFIF ON CFIFEMPE = IFATEMPE
         and CFIFDOCU = IFATDOCU
         and CFIFSERI = IFATSERI
         AND CFIFSEQU = IFATSEQU
         AND CFIFORIG = 'IFAT'
LEFT JOIN     ARQPROD ON PRODCODI = IFIFPROD
LEFT JOIN     ARQMAST ON MASTCODI = PRODMAST
LEFT JOIN     ARQTABE TIPO ON TIPO.TABEINDI = 100 AND TIPO.TABECODI = MASTTIPO
LEFT JOIN     ARQTABE SBTP ON SBTP.TABEINDI = 110 AND SBTP.TABECODI = MASTSUBT
LEFT JOIN     ARQTABE LINH ON LINH.TABEINDI = 120 AND LINH.TABECODI = MASTGRUP
LEFT JOIN     ARQMARC ON MARCCODI = MASTMARC
LEFT JOIN     ARQCINA ON CINACLIE= CFATCLIE
LEFT JOIN     ARQCFAM ON CFAMCODI = MASTFAMI
LEFT JOIN     ARQCADA FORN ON FORN.CADACODI = MASTFORN
WHERE CFATTIPO IN ( 'VD', 'DC' )
AND CFATDATA BETWEEN '2021-01-01' AND '2021-01-31'
--AND CFATDATA >= (DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL) AND CFATDATA < NOW()::DATE

AND CFATSTAT <> 'C'
AND IFATTPRO = 'M'
AND CFATEORI not in (099,101,899,900,901,902,903) --empresas inativas
