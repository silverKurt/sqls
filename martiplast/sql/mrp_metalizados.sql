WITH DADOS AS (

  SELECT DISTINCT Cd_material, Cd_Especif1 FROM ESMOVIME

)

SELECT DISTINCT ltrim(rtrim(a.cd_material)) + ' - ' + a.descricao + ' - ' + e.descricao  AS 'Material',
     d.Cd_Especif1 AS "Especificador",
         b.liberacao                                        AS 'Liberacao',
         ( CASE WHEN b.liberacao != '' THEN 'C/Liberação'
           else 'S/Liberação' end)                          AS 'Status Liberacao',
         b.tipo                                             AS 'Tipo Demanda',
         a.Cd_grupo       + ' - ' + j.descricao             AS 'Grupo Material',
         a.Cd_sub_grupo   + ' - ' + i.descricao             AS 'SubGrupo Material',
         b.dt_programada                                    AS 'Periodo',
         b.dt_programada                                    AS 'Periodo Filtro',
         b.qt_saldo                                         AS 'Qtde Demanda Liberada',
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK) 
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '100') AS 'Saldo CA 100',       
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '001') AS 'Saldo CA 001',
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '360') AS 'Saldo CA 360',
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '400') AS 'Saldo CA 400',
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material  AND x.Cd_Especif1 = d.Cd_Especif1) AS 'TOTAL ESTOQUE',

    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '701') AS 'Saldo CA 701',
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '200') AS 'Saldo CA 200',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '702') AS 'Saldo CA 702',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '703') AS 'Saldo CA 703',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '704') AS 'Saldo CA 704',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '705') AS 'Saldo CA 705',
    (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and
          x.cd_centro_armaz = '706') AS 'Saldo CA 706', 

      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '707') AS 'Saldo CA 707',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '708') AS 'Saldo CA 708',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '709') AS 'Saldo CA 709',

      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '711') AS 'Saldo CA 711',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '715') AS 'Saldo CA 715',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '716') AS 'Saldo CA 716',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '717') AS 'Saldo CA 717',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '718') AS 'Saldo CA 718',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '719') AS 'Saldo CA 719',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '720') AS 'Saldo CA 720',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '714') AS 'Saldo CA 714',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '713') AS 'Saldo CA 713',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '712') AS 'Saldo CA 712',
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          x.cd_centro_armaz = '710') AS 'Saldo CA 710',
      
      (SELECT SUM(x.quantidade)
          FROM ESESTOQU x (NOLOCK)
          INNER JOIN ESCARMAZ car ON (x.cd_centro_armaz = car.Cd_centro_armaz)
          WHERE x.cd_material = a.cd_material AND x.Cd_Especif1 = d.Cd_Especif1 and 
          car.campo31 = 'true') AS 'Saldo CAs Planejamento',

      ( SELECT (SUM(pc.Quantidade)) 
        FROM COIORDEM pc (NOLOCK) 
        WHERE pc.cd_material = a.cd_material AND pc.Cd_Especif1 = d.Cd_Especif1 and pc.situacao in ('A','P') ) AS 'Saldo OC',
      
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento)   = 01  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Jan',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 02  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Fev',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 03  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Mar',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 04  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Abri',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 05  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Mai',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 06  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Jun',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 07  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Jul',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 08  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Ago',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 09  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Set',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 10  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Out',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 11  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Nov',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 12  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Dez',

       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento)   = 01  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Jan AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 02  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Fev AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 03  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Mar AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 04  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())-1   and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Abri AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 05  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Mai AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 06  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Jun AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 07  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Jul AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 08  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Ago AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 09  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Set AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 10  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Out AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 11  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Nov AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 12  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ()) -1  and
             ab.cd_material = a.cd_material    and ab.Cd_Especif1 = d.Cd_Especif1 and 
             ab.cd_tp_operacao in  ('86000','5901')) as 'Dez AA',
	   (SELECT (SUM(pc.Quantidade) - SUM(pc.Qt_fabricada)) FROM PCORPROD pc (nolock) 
         WHERE pc.cd_material     = b.cd_material AND 
               pc.especif1     = b.especif1 AND 
               pc.situacao = 'L')                          AS 'Saldo OP',
       p.Estoque_segura as "Estoque Seguranca"
  FROM ESMATERI a (NOLOCK)
  LEFT JOIN DADOS d (NOLOCK) ON (a.cd_material = d.cd_material)
  LEFT JOIN ESES1 e (NOLOCK) ON (d.Cd_Especif1 = e.Cd_Especif1)
  LEFT JOIN ESDEMAND b (NOLOCK) ON (b.cd_material = a.cd_material and d.Cd_Especif1 = b.Especif1)
  LEFT JOIN ESSUBGRU i (NOLOCK) ON (i.Cd_grupo    = a.Cd_grupo AND a.Cd_sub_grupo = i.Cd_sub_grupo)
  LEFT JOIN ESGRUPO  j (NOLOCK) ON (j.Cd_grupo    = a.Cd_grupo)
  LEFT JOIN ESPARPLA p (NOLOCK) ON (a.cd_material = p.Cd_material and d.Cd_Especif1 = p.Especif1 and UPPER(p.Tipo) = 'P')
  WHERE a.Cd_grupo in ('50') AND
        a.Cd_sub_grupo != '50' AND 
        a.Tipo         = 'A' AND
        a.cd_material IN ('500400379', '500100203', '500400260', '500100215', '500100155', '500400380', '500400263', '500200064', '500100118', '500100174', '500100159', '500100183', '500600005', '500100173', '500100199', '500100157', '500900008', '500100175')
/*

 (SELECT ltrim(dbo.cg_fc_monta_descr_ident(':1',substring(i.cd_carac,1,CHARINDEX(';',i.Cd_Carac,2)),0,0,b.campo82,0,' '))
       FROM   ppident i(nolock)
       WHERE  i.identificador = a.Cd_Especif1
       AND i.Sequencial = 1)                            AS "Cor"*/