--
-- Copyright (c) 2016 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
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
--PgHydro version 6.2

---------------------------------------------------------------------------------
--Pfafstetter Consistency Extension Version 6.2 of 17/01/2018
---------------------------------------------------------------------------------

-------------------------------------
--CREATE SCHEMA, TABLES AND SEQUENCES
-------------------------------------

DROP SCHEMA IF EXISTS pgh_consistency CASCADE;

CREATE SCHEMA pgh_consistency;

-----------------------------
--CREATE CONSISTENCY TABLES
-----------------------------

CREATE TABLE pgh_consistency.pghft_drainageareaoverlapdrainagearea
(
  id bigint NOT NULL,
  int_pk bigint,
  editor bigint,
  dra_pk_a integer,
  dra_pk_b integer,
  cn01_gm geometry(MultiPolygon),
  dra_gm_a geometry(MultiPolygon),
  dra_gm_b geometry(MultiPolygon),
  area numeric,
  CONSTRAINT pghft_drainageareaoverlapdrainagearea_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainageareaisnotsimple
(
  id bigint NOT NULL,
  dra_pk integer,
  editor bigint,
  cn02_gm geometry(MultiPolygon),
  CONSTRAINT pghft_drainageareaisnotsimple_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainageareaisnotsingle
(
  id bigint NOT NULL,
  dra_pk integer,
  editor bigint,
  cn03_gm geometry(MultiPolygon),
  CONSTRAINT pghft_drainageareaisnotsingle_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainageareaisnotvalid
(
  id bigint NOT NULL,
  dra_pk integer,
  editor bigint,
  cn04_gm geometry(MultiPolygon),
  cn05_gm_point geometry(MultiPoint),
  CONSTRAINT pghft_drainageareaisnotvalid_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainageareamoreonedrainageline
(
  id bigint NOT NULL,
  dra_pk integer,
  editor bigint,
  cn06_gm geometry(MultiPolygon),
  CONSTRAINT pghft_drainageareamoreonedrainageline_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainageareanodrainageline
(
  id bigint NOT NULL,
  dra_pk integer,
  editor bigint,
  cn07_gm geometry(MultiPolygon),
  area numeric,
  CONSTRAINT pghft_drainageareanodrainageline_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainageareawithindrainagearea
(
  id bigint NOT NULL,
  dra_pk integer,
  editor bigint,
  cn08_gm geometry(MultiPolygon),
  area numeric,
  CONSTRAINT pghft_drainageareawithindrainagearea_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelinecrossdrainageline
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn09_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelinecrossdrainageline_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelinehaveselfintersection
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn10_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelinehaveselfintersection_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineisdisconnected
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn11_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelineisdisconnected_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineisnotsimple
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn12_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelineisnotsimple_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineisnotsingle
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn13_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelineisnotsingle_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineisnotvalid
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn14_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelineisnotvalid_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineisnotvalidpoint
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn15_gm_point geometry(MultiLineString),
  CONSTRAINT pghft_drainagelineisnotvalidpoint_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineloops
(
  id bigint NOT NULL,
  plg_pk integer,
  editor bigint,
  cn16_gm geometry(MultiPolygon),
  area numeric,
  CONSTRAINT pghft_drainagelineloops_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelinemoreonedrainagearea
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn17_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelinemoreonedrainagearea_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelinenodrainagearea
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn18_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelinenodrainagearea_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelineoverlapdrainageline
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn19_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelineoverlapdrainageline_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelinetouchdrainageline
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn20_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelinetouchdrainageline_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_drainagelinewithindrainageline
(
  id bigint NOT NULL,
  drn_pk integer,
  editor bigint,
  cn21_gm geometry(MultiLineString),
  CONSTRAINT pghft_drainagelinewithindrainageline_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_pointvalencevalue2
(
  id bigint NOT NULL,
  drp_pk integer,
  editor bigint,
  cn22_gm geometry(MultiPoint),
  CONSTRAINT pghft_pointvalencevalue2_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_pointvalencevalue4
(
  id bigint NOT NULL,
  drp_pk integer,
  editor bigint,
  cn23_gm geometry(MultiPoint),
  CONSTRAINT pghft_pointvalencevalue4_pkey PRIMARY KEY (id)
);

CREATE TABLE pgh_consistency.pghft_pointdivergent
(
  id bigint NOT NULL,
  drp_pk integer,
  editor bigint,
  cn24_gm geometry(MultiPoint),
  CONSTRAINT pghft_pointdivergent_pkey PRIMARY KEY (id)
);

-------------------------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_SplitDrainagelineMultipoint(input_geom geometry, blade geometry)
-------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_SplitDrainagelineMultipoint(input_geom geometry, blade geometry)
  RETURNS geometry AS
$$
    -- this function is a wrapper around the function ST_Split 
    -- to allow splitting multilines with multipoints
    --
    DECLARE
        result geometry;
        simple_blade geometry;
        blade_geometry_type text := GeometryType(blade);
        geom_geometry_type text := GeometryType(input_geom);
    BEGIN
        IF blade_geometry_type NOT ILIKE 'MULTI%' THEN
            RETURN ST_Split(input_geom, blade);
        ELSIF blade_geometry_type NOT ILIKE '%POINT' THEN
            RAISE NOTICE 'Need a Point/MultiPoint blade';
            RETURN NULL;
        END IF;

        IF geom_geometry_type NOT ILIKE '%LINESTRING' THEN
            RAISE NOTICE 'Need a LineString/MultiLineString input_geom';
            RETURN NULL;
        END IF;

        result := input_geom;           
        -- Loop on all the points in the blade
        FOR simple_blade IN SELECT (ST_Dump(ST_CollectionExtract(blade, 1))).geom
        LOOP
            -- keep splitting the previous result
            result := ST_CollectionExtract(ST_Split(result, simple_blade), 2);
        END LOOP;
        RETURN result;
    END;
$$
LANGUAGE PLPGSQL;

---------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_MakeSnapToGridDrainageLine(numeric)
---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_MakeSnapToGridDrainageLine(numeric)
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_line
SET drn_gm = ST_SNAPTOGRID(drn_gm, $1);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_MakeSnapToGridDrainageLine(0.000000000001);

-------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveReapetedPointsDrainageLine()
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_RemoveReapetedPointsDrainageLine()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_line
SET drn_gm = ST_RemoveRepeatedPoints(drn_gm);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_RemoveReapetedPointsDrainageLine();

-------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_CreateDrainageLineVertexIntersections(numeric)
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_CreateDrainageLineVertexIntersections(numeric)
RETURNS character varying AS
$$
DECLARE 

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

--Create Vertex on intersection lines

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_gm = ST_MULTI(ST_SNAP(drn.drn_gm, a.drp_gm, $1))
FROM
(
SELECT drn_pk_a, ST_MULTI(ST_UNION(drp_gm)) as drp_gm
FROM
(
SELECT a.drn_pk as drn_pk_a, b.drn_pk as drn_pk_b, ST_INTERSECTION(a.drn_gm, b.drn_gm) as drp_gm --row_number() over() 
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND
ST_Relate(a.drn_gm, b.drn_gm) IN (
--TOUCH
'F01FF0102',
'F010F0102',
--'FF1F00102',
'F01FF01F2',
'F010F01F2',
'F01F001F2',
'F010FF1F2',
--'FF1F0F1F2',
'F0100F1F2',
--CROSS
'0F1FF0102',
'0010F0102',
'0F1F00102',
'001FF0102',
'0010F01F2',
'001F001F2',
'001FF01F2',
'0F1F0F1F2',
'00100F1F2',
'0010FF1F2'
)
) as a
GROUP BY drn_pk_a
) as a
WHERE a.drn_pk_a = drn.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_CreateDrainageLineVertexIntersections(0.000000000001);

----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_BreakDrainageLine()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_BreakDrainageLine()
RETURNS character varying AS
$$
DECLARE 

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

--Break Lines

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_gm = pgh_consistency.pghfn_SplitDrainagelineMultipoint(drn.drn_gm, a.drp_gm)
FROM
(
SELECT drn_pk_a, ST_MULTI(ST_UNION(drp_gm)) as drp_gm
FROM
(
SELECT a.drn_pk as drn_pk_a, b.drn_pk as drn_pk_b, ST_INTERSECTION(a.drn_gm, b.drn_gm) as drp_gm --row_number() over() 
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND
(
ST_Relate(a.drn_gm, b.drn_gm) IN (
--TOUCH
'F01FF0102',
'F010F0102',
--'FF1F00102',
'F01FF01F2',
'F010F01F2',
'F01F001F2',
'F010FF1F2',
--'FF1F0F1F2',
'F0100F1F2',
--CROSS
'0F1FF0102',
'0010F0102',
'0F1F00102',
'001FF0102',
'0010F01F2',
'001F001F2',
'001FF01F2',
'0F1F0F1F2',
'00100F1F2',
'0010FF1F2'
)
)
) as a
GROUP BY drn_pk_a
) as a
WHERE a.drn_pk_a = drn.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_BreakDrainageLine();

--SELECT pgh_consistency.pghfn_ExplodeDrainageLine();

--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_MakeSnapToGridDrainageArea(numeric)
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_MakeSnapToGridDrainageArea(numeric)
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_area
SET dra_gm = ST_SNAPTOGRID(dra_gm, $1);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_MakeSnapToGridDrainageArea(numeric);

-------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveReapetedPointsDrainageArea()
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_RemoveReapetedPointsDrainageArea()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_area
SET dra_gm = ST_RemoveRepeatedPoints(dra_gm);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_RemoveReapetedPointsDrainageArea();

---------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_MakeDrainageAreaSimple()
---------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_MakeDrainageAreaSimple()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_area
SET dra_gm = st_multi(st_buildarea(st_union(st_multi(st_boundary(dra_gm)),st_pointn(st_boundary(dra_gm),1))))
WHERE ST_IsSimple(dra_gm) = 'f';

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_MakeDrainageAreaSimple();

--------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_MakeDrainageAreaValid()
--------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_MakeDrainageAreaValid()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_area
SET dra_gm = ST_CollectionExtract(ST_MakeValid(dra_gm),3)
WHERE ST_IsValid(dra_gm) = false;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_MakeDrainageAreaValid();

------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveDrainageAreaInteriorRings()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_RemoveDrainageAreaInteriorRings()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_area
SET dra_gm = ST_Multi(ST_MakePolygon(ST_ExteriorRing((ST_Dump(dra_gm)).geom)))
WHERE ST_NumInteriorRings(dra_gm) > 0;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_RemoveDrainageAreaInteriorRings();

--------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveWatershedInteriorRings()
--------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_RemoveWatershedInteriorRings()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_watershed
SET wts_gm = ST_Multi(ST_MakePolygon(ST_ExteriorRing((ST_Dump(wts_gm)).geom)))
WHERE ST_NumInteriorRings(wts_gm) > 0;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_RemoveWatershedInteriorRings();

------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_ExplodeDrainageArea()
------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_ExplodeDrainageArea()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.sqc;
   
CREATE SEQUENCE pghydro.sqc;

PERFORM setval(('pghydro.sqc'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(dra_pk)+1 as nextval
FROM pghydro.pghft_drainage_area
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghft_drainage_area_temp;

CREATE TABLE pghydro.pghft_drainage_area_temp
AS SELECT dra_gm 
FROM
(
SELECT (ST_Dump(dra_gm)).geom AS dra_gm
FROM
(

SELECT (pghfn_DrainageAreaIsNotSingle).dra_gm_ as dra_gm
FROM pgh_consistency.pghfn_DrainageAreaIsNotSingle()

) as b
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

ALTER TABLE pghydro.pghft_drainage_area_temp
ADD COLUMN dra_pk INTEGER PRIMARY KEY DEFAULT nextval('pghydro.sqc');

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

DELETE FROM pghydro.pghft_drainage_area
WHERE dra_pk in
(
SELECT dra_pk
FROM
(

SELECT (pghfn_DrainageAreaIsNotSingle).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaIsNotSingle()

) as b
);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

INSERT INTO pghydro.pghft_drainage_area (dra_pk, dra_gm)
SELECT dra_pk, ST_Multi(dra_gm)
FROM pghydro.pghft_drainage_area_temp;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghft_drainage_area_temp;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP SEQUENCE IF EXISTS pghydro.sqc;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_ExplodeDrainageArea();

-----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveInteriorRingDrainageArea()
-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_RemoveInteriorRingDrainageArea()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_area
SET dra_gm = ST_Multi(ST_MakePolygon(ST_ExteriorRing((ST_Dump(dra_gm)).geom)));

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_RemoveInteriorRingDrainageArea();

----------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineIsNotSingle()
----------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineIsNotSingle()
RETURNS TABLE(drn_pk_ integer, drn_nm_ character varying, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_nm, drn_gm
FROM pghydro.pghft_drainage_line
WHERE ST_NumGeometries(drn_gm) > 1;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineIsNotSingle()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineIsNotSingle()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineIsNotSingle).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsNotSingle()
) as a;
$$
LANGUAGE SQL;


------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_ExplodeDrainageLine()
------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_ExplodeDrainageLine()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

DROP SEQUENCE IF EXISTS pghydro.sqc;

CREATE SEQUENCE pghydro.sqc;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

PERFORM setval(('pghydro.sqc'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(drn_pk)+1 as nextval
FROM pghydro.pghft_drainage_line
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghft_drainage_line_temp;

CREATE TABLE pghydro.pghft_drainage_line_temp
AS SELECT drn_nm, drn_gm 
FROM
(
SELECT drn_nm, (ST_Dump(drn_gm)).geom AS drn_gm
FROM
(
SELECT (pghfn_DrainageLineIsNotSingle).drn_nm_ as drn_nm, (pghfn_DrainageLineIsNotSingle).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineIsNotSingle()
) as b
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

ALTER TABLE pghydro.pghft_drainage_line_temp
ADD COLUMN drn_pk INTEGER PRIMARY KEY DEFAULT nextval('pghydro.sqc');

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

DELETE FROM pghydro.pghft_drainage_line
WHERE drn_pk in
(
SELECT drn_pk
FROM
(
SELECT (pghfn_DrainageLineIsNotSingle).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsNotSingle()
) as b
);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

INSERT INTO pghydro.pghft_drainage_line (drn_pk, drn_nm, drn_gm)
SELECT drn_pk, drn_nm, ST_Multi(drn_gm)
FROM pghydro.pghft_drainage_line_temp;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP TABLE pghydro.pghft_drainage_line_temp;

DROP SEQUENCE pghydro.sqc;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

PERFORM setval(('pghydro.drn_pk_seq'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(drn_pk)+1 as nextval
FROM pghydro.pghft_drainage_line
) as a;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineIsNotSimple()
----------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineIsNotSimple()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE ST_IsSimple(drn_gm) <> 't';

RETURN;

END;
$$
LANGUAGE PLPGSQL;

-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineIsNotSimple()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineIsNotSimple()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineIsNotSimple).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsNotSimple()
) as a;
$$
LANGUAGE SQL;

---------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_MakeDrainageLineSimple()
---------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_MakeDrainageLineSimple()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_line drn
SET drn_gm = st_multi(st_union(drn.drn_gm,st_pointN(st_geometryN(drn.drn_gm, 1), 1)))
FROM
(
SELECT (pghfn_DrainageLineIsNotSimple).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsNotSimple()
) as a
WHERE a.drn_pk = drn.drn_pk;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_MakeDrainageLineSimple();

---------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineIsNotValid()
---------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineIsNotValid()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry, drn_gm_point_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm, location(ST_IsValidDetail(drn_gm)) as drn_gm_point
FROM pghydro.pghft_drainage_line
WHERE ST_IsValidReason(drn_gm) <> 'Valid Geometry';

RETURN;

END;
$$
LANGUAGE PLPGSQL;


------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineIsNotValid()
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineIsNotValid()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineIsNotValid).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsNotValid()
) as a;
$$
LANGUAGE SQL;


--------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_MakeDrainageLineValid()
--------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_MakeDrainageLineValid()
RETURNS character varying AS
$$
BEGIN

UPDATE pghydro.pghft_drainage_line drn
SET drn_gm = ST_CollectionExtract(ST_MakeValid(drn.drn_gm),2)
FROM
(
SELECT (pghfn_DrainageLineIsNotValid).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsNotValid()
) as a
WHERE a.drn_pk = drn.drn_pk;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_MakeDrainageLineValid();

-------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineHaveSelfIntersection()
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineHaveSelfIntersection()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM
(
WITH auto_intersect AS (
SELECT a.drn_pk as drn_pk_a, b.drn_pk as drn_pk_b, a.drn_gm as drn_gm_a, b.drn_gm as drn_gm_b 
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND
ST_Relate(a.drn_gm, b.drn_gm) IN (
--TOUCH
'F01FF0102',
'F010F0102',
--'FF1F00102',
'F01FF01F2',
'F010F01F2',
'F01F001F2',
'F010FF1F2',
--'FF1F0F1F2',
'F0100F1F2',
--CROSS
'0F1FF0102',
'0010F0102',
'0F1F00102',
'001FF0102',
'0010F01F2',
'001F001F2',
'001FF01F2',
'0F1F0F1F2',
'00100F1F2',
'0010FF1F2',
--OVERLAP
'1F1FF0102',
'1010F0102',
'1F1F00102',
'1F10F0102',
'1010FF102',
'1F100F102',
'1F10FF102',
'1F1F0F1F2',
'10100F1F2',
'1010FF1F2',
--WITHIN
'1FF00F102',
'1FF0FF102'
--'1FFF0FFF2'
)
)
SELECT drn_pk_a as drn_pk, drn_gm_a as drn_gm
FROM auto_intersect aut
UNION ALL
SELECT drn_pk_b as drn_pk, drn_gm_b as drn_gm
FROM auto_intersect aut
) as a;


RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DrainageLineHaveSelfIntersection()

----------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineHaveSelfIntersection()
----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineHaveSelfIntersection()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineHaveSelfIntersection).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineHaveSelfIntersection()
) as a;
$$
LANGUAGE SQL;


--SELECT pgh_consistency.pghfn_numDrainageLineHaveSelfIntersection();

-----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineWithinDrainageLine()
-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineWithinDrainageLine()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT a.drn_pk, a.drn_gm
FROM pghydro.pghft_drainage_line a, pghydro.pghft_drainage_line b
WHERE ST_RELATE(a.drn_gm, b.drn_gm) IN
(
'1FF00F102',
'1FF0FF102'
--'1FFF0FFF2'
)
AND (a.drn_gm && b.drn_gm)

UNION ALL

SELECT a.drn_pk, a.drn_gm
FROM pghydro.pghft_drainage_line a, pghydro.pghft_drainage_line b
WHERE ST_RELATE(a.drn_gm, b.drn_gm) IN
(
--'1FF00F102',
--'1FF0FF102',
'1FFF0FFF2'
)
AND (a.drn_gm && b.drn_gm)
AND a.drn_pk <> b.drn_pk
AND a.drn_pk < b.drn_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DrainageLineWithinDrainageLine()

--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineWithinDrainageLine()
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineWithinDrainageLine()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineWithinDrainageLine).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineWithinDrainageLine()
) as b;
$$
LANGUAGE SQL;


-----------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DeleteDrainageLineWithinDrainageLine()
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DeleteDrainageLineWithinDrainageLine()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

DELETE FROM pghydro.pghft_drainage_line
WHERE drn_pk IN
(
SELECT drn_pk 
FROM pgh_consistency.pghft_drainagelinewithindrainageline
);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DeleteDrainageLineWithinDrainageLine();

----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineLoops()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineLoops()
RETURNS TABLE(plg_pk_ integer, plg_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY


SELECT (ROW_NUMBER() OVER ())::integer AS plg_pk, clp_gm as plg_gm
FROM
(
SELECT drn_pk, ST_MULTI((ST_Dump(b.plg_gm)).geom) as clp_gm
FROM
(
SELECT max(drn_pk) as drn_pk, ST_Polygonize(drn_gm) as plg_gm
FROM
(
SELECT drn_pk, (st_dump(drn_gm)).geom AS drn_gm
FROM pghydro.pghft_drainage_line
) as a
) as b
) as c;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


--------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineLoops()
--------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineLoops()
RETURNS bigint AS
$$
SELECT count(plg_pk)
FROM
(
SELECT (pghfn_DrainageLineLoops).plg_pk_ as plg_pk
FROM pgh_consistency.pghfn_DrainageLineLoops()
) as c;
$$
LANGUAGE SQL;


----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineHaveGeometryEmpty()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineHaveGeometryEmpty()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE drn_gm is null
OR ST_IsEmpty(drn_gm) = true
OR ST_length(drn_gm) = 0;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


--SELECT pgh_consistency.pghfn_DrainageLineHaveGeometryEmpty()

-------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineHaveGeometryEmpty()
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineHaveGeometryEmpty()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineHaveGeometryEmpty).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineHaveGeometryEmpty()
) as b;
$$
LANGUAGE SQL;


------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DeleteDrainageLineGeometryEmpty()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DeleteDrainageLineGeometryEmpty()
RETURNS character varying AS
$$
BEGIN

DELETE FROM pghydro.pghft_drainage_line
WHERE drn_pk in
(
SELECT drn_pk
FROM
(
SELECT (pghfn_DrainageLineHaveGeometryEmpty).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineHaveGeometryEmpty()
) as b
);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_PointValenceValue2()
-----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_PointValenceValue2()
RETURNS TABLE(drp_pk_ integer, drp_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drp_pk, ST_MULTI(drp_gm) as drp_gm
FROM pghydro.pghft_drainage_point
WHERE drp_nu_valence = 2;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


--------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numPointValenceValue2()
--------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numPointValenceValue2()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM 
(
SELECT (pghfn_PointValenceValue2).drp_pk_ as drp_pk
FROM pgh_consistency.pghfn_PointValenceValue2()
) as a;
$$
LANGUAGE SQL;


-----------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_unionDrainageLine(integer)
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_unionDrainageLine(integer)
RETURNS character varying AS
$$
DECLARE

time_ timestamp;

BEGIN

INSERT INTO pghydro.pghft_drainage_line (drn_gm)
SELECT ST_Multi(ST_LineMerge(ST_Union(a.drn_gm))) as drn_gm
FROM
(
SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_targetnode = $1
OR drn_drp_pk_sourcenode = $1
) as a;

DELETE
FROM pghydro.pghft_drainage_line
WHERE drn_pk in
(
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_targetnode = $1
OR drn_drp_pk_sourcenode = $1
);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;


--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_unionDrainageLine(integer, integer)
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_unionDrainageLine(integer, integer)
RETURNS character varying AS
$$
DECLARE

time_ timestamp;

BEGIN

INSERT INTO pghydro.pghft_drainage_line (drn_gm)
SELECT ST_Multi(ST_LineMerge(ST_Union(a.drn_gm))) as drn_gm
FROM
(
SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE drn_pk = $1
OR drn_pk = $2
) as a;

DELETE
FROM pghydro.pghft_drainage_line
WHERE drn_pk in
(
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_pk = $1
OR drn_pk = $2
);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;


------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_unionDrainageLinevalence2()
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_unionDrainageLinevalence2()
RETURNS varchar AS
$$
DECLARE

_r record;
time_ timestamp;
max_pseudo_node integer;
i integer;

BEGIN

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

CREATE INDEX drp_nu_valence_idx ON pghydro.pghft_drainage_point(drp_nu_valence);

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

SELECT INTO max_pseudo_node count(drp_pk) FROM pghydro.pghft_drainage_point WHERE drp_nu_valence = 2;

i := 1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;


    FOR _r IN SELECT drp_pk FROM pghydro.pghft_drainage_point WHERE drp_nu_valence = 2
    
    LOOP

	PERFORM pgh_consistency.pghfn_unionDrainageLine(_r.drp_pk);
   
    RAISE NOTICE 'PSEUDO-NODE %/%', i, max_pseudo_node;    

    i := i + 1;

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DELETE FROM pghydro.pghft_drainage_line
WHERE drn_gm is null;
    
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;


-----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_PointValenceValue4()
-----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_PointValenceValue4()
RETURNS TABLE(drp_pk_ integer, drp_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drp_pk, ST_MULTI(drp_gm) as drp_gm
FROM pghydro.pghft_drainage_point
WHERE drp_nu_valence = 4;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


--------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numPointValenceValue4()
--------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numPointValenceValue4()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM 
(
SELECT (pghfn_PointValenceValue4).drp_pk_ as drp_pk
FROM pgh_consistency.pghfn_PointValenceValue4()
) as a;
$$
LANGUAGE SQL;

-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineIsDisconnected()
-------------------------------------------------------------

CREATE OR REPLACE  FUNCTION pgh_consistency.pghfn_DrainageLineIsDisconnected()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE drn_bo_flowdirection is null;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineIsDisconnected()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineIsDisconnected()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM 
(
SELECT (pghfn_DrainageLineIsDisconnected).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineIsDisconnected()
) as a;
$$
LANGUAGE SQL;

-------------------------------------------------
--FUNCTION pgh_consistency.pghfn_PointDivergent()
-------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_PointDivergent()
RETURNS TABLE(drp_pk_ integer, drp_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT a.drp_pk, ST_MULTI(drp.drp_gm) as drp_gm
FROM
(
SELECT drn_drp_pk_targetnode as drp_pk
FROM 
(
SELECT drn_drp_pk_targetnode, count(drn_drp_pk_targetnode)
FROM
(
SELECT drn_drp_pk_targetnode, drn_drp_pk_sourcenode
FROM pghydro.pghft_drainage_line
) as a
GROUP BY drn_drp_pk_targetnode
HAVING count(drn_drp_pk_targetnode) = 1
) as b, pghydro.pghft_shoreline_ending_point as c
WHERE c.sep_drp_pk <> b.drn_drp_pk_targetnode
) as a, pghydro.pghft_drainage_point drp
WHERE a.drp_pk = drp.drp_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numPointDivergent()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numPointDivergent()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM 
(
SELECT (pghfn_PointDivergent).drp_pk_ as drp_pk
FROM pgh_consistency.pghfn_PointDivergent()
) as a;
$$
LANGUAGE SQL;

----------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaIsNotSingle()
----------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaIsNotSingle()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE ST_NumGeometries(dra_gm) > 1;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaIsNotSingle()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaIsNotSingle()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaIsNotSingle).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaIsNotSingle()
) as a;
$$
LANGUAGE SQL;


----------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaIsNotSimple()
----------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaIsNotSimple()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE ST_IsSimple(dra_gm) <> 't';

RETURN;

END;
$$
LANGUAGE PLPGSQL;


-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaIsNotSimple()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaIsNotSimple()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaIsNotSimple).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaIsNotSimple()
) as a;
$$
LANGUAGE SQL;


---------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaIsNotValid()
---------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaIsNotValid()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry, dra_gm_point_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT dra_pk, dra_gm, ST_MULTI(ST_SETSRID(location(ST_IsValidDetail(dra_gm)), ST_SRID(dra_gm))) as dra_gm_point
FROM pghydro.pghft_drainage_area
WHERE ST_IsValidReason(dra_gm) <> 'Valid Geometry';

RETURN;

END;
$$
LANGUAGE PLPGSQL;


------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaIsNotValid()
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaIsNotValid()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaIsNotValid).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaIsNotValid()
) as a;
$$
LANGUAGE SQL;


------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaOverlapDrainageArea()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaOverlapDrainageArea()
RETURNS TABLE(int_pk_ bigint, dra_pk_a_ integer, dra_pk_b_ integer, dra_gm_a_ geometry, dra_gm_b_ geometry, int_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT row_number() over() as int_pk, dra_pk_a, dra_pk_b, dra_gm_a, dra_gm_b, int_gm
FROM
(
SELECT a.dra_pk as dra_pk_a, b.dra_pk as dra_pk_b, a.dra_gm as dra_gm_a, b.dra_gm as dra_gm_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as int_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_OVERLAPS(a.dra_gm, b.dra_gm) = true
AND a.dra_pk < b.dra_pk
) as a
WHERE st_geometrytype(int_gm) = 'ST_MultiPolygon';

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DrainageAreaOverlapDrainageArea();

---------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaOverlapDrainageArea()
---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaOverlapDrainageArea()
RETURNS bigint AS
$$
SELECT count(int_pk)
FROM
(
SELECT (pghfn_DrainageAreaOverlapDrainageArea).int_pk_ as int_pk
FROM pgh_consistency.pghfn_DrainageAreaOverlapDrainageArea()
) as a;
$$
LANGUAGE SQL;


--SELECT pgh_consistency.pghfn_numDrainageAreaOverlapDrainageArea();

------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveDrainageAreaOverlap()
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_RemoveDrainageAreaOverlap()
RETURNS character varying AS
$$
DECLARE

_r record;
time_ timestamp;
max_id integer;
i integer;

BEGIN

SELECT INTO max_id count(id) FROM pgh_consistency.pghft_drainageareaoverlapdrainagearea;

i := 1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

    FOR _r IN SELECT id FROM pgh_consistency.pghft_drainageareaoverlapdrainagearea
    
    LOOP

	PERFORM pgh_consistency.pghfn_removedrainageareaoverlaps(_r.id::integer);
   
    RAISE NOTICE 'Overlap %/%', i, max_id;    

    i := i + 1;

    END LOOP;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_RemoveDrainageAreaOverlap();

-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_RemoveDrainageAreaOverlaps()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_removedrainageareaoverlaps(integer)
RETURNS void AS
$$
DECLARE

BEGIN

UPDATE pghydro.pghft_drainage_area dra
SET dra_gm = ST_MULTI(ST_CollectionExtract(ST_Difference(dra.dra_gm, a.dra_gm), 3))
FROM
(
SELECT dra_pk_a, dra_gm_b as dra_gm
FROM pgh_consistency.pghft_drainageareaoverlapdrainagearea
WHERE id = $1
) as a
WHERE a.dra_pk_a = dra.dra_pk;

END;
$$
LANGUAGE PLPGSQL;

-----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaWithinDrainageArea()
-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaWithinDrainageArea()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT a.dra_pk, a.dra_gm
FROM pghydro.pghft_drainage_area a, pghydro.pghft_drainage_area b
WHERE ST_RELATE(a.dra_gm, b.dra_gm) IN
(
--WITHIN
'2FF11F212',
'2FF10F212',
'2FF1FF212'
--'2FFF1FFF2'
)
AND (a.dra_gm && b.dra_gm)

UNION ALL

SELECT a.dra_pk, a.dra_gm
FROM pghydro.pghft_drainage_area a, pghydro.pghft_drainage_area b
WHERE ST_RELATE(a.dra_gm, b.dra_gm) IN
(
--WITHIN
--'2FF11F212',
--'2FF10F212',
--'2FF1FF212',
'2FFF1FFF2'
)
AND (a.dra_gm && b.dra_gm)
AND a.dra_pk <> b.dra_pk
AND a.dra_pk < b.dra_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaWithinDrainageArea()
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaWithinDrainageArea()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaWithinDrainageArea).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaWithinDrainageArea()
) as b;
$$
LANGUAGE SQL;


-----------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DeleteDrainageAreaWithinDrainageArea()
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DeleteDrainageAreaWithinDrainageArea()
RETURNS character varying AS
$$
BEGIN

DELETE FROM pghydro.pghft_drainage_area
WHERE dra_pk IN
(
SELECT dra_pk 
FROM pgh_consistency.pghft_drainageareawithindrainagearea
);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DeleteDrainageAreaWithinDrainageArea();

----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaHaveGeometryEmpty()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaHaveGeometryEmpty()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE dra_gm is null
OR ST_IsEmpty(dra_gm) = true
OR ST_AREA(dra_gm) = 0;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


-------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaHaveGeometryEmpty()
-------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaHaveGeometryEmpty()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaHaveGeometryEmpty).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaHaveGeometryEmpty()
) as b;
$$
LANGUAGE SQL;


------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DeleteDrainageAreaGeometryEmpty()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DeleteDrainageAreaGeometryEmpty()
RETURNS character varying AS
$$
BEGIN

DELETE FROM pghydro.pghft_drainage_area
WHERE dra_pk in
(
SELECT dra_pk
FROM
(
SELECT (pghfn_DrainageAreaHaveGeometryEmpty).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaHaveGeometryEmpty()
) as b
);

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaNoDrainageLine()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaNoDrainageLine()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT hin.hin_dra_pk as dra_pk, dra.dra_gm as dra_gm
FROM pghydro.pghft_hydro_intel hin, pghydro.pghft_drainage_area dra
WHERE hin.hin_drn_pk isnull
AND hin.hin_dra_pk = dra.dra_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaNoDrainageLine()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaNoDrainageLine()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaNoDrainageLine).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaNoDrainageLine()
) as a;
$$
LANGUAGE SQL;


