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

--REQUIREMENTS

--Postgresql version 9.1+
--PostGIS version 2.0+
--PgHydro version 6.2

--INSTALLATION

--1 - Download the last pghydro stable release file Source code (zip) from the site https://github.com/pghydro/pghydro/releases
--2 - Unzip, copy and paste *.sql and *.control files to \PostgreSQL\x.x\share\extension

---------------------------------------------------------------------------------
--PgHYDRO Tutorial version 6.2 of 17/01/2018
---------------------------------------------------------------------------------

--=============================================
--1. CREATE SPATIAL DATABASE AND PGHYDRO SCHEMA
--=============================================

-------------------------------------------------------
--CREATE THE PGHYDRO DATABASE SCHEMA USING CMD COMMANDS
-------------------------------------------------------

C:\Local>createdb -h localhost -p 5433 -U postgres pghydro
C:\Local>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION postgis;"
C:\Local>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION pghydro;"
C:\Local>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION pgh_consistency;"
C:\Local>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION pgh_output;"

----------------------------------------------
--CREATE THE PGHYDRO DATABASE SCHEMA USING SQL
----------------------------------------------

CREATE EXTENSION postgis;

CREATE EXTENSION pghydro;

CREATE EXTENSION pgh_consistency;

CREATE EXTENSION pgh_output;

--==========================================
--2. IMPORT GEOMETRY TABLE TO PGHYDRO SCHEME
--==========================================

--------------------------
--2.1 CONVERT SHAPEFILE TO SQL
--------------------------

--THE USER CONVERT THE DRAINAGE SHAPEFILE 'input_drainage_line.shp' TO input_drainage_line.sql SQL USING THE SRID '4291' AND THE 'latin1' CHARACTER ENCODING
D:\Local>shp2pgsql -s 4674 -g geom -W "latin1" input_drainage_line.shp input_drainage_line > input_drainage_line.sql
--THE USER CONVERT DRAINAGE AREA SHAPEFILE 'input_drainage_area.shp' TO input_drainage_area.sql SQL USING THE SRID '4291' AND THE 'latin1' CHARACTER ENCODING
D:\Local>shp2pgsql -s 4674 -g geom -W "latin1" input_drainage_area.shp input_drainage_area > input_drainage_area.sql
--nome -> column with the 'name' of the drainage of the input_drainage_line.shp

--------------------------------------------
--2.2 INPUT DATA TO PGHYDRO DATABASE SCHEMA
--------------------------------------------
C:\Local>psql -h localhost -p 5433 -U postgres
postgres=# \c pghydro
pghydro=# \i input_drainage_line.sql
pghydro=# \i input_drainage_area.sql

------------------
--2.3 INPUT DATA
------------------

SELECT pghydro.pghfn_input_data_drainage_line('public', 'input_drainage_line', 'geom', 'nome');

SELECT pghydro.pghfn_input_data_drainage_area('public', 'input_drainage_area', 'geom');

--'nome' - column name;

--IF there is no column name:

SELECT pghydro.pghfn_input_data_drainage_line('public', 'input_drainage_line', 'geom', 'none');

--=====================================
--3. CONSIST DRAINAGE LINE
--=====================================

---------------------------------------
--3.1 GEOMETRIC CONSISTENCY
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

SELECT pgh_consistency.pghfn_MakeSnapToGridDrainageLine(0.0000001);

SELECT pgh_consistency.pghfn_removereapetedpointsdrainageline();

SELECT pgh_consistency.pghfn_DeleteDrainageLineGeometryEmpty();

SELECT setval(('pghydro.drn_pk_seq'::text)::regclass, 1, false);

UPDATE pghydro.pghft_drainage_line
SET drn_pk = NEXTVAL('pghydro.drn_pk_seq');

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

ALTER TABLE pghydro.pghft_drainage_line ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);
			
SELECT pgh_consistency.pghfn_UpdateDrainageLineConsistencyGeometryTables();

--3.1.1 Check_DrainageLineIsNotSimple

SELECT count(id)
FROM pgh_consistency.pghft_drainagelineisnotsimple;

--3.1.1 MakeDrainageLineSimple

SELECT pgh_consistency.pghfn_makedrainagelinesimple();

--3.1.2 Check_DrainageLineIsNotValid

