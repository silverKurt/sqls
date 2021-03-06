SELECT  
     "Empresa"
     , "Cod_Item"
     , "Descrição_Item"
     , "Cod_Almox"
     --, "Cod_Unidade_Medida"
     
     , CASE WHEN SUM("Estoque_Atual") = 0 THEN NULL ELSE SUM("Estoque_Atual") END AS "Estoque_Atual"
     , CASE WHEN SUM("Qntd_Vendida") = 0 THEN NULL ELSE SUM("Qntd_Vendida") END AS "Qtde_Pedido"
     , CASE WHEN SUM("Estoque_Final") = 0 THEN NULL ELSE SUM("Estoque_Final") END AS "Saldo"
FROM (
        SELECT TEMPRESAS.COD_EMP|| '-'|| TEMPRESAS.RAZAO_SOCIAL AS "Empresa",
        TITENS.COD_ITEM AS "Cod_Item",
        TITENS.DESC_TECNICA AS "Descrição_Item",
        TALMOXARIFADOS.COD_ALMOX AS "Cod_Almox",
        (TRUNC(SYSDATE,'MONTH')) AS "Periodo",

        FOCCO3I.MAN_EST_RETORNA_SALDO (TITENS_EMPR.EMPR_ID,TITENS.ID,3,TRUNC(SYSDATE)) AS "Estoque_Atual",
        
        NVL((SELECT SUM(ITPDV.QTDE_SLDO)
                FROM FOCCO3I.TITENS_PDV ITPDV
                     , FOCCO3I.TPEDIDOS_VENDA TPDV
                WHERE ITPDV.ITCM_ID  = TITENS_COMERCIAL.ID
                AND TPDV.EMPR_ID = TEMPRESAS.ID
                AND ITPDV.PDV_ID = TPDV.ID
                AND ITPDV.QTDE_SLDO > 0
                AND TPDV.POS_PDV = 'PE'),0) AS "Qntd_Vendida",
                
        FOCCO3I.MAN_EST_RETORNA_SALDO (TITENS_EMPR.EMPR_ID,TITENS.ID,3,TRUNC(SYSDATE))
                - NVL((SELECT SUM(ITPDV.QTDE_SLDO)
                        FROM FOCCO3I.TITENS_PDV ITPDV
                        , FOCCO3I.TPEDIDOS_VENDA TPDV
                        WHERE ITPDV.ITCM_ID  = TITENS_COMERCIAL.ID
                        AND TPDV.EMPR_ID = TEMPRESAS.ID
                        AND ITPDV.PDV_ID = TPDV.ID
                        AND ITPDV.QTDE_SLDO > 0
                        AND TPDV.POS_PDV = 'PE'),0)
                + NVL((SELECT SUM(PDCI.QTDE) 
                        FROM FOCCO3I.TPEDC_ITEM PDCI 
                        WHERE PDCI.ITEM_ID = TITENS_SUPRIMENTOS.ID 
                        AND PDCI.POSICAO = 'P'),0) 
                AS "Estoque_Final"
        
        FROM FOCCO3I.TITENS_COMERCIAL TITENS_COMERCIAL,
        FOCCO3I.TITENS_EMPR TITENS_EMPR,
        FOCCO3I.TITENS TITENS,
        FOCCO3I.TGRP_CLAS_ITE TGRP_CLAS_ITE,
        FOCCO3I.TITENS_SUPRIMENTOS TITENS_SUPRIMENTOS,
        FOCCO3I.TITENS_ESTOQUE TITENS_ESTOQUE,
        FOCCO3I.TITENS_PLANEJAMENTO TITENS_PLANEJAMENTO,
        FOCCO3I.TEMPRESAS TEMPRESAS,
        FOCCO3I.TUNID_MED TUNID_MED,
        FOCCO3I.TALMOXARIFADOS TALMOXARIFADOS
        WHERE TITENS_EMPR.ID = TITENS_PLANEJAMENTO.ITEMPR_ID
        AND TITENS_EMPR.ID = TITENS_ESTOQUE.ITEMPR_ID
        AND TITENS_EMPR.ID = TITENS_SUPRIMENTOS.ITEMPR_ID
        AND TITENS_EMPR.ID = TITENS_COMERCIAL.ITEMPR_ID
        AND TITENS.ID = TITENS_EMPR.ITEM_ID
        AND TGRP_CLAS_ITE.ID = TITENS_COMERCIAL.GRP_CLAS_ID
        AND TEMPRESAS.ID = TALMOXARIFADOS.EMPR_ID
        AND TEMPRESAS.ID = TITENS_EMPR.EMPR_ID
        AND TUNID_MED.ID = TITENS_ESTOQUE.UNID_MED_ID
        AND TALMOXARIFADOS.ID = TITENS_ESTOQUE.ALMOX_ID
        AND (NVL((SELECT SUM(ITPDV.QTDE_SLDO)
                FROM FOCCO3I.TITENS_PDV ITPDV
                        , FOCCO3I.TPEDIDOS_VENDA TPDV
                WHERE ITPDV.ITCM_ID  = TITENS_COMERCIAL.ID
                AND TPDV.EMPR_ID = TEMPRESAS.ID
                AND ITPDV.PDV_ID = TPDV.ID
                AND ITPDV.QTDE_SLDO > 0
                AND TPDV.POS_PDV = 'PE'),0)) > '0'
        AND ( TGRP_CLAS_ITE.COD_GRP_ITE BETWEEN '01.01.010.00001' AND '09.14.010.00006')
        AND (TALMOXARIFADOS.COD_ALMOX = '3')
) X
GROUP BY "Empresa"
     , "Pedido"
     , "Cod_Item"
     , "Descrição_Item"
     , "Cod_Unidade_Medida"