SELECT *
    , CASE
      WHEN CAST(DATEADD(MM, DATEDIFF(MM, 0, "Data Primeira Compra"), 0) AS DATE) = CAST(DATEADD(MM, DATEDIFF(MM, 0, "Data Ultima Compra"), 0) AS DATE) THEN 'Cliente Novo'
          WHEN CAST((GETDATE() - "Data Penultima Compra") AS INTEGER) > 90 THEN 'Cliente Recapturado'
              WHEN CAST((GETDATE() - "Data Ultima Compra") AS INTEGER) <= 90 THEN 'Cliente Ativo'
          ELSE 'Cliente Inativo'
        END AS "Situacao Clientes"
FROM
(
SELECT
          t.Ordem                           AS "Qtde Ordem"
        , t.Ordem                           AS "Ordem"
        , t.Data_Efetivado_Estoque          AS "Data"
        , t.Data_Efetivado_Estoque          AS "Data Filtro"
        , CONVERT(VARCHAR,(t.Data),103)     AS "Data Geo"
        , t.Criado_Por                      AS "Qtde Vendedor"
        , t.Tipo_Operacao                   AS 'Tipo Operação'
        , CONCAT(O.Codigo, ' - ', O.Nome) AS 'Tipo Venda'
      --  , t.Criado_Por                      AS "Vendedor"
        , f2.Nome                           AS "Vendedor"
        , t.NFCE_Cupom_Documento_Cliente    AS "Qtde Cupom"
        , t.NFCE_Cupom_Documento_Cliente    AS "Cupom"
        , t.NFCE_Cupom_Nome_Cliente         AS "Qtde Cliente"
        , CONCAT(t.NFCE_Cupom_Nome_Cliente, ' - ', C.Fone_1) AS "Cliente"
        , C.Fantasia                AS "Cliente Fantasia"
        , t.NFCE_Cupom_UF_Cliente           AS "Qtd UF"
        , t.NFCE_Cupom_UF_Cliente           AS "UF"
        , t.NFCE_Cupom_Cidade_Cliente       AS "Qtd Cidade"
        , t.NFCE_Cupom_Cidade_Cliente       AS "Cidade"
        , t.NFCE_Cupom_Bairro_Cliente       AS "Bairro"
        , CONCAT(t.NFCE_Cupom_Endereco_Cliente, ', ', t.NFCE_Cupom_Numero_Cliente) AS "Endereco"
        , CONCAT('BRASIL',', ', C.estado,', ', C.cidade) AS "Geo"
        , s3.Codigo                         AS "Codigo"
        , s3.Nome                           AS "Produto"
        , cl.nome 							AS "Marca"
        , sc.nome 							AS "Fornecedor"
        , s2.Quantidade_Itens               AS "Qtde Produto"
        , s2.Preco_Unitario                 AS "Valor Unitario"
        , s2.Preco_Final_Sem_Frete          AS "Valor Sem Frete"
        , S2.Frete_Valor                    AS "Valor Frete"
        , s2.Preco_Final -S2.Frete_Valor    AS "Valor Final"
        , CONCAT(f.Codigo, '-', f.Nome)     AS "Filial"
        , (SELECT distinct MIN(Data) FROM Movimento m where  m.NFCE_Cupom_Documento_Cliente  = t.NFCE_Cupom_Documento_Cliente and m.Tipo_Operacao IN ('PVN')  and m.Data_Efetivado_Estoque >= '2018-07-01') as "Data Primeira Compra"
        , (SELECT distinct MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Documento_Cliente  = t.NFCE_Cupom_Documento_Cliente and m.Tipo_Operacao IN ('PVN') and m.Data_Efetivado_Estoque >= '2018-07-01') as "Data Ultima Compra"
    , CONVERT(VARCHAR,(SELECT distinct MAX(Data)  FROM Movimento m where  m.NFCE_Cupom_Documento_Cliente  = t.NFCE_Cupom_Documento_Cliente and m.Tipo_Operacao IN ('PVN')),103) as "Data Ultima Compra Geo"
        , (SELECT MAX(B.Data) FROM Movimento B WHERE B.NFCE_Cupom_Documento_Cliente = t.NFCE_Cupom_Documento_Cliente and B.Tipo_Operacao IN ('PVN') 
           AND B.Data < (SELECT MAX(D.Data) FROM Movimento D WHERE D.NFCE_Cupom_Documento_Cliente = B.NFCE_Cupom_Documento_Cliente and  D.Tipo_Operacao IN ('PVN') ) and B.Data_Efetivado_Estoque >= '2018-07-01') as "Data Penultima Compra"
        , CONVERT(VARCHAR,(SELECT distinct MAX(Data)  FROM Movimento m where  m.NFCE_Cupom_Documento_Cliente  = t.NFCE_Cupom_Documento_Cliente and m.Tipo_Operacao IN ('PVN')),103) as "Ultima Compra"
        , CASE
              WHEN O.Codigo IN (540, 550) THEN 'SUNTECH'
              WHEN O.Codigo IN (560, 570, 580, 683) THEN 'OIW'
              WHEN O.Codigo IN (691, 693) THEN 'CONNECTOWAY'
              ELSE CAST(O.Codigo AS VARCHAR)
          END AS "Origem"
        , CASE
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) <=  30 THEN 'R1 - Últimos 30 Dias'
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) <=  60 THEN 'R2 - 31 A 60 Dias'
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) <=  90 THEN 'R3 - 61 A 90 Dias'
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) >   91 THEN 'R4 - Acima de 90 Dias'
            --  WHEN GETDATE () - (SELECT MAX(Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente) <= 180 THEN 'R4 - 121 A 180 Dias'
            --  WHEN GETDATE () - (SELECT MAX(Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente) <= 360 THEN 'R5 - 181 A 360 Dias'
            --  WHEN GETDATE () - (SELECT MAX(Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente) > 360 THEN 'Acima de 360 Dias'
          END AS "Faixa de Recência"
        , CASE
              WHEN (SELECT COUNT (Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN')) >= 12 THEN 'F1 - 12 vezes ou mais'
              WHEN (SELECT COUNT (Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN')) >= 10 THEN 'F2 - 10 a 11 vezes'
              WHEN (SELECT COUNT (Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN')) >=  6 THEN 'F3 - 6 a 9 vezes'
              WHEN (SELECT COUNT (Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN')) >=  2 THEN 'F4 - 2 a 5 vezes'
              WHEN (SELECT COUNT (Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN')) >=  1 THEN 'F5 - 1 vez'
          END AS "Faixa de Frequência"
        , CASE
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) <=  30 THEN 'Bom'
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) <=  60 THEN 'Razoavel'
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) <=  90 THEN 'Ruim'
              WHEN (GETDATE () - (SELECT DISTINCT MAX(Data) FROM Movimento m where  m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN'))) >   91 THEN 'Inativos'
            --  WHEN GETDATE () - (SELECT MAX(Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente) > 360 THEN 'Acima de 360 Dias'
          END AS "Faixa Dias sem Compra"
        , DATEDIFF(DD, (SELECT MAX(Data) FROM Movimento m where m.NFCE_Cupom_Nome_Cliente  = t.NFCE_Cupom_Nome_Cliente and m.Tipo_Operacao IN ('PVN') and m.Data_Efetivado_Estoque >= '2018-07-01'),  GETDATE () ) AS "Dias sem Compra" --and m.Tipo_Operacao IN ('PVN') -- Adicionei essa condição considerando a mesma lógica da "data da última compra"

FROM Movimento t
INNER JOIN Movimento_Prod_Serv S2 ON t.Ordem = S2.Ordem_Movimento
INNER JOIN Prod_Serv S3 ON S2.Ordem_Prod_Serv = S3.Ordem
LEFT JOIN Classes cl ON cl.Ordem = S3.Ordem_Classe
LEFT JOIN SubClasses sc ON sc.Ordem = S3.Ordem_Subclasse
INNER JOIN Filiais F ON t.Ordem_Filial = F.Ordem
INNER JOIN Funcionarios F2 ON S2.Ordem_Vendedor = F2.Ordem
INNER JOIN Cli_For C ON t.NFCE_Cupom_Documento_Cliente = C.CNPJ_Limpo
INNER JOIN Operacoes O ON t.Ordem_Operacao = O.Ordem
WHERE O.Tipo = 'PVN'
AND t.Data >= '2018-07-01'
AND  t.Criado_Por not in ('ADMIN', 'JAQUES')
AND s2.Excluido_Pelo_Shop <> '1'
AND s2.Estoque_Desefetivado <> '1'
AND s2.Estoque_Efetivado = '1'
AND C.Bloqueado = 'false'
--AND t.Data_Efetivado_Estoque >= '2018-07-01'
 --and t.NFCE_Cupom_Nome_Cliente = 'FABLO COPATTI CARA'
-- and  t.Criado_Por = 'Evandro'
 ) a