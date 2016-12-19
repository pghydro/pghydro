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
--PGHYDRO Hydronym Database Scheme version 5.4 of 26/09/2016
---------------------------------------------------------------------------------

--------
--SCHEMA
--------
--REPLACE pghydro. -> schema.
--REPLACE 'pghydro' -> 'schema'
--------

----------------------------------------------------
--PGHYDRO HYDRONYM FUNCTIONS
----------------------------------------------------
--BEGIN;
----------------------------------------------------
--FUNCTION pghydro.pghfn_CreateTempSchema()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateTempSchema()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

--ADD COLUMNS, CREATE TABLES AND SEQUENCES

TRUNCATE pghydro.pghft_hydronym;

TRUNCATE pghydro.pghtb_type_name_complete;

TRUNCATE pghydro.pghtb_type_name_connection;

TRUNCATE pghydro.pghtb_type_name_generic;

TRUNCATE pghydro.pghtb_type_name_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN IF EXISTS drn_dra_cd_pfafstetterbasin,
DROP COLUMN IF EXISTS drn_wtc_cd_pfafstetterwatercourse,
DROP COLUMN IF EXISTS drn_wtc_gm_area;

ALTER TABLE pghydro.pghft_drainage_line
ADD COLUMN drn_dra_cd_pfafstetterbasin varchar,
ADD COLUMN drn_wtc_cd_pfafstetterwatercourse varchar,
ADD COLUMN drn_wtc_gm_area numeric;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk); 

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk); 

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk); 

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_dra_cd_pfafstetterbasin = dra.dra_cd_pfafstetterbasin
FROM pghydro.pghft_drainage_area dra
WHERE drn.drn_dra_pk = dra.dra_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk); 

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk); 

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse
FROM pghydro.pghft_watercourse wtc
WHERE drn.drn_wtc_pk = wtc.wtc_pk;

UPDATE pghydro.pghft_drainage_line drn
SET drn_wtc_gm_area = wtc.wtc_gm_area
FROM pghydro.pghft_watercourse wtc
WHERE drn.drn_wtc_pk = wtc.wtc_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_nm_waterbodyoriginal;

CREATE SEQUENCE pghydro.nwo_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pghydro.pghtb_nm_waterbodyoriginal(
nwo_pk integer NOT NULL DEFAULT nextval('pghydro.nwo_pk_seq'::regclass),
nwo_nm_original varchar,
nwo_nm_generic varchar,
nwo_nm_connection varchar,
nwo_nm_specific varchar
);

ALTER SEQUENCE pghydro.nwo_pk_seq OWNED BY pghydro.pghtb_nm_waterbodyoriginal.nwo_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_nm_generic;

CREATE SEQUENCE pghydro.nmg_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pghydro.pghtb_nm_generic(
nmg_pk integer NOT NULL DEFAULT nextval('pghydro.nmg_pk_seq'::regclass),
nmg_nwo_nm_generic varchar,
nmg_nm_generic varchar
);

ALTER SEQUENCE pghydro.nmg_pk_seq OWNED BY pghydro.pghtb_nm_generic.nmg_pk;

