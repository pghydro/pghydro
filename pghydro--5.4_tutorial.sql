--
-- Copyright (c) 2015 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General pghydro License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General pghydro License for more details.
--
-- You should have received a copy of the GNU General pghydro License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
--
--PosgreSQL: postgresql-9.3.5-3-windows-x64.exe
--postgis-bundle-pg93x64-setup-2.1.4-1.exe
---------------------------------------------------------------------------------
--PgHYDRO Tools version 5.4 of 19/12/2016
---------------------------------------------------------------------------------
--------
--BEGIN
--------
--------------------------
--CONVERT SHAPEFILE TO SQL
--------------------------
--Download and install postgresql-9.3.5-3-windows-x64.exe
--Download and install postgis-bundle-pg93x64-setup-2.1.4-1.exe
--------------------------
--CONVERT SHAPEFILE TO SQL
--------------------------
--THE USER CONVERT THE DRAINAGE SHAPEFILE 'input_drainage_line.shp' TO input_drainage_line.sql SQL USING THE SRID '4291' AND THE 'latin1' CHARACTER ENCODING
D:\Local>shp2pgsql -s 4291 -g the_geom -W "latin1" input_drainage_line.shp input_drainage_line > input_drainage_line.sql
--THE USER CONVERT DRAINAGE AREA SHAPEFILE 'input_drainage_area.shp' TO input_drainage_area.sql SQL USING THE SRID '4291' AND THE 'latin1' CHARACTER ENCODING
D:\Local>shp2pgsql -s 4291 -g the_geom -W "latin1" input_drainage_area.shp input_drainage_area > input_drainage_area.sql
--nome -> column with the 'name' of the drainage of the input_drainage_line.shp
------------------------------------
--CREATE THE PGHYDRO DATABASE SCHEMA 
------------------------------------

C:\Local>createdb -h localhost -p 5433 -U postgres pghydro
C:\Local>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION postgis;"
C:\Local>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION pghydro;"
---------------------------------------
--INPUT DATA TO PGHYDRO DATABASE SCHEMA
---------------------------------------
C:\Local>psql -h localhost -p 5433 -U postgres
postgres=# \c pghydro
pghydro=# \i input_drainage_line.sql
pghydro=# \i input_drainage_area.sql
--=====================================
--BEGIN P1
--=====================================
BEGIN;
SELECT pghydro.pghfn_input_data_drainage_line('nome');
COMMIT;
BEGIN;
SELECT pghydro.pghfn_input_data_drainage_area();
COMMIT;
--'nome' - column name;
--IF there is no column name: SELECT pghydro.pghfn_input_data_drainage_line('none');
--=====================================
--END P1
--=====================================
BEGIN;
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
COMMIT;

BEGIN;
SELECT setval(('pghydro.drn_pk_seq'::text)::regclass, 1, false);
COMMIT;

BEGIN;
UPDATE pghydro.pghft_drainage_line
SET drn_pk = NEXTVAL('pghydro.drn_pk_seq');
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
COMMIT;

BEGIN;
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);
COMMIT;

--=====================================
--BEGIN P2
--=====================================
--CHECK HOW MANY FEATURES HAVE NOT SINGLE GEOMETRIES (DRAINAGE STRETCH)
SELECT pghydro.pghfn_numDrainageLineIsNotSingle() as count;
--IF 'count' > 0 THEN
	--EXECUTE P3
--ELSE GO TO STEP P4
--END IF 
--=====================================
--END P2
--=====================================
--=====================================
--BEGIN P3
--=====================================
--EXPLODE THE GEOMETRY
SELECT pghydro.pghfn_ExplodeDrainageLine();
--=====================================
--END P3
--=====================================
--=====================================
--BEGIN P4
--=====================================
--CHECK HOW MANY FEATURES DO NOT HAVE SIMPLE GEOMETRY (DRAINAGE STRETCH)
SELECT pghydro.pghfn_numDrainageLineIsNotSimple() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P1
--ELSE GO TO STEP P5
--=====================================
--END P4
--=====================================
--=====================================
--BEGIN P5
--=====================================
--CHECK HOW MANY FEATURES DO NOT HAVE VALID GEOMETRY (DRAINAGE STRETCH)
SELECT pghydro.pghfn_numDrainageLineIsNotValid() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P1
--ELSE GO TO STEP P6
--=====================================
--END P5
--=====================================
--=====================================
--BEGIN P6
--=====================================
--CHECK HOW MANY FEATURES HAVE SELF-INTERSECTION GEOMETRY (DRAINAGE STRETCH)
SELECT pghydro.pghfn_numDrainageLineHaveSelfIntersection() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P1
--ELSE GO TO STEP P7
--=====================================
--END P6
--=====================================
--=====================================
--BEGIN P7
--=====================================
--CHECK HOW MANY LOOP FEATURES
SELECT pghydro.pghfn_numDrainageLineLoops() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P1
--ELSE GO TO STEP P8
--=====================================
--END P7
--=====================================
--=====================================
--BEGIN P8
--=====================================
--RUNNING THE ARC-NODE DATA
BEGIN;
SELECT pghydro.pghfn_assign_vertex_id();
COMMIT;

