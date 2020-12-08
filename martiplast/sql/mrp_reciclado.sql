SELECT ltrim(rtrim(a.cd_material)) + ' - ' + a.descricao  AS 'Material',
         b.liberacao                                        AS 'Liberacao',
         ( CASE WHEN b.liberacao != '' THEN 'C/Liberação'
           else 'S/Liberação' end)                          AS 'Status Liberacao',
         b.tipo                                             AS 'Tipo Demanda',
         a.Cd_grupo       + ' - ' + j.descricao             AS 'Grupo Material',
         a.Cd_sub_grupo   + ' - ' + i.descricao             AS 'SubGrupo Material',
         b.dt_programada                                    AS 'Periodo',
         b.dt_programada                                    AS 'Periodo Filtro',
         b.qt_saldo                                         AS 'Qtde Demanda Liberada',
         (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK) 
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '100') AS 'Saldo CA 100',       
         (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '001') AS 'Saldo CA 001',
    (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '360') AS 'Saldo CA 360',

    (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material) AS 'TOTAL ESTOQUE',

    (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '701') AS 'Saldo CA 701',
    (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '200') AS 'Saldo CA 200',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '702') AS 'Saldo CA 702',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '703') AS 'Saldo CA 703',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '704') AS 'Saldo CA 704',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '705') AS 'Saldo CA 705',
    (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '706') AS 'Saldo CA 706', 

      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '707') AS 'Saldo CA 707',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '708') AS 'Saldo CA 708',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '709') AS 'Saldo CA 709',

      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '711') AS 'Saldo CA 711',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '715') AS 'Saldo CA 715',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '716') AS 'Saldo CA 716',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '717') AS 'Saldo CA 717',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '718') AS 'Saldo CA 718',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '719') AS 'Saldo CA 719',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '720') AS 'Saldo CA 720',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '714') AS 'Saldo CA 714',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '713') AS 'Saldo CA 713',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '712') AS 'Saldo CA 712',
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          WHERE d.cd_material = a.cd_material AND 
          d.cd_centro_armaz = '710') AS 'Saldo CA 710',
      
      (SELECT SUM(d.quantidade)
          FROM ESESTOQU d (NOLOCK)
          INNER JOIN ESCARMAZ car ON (d.cd_centro_armaz = car.Cd_centro_armaz)
          WHERE d.cd_material = a.cd_material AND 
          car.campo31 = 'true') AS 'Saldo CAs Planejamento',

      ( SELECT (SUM(pc.Quantidade)) 
        FROM COIORDEM pc (NOLOCK) 
        WHERE pc.cd_material = a.cd_material and pc.situacao in ('A','P') ) AS 'Saldo OC',
      
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento)   = 01  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Jan',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 02  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Fev',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 03  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Mar',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 04  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Abri',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 05  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Mai',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 06  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Jun',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 07  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Jul',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 08  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Ago',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 09  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Set',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 10  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Out',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 11  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Nov',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 12  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Dez',

       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento)   = 01  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Jan AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 02  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Fev AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 03  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Mar AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 04  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())-1   and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Abri AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 05  and
             DATEPART(YYYY, ab.Dt_movimento) = DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Mai AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 06  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Jun AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 07  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Jul AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 08  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Ago AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 09  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ()) -1 and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Set AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 10  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Out AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 11  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ())-1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Nov AA',
       ( SELECT  SUM(ab.Quantidade)
       FROM ESMOVIME ab (NOLOCK)
       WHERE DATEPART(mm, ab.Dt_movimento) = 12  and
             DATEPART(YYYY, ab.Dt_movimento) =  DATEPART(YYYY, GETDATE ()) -1  and
             ab.cd_material = a.cd_material    and 
             ab.cd_tp_operacao in  ('86000','5901', '5901A')) as 'Dez AA',

       p.Estoque_segura as "Estoque Seguranca"
  FROM ESMATERI a (NOLOCK)
  LEFT JOIN ESDEMAND b (NOLOCK) ON (b.cd_material = a.cd_material)
  LEFT JOIN ESSUBGRU i (NOLOCK) ON (i.Cd_grupo    = a.Cd_grupo AND a.Cd_sub_grupo = i.Cd_sub_grupo)
  LEFT JOIN ESGRUPO  j (NOLOCK) ON (j.Cd_grupo    = a.Cd_grupo)
  LEFT JOIN ESPARPLA p (NOLOCK) ON (a.cd_material = p.Cd_material and p.Tipo = 'p' and p.Regra = 1)
  WHERE a.Cd_grupo in ('01','02','05','10','12') AND
        a.Cd_sub_grupo = '50' AND 
        a.Tipo         = 'A'