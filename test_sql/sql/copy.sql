--
-- COPY
--

-- CLASS POPULATION
--	(any resemblance to real life is purely coincidental)
--
COPY aggtest FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/agg.data';

COPY onek FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/onek.data';

COPY onek TO '/home/postgres/postgresql-9.5.10/src/test/regress/results/onek.data';

DELETE FROM onek;

COPY onek FROM '/home/postgres/postgresql-9.5.10/src/test/regress/results/onek.data';

COPY tenk1 FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/tenk.data';

COPY slow_emp4000 FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/rect.data';

COPY person FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/person.data';

COPY emp FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/emp.data';

COPY student FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/student.data';

COPY stud_emp FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/stud_emp.data';

COPY road FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/streets.data';

COPY real_city FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/real_city.data';

COPY hash_i4_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hash.data';

COPY hash_name_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hash.data';

COPY hash_txt_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hash.data';

COPY hash_f8_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hash.data';

COPY test_tsvector FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/tsearch.data';

COPY testjsonb FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/jsonb.data';

-- the data in this file has a lot of duplicates in the index key
-- fields, leading to long bucket chains and lots of table expansion.
-- this is therefore a stress test of the bucket overflow code (unlike
-- the data in hash.data, which has unique index keys).
--
-- COPY hash_ovfl_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hashovfl.data';

COPY bt_i4_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/desc.data';

COPY bt_name_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hash.data';

COPY bt_txt_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/desc.data';

COPY bt_f8_heap FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/hash.data';

COPY array_op_test FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/array.data';

COPY array_index_op_test FROM '/home/postgres/postgresql-9.5.10/src/test/regress/data/array.data';

-- analyze all the data we just loaded, to ensure plan consistency
-- in later tests

ANALYZE aggtest;
ANALYZE onek;
ANALYZE tenk1;
ANALYZE slow_emp4000;
ANALYZE person;
ANALYZE emp;
ANALYZE student;
ANALYZE stud_emp;
ANALYZE road;
ANALYZE real_city;
ANALYZE hash_i4_heap;
ANALYZE hash_name_heap;
ANALYZE hash_txt_heap;
ANALYZE hash_f8_heap;
ANALYZE test_tsvector;
ANALYZE bt_i4_heap;
ANALYZE bt_name_heap;
ANALYZE bt_txt_heap;
ANALYZE bt_f8_heap;
ANALYZE array_op_test;
ANALYZE array_index_op_test;

--- test copying in CSV mode with various styles
--- of embedded line ending characters

create temp table copytest (
	style	text,
	test 	text,
	filler	int);

insert into copytest values('DOS',E'abc\r\ndef',1);
insert into copytest values('Unix',E'abc\ndef',2);
insert into copytest values('Mac',E'abc\rdef',3);
insert into copytest values(E'esc\\ape',E'a\\r\\\r\\\n\\nb',4);

copy copytest to '/home/postgres/postgresql-9.5.10/src/test/regress/results/copytest.csv' csv;

create temp table copytest2 (like copytest);

copy copytest2 from '/home/postgres/postgresql-9.5.10/src/test/regress/results/copytest.csv' csv;

select * from copytest except select * from copytest2;

truncate copytest2;

--- same test but with an escape char different from quote char

copy copytest to '/home/postgres/postgresql-9.5.10/src/test/regress/results/copytest.csv' csv quote '''' escape E'\\';

copy copytest2 from '/home/postgres/postgresql-9.5.10/src/test/regress/results/copytest.csv' csv quote '''' escape E'\\';

select * from copytest except select * from copytest2;


-- test header line feature

create temp table copytest3 (
	c1 int,
	"col with , comma" text,
	"col with "" quote"  int);

copy copytest3 from stdin csv header;
this is just a line full of junk that would error out if parsed
1,a,1
2,b,2
\.

copy copytest3 to stdout csv header;