BEGIN;
SELECT pghydro.pghfn_CalculateValence();
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.drp_gm_idx;
COMMIT;

BEGIN;
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);
COMMIT;

BEGIN;
CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);
COMMIT;

--=====================================
--END P8
--=====================================
--=====================================
--BEGIN P9
--=====================================
--CHECK HOW MANY FEATURES HAVE NODE VALENCE = 2
SELECT pghydro.pghfn_numPointValenceValue2() as count;
--IF 'count' > 0 THEN
	--CHECK THE DRAINAGE STRETCH OF ALL NODES WITH VALUES = 2
		--IF EDITION IS NECESSARY THEN
			--EDIT, CORRECT THE GEOMETRY GO STEP P1
			--OPTIONAL: GO TO STEP P11
--ELSE GO TO STEP P10
--=====================================
--END P9
--=====================================
--=====================================
--BEGIN P10
--=====================================
--CHECK HOW MANY FEATURES HAVE NODE VALENCE >= 4 (MULTIPLE CONFLUENCE)
SELECT pghydro.pghfn_numPointValenceValue4() as count;
--IF 'count' > 0 THEN
	--CHECK THE DRAINAGE STRETCH OF ALL NODES WITH VALUES >= 4
		--IF EDITION IS NECESSARY THEN
			--EDIT, CORRECT THE GEOMETRY GO STEP P1
		--ELSE CONTINUE AND GO TO STEP P11
--ELSE GO TO STEP P13
--=====================================
--END P10
--=====================================
--=====================================
--BEGIN P11
--=====================================
--UNION ALL DRAINAGE STRETCH WITH NODES VALENCE = 2
BEGIN;
SELECT pghydro.pghfn_uniondrainagelinevalence2();
COMMIT;
--GO STEP P1
--=====================================
--END P11
--=====================================
--=====================================
--BEGIN P13
--=====================================
--IDENTIFY THE NODE THAT REPRESENTS THE SHORELINE ENDING POINT
BEGIN;
SELECT pghydro.pghfn_UpdateShorelineEndingPoint(76);
COMMIT;
--=====================================
--END P13
--=====================================
--=====================================
--BEGIN P14
--=====================================
--IDENTIFY THE NODE THAT REPRESENTS THE SHORELINE STARTING POINT
BEGIN;
SELECT pghydro.pghfn_UpdateShorelineStartingPoint(70);
COMMIT;
--=====================================
--END P14
--=====================================
--=====================================
--BEGIN P15
--=====================================
BEGIN;
SELECT pghydro.pghfn_CalculateFlowDirection();
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.drp_gm_idx;
COMMIT;

BEGIN;
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);
COMMIT;

BEGIN;
CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);
COMMIT;

--=====================================
--END P15
--=====================================
--=====================================
--BEGIN P16
--=====================================
--CHECK HOW MANY FEATURES ARE DISCONNECTED
SELECT pghydro.pghfn_numDrainageLineIsDisconnected() as count;
--IF 'count' > 0 THEN
	--EDIT THE DRAINAGE STRETCHES DISCONNECTED AND GO BACK TO STEP P1
--ELSE GO TO STEP P16A
--=====================================
--END P16
--=====================================
--=====================================
--BEGIN P16A
--=====================================
--REVERSE DRAINAGE STRETCH
SELECT pghydro.pghfn_ReverseDrainageLine();
--=====================================
--END P16A
--=====================================
--=====================================
--BEGIN P16B
--============================================
--CHECK HOW MANY FEATURES HAVE DIVERGENT POINT
SELECT pghydro.pghfn_numPointDivergent() as count;
--IF 'count' > 0 THEN
	--EDIT THE DRAINAGE STRETCHES IN LOOP AND GO BACK TO STEP P1
