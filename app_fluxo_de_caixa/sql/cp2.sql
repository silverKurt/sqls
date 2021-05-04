SELECT
    case when replace(periodovencimento::TEXT, '2020-', extract(year from now()::date)::text||'-') ilike ('%-02-29') then (extract(year from now()::date)::text ||'-02-28')::date 
        else replace(periodovencimento::TEXT, '2020-', extract(year from now()::date)::text||'-')::DATE 
    end as "data_vencimento",
    --periodovencimento as "data_vencimento",
    1 AS "cod_lancamento",
    codloja as "cod_empresa",
    'EMPRESA - '||codloja as "empresa",
    replace(agrupadortipoconta, '_' , ' ') as "cod_categoria",
    replace(agrupadortipoconta, '_' , ' ') as "categoria",
    tipoconta as "cod_subcategoria",
    tipoconta as "subcategoria",
    contacaixa as "cod_conta_corrente",
    contacaixa as "conta_corrente",
    contacaixa as "tipo_conta",
    'SUL' as "regiao",
    'Grupo Fornecedor - Sul' as "grupo_fornec",
    rpad(substring(reverse(fornecedor)from 2 for 5), 10, 'XyxIhc') as "cod_cliente",
    rpad(substring(reverse(fornecedor)from 2 for 5), 10, 'XyxIhc')  as "cliente",
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
    (vlraberto + vlrquitado)*3 as "vlr_emissao",
    vlrquitado*3 as "vlr_pago",
    vlraberto*3  as "saldo",
    agrupadortipoconta as "tipo_cliente",
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
where codloja = 1
AND DATE_TRUNC('YEAR', periodovencimento) = '2020-01-01'