ALTER TABLE ONLY pghydro.pghtb_nm_generic ADD CONSTRAINT nmg_pk_pkey PRIMARY KEY (nmg_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_nm_connection;

CREATE SEQUENCE pghydro.nmc_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pghydro.pghtb_nm_connection(
nmc_pk integer NOT NULL DEFAULT nextval('pghydro.nmc_pk_seq'::regclass),
nmc_nwo_nm_connection varchar,
nmc_nm_connection varchar
);

ALTER SEQUENCE pghydro.nmc_pk_seq OWNED BY pghydro.pghtb_nm_connection.nmc_pk;

ALTER TABLE ONLY pghydro.pghtb_nm_connection ADD CONSTRAINT nmc_pk_pkey PRIMARY KEY (nmc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_nm_specific;

CREATE SEQUENCE pghydro.nms_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pghydro.pghtb_nm_specific(
nms_pk integer NOT NULL DEFAULT nextval('pghydro.nms_pk_seq'::regclass),
nms_nwo_nm_specific varchar,
nms_nm_specific varchar
);

ALTER SEQUENCE pghydro.nms_pk_seq OWNED BY pghydro.pghtb_nm_specific.nms_pk;

ALTER TABLE ONLY pghydro.pghtb_nm_specific ADD CONSTRAINT nms_pk_pkey PRIMARY KEY (nms_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_nm_complete;

CREATE SEQUENCE pghydro.nmp_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pghydro.pghtb_nm_complete(
nmp_pk integer NOT NULL DEFAULT nextval('pghydro.nmp_pk_seq'::regclass),
nmp_nm_complete varchar,
nmp_nm_generic varchar,
nmp_nm_connection varchar,
nmp_nm_specific varchar
);

ALTER SEQUENCE pghydro.nmp_pk_seq OWNED BY pghydro.pghtb_nm_complete.nmp_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym;

CREATE SEQUENCE pghydro.nhd_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pghydro.pghtb_nm_hydronym
(
  nhd_pk integer NOT NULL DEFAULT nextval('pghydro.nhd_pk_seq'::regclass),
  nhd_drn_hdr_pk integer,
  nhd_drn_wtc_cd_pfafstetterwatercourse_min varchar,
  nhd_drn_nu_distancetosea_min numeric,
  nhd_drn_wtc_cd_pfafstetterwatercourse_max varchar,
  nhd_drn_nu_distancetosea_max numeric,
  nhd_cd_nm varchar
);

ALTER SEQUENCE pghydro.nhd_pk_seq OWNED BY pghydro.pghtb_nm_hydronym.nhd_pk;

--VIEW pghydro.pghvw_confluencehydronym

CREATE OR REPLACE VIEW pghydro.pghvw_confluencehydronym AS
SELECT DISTINCT drn_drp_pk_targetnode as drp_pk, drp_gm as drp_gm
FROM
(
SELECT a.drn_drp_pk_targetnode, c.drp_gm
FROM pghydro.pghft_drainage_line a, pghydro.pghft_drainage_line b, pghydro.pghft_drainage_point c
WHERE a.drn_nm = b.drn_nm
AND a.drn_drn_pk_upstreamdrainageline = b.drn_pk
AND a.drn_drp_pk_targetnode = c.drp_pk
) as d;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_systematize_hydronym()
----------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_systematize_hydronym()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;
    
time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

TRUNCATE pghydro.pghtb_nm_waterbodyoriginal;

ALTER SEQUENCE pghydro.nwo_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_waterbodyoriginal (nwo_nm_original, nwo_nm_generic, nwo_nm_connection, nwo_nm_specific)
SELECT DISTINCT nm_original, nm_generic, nm_connection, nm_specific
FROM
(
SELECT
drn_pk,
nm_original,
trim(both ' ' from t1) as nm_generic,
trim(both ' ' from t2) as nm_connection,
trim(both ' ' from (t3||' '||t4||' '||t5||' '||t6||' '||t7||' '||t8||' '||t9||' '||t10||' '||t11||' '||t12||' '||t13||' '||t14||' '||t15||' '||t16||' '||t17)) as nm_specific
FROM
(
SELECT
drn_pk,
nm_original,
trim(both ' ' from split_part(nm_original, ' ', 1)) as t1,
trim(both ' ' from lower(split_part(nm_original, ' ', 2))) as t2,
trim(both ' ' from split_part(nm_original, ' ', 3)) as t3,
trim(both ' ' from split_part(nm_original, ' ', 4)) as t4,
trim(both ' ' from split_part(nm_original, ' ', 5)) as t5,
trim(both ' ' from split_part(nm_original, ' ', 6)) as t6,
trim(both ' ' from split_part(nm_original, ' ', 7)) as t7,
trim(both ' ' from split_part(nm_original, ' ', 8)) as t8,
trim(both ' ' from split_part(nm_original, ' ', 9)) as t9,
trim(both ' ' from split_part(nm_original, ' ', 10)) as t10,
trim(both ' ' from split_part(nm_original, ' ', 11)) as t11,
trim(both ' ' from split_part(nm_original, ' ', 12)) as t12,
trim(both ' ' from split_part(nm_original, ' ', 13)) as t13,
trim(both ' ' from split_part(nm_original, ' ', 14)) as t14,
trim(both ' ' from split_part(nm_original, ' ', 15)) as t15,
trim(both ' ' from split_part(nm_original, ' ', 16)) as t16,
trim(both ' ' from split_part(nm_original, ' ', 17)) as t17
FROM
(
SELECT drn_pk, nm_original
FROM
(
SELECT drn_pk, nm_original
FROM
(
SELECT
drn_pk,
drn_nm as nm_original,
lower(split_part(drn_nm, ' ', 2)) as t2
FROM pghydro.pghft_drainage_line
WHERE drn_nm is not null
) as a
WHERE t2 = 'de'
OR t2 = 'da'
OR t2 = 'do'
OR t2 = 'das'
OR t2 = 'dos'
OR t2 = 'del'
) as a
WHERE 
NOT EXISTS
(
SELECT drn_pk
FROM
(
SELECT drn_pk, nm_original
FROM
(
SELECT
drn_pk,
drn_nm as nm_original,
lower(split_part(drn_nm, ' ', 3)) as t3
FROM pghydro.pghft_drainage_line
WHERE drn_nm is not null
) as a
WHERE t3 = 'la'
OR t3 = 'las'
OR t3 = 'los'
) as b
WHERE b.drn_pk = a.drn_pk
)
) as a
) as b
--) as c
UNION ALL
SELECT
drn_pk,
nm_original,
trim(both ' ' from t1) as nm_generic,
trim(both ' ' from (t2||' '||t3)) as nm_connection,
trim(both ' ' from (t4||' '||t5||' '||t6||' '||t7||' '||t8||' '||t9||' '||t10||' '||t11||' '||t12||' '||t13||' '||t14||' '||t15||' '||t16||' '||t17)) as nm_specific
FROM
(
SELECT
drn_pk,
nm_original,
trim(both ' ' from split_part(nm_original, ' ', 1)) as t1,
trim(both ' ' from lower(split_part(nm_original, ' ', 2))) as t2,
trim(both ' ' from lower(split_part(nm_original, ' ', 3))) as t3,
trim(both ' ' from split_part(nm_original, ' ', 4)) as t4,
trim(both ' ' from split_part(nm_original, ' ', 5)) as t5,
trim(both ' ' from split_part(nm_original, ' ', 6)) as t6,
trim(both ' ' from split_part(nm_original, ' ', 7)) as t7,
trim(both ' ' from split_part(nm_original, ' ', 8)) as t8,
trim(both ' ' from split_part(nm_original, ' ', 9)) as t9,
trim(both ' ' from split_part(nm_original, ' ', 10)) as t10,
trim(both ' ' from split_part(nm_original, ' ', 11)) as t11,
trim(both ' ' from split_part(nm_original, ' ', 12)) as t12,
trim(both ' ' from split_part(nm_original, ' ', 13)) as t13,
trim(both ' ' from split_part(nm_original, ' ', 14)) as t14,
trim(both ' ' from split_part(nm_original, ' ', 15)) as t15,
trim(both ' ' from split_part(nm_original, ' ', 16)) as t16,
trim(both ' ' from split_part(nm_original, ' ', 17)) as t17
FROM
(
SELECT drn_pk, nm_original
FROM
(
SELECT
drn_pk,
drn_nm as nm_original,
lower(split_part(drn_nm, ' ', 3)) as t3
FROM pghydro.pghft_drainage_line
WHERE drn_nm is not null
) as a
WHERE t3 = 'la'
OR t3 = 'las'
OR t3 = 'los'
) as b
) as c
--) as d
UNION ALL
SELECT DISTINCT 
drn_pk,
nm_original,
trim(both ' ' from t1) as nm_generic,
null as nm_connection,
trim(both ' ' from (t2||' '||t3||' '||t4||' '||t5||' '||t6||' '||t7||' '||t8||' '||t9||' '||t10||' '||t11||' '||t12||' '||t13||' '||t14||' '||t15||' '||t16||' '||t17)) as nm_specific
FROM
(
SELECT
drn_pk,
nm_original,
trim(both ' ' from split_part(nm_original, ' ', 1)) as t1,
trim(both ' ' from split_part(nm_original, ' ', 2)) as t2,
trim(both ' ' from split_part(nm_original, ' ', 3)) as t3,
trim(both ' ' from split_part(nm_original, ' ', 4)) as t4,
trim(both ' ' from split_part(nm_original, ' ', 5)) as t5,
trim(both ' ' from split_part(nm_original, ' ', 6)) as t6,
trim(both ' ' from split_part(nm_original, ' ', 7)) as t7,
trim(both ' ' from split_part(nm_original, ' ', 8)) as t8,
trim(both ' ' from split_part(nm_original, ' ', 9)) as t9,
trim(both ' ' from split_part(nm_original, ' ', 10)) as t10,
trim(both ' ' from split_part(nm_original, ' ', 11)) as t11,
trim(both ' ' from split_part(nm_original, ' ', 12)) as t12,
trim(both ' ' from split_part(nm_original, ' ', 13)) as t13,
trim(both ' ' from split_part(nm_original, ' ', 14)) as t14,
trim(both ' ' from split_part(nm_original, ' ', 15)) as t15,
trim(both ' ' from split_part(nm_original, ' ', 16)) as t16,
trim(both ' ' from split_part(nm_original, ' ', 17)) as t17
FROM
(
SELECT drn_pk, nm_original
FROM
(
SELECT
drn_pk,
drn_nm as nm_original,
lower(split_part(drn_nm, ' ', 2)) as t2,
lower(split_part(drn_nm, ' ', 3)) as t3
FROM pghydro.pghft_drainage_line
WHERE drn_nm is not null
) as a
WHERE t2 <> 'de'
AND t2 <> 'da'
AND t2 <> 'do'
AND t2 <> 'das'
AND t2 <> 'dos'
AND t2 <> 'del'
AND t2||' '||t3 <> 'de la'
AND t2||' '||t3 <> 'de las'
AND t2||' '||t3 <> 'de los'
) as a
) as c
) as d
ORDER BY nm_original;

UPDATE pghydro.pghtb_nm_waterbodyoriginal
SET nwo_nm_connection = ' '
WHERE nwo_nm_connection is null;

UPDATE pghydro.pghtb_nm_waterbodyoriginal
SET nwo_nm_specific = ' '
WHERE nwo_nm_specific = '';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

TRUNCATE pghydro.pghtb_nm_generic;

ALTER SEQUENCE pghydro.nmg_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_generic (nmg_nwo_nm_generic, nmg_nm_generic)
SELECT DISTINCT nwo_nm_generic, nwo_nm_generic
FROM pghydro.pghtb_nm_waterbodyoriginal
ORDER BY nwo_nm_generic;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

TRUNCATE pghydro.pghtb_nm_connection;

ALTER SEQUENCE pghydro.nmc_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_connection (nmc_nwo_nm_connection, nmc_nm_connection)
SELECT DISTINCT nwo_nm_connection, nwo_nm_connection
FROM pghydro.pghtb_nm_waterbodyoriginal
ORDER BY nwo_nm_connection;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

TRUNCATE pghydro.pghtb_nm_specific;

ALTER SEQUENCE pghydro.nms_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_specific (nms_nwo_nm_specific, nms_nm_specific)
SELECT DISTINCT nwo_nm_specific, nwo_nm_specific
FROM pghydro.pghtb_nm_waterbodyoriginal
ORDER BY nwo_nm_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

TRUNCATE pghydro.pghtb_nm_complete;

ALTER SEQUENCE pghydro.nmp_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_complete(nmp_nm_complete, nmp_nm_generic, nmp_nm_connection, nmp_nm_specific)
SELECT nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM
(
SELECT DISTINCT nmg_nm_generic||' '||nmc_nm_connection||' '||nms_nm_specific as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pghydro.pghtb_nm_generic nmg, pghydro.pghtb_nm_connection nmc, pghydro.pghtb_nm_specific nms, pghydro.pghtb_nm_waterbodyoriginal nwo
WHERE nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmc.nmc_nm_connection <> ' '
UNION ALL
SELECT DISTINCT CASE WHEN nms.nms_nm_specific = ' ' THEN nmg.nmg_nm_generic ELSE nmg.nmg_nm_generic||' '||nms.nms_nm_specific END as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pghydro.pghtb_nm_generic nmg, pghydro.pghtb_nm_connection nmc, pghydro.pghtb_nm_specific nms, pghydro.pghtb_nm_waterbodyoriginal nwo
WHERE nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmc.nmc_nm_connection = ' '
) as a
ORDER BY nmg_nm_generic, nms_nm_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_generic;

INSERT INTO pghydro.pghtb_type_name_generic (tng_pk, tng_ds)
SELECT nmg_pk, nmg_nm_generic
FROM pghydro.pghtb_nm_generic;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_connection;

INSERT INTO pghydro.pghtb_type_name_connection (tcn_pk, tcn_ds)
SELECT nmc_pk, nmc_nm_connection
FROM pghydro.pghtb_nm_connection;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_specific;

INSERT INTO pghydro.pghtb_type_name_specific (tns_pk, tns_ds)
SELECT nms_pk, nms_nm_specific
FROM pghydro.pghtb_nm_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_complete;

DROP INDEX IF EXISTS pghydro.nmg_nm_generic_idx;

DROP INDEX IF EXISTS pghydro.nmp_nm_generic_idx;

DROP INDEX IF EXISTS pghydro.nmc_nm_connection_idx;

DROP INDEX IF EXISTS pghydro.nmp_nm_connection_idx;

DROP INDEX IF EXISTS pghydro.nms_nm_specific_idx;

DROP INDEX IF EXISTS pghydro.nmp_nm_specific_idx;

CREATE INDEX nmg_nm_generic_idx ON pghydro.pghtb_nm_generic(nmg_nm_generic);

CREATE INDEX nmp_nm_generic_idx ON pghydro.pghtb_nm_complete(nmp_nm_generic);

CREATE INDEX nmc_nm_connection_idx ON pghydro.pghtb_nm_connection(nmc_nm_connection);

CREATE INDEX nmp_nm_connection_idx ON pghydro.pghtb_nm_complete(nmp_nm_connection);

CREATE INDEX nms_nm_specific_idx ON pghydro.pghtb_nm_specific(nms_nm_specific);

CREATE INDEX nmp_nm_specific_idx ON pghydro.pghtb_nm_complete(nmp_nm_specific);

INSERT INTO pghydro.pghtb_type_name_complete (tnc_pk, tnc_ds, tnc_tng_pk, tnc_tcn_pk, tnc_tns_pk)
SELECT nmp.nmp_pk, nmp.nmp_nm_complete, nmg.nmg_pk, nmc.nmc_pk, nms.nms_pk
FROM pghydro.pghtb_nm_complete nmp, pghydro.pghtb_nm_generic nmg, pghydro.pghtb_nm_connection nmc, pghydro.pghtb_nm_specific nms
WHERE nmg.nmg_nm_generic = nmp.nmp_nm_generic
AND nmc.nmc_nm_connection = nmp.nmp_nm_connection
AND nms.nms_nm_specific = nmp.nmp_nm_specific;

DROP INDEX IF EXISTS pghydro.nmg_nm_generic_idx;

DROP INDEX IF EXISTS pghydro.nmp_nm_generic_idx;

DROP INDEX IF EXISTS pghydro.nmc_nm_connection_idx;

DROP INDEX IF EXISTS pghydro.nmp_nm_connection_idx;

DROP INDEX IF EXISTS pghydro.nms_nm_specific_idx;

DROP INDEX IF EXISTS pghydro.nmp_nm_specific_idx;

RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_update_drn_nm()
----------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_update_drn_nm()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;
    
time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk); 

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

