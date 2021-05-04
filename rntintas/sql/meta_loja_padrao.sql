-- META LOJA
SELECT 
    METADATA AS DATA,
	'LOJA' AS TIPO,
	METAEMPE AS COD_EMPRESA,
	EMP.CADANOME AS EMPRESA,
    METAVALO AS META,
    --METAVQUI,
    METALITR AS LITRAGEM_META
FROM ARQMETA
LEFT JOIN ARQCADA EMP ON EMP.CADACODI = ARQMETA.METAEMPE
WHERE METATIPO = 'E'
AND METADATA >= '2018-01-01'
AND METAEMPE NOT IN (101,900,901,902,903) --EMPRESAS INATIVAS
ORDER BY METAEMPE, METADATA