--
-- Copyright (c) 2020 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

--REQUIREMENTS

--Postgresql version 9.1+
--PostGIS version 2.0+
--PgHydro version 6.4

---------------------------------------------------------------------------------
--PgHydro Output Extension Version 6.4 of 13/02/2020
---------------------------------------------------------------------------------

-------------------------------------
--CREATE SCHEMA, TABLES AND SEQUENCES
-------------------------------------

DROP SCHEMA IF EXISTS pgh_output CASCADE;

CREATE SCHEMA pgh_output;

----------------------
--CREATE OUTPUT TABLES
----------------------
DROP TABLE IF EXISTS pgh_output.geoft_bho_drainage_line;

CREATE TABLE pgh_output.geoft_bho_drainage_line
(
  v001 integer,
  v002 integer,
  v003 integer,
  v004 character varying,
  v005 character varying,
  v006 numeric,
  v007 numeric,
  v008 numeric,
  v009 numeric,
  v010 numeric,
  v011 character varying,
  v012 character varying,
  v013 character varying,
  v014 character varying,
  v015 character varying,
  v016 character varying,
  v017 integer,
  v018 numeric,
  v019 numeric,
  v020 smallint,
  v021 numeric,
  v022 smallint,
  v023 smallint,
  v024 integer,
  v025 character varying,
  v026 text,
  v027 geometry(MultiLineString)
);

DROP TABLE IF EXISTS pgh_output.geoft_bho_drainage_area;

CREATE TABLE pgh_output.geoft_bho_drainage_area
(
  v001 integer,
  v002 integer,
  v003 character varying,
  v004 character varying,
  v005 numeric,
  v006 smallint,
  v007 char(1),
  v008 char(2),
  v009 char(3),
  v010 char(4),
  v011 char(5),
  v012 char(6),
  v013 smallint,
  v014 text,
  v015 geometry(MultiPolygon)
);

DROP TABLE IF EXISTS pgh_output.geoft_bho_watercourse;

CREATE TABLE pgh_output.geoft_bho_watercourse
(
  v001 integer,
  v002 character varying,
  v003 numeric,
  v004 numeric,
  v005 numeric,
  v006 character varying,
  v007 smallint,
  v008 smallint,
  v009 character varying,
  v010 text,
  v011 geometry(MultiLineString)
);

DROP TABLE IF EXISTS pgh_output.geoft_bho_drainage_point;

CREATE TABLE pgh_output.geoft_bho_drainage_point
(
  v001 integer,
  v002 character varying,
  v003 text,
  v004 text,
  v005 geometry(Point,4291)
);

DROP TABLE IF EXISTS pgh_output.geoft_bho_shoreline;

CREATE TABLE pgh_output.geoft_bho_shoreline
(
  v001 integer,
  v002 character varying,
  v003 geometry(MultiLineString,4291)
);

-----------------------------------------
--UpdateExtension
-----------------------------------------

SELECT pg_catalog.pg_extension_config_dump('pgh_output.geoft_bho_drainage_line', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output.geoft_bho_drainage_area', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output.geoft_bho_watercourse', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output.geoft_bho_drainage_point', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output.geoft_bho_shoreline', '');

-----------------------------------------
--UpdateGeometrySRID
-----------------------------------------

SELECT pghydro.pghfn_UpdateGeometrySRID();

----------------------------------------------------
--FUNCTION pgh_output.pghfn_UpdateExportTables()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_output.pghfn_UpdateExportTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

--TABLE pgh_output.geoft_bho_drainage_line

TRUNCATE pgh_output.geoft_bho_drainage_line;

INSERT INTO pgh_output.geoft_bho_drainage_line
SELECT
drn.drn_pk,
drn.drn_drp_pk_sourcenode,
drn.drn_drp_pk_targetnode,
wtc.wtc_cd_pfafstetterwatercourse,
dra.dra_cd_pfafstetterbasin,
drn.drn_gm_length,
drn.drn_nu_distancetosea,
drn.drn_nu_distancetowatercourse,
dra.dra_gm_area,
drn.drn_nu_upstreamarea,
tng.tng_ds,
tcn.tcn_ds,
tns.tns_ds,
tnc.tnc_ds,
drn.drn_nm,
wtc.wtc_cd_pfafstetterwatercourse_downstream,
drn.drn_drn_pk_downstreamdrainageline,
wtc.wtc_nu_distancetosea,
wtc.wtc_gm_area,
wtc.wtc_nu_pfafstetterwatercoursecodeorder,
wtc.wtc_gm_length,
dra.dra_nu_pfafstetterbasincodelevel,
wtc.wtc_nu_pfafstetterwatercoursecodelevel,
hin.hin_strahler,
tdm.tdm_ds,
'BHO '||current_database()||' '||CURRENT_DATE::text,
drn_gm
FROM pghydro.pghft_drainage_line drn
INNER JOIN pghydro.pghft_drainage_area dra ON drn.drn_dra_pk = dra.dra_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
FULL OUTER JOIN pghydro.pghtb_type_name_complete tnc ON drn.drn_tnc_pk = tnc.tnc_pk
FULL OUTER JOIN pghydro.pghtb_type_name_generic tng ON tnc.tnc_tng_pk = tng.tng_pk
FULL OUTER JOIN pghydro.pghtb_type_name_connection tcn ON tnc.tnc_tcn_pk = tcn.tcn_pk
FULL OUTER JOIN pghydro.pghtb_type_name_specific tns ON tnc.tnc_tns_pk = tns.tns_pk
LEFT OUTER JOIN pghydro.pghtb_type_domain tdm ON tdm.tdm_pk = drn.drn_tdm_pk
FULL OUTER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_drn_pk = drn.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