--ELSE GO TO STEP P16B
--============================================
--END P16B
--=====================================
BEGIN;
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.drp_gm_idx;
COMMIT;

BEGIN;
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);
COMMIT;

BEGIN;
CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);
COMMIT;

BEGIN;
SELECT setval(('pghydro.dra_pk_seq'::text)::regclass, 1, false);
COMMIT;

BEGIN;
UPDATE pghydro.pghft_drainage_area
SET dra_pk = NEXTVAL('dra_pk_seq');
COMMIT;

BEGIN;
DROP INDEX IF EXISTS pghydro.dra_gm_idx;
CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING GIST(dra_gm);
COMMIT;
--=====================================
--BEGIN P17
--=====================================
--CHECK HOW MANY FEATURES HAVE NOT SINGLE GEOMETRIES (DRAINAGE AREA)
SELECT pghydro.pghfn_numDrainageAreaIsNotSingle() as count;
--IF 'count' > 0 THEN
	--EXECUTE P18
--ELSE GO TO STEP P19
--END IF 
--=====================================
--END P17
--=====================================
--=====================================
--BEGIN P18
--=====================================
--EXPLODE THE GEOMETRY
BEGIN;
SELECT pghydro.pghfn_ExplodeDrainageArea();
COMMIT;

--=====================================
--END P18
--=====================================
--=====================================
--BEGIN P19
--=====================================
--CHECK HOW MANY FEATURES DO NOT HAVE SIMPLE GEOMETRY (DRAINAGE AREA)
SELECT pghydro.pghfn_numDrainageAreaIsNotSimple() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P16B
--ELSE GO TO STEP P20
--=====================================
--END P19
--=====================================
--=====================================
--BEGIN P20
--=====================================
--CHECK HOW MANY FEATURES DO NOT HAVE VALID GEOMETRY (DRAINAGE AREA)
SELECT pghydro.pghfn_numDrainageAreaIsNotValid() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P16B
--ELSE GO TO STEP P21
--=====================================
--END P20
--=====================================
--=====================================
--BEGIN P21
--=====================================
--CHECK HOW MANY FEATURES HAVE SELF-INTERSECTION GEOMETRY (DRAINAGE AREA)
SELECT pghydro.pghfn_numDrainageAreaHaveSelfIntersection() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P16B
--ELSE GO TO STEP P22
--=====================================
--END P21
--=====================================
--=====================================
--BEGIN P22
--=====================================
--CHECK HOW MANY FEATURES HAVE DUPLICATION GEOMETRY (DRAINAGE AREA)
SELECT pghydro.pghfn_numDrainageAreaHaveDuplication() as count;
--IF 'count' > 0  THEN
	--EDIT, CORRECT THE GEOMETRY GO STEP P16B
--ELSE GO TO STEP P23
--=====================================
--END P22
--=====================================
--=====================================
--BEGIN P23
--=====================================
--ASSOCIATION BETWEEN DRAINAGE LINE AND DRAINAGE AREA
BEGIN;
SELECT pghydro.pghfn_AssociateDrainageLine_DrainageArea();
COMMIT;
BEGIN;
DROP INDEX IF EXISTS pghydro.dra_gm_idx;
CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING GIST(dra_gm);
COMMIT;
BEGIN;
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drs_gm);
COMMIT;
--=====================================
--END P23
--=====================================
--=====================================
--BEGIN P24
--=====================================
--CHECK HOW MANY FEATURES HAVE DRAINAGE AREA WITHOUT DRAINAGE LINE
SELECT pghydro.pghvw_drainageareanodrainageline() as count;
--IF 'count' > 1  THEN
	--EDIT OR DROP THE DRAINAGE AREA WITHOUT DRAINAGE LINE AND GO BACK TO STEP P16-B
