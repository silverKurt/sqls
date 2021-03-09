-- Source: notas_unicas
SELECT 
	CAST("PEDIDO" AS TEXT) AS "PEDIDO",
	CAST("CODIGO" AS TEXT) AS "CODIGO",
	CAST("EMP" AS TEXT) AS "EMP",
	CAST("PRAZO" AS TEXT) AS "PRAZO",
	CAST("NOME_DO_CLIENTE" AS TEXT) AS "NOMEDOCLIENTE",
	CAST("EMPORIG" AS TEXT) AS "EMPORIG",
    CAST("DOCUMENTO" AS TEXT) AS "DOCUMENTO",
	CAST("NATUREZA_DEOPERACAO" AS TEXT) AS "NATUREZADEOPERACAO",
	CAST("VENDEDOR" AS TEXT) AS "VENDEDOR",
	CAST("FORMA_DEPAGAMENTO" AS TEXT) AS "FORMADEPAGAMENTO",
	CAST("EMISSAO" AS DATE) AS "EMISSAO",
	CAST("VALORPRODUTOS" AS DOUBLE PRECISION) AS "VALORPRODUTOS",
	CAST("DESCONTODESTACADO" AS DOUBLE PRECISION) AS "DESCONTODESTACADO",
	CAST("VALORTOTAL" AS DOUBLE PRECISION) AS "VALORTOTAL",
	CAST("VALOR_VENDAPRECO_TABELA" AS DOUBLE PRECISION) AS "VALORVENDAPRECOTABELA",
	CAST("VALORA_PRAZO" AS DOUBLE PRECISION) AS "VALORAPRAZO",
	CAST("_TOTALDESCONTO" AS DOUBLE PRECISION) AS "TOTALDESCONTO",
	CAST("VALORA_VISTA" AS DOUBLE PRECISION) AS "VALORAVISTA",
	CAST("VALOR_TOTALDESCONTO" AS DOUBLE PRECISION) AS "VALORTOTALDESCONTO",
	CAST("VALOR_DAFORMA" AS DOUBLE PRECISION) AS "VALORDAFORMA",
	CAST("VALORFRETE" AS DOUBLE PRECISION) AS "VALORFRETE"
FROM "rntintas"."fat_rntintas_notasunicas"
WHERE CAST("NATUREZA_DEOPERACAO" AS TEXT) IN ('VENDA MERC.REC.TERC.', 'VENDA ADQ.TERC. ENCOM.ENT.FUT.')
AND CAST("DOCUMENTO" AS TEXT) NOT ILIKE '%V%'
AND CAST("VALORTOTAL" AS DOUBLE PRECISION) <> 0.0
--AND CAST("DOCUMENTO" AS TEXT) = '005565-G'
operdesc

/*
cfatcond

cfatoper
arqoper

cfatfisc - 5405

008018-G	
000148-G

298949-N

Primeiro filtro: Natura de Operação Venda ADQ de Terceiros (045 e 046) e Venda Mercadoria (001 e 002).
Segundo: Remover série V
Terceiro: Remover todas as Vlr Total 0

CAST("notafiscal" AS TEXT)

"rntintas"."fat_rntintas_ETLFaturamento"
SELECT CAST(cfatdocu AS TEXT) FROM ARQCFAT WHERE cfatdocu = '000148' AND cfatseri = 'G' and CFATDATA >='2021-01-01'


select * from arqoper

/*SELECT operdesc 
FROM ARQCFAT 
left join arqoper on operorel = cfatfisc
WHERE cfatdocu = '000148' AND cfatseri = 'G' and CFATDATA >='2021-01-01'*/

--select * from arqoper

