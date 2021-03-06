-- create a tablespace using WITH clause
CREATE TABLESPACE testspacewith LOCATION '/home/postgres/postgresql-9.5.10/src/test/regress/testtablespace' WITH (some_nonexistent_parameter = true); -- fail
CREATE TABLESPACE testspacewith LOCATION '/home/postgres/postgresql-9.5.10/src/test/regress/testtablespace' WITH (random_page_cost = 3.0); -- ok

-- check to see the parameter was used
SELECT spcoptions FROM pg_tablespace WHERE spcname = 'testspacewith';

-- drop the tablespace so we can re-use the location
DROP TABLESPACE testspacewith;

-- create a tablespace we can use
CREATE TABLESPACE testspace LOCATION '/home/postgres/postgresql-9.5.10/src/test/regress/testtablespace';

-- try setting and resetting some properties for the new tablespace
ALTER TABLESPACE testspace SET (random_page_cost = 1.0);
ALTER TABLESPACE testspace SET (some_nonexistent_parameter = true);  -- fail
ALTER TABLESPACE testspace RESET (random_page_cost = 2.0); -- fail
ALTER TABLESPACE testspace RESET (random_page_cost, seq_page_cost); -- ok

-- create a schema we can use
CREATE SCHEMA testschema;

-- try a table
CREATE TABLE testschema.foo (i int) TABLESPACE testspace;
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'foo';

INSERT INTO testschema.foo VALUES(1);
INSERT INTO testschema.foo VALUES(2);

-- tables from dynamic sources
CREATE TABLE testschema.asselect TABLESPACE testspace AS SELECT 1;
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'asselect';

PREPARE selectsource(int) AS SELECT $1;
CREATE TABLE testschema.asexecute TABLESPACE testspace
    AS EXECUTE selectsource(2);
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'asexecute';

-- index
CREATE INDEX foo_idx on testschema.foo(i) TABLESPACE testspace;
SELECT relname, spcname FROM pg_catalog.pg_tablespace t, pg_catalog.pg_class c
    where c.reltablespace = t.oid AND c.relname = 'foo_idx';

-- check that default_tablespace doesn't affect ALTER TABLE index rebuilds
CREATE TABLE testschema.test_default_tab(id bigint) TABLESPACE testspace;
INSERT INTO testschema.test_default_tab VALUES (1);
CREATE INDEX test_index1 on testschema.test_default_tab (id);
CREATE INDEX test_index2 on testschema.test_default_tab (id) TABLESPACE testspace;
\d testschema.test_index1
\d testschema.test_index2
-- use a custom tablespace for default_tablespace
SET default_tablespace TO testspace;
-- tablespace should not change if no rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE bigint;
\d testschema.test_index1
\d testschema.test_index2
SELECT * FROM testschema.test_default_tab;
-- tablespace should not change even if there is an index rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE int;
\d testschema.test_index1
\d testschema.test_index2
SELECT * FROM testschema.test_default_tab;
-- now use the default tablespace for default_tablespace
SET default_tablespace TO '';
-- tablespace should not change if no rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE int;
\d testschema.test_index1
\d testschema.test_index2
-- tablespace should not change even if there is an index rewrite
ALTER TABLE testschema.test_default_tab ALTER id TYPE bigint;
\d testschema.test_index1
\d testschema.test_index2
DROP TABLE testschema.test_default_tab;

-- let's try moving a table from one place to another
CREATE TABLE testschema.atable AS VALUES (1), (2);
CREATE UNIQUE INDEX anindex ON testschema.atable(column1);

ALTER TABLE testschema.atable SET TABLESPACE testspace;
ALTER INDEX testschema.anindex SET TABLESPACE testspace;

INSERT INTO testschema.atable VALUES(3);	-- ok
INSERT INTO testschema.atable VALUES(1);	-- fail (checks index)
SELECT COUNT(*) FROM testschema.atable;		-- checks heap

-- Will fail with bad path
CREATE TABLESPACE badspace LOCATION '/no/such/location';

-- No such tablespace
CREATE TABLE bar (i int) TABLESPACE nosuchspace;

-- Fail, not empty
DROP TABLESPACE testspace;

CREATE ROLE tablespace_testuser1 login;
CREATE ROLE tablespace_testuser2 login;
GRANT USAGE ON SCHEMA testschema TO tablespace_testuser2;

ALTER TABLESPACE testspace OWNER TO tablespace_testuser1;

CREATE TABLE testschema.tablespace_acl (c int);
-- new owner lacks permission to create this index from scratch
CREATE INDEX k ON testschema.tablespace_acl (c) TABLESPACE testspace;
ALTER TABLE testschema.tablespace_acl OWNER TO tablespace_testuser2;

SET SESSION ROLE tablespace_testuser2;
CREATE TABLE tablespace_table (i int) TABLESPACE testspace; -- fail
ALTER TABLE testschema.tablespace_acl ALTER c TYPE bigint;
RESET ROLE;

ALTER TABLESPACE testspace RENAME TO testspace_renamed;

ALTER TABLE ALL IN TABLESPACE testspace_renamed SET TABLESPACE pg_default;
ALTER INDEX ALL IN TABLESPACE testspace_renamed SET TABLESPACE pg_default;

-- Should show notice that nothing was done
ALTER TABLE ALL IN TABLESPACE testspace_renamed SET TABLESPACE pg_default;

-- Should succeed
DROP TABLESPACE testspace_renamed;

DROP SCHEMA testschema CASCADE;

DROP ROLE tablespace_testuser1;
DROP ROLE tablespace_testuser2;