TRUNCATE pghydro.pghtb_nm_complete;

ALTER SEQUENCE pghydro.nmp_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_complete(nmp_nm_complete, nmp_nm_generic, nmp_nm_connection, nmp_nm_specific)
SELECT nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM
(
SELECT DISTINCT nmg_nm_generic||' '||nmc_nm_connection||' '||nms_nm_specific as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pghydro.pghtb_nm_generic nmg, pghydro.pghtb_nm_connection nmc, pghydro.pghtb_nm_specific nms, pghydro.pghtb_nm_waterbodyoriginal nwo
WHERE nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmc.nmc_nm_connection <> ' '
UNION ALL
SELECT DISTINCT CASE WHEN nms.nms_nm_specific = ' ' THEN nmg.nmg_nm_generic ELSE nmg.nmg_nm_generic||' '||nms.nms_nm_specific END as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pghydro.pghtb_nm_generic nmg, pghydro.pghtb_nm_connection nmc, pghydro.pghtb_nm_specific nms, pghydro.pghtb_nm_waterbodyoriginal nwo
WHERE nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmc.nmc_nm_connection = ' '
) as a
ORDER BY nmg_nm_generic, nms_nm_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

UPDATE pghydro.pghft_drainage_line drn
SET drn_nm = b.nmp_nm_complete
FROM
(
SELECT drn_pk, drn_nm, nmp_nm_complete
FROM
(
SELECT drn.drn_pk, drn.drn_nm, nmp.nmp_nm_complete
FROM
pghydro.pghft_drainage_line drn,
pghydro.pghtb_nm_complete nmp,
pghydro.pghtb_nm_generic nmg,
pghydro.pghtb_nm_connection nmc,
pghydro.pghtb_nm_specific nms,
pghydro.pghtb_nm_waterbodyoriginal nwo
WHERE drn.drn_nm = nwo.nwo_nm_original
AND nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmg.nmg_nm_generic = nmp.nmp_nm_generic
AND nmc.nmc_nm_connection = nmp.nmp_nm_connection
AND nms.nms_nm_specific = nmp.nmp_nm_specific
) as a 
WHERE drn_nm <> nmp_nm_complete
) as b
WHERE b.drn_pk = drn.drn_pk;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

