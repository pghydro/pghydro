--
-- Copyright (c) 2015 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
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
--
---------------------------------------------------------------------------------
--PGHYDRO Hydronym Database Tools version 5.1 of 10/03/2016
---------------------------------------------------------------------------------

--------
--SCHEMA
--------
--REPLACE pghydro. -> pghydro.
--REPLACE 'pghydro' -> 'pghydro'
--------

--INSTALL EXTENSIONS

>psql -h localhost -p 5433 -U postgres -d pghydro -c "CREATE EXTENSION hydronym;"

--------
--BEGIN
--------
--=====================================
--BEGIN P1
--=====================================
BEGIN;
SELECT pghydro.pghfn_turnoffkeysindex();
COMMIT;
--=====================================
--END P1
--=====================================
---------------------------------------------
--CREATE THE PGHYDRO HYDRONYM DATABASE SCHEMA 
---------------------------------------------
D:\pghydro>psql -h localhost -p 5433 -U postgres
postgres=# \c pghydro
pghydro=# \i pghydro_hydronym_schema_05_01.sql
pghydro=# \q
--=====================================
--BEGIN P2
--=====================================
DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;

DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;

SELECT pghydro.pghfn_systematize_hydronym();

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area (dra_pk);

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk);

DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;

CREATE INDEX dra_cd_pfafstetterbasin_idx ON pghydro.pghft_drainage_area (dra_cd_pfafstetterbasin);

DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;

CREATE INDEX wtc_cd_pfafstetterwatercourse_idx ON pghydro.pghft_watercourse(wtc_cd_pfafstetterwatercourse);

--=====================================
--END P2
--=====================================
--IF NAMES IN TABLES ARE WRONG (pghydro.pghtb_nm_generic, pghydro.pghtb_nm_connection, pghydro.pghtb_nm_specific)
	--EDIT THE NAMES IN COLUMNS (nmg_nm_generic, nmc_nm_connection, nms_nm_specific) AND EXECUTE P3 AND P2 AGAIN
--ELSE GO TO STEP P4
--END IF
--=====================================
--BEGIN P3
--=====================================
--UPADATE THE ORIGINAL NAME IN DRAINAGE STRETCH WITH THE EDITED ONES

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;

DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;

SELECT pghydro.pghfn_update_drn_nm();

--=====================================
--END P3
--=====================================
--=====================================
--BEGIN P4
--=====================================
--CHECK HOW MANY FEATURES HAVE HYDRONYMS CONFLUENTS
SELECT pghydro.pghfn_numConfluenceHydronym() as count;
--IF 'count' > 0  THEN
	--EDIT AND CORRECT THE HYDRONYM NAME IN DRAINAGE STRETCH AND EXECUTE P2 AGAIN
--ELSE GO TO STEP P5
--=====================================
--END P4
--=====================================
--=====================================
--BEGIN P5
--=====================================

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_cd_pfafstetterbasin_idx;

DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;

SELECT pghydro.pghfn_update_hydronym();

--=====================================
--END P5
--=====================================
--=====================================
--BEGIN P6
--=====================================
SELECT pghydro.pghfn_DropTempSchema();
--=====================================
--END P6
--=====================================
--=====================================
--BEGIN P7
--=====================================
SELECT pghydro.pghfn_turnoffkeysindex();
--=====================================
--END P7
--=====================================
--=====================================
--BEGIN P8
--=====================================
SELECT pghydro.pghfn_turnonkeysindex();
--=====================================
--END P8
--=====================================
--=====================================
--BEGIN P52
--=====================================
--CREATE EXPORT VIEWS
SELECT pghydro.pghfn_DropExportViews();
SELECT pghydro.pghfn_CreateExportViews();
--=====================================
--END P51
--=====================================
--ALTER DATABASE DATABASE SET client_encoding=utf-8;

--DROP EXTENSIONS

>psql -h localhost -p 5433 -U postgres -d pghydro -c "DROP EXTENSION hydronym;"