SELECT count(id)
FROM pgh_consistency.pghft_drainagelineisnotvalid;

--3.1.2 MakeDrainageLineValid

SELECT pgh_consistency.pghfn_makedrainagelinevalid();

--3.1.3 Check_DrainageLineIsNotSingle

SELECT count(id)
FROM pgh_consistency.pghft_drainagelineisnotsingle;

--3.1.3 ExplodeDrainageLine

SELECT pgh_consistency.pghfn_explodedrainageline();

---------------------------------------
--3.2 TOPOLOGICAL CONSISTENCY - PART I
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

SELECT pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_1();

--3.2.1 Check_DrainageLineWithinDrainageLine

SELECT count(id)
FROM pgh_consistency.pghft_drainagelinewithindrainageline;

--3.2.1 DeleteDrainageLineWithinDrainageLine

SELECT pgh_consistency.pghfn_deletedrainagelinewithindrainageline();

--Check_DrainageLineOverlapDrainageLine

SELECT count(id)
FROM pgh_consistency.pghft_drainagelineoverlapdrainageline;

--Check_DrainageLineLoops

SELECT count(id)
FROM pgh_consistency.pghft_drainagelineloops;

---------------------------------------
--3.3 TOPOLOGICAL CONSISTENCY - PART II
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

SELECT pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_2();

--Check_DrainageLineCrossDrainageLine

SELECT count(id)
FROM pgh_consistency.pghft_drainagelinecrossdrainageline;

--Check_DrainageTouchDrainageLine

SELECT count(id)
FROM pgh_consistency.pghft_drainagelinetouchdrainageline;

--BreakDrainageLines

SELECT pgh_consistency.pghfn_CreateDrainageLineVertexIntersections(0.0000001);

SELECT pgh_consistency.pghfn_BreakDrainageLine();
			
SELECT pgh_consistency.pghfn_ExplodeDrainageLine();

--=====================================
--4. CONSIST DRAINAGE LINE NETWORK
--=====================================

---------------------------------------
--4.1 CREATE DRAINAGE NETWORK
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.drp_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

SELECT pghydro.pghfn_assign_vertex_id(1);

SELECT pghydro.pghfn_CalculateValence();

DROP INDEX IF EXISTS pghydro.drn_gm_idx;
		
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

DROP INDEX IF EXISTS pghydro.drp_gm_idx;
		
CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);

ALTER TABLE pghydro.pghft_drainage_line ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);

SELECT pgh_consistency.pghfn_updatedrainagelinenetworkconsistencytables();

--4.1.1 Check_PointValenceValue2

SELECT count(id)
FROM pgh_consistency.pghft_pointvalencevalue2;

--4.1.1 UnionDrainageLineValence2

SELECT pgh_consistency.pghfn_uniondrainagelinevalence2();

--4.1.2 Check_PointValenceValue4

SELECT count(id)
FROM pgh_consistency.pghft_pointvalencevalue4;

---------------------------------------
--4.2 IDENTIFY NETWORK NODES
---------------------------------------

--4.2.1 UpdateShorelineEndingPoint

SELECT pghydro.pghfn_UpdateShorelineEndingPoint(1);--drp_pk

--4.2.2 UpdateShorelineStartingPoint

SELECT pghydro.pghfn_UpdateShorelineStartingPoint(2);--drp_pk

---------------------------------------
--4.3 CONNECTIVITY AND FLOW DIRECTION
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.drp_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

SELECT pghydro.pghfn_CalculateFlowDirection();

SELECT pghydro.pghfn_ReverseDrainageLine();

DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

DROP INDEX IF EXISTS pghydro.drp_gm_idx;
			
CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);

ALTER TABLE pghydro.pghft_drainage_line ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);

SELECT pgh_consistency.pghfn_updatedrainagelineconnectionconsistencytables();

--4.3.1 Check_DrainageLineIsDisconnected

SELECT count(id)
FROM pgh_consistency.pghft_drainagelineisdisconnected;

--4.3.2 Check_PointDivergent

SELECT count(id)
FROM pgh_consistency.pghft_pointdivergent;

--=====================================
--5. CONSIST DRAINAGE AREA
--=====================================

---------------------------------------
--5.1 GEOMETRIC CONSISTENCY
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.dra_gm_idx;
		
