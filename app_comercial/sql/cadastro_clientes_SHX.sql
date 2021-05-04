select 
	cadacodi as "cod_cliente"
    , cadacada as "data_cadastro"
    , cadanome as "cliente"
    , NULL::TEXT AS "cidade"
    , NULL::TEXT AS "estado"
    , NULL::TEXT AS "pais"
    , NULL::TEXT AS "bairro"
    , NULL::TEXT AS "endereco"
    , NULL::TEXT AS "segmento_cliente"
    , NULL::TEXT AS "email"
    , NULL::TEXT AS "telefone"
    , NULL::TEXT AS "cod_representante"
    , NULL::TEXT AS "regiao"
    , NULL::TEXT AS "cnpj_cliente"
    , NULL::TEXT AS "status_cliente"
    , cadabloq as "data_inativacao"
from arqcada
WHERE cadatipo = 'CLIE'