-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineNoDrainageArea()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineNoDrainageArea()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT hin.hin_drn_pk as drn_pk, drn.drn_gm as drn_gm
FROM pghydro.pghft_hydro_intel hin, pghydro.pghft_drainage_line drn
WHERE hin.hin_dra_pk isnull
AND hin.hin_drn_pk = drn.drn_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineNoDrainageArea()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineNoDrainageArea()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineNoDrainageArea).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineNoDrainageArea()
) as a;
$$
LANGUAGE SQL;


------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageAreaMoreOneDrainageLine()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageAreaMoreOneDrainageLine()
RETURNS TABLE(dra_pk_ integer, dra_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT hin.hin_dra_pk as dra_pk, dra.dra_gm as dra_gm
FROM pghydro.pghft_hydro_intel hin, pghydro.pghft_drainage_area dra
WHERE hin.hin_count_dra_pk >=2
AND hin.hin_dra_pk = dra.dra_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


---------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageAreaMoreOneDrainageLine()
---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageAreaMoreOneDrainageLine()
RETURNS bigint
AS
$$

SELECT count(dra_pk)
FROM
(
SELECT (pghfn_DrainageAreaMoreOneDrainageLine).dra_pk_ as dra_pk
FROM pgh_consistency.pghfn_DrainageAreaMoreOneDrainageLine()
) as a;

$$
LANGUAGE SQL;


------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineMoreOneDrainageArea()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineMoreOneDrainageArea()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT hin.hin_drn_pk as drn_pk, drn.drn_gm as drn_gm
FROM pghydro.pghft_hydro_intel hin, pghydro.pghft_drainage_line drn
WHERE hin.hin_count_drn_pk >=2
AND hin.hin_drn_pk = drn.drn_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;


---------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineMoreOneDrainageArea()
---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineMoreOneDrainageArea()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineMoreOneDrainageArea).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineMoreOneDrainageArea()
) as a;
$$
LANGUAGE SQL;


