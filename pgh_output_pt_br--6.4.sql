--
-- Copyright (c) 2021 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
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
--PgHydro Output Extension Version pt_br 6.4 of 03/05/2021
---------------------------------------------------------------------------------

-------------------------------------
--CREATE SCHEMA, TABLES AND SEQUENCES
-------------------------------------

DROP SCHEMA IF EXISTS pgh_output_pt_br CASCADE;

CREATE SCHEMA pgh_output_pt_br;

----------------------
--CREATE OUTPUT TABLES
----------------------
DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bho_trecho_drenagem;

CREATE TABLE pgh_output_pt_br.geoft_bho_trecho_drenagem
(
  drn_pk integer,
  cotrecho integer,
  noorigem integer,
  nodestino integer,
  cocursodag character varying,
  cobacia character varying,
  nucomptrec numeric,
  nudistbact numeric,
  nudistcdag numeric,
  nuareacont numeric,
  nuareamont numeric,
  nogenerico character varying,
  noligacao character varying,
  noespecif character varying,
  noriocomp character varying,
  nooriginal character varying,
  cocdadesag character varying,
  nutrjus integer,
  nudistbacc numeric,
  nuareabacc numeric,
  nuordemcda smallint,
  nucompcda numeric,
  nunivotto smallint,
  nunivotcda smallint,
  nustrahler integer,
  dedominial character varying,
  dsversao text,
  drn_gm geometry(MultiLineString)
);

DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bho_area_drenagem;

CREATE TABLE pgh_output_pt_br.geoft_bho_area_drenagem
(
  dra_pk integer,
  idbacia integer,
  cotrecho integer,
  cocursodag character varying,
  cobacia character varying,
  nuareacont numeric,
  nuordemcda smallint,
  nunivotto1 text,
  nunivotto2 text,
  nunivotto3 text,
  nunivotto4 text,
  nunivotto5 text,
  nunivotto6 text,
  nunivotto smallint,
  dsversao text,
  dra_gm geometry(MultiPolygon)
);

DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bho_curso_dagua;

CREATE TABLE pgh_output_pt_br.geoft_bho_curso_dagua
(
  wtc_pk integer,
  idcda integer,
  cocursodag character varying,
  nudistbacc numeric,
  nucompcda numeric,
  nuareabacc numeric,
  cocdadesag character varying,
  nunivotcda smallint,
  nuordemcda smallint,
  dedominial character varying,
  dsversao text,
  wtc_gm geometry(MultiLineString)
);

DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bho_ponto_drenagem;

CREATE TABLE pgh_output_pt_br.geoft_bho_ponto_drenagem
(
  drp_pk integer,
  idponto integer,
  cocursodag character varying,
  deponto text,
  dsversao text,
  drp_gm geometry(Point,4291)
);

DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bho_linha_costa;

CREATE TABLE pgh_output_pt_br.geoft_bho_linha_costa
(
  colinhacosta integer,
  nooriginal character varying,
  sho_gm geometry(MultiLineString,4291)
);

-----------------------------------------
--UpdateExtension
-----------------------------------------

