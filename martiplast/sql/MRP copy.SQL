SELECT
    NULL AS "cod_lancamento",
    1 AS "qtd_lancamento",
    codloja as "cod_empresa",
    'Loja - '||codloja as "empresa",
    replace(agrupadortipoconta, '_' , ' ') as "cod_categoria",
    replace(agrupadortipoconta, '_' , ' ') as "categoria",
    tipoconta as "cd_subcategoria",
    tipoconta as "subcategoria",
    contacaixa as "cod_conta_corrente",
    contacaixa as "conta_corrente",
    contacaixa as "tipo_conta",
    'SUL' as "regiao",
    'Grupo Fornecedor - Sul' as "grupo_fornec",
    rpad(substring(reverse(fornecedor)from 2 for 5), 10, 'XyxIhc') as "cod_clifor",
    rpad(substring(reverse(fornecedor)from 2 for 5), 10, 'XyxIhc') as "qtd_clifor",
    rpad(substring(reverse(fornecedor)from 2 for 5), 10, 'XyxIhc')  as "nome_reduzido",
    periodoentrada as "data_emissao",
    null as "fl_liquidado",
    null as "fl_vencido",
    coalesce(periodoquitacao, now()::date) - periodovencimento as "dias_vencido",
    CASE 
      WHEN  coalesce(periodoquitacao, now()::date) - periodovencimento  < 7 then 'Até 7 Dias'
      when  coalesce(periodoquitacao, now()::date) - periodovencimento  between 7 and 14 then 'Entre 7 e 14 Dias'
      when  coalesce(periodoquitacao, now()::date) - periodovencimento  between 14 and 21 then 'Entre 14 e 21 Dias'
      when  coalesce(periodoquitacao, now()::date) - periodovencimento  between 21 and 30 then 'Entre 21 e 30 Dias'
      else 'Mais que 30 Dias'
    END AS "faixa_atraso",
    periodovencimento as "data_vencimento",
    (vlraberto + vlrquitado)*3 as "vlr_emissao",
    vlrquitado*3 as "vlr_pago",
    vlraberto*3  as "saldo",
    agrupadortipoconta as "tipo_clifor",
    'P' as "pagar_receber",
    case
        when coalesce(periodoquitacao, now()::date) - periodovencimento > 0
        then 'VENCIDO'
        else 'OK'
    end as "situacao_vencimento",
    case
        when quitado = 'Sim' and vlraberto = 0 then 'BAIXADO'
        when quitado = 'Sim' and vlraberto > 0 then 'BAIXADO PARCIAL'
        else 'ABERTO'
    end as "situacao_baixa"
from cp_base
where periodoentrada >= now()::date - interval '1 year'
and codloja = 1

union all


SELECT
    NULL AS "cod_lancamento",
    1 AS "qtd_lancamento",
    cast(substring(loja from 6 for 2 )as int) as "cod_empresa",
    'Loja - '|| cast(substring(loja from 6 for 2 )as int) as "empresa",
    'VENDAS' as "cod_categoria",
    'VENDAS' as "categoria",
    operacao as "cd_subcategoria",
    operacao as "subcategoria",
    case when formapagto = 1 then 'CAIXA 1 LJ01'
         when formapagto = 8 then 'CAIXA RETAGUARDA LJ01'
         when formapagto = 55 then 'CAIXA BANCO BANRISUL LJ 01'
         when formapagto = 40 then 'CAIXA BANCO B. DO BRASIL LJ01'
         else 'CAIXA 3 LJ01'
    end as "cod_conta_corrente",
    case when formapagto = 1 then 'CAIXA 1 LJ01'
         when formapagto = 8 then 'CAIXA RETAGUARDA LJ01'
         when formapagto = 55 then 'CAIXA BANCO BANRISUL LJ 01'
         when formapagto = 40 then 'CAIXA BANCO B. DO BRASIL LJ01'
         else 'CAIXA 3 LJ01'
    end as "conta_corrente",
    case when formapagto in (1,8) then 'CONTA CORRENTE'
         else 'CONTA INVESTIMENTO'
    end as "tipo_conta",
    'SUL' as "regiao",
    'Grupo Clente - Sul' as "grupo_fornec",
    'Cliente - '||vendedor as "cod_clifor",
    'Cliente - '||vendedor as "qtd_clifor",
    'Cliente - '||vendedor as "nome_reduzido",
    dtabertura as "data_emissao",
    null as "fl_liquidado",
    null as "fl_vencido",
    diasatraso as "dias_vencido",
    CASE 
      WHEN diasatraso < 7 then 'Até 7 Dias'
      when diasatraso between 7 and 14 then 'Entre 7 e 14 Dias'
      when diasatraso between 14 and 21 then 'Entre 14 e 21 Dias'
      when diasatraso between 21 and 30 then 'Entre 21 e 30 Dias'
      else 'Mais que 30 Dias'
    END AS "faixa_atraso",
    dtvencimento as "data_vencimento",
    
    vlrtotal*.75 as "vlr_emissao",
    valorquitado*.75 as "vlr_quitado",
    vlrtotal*.75 - valorquitado as "saldo",
    'Cliente' as "tipo_clifor",
    'R' as "pagar_receber",
    CASE
         WHEN coalesce(dtquitacao, now()::date) > dtvencimento 
         THEN 'VENCIDO'
         ELSE 'OK'
    END AS "situacao_vencimento",
    CASE
          WHEN vlrtotal - valorquitado = 0
          THEN 'BAIXADO'
          WHEN vlrtotal - valorquitado <> 0 AND valorquitado <> 0
          THEN 'BAIXADO PARCIAL'
        ELSE 'ABERTO'
        END AS "situacao_baixa"
from cr_base
where dtabertura >= now()::date - interval '1 year'
and cast(substring(loja from 6 for 2 )as int) = 1