---------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_FillGapsInDrainageArea()
---------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_FillGapsInDrainageArea()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP TABLE IF EXISTS pgh_consistency.temp_union_drainage_area;

CREATE TABLE pgh_consistency.temp_union_drainage_area as
SELECT ST_MemUnion(dra_gm) as geom
FROM pghydro.pghft_drainage_area;

INSERT INTO pghydro.pghft_drainage_area(dra_gm)
SELECT ST_MULTI(geom)
FROM
(
SELECT path(ST_DumpRings(st_geometryn(geom,1))), (ST_DumpRings(st_geometryn(geom,1))).geom
FROM pgh_consistency.temp_union_drainage_area
) as a
WHERE a.path[1] > 0;

DROP TABLE IF EXISTS pgh_consistency.temp_union_drainage_area;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UnionDrainageArea(integer, integer)
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UnionDrainageArea(integer, integer)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

INSERT INTO pghydro.pghft_drainage_area (dra_gm)
SELECT ST_Multi(ST_Union(a.dra_gm)) as dra_gm
FROM
(
SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE dra_pk = $1
OR dra_pk = $2
) as a;

DELETE
FROM pghydro.pghft_drainage_area
WHERE dra_pk in
(
SELECT dra_pk
FROM pghydro.pghft_drainage_area
WHERE dra_pk = $1
OR dra_pk = $2
);

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK - RUN AGAIN THE FUNCTION pghydro.pghfn_AssociationDrainageLine_DrainageArea()';