--ELSE GO TO STEP P25
--=====================================
--END P24
--=====================================
--=====================================
--BEGIN P25
--=====================================
--CHECK HOW MANY FEATURES HAVE DRAINAGE LINE WITHOUT DRAINAGE AREA 
SELECT pghydro.pghfn_numdrainagelinenodrainagearea() as count;
--IF 'count' > 1  THEN
	--EDIT THE HYDROGRAPHIC CATCHMENT AREA WITHOUT DRAINAGE STRETCH AND GO BACK TO STEP P16-B
	-- OR
	--EXECUTE THE FUNCTION pghydro.pghfn_uniondrainageareanodrainageline() AND GO BACK TO STEP P16-B
		SELECT pghydro.pghfn_uniondrainageareanodrainageline();
--ELSE GO TO STEP P26
--=====================================
--END P25
--=====================================
--=====================================
--BEGIN P26
--=====================================
--CHECK HOW MANY FEATURES HAVE DRAINAGE AREA ASSOCIATED MORE ONE DRAINAGE LINE
SELECT pghydro.pghfn_numdrainageareamoreonedrainageline() as count;
--IF 'count' > 1  THEN
	--EDIT THE DRAINAGE AREA OR INSERT THE DRAINAGE AREA AND GO BACK TO STEP P16-B
--ELSE GO TO STEP P27
--=====================================
--END P26
--=====================================
--=====================================
--BEGIN P27
--=====================================
--CHECK HOW MANY FEATURES HAVE DRAINAGE LINE ASSOCIATED MORE ONE DRAINAGE AREA
SELECT pghydro.pghfn_numdrainageareamoreonedrainageline() as count;
--IF 'count' > 1  THEN
	--EDIT THE DRAINAGE AREA THAT HAVE OVERLAPS AND GO BACK TO STEP P16-B
--ELSE GO TO STEP P28
--=====================================
--END P27
--=====================================
SELECT pghydro.pghfn_TurnOffKeysIndex();
--=====================================
--BEGIN P28
--=====================================
--CALCULATE DRAINAGE STRETCH LENGTH
SELECT pghydro.pghfn_CalculateDrainageLineLength(29100, 1000);
--=====================================
--END P28
--=====================================
--=====================================
--BEGIN P29
--=====================================
--CALCULATE DRAINAGE AREA AREA
SELECT pghydro.pghfn_CalculateDrainageAreaArea(29100, 1000000);
--=====================================
--END P29
--=====================================
--=====================================
--BEGIN P31
--=====================================
--CALCULATE DISTANCE TO SEA
SELECT pghydro.pghfn_CalculateDistanceToSea(0);
--offset distance to sea
--=====================================
--END P31
--=====================================
--=====================================
--BEGIN P32
--=====================================
--CALCULATE UPSTREAM AREA
SELECT pghydro.pghfn_CalculateUpstreamArea();
--=====================================
--END P32
--=====================================
--=====================================
--BEGIN P33
--=====================================
--CALCULATE UPSTREAM STRETCH
SELECT pghydro.pghfn_CalculateUpstreamDrainageLine();
--=====================================
--END P33
--=====================================
--=====================================
--BEGIN P34
--=====================================
--CALCULATE DOWNSTREAM STRETCH
SELECT pghydro.pghfn_CalculateDownstreamDrainageLine();
--=====================================
--END P34
--=====================================

--==================================================
--INÍCIO DA ETAPA ALTERNATIVA - CODIFICAÇÃO DE OTTO
--==================================================

--=====================================
--BEGIN P35
--=====================================
----Exportar tabela de entrada do aplicativo topologia hídrica 

SELECT pghydro.pghfn_ExportTopologicalTable('d://teste/aat.txt')

--=====================================
--END P35
--=====================================

------------------------------------------------------
--Executar o aplicativo topologia hídrica versão 1.8
------------------------------------------------------

--=====================================
--BEGIN P36
--=====================================
--Importar e Criar as tabela com as informações da topologia hídrica

SELECT pghydro.pghfn_ImportTopologicalTable('d://teste/TRECHOS DE CURSOS DAGUA.txt')

--=====================================
--END P36
--=====================================

--==================================================
--FIM DA ETAPA ALTERNATIVA - CODIFICAÇÃO DE OTTO
--==================================================
--=====================================
--BEGIN P35-P36
--=====================================
----CALCULATE PFAFSTETTER BASIN CODIFICATION 
SELECT pghydro.pghfn_Calculate_Pfafstetter_Codification();
--=====================================
--END P35-P36
--=====================================

--=====================================
--BEGIN P37
--=====================================
--UPDATE PFAFSTETTER BASIN CODE
SELECT pghydro.pghfn_UpdatePfafstetterBasinCode('7597');
--=====================================
--END P37
--=====================================

