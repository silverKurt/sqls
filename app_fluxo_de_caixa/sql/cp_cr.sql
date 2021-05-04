WITH dados_pagar AS (
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
    rpad(substring(reverse(fornecedor)from 2 for 5), 10, 'XyxIhc') as "cod_clifor",
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
    (vlraberto + vlrquitado)*3 as "vlr_emissao",
    vlrquitado*3 as "vlr_pago",
    vlraberto*3  as "saldo",
    agrupadortipoconta as "tipo_clifor",
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

), periodos_contas AS (
select *, now()::date + ((RANK () OVER ( 
		ORDER BY periodo 
	)::INT)-1) periodo_tratado  from (
SELECT DISTINCT
  CAST("data_vencimento" AS DATE) AS "periodo"
FROM dados_pagar
where "data_vencimento"::Date >= '2020-06-15' AND "data_vencimento"::Date <= '2020-07-15'
) Y
)
SELECT 
    d."cod_lancamento",
    d."qtd_lancamento",
    d."cod_empresa",
    d."empresa",
    d."cod_categoria",
    d."categoria",
    d."cd_subcategoria",
    d."subcategoria",
    d."cod_conta_corrente",
    d."conta_corrente",
    d."tipo_conta",
    d."regiao",
    d."grupo_fornec",
    d."cod_clifor",
    d."qtd_clifor",
    d."nome_reduzido",
    d."data_emissao",
    d."fl_liquidado",
    d."fl_vencido",
    --periodoquitacao, 
    now()::date - pc."periodo_tratado"::date as "dias_vencido",
    CASE 
      WHEN (now()::date - pc."periodo_tratado"::date) *-1  < 7 then 'Até 7 Dias'
      when (now()::date - pc."periodo_tratado"::date) *-1 between 7 and 14 then 'Entre 7 e 14 Dias'
      when (now()::date - pc."periodo_tratado"::date) *-1 between 14 and 21 then 'Entre 14 e 21 Dias'
      when (now()::date - pc."periodo_tratado"::date) *-1 between 21 and 30 then 'Entre 21 e 30 Dias'
      else 'Mais que 30 Dias'
    END AS "faixa_atraso",
    
    pc."periodo_tratado" as "data_vencimento",
    
    d."vlr_emissao",
    d."vlr_pago",
    d."saldo",
    d."tipo_clifor",
    d."pagar_receber",
    case
        when (now()::date - pc."periodo_tratado"::date) > 0
        then 'VENCIDO'
        else 'OK'
    end as "situacao_vencimento",

    d."situacao_baixa"
FROM dados_pagar d
INNER JOIN periodos_contas pc ON (d."data_vencimento" = pc."periodo")

UNION ALL 

SELECT 
    d."cod_lancamento",
    d."qtd_lancamento",
    d."cod_empresa",
    d."empresa",
    d."cod_categoria",
    d."categoria",
    d."cd_subcategoria",
    d."subcategoria",
    d."cod_conta_corrente",
    d."conta_corrente",
    d."tipo_conta",
    d."regiao",
    d."grupo_fornec",
    d."cod_clifor",
    d."qtd_clifor",
    d."nome_reduzido",
    d."data_emissao",
    d."fl_liquidado",
    d."fl_vencido",
    --periodoquitacao, 
    d."dias_vencido",
    d."faixa_atraso",
    
    d."data_vencimento",
    
    d."vlr_emissao",
    d."vlr_pago",
    d."saldo",
    d."tipo_clifor",
    d."pagar_receber",
    d."situacao_vencimento",
    d."situacao_baixa"
FROM dados_pagar d
WHERE "data_vencimento"::Date < now()::date

case when replace(data_fatura, '2020-', extract(year from now()::date - '2 year'::interval)::text||'-') ilike ('%-02-29') then (extract(year from now()::date - '2 year'::interval)::text ||'-02-28')::date 
     else replace(data_fatura, '2020-', extract(year from now()::date - '2 year'::interval)::text||'-')::DATE 
end as data_fatura