PERFORM pghydro.pghfn_systematize_hydronym();

RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-------------------------------------------------------------
--FUNCTION pghydro.pghfn_hydronym_connected(integer, varchar)
-------------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_hydronym_connected(integer, varchar)
RETURNS integer[] AS
$$

WITH RECURSIVE lines_r AS (
SELECT ARRAY[drn_pk] AS idlist, drn_gm, drn_pk
FROM pghydro.pghft_drainage_line 
WHERE drn_pk = $1
AND drn_nm = $2
UNION ALL
SELECT array_append(lines_r.idlist, pghydro.pghft_drainage_line.drn_pk) AS idlist, pghydro.pghft_drainage_line.drn_gm AS drn_gm, pghydro.pghft_drainage_line.drn_pk AS drn_pk
FROM pghydro.pghft_drainage_line, lines_r
WHERE ST_Touches(pghydro.pghft_drainage_line.drn_gm, lines_r.drn_gm)
AND (pghydro.pghft_drainage_line.drn_gm && lines_r.drn_gm)
AND pghydro.pghft_drainage_line.drn_nm = $2
AND NOT lines_r.idlist @> ARRAY[pghydro.pghft_drainage_line.drn_pk]
)
SELECT array_agg(DISTINCT drn_pk) AS idlist
FROM lines_r;

