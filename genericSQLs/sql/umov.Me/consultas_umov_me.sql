/*Verificar campos que não tem identificador alternativo*/
select af.* from activity a
inner join activitysection acs on (a.act_id = acs.act_id)
inner join activityfield af on (acs.acs_id = af.acs_id)
where a.act_id = '286351'
/*Filtra o ID da atividade que quer consultar*/
