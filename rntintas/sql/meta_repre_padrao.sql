-- META VENDEDOR
SELECT 
	METADATA AS DATA,
	'REPRESENTANTE' AS TIPO,
    METACODI AS COD_REPRESENTANTE,
    REP.CADANOME AS REPRESENTANTE,
    METAVALO AS META,
    METALITR AS VOLUME_META
FROM ARQMETA
LEFT JOIN ARQCADA REP ON REP.CADACODI = METACODI
WHERE METATIPO = 'V'
AND METADATA >= '2017-01-01'
ORDER BY METACODI, METADATA