$$ 
LANGUAGE 'sql';
--COMMIT;

-------------------------------------------------------------
--FUNCTION pghydro.pghfn_hydronym_unique(varchar)
-------------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_hydronym_unique(varchar)
RETURNS TABLE(drn_pk_ integer, class_ integer)
AS $$

BEGIN

RETURN QUERY

SELECT a.drn_pk, a.class
FROM
(
SELECT unnest(a.grouplist) as drn_pk, a.class
FROM
(

WITH RECURSIVE groups_r AS(
(
SELECT pghydro.pghfn_hydronym_connected(drn_pk, $1) AS idlist, pghydro.pghfn_hydronym_connected(drn_pk, $1) AS grouplist, drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_pk =
(
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_nm = $1
LIMIT 1
)
)
UNION ALL
(
SELECT array_cat(groups_r.idlist,pghydro.pghfn_hydronym_connected(pghydro.pghft_drainage_line.drn_pk, $1)) AS idlist, pghydro.pghfn_hydronym_connected(pghydro.pghft_drainage_line.drn_pk, $1) AS grouplist, pghydro.pghft_drainage_line.drn_pk
FROM pghydro.pghft_drainage_line, groups_r
WHERE NOT idlist @> ARRAY[pghydro.pghft_drainage_line.drn_pk]
AND pghydro.pghft_drainage_line.drn_nm = $1
LIMIT 1
)
)
SELECT (ROW_NUMBER() OVER ())::integer AS class, drn_pk, grouplist
FROM groups_r

) as a
) as a
,  pghydro.pghft_drainage_line drn
WHERE drn.drn_pk = a.drn_pk;