12953
12952
12951
-- Source: Faturamento Gerencial
SELECT 
	CAST("periodo" AS DATE) AS "periodo",
	CAST("Tipo Cliente" AS TEXT) AS "TipoCliente",
	CAST("datamovimento" AS DATE) AS "datamovimento",
	CAST("geoloja" AS TEXT) AS "geoloja",
	CAST("estado" AS TEXT) AS "estado",
	CAST("nomefornecedor" AS TEXT) AS "nomefornecedor",
	CAST("dataultimacompra" AS DATE) AS "dataultimacompra",
	CAST("dataprimeiracompra" AS DATE) AS "dataprimeiracompra",
	CAST("notafiscal" AS TEXT) AS "notafiscal",
	CAST("geocliente" AS TEXT) AS "geocliente",
	CAST("cidade" AS TEXT) AS "cidade",
	CAST("clienteni" AS TEXT) AS "clienteni",
	CAST("itemni" AS TEXT) AS "itemni",
	CAST("itemnii" AS TEXT) AS "itemnii",
	CAST("formapagamento" AS TEXT) AS "formapagamento",
	CAST("codgerente" AS TEXT) AS "codgerente",
	CAST("item" AS TEXT) AS "item",
	CAST("tiponotafiscal" AS TEXT) AS "tiponotafiscal",
	CAST("codrepresentante" AS TEXT) AS "codrepresentante",
	CAST("linha" AS TEXT) AS "linha",
	CAST("familia" AS TEXT) AS "familia",
	CAST("unidadeempresa" AS TEXT) AS "unidadeempresa",
	CAST("descricaomaster" AS TEXT) AS "descricaomaster",
	CAST("clientenii" AS TEXT) AS "clientenii",
	CAST("representanteni" AS TEXT) AS "representanteni",
	CAST("regiao" AS TEXT) AS "regiao",
	CAST("representante" AS TEXT) AS "representante",
	CAST("codempresarepresentante" AS TEXT) AS "codempresarepresentante",
	CAST("pedido" AS TEXT) AS "pedido",
	CAST("cliente" AS TEXT) AS "cliente",
	CAST("itemniii" AS TEXT) AS "itemniii",
	CAST("codmaster" AS TEXT) AS "codmaster",
	CAST("codclientecont" AS TEXT) AS "codclientecont",
	CAST("codfornecedor" AS DOUBLE PRECISION) AS "codfornecedor",
	CAST("valorprodutos" AS DOUBLE PRECISION) AS "valorprodutos",
	CAST("qtdeitensvendidoslt" AS DOUBLE PRECISION) AS "qtdeitensvendidoslt",
	CAST("qtdclientesnovos" AS TEXT) AS "qtdclientesnovos",
	CAST("vlrdesconto" AS DOUBLE PRECISION) AS "vlrdesconto",
	CAST("vlrimpostos" AS DOUBLE PRECISION) AS "vlrimpostos",
	CAST("vlrmercadoria" AS DOUBLE PRECISION) AS "vlrmercadoria",
	CAST("codunidadeempresa" AS DOUBLE PRECISION) AS "codunidadeempresa",
	CAST("precoitem" AS DOUBLE PRECISION) AS "precoitem",
	CAST("coditemcont" AS TEXT) AS "coditemcont",
	CAST("valorcustofixo" AS DOUBLE PRECISION) AS "valorcustofixo",
	CAST("codrepresentantecont" AS TEXT) AS "codrepresentantecont",
	CAST("vlrnfitem" AS DOUBLE PRECISION) AS "vlrnfitem",
	CAST("valoresacessorios" AS DOUBLE PRECISION) AS "valoresacessorios",
	CAST("notafiscalcont" AS TEXT) AS "notafiscalcont",
	CAST("qtdetotalitem" AS DOUBLE PRECISION) AS "qtdetotalitem",
	CAST("cmv" AS DOUBLE PRECISION) AS "cmv",
	CAST("pedidocont" AS TEXT) AS "pedidocont",
	CAST("prazomedio" AS DOUBLE PRECISION) AS "prazomedio",
	CAST("notafiscalunica" AS TEXT) AS "notafiscalunica",
	CAST("qtdeitensvendidoskg" AS DOUBLE PRECISION) AS "qtdeitensvendidoskg" 
FROM "rntintas"."fat_rntintas_ETLFaturamento"
*/



6075821.710000
5550637.790000
2516943.940000