--=====================================
--BEGIN P38
--=====================================
--UPDATE PFAFSTETTER WATERCOURSE CODE
SELECT pghydro.pghfn_UpdatePfafstetterWatercourseCode();
--=====================================
--END P38
--=====================================

--=====================================
--BEGIN P39
--=====================================
--UPDATE WATERCOURSE
SELECT pghydro.pghfn_UpdateWatercourse();
--=====================================
--END P39
--=====================================
--=====================================
--BEGIN P40
--=====================================
--CHECK HIGHER PFAFSTETTER BASIN CODE
SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN((SELECT pghydro.pghfn_numPfafstetterBasinCodeLevel()::integer));
--=====================================
--END P40
--=====================================
--=====================================
--BEGIN P41
--=====================================
--CHECK LOWER PFAFSTETTER BASIN CODE
SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN(1);
--=====================================
--END P41
--=====================================
--=====================================
--BEGIN P42
--=====================================
--UPDATE WATERSHED WITH HIGHER PFAFSTETTER BASIN CODE
SELECT pghydro.pghfn_UpdateWatershedDrainageArea((SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN((SELECT pghydro.pghfn_numPfafstetterBasinCodeLevel()::integer))));
--=====================================
--END P42
--=====================================
--=====================================
--BEGIN P43
--=====================================
--UPDATE WATERSHED WITH LOWER PFAFSTETTER BASIN CODE
SELECT pghydro.pghfn_UpdateWatershedDrainageArea((SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN(1)));
--=====================================
--END P43
--=====================================
--=====================================
--BEGIN P44
--=====================================
--INSERT PFASTETTER BASIN CODE LEVEL COLUMNS
SELECT pghydro.pghfn_InsertColumnPfafstetterBasinCodeLevel();
--=====================================
--END P44
--=====================================
--=====================================
--BEGIN P45
--=====================================
--UPDATE WATERCOURSE_STARTING_POINT
SELECT pghydro.pghfn_UpdateWatercourse_Starting_Point();
--=====================================
--END P45
--=====================================
--=====================================
--BEGIN P46
--=====================================
--UPDATE WATERCOURSE_ENDING_POINT
SELECT pghydro.pghfn_UpdateWatercourse_Ending_Point();
--=====================================
--END P46
--=====================================
--=====================================
--BEGIN P47
--=====================================
--UPDATE STREAM_MOUTH
SELECT pghydro.pghfn_UpdateStream_Mouth();
--=====================================
--END P47
--=====================================
--=====================================
--BEGIN P48
--=====================================
--INSERT DOMAIN COLUMN
--SELECT pghydro.pghfn_InsertDomainColumn();
--=====================================
--END P48
--=====================================
--=====================================
--BEGIN P49
--=====================================
--UPDATE THE DRAINAGE STRETCHES (pghydro.pghft_drainage_line) THAT CROSS STATE/COUNTRY BORDERS WITH pghydro.drn_tdm_pk = 1
--=====================================
--END P49
--=====================================
--=====================================
--BEGIN P50A
--=====================================
--UPDATE FEDERAL DRAINAGE STRETCHES AND WATERCOURSES
SELECT pghydro.pghfn_UpdateDomainColumn();
--=====================================
--END P50A
--=====================================
--=====================================
--BEGIN P50B
--=====================================
--UPDATE STRAHLER NUMBER
SELECT pghydro.pghfn_calculatestrahlernumber();
--=====================================
--END P50B
--=====================================
--=====================================
--BEGIN P50C
--=====================================
--UPDATE STRAHLER NUMBER
SELECT pghydro.pghfn_updateshoreline();
--=====================================
--END P50C
--=====================================
--=====================================
--BEGIN P51
--=====================================
--TURN ON KEYS AND INDEX
SELECT pghydro.pghfn_TurnOffKeysIndex();
SELECT pghydro.pghfn_TurnOnKeysIndex();
--=====================================
--END P51
--=====================================
--=====================================
--BEGIN P52
--=====================================
--CREATE EXPORT VIEWS
SELECT pghydro.pghfn_DropExportViews();
SELECT pghydro.pghfn_DropConsistencyViews();
SELECT pghydro.pghfn_CreateExportViews();
--=====================================
--END P51
--=====================================