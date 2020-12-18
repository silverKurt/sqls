WITH meses AS (
    SELECT DISTINCT cast(dateadd(mm, datediff(mm, 0, R8_DATAINI), 0) AS date) AS "Periodo"
 	FROM SR8010
 	WHERE dateadd(mm, datediff(mm, 0, R8_DATAINI), 0) >= CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0) AS DATE)
) , AFA010 AS (
  SELECT DISTINCT
      LTRIM(RTRIM(RCM.RCM_DESCRI)) + ' (' + LTRIM(RTRIM(RCM.RCM_TIPO)) + ')' AS "Motivo"
      , LTRIM(RTRIM(X.R8_NOME)) + ' (' + LTRIM(RTRIM(X.R8_MAT)) + ')'  AS "Colaborador"
      , LTRIM(RTRIM(X.R8_MAT)) AS "Qtde de Colaboradores"
      , LTRIM(RTRIM(X.R8_FILIAL)) AS "Filial"
      , CAST(X.R8_DATAINI AS DATE) AS "Data de Afastamento"
      , CAST(X.R8_DATAFIM AS DATE) AS "Data de Volta" 
      , CASE WHEN SRA.RA_SITFOLH <> ' ' THEN LTRIM(RTRIM(SRA.RA_SITFOLH)) ELSE 'E' END AS "Situacao da Folha"
      , LTRIM(RTRIM(SRA.RA_CATFUNC)) AS "Categoria de Funcao"
  FROM (
    SELECT
      LTRIM(RTRIM(SRA.RA_NOME)) AS "R8_NOME"
      , LTRIM(RTRIM(SRA.RA_FILIAL)) AS "R8_FILIAL"
      , MAX(LTRIM(RTRIM(SRA.RA_MAT))) AS "R8_MAT"
      , MAX(SR8.R8_TIPOAFA) AS "R8_TIPOAFA"
      , MAX(CAST(CONVERT(VARCHAR(25), SR8.R8_DATAINI, 122) AS DATE)) AS "R8_DATAINI"
      , MAX(CASE WHEN SR8.R8_DATAFIM <> ' ' THEN CAST(CONVERT(VARCHAR(25), SR8.R8_DATAFIM, 122) AS DATE) ELSE CAST(dateadd(m, datediff(m, 0, GETDATE()), 0) AS DATE) END) AS "R8_DATAFIM" 
    FROM SR8010 SR8
    LEFT JOIN SRA010 SRA ON (SR8.R8_FILIAL = SRA.RA_FILIAL AND SR8.R8_MAT = SRA.RA_MAT)
    WHERE SR8.D_E_L_E_T_ <> '*' AND SRA.D_E_L_E_T_ <> '*'
    --AND SRA.RA_SITFOLH NOT IN ('A', 'D', 'F', 'T') AND SRA.RA_CATFUNC = 'M'
    GROUP BY LTRIM(RTRIM(SRA.RA_NOME)), LTRIM(RTRIM(SRA.RA_FILIAL))
  ) X
  LEFT JOIN SRA010 SRA ON (X.R8_FILIAL = SRA.RA_FILIAL AND X.R8_MAT = SRA.RA_MAT)
  LEFT JOIN RCM010 RCM ON (X.R8_TIPOAFA = RCM.RCM_TIPO AND RCM.D_E_L_E_T_ <> '*')
  LEFT JOIN CTT010 CTT ON (SRA.RA_CC = CTT.CTT_CUSTO AND CTT.D_E_L_E_T_ <> '*')
  WHERE dateadd(m, datediff(m, 0, "R8_DATAFIM" ), 0) >= dateadd(m, datediff(m, 0, GETDATE()), 0)
), funcionarios AS (
	SELECT RA_MAT AS "Quantidade",
	    RA_MAT AS "Matricula",
	    RA_NOME + ' (' + RA_MAT +')' AS "Nome",
	    CASE
	        WHEN RA_SEXO = 'M' THEN 'Masculino'
	        WHEN RA_SEXO = 'F' THEN 'Feminino'
	        ELSE 'Indefinido'
	    END AS "Genero",
	    CASE
	        WHEN RA_ESTCIVI = 'C' THEN 'CASADO'
	        WHEN RA_ESTCIVI = 'S' THEN 'SOLTEIRO'
	        WHEN RA_ESTCIVI = 'D' THEN 'DIVORCIADO'
	        WHEN RA_ESTCIVI = 'M' THEN 'UNIÃO ESTÁVEL'
	        WHEN RA_ESTCIVI = 'V' THEN 'VIÚVO'
	        ELSE 'OUTROS'
	    END AS "Estado Civil",
	    CASE
	        WHEN RA_DEFIFIS = '2' THEN 'NÃO'
	        ELSE 'SIM'
	    END "PNE",
	    CAST(CONVERT(VARCHAR(25), RA_ADMISSA, 122) AS DATETIME) AS "Data de admissao",
	    RJ_DESC AS "Cargo",
	    CASE
	        WHEN RA_SITFOLH = ' ' THEN 'EFETIVO'
	        WHEN RA_SITFOLH = 'F' THEN 'FERIAS'
	        WHEN RA_SITFOLH = 'D' THEN 'DEMITIDO'
	        WHEN RA_SITFOLH = 'A' THEN 'AFASTADO'
	        ELSE 'NÃO MAPEADO'
	    END AS "Status",
	    CASE
	        WHEN RA_CODFUNC IN ('00003', '00008', '00009', '00014', '00015', '00018', '00019', '00021', '00028', '00029', '00031', '00032', '00034', '00036', '00037', '00041', '00043', '00048', '00049', '00053', '00055', '00056', '00062', '00063', '00066', '00069', '00074', '00079', '00080', '00084', '00087', '00089', '00090', '00091', '00094', '00099', '00101', '00104', '00106', '00108', '00112', '00119', '00120', '00122', '00125', '00131', '00132', '00133', '00214', '00217', '00222', '00226', '00229', '00235', '00238', '00239', '00242', '00253', '00256', '00257', '00258', '00260', '00296', '00298', '00301', '00303', '00305', '00308', '00310', '00311', '00312', '00313', '00329', '04', '110', '234') THEN 'Alto'
	        WHEN RA_CODFUNC IN ('00005', '00012', '00040', '00046', '00051', '00054', '00067', '00068', '00070', '00085', '00086', '00098', '00103', '00115', '00124', '00216', '00237', '00255', '00261', '00262', '00263', '00265', '00266', '00267', '00295', '00314', '00315', '00316', '00317', '00323', '00330', '00331', '00332', '99999') THEN 'Medio'
	        ELSE 'Baixo'
	    END AS "Grau Hierarquico", -- Regra passada pelo Cliente
	    DATEDIFF(MONTH, CAST(CONVERT(VARCHAR(25), RA_ADMISSA, 102) AS DATETIME), GETDATE()) AS "Tempo de Empresa",
	    CASE
	        WHEN RA_DEMISSA = '        ' THEN NULL
	        ELSE CAST(CONVERT(VARCHAR(25), RA_DEMISSA, 122) AS DATETIME)
	    END AS "Data de demissao",
	    CASE
	        WHEN RA_FILIAL = 00 THEN '00 - FILIAL 00'
	        WHEN RA_FILIAL = 01 THEN '01 - FILIAL 01'
	        WHEN RA_FILIAL = 02 THEN '02 - FILIAL 02'
	        ELSE 'OUTROS'
	    END AS "Filial",
	    RA_CC AS "CodCentroCusto",
	    CTT_DESC01 AS "CentroCusto",
	    CASE
	        WHEN RA_CATFUNC = 'A' THEN 'Autonomo'
	        WHEN RA_CATFUNC = 'E' THEN 'Estagiario'
	        WHEN RA_CATFUNC = 'P' THEN 'Sócio'
	        WHEN RA_CATFUNC = 'M' THEN 'Mensalista'
	        WHEN RA_CATFUNC = 'G' THEN 'Aprendiz'
	        ELSE 'Indefinido'
	    END AS "Categoria Funcionario",
	    RA_CODFUNC AS "Funcao" ,
	    RA_SALARIO AS "Salario" ,
	    CASE WHEN LTRIM(RTRIM(CONVERT(VARCHAR(255), RA_DEPTO))) <> '' THEN LTRIM(RTRIM(CONVERT(VARCHAR(255), RA_DEPTO))) + ' - ' + RTRIM(CONVERT(VARCHAR(255), QB_DESCRIC))
	    	WHEN RA_CATFUNC = 'A' THEN '00 - AUTONOMO'--LTRIM(RTRIM(CONVERT(VARCHAR(255), RA_DEPTO))) = '' AND LTRIM(RTRIM(CONVERT(VARCHAR(255), RA_DEP2))) = '' THEN '00 - AUTONOMO'
	        ELSE LTRIM(RTRIM(CONVERT(VARCHAR(255), RA_DEP2))) + ' - ' + RTRIM(CONVERT(VARCHAR(255), QB_DESCRIC))
	    END AS 'Departamento',

	    CASE 
  			WHEN SUBSTRING(RCC_CONTEU, 3, 30) <> ' ' THEN SUBSTRING(RCC_CONTEU, 3, 30) 
  			WHEN RTRIM(LTRIM(RA_DEMISSA)) = '' THEN NULL
  			ELSE 'RESCISAO ESTAGIARIO' 
  		END AS "Descricao Tipo Demissao",
	
	    CASE WHEN RA_SITFOLH = 'A' AND SR8."Qtde de Colaboradores" IS NULL THEN RA_MAT ELSE SR8."Qtde de Colaboradores" END AS "Qtde Colaboradores Afastados",
	    SR8."Data de Afastamento",
	    SR8."Data de Volta",
	    CASE WHEN RA_SITFOLH = 'A' AND SR8."Motivo" IS NULL THEN 'SEM MOTIVO CADASTRADO' ELSE SR8."Motivo" END AS "Motivo"

	FROM SRA010
	LEFT OUTER JOIN SRG010 ON RA_MAT = RG_MAT AND RA_FILIAL = RG_FILIAL AND SRG010.D_E_L_E_T_ <> '*'
	LEFT OUTER JOIN RCC010 ON RG_TIPORES = SUBSTRING(RCC_CONTEU, 1, 2) AND RCC_CODIGO = 'S043' AND RCC010.D_E_L_E_T_ <> '*'
	LEFT OUTER JOIN CTT010 ON RA_CC = CTT_CUSTO AND CTT010.D_E_L_E_T_ <> '*'
	LEFT OUTER JOIN SRJ010 ON RA_CODFUNC = RJ_FUNCAO AND SRJ010.D_E_L_E_T_ <> '*'
	LEFT OUTER JOIN SQB010 ON (CASE WHEN RA_DEPTO <> '' THEN RA_DEPTO ELSE RA_DEP2 END) = QB_DEPTO AND SQB010.D_E_L_E_T_ <> '*'
	LEFT OUTER JOIN AFA010 SR8 ON SR8."Filial" = RA_FILIAL AND SR8."Qtde de Colaboradores" = RA_MAT
	WHERE SRA010.D_E_L_E_T_ <> '*' 
)
SELECT 
		"Periodo"
		, "Quantidade"
		, "Matricula"
		, "Nome"
		, "Genero"
		, "Estado Civil"
		, "PNE"
		, "Data de admissao"
		, "Cargo"
		, "Status"
		, "Grau Hierarquico" 
		, "Tempo de Empresa"
		, "Data de demissao"
		, "Filial"
		, UPPER("CentroCusto")+' ('+LTRIM(RTRIM("CodCentroCusto"))+')' AS CodCentroCusto
		, "CentroCusto"
		, "Categoria Funcionario"
		, "Funcao" 
		, "Salario" 
		, CASE
    			WHEN f."Data de demissao" IS NOT NULL AND dateadd(m, datediff(m, 0, f."Data de demissao"), 0) = m."Periodo" AND dateadd(m, datediff(m, 0, f."Data de admissao"), 0) = m."Periodo" THEN 'ADMITIDO E DEMITIDO'
    			WHEN dateadd(m, datediff(m, 0, f."Data de admissao"), 0) = m."Periodo" THEN 'NOVA ADMISSAO'
  				WHEN f."Data de demissao" IS NOT NULL AND dateadd(m, datediff(m, 0, f."Data de demissao"), 0) = m."Periodo" THEN 'DEMITIDO'
    			ELSE NULL
		END AS "contaadmissoes"
		, "Departamento"
		, "Descricao Tipo Demissao"
		, "Qtde Colaboradores Afastados" AS "Qtde Colaboradores Afastados"
		, "Data de Afastamento"
		, "Data de Volta"
		, "Motivo"
FROM funcionarios f
INNER JOIN meses m ON (m."Periodo" >= dateadd(m, datediff(m, 0, "Data de admissao"), 0) AND m."Periodo" <= COALESCE(dateadd(m, datediff(m, 0, "Data de demissao"), 0), dateadd(m, datediff(m, 0, getdate()), 0)))
--WHERE "Nome" LIKE '%DANIELE DOS SANTOS MESSIAS%'
ORDER BY "Periodo"