END;
$$
LANGUAGE PLPGSQL;


------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_uniondrainageareanodrainageline()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_uniondrainageareanodrainageline()
RETURNS varchar AS
$$
DECLARE
_r record;
time_ timestamp;
numdrainageareanodrainageline integer;
i integer;

BEGIN

PERFORM setval(('pghydro.dra_pk_seq'::text)::regclass, a.nextval, false)
FROM
(
SELECT max(dra_pk)+1 as nextval
FROM pghydro.pghft_drainage_area
) as a;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_gm_idx;

CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING GIST(dra_gm);

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

SELECT INTO numdrainageareanodrainageline pgh_consistency.pghfn_numdrainageareanodrainageline();

i := 1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;


    FOR _r IN

    WITH a AS
    (
    SELECT b.dra_pk, dra.dra_pk as dra_pk_touch, ST_LENGTH(ST_INTERSECTION(b.dra_gm, dra.dra_gm)) as length
    FROM
    (
    SELECT a.dra_pk, dra.dra_gm
    FROM pghydro.pghft_drainage_area dra, (SELECT(pghfn_drainageareanodrainageline).dra_pk_ as dra_pk FROM pgh_consistency.pghfn_drainageareanodrainageline()) as a
    WHERE dra.dra_pk = a.dra_pk
    ) as b, pghydro.pghft_drainage_area as dra
    WHERE ST_TOUCHES(b.dra_gm, dra.dra_gm)
    AND (b.dra_gm && dra.dra_gm)
    )
    SELECT a.dra_pk, a.dra_pk_touch
    FROM a, (SELECT dra_pk, max(length) as max_length FROM a GROUP BY dra_pk) as b
    WHERE a.length = max_length
    AND a.dra_pk = b.dra_pk
    ORDER BY a.dra_pk
    
    LOOP

	PERFORM pgh_consistency.pghfn_UnionDrainageArea(_r.dra_pk, _r.dra_pk_touch);
   
    RAISE NOTICE 'DRAINAGE AREA NO DRAINAGE LINE %/%', i, numdrainageareanodrainageline;    

    i := i + 1;

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_gm_idx;