SELECT pg_catalog.pg_extension_config_dump('pgh_output_pt_br.geoft_bho_trecho_drenagem', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output_pt_br.geoft_bho_area_drenagem', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output_pt_br.geoft_bho_curso_dagua', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output_pt_br.geoft_bho_ponto_drenagem', '');
SELECT pg_catalog.pg_extension_config_dump('pgh_output_pt_br.geoft_bho_linha_costa', '');

-----------------------------------------
--UpdateGeometrySRID
-----------------------------------------

SELECT pghydro.pghfn_UpdateGeometrySRID();

----------------------------------------------------
--FUNCTION pgh_output_pt_br.pghfn_UpdateExportTables()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_output_pt_br.pghfn_UpdateExportTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

--TABLE pgh_output_pt_br.geoft_bho_trecho_drenagem

TRUNCATE pgh_output_pt_br.geoft_bho_trecho_drenagem;

INSERT INTO pgh_output_pt_br.geoft_bho_trecho_drenagem
SELECT
drn_pk,
drn.drn_pk as cotrecho,
drn.drn_drp_pk_sourcenode as noorigem,
drn.drn_drp_pk_targetnode as nodestino,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
dra.dra_cd_pfafstetterbasin as cobacia,
drn.drn_gm_length as nucomptrec,
drn.drn_nu_distancetosea as nudistbact,
drn.drn_nu_distancetowatercourse as nudistcdag,
dra.dra_gm_area as nuareacont,
drn.drn_nu_upstreamarea as nuareamont,
tng.tng_ds as nogenerico,
tcn.tcn_ds as noligacao,
tns.tns_ds as noespecif,
tnc.tnc_ds as noriocomp,
drn.drn_nm as nooriginal,
wtc.wtc_cd_pfafstetterwatercourse_downstream as cocdadesag,
drn.drn_drn_pk_downstreamdrainageline as nutrjus,
wtc.wtc_nu_distancetosea as nudistbacc,
wtc.wtc_gm_area as nuareabacc,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as nuordemcda,
wtc.wtc_gm_length as nucompcda,
dra.dra_nu_pfafstetterbasincodelevel as nunivotto,
wtc.wtc_nu_pfafstetterwatercoursecodelevel as nunivotcda,
hin.hin_strahler as nustrahler,
tdm.tdm_ds as dedominial,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
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

--TABLE pgh_output_pt_br.geoft_bho_area_drenagem

TRUNCATE pgh_output_pt_br.geoft_bho_area_drenagem;

INSERT INTO pgh_output_pt_br.geoft_bho_area_drenagem
SELECT
dra_pk,
dra.dra_pk as idbacia,
drn.drn_pk as cotrecho,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
dra.dra_cd_pfafstetterbasin as cobacia,
dra.dra_gm_area as nuareacont,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as nuordemcda,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 1) as nunivotto1,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 2) as nunivotto2,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 3) as nunivotto3,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 4) as nunivotto4,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 5) as nunivotto5,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 6) as nunivotto6,
dra.dra_nu_pfafstetterbasincodelevel as nunivotto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
dra_gm
FROM pghydro.pghft_drainage_line drn
INNER JOIN pghydro.pghft_drainage_area dra ON drn.drn_dra_pk = dra.dra_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
UNION
SELECT 
dra.dra_pk,
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
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
dra.dra_gm
FROM pghydro.pghft_drainage_area dra
INNER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_dra_pk = dra.dra_pk
WHERE hin.hin_drn_pk is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--TABLE pgh_output_pt_br.geoft_bho_curso_dagua

TRUNCATE pgh_output_pt_br.geoft_bho_curso_dagua;

INSERT INTO pgh_output_pt_br.geoft_bho_curso_dagua
SELECT
wtc.wtc_pk,
wtc.wtc_pk as idcda,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
wtc.wtc_nu_distancetosea as nudistbacc,
wtc.wtc_gm_length as nucompcda,
wtc.wtc_gm_area as nuareabacc,
wtc.wtc_cd_pfafstetterwatercourse_downstream as cocdadesag,
wtc.wtc_nu_pfafstetterwatercoursecodelevel as nunivotcda,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as nuordemcda,
tdm.tdm_ds as dedominial,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
wtc.wtc_gm
FROM pghydro.pghft_watercourse wtc
LEFT OUTER JOIN pghydro.pghtb_type_domain tdm ON tdm.tdm_pk = wtc.wtc_tdm_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

--TABLE pgh_output_pt_br.geoft_bho_ponto_drenagem

TRUNCATE pgh_output_pt_br.geoft_bho_ponto_drenagem;

INSERT INTO pgh_output_pt_br.geoft_bho_ponto_drenagem
--watercourse starting point
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Inicio do Curso Dagua'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
UNION
--Shoreline starting point
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Inicio da Linha de Costa'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
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
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Fim do Curso Dagua'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea > 0
UNION
--foz
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Foz Maritima'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
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
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Fim da Linha de Costa'::text as dsponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

--TABLE pgh_output_pt_br.geoft_bho_linha_costa

TRUNCATE pgh_output_pt_br.geoft_bho_linha_costa;

INSERT INTO pgh_output_pt_br.geoft_bho_linha_costa 
SELECT
sho.sho_pk AS colinhacosta,
sho.sho_nm AS nooriginal,
sho.sho_gm
FROM pghydro.pghft_shoreline sho;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_output_pt_br.pghfn_UpdateExportTables();