--TABLE pgh_output.geoft_bho_drainage_area

TRUNCATE pgh_output.geoft_bho_drainage_area;

INSERT INTO pgh_output.geoft_bho_drainage_area
SELECT
dra.dra_pk,
drn.drn_pk,
wtc.wtc_cd_pfafstetterwatercourse,
dra.dra_cd_pfafstetterbasin,
dra.dra_gm_area,
wtc.wtc_nu_pfafstetterwatercoursecodeorder,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 1),
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 2),
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 3),
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 4),
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 5),
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 6),
dra.dra_nu_pfafstetterbasincodelevel,
'BHO '||current_database()||' '||CURRENT_DATE::text,
dra_gm
FROM pghydro.pghft_drainage_line drn
INNER JOIN pghydro.pghft_drainage_area dra ON drn.drn_dra_pk = dra.dra_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
UNION
SELECT 
dra.dra_pk,
null,
null,
'0',
dra.dra_gm_area,
null,
'0',
'0',
'0',
'0',
'0',
'0',
'0',
'BHO '||current_database()||' '||CURRENT_DATE::text as dsversao,
dra.dra_gm
FROM pghydro.pghft_drainage_area dra
INNER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_dra_pk = dra.dra_pk
WHERE hin.hin_drn_pk is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--TABLE pgh_output.geoft_bho_watercourse

TRUNCATE pgh_output.geoft_bho_watercourse;

INSERT INTO pgh_output.geoft_bho_watercourse
SELECT
wtc.wtc_pk,
wtc.wtc_cd_pfafstetterwatercourse,
wtc.wtc_nu_distancetosea,
wtc.wtc_gm_length,
wtc.wtc_gm_area,
wtc.wtc_cd_pfafstetterwatercourse_downstream,
wtc.wtc_nu_pfafstetterwatercoursecodelevel,
wtc.wtc_nu_pfafstetterwatercoursecodeorder,
tdm.tdm_ds,
'BHO '||current_database()||' '||CURRENT_DATE::text,
wtc.wtc_gm
FROM pghydro.pghft_watercourse wtc
LEFT OUTER JOIN pghydro.pghtb_type_domain tdm ON tdm.tdm_pk = wtc.wtc_tdm_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

--TABLE pgh_output.geoft_bho_drainage_point

TRUNCATE pgh_output.geoft_bho_drainage_point;

INSERT INTO pgh_output.geoft_bho_drainage_point
--watercourse starting point
SELECT
drp.drp_pk,
wtc.wtc_cd_pfafstetterwatercourse,
'Watercourse Starting Point'::text,
'BHO '||current_database()||' '||CURRENT_DATE::text,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
UNION
--Shoreline starting point
SELECT
drp.drp_pk,
wtc.wtc_cd_pfafstetterwatercourse,
'Shoreline Starting Point'::text,
'BHO '||current_database()||' '||CURRENT_DATE::text,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null
UNION
--watercourse ending point
SELECT
drp.drp_pk,
wtc.wtc_cd_pfafstetterwatercourse,
'Watercourse Ending Point'::text,
'BHO '||current_database()||' '||CURRENT_DATE::text,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea > 0
UNION
--outlet
SELECT
drp.drp_pk,
wtc.wtc_cd_pfafstetterwatercourse,
'Outlet'::text,
'BHO '||current_database()||' '||CURRENT_DATE::text,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea = 0
UNION
--Shoreline ending point
SELECT
drp.drp_pk,
wtc.wtc_cd_pfafstetterwatercourse,
'Shoreline Ending Point'::text,
'BHO '||current_database()||' '||CURRENT_DATE::text,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

--TABLE pgh_output.geoft_bho_shoreline

TRUNCATE pgh_output.geoft_bho_shoreline;

INSERT INTO pgh_output.geoft_bho_shoreline 
SELECT
sho.sho_pk,
sho.sho_nm,
sho.sho_gm
FROM pghydro.pghft_shoreline sho;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_output.pghfn_UpdateExportTables();