DELETE FROM pghydro.pghft_drainage_area
WHERE dra_gm is null;
    
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineTouchDrainageLine()
-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineTouchDrainageLine()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM
(
WITH auto_intersect AS (
SELECT a.drn_pk as drn_pk_a, b.drn_pk as drn_pk_b, a.drn_gm as drn_gm_a, b.drn_gm as drn_gm_b 
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND
ST_Relate(a.drn_gm, b.drn_gm) IN (
--TOUCH
'F01FF0102',
'F010F0102',
--'FF1F00102',
'F01FF01F2',
'F010F01F2',
'F01F001F2',
'F010FF1F2',
--'FF1F0F1F2',
'F0100F1F2'
)
)
SELECT drn_pk_a as drn_pk, drn_gm_a as drn_gm
FROM auto_intersect aut
UNION ALL
SELECT drn_pk_b as drn_pk, drn_gm_b as drn_gm
FROM auto_intersect aut
) as a;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DrainageLineTouchDrainageLine()

--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineTouchDrainageLine()
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineTouchDrainageLine()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineTouchDrainageLine).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineTouchDrainageLine()
) as b;
$$
LANGUAGE SQL;


--SELECT pgh_consistency.pghfn_numDrainageLineTouchDrainageLine();

-----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineCrossDrainageLine()
-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineCrossDrainageLine()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM
(
WITH auto_intersect AS (
SELECT a.drn_pk as drn_pk_a, b.drn_pk as drn_pk_b, a.drn_gm as drn_gm_a, b.drn_gm as drn_gm_b 
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND
ST_Relate(a.drn_gm, b.drn_gm) IN (
--CROSS
'0F1FF0102',
'0010F0102',
'0F1F00102',
'001FF0102',
'0010F01F2',
'001F001F2',
'001FF01F2',
'0F1F0F1F2',
'00100F1F2',
'0010FF1F2'
)
)
SELECT drn_pk_a as drn_pk, drn_gm_a as drn_gm
FROM auto_intersect aut
) as a;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DrainageLineCrossDrainageLine()

--------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineCrossDrainageLine()
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineCrossDrainageLine()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineCrossDrainageLine).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineCrossDrainageLine()
) as b;
$$
LANGUAGE SQL;


--SELECT pgh_consistency.pghfn_numDrainageLineCrossDrainageLine();

------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_DrainageLineOverlapDrainageLine()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_DrainageLineOverlapDrainageLine()
RETURNS TABLE(drn_pk_ integer, drn_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT drn_pk, drn_gm
FROM
(
WITH auto_intersect AS (
SELECT a.drn_pk as drn_pk_a, b.drn_pk as drn_pk_b, a.drn_gm as drn_gm_a, b.drn_gm as drn_gm_b 
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND
ST_Relate(a.drn_gm, b.drn_gm) IN (
--OVERLAP
'1F1FF0102',
'1010F0102',
'1F1F00102',
'1F10F0102',
'1010FF102',
'1F100F102',
'1F10FF102',
'1F1F0F1F2',
'10100F1F2',
'1010FF1F2'
)
)
SELECT drn_pk_a as drn_pk, drn_gm_a as drn_gm
FROM auto_intersect aut
) as a;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_DrainageLineOverlapDrainageLine()

---------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numDrainageLineOverlapDrainageLine()
---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineOverlapDrainageLine()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT (pghfn_DrainageLineOverlapDrainageLine).drn_pk_ as drn_pk
FROM pgh_consistency.pghfn_DrainageLineOverlapDrainageLine()
) as b;
$$
LANGUAGE SQL;

--SELECT pgh_consistency.pghfn_numDrainageLineOverlapDrainageLine();

------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConsistencyGeometryTables()
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConsistencyGeometryTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_DrainageLineIsNotSingle

TRUNCATE pgh_consistency.pghft_DrainageLineIsNotSingle;

INSERT INTO pgh_consistency.pghft_DrainageLineIsNotSingle
SELECT row_number() OVER () as id, (pghfn_DrainageLineIsNotSingle).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineIsNotSingle).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineIsNotSingle();

--TABLE pgh_consistency.pghft_DrainageLineIsNotSimple

TRUNCATE pgh_consistency.pghft_DrainageLineIsNotSimple;

INSERT INTO pgh_consistency.pghft_DrainageLineIsNotSimple
SELECT row_number() OVER () as id, (pghfn_DrainageLineIsNotSimple).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineIsNotSimple).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineIsNotSimple();

--TABLE pgh_consistency.pghft_DrainageLineIsNotValid

TRUNCATE pgh_consistency.pghft_DrainageLineIsNotValid;

INSERT INTO pgh_consistency.pghft_DrainageLineIsNotValid
SELECT row_number() OVER () as id, (pghfn_DrainageLineIsNotValid).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineIsNotValid).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineIsNotValid();

--TABLE pgh_consistency.pghft_DrainageLineIsNotValidPoint

TRUNCATE pgh_consistency.pghft_DrainageLineIsNotValidPoint;

INSERT INTO pgh_consistency.pghft_DrainageLineIsNotValidPoint
SELECT row_number() OVER () as id, (pghfn_DrainageLineIsNotValid).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineIsNotValid).drn_gm_point_ as drn_gm_point
FROM pgh_consistency.pghfn_DrainageLineIsNotValid();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_UpdateDrainageLineConsistencyGeometryTables();

----------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_1()
----------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_1()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

/*
--TABLE pgh_consistency.pghft_DrainageLineHaveSelfIntersection

TRUNCATE pgh_consistency.pghft_DrainageLineHaveSelfIntersection;

INSERT INTO pgh_consistency.pghft_DrainageLineHaveSelfIntersection
SELECT row_number() OVER () as id, (pghfn_DrainageLineHaveSelfIntersection).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineHaveSelfIntersection).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineHaveSelfIntersection();
*/

--TABLE pgh_consistency.pghft_DrainageLineWithinDrainageLine

TRUNCATE pgh_consistency.pghft_DrainageLineWithinDrainageLine;

INSERT INTO pgh_consistency.pghft_DrainageLineWithinDrainageLine
SELECT row_number() OVER () as id, (pghfn_DrainageLineWithinDrainageLine).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineWithinDrainageLine).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineWithinDrainageLine();

--TABLE pgh_consistency.pghft_DrainageLineOverlapDrainageLine

TRUNCATE pgh_consistency.pghft_DrainageLineOverlapDrainageLine;

INSERT INTO pgh_consistency.pghft_DrainageLineOverlapDrainageLine
SELECT row_number() OVER () as id, (pghfn_DrainageLineOverlapDrainageLine).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineOverlapDrainageLine).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineOverlapDrainageLine();

--TABLE pgh_consistency.pghft_DrainageLineLoops

TRUNCATE pgh_consistency.pghft_DrainageLineLoops;

INSERT INTO pgh_consistency.pghft_DrainageLineLoops
SELECT row_number() OVER () as id, (pghfn_DrainageLineLoops).plg_pk_ as plg_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineLoops).plg_gm_ as plg_gm, ST_AREA((pghfn_DrainageLineLoops).plg_gm_) as area
FROM pgh_consistency.pghfn_DrainageLineLoops();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_1();

--------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_2()
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_2()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_DrainageLineCrossDrainageLine

TRUNCATE pgh_consistency.pghft_DrainageLineCrossDrainageLine;

INSERT INTO pgh_consistency.pghft_DrainageLineCrossDrainageLine
SELECT row_number() OVER () as id, (pghfn_DrainageLineCrossDrainageLine).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineCrossDrainageLine).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineCrossDrainageLine();

--TABLE pgh_consistency.pghft_DrainageLineTouchDrainageLine

TRUNCATE pgh_consistency.pghft_DrainageLineTouchDrainageLine;

INSERT INTO pgh_consistency.pghft_DrainageLineTouchDrainageLine
SELECT row_number() OVER () as id, (pghfn_DrainageLineTouchDrainageLine).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineTouchDrainageLine).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineTouchDrainageLine();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_UpdateDrainageLineConsistencyTopologyTables_2();

-----------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageLineNetworkConsistencyTables()
-----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageLineNetworkConsistencyTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_PointValenceValue2