ALTER TABLE pghydro.pghft_drainage_area DROP CONSTRAINT IF EXISTS dra_pk_pkey;

SELECT pgh_consistency.pghfn_makesnaptogriddrainagearea(0.0000001);

SELECT pgh_consistency.pghfn_removereapetedpointsdrainagearea();

SELECT pgh_consistency.pghfn_DeleteDrainageAreaGeometryEmpty();

SELECT pgh_consistency.pghfn_RemoveDrainageAreaInteriorRings();

SELECT setval(('pghydro.dra_pk_seq'::text)::regclass, 1, false);
			
UPDATE pghydro.pghft_drainage_area
SET dra_pk = NEXTVAL('pghydro.dra_pk_seq');
			
CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING GIST(dra_gm);
			
ALTER TABLE pghydro.pghft_drainage_area ADD CONSTRAINT dra_pk_pkey PRIMARY KEY (dra_pk);

SELECT pgh_consistency.pghfn_updatedrainageareaconsistencygeometrytables();

--5.1.1 Check_DrainageAreaIsNotSimple

SELECT count(id)
FROM pgh_consistency.pghft_drainageareaisnotsimple;

--5.1.1 MakeDrainageAreaSimple

SELECT pgh_consistency.pghfn_makedrainageareasimple();

--5.1.2 Check_DrainageAreaIsNotValid

SELECT count(id)
FROM pgh_consistency.pghft_drainageareaisnotvalid;

--5.1.2 MakeDrainageAreaValid

SELECT pgh_consistency.pghfn_makedrainageareavalid();

--5.1.3 Check_DrainageAreaIsNotSingle

SELECT count(id)
FROM pgh_consistency.pghft_drainageareaisnotsingle;

--5.1.3 ExplodeDrainageArea

SELECT pgh_consistency.pghfn_explodedrainagearea();

---------------------------------------
--5.2 TOPOLOGICAL CONSISTENCY
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

SELECT pgh_consistency.pghfn_updatedrainageareaconsistencytopologytables();

--5.2.1 Check_DrainageAreaWithinDrainageArea

SELECT count(id)
FROM pgh_consistency.pghft_drainageareawithindrainagearea;

--5.2.1 DeleteDrainageAreaWithinDrainageArea

SELECT pgh_consistency.pghfn_deletedrainageareawithindrainagearea();

--5.2.2 Check_DrainageAreaOverlapDrainageArea

SELECT count(id)
FROM pgh_consistency.pghft_drainageareaoverlapdrainagearea;

--5.2.2 RemoveDrainageAreaOverlap

SELECT pgh_consistency.pghfn_removedrainageareaoverlap();

--========================================
--6. CONSIST DRAINAGE LINE X DRAINAGE AREA
--========================================

---------------------------------------
--6 TOPOLOGICAL CONSISTENCY
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

ALTER TABLE pghydro.pghft_drainage_area DROP CONSTRAINT IF EXISTS dra_pk_pkey;

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

SELECT pghydro.pghfn_AssociateDrainageLine_DrainageArea();

SELECT pgh_consistency.pghfn_updatedrainagelinedrainageareaconsistencytables();

DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

DROP INDEX IF EXISTS pghydro.drp_gm_idx;
			
CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);

DROP INDEX IF EXISTS pghydro.dra_gm_idx;
			
CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING GIST(dra_gm);

ALTER TABLE pghydro.pghft_drainage_area DROP CONSTRAINT IF EXISTS dra_pk_pkey;

ALTER TABLE pghydro.pghft_drainage_area ADD CONSTRAINT dra_pk_pkey PRIMARY KEY (dra_pk);

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

ALTER TABLE pghydro.pghft_drainage_line ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);

SELECT pgh_consistency.pghfn_updatedrainagelinedrainageareaconsistencytables();

--6.1 Check_DrainageLineNoDrainageArea

SELECT count(id)
FROM pgh_consistency.pghft_drainagelinenodrainagearea;

--6.2 Check_DrainageAreaMoreOneDrainageLine

SELECT count(id)
FROM pgh_consistency.pghft_drainageareamoreonedrainageline;

--6.3 Check_DrainageLineMoreOneDrainageArea

SELECT count(id)
FROM pgh_consistency.pghft_drainagelinemoreonedrainagearea;

