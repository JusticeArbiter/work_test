--
-- CREATE_FUNCTION_2
--
CREATE FUNCTION hobbies(person)
   RETURNS setof hobbies_r
   AS 'select * from hobbies_r where person = $1.name'
   LANGUAGE SQL;


CREATE FUNCTION hobby_construct(text, text)
   RETURNS hobbies_r
   AS 'select $1 as name, $2 as hobby'
   LANGUAGE SQL;


CREATE FUNCTION hobby_construct_named(name text, hobby text)
   RETURNS hobbies_r
   AS 'select name, hobby'
   LANGUAGE SQL;


CREATE FUNCTION hobbies_by_name(hobbies_r.name%TYPE)
   RETURNS hobbies_r.person%TYPE
   AS 'select person from hobbies_r where name = $1'
   LANGUAGE SQL;


CREATE FUNCTION equipment(hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = $1.name'
   LANGUAGE SQL;


CREATE FUNCTION equipment_named(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where equipment_r.hobby = equipment_named.hobby.name'
   LANGUAGE SQL;

CREATE FUNCTION equipment_named_ambiguous_1a(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = equipment_named_ambiguous_1a.hobby.name'
   LANGUAGE SQL;

CREATE FUNCTION equipment_named_ambiguous_1b(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where equipment_r.hobby = hobby.name'
   LANGUAGE SQL;

CREATE FUNCTION equipment_named_ambiguous_1c(hobby hobbies_r)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = hobby.name'
   LANGUAGE SQL;

CREATE FUNCTION equipment_named_ambiguous_2a(hobby text)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where hobby = equipment_named_ambiguous_2a.hobby'
   LANGUAGE SQL;

CREATE FUNCTION equipment_named_ambiguous_2b(hobby text)
   RETURNS setof equipment_r
   AS 'select * from equipment_r where equipment_r.hobby = hobby'
   LANGUAGE SQL;


CREATE FUNCTION pt_in_widget(point, widget)
   RETURNS bool
   AS '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so'
   LANGUAGE C STRICT;

CREATE FUNCTION overpaid(emp)
   RETURNS bool
   AS '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so'
   LANGUAGE C STRICT;

CREATE FUNCTION boxarea(box)
   RETURNS float8
   AS '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so'
   LANGUAGE C STRICT;

CREATE FUNCTION interpt_pp(path, path)
   RETURNS point
   AS '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so'
   LANGUAGE C STRICT;

CREATE FUNCTION reverse_name(name)
   RETURNS name
   AS '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so'
   LANGUAGE C STRICT;

CREATE FUNCTION oldstyle_length(int4, text)
   RETURNS int4
   AS '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so'
   LANGUAGE C;  -- intentionally not strict

--
-- Function dynamic loading
--
LOAD '/home/postgres/postgresql-9.5.10/src/test/regress/regress.so';