TRUNCATE pgh_consistency.pghft_PointValenceValue2;

INSERT INTO pgh_consistency.pghft_PointValenceValue2
SELECT row_number() OVER () as id, (pghfn_PointValenceValue2).drp_pk_ as drp_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_PointValenceValue2).drp_gm_ as drp_gm
FROM pgh_consistency.pghfn_PointValenceValue2();

--TABLE pgh_consistency.pghft_PointValenceValue4

TRUNCATE pgh_consistency.pghft_PointValenceValue4;

INSERT INTO pgh_consistency.pghft_PointValenceValue4
SELECT row_number() OVER () as id, (pghfn_PointValenceValue4).drp_pk_ as drp_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_PointValenceValue4).drp_gm_ as drp_gm
FROM pgh_consistency.pghfn_PointValenceValue4();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConnectionConsistencyTables()
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageLineConnectionConsistencyTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_DrainageLineIsDisconnected()

TRUNCATE pgh_consistency.pghft_DrainageLineIsDisconnected;

INSERT INTO pgh_consistency.pghft_DrainageLineIsDisconnected
SELECT row_number() OVER () as id, (pghfn_DrainageLineIsDisconnected).drn_pk_ as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageLineIsDisconnected).drn_gm_ as drn_gm
FROM pgh_consistency.pghfn_DrainageLineIsDisconnected();

--TABLE pgh_consistency.pghft_pointdivergent

TRUNCATE pgh_consistency.pghft_pointdivergent;

INSERT INTO pgh_consistency.pghft_pointdivergent
SELECT row_number() OVER () as id, (pghfn_PointDivergent).drp_pk_ as drp_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_PointDivergent).drp_gm_ as drp_gm
FROM pgh_consistency.pghfn_PointDivergent();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageAreaConsistencyGeometryTables()
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageAreaConsistencyGeometryTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_DrainageAreaIsNotSingle

TRUNCATE pgh_consistency.pghft_DrainageAreaIsNotSingle;

INSERT INTO pgh_consistency.pghft_DrainageAreaIsNotSingle
SELECT row_number() OVER () as id, (pghfn_DrainageAreaIsNotSingle).dra_pk_ as dra_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageAreaIsNotSingle).dra_gm_ as dra_gm
FROM pgh_consistency.pghfn_DrainageAreaIsNotSingle();

--TABLE pgh_consistency.pghft_DrainageAreaIsNotSimple

TRUNCATE pgh_consistency.pghft_DrainageAreaIsNotSimple;

INSERT INTO pgh_consistency.pghft_DrainageAreaIsNotSimple
SELECT row_number() OVER () as id, (pghfn_DrainageAreaIsNotSimple).dra_pk_ as dra_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageAreaIsNotSimple).dra_gm_ as dra_gm
FROM pgh_consistency.pghfn_DrainageAreaIsNotSimple();

--TABLE pgh_consistency.pghft_DrainageAreaIsNotValid

TRUNCATE pgh_consistency.pghft_DrainageAreaIsNotValid;

INSERT INTO pgh_consistency.pghft_DrainageAreaIsNotValid
SELECT row_number() OVER () as id, (pghfn_DrainageAreaIsNotValid).dra_pk_ as dra_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageAreaIsNotValid).dra_gm_ as dra_gm, (pghfn_DrainageAreaIsNotValid).dra_gm_point_ as dra_gm_point
FROM pgh_consistency.pghfn_DrainageAreaIsNotValid();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageAreaConsistencyTopologyTables()
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageAreaConsistencyTopologyTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_DrainageAreaOverlapDrainageArea

TRUNCATE pgh_consistency.pghft_DrainageAreaOverlapDrainageArea;

INSERT INTO pgh_consistency.pghft_DrainageAreaOverlapDrainageArea
SELECT row_number() OVER () as id, (pghfn_DrainageAreaOverlapDrainageArea).int_pk_ as int_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageAreaOverlapDrainageArea).dra_pk_a_ as dra_pk_a, (pghfn_DrainageAreaOverlapDrainageArea).dra_pk_b_ as dra_pk_b, (pghfn_DrainageAreaOverlapDrainageArea).int_gm_ as int_gm, (pghfn_DrainageAreaOverlapDrainageArea).dra_gm_a_ as dra_gm_a, (pghfn_DrainageAreaOverlapDrainageArea).dra_gm_b_ as dra_gm_b, ST_AREA((pghfn_DrainageAreaOverlapDrainageArea).int_gm_) as area
FROM pgh_consistency.pghfn_DrainageAreaOverlapDrainageArea();

--TABLE pgh_consistency.pghft_DrainageAreaWithinDrainageArea

TRUNCATE pgh_consistency.pghft_DrainageAreaWithinDrainageArea;

INSERT INTO pgh_consistency.pghft_DrainageAreaWithinDrainageArea
SELECT row_number() OVER () as id, (pghfn_DrainageAreaWithinDrainageArea).dra_pk_ as dra_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_DrainageAreaWithinDrainageArea).dra_gm_ as dra_gm, ST_AREA((pghfn_DrainageAreaWithinDrainageArea).dra_gm_) as area
FROM pgh_consistency.pghfn_DrainageAreaWithinDrainageArea();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateDrainageLineDrainageAreaConsistencyTables()
----------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateDrainageLineDrainageAreaConsistencyTables()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

--TABLE pgh_consistency.pghft_DrainageAreaNoDrainageLine

TRUNCATE pgh_consistency.pghft_DrainageAreaNoDrainageLine;

INSERT INTO pgh_consistency.pghft_DrainageAreaNoDrainageLine
SELECT row_number() OVER () as id, a.hin_dra_pk as dra_pk, (row_number() OVER () - 1) % 10 + 1 as editor, b.dra_gm as dra_gm, ST_AREA(b.dra_gm) as area
FROM pghydro.pghft_drainage_area b, pghydro.pghft_hydro_intel a
WHERE a.hin_drn_pk isnull
AND a.hin_dra_pk = b.dra_pk;

--TABLE pgh_consistency.pghft_DrainageLineNoDrainageArea

TRUNCATE pgh_consistency.pghft_DrainageLineNoDrainageArea;

INSERT INTO pgh_consistency.pghft_DrainageLineNoDrainageArea
SELECT row_number() OVER () as id, a.hin_drn_pk as drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, b.drn_gm
FROM pghydro.pghft_drainage_line b, pghydro.pghft_hydro_intel a
WHERE a.hin_dra_pk isnull
AND a.hin_drn_pk = b.drn_pk;

--TABLE pgh_consistency.pghft_DrainageAreaMoreOneDrainageLine

TRUNCATE pgh_consistency.pghft_DrainageAreaMoreOneDrainageLine;

INSERT INTO pgh_consistency.pghft_DrainageAreaMoreOneDrainageLine
SELECT row_number() OVER () as id, dra_pk, (row_number() OVER () - 1) % 10 + 1 as editor, dra_gm
FROM
(
SELECT DISTINCT a.hin_dra_pk as dra_pk, b.dra_gm as dra_gm
FROM pghydro.pghft_drainage_area b, pghydro.pghft_hydro_intel a
WHERE hin_count_dra_pk >=2 
AND a.hin_dra_pk = b.dra_pk
)as a;

--TABLE pgh_consistency.pghft_DrainageLineMoreOneDrainageArea

TRUNCATE pgh_consistency.pghft_DrainageLineMoreOneDrainageArea;

INSERT INTO pgh_consistency.pghft_DrainageLineMoreOneDrainageArea
SELECT row_number() OVER () as id, drn_pk, (row_number() OVER () - 1) % 10 + 1 as editor, drn_gm
FROM
(
SELECT DISTINCT a.hin_drn_pk as drn_pk, b.drn_gm
FROM pghydro.pghft_drainage_line b, pghydro.pghft_hydro_intel a
WHERE hin_count_drn_pk >=2 
AND a.hin_drn_pk = b.drn_pk
) as a;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------
--HYDRONYM
----------------------------------------------

--CREATE TABLES

--TABLE pgh_consistency.pghtb_nm_waterbodyoriginal

DROP TABLE IF EXISTS pgh_consistency.pghtb_nm_waterbodyoriginal;

CREATE SEQUENCE pgh_consistency.nwo_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pgh_consistency.pghtb_nm_waterbodyoriginal(
nwo_pk integer NOT NULL DEFAULT nextval('pgh_consistency.nwo_pk_seq'::regclass),
nwo_nm_original varchar,
nwo_nm_generic varchar,
nwo_nm_connection varchar,
nwo_nm_specific varchar
);

ALTER SEQUENCE pgh_consistency.nwo_pk_seq OWNED BY pgh_consistency.pghtb_nm_waterbodyoriginal.nwo_pk;

--TABLE pgh_consistency.pghtb_nm_generic

DROP TABLE IF EXISTS pgh_consistency.pghtb_nm_generic;

CREATE SEQUENCE pgh_consistency.nmg_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pgh_consistency.pghtb_nm_generic(
nmg_pk integer NOT NULL DEFAULT nextval('pgh_consistency.nmg_pk_seq'::regclass),
nmg_nwo_nm_generic varchar,
nmg_nm_generic varchar
);

ALTER SEQUENCE pgh_consistency.nmg_pk_seq OWNED BY pgh_consistency.pghtb_nm_generic.nmg_pk;

