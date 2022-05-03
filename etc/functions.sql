
CREATE OR REPLACE FUNCTION user_get_animal_from_cage(int, text, int) RETURNS int AS $$ select db_animal from animal where db_cage=$1 and db_sex=(select db_code from codes where class='SEX' and ext_code=$2) offset 3 limit 1 ; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_last_birth_years(int) RETURNS float  AS $$ select distinct date_part('year', birth_dt) from animal where birth_dt notnull order by date_part('year', birth_dt) desc limit 2; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_body_wt_hens(text, int, text) RETURNS real AS $$ select body_wt from pt_cage z inner join event b on z.db_event=b.db_event where b.db_event_type=(select db_code from codes where class='EVENT' and ext_code=$1) and z.db_cage=$2 and z.hen_number=$3 $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_multiple_roosters_in_cages(text,text) RETURNS bigint AS $$  select count(*) from (select user_get_ext_code(db_breed,'s') as breed, count(db_cage), db_cage, user_get_full_db_unit(db_cage) from (select db_breed, user_get_ext_code(db_sex,'e'),db_cage from animal where date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1 and user_get_ext_code(db_sex,'e')='1') as a group by db_breed, db_cage having  count(db_cage)>1 ) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_multiple_cages(text,text) RETURNS text AS $$  select  y.clinien::text from (select z1.db_breed, count(z1.db_sire) as clinien from (select distinct z.db_breed, z.db_sire  from (select distinct a.db_breed, a.db_cage, b.db_sire from v_active_animals_and_cages a inner join animal b on a.db_animal=b.db_animal where date_part('year', a.birth_dt)::text=$2 and user_get_ext_code(a.db_breed,'s')=$1 and user_get_ext_code(a.db_sex,'e')='1') as z group by z.db_breed,  z.db_sire) z1 group by z1.db_breed) as y $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_open_cages(text,text) RETURNS bigint AS $$  select count(*) from (select distinct db_cage from v_active_animals_and_cages where date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_open_animals(text,text) RETURNS bigint AS $$  select count(*) from (select db_animal from entry_animal where date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_open_animals_without_cages(text,text) RETURNS bigint AS $$  select count(*) from entry_animal where db_cage isnull and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1 $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_body_weigh_20weeks(text,text) RETURNS bigint AS $$ select count(*) from (select b.db_breed, a.db_animal from pt_indiv a inner join animal b on a.db_animal=b.db_animal inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='weighingbody20weeks' and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_body_weigh_40weeks(text,text) RETURNS bigint AS $$ select count(*) from (select b.db_breed, a.db_animal from pt_indiv a inner join animal b on a.db_animal=b.db_animal inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='weighingbody40weeks' and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1) as yy $$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION user_get_check_body_weigh_20weeks_hens(text,text) RETURNS bigint AS $$ select count(*) from (select  a.db_cage from pt_cage a inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='weighingbody20weeks' and (select distinct date_part('year', birth_dt)::text from animal where db_cage=a.db_cage)=$2 and (select distinct user_get_ext_code(db_breed,'s') from animal where db_cage=a.db_cage)=$1) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_body_weigh_40weeks_hens(text,text) RETURNS bigint AS $$ select count(*) from (select  a.db_cage from pt_cage a inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='weighingbody40weeks' and (select distinct date_part('year', birth_dt)::text from animal where db_cage=a.db_cage)=$2 and (select distinct user_get_ext_code(db_breed,'s') from animal where db_cage=a.db_cage)=$1) as yy $$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION user_get_check_eggs_weigh_33weeks(text,text) RETURNS bigint AS $$ select count(*) from (select distinct b.db_breed, a.db_cage from eggs_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='weighingeggs33weeks' and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_eggs_weigh_53weeks(text,text) RETURNS bigint AS $$ select count(*) from (select distinct b.db_breed, a.db_cage from eggs_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='weighingeggs53weeks' and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_eggs_collected(text,text) RETURNS bigint AS $$ select count(*) from ( select distinct b.db_breed, a.db_cage from hatch_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='eggs_for_hatching' and collected_eggs notnull and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1 ) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_eggs_incubated(text,text) RETURNS bigint AS $$ select count(*) from ( select distinct b.db_breed, a.db_cage from hatch_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='eggs_for_hatching' and collected_eggs notnull and incubated_eggs notnull  and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1 ) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_check_eggs_hatched(text,text) RETURNS bigint AS $$ select count(*) from ( select distinct b.db_breed, a.db_cage from hatch_cage a inner join animal b on a.db_cage=b.db_cage inner join event c on a.db_event=c.db_event where user_get_ext_code(db_event_type,'e')='eggs_for_hatching' and collected_eggs notnull and incubated_eggs notnull  and hatched_eggs notnull  and date_part('year', birth_dt)::text=$2 and user_get_ext_code(db_breed,'s')=$1 ) as yy $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_old_db_cages(text,text) RETURNS integer AS $$ select  distinct a.db_cage from animal a inner join unit b on a.db_cage=b.db_unit where date_part('year', birth_dt)::text=$2 and ext_id::text=$1 $$ LANGUAGE SQL;

CREATE view v_animals_and_cages as  SELECT a.db_animal,
    a.db_sire,
    a.db_dam,
    a.db_sex,
    a.db_breed,
    a.db_selection,
    a.birth_dt,
    a.la_rep_dt,
    a.la_rep,
    a.last_change_dt,
    a.last_change_user,
    a.dirty,
    a.synch,
    a.chk_lvl,
    a.guid,
    a.owner,
    a.version,
    a.db_cage,
    a.line,
    a.exit_dt,
    a.db_exit,
    b.ext_unit,
    b.ext_id,
    b.opening_dt
   FROM animal a
     JOIN unit b ON a.db_cage = b.db_unit;
