(--Devolução
SELECT 
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , codigo_meta as "Codigo Meta"
  , meta as "Meta"
  , realizado as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM devolucao
WHERE periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)

UNION ALL

(--Uso do APP
SELECT 
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , codigo_meta as "Codigo Meta"
  , meta as "Meta"
  , realizado as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM tempo_uso
WHERE periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)

UNION ALL

(--1. Pesquisa de Preço - PDVs - Atualizado Semana
SELECT
    p.periodo as "Periodo"
  , p.periodo as "Periodo Filtro"
  , p.promotor as "Promotor"
  , p.rota as "Rota"
  , p.regional as "Regional"
  , '1' as "Codigo Meta"
  , '1. Pesquisa de Preço' as "Meta"
  , COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||v.pdv_codigo::TEXT)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||p.pdv_codigo::TEXT)::DOUBLE PRECISION as "Realizado"
  , COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||v.pdv_codigo::TEXT)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||p.pdv_codigo::TEXT)::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM pdvs_previstos p
LEFT JOIN precos_pdvs_visitados v ON (p.periodo = v.periodo AND p.semana = v.semana  AND p.promotor = v.promotor AND p.rota = v.rota AND p.regional = v.regional AND p.pdv_codigo = v.pdv_codigo)
WHERE p.periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
GROUP BY 1,2,3,4,5)

UNION ALL

(--1. Pesquisa de Preço - Itens - Atualizado Semana
SELECT
    mix.periodo as "Periodo"
  , mix.periodo as "Periodo Filtro"
  , mix.promotor as "Promotor"
  , mix.rota as "Rota"
  , mix.regional as "Regional"
  , '1' as "Codigo Meta"
  , '1. Pesquisa de Preço' as "Meta"
  , COUNT(DISTINCT COALESCE(mix.semana::TEXT, '')||pre.itens_preco::TEXT)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(mix.semana::TEXT, '')||mix.itens_mix::TEXT)::DOUBLE PRECISION as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , COUNT(DISTINCT COALESCE(mix.semana::TEXT, '')||pre.itens_preco::TEXT)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(mix.semana::TEXT, '')||mix.itens_mix::TEXT)::DOUBLE PRECISION as "Realizado Item"
FROM preco_itensmix mix
LEFT JOIN preco_itenspreco pre ON (mix.periodo = pre.periodo AND mix.semana = pre.semana and mix.pdv_codigo = pre.pdv_codigo and mix.itens_mix = pre.itens_preco)
WHERE mix.periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
AND mix.periodo <= DATE_TRUNC('MONTH',now())::DATE
GROUP BY 1,2,3,4,5)

UNION ALL

--2. Controle de Estoque - PDVs - Atualizado Semana
(SELECT
    p.periodo as "Periodo"
  , p.periodo as "Periodo Filtro"
  , p.promotor as "Promotor"
  , p.rota as "Rota"
  , p.regional as "Regional"
  , '2' as "Codigo Meta"
  , '2. Controle de Estoque' as "Meta"
  , COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||v.pdv_codigo::TEXT)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||p.pdv_codigo::TEXT)::DOUBLE PRECISION as "Realizado"
  , COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||v.pdv_codigo::TEXT)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(p.semana::TEXT, '')||p.pdv_codigo::TEXT)::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM pdvs_previstos p
LEFT JOIN estoque_pdvs_visitados v ON (p.periodo = v.periodo  AND p.semana = v.semana AND p.promotor = v.promotor AND p.rota = v.rota AND p.regional = v.regional AND p.pdv_codigo = v.pdv_codigo)
WHERE p.periodo  >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
GROUP BY 1,2,3,4,5)

UNION ALL

(--2. Controle de Estoque - Itens - Atualizado semana
SELECT
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , '2' as "Codigo Meta"
  , '2. Controle de Estoque' as "Meta"
  , COUNT(DISTINCT pdv_ok)::DOUBLE PRECISION/COUNT(DISTINCT pdv_id)::DOUBLE PRECISION as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , COUNT(DISTINCT pdv_ok)::DOUBLE PRECISION/COUNT(DISTINCT pdv_id)::DOUBLE PRECISION as "Realizado Item"
FROM
(
SELECT
  fat.periodo
, fat.promotor
, fat.rota
, fat.pdv_previsto as pdv_id
, COUNT(DISTINCT fat.pdv_previsto) as qtd_pdv
, fat.regional
, COUNT(DISTINCT COALESCE(fat.semana::TEXT, '')||fat.pdv_previsto||fat.itens_fat) as qtd_itensfat
, COUNT(DISTINCT COALESCE(fat.semana::TEXT, '')||fat.pdv_previsto||est.itens_estoque) as qtd_itensest
, CASE WHEN (COUNT(DISTINCT COALESCE(fat.semana::TEXT, '')||fat.pdv_previsto||est.itens_estoque)::DOUBLE PRECISION/COUNT(DISTINCT COALESCE(fat.semana::TEXT, '')||fat.pdv_previsto||fat.itens_fat)::DOUBLE PRECISION) >= 0.75 THEN fat.pdv_previsto END as pdv_ok
/* FROM estoque_itensfat_tres fat */
FROM calcula_estoque_itensfat_tres_incremental fat
LEFT JOIN estoque_itensest est ON (fat.periodo = est.periodo AND fat.semana = est.semana and fat.pdv_previsto = est.pdv_id and fat.rota = est.rota and fat.itens_fat = est.itens_estoque)
WHERE fat.periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
AND fat.periodo <= DATE_TRUNC('MONTH',now())::DATE
GROUP BY 1,2,3,4,6
) x
GROUP BY 1,2,3,4,5)

UNION ALL

(--3. Conquistas
SELECT 
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , codigo_meta as "Codigo Meta"
  , meta as "Meta"
  , realizado as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM conquistas
WHERE periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)

UNION ALL

(--4. Planograma
SELECT 
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , codigo_meta as "Codigo Meta"
  , meta as "Meta"
  , realizado as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM planograma
WHERE periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)

UNION ALL

(--5. Produtividade
SELECT 
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , codigo_meta as "Codigo Meta"
  , meta as "Meta"
  , realizado as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM produtividade
WHERE periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL)

UNION ALL

(--6. Faturamento
SELECT
    periodo as "Periodo"
  , periodo as "Periodo Filtro"
  , promotor as "Promotor"
  , rota as "Rota"
  , regional as "Regional"
  , '6' as "Codigo Meta"
  , '6. Faturamento' as "Meta"
  , (((SUM(vlr_fat)+SUM(vlr_dev))/3::DOUBLE PRECISION)/((SUM(vlr_fat_3)+SUM(vlr_dev_3))/3::DOUBLE PRECISION))-1.0 as "Realizado"
  , NULL::DOUBLE PRECISION as "Realizado PDV"
  , NULL::DOUBLE PRECISION as "Realizado Item"
FROM faturamento
WHERE periodo >= DATE_TRUNC('MONTH', NOW()::DATE) - '1 MONTH'::INTERVAL
GROUP BY 1,2,3,4,5)