--6.4 Check_DrainageAreaNoDrainageLine

SELECT count(id)
FROM pgh_consistency.pghft_drainageareanodrainageline;

--6.4.1 Union_DrainageAreaNoDrainageLine

SELECT pgh_consistency.pghfn_uniondrainageareanodrainageline();

--=========================================
--7. EXECUTE FINAL HYDROGRAPHIC INFORMATION
--=========================================

---------------------------------------
--7 MAIN PROCEDURES
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

SELECT pghydro.pghfn_TurnOffKeysIndex();

SELECT pghydro.pghfn_CalculateDrainageLineLength(29100, 1000);--SRID, FACTOR

SELECT pghydro.pghfn_CalculateDrainageAreaArea(29100, 1000000);--SRID, FACTOR	

SELECT pghydro.pghfn_CalculateDistanceToSea(0);--DISTANCE TO SEA

SELECT pghydro.pghfn_CalculateUpstreamArea();

SELECT pghydro.pghfn_CalculateUpstreamDrainageLine();

SELECT pghydro.pghfn_CalculateDownstreamDrainageLine();

SELECT pghydro.pghfn_Calculate_Pfafstetter_Codification();

SELECT pghydro.pghfn_UpdatePfafstetterBasinCode(75978);--PFAFSTETTER BASIN CODE

SELECT pghydro.pghfn_UpdatePfafstetterWatercourseCode();

SELECT pghydro.pghfn_UpdateWatercourse();

SELECT pghydro.pghfn_InsertColumnPfafstetterBasinCodeLevel();

SELECT pghydro.pghfn_UpdateWatercourse_Starting_Point();

SELECT pghydro.pghfn_UpdateWatercourse_Ending_Point();

SELECT pghydro.pghfn_UpdateStream_Mouth();

SELECT pghydro.pghfn_calculatestrahlernumber();

SELECT pghydro.pghfn_updateshoreline();

SELECT pghydro.pghfn_UpdateDomainColumn();

SELECT pghydro.pghfn_TurnOnKeysIndex();

SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN(1);--MIN PFAFSTETTER LEVEL

SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN((SELECT pghydro.pghfn_numPfafstetterBasinCodeLevel()::integer));--MAX PFAFSTETTER LEVEL

--TRUNCATE TABLE pghydro.pghft_watershed;
				
--SELECT pghydro.pghfn_updatewatersheddrainagearea((SELECT pghydro.pghfn_PfafstetterBasinCodeLevelN((SELECT pghydro.pghfn_numPfafstetterBasinCodeLevel()::integer))));--PDATE WATERSHED WITH MAX PFAFSTETTER LEVEL

--SELECT pghydro.pghfn_updatewatershed(MAX - 1);

--=========================================
--8. UPDATE OUTPUT GEOMETRY TABLES
--=========================================

---------------------------------------
--8 UPDATE OUTPUT GEOMETRY TABLES
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

SELECT pghydro.pghfn_TurnOffKeysIndex();

SELECT pghydro.pghfn_TurnOnKeysIndex();

SELECT pgh_output.pghfn_UpdateExportTables();

--===========================================
--9. HYDRONYMIA SYSTEMATIZATION (RIVER NAMES)
--===========================================

---------------------------------------
--9.1 START HYDRONYMIA SYSTEMATIZATION
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

SELECT pghydro.pghfn_TurnOffKeysIndex();

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN IF EXISTS drn_dra_cd_pfafstetterbasin,
DROP COLUMN IF EXISTS drn_wtc_cd_pfafstetterwatercourse,
DROP COLUMN IF EXISTS drn_wtc_gm_area;

ALTER TABLE pghydro.pghft_drainage_line
ADD COLUMN drn_dra_cd_pfafstetterbasin varchar,
ADD COLUMN drn_wtc_cd_pfafstetterwatercourse varchar,
ADD COLUMN drn_wtc_gm_area numeric;
DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk); 

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk); 

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk); 

UPDATE pghydro.pghft_drainage_line drn
SET drn_dra_cd_pfafstetterbasin = dra.dra_cd_pfafstetterbasin
FROM pghydro.pghft_drainage_area dra
WHERE drn.drn_dra_pk = dra.dra_pk;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk); 

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk); 

