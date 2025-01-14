SET client_min_messages = WARNING;

CREATE EXTENSION oracle_fdw;

-- TWO_TASK or ORACLE_HOME and ORACLE_SID must be set in the server's environment for this to work
CREATE SERVER oracle FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '', isolation_level 'read_committed', nchar 'true');

CREATE USER MAPPING FOR CURRENT_USER SERVER oracle OPTIONS (user 'SCOTT', password 'tiger');

-- create the foreign tables
CREATE FOREIGN TABLE typetest1 (
   id  integer OPTIONS (key 'yes') NOT NULL,
   q   double precision,
   c   character(10),
   nc  character(10),
   vc  character varying(10),
   nvc character varying(10),
   lc  text,
   r   bytea,
   u   uuid,
   lb  bytea,
   lr  bytea,
   b   boolean,
   num numeric(7,5),
   fl  float,
   db  double precision,
   d   date,
   ts  timestamp with time zone,
   ids interval,
   iym interval
) SERVER oracle OPTIONS (table 'TYPETEST1');
ALTER FOREIGN TABLE typetest1 DROP q;

CREATE SCHEMA import;

IMPORT FOREIGN SCHEMA "SCOTT" LIMIT TO ("typetest1") FROM SERVER oracle INTO import OPTIONS (case 'lower');

SELECT t.relname, fs.srvname, ft.ftoptions
FROM pg_foreign_table ft
     JOIN pg_class t ON ft.ftrelid = t.oid
     JOIN pg_foreign_server fs ON ft.ftserver = fs.oid
WHERE relnamespace = 'import'::regnamespace;

SELECT attname, atttypid::regtype, attfdwoptions
FROM pg_attribute
WHERE attrelid = 'typetest1'::regclass
  AND attnum > 0
  AND NOT attisdropped
ORDER BY attnum;

-- clean up
DROP EXTENSION oracle_fdw CASCADE;