RETURN;

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

-----------------------------------------------------------
--EXECUTE pghydro.pghfn_CreateTempSchema()
-----------------------------------------------------------

--BEGIN;
SELECT pghydro.pghfn_CreateTempSchema();
--COMMIT;

------------------------------------------------------------------
--FUNCTION pghydro.pghfn_hydronym_pfastettercode(integer, varchar)
------------------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_hydronym_pfastettercode(var1 integer, var2 varchar)
RETURNS INTEGER AS $$

DECLARE

var3 pghydro.pghtb_nm_hydronym%ROWTYPE;
var4 pghydro.pghtb_nm_hydronym%ROWTYPE;
var5 INTEGER;

BEGIN

var5 := 0;

     SELECT * INTO var3 FROM pghydro.pghtb_nm_hydronym a WHERE a.nhd_pk=var1 AND a.nhd_drn_wtc_cd_pfafstetterwatercourse_min=var2;

     SELECT * INTO var4 FROM pghydro.pghtb_nm_hydronym a WHERE a.nhd_pk=(var1-1) AND a.nhd_drn_wtc_cd_pfafstetterwatercourse_min=var2;

                
                
                   IF var3.nhd_drn_wtc_cd_pfafstetterwatercourse_min = var4.nhd_drn_wtc_cd_pfafstetterwatercourse_min THEN

                                  SELECT count(a.nhd_pk) AS TOTAL INTO var5 FROM pghydro.pghtb_nm_hydronym a WHERE a.nhd_pk<=var1 AND a.nhd_drn_wtc_cd_pfafstetterwatercourse_min=var2;

                                  var5 := var5-1;
                                  
                   ELSE

				var5 := 0;

                   END IF;
                
RETURN var5;
END;
$$ LANGUAGE 'plpgsql';
--COMMIT;

---------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_update_hydronym()
---------------------------------------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_update_hydronym()
RETURNS varchar AS
$$

DECLARE

time_ timestamp;
i INTEGER;
j INTEGER;
n INTEGER;
var1 varchar;
	                
BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;
    
time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

DROP INDEX IF EXISTS pghydro.drn_nm_idx;

CREATE INDEX drn_nm_idx ON pghydro.pghft_drainage_line(drn_nm);

DROP INDEX IF EXISTS pghydro.tnc_pk_idx;

CREATE INDEX tnc_pk_idx ON pghydro.pghtb_type_name_complete(tnc_pk);

DROP TABLE IF EXISTS temp;

CREATE TABLE temp 
(
tmp_drn_pk integer,
tmp_tnc_pk integer,
tmp_drn_hdr_pk integer
);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

j := max(tnc_pk) FROM pghydro.pghtb_type_name_complete;

n :=0;

FOR i IN 1..j LOOP

var1 := tnc_ds
FROM pghydro.pghtb_type_name_complete
WHERE tnc_pk = i;

INSERT INTO temp(tmp_drn_pk, tmp_tnc_pk, tmp_drn_hdr_pk)

SELECT pghfn_hydronym_unique.drn_pk_ as drn_pk, i as tmp_tnc_pk, pghfn_hydronym_unique.class_+ n as drn_hdr_pk
FROM pghydro.pghfn_hydronym_unique(var1);

n := n + max(pghfn_hydronym_unique.class_)
FROM pghydro.pghfn_hydronym_unique(var1);

RAISE NOTICE 'NAME %/%', i, j;  

END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

TRUNCATE pghydro.pghft_hydronym;

DROP INDEX IF EXISTS pghydro.tnc_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_hdr_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_nm_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_hdr_pk_idx;

DROP INDEX IF EXISTS pghydro.hdr_pk_idx;

DROP INDEX IF EXISTS pghydro.tmp_drn_hdr_pk_idx;

UPDATE pghydro.pghft_drainage_line drn
SET drn_hdr_pk = null;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

CREATE INDEX tmp_drn_pk_idx ON temp(tmp_drn_pk);