UPDATE pghydro.pghft_drainage_line drn
SET drn_wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse
FROM pghydro.pghft_watercourse wtc
WHERE drn.drn_wtc_pk = wtc.wtc_pk;

UPDATE pghydro.pghft_drainage_line drn
SET drn_wtc_gm_area = wtc.wtc_gm_area
FROM pghydro.pghft_watercourse wtc
WHERE drn.drn_wtc_pk = wtc.wtc_pk;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;
			
DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;
			
DROP INDEX IF EXISTS pghydro.dra_pk_idx;
			
DROP INDEX IF EXISTS pghydro.wtc_pk_idx;
			
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

ALTER TABLE pghydro.pghft_drainage_line ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);

---------------------------------------
--9.2 HYDRONYMIA EDITING
---------------------------------------

--9.2.1 Systematize_Hydronym

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;
			
DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;
			
DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;
			
DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;
			
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

SELECT pgh_consistency.pghfn_systematize_hydronym();

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;
			
CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);
			
DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;
			
CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);
			
DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;
			
CREATE INDEX dra_cd_pfafstetterbasin_idx ON pghydro.pghft_drainage_area (dra_cd_pfafstetterbasin);
			
DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;
			
CREATE INDEX wtc_cd_pfafstetterwatercourse_idx ON pghydro.pghft_watercourse(wtc_cd_pfafstetterwatercourse);
			
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

ALTER TABLE pghydro.pghft_drainage_line ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);

--9.2.3 Update_OriginalHydronym

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;
			
DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;
			
DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;
			
DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;
			
DROP INDEX IF EXISTS pghydro.drn_gm_idx;
			
ALTER TABLE pghydro.pghft_drainage_line DROP CONSTRAINT IF EXISTS drn_pk_pkey;

SELECT pgh_consistency.pghfn_update_drn_nm();

---------------------------------------
--9.3 CONFLUENT HYDRONYMIA
---------------------------------------

DROP INDEX IF EXISTS pghydro.drn_nm_idx;
			
CREATE INDEX drn_nm_idx ON pghydro.pghft_drainage_line(drn_nm); 

SELECT pgh_consistency.pghfn_updateconfluencehydronymconistencytable();
			
DROP INDEX IF EXISTS pghydro.drn_nm_idx;

--9.3.1 Check_ConfluenceHydronym

SELECT count(id)
FROM pgh_consistency.pghft_confluencehydronym;

---------------------------------------
--9.4 FINISH HYDRONYMIA SYSTEMATIZATION
---------------------------------------

SELECT pgh_consistency.pghfn_TurnOffBackup();

DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;
			
DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;
			
ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN IF EXISTS drn_dra_cd_pfafstetterbasin,
DROP COLUMN IF EXISTS drn_wtc_cd_pfafstetterwatercourse,
DROP COLUMN IF EXISTS drn_wtc_gm_area;

SELECT pghydro.pghfn_turnoffkeysindex();

SELECT pghydro.pghfn_turnonkeysindex();

--===========================================
--10. MULTI-USER EDITING
--===========================================

---------------------------------------
--10.1 CRIATE USER
---------------------------------------

CREATE USER user_name WITH PASSWORD 'user_name' SUPERUSER;

---------------------------------------
--10.2 VIEW USERS
---------------------------------------

--10.2.1 View Users

SELECT usename FROM pg_user;

--10.2.2 Grant User

GRANT ALL PRIVILEGES ON DATABASE database_name TO user_name;

--10.2.3 Revoke User

REVOKE ALL PRIVILEGES ON DATABASE database_name FROM user_name;

--10.2.4 Drop User

DROP USER IF EXISTS user_name;

---------------------------------------
--10.3 LOG MANAGEMENT
---------------------------------------

--10.3.1 Turn_ON_Audit

SELECT pgh_consistency.pghfn_turnonbackup();

--10.3.2 Turn_OFF_Audit

SELECT pgh_consistency.pghfn_TurnOffBackup();

--10.3.3 Reset_Drainage_Line_Audit

SELECT pgh_consistency.pghfn_CleanDrainageLineBackupTables();

--10.3.4 Reset_Drainage_Area_Audit

SELECT pgh_consistency.pghfn_CleanDrainageAreaBackupTables();
