/*
 * Define the PostGIS extension and create a foreign table.
 */

CREATE EXTENSION postgis;
CREATE EXTENSION oracle_fdw;

-- TWO_TASK or ORACLE_HOME and ORACLE_SID must be set in the server's environment for this to work
CREATE SERVER oracle FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '', isolation_level 'read_committed', nchar 'true');
CREATE USER MAPPING FOR CURRENT_USER SERVER oracle OPTIONS (user 'SCOTT', password 'tiger');

-- reconnect so that oracle_fdw recognizes PostGIS
\c

SET client_min_messages = WARNING;
-- Table with a PostGIS geometry
CREATE FOREIGN TABLE gis (
   id integer OPTIONS (key 'on') NOT NULL,
   g  geometry
) SERVER oracle OPTIONS (table 'GIS');

/*
 * Empty the table and INSERT some data.
 */

-- empty table
DELETE FROM gis;
-- INSERT a couple of rows
INSERT INTO gis (id, g) VALUES
   (1, 'SRID=8307;POINT(16.4891 48.1754)'),
   (2, 'SRID=0;LINESTRING(1552410.48 6720732.7,1552408.69 6720731.97)'),
   (3, 'SRID=8307;POINT Z (1.5 2.6 3.7)'),
   (4, NULL),
   (5, 'SRID=8307;MULTIPOLYGON(((50 168,50 160,55 160,55 168,50 168),(51 167,54 167,54 161,51 161,51 162,52 163,51 164,51 165,51 166,51 167)),((52 166,52 162,53 162,53 166,52 166)))'),
   (6, 'SRID=8307;POLYGON((35 10,45 45,15 40,10 20,35 10),(20 30,35 35,30 20,20 30))'),
   (7, 'SRID=8307;MULTILINESTRING((10 10,20 20,10 40),(40 40,30 30,40 20,30 10))'),
   (8, 'SRID=8307;MULTIPOLYGON(((40 40,20 45,45 30,40 40)),((20 35,10 30,10 10,30 5,45 20,20 35),(30 20,20 15,20 25,30 20)))'),
   (9, 'SRID=8307;POINT M (12 13 14)'),
   (10, 'SRID=8307;POLYGON M ((0 0 0, 1 0 2, 1 1 4, 0 1 2, 0 0 0))');

/*
 * Test empty geometries.
 */

UPDATE gis SET g = 'POINT Z EMPTY' WHERE id = 1;
UPDATE gis SET g = 'MULTIPOLYGON(((10 10,20 10,20 20,10 20,10 10)),EMPTY)' WHERE id = 8;

/*
 * Test four-dimensional geometry.
 */

UPDATE gis SET g = 'POINT ZM (12 13 14 15)';

/*
 * Test SELECT and UPDATE ... RETURNING.
 */

-- simple SELECT
SELECT id, st_srid(g), st_astext(g) FROM gis ORDER BY id;
-- UPDATE with RETURNING clause
WITH upd (id, srid, wkt) AS
   (UPDATE gis SET g=g RETURNING id, st_srid(g), st_astext(g))
SELECT * FROM upd ORDER BY id;

-- clean up
DROP EXTENSION oracle_fdw CASCADE;
DROP EXTENSION postgis CASCADE;
