--
-- Copyright (c) 2022 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
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

--Postgresql version 9+
--PostGIS version 3+
--PgHydro version 6.6

---------------------------------------------------------------------------------
--PgHydro Output Extension Version en_au 6.6 of 28/07/2022
---------------------------------------------------------------------------------

-------------------------------------
--CREATE SCHEMA, TABLES AND SEQUENCES
-------------------------------------

DROP SCHEMA IF EXISTS pgh_output_en_au CASCADE;

CREATE SCHEMA pgh_output_en_au;

----------------------
--CREATE OUTPUT TABLES
----------------------

-- Table: pgh_output_en_au.geoft_bho_drainage_line

DROP TABLE IF EXISTS pgh_output_en_au.geoft_bho_drainage_line;

CREATE TABLE IF NOT EXISTS pgh_output_en_au.geoft_bho_drainage_line
(
    drn_id integer,
    drp_id_src integer,
    drp_id_tgt integer,
    wtc_cd character varying,
    dra_cd character varying,
    drn_length numeric,
    drn_dt_sea numeric,
    wtc_dt_wtc numeric,
    dra_area numeric,
    upstr_area numeric,
    nm_generic character varying,
    nm_connect character varying,
    nm_specif character varying,
    nm_comp character varying,
    nm_orig character varying,
    wtc_cd_dwn character varying,
    drn_cd_dwn integer,
    wtc_dt_sea numeric,
    wtc_area numeric,
    wtc_cd_ord smallint,
    wtc_length numeric,
    dra_cd_lev smallint,
    wtc_cd_lev smallint,
    strahler integer,
    authority character varying,
    db_version text,
    drn_gm geometry(MultiLineString)
);

-- Table: pgh_output_en_au.geoft_bho_drainage_area

DROP TABLE IF EXISTS pgh_output_en_au.geoft_bho_drainage_area;

CREATE TABLE IF NOT EXISTS pgh_output_en_au.geoft_bho_drainage_area
(
    dra_id integer,
    drn_id integer,
    wtc_cd character varying,
    dra_cd character varying,
    dra_area numeric,
    wtc_cd_ord smallint,
    dra_cd_01 text,
    dra_cd_02 text,
    dra_cd_03 text,
    dra_cd_04 text,
    dra_cd_05 text,
    dra_cd_06 text,
    dra_cd_lev smallint,
    db_version text,
    dra_gm geometry(MultiPolygon)
);

-- Table: pgh_output_en_au.geoft_bho_drainage_point

DROP TABLE IF EXISTS pgh_output_en_au.geoft_bho_drainage_point;

CREATE TABLE IF NOT EXISTS pgh_output_en_au.geoft_bho_drainage_point
(
    drp_id integer,
    wtc_cd character varying,
    point_type text,
    db_version text,
    drp_gm geometry(Point)
);

-----------------------------------------
--UpdateExtension
-----------------------------------------

SELECT pg_catalog.pg_extension_config_dump('pgh_output_en_au.geoft_bho_drainage_line', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output_en_au.geoft_bho_drainage_area', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output_en_au.geoft_bho_drainage_point', '');


-----------------------------------------
--UpdateGeometrySRID
-----------------------------------------

SELECT pghydro.pghfn_UpdateGeometrySRID();

----------------------------------------------------
--FUNCTION pgh_output_en_au.pghfn_UpdateExportTables()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_output_en_au.pghfn_UpdateExportTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

--TABLE pgh_output_en_au.geoft_bho_drainage_line

TRUNCATE pgh_output_en_au.geoft_bho_drainage_line;

INSERT INTO pgh_output_en_au.geoft_bho_drainage_line
SELECT
drn.drn_pk as drn_id,
drn.drn_drp_pk_sourcenode as drp_id_src,
drn.drn_drp_pk_targetnode as drp_id_tgt,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
dra.dra_cd_pfafstetterbasin as dra_cd,
drn.drn_gm_length as drn_length,
drn.drn_nu_distancetosea as drn_dt_sea,
drn.drn_nu_distancetowatercourse as wtc_dt_wtc,
dra.dra_gm_area as dra_area,
drn.drn_nu_upstreamarea as upstr_area,
tng.tng_ds as nm_generic,
tcn.tcn_ds as nm_connect,
tns.tns_ds as nm_specif,
tnc.tnc_ds as nm_comp,
drn.drn_nm as nm_orig,
wtc.wtc_cd_pfafstetterwatercourse_downstream as wtc_cd_dwn,
drn.drn_drn_pk_downstreamdrainageline as drn_cd_dwn,
wtc.wtc_nu_distancetosea as wtc_dt_sea,
wtc.wtc_gm_area as wtc_area,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as wtc_cd_ord,
wtc.wtc_gm_length as wtc_length,
dra.dra_nu_pfafstetterbasincodelevel as dra_cd_lev,
wtc.wtc_nu_pfafstetterwatercoursecodelevel as wtc_cd_lev,
hin.hin_strahler as strahler,
tdm.tdm_ds as authority,
'BHO '||current_database()||' de '||CURRENT_DATE::text as db_version,
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

--TABLE pgh_output_en_au.geoft_bho_drainage_area;

TRUNCATE pgh_output_en_au.geoft_bho_drainage_area;

INSERT INTO pgh_output_en_au.geoft_bho_drainage_area
SELECT
dra.dra_pk as dra_id,
drn.drn_pk as drn_id,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
dra.dra_cd_pfafstetterbasin as dra_cd,
dra.dra_gm_area as dra_area,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as wtc_cd_ord,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 1) as dra_cd_01,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 2) as dra_cd_02,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 3) as dra_cd_03,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 4) as dra_cd_04,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 5) as dra_cd_05,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 6) as dra_cd_06,
dra.dra_nu_pfafstetterbasincodelevel as dra_cd_lev,
'BHO '||current_database()||' de '||CURRENT_DATE::text as db_version,
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
'BHO '||current_database()||' : '||CURRENT_DATE::text as dsversao,
dra.dra_gm
FROM pghydro.pghft_drainage_area dra
INNER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_dra_pk = dra.dra_pk
WHERE hin.hin_drn_pk is null;

--TABLE pgh_output_en_au.geoft_bho_drainage_point

TRUNCATE pgh_output_en_au.geoft_bho_drainage_point;

INSERT INTO pgh_output_en_au.geoft_bho_drainage_point
--watercourse starting point
SELECT
drp.drp_pk as drp_id,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
'Watercourse Starting Point'::text as point_type,
'BHO '||current_database()||' : '||CURRENT_DATE::text as db_version,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
UNION
--Shoreline starting point
SELECT
drp.drp_pk as drp_id,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
'Shoreline Starting Point'::text as point_type,
'BHO '||current_database()||' : '||CURRENT_DATE::text as db_version,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null
UNION
--watercourse ending point
SELECT
drp.drp_pk as drp_id,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
'Watercourse Ending Point'::text as point_type,
'BHO '||current_database()||' : '||CURRENT_DATE::text as db_version,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea > 0
UNION
--foz
SELECT
drp.drp_pk as drp_id,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
'Outlet'::text as point_type,
'BHO '||current_database()||' : '||CURRENT_DATE::text as db_version,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea = 0
UNION
--Shoreline ending point
SELECT
drp.drp_pk as drp_id,
wtc.wtc_cd_pfafstetterwatercourse as wtc_cd,
'Shoreline Ending Point'::text as point_type,
'BHO '||current_database()||' de '||CURRENT_DATE::text as db_version,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_output_en_au.pghfn_UpdateExportTables();