ALTER TABLE ONLY pgh_consistency.pghtb_nm_generic ADD CONSTRAINT nmg_pk_pkey PRIMARY KEY (nmg_pk);

--TABLE pgh_consistency.pghtb_nm_connection;

DROP TABLE IF EXISTS pgh_consistency.pghtb_nm_connection;

CREATE SEQUENCE pgh_consistency.nmc_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pgh_consistency.pghtb_nm_connection(
nmc_pk integer NOT NULL DEFAULT nextval('pgh_consistency.nmc_pk_seq'::regclass),
nmc_nwo_nm_connection varchar,
nmc_nm_connection varchar
);

ALTER SEQUENCE pgh_consistency.nmc_pk_seq OWNED BY pgh_consistency.pghtb_nm_connection.nmc_pk;

ALTER TABLE ONLY pgh_consistency.pghtb_nm_connection ADD CONSTRAINT nmc_pk_pkey PRIMARY KEY (nmc_pk);

--TABLE pgh_consistency.pghtb_nm_specific;

DROP TABLE IF EXISTS pgh_consistency.pghtb_nm_specific;

CREATE SEQUENCE pgh_consistency.nms_pk_seq 
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pgh_consistency.pghtb_nm_specific(
nms_pk integer NOT NULL DEFAULT nextval('pgh_consistency.nms_pk_seq'::regclass),
nms_nwo_nm_specific varchar,
nms_nm_specific varchar
);

ALTER SEQUENCE pgh_consistency.nms_pk_seq OWNED BY pgh_consistency.pghtb_nm_specific.nms_pk;

ALTER TABLE ONLY pgh_consistency.pghtb_nm_specific ADD CONSTRAINT nms_pk_pkey PRIMARY KEY (nms_pk);

--TABLE pgh_consistency.pghtb_nm_complete

DROP TABLE IF EXISTS pgh_consistency.pghtb_nm_complete;

CREATE SEQUENCE pgh_consistency.nmp_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE pgh_consistency.pghtb_nm_complete(
nmp_pk integer NOT NULL DEFAULT nextval('pgh_consistency.nmp_pk_seq'::regclass),
nmp_nm_complete varchar,
nmp_nm_generic varchar,
nmp_nm_connection varchar,
nmp_nm_specific varchar
);

ALTER SEQUENCE pgh_consistency.nmp_pk_seq OWNED BY pgh_consistency.pghtb_nm_complete.nmp_pk;

CREATE TABLE pgh_consistency.pghft_confluencehydronym
(
  id bigint,
  cnh_drp_pk integer,
  editor bigint,
  cnh_gm geometry(MultiPoint),
  CONSTRAINT pghft_confluencehydronym_pkey PRIMARY KEY (id)
);

-------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_ConfluenceHydronym()
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_ConfluenceHydronym()
RETURNS TABLE(cnh_drp_pk_ integer, cnh_gm_ geometry)
AS
$$
BEGIN

RETURN QUERY

SELECT a.drp_pk as cnh_drp_pk, ST_MULTI(drp.drp_gm) as cnh_gm
FROM
(
SELECT DISTINCT drn_drp_pk_targetnode as drp_pk
FROM
(
SELECT a.drn_drp_pk_targetnode
FROM pghydro.pghft_drainage_line a, pghydro.pghft_drainage_line b, pghydro.pghft_drainage_point c
WHERE a.drn_nm = b.drn_nm
AND a.drn_drn_pk_upstreamdrainageline = b.drn_pk
AND a.drn_drp_pk_targetnode = c.drp_pk
) as d
) as a, pghydro.pghft_drainage_point drp
WHERE drp.drp_pk = a.drp_pk;

RETURN;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_ConfluenceHydronym();

--------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_numConfluenceHydronym()
--------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_numDrainageLineOverlapDrainageLine()
RETURNS bigint AS
$$
SELECT count(cnh_drp_pk)
FROM
(
SELECT (pghfn_ConfluenceHydronym).cnh_drp_pk_ as cnh_drp_pk
FROM pgh_consistency.pghfn_ConfluenceHydronym()
) as b;
$$
LANGUAGE SQL;

--SELECT pgh_consistency.pghfn_numConfluenceHydronym();

--------------------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_UpdateConfluenceHydronymConistencyTable()
--------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_UpdateConfluenceHydronymConistencyTable()
RETURNS character varying AS
$$
BEGIN

--TABLE pgh_consistency.pghft_ConfluenceHydronym

TRUNCATE pgh_consistency.pghft_ConfluenceHydronym;

INSERT INTO pgh_consistency.pghft_ConfluenceHydronym
SELECT row_number() OVER () as id, (pghfn_ConfluenceHydronym).cnh_drp_pk_ as cnh_drp_pk, (row_number() OVER () - 1) % 10 + 1 as editor, (pghfn_ConfluenceHydronym).cnh_gm_ as cnh_gm
FROM pgh_consistency.pghfn_ConfluenceHydronym();

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;


-------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_systematize_hydronym()
-------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_systematize_hydronym()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;
    
time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

TRUNCATE pgh_consistency.pghtb_nm_waterbodyoriginal;

ALTER SEQUENCE pgh_consistency.nwo_pk_seq RESTART WITH 1;

INSERT INTO pgh_consistency.pghtb_nm_waterbodyoriginal (nwo_nm_original, nwo_nm_generic, nwo_nm_connection, nwo_nm_specific)
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

UPDATE pgh_consistency.pghtb_nm_waterbodyoriginal
SET nwo_nm_connection = ' '
WHERE nwo_nm_connection is null;

UPDATE pgh_consistency.pghtb_nm_waterbodyoriginal
SET nwo_nm_specific = ' '
WHERE nwo_nm_specific = '';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

TRUNCATE pgh_consistency.pghtb_nm_generic;

ALTER SEQUENCE pgh_consistency.nmg_pk_seq RESTART WITH 1;

INSERT INTO pgh_consistency.pghtb_nm_generic (nmg_nwo_nm_generic, nmg_nm_generic)
SELECT DISTINCT nwo_nm_generic, nwo_nm_generic
FROM pgh_consistency.pghtb_nm_waterbodyoriginal
ORDER BY nwo_nm_generic;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

TRUNCATE pgh_consistency.pghtb_nm_connection;

ALTER SEQUENCE pgh_consistency.nmc_pk_seq RESTART WITH 1;

INSERT INTO pgh_consistency.pghtb_nm_connection (nmc_nwo_nm_connection, nmc_nm_connection)
SELECT DISTINCT nwo_nm_connection, nwo_nm_connection
FROM pgh_consistency.pghtb_nm_waterbodyoriginal
ORDER BY nwo_nm_connection;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

TRUNCATE pgh_consistency.pghtb_nm_specific;

ALTER SEQUENCE pgh_consistency.nms_pk_seq RESTART WITH 1;

INSERT INTO pgh_consistency.pghtb_nm_specific (nms_nwo_nm_specific, nms_nm_specific)
SELECT DISTINCT nwo_nm_specific, nwo_nm_specific
FROM pgh_consistency.pghtb_nm_waterbodyoriginal
ORDER BY nwo_nm_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

TRUNCATE pgh_consistency.pghtb_nm_complete;

ALTER SEQUENCE pgh_consistency.nmp_pk_seq RESTART WITH 1;

