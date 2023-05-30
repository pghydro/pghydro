--
-- Copyright (c) 2023 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
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
--PostGIS Raster version 3+
--PgHydro version 6.6

---------------------------------------------------------------------------------
--Pghydro Raster Extension Version 6.6 of 01/03/2023
---------------------------------------------------------------------------------

-------------------------------------
--CREATE SCHEMA, TABLES AND SEQUENCES
-------------------------------------

DROP SCHEMA IF EXISTS pgh_raster CASCADE;

CREATE SCHEMA pgh_raster;

--INSERÇÃO RASTERS

--raster2pgsql -s 3857 -I -C -M -a outputDem.tif -F -t 200x200 pgh_raster.pghrt_elevation | psql -U postgres -d database -h localhost -p 5432

--raster2pgsql -s 3857 -I -C -M -a outputDrainage.tif -F -t 200x200 pgh_raster.pghrt_flowpath | psql -U postgres -d database -h localhost -p 5432

--raster2pgsql -s 3857 -I -C -M -a outputD8.tif -F -t 200x200 pgh_raster.pghrt_flowdirection | psql -U postgres -d database -h localhost -p 5432

--raster2pgsql -s 3857 -I -C -M -a outputD8ContributingArea.tif -F -t 200x200 pgh_raster.pghrt_flowaccumulation | psql -U postgres -d database -h localhost -p 5432

--raster2pgsql -s 3857 -I -C -M landuse.tif -F -t 200x200 pgh_raster.pghrt_landuse | psql -U postgres -d database -h localhost -p 5432

CREATE TABLE pgh_raster.pghrt_elevation (
    rid integer,
    rast raster,
    filename text);
	
CREATE TABLE pgh_raster.pghrt_flowpath (
    rid integer,
    rast raster,
    filename text);
	
CREATE TABLE pgh_raster.pghrt_flowdirection (
    rid integer,
    rast raster,
    filename text);
	
CREATE TABLE pgh_raster.pghrt_flowaccumulation (
    rid integer,
    rast raster,
    filename text);

-----------------------------------------
--UpdateExtension
-----------------------------------------

--SELECT pg_catalog.pg_extension_config_dump('pgh_raster.pghrt_elevation', '');
--SELECT pg_catalog.pg_extension_config_dump('pgh_raster.pghrt_flowpath', '');
--SELECT pg_catalog.pg_extension_config_dump('pgh_raster.pghrt_flowdirection', '');
--SELECT pg_catalog.pg_extension_config_dump('pgh_raster.pghrt_flowaccumulation', '');

-----------------------------
--INSERT DATA
-----------------------------

--

---------------------------------------------------------------------------------------------------
--PGH_RASTER FUNCTIONS
---------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------
--FUNCTION pgh_raster.pghfn_downstream_pixel(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_downstream_pixel(geometry)
  RETURNS geometry AS
$BODY$

DECLARE

dir integer;
flow integer;
dx double precision;
dy double precision;
x double precision;
y double precision;
srid_ integer;
gm geometry;

BEGIN

SELECT INTO srid_ srid
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO dx scale_x
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO dy scale_y
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO x ST_X(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as x
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO y ST_Y(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as y
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dir ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT ST_SETSRID(ST_Point(x, y), srid_) as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO flow ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowpath ras INNER JOIN (SELECT ST_SETSRID(ST_Point(x, y), srid_) as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

IF flow = 1 THEN

gm = null;

ELSE

IF dir = 1 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x + dx, y), srid_);

ELSIF dir = 128 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x + dx, y - dy), srid_);
		
ELSIF dir = 64 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x, y - dy), srid_);

ELSIF dir = 32 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x - dx, y - dy), srid_);

ELSIF dir = 16 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x - dx, y), srid_);

ELSIF dir = 8 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x - dx, y + dy), srid_);

ELSIF dir = 4 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x, y + dy), srid_);
	
ELSIF dir = 2 THEN

SELECT INTO gm ST_SETSRID(ST_Point(x + dx, y + dy), srid_);

END IF;

END IF;

