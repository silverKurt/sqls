SELECT
    case when replace(dtvencimento::TEXT, '2020-', extract(year from now()::date)::text||'-') ilike ('%-02-29') then (extract(year from now()::date)::text ||'-02-28')::date 
        else replace(dtvencimento::TEXT, '2020-', extract(year from now()::date)::text||'-')::DATE 
    end as "data_vencimento",
    --dtvencimento as "data_vencimento",
    1 AS "cod_lancamento",
    cast(substring(loja from 6 for 2 )as int) as "cod_empresa",
    'Loja - '|| cast(substring(loja from 6 for 2 )as int) as "empresa",
    'VENDAS' as "cod_categoria",
    'VENDAS' as "categoria",
    operacao as "cod_subcategoria",
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
    'Cliente - '||vendedor as "cod_cliente",
    'Cliente - '||vendedor as "cliente",
    dtabertura as "data_emissao",
    null as "fl_liquidado",
    null as "fl_vencido",
    --dtquitacao as periodoquitacao,
    diasatraso as "dias_vencido",
    CASE 
      WHEN diasatraso < 7 then 'Até 7 Dias'
      when diasatraso between 7 and 14 then 'Entre 7 e 14 Dias'
      when diasatraso between 14 and 21 then 'Entre 14 e 21 Dias'
      when diasatraso between 21 and 30 then 'Entre 21 e 30 Dias'
      else 'Mais que 30 Dias'
    END AS "faixa_atraso",
    
    vlrtotal*.75 as "vlr_emissao",
    valorquitado*.75 as "vlr_pago",
    vlrtotal*.75 - valorquitado as "saldo",
    'Cliente' as "tipo_cliente",
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
where cast(substring(loja from 6 for 2 )as int) = 1
AND date_trunc('YEAR', dtvencimento) = '2020-01-01'

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