UPDATE pghydro.pghft_drainage_line drn
SET drn_hdr_pk = tmp.tmp_drn_hdr_pk
FROM temp tmp
WHERE tmp.tmp_drn_pk = drn.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

CREATE INDEX drn_hdr_pk_idx ON pghydro.pghft_drainage_line(drn_hdr_pk);

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

INSERT INTO pghydro.pghft_hydronym (hdr_pk, hdr_gm)
SELECT drn_hdr_pk, ST_UNION(drn_gm) 
FROM pghydro.pghft_drainage_line
WHERE drn_hdr_pk is not null
GROUP BY drn_hdr_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

CREATE INDEX hdr_pk_idx ON pghydro.pghft_hydronym(hdr_pk);

CREATE INDEX tmp_drn_hdr_pk_idx ON temp(tmp_drn_hdr_pk);

UPDATE pghydro.pghft_hydronym hdr
SET hdr_tnc_pk = tmp.tmp_tnc_pk
FROM temp tmp
WHERE tmp.tmp_drn_hdr_pk = hdr.hdr_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_nu_distancetosea_idx;

CREATE INDEX drn_nu_distancetosea_idx ON pghydro.pghft_drainage_line(drn_nu_distancetosea);

UPDATE pghydro.pghft_hydronym hdr
SET hdr_nu_distancetosea = a.hdr_nu_distancetosea
FROM
(
SELECT drn_hdr_pk, min(drn_nu_distancetosea) as hdr_nu_distancetosea
FROM pghydro.pghft_drainage_line
GROUP BY drn_hdr_pk
) as a
WHERE a.drn_hdr_pk = hdr.hdr_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

UPDATE pghydro.pghft_hydronym hdr
SET hdr_gm_length = a.hdr_gm_length
FROM
(
SELECT drn_hdr_pk, sum(drn_gm_length) as hdr_gm_length
FROM pghydro.pghft_drainage_line
GROUP BY drn_hdr_pk
) as a
WHERE a.drn_hdr_pk = hdr.hdr_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_temp;

CREATE TABLE pghydro.pghtb_nm_hydronym_temp AS
SELECT drn_hdr_pk, drn_wtc_cd_pfafstetterwatercourse, min(drn_nu_distancetosea) as drn_nu_distancetosea_min, max(drn_nu_distancetosea) as drn_nu_distancetosea_max
FROM pghydro.pghft_drainage_line drn
WHERE drn_hdr_pk is not null
GROUP BY drn_hdr_pk, drn_wtc_cd_pfafstetterwatercourse
ORDER BY drn_wtc_cd_pfafstetterwatercourse, drn_nu_distancetosea_min;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_min;

CREATE TABLE pghydro.pghtb_nm_hydronym_min AS
SELECT a.drn_hdr_pk, a.drn_wtc_cd_pfafstetterwatercourse, a.drn_nu_distancetosea_min
FROM pghydro.pghtb_nm_hydronym_temp a,
(
SELECT drn_hdr_pk, min(drn_nu_distancetosea_min) as drn_nu_distancetosea_min
FROM pghydro.pghtb_nm_hydronym_temp
GROUP BY drn_hdr_pk
) as b
WHERE a.drn_hdr_pk = b.drn_hdr_pk
AND a.drn_nu_distancetosea_min = b.drn_nu_distancetosea_min
ORDER by a.drn_wtc_cd_pfafstetterwatercourse, a.drn_nu_distancetosea_min;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_max;

CREATE TABLE pghydro.pghtb_nm_hydronym_max AS
SELECT a.drn_hdr_pk, a.drn_wtc_cd_pfafstetterwatercourse, a.drn_nu_distancetosea_max
FROM pghydro.pghtb_nm_hydronym_temp a,
(
SELECT drn_hdr_pk, max(drn_nu_distancetosea_max) as drn_nu_distancetosea_max
FROM pghydro.pghtb_nm_hydronym_temp
GROUP BY drn_hdr_pk
) as b
WHERE a.drn_hdr_pk = b.drn_hdr_pk
AND a.drn_nu_distancetosea_max = b.drn_nu_distancetosea_max
ORDER by a.drn_wtc_cd_pfafstetterwatercourse, a.drn_nu_distancetosea_max;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_temp2;

CREATE TABLE pghydro.pghtb_nm_hydronym_temp2
(
  drn_hdr_pk integer,
  drn_wtc_cd_pfafstetterwatercourse_min varchar,
  drn_nu_distancetosea_min numeric,
  drn_wtc_cd_pfafstetterwatercourse_max varchar,
  drn_nu_distancetosea_max numeric
);

INSERT INTO pghydro.pghtb_nm_hydronym_temp2 
(
  drn_hdr_pk,
  drn_wtc_cd_pfafstetterwatercourse_min,
  drn_nu_distancetosea_min
)
SELECT
  drn_hdr_pk,
  drn_wtc_cd_pfafstetterwatercourse,
  drn_nu_distancetosea_min