INSERT INTO pgh_consistency.pghtb_nm_complete(nmp_nm_complete, nmp_nm_generic, nmp_nm_connection, nmp_nm_specific)
SELECT nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM
(
SELECT DISTINCT nmg_nm_generic||' '||nmc_nm_connection||' '||nms_nm_specific as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pgh_consistency.pghtb_nm_generic nmg, pgh_consistency.pghtb_nm_connection nmc, pgh_consistency.pghtb_nm_specific nms, pgh_consistency.pghtb_nm_waterbodyoriginal nwo
WHERE nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmc.nmc_nm_connection <> ' '
UNION ALL
SELECT DISTINCT CASE WHEN nms.nms_nm_specific = ' ' THEN nmg.nmg_nm_generic ELSE nmg.nmg_nm_generic||' '||nms.nms_nm_specific END as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pgh_consistency.pghtb_nm_generic nmg, pgh_consistency.pghtb_nm_connection nmc, pgh_consistency.pghtb_nm_specific nms, pgh_consistency.pghtb_nm_waterbodyoriginal nwo
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
FROM pgh_consistency.pghtb_nm_generic;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_connection;

INSERT INTO pghydro.pghtb_type_name_connection (tcn_pk, tcn_ds)
SELECT nmc_pk, nmc_nm_connection
FROM pgh_consistency.pghtb_nm_connection;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_specific;

INSERT INTO pghydro.pghtb_type_name_specific (tns_pk, tns_ds)
SELECT nms_pk, nms_nm_specific
FROM pgh_consistency.pghtb_nm_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

TRUNCATE pghydro.pghtb_type_name_complete;

DROP INDEX IF EXISTS pgh_consistency.nmg_nm_generic_idx;

DROP INDEX IF EXISTS pgh_consistency.nmp_nm_generic_idx;

DROP INDEX IF EXISTS pgh_consistency.nmc_nm_connection_idx;

DROP INDEX IF EXISTS pgh_consistency.nmp_nm_connection_idx;

DROP INDEX IF EXISTS pgh_consistency.nms_nm_specific_idx;

DROP INDEX IF EXISTS pgh_consistency.nmp_nm_specific_idx;

CREATE INDEX nmg_nm_generic_idx ON pgh_consistency.pghtb_nm_generic(nmg_nm_generic);

CREATE INDEX nmp_nm_generic_idx ON pgh_consistency.pghtb_nm_complete(nmp_nm_generic);

CREATE INDEX nmc_nm_connection_idx ON pgh_consistency.pghtb_nm_connection(nmc_nm_connection);

CREATE INDEX nmp_nm_connection_idx ON pgh_consistency.pghtb_nm_complete(nmp_nm_connection);

CREATE INDEX nms_nm_specific_idx ON pgh_consistency.pghtb_nm_specific(nms_nm_specific);

CREATE INDEX nmp_nm_specific_idx ON pgh_consistency.pghtb_nm_complete(nmp_nm_specific);

INSERT INTO pghydro.pghtb_type_name_complete (tnc_pk, tnc_ds, tnc_tng_pk, tnc_tcn_pk, tnc_tns_pk)
SELECT nmp.nmp_pk, nmp.nmp_nm_complete, nmg.nmg_pk, nmc.nmc_pk, nms.nms_pk
FROM pgh_consistency.pghtb_nm_complete nmp, pgh_consistency.pghtb_nm_generic nmg, pgh_consistency.pghtb_nm_connection nmc, pgh_consistency.pghtb_nm_specific nms
WHERE nmg.nmg_nm_generic = nmp.nmp_nm_generic
AND nmc.nmc_nm_connection = nmp.nmp_nm_connection
AND nms.nms_nm_specific = nmp.nmp_nm_specific;

DROP INDEX IF EXISTS pgh_consistency.nmg_nm_generic_idx;

DROP INDEX IF EXISTS pgh_consistency.nmp_nm_generic_idx;

DROP INDEX IF EXISTS pgh_consistency.nmc_nm_connection_idx;

DROP INDEX IF EXISTS pgh_consistency.nmp_nm_connection_idx;

DROP INDEX IF EXISTS pgh_consistency.nms_nm_specific_idx;

DROP INDEX IF EXISTS pgh_consistency.nmp_nm_specific_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;   

--UPDATE pghydro.pghft_drainage_line.drn_tnc_pk

DROP INDEX IF EXISTS pghydro.tnc_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_nm_idx;

DROP INDEX IF EXISTS pghydro.tnc_ds_idx;

UPDATE pghydro.pghft_drainage_line drn
SET drn_tnc_pk = NULL;

CREATE INDEX tnc_pk_idx ON pghydro.pghtb_type_name_complete(tnc_pk);

CREATE INDEX drn_nm_idx ON pghydro.pghft_drainage_line(drn_nm); 

CREATE INDEX tnc_ds_idx ON pghydro.pghtb_type_name_complete(tnc_ds); 

UPDATE pghydro.pghft_drainage_line drn
SET drn_tnc_pk = tnc.tnc_pk
FROM pghydro.pghtb_type_name_complete tnc
WHERE drn.drn_nm = tnc.tnc_ds;

DROP INDEX IF EXISTS pghydro.tnc_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_nm_idx;

DROP INDEX IF EXISTS pghydro.tnc_ds_idx;

RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_systematize_hydronym();

----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_update_drn_nm()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_update_drn_nm()
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

TRUNCATE pgh_consistency.pghtb_nm_complete;

ALTER SEQUENCE pgh_consistency.nmp_pk_seq RESTART WITH 1;

INSERT INTO pgh_consistency.pghtb_nm_complete(nmp_nm_complete, nmp_nm_generic, nmp_nm_connection, nmp_nm_specific)
SELECT nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM
(
SELECT DISTINCT nmg_nm_generic||' '||nmc_nm_connection||' '||nms_nm_specific as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pgh_consistency.pghtb_nm_generic nmg, pgh_consistency.pghtb_nm_connection nmc, pgh_consistency.pghtb_nm_specific nms, pgh_consistency.pghtb_nm_waterbodyoriginal nwo
WHERE nmg.nmg_nwo_nm_generic = nwo.nwo_nm_generic
AND nmc.nmc_nwo_nm_connection = nwo.nwo_nm_connection
AND nms.nms_nwo_nm_specific = nwo.nwo_nm_specific
AND nmc.nmc_nm_connection <> ' '
UNION ALL
SELECT DISTINCT CASE WHEN nms.nms_nm_specific = ' ' THEN nmg.nmg_nm_generic ELSE nmg.nmg_nm_generic||' '||nms.nms_nm_specific END as nmp_nm_complete, nmg_nm_generic, nmc_nm_connection, nms_nm_specific
FROM pgh_consistency.pghtb_nm_generic nmg, pgh_consistency.pghtb_nm_connection nmc, pgh_consistency.pghtb_nm_specific nms, pgh_consistency.pghtb_nm_waterbodyoriginal nwo
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
pgh_consistency.pghtb_nm_complete nmp,
pgh_consistency.pghtb_nm_generic nmg,
pgh_consistency.pghtb_nm_connection nmc,
pgh_consistency.pghtb_nm_specific nms,
pgh_consistency.pghtb_nm_waterbodyoriginal nwo
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

RAISE NOTICE 'END OF PROCESS IN : %', time_;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--SELECT pgh_consistency.pghfn_update_drn_nm();

----------------------------------------------
--CREATE BACKUP TABLES
----------------------------------------------

CREATE TABLE pgh_consistency.pghft_backup_drainage_line(
    ads_operation         char(1),
    ads_stamp             timestamp,
    ads_userid            text,
    ads_drn_pk            integer,
    ads_drn_nm            text,
    ads_drn_nm_old        text,
    ads_drn_gm            geometry(MultiLineString)
);

CREATE TABLE pgh_consistency.pghft_backup_drainage_area(
    adh_operation         char(1),
    adh_stamp             timestamp,
    adh_userid            text,
    adh_dra_pk           integer,
    adh_dra_gm           geometry(MultiPolygon)
);

-------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_Backup_Drainage_Line()
-------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_backup_drainage_line() RETURNS TRIGGER AS $pghft_backup_drainage_line$
    BEGIN
        --
        -- Create a row in emp_backup to reflect the operation performed on emp,
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO pgh_consistency.pghft_backup_drainage_line(ads_operation, ads_stamp, ads_userid, ads_drn_pk, ads_drn_nm, ads_drn_gm)
            SELECT 'D', now(), user, OLD.drn_pk, OLD.drn_nm, OLD.drn_gm;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO pgh_consistency.pghft_backup_drainage_line(ads_operation, ads_stamp, ads_userid, ads_drn_pk, ads_drn_nm, ads_drn_nm_old, ads_drn_gm)
            SELECT 'U', now(), user, NEW.drn_pk, NEW.drn_nm, OLD.drn_nm, NEW.drn_gm;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO pgh_consistency.pghft_backup_drainage_line(ads_operation, ads_stamp, ads_userid, ads_drn_pk, ads_drn_nm, ads_drn_gm)
            SELECT 'I', now(), user, NEW.drn_pk, NEW.drn_nm, NEW.drn_gm;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$pghft_backup_drainage_line$ LANGUAGE plpgsql;

-------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_Backup_Drainage_Area()
-------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_backup_drainage_area() RETURNS TRIGGER AS $pghft_backup_drainage_area$
    BEGIN
        --
        -- Create a row in emp_backup to reflect the operation performed on emp,
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO pgh_consistency.pghft_backup_drainage_area SELECT 'D', now(), user, OLD.dra_pk, OLD.dra_gm;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO pgh_consistency.pghft_backup_drainage_area SELECT 'U', now(), user, NEW.dra_pk, NEW.dra_gm;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO pgh_consistency.pghft_backup_drainage_area SELECT 'I', now(), user, NEW.dra_pk, NEW.dra_gm;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$pghft_backup_drainage_area$ LANGUAGE plpgsql;

----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_TurnOnBackup()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_turnonbackup()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

DROP TRIGGER IF EXISTS pghft_backup_drainage_line ON pghydro.pghft_drainage_line;

CREATE TRIGGER pghft_backup_drainage_line
AFTER INSERT OR UPDATE OR DELETE ON pghydro.pghft_drainage_line
    FOR EACH ROW EXECUTE PROCEDURE pgh_consistency.pghfn_backup_drainage_line();

DROP TRIGGER IF EXISTS pghft_backup_drainage_area ON pghydro.pghft_drainage_area;

CREATE TRIGGER pghft_backup_drainage_area
AFTER INSERT OR UPDATE OR DELETE ON pghydro.pghft_drainage_area
    FOR EACH ROW EXECUTE PROCEDURE pgh_consistency.pghfn_backup_drainage_area();

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pgh_consistency.pghfn_TurnOffBackup()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_turnoffbackup()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

DROP TRIGGER IF EXISTS pghft_backup_drainage_line ON pghydro.pghft_drainage_line;

DROP TRIGGER IF EXISTS pghft_backup_drainage_area ON pghydro.pghft_drainage_area;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_CleanDrainageLineBackupTables()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_CleanDrainageLineBackupTables()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

TRUNCATE TABLE pgh_consistency.pghft_backup_drainage_line;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------------------
--FUNCTION pgh_consistency.pghfn_CleanDrainageAreaBackupTables()
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_consistency.pghfn_CleanDrainageAreaBackupTables()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

TRUNCATE TABLE pgh_consistency.pghft_backup_drainage_area;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-----------------------------------------
--UpdateGeometrySRID
-----------------------------------------

SELECT pghydro.pghfn_UpdateGeometrySRID();