RETURN gm;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_downstream_pixel(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--FUNCTION pgh_raster.pghfn_downstream_pixels(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_downstream_pixels(geometry)
  RETURNS SETOF geometry AS
$BODY$
DECLARE

r record;
x double precision;
y double precision;
srid_ integer;

BEGIN

SELECT INTO srid_ srid
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO x ST_X(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as x
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO y ST_Y(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as y
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

RETURN QUERY

SELECT ST_SETSRID(ST_Point(x, y), srid_) as pghfn_downstream_pixel;

FOR r IN

WITH RECURSIVE downstream_pixel AS (

	SELECT pgh_raster.pghfn_downstream_pixel(ST_SETSRID(ST_Point(x, y), srid_))
UNION 
        SELECT pgh_raster.pghfn_downstream_pixel(pghfn_downstream_pixel)
        FROM downstream_pixel

)

SELECT pghfn_downstream_pixel
FROM downstream_pixel

LOOP

RETURN NEXT r.pghfn_downstream_pixel;

END LOOP;

RETURN;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION pgh_raster.pghfn_downstream_pixels(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--FUNCTION pgh_raster.pghfn_upstream_pixel(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_upstream_pixel(geometry)
  RETURNS SETOF geometry AS
$BODY$

DECLARE

r record;
dira integer;
dirb integer;
dirc integer;
dird integer;
dire integer;
dirf integer;
dirg integer;
dirh integer;
flow integer;
dx double precision;
dy double precision;
x double precision;
y double precision;
srid_ integer;
gma geometry;
gmb geometry;
gmc geometry;
gmd geometry;
gme geometry;
gmf geometry;
gmg geometry;
gmh geometry;
gmaq geometry;
gmbq geometry;
gmcq geometry;
gmdq geometry;
gmeq geometry;
gmfq geometry;
gmgq geometry;
gmhq geometry;

BEGIN

SELECT INTO srid_ srid
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO dx scale_x
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO dy scale_y
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO x ST_X(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as x
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO y ST_Y(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as y
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO gma ST_SETSRID(ST_Point(x - dx, y - dy), srid_);--2
SELECT INTO gmb ST_SETSRID(ST_Point(x, y - dy), srid_);--4
SELECT INTO gmc ST_SETSRID(ST_Point(x + dx, y - dy), srid_);--8
SELECT INTO gmd ST_SETSRID(ST_Point(x - dx, y), srid_);--1
SELECT INTO gme ST_SETSRID(ST_Point(x + dx, y), srid_);--16
SELECT INTO gmf ST_SETSRID(ST_Point(x - dx, y + dy), srid_);--128
SELECT INTO gmg ST_SETSRID(ST_Point(x, y + dy), srid_);--64
SELECT INTO gmh ST_SETSRID(ST_Point(x + dx, y + dy), srid_);--32

SELECT INTO dira ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gma as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dirb ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gmb as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dirc ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gmc as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dird ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gmd as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dire ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gme as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dirf ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gmf as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dirg ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gmg as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO dirh ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT gmh as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

IF dira = 2 THEN

gmaq = gma;

END IF;

IF dirb = 4 THEN

gmbq = gmb;

END IF;

IF dirc = 8 THEN

gmcq = gmc;

END IF;

IF dird = 1 THEN

gmdq = gmd;

END IF;

IF dire = 16 THEN

gmeq = gme;

END IF;

IF dirf = 128 THEN

gmfq = gmf;

END IF;

IF dirg = 64 THEN

gmgq = gmg;

END IF;

IF dirh = 32 THEN

gmhq = gmh;

END IF;

RETURN QUERY

SELECT geom
FROM
(
SELECT gmaq as geom
UNION
SELECT gmbq as geom
UNION
SELECT gmcq as geom
UNION
SELECT gmdq as geom
UNION
SELECT gmeq as geom
UNION
SELECT gmfq as geom
UNION
SELECT gmgq as geom
UNION
SELECT gmhq as geom
) as a
WHERE geom is not null;

RETURN;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_upstream_pixel(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--pgh_raster.pghfn_upstream_pixels(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_upstream_pixels(geometry)
  RETURNS SETOF geometry AS
$BODY$
DECLARE

r record;
x double precision;
y double precision;
srid_ integer;

BEGIN

SELECT INTO srid_ srid
FROM public.raster_columns
WHERE r_table_name = 'pghrt_flowdirection';

SELECT INTO x ST_X(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as x
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

SELECT INTO y ST_Y(ST_PixelAsCentroid(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))) as y
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

FOR r IN

WITH RECURSIVE upstream_pixel AS (

	SELECT ST_SETSRID(ST_Point(x, y), srid_) as pghfn_upstream_pixel
UNION 
        SELECT pgh_raster.pghfn_upstream_pixel(pghfn_upstream_pixel)
        FROM upstream_pixel

)

SELECT pghfn_upstream_pixel
FROM upstream_pixel

LOOP

RETURN NEXT r.pghfn_upstream_pixel;

END LOOP;

RETURN;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION pgh_raster.pghfn_upstream_pixels(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--pgh_raster.pghfn_upstream_area(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_upstream_area(geometry)
  RETURNS geometry AS
$BODY$
SELECT ST_UNION(ST_SnapToGrid(geom, 0.0000001)) as geom
FROM
(
SELECT ST_PixelAsPolygon(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom)) as geom
FROM pgh_raster.pghrt_flowdirection ras INNER JOIN (SELECT pgh_raster.pghfn_upstream_pixels($1) as geom) as pon ON ST_Intersects(ras.rast,pon.geom)--10s
) as a;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_upstream_area(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--pgh_raster.pghfn_downstream(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_downstream(geometry)
  RETURNS geometry AS
$BODY$
SELECT
ST_MAKELINE(
ARRAY(
SELECT pgh_raster.pghfn_downstream_pixels($1)
)
)
as geom;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_downstream(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--pgh_raster.pghfn_downstream(geometry, integer, integer)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_downstream(geometry, integer, integer)
  RETURNS geometry AS
$BODY$
SELECT
ST_ChaikinSmoothing(
ST_Simplify(
ST_MAKELINE(
ARRAY(
SELECT pgh_raster.pghfn_downstream_pixels($1)
)
)
,$2, true)
, $3)
as geom;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
  
-----------------------------------------------------------------------
--pgh_raster.pghfn_downstream_drainage_point(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_downstream_drainage_point(geometry)
  RETURNS geometry AS
$BODY$
SELECT ST_PointN(geom, ST_NumPoints(geom)) as geom
FROM
(
SELECT pgh_raster.pghfn_downstream($1) as geom
) as a;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_downstream_drainage_point(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--pgh_raster.pghfn_downstream_drainage_area(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_downstream_drainage_area(geometry)
  RETURNS geometry AS
$BODY$
SELECT pgh_raster.pghfn_upstream_area(geom) as geom
FROM
(
SELECT ST_PointN(geom, ST_NumPoints(geom)-1) as geom
FROM
(
SELECT pgh_raster.pghfn_downstream($1) as geom
) as a
) as a;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_downstream_drainage_area(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--pgh_raster.pghfn_upstream_drainage_area(geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_upstream_drainage_area(geometry)
  RETURNS geometry AS
$BODY$
SELECT ST_CollectionExtract(
ST_Difference(pgh_raster.pghfn_upstream_area(pgh_raster.pghfn_downstream_drainage_point($1))
,
pgh_raster.pghfn_downstream_drainage_area($1)
)
,3);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_upstream_drainage_area(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--FUNCTION pgh_raster.pghfn_elevation_pixel_value(geometry)
-----------------------------------------------------------------------

-- DROP FUNCTION pgh_raster.pghfn_elevation_pixel_value(geometry);

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_elevation_pixel_value(geometry)
  RETURNS integer AS
$BODY$

DECLARE

eleva integer;

BEGIN

SELECT INTO eleva ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom))
FROM pgh_raster.pghrt_elevation ras INNER JOIN (SELECT $1 as geom) as pon ON ST_Intersects(ras.rast,pon.geom);

RETURN eleva;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION pgh_raster.pghfn_elevation_pixel_value(geometry)
  OWNER TO postgres;

-----------------------------------------------------------------------
--FUNCTION pgh_raster.pghfn_elevation_profile(geometry, integer)
-----------------------------------------------------------------------

DROP FUNCTION IF EXISTS pgh_raster.pghfn_elevation_profile(geometry, integer);

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_elevation_profile(geometry, integer)
  RETURNS TABLE(xy integer, z double precision, gm geometry) AS
$BODY$
DECLARE

BEGIN

RETURN QUERY

SELECT id::integer, ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom)) as elevation, geom
FROM pgh_raster.pghrt_elevation ras INNER JOIN
(
--Starting Point
SELECT 0 as id, ST_StartPoint($1) as geom
UNION
--Intermediary Points
SELECT id, geom
FROM
(
WITH line AS
(
SELECT $1 as geom
)
SELECT ROW_NUMBER() OVER()*$2 as id, geom
FROM
(
SELECT (ST_DumpPoints(ST_LineInterpolatePoints(geom, $2/ST_Length(geom)))).geom as geom
FROM line
) as a
) as a
UNION
--Ending Point
SELECT ST_LENGTH($1) as id, ST_EndPoint($1) as geom
) as pon ON ST_Intersects(ras.rast,pon.geom)
ORDER BY id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION pgh_raster.pghfn_elevation_profile(geometry, integer)
  OWNER TO postgres;

-----------------------------------------------------------------------
--FUNCTION pgh_raster.pghfn_elevation_profile(geometry)
-----------------------------------------------------------------------

DROP FUNCTION IF EXISTS pgh_raster.pghfn_elevation_profile(geometry);

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_elevation_profile(geometry)
  RETURNS TABLE(xy integer, z double precision, gm geometry) AS
$BODY$
DECLARE

length double precision;

BEGIN

SELECT INTO length ST_Length($1);

RETURN QUERY

SELECT id::integer, ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom), ST_WorldToRasterCoordY(rast, pon.geom)) as elevation, geom
FROM pgh_raster.pghrt_elevation ras INNER JOIN
(
SELECT id, geom
FROM
(
WITH line AS
(
SELECT $1 as geom
)
SELECT ST_LineLocatePoint($1, a.geom)*length as id, geom--ROW_NUMBER() OVER() as id, geom
FROM
(
SELECT (ST_DumpPoints(geom)).geom as geom
FROM line
) as a
) as a
) as pon ON ST_Intersects(ras.rast,pon.geom)
ORDER BY id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION pgh_raster.pghfn_elevation_profile(geometry)
  OWNER TO postgres;

----------------------------------------------------------------------------------------------------------------------------
--pgh_raster.pghfn_clip_raster(integer, character varying, character varying, character varying, character varying, integer)
----------------------------------------------------------------------------------------------------------------------------

-- DROP FUNCTION pgh_raster.pghfn_clip_raster(integer, character varying, character varying, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_clip_raster(
    clip_id integer,
    clip_column_id character varying,
    clip_column_geom character varying,
    clip_table character varying,
    raster_table character varying,
    raster_band integer)
  RETURNS TABLE(clip_id_ integer, raster_id_ double precision, cont_raster_id_ bigint) AS
$BODY$

BEGIN

RETURN QUERY

EXECUTE '
WITH cte AS (
SELECT clip.'||clip_column_id||', ST_ValueCount(ST_Clip(raster.rast, '||raster_band||', clip.'||clip_column_geom||', true)) As pv
FROM '||raster_table||' raster INNER JOIN
(
SELECT '||clip_column_id||', '||clip_column_geom||'
FROM '||clip_table||'
WHERE '||clip_column_id||' = '||clip_id||'
) as clip
ON ST_Intersects(raster.rast, clip.'||clip_column_geom||')
)
SELECT '||clip_column_id||', (pv).value, sum((pv).count)
FROM cte
GROUP BY '||clip_column_id||', (pv).value
;
';

RETURN;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-------------------------------------------------------------------------------------------------------------------------------------------
--pgh_raster.pghfn_insert_clip_data(character varying, character varying, character varying, character varying, integer, character varying)
-------------------------------------------------------------------------------------------------------------------------------------------

-- DROP FUNCTION pgh_raster.pghfn_insert_clip_data(character varying, character varying, character varying, character varying, integer, character varying)

CREATE OR REPLACE FUNCTION pgh_raster.pghfn_insert_clip_data(
    clip_column_id character varying,
    clip_column_geom character varying,
    clip_table character varying,
    raster_table character varying,
    raster_band integer,
    associative_entity character varying)
    
  RETURNS character varying AS
$BODY$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

--PERFORM pghydro.pghfn_DropForeignKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

	EXECUTE '
	DELETE FROM '||associative_entity||'
	';
	
	FOR r IN

	EXECUTE '

	SELECT '||clip_column_id||' FROM '||clip_table||'
	--WHERE '||clip_column_id||' = 422662
	--LIMIT 10 OFFSET 422662

	'

--	FOR r IN SELECT dra_pk FROM pgh_output_pt_br.geoft_bho_area_drenagem
--	LIMIT 10 OFFSET 319925
	
	LOOP

	EXECUTE '

	INSERT INTO '||associative_entity||'
	SELECT clip_id_, raster_id_, cont_raster_id_
	FROM pgh_raster.pghfn_clip_raster('||r||', '||quote_literal(clip_column_id)||', '||quote_literal(clip_column_geom)||', '||quote_literal(clip_table)||', '||quote_literal(raster_table)||','||raster_band||');

	';

	END LOOP;


time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-------------------------------------
--COMMENTS
-------------------------------------

--COMMENT ON FUNCTION pgh_raster.pghfn_clip_raster(integer, character varying, character varying, character varying, character varying, integer) IS 'returns ';
--COMMENT ON FUNCTION pgh_raster.pghfn_downstream(geometry) IS 'returns the geometry linestring representing the linestring created using all the centroid pixel(s) downstream to the pixels located in the input point geometry until the drainage line pixel based in the flow direction raster.';
--COMMENT ON FUNCTION pgh_raster.pghfn_downstream(geometry, integer, integer) IS 'returns the geometry linestring simplified and smoothed using simplify and Chaikin Smooth tolerance parameters as input preserving collapsed linestrings representing the linestring created using all the centroid pixel(s) downstream to the pixels located in the input point geometry until the drainage line pixel based in the flow direction raster. ';
--COMMENT ON FUNCTION pgh_raster.pghfn_downstream_drainage_area(geometry) IS 'returns the upstream area polygon using as reference the n-1 downstream geometry point';
--COMMENT ON FUNCTION pgh_raster.pghfn_downstream_drainage_point(geometry) IS 'returns the downstream end geometry point';
--COMMENT ON FUNCTION pgh_raster.pghfn_downstream_pixel(geometry) IS 'returns a geometry point representing the centroid pixel imediatelly downstream to the pixel located in the input point geometry based in the flow direction raster.';
--COMMENT ON FUNCTION pgh_raster.pghfn_downstream_pixels(geometry) IS 'returns the geometry point(s) representing all the centroid pixel(s) downstream to the pixels located in the input point geometry until the drainage line pixel based in the flow direction raster.';
--COMMENT ON FUNCTION pgh_raster.pghfn_elevation_pixel_value(geometry) IS 'returns the elevation model value given an input point geometry based in the elevation model raster.';
--COMMENT ON FUNCTION pgh_raster.pghfn_elevation_profile(geometry) IS 'returns the distance, elevation and the geometry point located in the vertex of a given linestring geometry.';
--COMMENT ON FUNCTION pgh_raster.pghfn_elevation_profile(geometry, integer) IS 'returns the equidistance, elevation and geometry point of a given linestring geometry and equidistance along the linestring.';
--COMMENT ON FUNCTION pgh_raster.pghfn_insert_clip_data(character varying, character varying, character varying, character varying, integer, character varying) IS 'returns ';
--COMMENT ON FUNCTION pgh_raster.pghfn_upstream_area(geometry) IS 'returns a geometry of polygon representing the upstream area related to the pixel located in the input point geometry based in the flow direction raster.';
--COMMENT ON FUNCTION pgh_raster.pghfn_upstream_drainage_area(geometry) IS 'returns the upstream area polygon using as reference downstream geometry end point';
--COMMENT ON FUNCTION pgh_raster.pghfn_upstream_pixel(geometry) IS 'returns a geometry of point(s) representing the centroid pixel(s) imediatelly upstream to the pixel located in the input point geometry based in the flow direction raster.';
--COMMENT ON FUNCTION pgh_raster.pghfn_upstream_pixels(geometry) IS 'returns a geometry of point(s) representing all the centroid pixel(s) upstream to the pixel located in the input point geometry based in the flow direction raster.';
--COMMENT ON TABLE pgh_raster.pghrt_elevation IS 'Digital Elevation Model.';
--COMMENT ON TABLE pgh_raster.pghrt_flowaccumulation IS 'Raster that represents how many cells that flows through that cell.';
--COMMENT ON TABLE pgh_raster.pghrt_flowdirection IS 'The Flow Direction raster represents the flow direction from each pixel to its steepest downslope neighbor according to the D8 method.';
--COMMENT ON TABLE pgh_raster.pghrt_flowpath IS 'Raster representing the drainage line.';