FROM pghydro.pghtb_nm_hydronym_min;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;    

UPDATE pghydro.pghtb_nm_hydronym_temp2 a
SET drn_wtc_cd_pfafstetterwatercourse_max = b.drn_wtc_cd_pfafstetterwatercourse
FROM
(
SELECT drn_hdr_pk, drn_wtc_cd_pfafstetterwatercourse
FROM pghydro.pghtb_nm_hydronym_max
) as b
WHERE a.drn_hdr_pk = b.drn_hdr_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;    

UPDATE pghydro.pghtb_nm_hydronym_temp2 a
SET drn_nu_distancetosea_max = b.drn_nu_distancetosea_max
FROM
(
SELECT drn_hdr_pk, drn_nu_distancetosea_max
FROM pghydro.pghtb_nm_hydronym_max
) as b
WHERE a.drn_hdr_pk = b.drn_hdr_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;    

TRUNCATE pghydro.pghtb_nm_hydronym;

ALTER SEQUENCE pghydro.nhd_pk_seq RESTART WITH 1;

INSERT INTO pghydro.pghtb_nm_hydronym (nhd_drn_hdr_pk, nhd_drn_wtc_cd_pfafstetterwatercourse_min, nhd_drn_nu_distancetosea_min, nhd_drn_wtc_cd_pfafstetterwatercourse_max, nhd_drn_nu_distancetosea_max)
SELECT drn_hdr_pk, drn_wtc_cd_pfafstetterwatercourse_min, drn_nu_distancetosea_min, drn_wtc_cd_pfafstetterwatercourse_max, drn_nu_distancetosea_max 
FROM pghydro.pghtb_nm_hydronym_temp2
ORDER by drn_wtc_cd_pfafstetterwatercourse_min, drn_nu_distancetosea_min;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;    

UPDATE pghydro.pghtb_nm_hydronym
SET nhd_cd_nm = nhd_drn_wtc_cd_pfafstetterwatercourse_min||'_'||pghydro.pghfn_hydronym_pfastettercode(nhd_pk, nhd_drn_wtc_cd_pfafstetterwatercourse_min);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;    

UPDATE pghydro.pghft_hydronym hdr
SET hdr_cd = nhd.nhd_cd_nm
FROM pghydro.pghtb_nm_hydronym nhd
WHERE nhd.nhd_drn_hdr_pk = hdr.hdr_pk;

--time_ := timeofday();
--RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;    

--PERFORM pghydro.pghfn_DropTempSchema();

RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

---------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_DropTempSchema()
---------------------------------------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropTempSchema()
RETURNS varchar AS
$$

DECLARE

time_ timestamp;
	                
BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;
    
time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP TABLE IF EXISTS temp;

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_temp;

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_min;

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_max;

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym_temp2;

DROP TABLE IF EXISTS pghydro.pghtb_nm_complete;

DROP TABLE IF EXISTS pghydro.pghtb_nm_connection;

DROP TABLE IF EXISTS pghydro.pghtb_nm_generic;

DROP TABLE IF EXISTS pghydro.pghtb_nm_hydronym;

DROP TABLE IF EXISTS pghydro.pghtb_nm_specific;

DROP TABLE IF EXISTS pghydro.pghtb_nm_waterbodyoriginal;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_nm_idx;

DROP INDEX IF EXISTS pghydro.drn_nu_distancetosea_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN IF EXISTS drn_dra_cd_pfafstetterbasin;

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN IF EXISTS drn_wtc_cd_pfafstetterwatercourse;

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN IF EXISTS drn_wtc_gm_area;

UPDATE pghydro.pghft_drainage_line
SET drn_rcl_pk_hdr = null;

UPDATE pghydro.pghft_drainage_line
SET drn_rcl_pk_hdr = 13
WHERE drn_hdr_pk is not null;

--PERFORM pghydro.pghfn_turnoffkeysindex();

RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_ConfluenceHydronym()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ConfluenceHydronym()
RETURNS SETOF integer AS
$$

SELECT DISTINCT drn_drp_pk_targetnode as drp_pk
FROM
(
SELECT a.drn_drp_pk_targetnode
FROM pghydro.pghft_drainage_line a, pghydro.pghft_drainage_line b, pghydro.pghft_drainage_point c
WHERE a.drn_nm = b.drn_nm
AND a.drn_drn_pk_upstreamdrainageline = b.drn_pk
AND a.drn_drp_pk_targetnode = c.drp_pk
) as d;

$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numConfluenceHydronym()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numConfluenceHydronym()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM
(
SELECT pghydro.pghfn_ConfluenceHydronym() as drp_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_ConfluenceHydronymN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ConfluenceHydronymN(integer)
RETURNS integer AS
$$
SELECT drp_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drp_pk, drp_pk
FROM
(
SELECT pghydro.pghfn_ConfluenceHydronym() as drp_pk
) as a
) as b
WHERE seq_drp_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;
--COMMIT;