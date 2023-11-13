

/*
  
    Copyright (C) 2023

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
    REQUIREMENTS
    - Postgresql version 14
    - PostGIS version 3+
    - PostGIS Raster version 3+
    - PgHydro version 6.6 (of 23 aug 2022)
    - PgH_Raster version 6.6 (of 30 jun 2023)

    Copy to ...\PostgreSQL\14\share\extension

    REPOSITORIES

        https://github.com/pghydro/pghydro
        https://github.com/HGE-IPH/pgh_hgm      

    Authors:  
        Mino V Sorribas, mino.sorribas@gmail.com
        Fernando M Fan, fernando.fan@ufrgs.br
        Stefany G Lima, stefglima@gmail.com
        Maria Eduarda P Alves, duda.epa@gmail.com
        Alexandre de Amorim Teixeira, pghydro.project@gmail.com    
   
*/

---------------------------------------------------------------------------------
--PGH_HGM: PgHydro Hydrological Geomorphology Calculations Extension - v.2.2.3 (2023.10.30)
---------------------------------------------------------------------------------

-------------------------------------
-- DROP AND CREATE SCHEMA
-------------------------------------
DROP SCHEMA IF EXISTS pgh_hgm CASCADE;
CREATE SCHEMA pgh_hgm;



CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_tables_initialize()
  RETURNS CHARACTER VARYING AS
$BODY$
/*
    PREPARE PGH_HGM INTEL TABLE WITH EXISTING ATTRIBUTES FROM PGHYDRO
 
*/

BEGIN

    -- TRUNCATE TABLES
    TRUNCATE TABLE pgh_hgm.pghft_hydro_intel;
    TRUNCATE TABLE pgh_hgm.pghft_drn_elevationprofile;
    TRUNCATE TABLE pgh_hgm.pghft_upn_elevationprofile;

    -- FIRST FILL DRN_PK, DRA_PK AND WTC_PK COLUMNS
    INSERT INTO pgh_hgm.pghft_hydro_intel(
        hig_drn_pk,
        hig_dra_pk,
        hig_wtc_pk,
        hig_drn_strahler,
        hig_dra_area_,
        hig_upa_area_,
        hig_drn_length_,
        hig_dra_area_km2,
        hig_upa_area_km2,
        hig_drn_length_km
        )
    SELECT
        drn.drn_pk,
        dra.dra_pk,
        drn.drn_wtc_pk,
        hin.hin_strahler AS hig_drn_strahler,

        -- user-defined pghydro units
        dra.dra_gm_area AS hig_dra_area_,
        drn.drn_nu_upstreamarea AS hig_upa_area_,
        drn.drn_gm_length AS hig_drn_length_,

        -- assuming km and km2
        dra.dra_gm_area AS hig_dra_area_km2,
        drn.drn_nu_upstreamarea AS hig_upa_area_km2,
        drn.drn_gm_length AS hig_drn_length_km

    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
    INNER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_drn_pk = drn.drn_pk
    ORDER BY drn.drn_pk ASC;

    RAISE NOTICE ' - inherited attributes from pghydro into pgh_hgm.pghft_hydro_intel';
    

    -- CREATE MAIN INDEXES
    DROP INDEX IF EXISTS pgh_hgm.hig_drn_idx;
    DROP INDEX IF EXISTS pgh_hgm.hig_dra_idx;
    DROP INDEX IF EXISTS pgh_hgm.hig_drn_dra_idx;

    CREATE INDEX hig_drn_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_drn_pk);
    CREATE INDEX hig_dra_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_dra_pk);
    CREATE INDEX hig_drn_dra_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_drn_pk,hig_dra_pk);

    RAISE NOTICE ' - primary key indexes included in pgh_hgm.pghft_hydro_intel';


    -- CREATE AUXILIARY INDEXES
    DROP INDEX IF EXISTS pgh_hgm.hig_wtc_idx; 
    DROP INDEX IF EXISTS pgh_hgm.hig_dra_wtc_idx;
    DROP INDEX IF EXISTS pgh_hgm.hig_dra_wtc_strahler_idx;

    CREATE INDEX hig_wtc_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_wtc_pk);
    CREATE INDEX hig_dra_wtc_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_dra_pk,hig_wtc_pk);
    CREATE INDEX hig_dra_wtc_strahler_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_dra_pk,hig_wtc_pk,hig_drn_strahler);


    -- CREATE ELEVATION PROFILE INDEXES (not really useful yet)
    DROP INDEX IF EXISTS pgh_hgm.elpdrn_dra_idx;
    DROP INDEX IF EXISTS pgh_hgm.elpupn_dra_idx;
    CREATE INDEX elpdrn_dra_idx ON pgh_hgm.pghft_drn_elevationprofile USING btree(dra_pk);
    CREATE INDEX elpupn_dra_idx ON pgh_hgm.pghft_upn_elevationprofile USING btree(dra_pk);

    -- CREATE INDEX ON WATERCOURSEORDER
    
    
     -- CALCULATE UPSTREAM MAIN RIVER LENGTH BASED ON WTC/DRN ATTRIBUTES
    -- WHEN DRN IN WATERCOURSE ORDER = 1
    UPDATE pgh_hgm.pghft_hydro_intel
	SET
		hig_upn_length_ = a.hig_upn_length_,
		hig_upn_length_km = a.hig_upn_length_km
	FROM (
        SELECT
			hig_drn_pk AS drn_pk_,
            wtc.wtc_gm_length - drn.drn_nu_distancetosea AS hig_upn_length_,
            wtc.wtc_gm_length - drn.drn_nu_distancetosea AS hig_upn_length_km --assuming km2
        FROM pgh_hgm.pghft_hydro_intel hig
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_pk = hig.hig_drn_pk
        INNER JOIN pghydro.pghft_watercourse wtc ON wtc.wtc_pk = drn.drn_wtc_pk
        WHERE wtc.wtc_nu_pfafstetterwatercoursecodeorder = 1) a
	WHERE hig_drn_pk = a.drn_pk_;
	
    -- WHEN DRN IN WATERCOURSE ORDER > 1
    UPDATE pgh_hgm.pghft_hydro_intel
	SET
		hig_upn_length_ = a.hig_upn_length_,
		hig_upn_length_km = a.hig_upn_length_km
	FROM (
		SELECT
			hig_drn_pk AS drn_pk_,
			wtc.wtc_gm_length - drn.drn_nu_distancetowatercourse AS hig_upn_length_,
			wtc.wtc_gm_length - drn.drn_nu_distancetowatercourse AS hig_upn_length_km  --assuming km2
		FROM pgh_hgm.pghft_hydro_intel hig
		INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_pk = hig.hig_drn_pk
		INNER JOIN pghydro.pghft_watercourse wtc ON wtc.wtc_pk = drn.drn_wtc_pk
		WHERE wtc.wtc_nu_pfafstetterwatercoursecodeorder > 1 ) a
	WHERE hig_drn_pk = a.drn_pk_;


    RETURN 'OK';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


-----------------------------------------
-- CREATE TABLES
-----------------------------------------

-- CREATE AUXILIARY TABLE FOR TEMPORARY 'LOCAL REACH ELEVATION PROFILE'
DROP TABLE IF EXISTS pgh_hgm.pghft_drn_elevationprofile;
CREATE TABLE pgh_hgm.pghft_drn_elevationprofile(
    dra_pk integer,
    xy integer,
    z double precision,
    gm geometry  --NOTE: not really needed
    );

-- CREATE AUXILIARY TABLE FOR TEMPORARY 'MAIN-STREAM ELEVATION PROFILE'
DROP TABLE IF EXISTS pgh_hgm.pghft_upn_elevationprofile;
CREATE TABLE pgh_hgm.pghft_upn_elevationprofile(
    dra_pk integer,
    xy integer,
    z double precision,
    gm geometry  --NOTE: not really needed
    );

    
-- CREATE SEQUENCE FOR PGH_HGM INTEL TABLE
DROP SEQUENCE IF EXISTS pgh_hgm.hig_pk_seq CASCADE;
CREATE SEQUENCE pgh_hgm.hig_pk_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

-- CREATE PGH_HGM INTEL TABLE
DROP TABLE IF EXISTS pgh_hgm.pghft_hydro_intel;
CREATE TABLE pgh_hgm.pghft_hydro_intel(
    
    ----------------------------------------------
    -- PRIMARY AND AUXILIARY KEYS
    ----------------------------------------------
    hig_pk integer DEFAULT nextval('pgh_hgm.hig_pk_seq'::regclass),
    hig_drn_pk integer,
    hig_dra_pk integer,
    hig_wtc_pk integer,    -- watercourses, helpful as 'null' is coastline
    hig_drn_strahler integer,  -- helpful to get headwaters

    --hig_drn_gm geometry, -- easy outputs.

    ----------------------------------------------
    -- DEM BASED
    --------------------------------------------
    -- depends on elevation profile
    -- stream elevation
    hig_drn_elevation_avg double precision,
    hig_drn_elevation_max double precision,
    hig_drn_elevation_min double precision,
    -- stream elevation drop
    hig_drn_elevationdrop_maxmin double precision,
    hig_drn_elevationdrop_s1585 double precision,
    hig_drn_elevationdrop_pipf double precision,
    hig_drn_elevationdrop_z1585 double precision, 
    hig_drn_elevationdrop_harmonic double precision,
    hig_drn_elevationdrop_weighted double precision,       
    hig_drn_elevationdrop_linreg double precision,
    -- stream slopes
    hig_drn_slope_maxmin double precision,
    hig_drn_slope_s1585 double precision,
    hig_drn_slope_pipf double precision,
    hig_drn_slope_z1585 double precision,
    hig_drn_slope_harmonic double precision,
    hig_drn_slope_weighted double precision,
    hig_drn_slope_linreg double precision,
    
    
    ----------------------------------------------
    -- GEOMETRY AND HYDROGEOMORPHOLOGY
    ----------------------------------------------
    
    ---------------------------------------------
    --- LOCAL CATCHMENT
    ---------------------------------------------
    -- local catchment pghydro attributes 
    hig_dra_area_ double precision,         -- pghydro input units    
    hig_dra_area_km2 double precision,      -- pgh_hgm standard    
    
    -- "pghydro eligible" local cathcment attributes...
    hig_dra_perimeter_ double precision,    -- pghydro input units   
    hig_dra_perimeter_km double precision,    

    -- new local cathcment attributes...
    hig_dra_axislength double precision, -- axial length
    hig_dra_circularity double precision, -- circularity
    hig_dra_compacity double precision, -- compacity
    hig_dra_shapefactor double precision, -- shape factor
    hig_dra_formfactor double precision, -- form factor
    
    -- drainage...
    hig_drn_sinuosity double precision, -- sinuosity, actually from drainage

    -- more local cathcment attributes (requires DEM)
    -- calculated using internal call to .pghfn_drn_drn_elevation_profile
    hig_dra_reliefratio  double precision,  -- relief ratio
    hig_dra_reachgradient  double precision,  -- reach gradient
      

    -- catchment elevation stats
    hig_dra_elevation_avg double precision,
    hig_dra_elevation_max double precision,
    hig_dra_elevation_min double precision,
    hig_dra_elevationdrop_m  double precision,   -- maxmin based 
    
    -- "strange" area attributes for local catchment
    hig_dra_drainagedensity double precision,  -- drainage density
    hig_dra_hydrodensity double precision,  -- hydro density
    hig_dra_avglengthoverlandflow double precision,  -- average length of overflow land      

    ----------------------------------------------
    -- LOCAL STREAM/DRAINAGE HYDRAULICS
    ----------------------------------------------   
    -- "pghydro eligible" local drainage attributes...
    hig_drn_length_ double precision,         -- pghydro input units    
    hig_drn_length_km double precision,       -- pgh_hgm standard

    -- depth and width geomorphological relations
    hig_drn_depth_m  double precision,
    hig_drn_width_m  double precision,

    -- stream drop, slope and manning roughness
    hig_drn_elevationdrop_m  double precision,        -- we assume: maxmin method
    hig_drn_slope_adim  double precision,    -- we assume: maxmin method
    hig_drn_manning_n  double precision,

    --  wave-travel "manning" hydraulics (velocities, celerities, travel)
    hig_drn_velmann  double precision,
    hig_drn_celmann  double precision,
    hig_drn_trlmann  double precision, -- minutes
    hig_drn_velmann_lr  double precision,
    hig_drn_celmann_lr  double precision,
    hig_drn_trlmann_lr   double precision,
    
    -- wave travel: dynamic wave
    hig_drn_celdyna double precision,
    hig_drn_trldyna double precision,

    ---------------------------------------------
    --- UPSTREAM AREA
    ---------------------------------------------    
    -- upstream area pghydro attributes
    hig_upa_area_ double precision,        -- input unit           
    hig_upa_area_km2 double precision,     -- km2
    
    -- "pghydro eligible" upstream geometry attributes...
    hig_upa_perimeter_ double precision,   -- input unit 
    hig_upa_perimeter_km double precision, -- km

    -- new upstream area attributes
    hig_upa_drainagedensity double precision,  -- drainage density
    hig_upa_hydrodensity double precision,  -- hydro density
    hig_upa_avglengthoverlandflow double precision,  -- average length of overflow land
    hig_upa_totaldrainagelength double precision,  -- sum of lengths upstream
    
    -- "catchment attributes" applied to upstream area scale
    hig_upa_axislength double precision, -- axial length    
    hig_upa_circularity double precision, -- circularity
    hig_upa_compacity double precision, -- compacity
    hig_upa_shapefactor double precision, -- shape factor
    hig_upa_formfactor double precision, -- form factor
    
    -- drainage...
    hig_upn_sinuosity double precision, -- sinuosity
    
    
    -- MS: catchment elevation stats
    hig_upa_elevation_avg double precision,
    hig_upa_elevation_max double precision,
    hig_upa_elevation_min double precision,
    hig_upa_elevationdrop_m  double precision,   -- maxmin based
    
    -- MS: dem-based stats
    hig_upa_reliefratio  double precision,  -- relief ratio
    hig_upa_reachgradient  double precision,  -- reach gradient

   
    ----------------------------------------------
    -- TIME OF CONCENTRATION
    ----------------------------------------------
    -- local drainage/area 
    -- note: dra attribute
    hig_dra_tc_kirpich double precision,    
    hig_dra_tc_dooge double precision,
    hig_dra_tc_carter double precision,
    hig_dra_tc_armycorps double precision,
    hig_dra_tc_wattchow double precision,
    hig_dra_tc_kirpicha double precision, -- kirpich's based on dra/upa _elevation_drop_m    
    hig_dra_tc_georgeribeiro double precision,
    hig_dra_tc_pasini double precision,
    hig_dra_tc_ventura double precision,
    hig_dra_tc_dnosk1 double precision,
    
    
    -- upstream area/main river (upa)
    hig_upa_tc_kirpich double precision,
    hig_upa_tc_dooge double precision,
    hig_upa_tc_carter double precision,
    hig_upa_tc_armycorps double precision,
    hig_upa_tc_wattchow double precision,
    hig_upa_tc_kirpicha double precision, -- kirpich's based on dra/upa _elevation_drop_m
    hig_upa_tc_georgeribeiro double precision, 
    hig_upa_tc_pasini double precision,
    hig_upa_tc_ventura double precision,
    hig_upa_tc_dnosk1 double precision,     
    
    

    ----------------------------------------------
    -- UPSTREAM MAIN-RIVER ATTRIBUTES
    ----------------------------------------------
    -- "main-river"  (upn)
    hig_upn_elevation_avg double precision,
    hig_upn_elevation_max double precision,
    hig_upn_elevation_min double precision,
    
    hig_upn_length_ double precision,            -- pghydro input units 
    hig_upn_length_km double precision,
    hig_upn_elevationdrop_m  double precision,   -- maxmin based
    hig_upn_slope_adim  double precision,        -- maxmin based 
    --... required for time of concentration

    -- stream slopes
    hig_upn_slope_maxmin double precision,
    hig_upn_slope_s1585 double precision,
    hig_upn_slope_pipf double precision,
    hig_upn_slope_z1585 double precision,
    hig_upn_slope_harmonic double precision,
    hig_upn_slope_weighted double precision,
    hig_upn_slope_linreg double precision,

    -- elevation profile drop
    hig_upn_elevationdrop_maxmin double precision,
    hig_upn_elevationdrop_s1585 double precision,
    hig_upn_elevationdrop_pipf double precision,
    hig_upn_elevationdrop_z1585 double precision, 
    hig_upn_elevationdrop_harmonic double precision,
    hig_upn_elevationdrop_weighted double precision,
    hig_upn_elevationdrop_linreg double precision,    
    
    
    ----------------------------------------------
    -- JOBSON'S SCALAR TRANSPORT/TRAVEL TIME MODEL FOR DRAINAGE
    ----------------------------------------------
    -- inputs to jobson
    hig_drn_annual_flow  double precision,
    hig_drn_event_flow  double precision,

    -- jobson outputs
    hig_drn_jobson_tpeak double precision,
    hig_drn_jobson_tlead double precision,
    hig_drn_jobson_tpeak_shortest double precision,
    hig_drn_jobson_tlead_shortest double precision,
    
    ----------------------------------------------
    -- temporary merged-upstream geometries
    ----------------------------------------------    
    -- main river upstream (upn) and merged upstream area (polygon)
    hig_upn_gm geometry,
    hig_upa_gm geometry,

    
    
    ----------------------------------------------
    -- experimental: reservoirs features
    ----------------------------------------------
    -- input table columns
    hig_drn_reservoir_depth_m  double precision,
    hig_drn_reservoir_length_m  double precision,
    -- outputs (pgh_hgm.pghfn_drn_wavetravel_reservoir)
    hig_drn_reservoir_celwave double precision,
    hig_drn_reservoir_trlwave double precision,
    
    
    ------------------------------------------------
    -- additional methods for axis length and related attributes
    ------------------------------------------------
    hig_dra_axislength_schumm double precision, -- axis length
    hig_dra_shapefactor_schumm double precision, -- shape factor
    hig_dra_formfactor_schumm double precision, -- form factor
    hig_dra_reliefratio_schumm double precision, -- relief ratio
    
    hig_dra_axislength_ring double precision, -- axis length
    hig_dra_shapefactor_ring double precision, -- shape factor
    hig_dra_formfactor_ring double precision, -- form factor
    hig_dra_reliefratio_ring double precision, -- relief ratio
    
    hig_dra_axislength_river double precision, -- axis length
    hig_dra_shapefactor_river double precision, -- shape factor
    hig_dra_formfactor_river double precision, -- form factor 
    hig_dra_reliefratio_river double precision, -- relief ratio   

    hig_upa_axislength_schumm double precision, -- axis length
    hig_upa_shapefactor_schumm double precision, -- shape factor
    hig_upa_formfactor_schumm double precision, -- form factor
    hig_upa_reliefratio_schumm double precision, -- relief ratio

    hig_upa_axislength_ring double precision, -- axis length
    hig_upa_shapefactor_ring double precision, -- shape factor
    hig_upa_formfactor_ring double precision, -- form factor
    hig_upa_reliefratio_ring double precision, -- relief ratio

    hig_upa_axislength_river double precision, -- axis length
    hig_upa_shapefactor_river double precision, -- shape factor
    hig_upa_formfactor_river double precision, -- form factor    
    hig_upa_reliefratio_river double precision -- relief ratio
);



-- FILL TABLES WITH DATA FROM PGHYDRO SCHEMA
-- SELECT pgh_hgm.pghfn_tables_initialize();

-- COMMANDS FOR VACUUM
--VACUUM(FULL, ANALYZE) pgh_hgm.pghft_hydro_intel;
--VACUUM(FULL, ANALYZE) pgh_hgm.pghft_drn_elevationprofile;
--VACUUM(FULL, ANALYZE) pgh_hgm.pghft_upn_elevationprofile;

-------------------------------------
--CREATE FUNCTIONS
-------------------------------------


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_elevationprofile(
    IN dra_pk_ integer)
  RETURNS TABLE(dra_pk integer, xy integer, z double precision, gm geometry) AS
$BODY$
/*
    QUERY DRAINAGE LINE ELEVATION PROFILE
    USING DRA_PK

    calls:
        pgh_raster.pghfn_elevation_profile() -> returns (xy integer, z double precision, gm geometry)

*/
DECLARE
    srid_dem integer;

BEGIN

    -- get DEM srid
    SELECT srid INTO srid_dem
    FROM public.raster_columns
    WHERE r_table_schema = 'pgh_raster' AND r_table_name = 'pghrt_elevation';

    -- main query
    RETURN
    QUERY

    SELECT
        dra_pk_ AS dra_pk,
        a.xy,
        a.z,
        a.gm
    FROM (
        -- CALL PGH_RASTER
        SELECT
            (pgh_raster.pghfn_elevation_profile(line_gm)).*  -- original spacing using pgh_raster
            -- (pgh_raster.pghfn_elevation_profile(line_gm,60)).*    -- 60 m spacing using pgh_raster
            --(pgh_hgm.pghfn_geom_elevationprofile(line_gm)).*  -- original spacing using pgh_hgm standalone function
        FROM
            (
            -- PREPARE DRAINAGE POINTS (FROM DRAINAGE LINE) TO PGH_RASTER
            SELECT
                ST_TRANSFORM( (ST_DUMP(drn_gm)).geom, srid_dem)    AS line_gm
            FROM pghydro.pghft_drainage_area dra
            INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
            WHERE dra.dra_pk = dra_pk_
            ) a
        ) a;

RETURN;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;



CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_elevations(
    IN dra_pk_ integer)
 RETURNS TABLE(dra_pk integer, pixels double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - ELEVATIONS FROM DEM
    BY CLIPPING 'dra_gm' with 'pgh_raster.elevation'
    USING DRA_PK

*/

DECLARE
    srid_dem integer;

BEGIN

    -- get DEM srid
    SELECT srid INTO srid_dem
    FROM public.raster_columns
    WHERE r_table_schema = 'pgh_raster' AND r_table_name = 'pghrt_elevation';

    -- query
    RETURN
    QUERY
    
    SELECT
        dra_pk_ as dra_pk,
        a.pixels
    FROM (    

        SELECT
            UNNEST((st_dumpvalues(rclip)).valarray) as pixels
        FROM (
            --- CLIP RASTER IN POLYGON INTERSECTION
            SELECT
                ST_CLIP(rast, g.dra_gm_srid_dem, -9999) as rclip
            FROM pgh_raster.pghrt_elevation r
            INNER JOIN
            (
            -- JOIN WITH CATCHMENT
                SELECT
                    ST_TRANSFORM(dra_gm, srid_dem) AS dra_gm_srid_dem
                FROM pghydro.pghft_drainage_area dra
                WHERE dra.dra_pk = dra_pk_
            ) g
            -- SPATIAL JOIN
            ON ST_Intersects(r.rast, g.dra_gm_srid_dem)
        ) a
    ) a
    WHERE a.pixels IS NOT NULL;   

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    

    CREATE OR REPLACE VIEW pgh_hgm.geoft_bho_hgm AS
    SELECT
        hig_pk, hig_drn_pk, hig_dra_pk, hig_wtc_pk, hig_drn_strahler,
        hig_drn_elevation_avg, hig_drn_elevation_max, hig_drn_elevation_min, hig_drn_elevationdrop_maxmin, hig_drn_elevationdrop_s1585, hig_drn_elevationdrop_pipf, hig_drn_elevationdrop_z1585, hig_drn_elevationdrop_harmonic, hig_drn_elevationdrop_weighted, hig_drn_elevationdrop_linreg, hig_drn_slope_maxmin, hig_drn_slope_s1585, hig_drn_slope_pipf, hig_drn_slope_z1585, hig_drn_slope_harmonic, hig_drn_slope_weighted, hig_drn_slope_linreg,
        hig_dra_area_, hig_dra_area_km2, hig_dra_perimeter_, hig_dra_perimeter_km, hig_dra_axislength, hig_dra_circularity, hig_dra_compacity, hig_dra_shapefactor, hig_dra_formfactor, hig_drn_sinuosity, hig_dra_reliefratio, hig_dra_reachgradient, hig_dra_elevation_avg, hig_dra_elevation_max, hig_dra_elevation_min, hig_dra_elevationdrop_m, hig_dra_drainagedensity, hig_dra_hydrodensity, hig_dra_avglengthoverlandflow,
        hig_drn_length_, hig_drn_length_km, hig_drn_depth_m, hig_drn_width_m, hig_drn_elevationdrop_m, hig_drn_slope_adim, hig_drn_manning_n, hig_drn_velmann, hig_drn_celmann, hig_drn_trlmann, hig_drn_velmann_lr, hig_drn_celmann_lr, hig_drn_trlmann_lr, hig_drn_celdyna, hig_drn_trldyna,
        hig_upa_area_, hig_upa_area_km2, hig_upa_perimeter_, hig_upa_perimeter_km, hig_upa_drainagedensity, hig_upa_hydrodensity, hig_upa_avglengthoverlandflow, hig_upa_totaldrainagelength, hig_upa_axislength, hig_upa_circularity, hig_upa_compacity, hig_upa_shapefactor, hig_upa_formfactor, hig_upn_sinuosity, hig_upa_elevation_avg, hig_upa_elevation_max, hig_upa_elevation_min, hig_upa_elevationdrop_m, hig_upa_reliefratio, hig_upa_reachgradient,
        hig_dra_tc_kirpich, hig_dra_tc_dooge, hig_dra_tc_carter, hig_dra_tc_armycorps, hig_dra_tc_wattchow,
        hig_upa_tc_kirpich, hig_upa_tc_dooge, hig_upa_tc_carter, hig_upa_tc_armycorps, hig_upa_tc_wattchow,
        hig_upn_elevation_avg, hig_upn_elevation_max, hig_upn_elevation_min, hig_upn_length_, hig_upn_length_km, hig_upn_elevationdrop_m, hig_upn_slope_adim, hig_upn_slope_maxmin, hig_upn_slope_s1585, hig_upn_slope_pipf, hig_upn_slope_z1585, hig_upn_slope_harmonic, hig_upn_slope_weighted, hig_upn_slope_linreg, hig_upn_elevationdrop_maxmin, hig_upn_elevationdrop_s1585, hig_upn_elevationdrop_pipf, hig_upn_elevationdrop_z1585, hig_upn_elevationdrop_harmonic, hig_upn_elevationdrop_weighted, hig_upn_elevationdrop_linreg,
        hig_drn_annual_flow, hig_drn_event_flow, hig_drn_jobson_tpeak, hig_drn_jobson_tlead, hig_drn_jobson_tpeak_shortest, hig_drn_jobson_tlead_shortest,
        --hig_upn_gm, hig_upa_gm,
        hig_drn_reservoir_depth_m, hig_drn_reservoir_length_m,
        hig_drn_reservoir_celwave, hig_drn_reservoir_trlwave,
        -- BONUS info
        hig_dra_axislength_schumm, hig_dra_shapefactor_schumm, hig_dra_formfactor_schumm, hig_dra_reliefratio_schumm,
        hig_dra_axislength_ring, hig_dra_shapefactor_ring, hig_dra_formfactor_ring, hig_dra_reliefratio_ring,
        hig_dra_axislength_river, hig_dra_shapefactor_river, hig_dra_formfactor_river, hig_dra_reliefratio_river,
        hig_upa_axislength_schumm, hig_upa_shapefactor_schumm, hig_upa_formfactor_schumm, hig_upa_reliefratio_schumm,
        hig_upa_axislength_ring, hig_upa_shapefactor_ring, hig_upa_formfactor_ring, hig_upa_reliefratio_ring,
        hig_upa_axislength_river, hig_upa_shapefactor_river, hig_upa_formfactor_river, hig_upa_reliefratio_river,
        drn_gm  -- get drainage geometry
    FROM pgh_hgm.pghft_hydro_intel hig
    INNER JOIN pghydro.pghft_drainage_line drn ON hig_drn_pk = drn_pk;

 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_avglengthoverlandflow(
    srid_area integer,
    srid_length integer)
 RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - 'AVERAGE LENGTH OF OVERLAND FLOW
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE);    


    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP

        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- good to gofrom pghydro
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_avglengthoverlandflow = a.avglengthoverlandflow
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_avglengthoverlandflow(i,1.,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;
    RETURN 'OK'; 

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_axislength(
    srid_area integer,
    srid_length integer)
 RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - AXIS LENGTH
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_axislength = a.axislength 
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_axislength(i,srid_length) -- axis length     
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;
        

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_bonus_ring(
    srid_area integer,
    srid_length integer)
 RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - AXIS LENGTH, SHAPEFACTOR, FORMFACTOR, RELIEF RATIO
    (XIS LENGTH AS 'MAX DISTANCE IN EXTERIOR RING APPROACH)
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- EXPERIMENTAL: "RING APPROACH" VARIANTS OF SOME CATCHMENTS ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_axislength_ring = a.axislength_ring,
            hig_dra_shapefactor_ring = a.shapefactor_ring,
            hig_dra_formfactor_ring = a.formfactor_ring,          
            hig_dra_reliefratio_ring = a.reliefratio_ring
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_axislength_ring(i,srid_length), -- axial length            
                pgh_hgm.pghfn_dra_shapefactor_ring(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor_ring(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_dra_reliefratio_ring(i,srid_length) -- relief ratio (require catchment DEM)
                        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 
 
        
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_bonus_river(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - AXIS LENGTH, SHAPEFACTOR, FORMFACTOR, RELIEF RATIO
    (AXIS LENGTH ~ RIVER LENGTH APPROACH)
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- EXPERIMENTAL: "RIVER AXIS" VARIANTS OF SOME CATCHMENTS ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_axislength_river = a.axislength_river,
            hig_dra_shapefactor_river = a.shapefactor_river,
            hig_dra_formfactor_river = a.formfactor_river,          
            hig_dra_reliefratio_river = a.reliefratio_river
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_axislength_river(i,srid_length), -- axial length
                pgh_hgm.pghfn_dra_shapefactor_river(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor_river(i,srid_area,srid_length),  -- form factor
                pgh_hgm.pghfn_dra_reliefratio_river(i,srid_length) -- relief ratio (require catchment DEM)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

        
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;
    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_bonus_schumm(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - AXIS LENGTH, SHAPEFACTOR, FORMFACTOR, RELIEF RATIO
    (SCHUMM'S EQUATIONS APPROACH)
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- EXPERIMENTAL: "SCHUMM'S EQUATION" VARIANTS OF SOME CATCHMENTS ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_axislength_schumm = a.axislength_schumm,
            hig_dra_shapefactor_schumm = a.shapefactor_schumm,
            hig_dra_formfactor_schumm = a.formfactor_schumm,          
            hig_dra_reliefratio_schumm = a.reliefratio_schumm

        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_axislength_schumm(i,1.), -- axial length            
                pgh_hgm.pghfn_dra_shapefactor_schumm(i,1.),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor_schumm(i,1.),  -- form factor        
                pgh_hgm.pghfn_dra_reliefratio_schumm(i,1.) -- relief ratio (require catchment DEM)                        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;     


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_circularity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - CIRCULARITY
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_circularity = a.circularity      
        FROM (
            SELECT
                *
            FROM            
                pgh_hgm.pghfn_dra_circularity(i,srid_area,srid_length) --circularity
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


   -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_compacity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - COMPACITY
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_compacity = a.compacity  
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_compacity(i,srid_area,srid_length) -- compacity
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

  
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_drainagedensity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - DRAINAGE DENSITY
    
    note:
    - see 'upa_drainagedensity' for a more interpretable attribute
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- good to gofrom pghydro
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_drainagedensity = a.drainagedensity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_drainagedensity(i,1.,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

    -- FINISH
    END LOOP;

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';   

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_elevations_stats(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - ELEVATIONS STATISTICS 
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_elevation_avg = a.dra_elevation_avg,
            hig_dra_elevation_max = a.dra_elevation_max,
            hig_dra_elevation_min = a.dra_elevation_min,            
            hig_dra_elevationdrop_m = a.dra_elevationdrop_maxmin
        FROM (
            SELECT
                dra_elevation_avg,
                dra_elevation_max,
                dra_elevation_min,
                dra_elevationdrop_maxmin
            FROM pgh_hgm.pghfn_dra_elevations_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 
    
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_formfactor(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - FORM FACTOR
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_formfactor = a.formfactor       
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_formfactor(i,srid_area,srid_length)  -- form factor                    
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_hydrodensity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - HYDRO DENSITY (NUMBER OF RIVERS PER KM2)

    note:
    - see 'upa_hydrodensity' for a more interpretable attribute

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- good to gofrom pghydro
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_hydrodensity = a.hydrodensity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_hydrodensity(i,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 


    -- FINISH
    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_kirpicha(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - TIME OF CONCENTRATION
    BASED ON KIRPICH'S EQUATION USING 'CATCHMENT ELEVATION DROP'

    requires:        
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
        PERFORM pgh_hgm.pghfn_dra_elevation_stats(i)
        actually, hig_drn_length_km, hig_dra_elevationdrop_m
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        -- REQUIRES hig_drn_length_km, hig_dra_elevationdrop_m
        
        -- TIME OF CONCENTRATION
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_tc_kirpicha = a.tc_kirpicha 
        FROM (
            SELECT
                tc_kirpicha
            FROM pgh_hgm.pghfn_dra_kirpicha(i)   
            ) a
        WHERE hig_dra_pk = i 
            AND hig_wtc_pk IS NOT NULL
            AND hig_dra_elevationdrop_m > 0.;      

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_perimeter(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - PERIMETER
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_perimeter_ = a.perimeter,
            hig_dra_perimeter_km = a.perimeter/1000   
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_perimeter(i,srid_length,1.)   -- perimeter in m
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_reachgradient(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - REACH GRADIENT
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_reachgradient = a.reachgradient       
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_reachgradient(i)  -- reach gradient (redundant to slope)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_reliefratio(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - RELIEF RATIO
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN
    
    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
   
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET         
            hig_dra_reliefratio = a.reliefratio      
        FROM (
            SELECT
                *
            FROM                  
                pgh_hgm.pghfn_dra_reliefratio(i,srid_length) -- relief ratio (require catchment DEM)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_shapefactor(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL CATCHMENT - SHAPE FACTOR
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN
    
    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_shapefactor = a.shapefactor      
        FROM (
            SELECT
                *
            FROM    
                pgh_hgm.pghfn_dra_shapefactor(i,srid_area,srid_length)  -- shape factor
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_dra_timeofconcentration(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - TIME OF CONCENTRATION
    USING EQUATIONS FROM ARMY CORPS, CARTER, DOOGE, KIRPICH, WATTCHOW

    requires:        
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
        actually only 'hig_drn_slope_adim' and 'hig_drn_elevationdrop_m'
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        -- PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
        
        -- TIME OF CONCENTRATION
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_tc_armycorps = a.tc_armycorps,
            hig_dra_tc_carter = a.tc_carter,
            hig_dra_tc_dooge = a.tc_dooge,
            hig_dra_tc_kirpich = a.tc_kirpich,
            hig_dra_tc_wattchow = a.tc_wattchow,
            hig_dra_tc_georgeribeiro = a.tc_georgeribeiro,
            hig_dra_tc_pasini = a.tc_pasini,
            hig_dra_tc_ventura = a.tc_ventura,
            hig_dra_tc_dnosk1 = a.tc_dnosk1            
        FROM (
            SELECT
                tc_armycorps,
                tc_carter,
                tc_dooge,
                tc_kirpich,
                tc_wattchow,
                tc_georgeribeiro
                tc_pasini,
                tc_ventura,
                tc_dnosk1                
            FROM pgh_hgm.pghfn_dra_timeofconcentration(i)   
            ) a
        WHERE hig_dra_pk = i 
            AND hig_wtc_pk IS NOT NULL
            AND hig_drn_slope_adim>0.;      

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_amhg_depth_width(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - DEPTH AND WIDTH (AT-MANY-STATIONS HYDRAULIC GEOMETRY, AMHG)
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN
    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_depth_m = a.hig_drn_depth_m,
            hig_drn_width_m = a.hig_drn_width_m
        FROM (
            SELECT 
                *
            FROM
                pgh_hgm.pghfn_drn_amhg_depthfromarea(i,1.),
                pgh_hgm.pghfn_drn_amhg_widthfromarea(i,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_elevationprofiledrop_from_slopes(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE EQUIVALENTE DROP
    FROM SLOPES STORED IN PGHFT_HYDRO_INTEL
    SLOPE MAXMIN, S15-85, PIPF, Z15-85, HARMONIC, WEIGHTED, LINREG

    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_drn_length_km
    -hig_drn_slope_maxmin,
    -hig_drn_slope_s1585,
    -hig_drn_slope_pipf,
    -hig_drn_slope_z1585,
    -hig_drn_slope_harmonic,
    -hig_drn_slope_weighted,
    -hig_drn_slope_linreg


*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;


BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();


        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_elevationdrop_maxmin = a.elevationdrop_maxmin,
            hig_drn_elevationdrop_s1585 = a.elevationdrop_s1585,
            hig_drn_elevationdrop_pipf = a.elevationdrop_pipf,
            hig_drn_elevationdrop_z1585  = a.elevationdrop_z1585,
            hig_drn_elevationdrop_harmonic = a.elevationdrop_harmonic,
            hig_drn_elevationdrop_weighted = a.elevationdrop_weighted,
            hig_drn_elevationdrop_linreg = a.elevationdrop_linreg
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_drn_elevationprofiledrop_from_slopes(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


        
    
    -- FINISH
    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_elevationprofile_stats(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE STATISTICS
    AVERAGE, MAX, MIN

    requires:
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN
    
    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');

        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_elevation_avg = a.elevation_avg,
            hig_drn_elevation_max = a.elevation_max,
            hig_drn_elevation_min = a.elevation_min
        FROM (
            SELECT
                elevation_avg, elevation_max, elevation_min
            FROM pgh_hgm.pghfn_drn_tmp_elevationprofile_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_jobson_initialize(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    INITIALIZE
    + DEFAULT JOBSON PARAMETERS
    
    note:
        it assumes hydraulic parameters are already pre-processed.

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');
        --PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(:);
    calls:
       PERFORM pgh_hgm.pghfn_utils_drn_jobson_defaults(i)  

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();
        
        ----------------------------------------------------------------
        -- INSERT ELEVATION PROFILE AT 'pgh_hgm.pghft_upn_elevationprofile'
        ----------------------------------------------------------------
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');


        ----------------------------------------------------------------
        -- DEFAULTS FOR DRAINAGE LINE
        ----------------------------------------------------------------
        --PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);   

        ----------------------------------------------------------------
        -- DEFAULTS FOR JOBSON
        ---------------------------------------------------------------- 
        PERFORM pgh_hgm.pghfn_utils_drn_jobson_defaults(i);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        --...
 
    -- FINISH
    END LOOP;

    RETURN 'OK';
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;

    RETURN 'OK';    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_jobson_traveltime(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - JOBSON'S TRAVELTIME

    requires:
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
        PERFORM pgh_hgm.pghfn_utils_drn_jobson_defaults(i);
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
        --PERFORM pgh_hgm.pghfn_utils_drn_jobson_defaults(i);
        
        -- TIME OF PEAK AND TIME OF LEAD-EDGING (FROM START TO END OF REACH LENGTH)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_jobson_tpeak = a.hig_drn_jobson_tpeak,
            hig_drn_jobson_tlead = a.hig_drn_jobson_tlead,
            hig_drn_jobson_tpeak_shortest = a.hig_drn_jobson_tpeak_shortest,
            hig_drn_jobson_tlead_shortest = a.hig_drn_jobson_tlead_shortest        
        FROM (
            SELECT 
                hig_drn_jobson_tpeak,
                hig_drn_jobson_tlead,
                hig_drn_jobson_tpeak_shortest,
                hig_drn_jobson_tlead_shortest
            FROM pgh_hgm.pghfn_drn_jobson_traveltime(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;        

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_sinuosity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - SINUOSITY
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;


BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_sinuosity = a.sinuosity        
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_drn_sinuosity(i,srid_length) -- sinuosity, actually a drainage attribute
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_harmonic(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE HARMONIC SLOPE

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');      
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_harmonic = a.slope_harmonic  
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_harmonic(i)         
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_linreg(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE LINEAR REGRESSION SLOPE

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');      
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;


BEGIN
    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_linreg = a.slope_linreg     
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_linreg(i)           
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_maxmin(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE MAXMIN SLOPE 

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');       
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_maxmin = a.slope_maxmin      
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_maxmin(i)         
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_pipf(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE PIPF SLOPE 

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');       
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_pipf = a.slope_pipf      
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_pipf(i)        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_s1585(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE SLOPE S15-85

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');   
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_s1585 = a.slope_s1585   
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_s1585(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 
        
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_weighted(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE WEIGHTED SLOPE

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');       
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_weighted = a.slope_weighted    
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_weighted(i)        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 
        
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_slope_z1585(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - ELEVATION PROFILE SLOPE Z15-85

    requires:
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');       
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN
    
    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');
                
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_z1585 = a.slope_z1585   
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_tmp_slope_z1585(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    
    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

    RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_drn_wavetravel(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE LOCAL DRAINAGE - WAVE TRAVEL
        VELOCITY, CELERITY, TRAVEL TIME USING MANNING'S EQUATION,
        VELOCITY, CELERITY, TRAVEL TIME USING MANNING'S EQUATION & LARGE RIVER ASSUMPTION(RH~H),
        CELERITY OF DYNAMIC WAVE

    requires:
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();



        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- PREPARE
        -- PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i); 

       
        -- KINEMATIC HYDRAULICS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_velmann = a.hig_drn_velmann,
            hig_drn_celmann = a.hig_drn_celmann,
            hig_drn_trlmann = a.hig_drn_trlmann_minutes,
            hig_drn_velmann_lr = a.hig_drn_velmann_lr,
            hig_drn_celmann_lr = a.hig_drn_celmann_lr,
            hig_drn_trlmann_lr = a.hig_drn_trlmann_lr_minutes        
        FROM (
            SELECT 
                hig_drn_velmann,
                hig_drn_celmann,
                hig_drn_trlmann_minutes,
                hig_drn_velmann_lr,
                hig_drn_celmann_lr,
                hig_drn_trlmann_lr_minutes
            FROM pgh_hgm.pghfn_drn_wavetravel_kinematic(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_slope_adim>0.;


        -- DYNAMIC WAVE
        UPDATE pgh_hgm.pghft_hydro_intel
        SET 
            hig_drn_celdyna = a.hig_drn_celdyna,
            hig_drn_trldyna = a.hig_drn_trldyna_minutes
        FROM (
            SELECT
                hig_drn_celdyna,
                hig_drn_trldyna_minutes
            FROM pgh_hgm.pghfn_drn_wavetravel_dynamic(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 

    -- FINISH
    END LOOP;
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_avglengthoverlandflow(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - AVERAGE LENGTH OF OVERLAND FLOW

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_avglengthoverlandflow = a.avglengthoverlandflow
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_avglengthoverlandflow(i,1.,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_axislength(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - AXIS LENGTH

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);    
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE); 


    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP    
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_axislength = a.axislength
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_axislength(i,srid_length) -- axial length              
                
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_bonus_ring(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - AXIS LENGTH, SHAPEFACTOR, FORMFACTOR, RELIEF RATIO
    (AXIS RING AS 'MAX DISTANCE IN EXTERIOR RING' APPROACH)

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);  
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- EXPERIMENTAL: 'RING AXIS" VARIANTS OF SOME CATCHMENTS ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_axislength_ring = a.axislength_ring,
            hig_upa_shapefactor_ring = a.shapefactor_ring,
            hig_upa_formfactor_ring = a.formfactor_ring,          
            hig_upa_reliefratio_ring = a.reliefratio_ring
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_axislength_ring(i,srid_length), -- axial length            
                pgh_hgm.pghfn_upa_shapefactor_ring(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor_ring(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_upa_reliefratio_ring(i,srid_length) -- relief ratio (require catchment DEM)                     
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;   

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_bonus_river(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - AXIS LENGTH, SHAPEFACTOR, FORMFACTOR, RELIEF RATIO
    (RIVER ~ MAIN AXIS APPROACH)

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);     

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);  

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- EXPERIMENTAL: "RIVER AXIS" VARIANTS OF SOME CATCHMENTS ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_axislength_river = a.axislength_river,
            hig_upa_shapefactor_river = a.shapefactor_river,
            hig_upa_formfactor_river = a.formfactor_river,          
            hig_upa_reliefratio_river = a.reliefratio_river
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_axislength_river(i,srid_length), -- axial length            
                pgh_hgm.pghfn_upa_shapefactor_river(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor_river(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_upa_reliefratio_river(i,srid_length) -- relief ratio (require catchment DEM)               
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;   

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_bonus_schumm(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM CATCHMENT - AXIS LENGTH, SHAPEFACTOR, FORMFACTOR, RELIEF RATIO
    (USING SCHUMM'S EQUATIONS)

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);  

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);   

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------  
        -- EXPERIMENTAL: SCHUMM'S VARIANTS OF SOME CATCHMENTS ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_axislength_schumm = a.axislength_schumm,
            hig_upa_shapefactor_schumm = a.shapefactor_schumm,
            hig_upa_formfactor_schumm = a.formfactor_schumm,          
            hig_upa_reliefratio_schumm = a.reliefratio_schumm

        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_axislength_schumm(i), -- axial length            
                pgh_hgm.pghfn_upa_shapefactor_schumm(i),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor_schumm(i),  -- form factor        
                pgh_hgm.pghfn_upa_reliefratio_schumm(i) -- relief ratio (require catchment DEM)                        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;   

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);


    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_circularity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM CATCHMENT - CIRCULARITY

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_circularity = a.circularity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_circularity(i,srid_area,srid_length) --circularity        
                
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;
    

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_compacity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - COMPACITY

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_compacity = a.compacity
        FROM (
            SELECT
                *
            FROM     
                pgh_hgm.pghfn_upa_compacity(i,srid_area,srid_length) -- compacity     
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_drainagedensity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - DRAINAGE DENSITY

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        
        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- good to go from pghydro
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_drainagedensity = a.drainagedensity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_drainagedensity(i,1.,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_elevations_stats(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - ELEVATIONS STATISTICS

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_elevation_avg = a.upa_elevation_avg,
            hig_upa_elevation_max = a.upa_elevation_max,
            hig_upa_elevation_min = a.upa_elevation_min,            
            hig_upa_elevationdrop_m = a.upa_elevationdrop_maxmin
        FROM (
            SELECT
                upa_elevation_avg,
                upa_elevation_max,
                upa_elevation_min,
                upa_elevationdrop_maxmin
            FROM pgh_hgm.pghfn_upa_elevations_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;      
        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_formfactor(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - FORM FACTOR

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        
        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_formfactor = a.formfactor
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_formfactor(i,srid_area,srid_length)  -- form factor
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_hydrodensity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - HYDRO DENSITY (NUMBER OF RIVERS PER KM2)

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- good to gofrom pghydro
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_hydrodensity = a.hydrodensity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_hydrodensity(i,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_kirpicha(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - TIME OF CONCENTRATION
    BASED ON KIRPICH'S EQUATION USING 'CATCHMENT ELEVATION DROP'

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_upa_elevation_stats(i)
        actually, hig_upn_length_km, hig_upa_elevationdrop_m
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_upn_hydraulics_defaults(i)
        --PERFORM pgh_hgm.pghfn_upa_elevation_stats(i)

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_tc_kirpicha = a.tc_kirpicha
        FROM (
            SELECT
                tc_kirpicha
            FROM pgh_hgm.pghfn_upa_kirpicha(i)   
            ) a
        WHERE hig_dra_pk = i
            AND hig_wtc_pk IS NOT NULL
            AND hig_drn_strahler > 1
            AND hig_upa_elevationdrop_m >0. ;   

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_perimeter(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - PERIMETER

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_perimeter_ = a.perimeter,
            hig_upa_perimeter_km = a.perimeter/1000.
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_perimeter(i,srid_length,1.)    -- perimeter in m
                
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;
    
        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_reachgradient(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - REACH GRADIENT

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_reachgradient = a.reachgradient
        FROM (
            SELECT
                *
            FROM                 
                pgh_hgm.pghfn_upa_reachgradient(i) -- reach gradient
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);  
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_reliefratio(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - RELIEF RATIO

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);  

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_reliefratio = a.reliefratio
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_reliefratio(i,srid_length)-- realief ratio
                
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
    CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_shapefactor(
        srid_area integer,
        srid_length integer)
    RETURNS character varying AS
    $BODY$
    /*
        CALCULATE UPSTREAM AREA - SHAPE FACTOR

        requires:
            --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

    */

    DECLARE
        time_ timestamp;
        i integer;
        imin integer;
        imax integer;

    BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);    

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET     
            hig_upa_shapefactor = a.shapefactor
        FROM (
            SELECT
                *
            FROM            
                pgh_hgm.pghfn_upa_shapefactor(i,srid_area,srid_length)  -- shape factor
                
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_timeofconcentration(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - TIME OF CONCENTRATION
    USING EQUATIONS FROM ARMY CORPS, CARTER, DOOGE, KIRPICH, WATTCHOW

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_upn_hydraulics_defaults(i)
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_upn_hydraulics_defaults(i)

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_tc_armycorps = a.tc_armycorps,
            hig_upa_tc_carter = a.tc_carter,
            hig_upa_tc_dooge = a.tc_dooge,
            hig_upa_tc_kirpich = a.tc_kirpich,
            hig_upa_tc_wattchow = a.tc_wattchow,
            hig_upa_tc_georgeribeiro = a.tc_georgeribeiro,
            hig_upa_tc_pasini = a.tc_pasini,
            hig_upa_tc_ventura = a.tc_ventura,
            hig_upa_tc_dnosk1 = a.tc_dnosk1
        FROM (
            SELECT
                tc_armycorps,
                tc_carter,
                tc_dooge,
                tc_kirpich,
                tc_wattchow,
                tc_georgeribeiro,
                tc_pasini,
                tc_ventura,
                tc_dnosk1                
            FROM pgh_hgm.pghfn_upa_timeofconcentration(i)   
            ) a
        WHERE hig_dra_pk = i
            AND hig_wtc_pk IS NOT NULL
            AND hig_drn_strahler  > 1
            AND hig_upn_slope_adim >0. ;   

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upa_totaldrainagelength(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA - TOTAL DRAINAGE LENGTH (SUM OF ALL UPSTREAM RIVER LENGTHS)

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        -- good to go from pghydro
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_totaldrainagelength = a.totaldrainagelength
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_totaldrainagelength(i,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_elevationprofiledrop_from_slopes(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM MAIN RIVER - ELEVATION PROFILE EQUIVALENTE DROP
    FROM SLOPES STORED IN PGHFT_HYDRO_INTEL
    SLOPE MAXMIN, S15-85, PIPF, Z15-85, HARMONIC, WEIGHTED, LINREG

    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_upn_length_km
    -hig_upn_slope_maxmin,
    -hig_upn_slope_s1585,
    -hig_upn_slope_pipf,
    -hig_upn_slope_z1585,
    -hig_upn_slope_harmonic,
    -hig_upn_slope_weighted,
    -hig_upn_slope_linreg


*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;


BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();


        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_elevationdrop_maxmin = a.elevationdrop_maxmin,
            hig_upn_elevationdrop_s1585 = a.elevationdrop_s1585,
            hig_upn_elevationdrop_pipf = a.elevationdrop_pipf,
            hig_upn_elevationdrop_z1585  = a.elevationdrop_z1585,
            hig_upn_elevationdrop_harmonic = a.elevationdrop_harmonic,
            hig_upn_elevationdrop_weighted = a.elevationdrop_weighted,
            hig_upn_elevationdrop_linreg = a.elevationdrop_linreg
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_elevationprofiledrop_from_slopes(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1; 


        
    
    -- FINISH
    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_elevationprofile_stats(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE STATISTICS

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');        

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn'); 

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_elevation_avg = a.elevation_avg,
            hig_upn_elevation_max = a.elevation_max,
            hig_upn_elevation_min = a.elevation_min
        FROM (
            SELECT
                elevation_avg, elevation_max, elevation_min
            FROM pgh_hgm.pghfn_upn_tmp_elevationprofile_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_sinuosity(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - SINUOSITY

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_sinuosity = a.sinuosity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upn_sinuosity(i,srid_length)  -- sinuosity, actually main river drainage           
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_harmonic(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE HARMONIC SLOPE
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile' 

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_harmonic = a.slope_harmonic        
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_harmonic(i)              
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;
        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_linreg(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE LINEAR REGRESSION SLOPE
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile' 

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');        

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_linreg = a.slope_linreg      
        FROM (
            SELECT *
            FROM   
                pgh_hgm.pghfn_upn_tmp_slope_linreg(i)          
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_maxmin(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE MAXMIN SLOPE
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile'

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;


BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_maxmin = a.slope_maxmin     
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_maxmin(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_pipf(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE 'PIPF' SLOPE
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile'

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_pipf = a.slope_pipf    
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_pipf(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_s1585(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE SLOPE S15-85
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile'

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_s1585 = a.slope_s1585        
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_s1585(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_weighted(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE WEIGHTED SLOPE
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile'

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_weighted = a.slope_weighted      
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_weighted(i)             
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_upn_slope_z1585(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    CALCULATE UPSTREAM AREA MAIN RIVER - ELEVATION PROFILE SLOPE Z15-85
    FROM THE TEMPORARY ELEVATION PROFILE 'pgh_hgm.pghft_upn_elevationprofile'

    requires:
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'upn');

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    -- DROP AND CREATE INDEXES
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE); 

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        
        -- ACTIVATE THIS IF REQUIRED.
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        --PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_z1585 = a.slope_z1585      
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_z1585(i)              
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
    
        -- ACTIVATE THIS IF REQUIRED
        --PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    

    END LOOP;
    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_area(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN divfactor double precision default 1.)
  RETURNS TABLE(area double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT - AREA
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        area_/divfactor AS area
    FROM (
        SELECT
            ST_Area(ST_Transform(dra_gm,srid_area)) AS area_       
        FROM pghydro.pghft_drainage_area dra    
        WHERE dra.dra_pk = dra_pk_
    )
      
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_avglengthoverlandflow(
    IN dra_pk_ integer,
    IN _to_km2 double precision,
    IN _to_km double precision)
  RETURNS TABLE(avglengthoverlandflow double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT - AVERAGE DISTANCE TO WATERSHED BOUNDARY
    USING DRA_PK

    calls:
        pgh_hgm.pghfn_dra_drainagedensity(dra_pk_,_to_km2,_to_km)
        use "pgh_hgm.pghfn_upa_avglengthoverlandflow" for a more interpretable value
*/

BEGIN
    RETURN
    QUERY

    SELECT
        1./(2.*drainagedensity) ::double precision AS avglengthoverlandflow
    FROM (
        SELECT drainagedensity FROM pgh_hgm.pghfn_dra_drainagedensity(dra_pk_,_to_km2,_to_km)
    ) a;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_axislength(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(axislength double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT - AXIS LENGTH
   ( AS MAX EUCLIDEAN DISTANCE FROM STREAM OUTLET/ENDPOINT TO CATCHMENT EXTERIOR RING)
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY
    
    SELECT
        ST_MaxDistance(foz_gm,ring_gm) AS axislength
    FROM (
        SELECT
            ST_Exteriorring((ST_Dump(dra_gm_srid_length)).geom) AS ring_gm,
            ST_EndPoint((ST_Dump(drn_gm_srid_length)).geom) AS foz_gm
        FROM (    
            SELECT
                ST_Transform(drn_gm,srid_length) AS drn_gm_srid_length,
                ST_Transform(dra_gm,srid_length) AS dra_gm_srid_length  -- pick srid for exterior ring length.
            FROM pghydro.pghft_drainage_area dra
            INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
            WHERE dra.dra_pk = dra_pk_
            ) a
        ) a;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_axislength_ring(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(axislength_ring double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT - AXIS LENGTH
    (AS 'MAX DISTANCE IN EXTERIOR RING' APPROACH)
    USING DRA_PK
 
*/

BEGIN
    RETURN
    QUERY

    SELECT
        axlen_ring AS axislength_ring
    FROM
    (
        SELECT 
            (ST_MaxDistance(ring_gm,ring_gm)) AS axlen_ring
        FROM (

            SELECT
                ST_ExteriorRing((ST_Dump(dra_gm_srid_length)).geom) AS ring_gm
            FROM (    
                SELECT
                    ST_Transform(dra_gm,srid_length) AS dra_gm_srid_length
                FROM
                    pghydro.pghft_drainage_area dra
                WHERE dra.dra_pk = dra_pk_
                ) a
            ) a
        ) a;
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_axislength_river(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(axislength_river double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - AXIS LENGTH
    (AXIS LENGTH ~ THE RIVER LENGTH)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        ST_Length(ST_Transform(drn_gm,srid_length)) AS axislength_river
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
    WHERE dra.dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_axislength_schumm(
    IN dra_pk_ integer,
    IN _to_km2 double precision)
  RETURNS TABLE(axislength_schumm double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT - AXIS LENGTH
    (SCHUMM'S EQUATION)
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT 
        (1.312 * (dra_gm_area * _to_km2)^0.568)*1000. ::double precision AS axislength_schumm
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
    WHERE dra.dra_pk = dra_pk_;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_circularity(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(circularity double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - CIRCULARITY
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        12.57*(area_m2/perimeter_m^2)  AS circularity
    FROM (

        SELECT
            ST_Perimeter(ST_Transform(dra.dra_gm, srid_length)) AS perimeter_m,
            ST_Area(ST_Transform(dra.dra_gm, srid_area)) AS area_m2
        FROM pghydro.pghft_drainage_area dra
        WHERE dra.dra_pk = dra_pk_
        ) a; 
             
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_compacity(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(compacity double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - COMPACITY
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        0.28*perimeter_/SQRT(area_) AS compacity
    FROM (
        SELECT
            ST_Area(ST_Transform(dra_gm,srid_area)) AS area_,        
            ST_Perimeter(ST_Transform(dra_gm,srid_length)) AS perimeter_
        FROM pghydro.pghft_drainage_area dra
        WHERE dra.dra_pk = dra_pk_
        ) a;
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_drainagedensity(
    IN dra_pk_ integer,
    IN _to_km2 double precision,
    IN _to_km double precision)
  RETURNS TABLE(drainagedensity double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - DRAINAGE DENSITY
    USING DRA_PK

    note:
        more like a 'axial_length/area' ratio
        use "pgh_hgm.pghfn_upa_drainagedensity" for a more interpretable metric
*/

BEGIN
    RETURN
    QUERY

    SELECT
        drainage_density_ AS drainagedensity
    FROM (
        SELECT
            (drn_gm_length*_to_km)/(dra_gm_area*_to_km2) ::double precision AS drainage_density_
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
        WHERE dra.dra_pk = dra_pk_    
    ) a;

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_elevations_stats(
    IN dra_pk_ integer)
 RETURNS TABLE(
    dra_elevation_avg double precision,
    dra_elevation_max double precision,
    dra_elevation_min double precision,
    dra_elevationdrop_maxmin double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - STATISTICS OF CATCHMENT ELEVATIONS (EXTRACTED FROM DEM)
    USING DRA_PK

    calls:
        pgh_hgm.pghfn_dra_elevations()

*/

BEGIN
    RETURN
    QUERY

    SELECT
        AVG(pixels) as dra_elevation_avg,    
        MAX(pixels) as dra_elevation_max,
        MIN(pixels) as dra_elevation_min,
        MAX(pixels) - MIN(pixels) AS dra_elevationdrop_maxmin
    FROM
        pgh_hgm.pghfn_dra_elevations(dra_pk_)

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;       


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_formfactor(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(formfactor double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - FORM FACTOR
    (USING MAX EUCLIDEAN DISTANCE FROM STREAM OUTLET/ENDPOINT TO CATCHMENT RING)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT 1./pgh_hgm.pghfn_dra_shapefactor(dra_pk_, srid_area, srid_length) AS formfactor;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_formfactor_ring(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(formfactor_ring double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - FORM FACTOR
    (AXIS LENGTH AS MAX EUCLIDEAN DISTANCE BETWEEN EXTERIOR RING POINTS)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT 1./pgh_hgm.pghfn_dra_shapefactor_ring(dra_pk_,srid_area,srid_length) AS formfactor_ring;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_formfactor_river(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(formfactor_river double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - FORM FACTOR
    (AXIS LENGTH ~RIVER LENGTH)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT 1./pgh_hgm.pghfn_dra_shapefactor_river(dra_pk_, srid_area, srid_length) AS formfactor_river;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_formfactor_schumm(
    IN dra_pk_ integer,
    IN _to_km2 double precision)
  RETURNS TABLE(formfactor_schumm double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - FORM FACTOR
    (SCHUMM'S EQUATION)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT 1./pgh_hgm.pghfn_dra_shapefactor_schumm(dra_pk_, _to_km2) AS formfactor_schumm;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_hydrodensity(
    IN dra_pk_ integer,
    IN _to_km2 double precision)
  RETURNS TABLE(hydrodensity double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - HYDRODENSITY
    (NUMBER OF REACHES PER UNIT OF LOCAL AREA)
    USING DRA_PK

    note:
        strongly related to the hydrographic dataset resolution
        use "pgh_hgm.pghfn_upa_hydrodensity" for a more interpretable value
*/

BEGIN
    RETURN
    QUERY
    
    SELECT 
        1./(dra_gm_area*_to_km2) :: double precision AS hydrodensity
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
    WHERE dra.dra_pk = dra_pk_ ;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_kirpicha(IN dra_pk_ integer)
  RETURNS TABLE(
  tc_kirpicha double precision
  ) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - KIRPICH'S TIME OF CONCENTRATION BASED ON CATCHMENT DROP
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    - hig_drn_length_km
    - hig_drn_slope_adim
    - hig_dra_area_km2  -> for Dooge's model

*/

DECLARE
    cur_drop double precision;

BEGIN

    SELECT INTO cur_drop COALESCE(hig_dra_elevationdrop_m,-9999.)
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_ ;


    IF cur_drop>0 THEN

        RETURN
        QUERY
        
        SELECT
            57.0 * (hig_drn_length_km^3. / (hig_dra_elevationdrop_m))^0.385 AS tc_kirpicha     
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_;
    
    ELSE

        RETURN
        QUERY

        SELECT
            -9999. ::double precision AS tc_kirpicha;
            
    END IF;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_perimeter(
    IN dra_pk_ integer,
    IN srid_length integer,
    IN divfactor double precision default 1.)
  RETURNS TABLE(perimeter double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - PERIMETER
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        perimeter_/divfactor AS perimeter
    FROM (
        SELECT       
            ST_Perimeter(ST_Transform(dra_gm,srid_length)) AS perimeter_
        FROM pghydro.pghft_drainage_area dra
        WHERE dra.dra_pk = dra_pk_
    ) a;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_reachgradient(
    IN dra_pk_ integer)
  RETURNS TABLE(reachgradient double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - REACH GRADIENT (m/km)
    BASED ON MAXMIN SLOPE
    FROM THE DRAINAGE ELEVATION PROFILE
    USING DRA_PK

    depends on:
    - 'hig_drn_elevationdrop_maxmin'

*/

BEGIN
    RETURN
    QUERY

    --SELECT 1000.*pgh_hgm.pghfn_drn_slope_maxmin(dra_pk_) AS reachgradient;

    SELECT
        1000.*hig_drn_slope_maxmin AS reachgradient
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_ ;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_reliefratio(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(reliefratio double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - RELIEF RATIO (m/km)
    (RATIO BETWEEN THE ELEVATION DROP FROM THE CATCHMENT ELEVATIONS
    AND THE AXIAL LENGHTH [AS MAX DISTANCE FROM CATCHMENT BOUNDARY TO OUTLET])
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_axislength(dra_pk_,srid_length)     
    - pgh_hgm.pghfn_dra_elevations(dra_pk_)
        - queries elevations internally


*/

BEGIN
    RETURN
    QUERY

    -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) AS dz
    --     FROM pgh_hgm.pghfn_dra_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP    
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_dra_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),
    -- CALCULATE AXIS LENGTH
    tb_axlen AS (
        SELECT
            dra_pk_ AS dra_pk,
            axislength
        FROM pgh_hgm.pghfn_dra_axislength(dra_pk_,srid_length)
    )

    -- JOIN/CALCULATE RELIEF RATIO
    SELECT
        dz/axislength AS reliefratio
    FROM tb_axlen
    INNER JOIN tb_dz ON tb_axlen.dra_pk = tb_dz.dra_pk;
        

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_reliefratio_ring(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(reliefratio_ring double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - RELIEF RATIO (m/km)
    (RATIO BETWEEN THE ELEVATION DROP FROM THE CATCHMENT ELEVATIONS
    AND THE AXIAL LENGTH [AS MAX DISTANCE FROM CATCHMENT BOUNDARY TO OUTLET])
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_axislength_ring(dra_pk_,srid_length) 
    - pgh_hgm.pghfn_dra_elevations(dra_pk_)
        - queries elevations internally

*/

BEGIN
    RETURN
    QUERY

    -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) AS dz
    --     FROM pgh_hgm.pghfn_dra_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_dra_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),  
    -- CALCULATE AXIS LENGTH (USING EXTERIOR RING)
    tb_axlen AS (
        SELECT
            dra_pk_ AS dra_pk,
            axislength_ring
        FROM pgh_hgm.pghfn_dra_axislength_ring(dra_pk_,srid_length)
    )

    -- JOIN/CALCULATE RELIEF RATIO
    SELECT
        dz/axislength_ring AS reliefratio_ring
    FROM tb_axlen
    INNER JOIN tb_dz ON tb_axlen.dra_pk = tb_dz.dra_pk;
        

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_reliefratio_river(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(reliefratio_river double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - RELIEF RATIO (m/km)
    (RATIO BETWEEN THE ELEVATION DROP FROM THE CATCHMENT ELEVATIONS
    AND THE AXIAL LENGHTH [AS THE RIVER LENGTH])
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_axislength_river(dra_pk_,srid_length) 
    - pgh_hgm.pghfn_dra_elevations(dra_pk_)
        - queries elevations internally
    
*/

BEGIN
    RETURN
    QUERY

    -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) AS dz
    --     FROM pgh_hgm.pghfn_dra_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_dra_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),
    -- CALCULATE AXIS LENGTH (USING EXTERIOR RING)
    tb_axlen AS (
        SELECT
            dra_pk_ AS dra_pk,
            axislength_river
        FROM pgh_hgm.pghfn_dra_axislength_river(dra_pk_,srid_length)
    )

    -- JOIN/CALCULATE RELIEF RATIO
    SELECT
        dz/axislength_river AS reliefratio_river
    FROM tb_axlen
    INNER JOIN tb_dz ON tb_axlen.dra_pk = tb_dz.dra_pk;
        

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_reliefratio_schumm(
    IN dra_pk_ integer,
    IN _to_km2 double precision
    )
  RETURNS TABLE(reliefratio_schumm double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - RELIEF RATIO (m/km)
    (RATIO BETWEEN THE ELEVATION DROP FROM THE CATCHMENT ELEVATIONS
    AND THE AXIAL LENGHTH [FROM SCHUMM'S EQUATION])
    USING DRA_PK

    depends on:
        - pgh_hgm.pghfn_dra_elevations(dra_pk_)
        -- queries elevations internally

*/

BEGIN
    RETURN
    QUERY

    -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) as dz
    --     FROM pgh_hgm.pghfn_dra_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- )
    -- GET STORED ELEVATION DROP
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_dra_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    )  

    -- JOIN/CALCULATE RELIEF RATIO
    SELECT
        dz/axislength_schumm AS reliefratio_schumm
    FROM (
        SELECT
            dz,
            (1.312 * (dra_gm_area * _to_km2)^0.568)*1000. ::double precision AS axislength_schumm
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
        INNER JOIN tb_dz ON tb_dz.dra_pk = dra.dra_pk
        WHERE dra.dra_pk = dra_pk_
    ) a;   
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_shapefactor(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(shapefactor double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - SHAPE FACTOR
    (USING MAX EUCLIDEAN DISTANCE FROM STREAM OUTLET/ENDPOINT) TO CATCHMENT EXTERIOR RING)
    USING DRA_PK

*/

BEGIN
RETURN
    QUERY

    WITH
    tb_axlen AS (
    SELECT
        dra_pk_ as dra_pk, --required for join
        pgh_hgm.pghfn_dra_axislength(dra_pk_,srid_length) AS axis_length
    )

    SELECT
        (axis_length)^2/ST_Area(ST_Transform(dra_gm,srid_area)) AS shapefactor_ring
    FROM tb_axlen
    INNER JOIN pghydro.pghft_drainage_area dra ON tb_axlen.dra_pk = dra.dra_pk
    WHERE dra.dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_shapefactor_ring(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(shapefactor_ring double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - SHAPE FACTOR
    (USING MAX EUCLIDEAN DISTANCE ALONG EXTERIOR RING POINTS)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    WITH
    -- CALCULATE AXIAL LENGTH
    tb_axlen AS (
        SELECT
        dra_pk_ AS dra_pk, --required for join
        pgh_hgm.pghfn_dra_axislength_ring(dra_pk_, srid_length) AS axis_length_ring
    )
    -- QUERY SHAPE FACTOR
    SELECT
        axis_length_ring^2/ST_Area(ST_Transform(dra_gm, srid_area)) AS shapefactor_ring
    FROM tb_axlen
    INNER JOIN pghydro.pghft_drainage_area dra ON tb_axlen.dra_pk = dra.dra_pk
    WHERE dra.dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_shapefactor_river(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(shapefactor_river double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - SHAPE FACTOR
    (AXIAL LENGTH ~RIVER LENGTH)
    USING DRA_PK


*/

BEGIN
    RETURN
    QUERY

    SELECT
        drn_length_^2/dra_area_ AS shapefactor_river
    FROM (
    
        SELECT
            ST_Length(ST_Transform(drn_gm, srid_length)) AS drn_length_,
            ST_Area(ST_Transform(dra_gm, srid_area)) AS dra_area_
        FROM
            pghydro.pghft_drainage_area dra
            INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
            WHERE dra.dra_pk = dra_pk_
            ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_shapefactor_schumm(
    IN dra_pk_ integer,
    IN _to_km2 double precision
    )
  RETURNS TABLE(shapefactor_schumm double precision) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - SHAPE FACTOR
    (BY SCHUMM'S EQUATION)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT 
        axlen_schumm^2/area_m2 AS shapefactor_schumm
    FROM (
        SELECT
            dra_gm_area * _to_km2 * 1e6 ::double precision AS area_m2 ,
            (1.312 * (dra_gm_area * _to_km2)^0.568)*1000. ::double precision AS axlen_schumm
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
        WHERE dra.dra_pk = dra_pk_
    ) a;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_dra_timeofconcentration(IN dra_pk_ integer)
  RETURNS TABLE(
  tc_armycorps double precision,
  tc_carter double precision,
  tc_dooge double precision,
  tc_kirpich double precision,
  tc_wattchow double precision,
  tc_georgeribeiro double precision,
  tc_pasini double precision,
  tc_ventura double precision,
  tc_dnosk1 double precision
  ) AS
$BODY$
/*
    QUERY LOCAL CATCHMENT AREA - TIME OF CONCENTRATION (MINUTES)
    USING EQUATIONS FROM ARMY CORPS, CARTER, DOOGE, KIRPICH, WATT&CHOW
     MANUAL DNIT: GEORGE RIBEIRO (60% RURAL), PASINI, VENTURA, DNOS(K=1)
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    - hig_drn_length_km
    - hig_drn_slope_adim
    - hig_dra_area_km2  -> for Dooge's model

*/

DECLARE
    cur_slope double precision;

BEGIN

    SELECT INTO cur_slope COALESCE(hig_drn_slope_adim,-9999.)
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_ ;


    IF cur_slope>0 THEN

        RETURN
        QUERY
        
        SELECT
            11.46 * (hig_drn_length_km^0.76)/(hig_drn_slope_adim^0.19) AS tc_armycorps,
            5.96*(hig_drn_length_km^0.6)/(hig_drn_slope_adim^0.3) AS tc_carter,
            21.88*(hig_dra_area_km2^0.41)/(hig_drn_slope_adim^0.17) AS tc_dooge,
            57.0 * (hig_drn_length_km^3. / (hig_drn_slope_adim*hig_drn_length_km*1000.))^0.385 AS tc_kirpich,
            7.68*(hig_drn_length_km/(hig_drn_slope_adim^0.5))^0.79 AS tc_wattchow,
            16.*hig_drn_length_km/(1.05-0.2*(0.6))*(100.*hig_drn_slope_adim)^0.04 AS tc_georgeribeiro, --assuming p=0.6   
            (60)*0.107*(hig_dra_area_km2*hig_drn_length_km)^(1./3.)/((100.*hig_drn_slope_adim)^0.5) AS tc_pasini,
            (60)*0.127*SQRT(hig_dra_area_km2/(100.*hig_drn_slope_adim)) AS tc_ventura,
            10./(1.0)*(hig_dra_area_km2^0.3)*(hig_drn_length_km^0.2)/((100.*hig_drn_slope_adim)^0.4) AS tc_dnosk1 --assume K=1                  
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_;
    
    ELSE

        RETURN
        QUERY

        SELECT
            -9999. ::double precision AS tc_armycorps,
            -9999. ::double precision AS tc_carter,
            -9999. ::double precision AS tc_dooge,
            -9999. ::double precision AS tc_kirpich,
            -9999. ::double precision AS tc_wattchow,
            -9999. ::double precision AS tc_georgeribeiro,
            -9999. ::double precision AS tc_pasini,
            -9999. ::double precision AS tc_ventura,
            -9999. ::double precision AS tc_dnosk1;
            
    END IF;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_amhg_depthfromarea(
    IN dra_pk_ integer,
    IN _to_km2 double precision default 1.
    )
  RETURNS TABLE(hig_drn_depth_m double precision) AS
$BODY$
/*
    QUERY LOCAL DRAINAGE LINE
    BANKFULL DEPTH BASED ON DRAINAGE AREA
    USING AT-MANY STATION HYDRAULIC GEOMETRY (AMHG)
    BY ALVES ET AL.,2022
    USING DRA_PK 
*/

BEGIN
    RETURN
    QUERY

    SELECT 
        0.1132 * (drn_nu_upstreamarea * _to_km2)^0.3169 ::double precision AS hig_drn_depth_m    
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
    WHERE dra.dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_amhg_widthfromarea(
    IN dra_pk_ integer,
    IN _to_km2 double precision default 1.
    )
  RETURNS TABLE(hig_drn_width_m double precision) AS
$BODY$
/*
    QUERY LOCAL DRAINAGE LINE
    BANKFULL WIDTH BASED ON DRAINAGE AREA
    USING AT-MANY STATION HYDRAULIC GEOMETRY (AMHG)
    BY ALVES ET AL.,2022
    USING DRA_PK 
*/

BEGIN
    RETURN
    QUERY

    SELECT 
        0.8554 * (drn_nu_upstreamarea * _to_km2)^0.4921 ::double precision AS hig_drn_width_m
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
    WHERE dra.dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_elevationprofiledrop_from_slopes(
    IN dra_pk_ integer)
  RETURNS TABLE(
    elevationdrop_maxmin double precision,
    elevationdrop_s1585 double precision,
    elevationdrop_pipf double precision,
    elevationdrop_z1585 double precision, 
    elevationdrop_harmonic double precision,
    elevationdrop_weighted double precision,       
    elevationdrop_linreg double precision
  ) AS
$BODY$
/*
    QUERY ELEVATION PROFILE DROP 
    FROM SLOPES STORED IN PGHFT_HYDRO_INTEL
    SLOPE MAXMIN, S15-85, PIPF, Z15-85, HARMONIC, WEIGHTED, LINREG

    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_drn_length_km
    -hig_drn_slope_maxmin,
    -hig_drn_slope_s1585,
    -hig_drn_slope_pipf,
    -hig_drn_slope_z1585,
    -hig_drn_slope_harmonic,
    -hig_drn_slope_weighted,
    -hig_drn_slope_linreg

*/

BEGIN

    RETURN
    QUERY

    SELECT
        1000.*hig_drn_length_km*hig_drn_slope_maxmin,
        1000.*hig_drn_length_km*hig_drn_slope_s1585,
        1000.*hig_drn_length_km*hig_drn_slope_pipf,
        1000.*hig_drn_length_km*hig_drn_slope_z1585,
        1000.*hig_drn_length_km*hig_drn_slope_harmonic,
        1000.*hig_drn_length_km*hig_drn_slope_weighted,
        1000.*hig_drn_length_km*hig_drn_slope_linreg     
    FROM 
        pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_elevationprofile_stats(
    IN dra_pk_ integer)
  RETURNS TABLE(
  elevation_avg double precision,
  elevation_max double precision,
  elevation_min double precision,
  elevationdrop_maxmin double precision,
  slope_maxmin  double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE STATISTICS (AVG/MAX/MIN)    
    USING DRA_PK
    
    note:
        query elevation profile internally, not from table.

*/

BEGIN

    RETURN
    QUERY

    SELECT
        AVG(z) AS elevation_avg,
        MAX(z) AS elevation_max,
        MIN(z) AS elevation_min,
        MAX(z) - MIN(z) AS elevationdrop_maxmin,
        (MAX(z) - MIN(z))/MAX(xy) AS slope_maxmin
    FROM 
        pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
            
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_jobson_traveltime(
 IN dra_pk_ integer)
  RETURNS TABLE(
  hig_drn_jobson_tpeak double precision,
  hig_drn_jobson_tlead double precision,
  hig_drn_jobson_tpeak_shortest double precision,
  hig_drn_jobson_tlead_shortest double precision
  ) AS
$BODY$
/*
    QUERY JOBSON'S MODEL TRAVEL TIME
    -- PEAK AND LEADING EDGE TRAVEL TIMES (MINUTES)
    -- AND SHORTEST PEAK AND LEADING EDGE TRAVEL TIMES
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_drn_length_km
    -hig_drn_slope_adim
    -hig_dra_upa_area_km2
    -hig_drn_annual_flow
    -hig_drn_event_flow

*/

BEGIN
    RETURN
    QUERY
    SELECT
        time_of_peak ::double precision AS hig_drn_jobson_tpeak,    
        time_leading_leading_edge ::double precision  AS hig_drn_jobson_tlead,
        shortest_time_of_peak ::double precision  AS hig_drn_jobson_tpeak_shortest,
        shortest_time_leading_edge ::double precision  AS hig_drn_jobson_tlead_shortest 
    FROM (
        SELECT
            time_of_peak,
            shortest_time_of_peak,
            -- 4th step
            0.890*time_of_peak AS time_leading_leading_edge,
            0.890*shortest_time_of_peak AS shortest_time_leading_edge
        FROM (        
            SELECT
                hig_drn_length_km,
                peak_velocity,
                max_probable_velocity,
                -- 3rd step
                (1000./60.)*hig_drn_length_km/peak_velocity AS time_of_peak,  --minutes
                (1000./60.)*hig_drn_length_km/max_probable_velocity AS shortest_time_of_peak --minutes

            FROM (
                SELECT
                    hig_drn_length_km,
                    hig_drn_slope_adim,
                    hig_drn_event_flow,
                    -- second step
                    0.094 + 0.0143*(adim_drainage_area)^0.919 * adim_flow^(-0.469) * hig_drn_slope_adim^(0.159) * hig_drn_event_flow/(hig_upa_area_m2) AS peak_velocity,
                    0.25 + 0.02*(adim_drainage_area)^0.919 * adim_flow^(-0.469) * hig_drn_slope_adim^(0.159) * hig_drn_event_flow/(hig_upa_area_m2) AS max_probable_velocity
                    FROM (
                    SELECT
                        hig_drn_length_km,
                        hig_drn_slope_adim,
                        hig_drn_event_flow,
                        hig_upa_area_km2*1000000 as hig_upa_area_m2,
                        -- first step
                        ( ( (hig_upa_area_km2*1000000)^1.25 ) * SQRT(9.81) )/hig_drn_annual_flow AS adim_drainage_area,
                        hig_drn_event_flow/hig_drn_annual_flow AS adim_flow
                    FROM 
                        pgh_hgm.pghft_hydro_intel
                        WHERE hig_dra_pk = dra_pk_
                    ) q
                ) q
            ) q
        ) q;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_sinuosity(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(sinuosity double precision) AS
$BODY$
/*
    QUERY DRAINAGE 'SINUOSITY'
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        ss AS sinuosity
    FROM
        (
        SELECT
            ST_Length(drn_line)/ST_Distance(p1,p2)  :: double precision AS ss
        FROM(
            
            SELECT
                ST_Transform(ST_StartPoint((ST_Dump(drn_gm)).geom),srid_length) AS p1,
                ST_Transform(ST_EndPoint((ST_Dump(drn_gm)).geom),srid_length) AS p2,
                ST_Transform(drn_gm,srid_length) AS drn_line
            FROM pghydro.pghft_drainage_area dra
            INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
            WHERE dra.dra_pk = dra_pk_
            ) a
        ) a;    
            
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_harmonic(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_harmonic double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING HARMONIC SLOPE METHOD
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)

*/

BEGIN

    RETURN
    QUERY

    WITH
    -- ELEVATION PROFILE WITH INDEX, NEIGHBOURING POINTS AND MAX VALUE
    tb_elevations AS (
        SELECT
            ROW_NUMBER() OVER (ORDER BY xy) AS idx,  -- auxiliary index
            LAG(xy) OVER (ORDER BY xy) AS xy_previous,
            LAG(z) OVER (ORDER BY xy) AS z_previous,
            xy AS xy_current,
            z AS z_current,
            MAX(xy) OVER() AS profile_length
        FROM pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
        OFFSET 1
        ),
    -- REMOVES REPEATED COORDINATES
    tb_valid AS (
        SELECT *
        FROM tb_elevations
        WHERE xy_current != xy_previous
        ORDER BY idx
        ),
    -- CALCULATION OF LOCAL SLOPES
    tb_harmelev AS (
        SELECT
            idx,
            xy_previous, xy_current, z_previous, z_current, profile_length,
            -(z_current - z_previous)/(xy_current - xy_previous) AS local_slope,
            (xy_current - xy_previous) AS local_length
        FROM tb_valid
        ORDER BY idx
        ),
    -- FILTER ZERO SLOPES AND PREPARE SLOPE SIGNALS
    tb_harmelev_adj AS (
        SELECT
            idx,
            xy_previous, xy_current, z_previous, z_current, profile_length,
            local_slope,
            local_length,
            -- calculations
            SIGN(local_slope) AS slp_sgn,
            ABS(local_slope) AS slp_abs
        FROM tb_harmelev
        WHERE abs(local_slope)>0
        ), 
    -- POSITIVE DENOMINATOR CHECK (SIGN() TO AVOID ERRORS WITH NEGATIVE SLOPE)
    tb_calc AS (
        SELECT
            CASE WHEN SUM( slp_sgn*local_length/SQRT(slp_abs) )>0 AND COUNT(*)>0 THEN
                --( MAX(xy_current)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
                --( MAX(profile_length)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
                --( SUM(xy_current)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
                ( SUM(local_length)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
            ELSE
                NULL
            END AS slope_harm_
        FROM tb_harmelev_adj
        )
    -- FINAL QUERY THE HARMONIC SLOPE 
    SELECT
        slope_harm_ AS slope_harmonic
    FROM tb_calc
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_linreg(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_linreg double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING LINEAR REGRESSION METHOD
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
*/

BEGIN

RETURN
QUERY

SELECT
    -regr_slope(z,xy) AS slope_linreg
FROM 
    pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
    
RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_maxmin(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_maxmin double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING MAX-MIN METHOD
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
*/

BEGIN

RETURN
QUERY

SELECT
    ( MAX(z)-MIN(z))/MAX(xy) AS slope_maxmin
FROM 
     pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_pipf(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_pipf double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING INITIAL AND FINAL POINT OF DRAINAGE
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
*/

BEGIN

RETURN
QUERY

SELECT
    -(z_pf - z_pi)/(xy_pf - xy_pi) AS slope_pipf
FROM (
    -- ORGANIZE THE INFORMATION IN ONE LINE
    SELECT
        xy AS xy_pi,
        z AS z_pi,
        LEAD(xy) OVER (ORDER BY xy) AS xy_pf,
        LEAD(z) OVER (ORDER BY xy) AS z_pf       
    FROM (   
        -- RETURN THE START POINT AND END POINT BY ORDERING
        SELECT
            xy,
            z,            
            ROW_NUMBER () OVER (ORDER BY xy DESC) AS idesc,
            ROW_NUMBER () OVER (ORDER BY xy) AS iasc
        FROM 
            pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
        ) a
        WHERE iasc=1 OR idesc = 1
    ) a
    LIMIT 1;
RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_s1585(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_s1585 double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING ELEVATION LOCATED AT THE 15-85 'DISTANCE PERCENTILES' ALONG THE LENGTH OF REACH
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
*/

BEGIN

RETURN
QUERY

WITH
-- ELEVATION PROFILE WITH INDEX
tb_cotas AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY xy) AS idx,
        xy,
        z
    FROM pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
),

-- INDEXES OF 15-85 PERCENTILES ALONG THE DRAINAGE LENGTH, ACTUALLY FROM INDEXES.
tb_percL AS (
SELECT
    percentile_disc(0.15) within group (order by idx) AS i1,
    percentile_disc(0.85) within group (order by idx) AS i2
FROM tb_cotas
),

-- ELEVATION VALUES AT THE 15-85 POSITIONS
tb_percZ AS (
SELECT
    idx,
    xy AS xy1,
    z AS z1,
    LEAD(xy) OVER (ORDER BY xy) AS xy2,
    LEAD(z) OVER (ORDER BY xy) AS z2
FROM tb_cotas
WHERE (idx IN (SELECT i1 FROM tb_percL)) OR (idx IN (SELECT i2 FROM tb_percL))
LIMIT 1
)

-- QUERY SLOPE CALCULATION
-- negative sign adjust reference por positive downslope
SELECT
    -(z2-z1)/((xy2-xy1)) AS slope_S1585 
FROM tb_percZ;

RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_weighted(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_weighted double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING WEIGHTED/INTEGRAL METHOD
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
*/

BEGIN

RETURN
QUERY

SELECT
    slope_nint AS slope_weighted
FROM
    (
    SELECT
        SUM(areainc)*2./((MAX(xy_current)^2)) AS slope_nint
    FROM (
        -- UPDATE ELEVATION PROFILE INCREMENTAL VALUES OF INTEGRATION BY TRAPEZIUM
        SELECT
            *,
            ( (xy_current - xy_previous) * (z_current + z_previous - 2.*zmin) )/2 AS areainc        
        FROM (
            -- ELEVATION PROFILE WITH INDEX, NEIGHBOURING POINTS AND MIN VALUE
            SELECT
                ROW_NUMBER() OVER (ORDER BY xy) AS idx,
                xy AS xy_current,
                z AS z_current,
                LAG(xy) OVER (ORDER BY xy) AS xy_previous,
                LAG(z) OVER (ORDER BY xy) AS z_previous,
                MIN(z) OVER () AS zmin --CORRECAO
            FROM pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
            ) a
        ORDER BY idx ASC
        OFFSET 1
    ) a
) a;
RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_slope_z1585(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_z1585 double precision) AS
$BODY$
/*
    QUERY ELEVATION PROFILE SLOPE
    WHEN USING ELEVATION LOCATED AT THE 15-85 PERCENTILES OF ELEVATION VALUES
    USING DRA_PK

    note:
        query elevation profile internally, not from table.

    depends on:
    - pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
 
*/

BEGIN

RETURN
QUERY
SELECT
    slope_Z1585_ AS slope_Z1585
FROM (
    SELECT
        (zu - zl)/profile_length AS slope_Z1585_
    FROM (
        SELECT
            percentile_cont(0.15) WITHIN GROUP(ORDER BY z) AS zl,
            percentile_cont(0.85) WITHIN GROUP(ORDER BY z) AS zu,
            max(xy) AS profile_length        
         FROM
            pgh_hgm.pghfn_drn_elevationprofile(dra_pk_)
        ) a
    ) a;
RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_elevationprofile_stats(
    IN dra_pk_ integer
    )
  RETURNS TABLE(
  elevation_avg double precision,
  elevation_max double precision,
  elevation_min double precision,
  elevationdrop_maxmin double precision,
  slope_maxmin  double precision) AS
$BODY$
/*
    QUERY ELEVATION STATS
    BASED ON MAX-MIN VALUES 
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile' 
    USING DRA_PK
 
*/

BEGIN

    RETURN
    QUERY

    SELECT
        AVG(z) AS elevation_avg,
        MAX(z) AS elevation_max,
        MIN(z) AS elevation_min,
        MAX(z) - MIN(z) AS elevationdrop_maxmin,
        (MAX(z) - MIN(z))/MAX(xy) AS slope_maxmin    
    FROM pgh_hgm.pghft_drn_elevationprofile
    WHERE dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_harmonic(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_harmonic double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING HARMONIC SLOPE METHOD
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile'
    USING DRA_PK 
*/

BEGIN

RETURN
QUERY

WITH
-- ELEVATION PROFILE WITH INDEX, NEIGHBOURING POINTS AND MAX VALUE
tb_elevations AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY xy) AS idx,  -- auxiliary index
        LAG(xy) OVER (ORDER BY xy) AS xy_previous,
        LAG(z) OVER (ORDER BY xy) AS z_previous,
        xy AS xy_current,
        z AS z_current,
        MAX(xy) OVER() AS profile_length
    FROM pgh_hgm.pghft_drn_elevationprofile
    WHERE dra_pk = dra_pk_
    OFFSET 1
    ),
-- REMOVES REPEATED COORDINATES
tb_valid AS (
    SELECT *
    FROM tb_elevations
    WHERE xy_current != xy_previous
    ORDER BY idx
    ),
-- CALCULATION OF LOCAL SLOPES
tb_harmelev AS (
    SELECT
        idx,
        xy_previous, xy_current, z_previous, z_current, profile_length,
        -(z_current - z_previous)/(xy_current - xy_previous) AS local_slope,
        (xy_current - xy_previous) AS local_length
    FROM tb_valid
    ORDER BY idx
    ),
-- FILTER ZERO SLOPES AND PREPARE SLOPE SIGNALS
tb_harmelev_adj AS (
    SELECT
        idx,
        xy_previous, xy_current, z_previous, z_current, profile_length,
        local_slope,
        local_length,
        -- calculations
        SIGN(local_slope) AS slp_sgn,
        ABS(local_slope) AS slp_abs
    FROM tb_harmelev
    WHERE abs(local_slope)>0
    ), 
-- POSITIVE DENOMINATOR CHECK (SIGN() TO AVOID ERRORS WITH NEGATIVE SLOPE)
tb_calc AS (
    SELECT
        CASE WHEN SUM( slp_sgn*local_length/SQRT(slp_abs) )>0 AND COUNT(*)>0 THEN
            --( MAX(xy_current)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
            --( MAX(profile_length)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
            --( SUM(xy_current)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
            ( SUM(local_length)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
        ELSE
            NULL
        END AS slope_harm_
    FROM tb_harmelev_adj
    )
-- FINAL QUERY THE HARMONIC SLOPE 
SELECT
    slope_harm_ AS slope_harmonic
FROM tb_calc
    
RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_linreg(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_linreg double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING LINEAR REGRESSION SLOPE COEFFICIENT
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile'
    USING DRA_PK 
*/

BEGIN
    RETURN
    QUERY

    SELECT
        slope_regress_ AS slope_linreg
    FROM (
        SELECT
            -regr_slope(z,xy) AS slope_regress_
        FROM pgh_hgm.pghft_drn_elevationprofile
        WHERE dra_pk = dra_pk_
    ) a;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_maxmin(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_maxmin double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING MAXIMUM AND MINIMUM ELEVATIONS 
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile' 
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        ( MAX(z) - MIN(z))/MAX(xy) AS slope_maxmin
    FROM pgh_hgm.pghft_drn_elevationprofile
    WHERE dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_pipf(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_pipf double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING START POINT AND END POINTS
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile' 
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        -(z_pf - z_pi)/(xy_pf - xy_pi) AS slope_pipf
    FROM (
        -- ORGANIZE THE INFORMATION IN ONE LINE
        SELECT
            xy AS xy_pi,
            z AS z_pi,
            LEAD(xy) OVER (ORDER BY xy) AS xy_pf,
            LEAD(z) OVER (ORDER BY xy) AS z_pf       
        FROM (   
            -- RETURN THE START POINT AND END POINT BY ORDERING
            SELECT
                xy,
                z,            
                ROW_NUMBER () OVER (ORDER BY xy DESC) AS idesc,
                ROW_NUMBER () OVER (ORDER BY xy) AS iasc
            FROM pgh_hgm.pghft_drn_elevationprofile
            WHERE dra_pk = dra_pk_
            ) a
        WHERE iasc=1 OR idesc = 1
        ) a
        LIMIT 1;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_s1585(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_s1585 double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING ELEVATION LOCATED IN THE 15-85 
    PERCENTILES THROUGHOUT THE LENGTH OF THE SECTION 
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile'
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    WITH
    -- NUMBERED TABLE OF ELEVATIONS ELEVATION PROFILE 
    tb_cotas AS (
        SELECT
            ROW_NUMBER() OVER (ORDER BY xy) AS id,  -- numeration
            xy,
            z
        FROM pgh_hgm.pghft_drn_elevationprofile
        WHERE dra_pk = dra_pk_
    ),

    -- INDEXES OF 15-85 PERCENTILES THROUGHOUT THE SECTION
    tb_percL AS (
        SELECT
            percentile_disc(0.15) within group (order by id) AS i1,
            percentile_disc(0.85) within group (order by id) AS i2
        FROM tb_cotas
    ),

    -- ELEVATION VALUES AT POINTS 15-85 THROUGHOUT THE SECTION
    tb_percZ AS (
    SELECT
        id,
        xy AS xy1,
        z AS z1,
        LEAD(xy) OVER (ORDER BY xy) AS xy2,
        LEAD(z) OVER (ORDER BY xy) AS z2
    FROM tb_cotas
    WHERE (id IN (SELECT i1 FROM tb_percL)) OR (id IN (SELECT i2 FROM tb_percL))
    LIMIT 1
    )

    -- QUERY SLOPE CALCULATION
    -- negative sign adjust reference por positive downslope
    SELECT
        -(z2-z1)/((xy2-xy1)) AS slope_S1585 
    FROM tb_percZ;
    RETURN;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_weighted(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_weighted double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING WEIGHTED/INTEGRAL METHOD
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile' 
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        slope_w AS slope_weighted
    FROM
        (
        SELECT
            SUM(areainc)*2./((MAX(xy_current)^2)) AS slope_w
        FROM (
            SELECT
                *,
                ( (xy_current - xy_previous) * (z_current + z_previous - 2.*zmin) )/2 AS areainc        
            FROM (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY xy) AS id,  -- index from 1 to nline
                    xy AS xy_current,
                    z AS z_current,
                    LAG(xy) OVER (ORDER BY xy) AS xy_previous,
                    LAG(z) OVER (ORDER BY xy) AS z_previous,
                    MIN(z) OVER ()  AS zmin 
                FROM pgh_hgm.pghft_drn_elevationprofile
                WHERE dra_pk = dra_pk_
                ) a
            ORDER BY id ASC
            OFFSET 1
        ) a
    ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_tmp_slope_z1585(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_z1585 double precision) AS
$BODY$
/*
    QUERY SLOPE BY USING THE 15-85 PERCENTILES OF ELEVATIONS
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile'
    USING DRA_PK
 
*/

BEGIN
    RETURN
    QUERY
    SELECT
        slope_Z1585_ AS slope_Z1585
    FROM (
        SELECT
            (zu - zl)/profile_length  AS slope_Z1585_
        FROM 
            (SELECT
                percentile_cont(0.15) WITHIN GROUP(ORDER BY z) AS zl,
                percentile_cont(0.85) WITHIN GROUP(ORDER BY z) AS zu,
                max(xy) AS profile_length        
            FROM pgh_hgm.pghft_drn_elevationprofile
            WHERE dra_pk = dra_pk_
            ) a
        ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_wavetravel_dynamic(
    IN dra_pk_ integer)
  RETURNS TABLE(hig_drn_celdyna double precision, hig_drn_trldyna_minutes double precision) AS
$BODY$
/* 
    QUERY LOCAL DRAINAGE LINE - DYNAMIC CELERITY = SQRT(G*H)

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_drn_depth_m
    -hig_drn_length_km

    note:
        x = c*t
        t = x/c   [m]/ [s/m] [1 min/60s]    
*/

BEGIN

    RETURN
    QUERY
    SELECT
        SQRT(9.81*hig_drn_depth_m) ::double precision AS hig_drn_celdyna,
        (1./60.)*(hig_drn_length_km*1000.)/(SQRT(9.81*hig_drn_depth_m)) ::double precision AS hig_drn_trldyna_minutes
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_wavetravel_kinematic(
    IN dra_pk_ integer)
  RETURNS TABLE(
  hig_drn_velmann double precision,
  hig_drn_celmann double precision,
  hig_drn_trlmann_minutes double precision,
  hig_drn_velmann_lr double precision,
  hig_drn_celmann_lr double precision,
  hig_drn_trlmann_lr_minutes double precision)
  AS
$BODY$
/*
    QUERY WATER VELOCITY, CELERITY AND TRAVEL TIME (MINUTES)
    BY USING MANNING EQUATION AND RECTANGULAR CROSS SECTION
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_drn_length_km
    -hig_drn_slope_adim
    -hig_drn_width_m,
    -hig_drn_depth_m,
    -hig_drn_manning_n  

    note:
        x = c*t
        t = x/c   [m]/ [s/m] [1 min/60s]    
   
*/

BEGIN
    RETURN
    QUERY

    SELECT 
        hig_drn_velmann_ AS hig_drn_velmann,
        hig_drn_celmann_ AS hig_drn_celmann,
        hig_drn_trlmann_ AS hig_drn_trlmann_minutes,
        hig_drn_velmann_lr_ AS hig_drn_velmann_lr,
        hig_drn_celmann_lr_ AS hig_drn_celmann_lr,
        hig_drn_trlmann_lr_  AS hig_drn_trlmann_lr_minutes
    FROM (
        SELECT        
            hig_drn_celmann_,
            hig_drn_celmann_lr_,
            hig_drn_velmann_,
            hig_drn_velmann_lr_, 
            -- 3rd step: wave travel
            (1./60.)*(1000.*hig_drn_length_km)/hig_drn_celmann_ AS hig_drn_trlmann_,
            (1./60.)*(1000.*hig_drn_length_km)/hig_drn_celmann_lr_ AS hig_drn_trlmann_lr_
        FROM (
            SELECT
                hig_drn_length_km,
                hig_drn_velmann_,
                hig_drn_velmann_lr_,
                -- 2nd step: celerities (i.e. wave speed)
                (5./3.)*hig_drn_velmann_ AS hig_drn_celmann_,
                (5./3.)*hig_drn_velmann_lr_ AS hig_drn_celmann_lr_
            FROM (
                SELECT
                    -- 1st step: velocities
                    hig_drn_length_km,
                    -- manning velocities for rectangular xs            
                    ((hig_drn_width_m*hig_drn_depth_m/(hig_drn_width_m+2.*hig_drn_depth_m))^(2./3.))*(hig_drn_slope_adim^0.5)/hig_drn_manning_n AS hig_drn_velmann_,
                    -- simplification for large rivers
                    ((hig_drn_depth_m)^(2./3.))*SQRT(hig_drn_slope_adim)/hig_drn_manning_n AS hig_drn_velmann_lr_
                FROM 
                    pgh_hgm.pghft_hydro_intel
                WHERE hig_dra_pk = dra_pk_
                ) a
            ) a
        )a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_drn_wavetravel_reservoir(
    IN dra_pk_ integer)
  RETURNS TABLE(hig_reservoir_celwave double precision, hig_reservoir_trlwave_minutes double precision) AS
$BODY$
/* 
    QUERY CELERITY AND TRAVEL TIME (MINUTES)
    IN LARGE WATER MASSES USING SQRT(G*H)
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_reservoir_depth_m
    -hig_reservoir_length_m

    note:
        x = c*t
        t = x/c   [m]/[s/m] [1 min/60s]
    

*/

BEGIN
    RETURN
    QUERY
    SELECT
        SQRT(9.81*hig_reservoir_depth_m) AS hig_reservoir_celwave,
        (1./60.)*(hig_reservoir_length_m)/(SQRT(9.81*hig_reservoir_depth_m)) AS hig_reservoir_trlwave_minutes
    FROM 
        pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_geom_elevationprofile(IN geometry)
  RETURNS TABLE(xy integer, z double precision, gm geometry) AS
$BODY$
/*
    QUERY ELEVATION PROFILE AND POINT GEOMETRIES (DEM CENTER PIXEL)
    FROM A GIVE LINE GEOMETRY

    depends on:
    - pgh_raster.pghrt_elevation
    
    note:
    - actually, this is the same function from pgh_raster.
    - geometry SRID must be the same of the DEM


*/
DECLARE
    slength double precision;

BEGIN

    SELECT INTO slength ST_Length($1);

    RETURN
    QUERY
    -- GET POINT "S-COORDINATE", ELEVATION VALUE (Z) AND POINT GEOMETRY
    SELECT
        id :: integer,
        ST_Value(rast, ST_WorldToRasterCoordX(rast, pon.geom),ST_WorldToRasterCoordY(rast, pon.geom)) as elevation,
        geom
    FROM pgh_raster.pghrt_elevation ras
    INNER JOIN
        (
        SELECT
            id, geom
        FROM
            (
            WITH
                line AS ( SELECT $1 as geom )
            SELECT
                ST_LineLocatePoint($1, a.geom)*slength as id,
                geom
            FROM
                (
                SELECT
                    (ST_DumpPoints(geom)).geom as geom
                FROM line
                ) as a
            ) as a  -- END WITH BLOCK
        ) as pon ON ST_Intersects(ras.rast,pon.geom)
    ORDER BY id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_postpro_updateheadwaters()
RETURNS character varying
AS $BODY$
/*
    
    POST-PROCESSING: UPDATE 'UPA' and 'UPN' ATTRIBUTES of HEADWATERS

*/


BEGIN

    --UPDATE UPSTREAM VALUES IN HEADWATERS
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_upn_elevation_avg = hig_drn_elevation_avg,
        hig_upn_elevation_max = hig_drn_elevation_max,
        hig_upn_elevation_min = hig_drn_elevation_min,
        hig_upn_elevationdrop_maxmin = hig_drn_elevationdrop_maxmin,
        hig_upn_elevationdrop_s1585 = hig_drn_elevationdrop_s1585,
        hig_upn_elevationdrop_pipf = hig_drn_elevationdrop_pipf,
        hig_upn_elevationdrop_z1585 = hig_drn_elevationdrop_z1585,
        hig_upn_elevationdrop_harmonic = hig_drn_elevationdrop_harmonic,
        hig_upn_elevationdrop_weighted = hig_drn_elevationdrop_weighted,
        hig_upn_elevationdrop_linreg = hig_drn_elevationdrop_linreg,
        hig_upn_slope_maxmin = hig_drn_slope_maxmin,
        hig_upn_slope_s1585 = hig_drn_slope_s1585,
        hig_upn_slope_pipf = hig_drn_slope_pipf,
        hig_upn_slope_z1585 = hig_drn_slope_z1585,
        hig_upn_slope_harmonic = hig_drn_slope_harmonic,
        hig_upn_slope_weighted = hig_drn_slope_weighted,
        hig_upn_slope_linreg = hig_drn_slope_linreg,
        --hig_upa_area_ = hig_dra_area_,
        --hig_upa_area_km2 = hig_dra_area_km2,
        hig_upa_perimeter_ = hig_dra_perimeter_,
        hig_upa_perimeter_km = hig_dra_perimeter_km,
        hig_upa_axislength = hig_dra_axislength,
        hig_upa_circularity = hig_dra_circularity,
        hig_upa_compacity = hig_dra_compacity,
        hig_upa_shapefactor = hig_dra_shapefactor,
        hig_upa_formfactor = hig_dra_formfactor,
        hig_upn_sinuosity = hig_drn_sinuosity,
        hig_upa_reliefratio = hig_dra_reliefratio,
        hig_upa_reachgradient = hig_dra_reachgradient,
        hig_upa_elevation_avg = hig_dra_elevation_avg,
        hig_upa_elevation_max = hig_dra_elevation_max,
        hig_upa_elevation_min = hig_dra_elevation_min,
        hig_upa_elevationdrop_m = hig_dra_elevationdrop_m,
        hig_upa_drainagedensity = hig_dra_drainagedensity,
        hig_upa_hydrodensity = hig_dra_hydrodensity,
        hig_upa_avglengthoverlandflow = hig_dra_avglengthoverlandflow,
        hig_upn_length_ = hig_drn_length_,
        hig_upn_length_km = hig_drn_length_km,
        --hig_upn_depth_m = hig_drn_depth_m,
        --hig_upn_width_m = hig_drn_width_m,
        hig_upn_elevationdrop_m = hig_drn_elevationdrop_m,
        hig_upn_slope_adim = hig_drn_slope_adim,
        --hig_upn_manning_n = hig_drn_manning_n,
        --hig_upn_velmann = hig_drn_velmann,
        --hig_upn_celmann = hig_drn_celmann,
        --hig_upn_trlmann = hig_drn_trlmann,
        --hig_upn_velmann_lr = hig_drn_velmann_lr,
        --hig_upn_celmann_lr = hig_drn_celmann_lr,
        --hig_upn_trlmann_lr = hig_drn_trlmann_lr,
        --hig_upn_celdyna = hig_drn_celdyna,
        --hig_upn_trldyna = hig_drn_trldyna,
        hig_upa_axislength_schumm = hig_dra_axislength_schumm,
        hig_upa_axislength_ring = hig_dra_axislength_ring,
        hig_upa_axislength_river = hig_dra_axislength_river,
        hig_upa_shapefactor_schumm = hig_dra_axislength_river,
        hig_upa_shapefactor_ring = hig_dra_shapefactor_ring,
        hig_upa_shapefactor_river = hig_dra_shapefactor_river,
        hig_upa_formfactor_schumm = hig_dra_formfactor_schumm,
        hig_upa_formfactor_ring = hig_dra_formfactor_ring,
        hig_upa_formfactor_river = hig_dra_formfactor_river,
        hig_upa_reliefratio_schumm = hig_dra_reliefratio_schumm,
        hig_upa_reliefratio_ring = hig_dra_reliefratio_ring,
        hig_upa_reliefratio_river = hig_dra_reliefratio_river,
        hig_upa_tc_kirpich = hig_dra_tc_kirpich,
        hig_upa_tc_dooge = hig_dra_tc_dooge,
        hig_upa_tc_carter =  hig_dra_tc_carter,
        hig_upa_tc_armycorps = hig_dra_tc_armycorps,
        hig_upa_tc_wattchow = hig_dra_tc_wattchow,
        hig_upa_totaldrainagelength = hig_drn_length_,

        hig_upa_tc_kirpicha = hig_dra_tc_kirpicha,

        hig_upa_tc_georgeribeiro = hig_dra_tc_georgeribeiro,
        hig_upa_tc_pasini = hig_dra_tc_pasini,
        hig_upa_tc_ventura = hig_dra_tc_ventura,
        hig_upa_tc_dnosk1 = hig_dra_tc_dnosk1        

    WHERE hig_drn_strahler = 1;   


    RETURN 'OK';
END;

$BODY$
LANGUAGE PLPGSQL VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_prepro_calculate()
  RETURNS character varying AS
$BODY$
/*
    INITIALIZE
    + DRN ELEVATION PROFILE
    + DRN DEFAULT HYDRAULIC ATTRIBUTES

    calls:
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:,'drn');
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(:);

*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    ----------------------------------------------------------------
    -- DROP/CREATE INDEXES
    ----------------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)    
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);   


    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP
        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();
        
        ----------------------------------------------------------------
        -- INSERT ELEVATION PROFILE AT 'pgh_hgm.pghft_upn_elevationprofile'
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');


        ----------------------------------------------------------------
        -- DEFAULTS FOR DRAINAGE LINE
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);   

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------
        --...

   
    -- FINISH
    END LOOP;

    ----------------------------------------------------------------
    -- REMAKE INDEXES -> we want 'pgh_hgm.elpdrn_dra_idx' to be updated.
    ----------------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);


    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;
    RETURN 'OK';    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_prepro_calculate_upa(
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
    INITIALIZE
    + UPSTREAM AREA (UPA_GM) AND MAIN RIVER GEOMETRIES (UPN_GM)
    + UPN ELEVATION PROFILES
    + UPN DEFAULT HYDRAULIC ATTRIBUTES

    calls:
        PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(:, srid_area, srid_length);
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(:, 'upn');
        PERFORM pgh_hgm.pghfn_utils_upn_hydraulics_defaults(:);

 
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;

    ----------------------------------------------------------------
    -- DROP/CREATE INDEXES
    ----------------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)    
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);

    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        
        ----------------------------------------------------------------
        -- INSERT INTO TEMPORARY TABLE 'pgh_hgm.pghft_upn_elevationprofile'
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        
        ----------------------------------------------------------------
        -- DEFAULTS FOR MAIN UPSTREAM RIVER
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_upn_hydraulics_defaults(i);

        ------------------------------------------------------
        -- CALCULATE/UPDATE ATTRIBUTE
        ------------------------------------------------------

        --...

        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
        -- ACTIVATE THIS IF REQUIRED
        -- PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);
        
    END LOOP;

    ----------------------------------------------------------------
    -- REMAKE INDEXES -> we want 'pgh_hgm.elpupn_dra_idx' to be updated.
    ----------------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE);
    
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;  
    RETURN 'OK';

  

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_avglengthoverlandflow(
    IN dra_pk_ integer,
    IN _to_km2 double precision,
    IN _to_km double precision)
  RETURNS TABLE(avglengthoverlandflow double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - AVERAGE LENGTHOF OVERLAND FLOW
    USING DRA_PK

    depends on:
        pgh_hgm.pghfn_upa_drainagedensity(dra_pk_,_to_km2,_to_km)
*/

BEGIN
    RETURN
    QUERY

    SELECT
        1./(2.*drainagedensity) ::double precision AS avglengthoverlandflow
    FROM (
        SELECT drainagedensity FROM pgh_hgm.pghfn_upa_drainagedensity(dra_pk_,_to_km2,_to_km)
    ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_axislength(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(axislength double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - AXIS LENGTH
    USING MAX DISTANCE FROM STREAM OUTLET (ENDPOINT) TO CATCHMENT EXTERIOR RING
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY
    -- JOIN TABLES AND CALCULATE EXTERIOR RING AND OUTLET
    SELECT
        ST_MaxDistance(ring_gm, foz_gm) AS axislength
    FROM (
        SELECT
            ST_Exteriorring((ST_Dump(upa_gm_srid_length)).geom) AS ring_gm,
            ST_EndPoint((ST_Dump(upn_gm_srid_length)).geom) AS foz_gm
        FROM (    
            SELECT
                ST_Transform(hig_upa_gm, srid_length) AS upa_gm_srid_length,
                ST_Transform(hig_upn_gm, srid_length) AS upn_gm_srid_length    
            FROM pgh_hgm.pghft_hydro_intel
            WHERE hig_dra_pk = dra_pk_
            ) a
    ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_axislength_ring(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(axislength_ring double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - AXIS LENGTH
    (BASED ON MAX EUCLIDEAN DISTANCE BETWEEN POINTS IN EXTERIOR RING POINTS)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        ST_MaxDistance(ring_gm,ring_gm) AS axislength_ring
    FROM (
        SELECT
            ST_Exteriorring((ST_Dump(upa_gm_srid_length)).geom) AS ring_gm
        FROM (    
            SELECT
                ST_Transform(hig_upa_gm,srid_length) AS upa_gm_srid_length  -- pick srid for exterior ring length.
            FROM pgh_hgm.pghft_hydro_intel
            WHERE hig_dra_pk = dra_pk_
            ) a
        ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_axislength_river(
    IN dra_pk_ integer,
    IN srid_length integer)    
  RETURNS TABLE(axislength_river double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - AXIS LENGTH
    AS THE MAIN RIVER LENGTH
    USING DRA_PK
  
*/
BEGIN
    RETURN
    QUERY

    SELECT
        ST_Length(ST_TRANSFORM(hig_upn_gm,srid_length)) as axislength_river
    FROM
        pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_;

        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
  
  



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_axislength_schumm(
    IN dra_pk_ integer)
  RETURNS TABLE(axislength_schumm double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - AXIAL LENGTH 
    (BY SCHUMM'S EQUATION)
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        (1.312 * (hig_upa_area_km2)^0.568)*1000. ::double precision AS axislength_schumm
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_;
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_circularity(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(circularity double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - CIRCULARITY
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY
    SELECT
        12.57*(area_/perimeter_^2)  AS circularity
    FROM (
        SELECT        
            ST_Area(ST_Transform(hig_upa_gm, srid_area)) AS area_,
            ST_Perimeter(ST_Transform(hig_upa_gm, srid_length)) AS perimeter_
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
        ) a;      
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_compacity(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(compacity double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - COMPACITY
    USING DRA_PK
 
*/

BEGIN
    RETURN
    QUERY

    SELECT    
        0.28*perimeter_/SQRT(area_) AS compacity
    FROM (
        SELECT             
            ST_Perimeter(ST_Transform(hig_upa_gm, srid_length)) AS perimeter_,
            ST_Area(ST_Transform(hig_upa_gm, srid_area)) AS area_
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
        ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_drainagedensity(
    IN dra_pk_ integer,
    IN _to_km2 double precision,
    IN _to_km double precision   
    )
  RETURNS TABLE(drainagedensity double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA DRAINAGE DENSITY
    USING DRA_PK
    
    depends on:
        pghydro.pghfn_variableupstream()
*/

BEGIN
    RETURN
    QUERY

    SELECT
        drainage_density_ AS drainagedensity
    FROM (
        SELECT
            pghydro.pghfn_variableupstream(
                drn_pk,
                'pghydro.pghft_drainage_line',
                'drn_pk',
                'drn_gm_length'
                )*_to_km/(drn_nu_upstreamarea*_to_km2) ::double precision AS drainage_density_
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
        WHERE dra.dra_pk = dra_pk_    
    ) a;

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_elevations(
    IN dra_pk_ integer)
  RETURNS TABLE(dra_pk integer, pixels double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - ELEVATIONS FROM DEM
    USING DRA_PK
    
    depends on:
    - 'hig_upa_gm' at 'pgh_hgm.pghft_hydro_intel'
    - pgh_raster.pghrt_elevation()

*/

DECLARE
    srid_dem integer;

BEGIN

    -- get DEM srid
    SELECT srid INTO srid_dem
    FROM public.raster_columns
    WHERE r_table_schema = 'pgh_raster' AND r_table_name = 'pghrt_elevation';

    -- main query
    RETURN
    QUERY

    SELECT
        dra_pk_ as dra_pk,
        a.pixels
    FROM (    

        SELECT
            UNNEST((st_dumpvalues(rclip)).valarray) as pixels
        FROM (
            --- CLIP RASTER IN POLYGON INTERSECTION
            SELECT
                ST_CLIP(rast, g.upa_gm_srid_dem, -9999) as rclip
            FROM pgh_raster.pghrt_elevation r
            INNER JOIN
            (
            -- JOIN WITH CATCHMENT
                SELECT
                    ST_TRANSFORM(hig_upa_gm, srid_dem) AS upa_gm_srid_dem
                FROM pgh_hgm.pghft_hydro_intel
                WHERE hig_dra_pk = dra_pk_
            ) g
            -- SPATIAL JOIN
            ON ST_Intersects(r.rast, g.upa_gm_srid_dem)
        ) a
    ) a
    WHERE a.pixels IS NOT NULL;   

RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_elevations_stats(
    IN dra_pk_ integer)
RETURNS TABLE(
    upa_elevation_avg double precision,            
    upa_elevation_max double precision,
    upa_elevation_min double precision,
    upa_elevationdrop_maxmin double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - STATISTICS OF ELEVATIONS EXTRACTED FROM DEM
    USING DRA_PK

    depends on:
    - 'hig_upa_gm' at 'pgh_hgm.pghft_hydro_intel'
    - pgh_hgm.pghfn_upa_elevations()

*/

BEGIN
    RETURN
    QUERY

    SELECT
        AVG(pixels) as upa_elevation_avg,    
        MAX(pixels) as upa_elevation_max,
        MIN(pixels) as upa_elevation_min,
        MAX(pixels) - MIN(pixels) AS upa_elevationdrop_maxmin
    FROM pgh_hgm.pghfn_upa_elevations(dra_pk_)

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;       


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_formfactor(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(formfactor double precision) AS
  
$BODY$
/*
    QUERY UPSTREAM AREA POLYGON - FORM FACTOR
    USING DRA_PK
    
*/
BEGIN
    RETURN
    QUERY

    SELECT 1./pgh_hgm.pghfn_upa_shapefactor(dra_pk_,srid_area,srid_length) as formfactor;
        
    RETURN;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_formfactor_ring(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(formfactor_ring double precision) AS
  
$BODY$
/*
    QUERY UPSTREAM AREA - FORM FACTOR
    (BASED ON EXTERIOR RING AXIS)
    USING DRA_PK

*/
BEGIN
    RETURN
    QUERY
    SELECT 1./pgh_hgm.pghfn_upa_shapefactor_ring(dra_pk_,srid_area,srid_length) as formfactor_ring;
        
    RETURN;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_formfactor_river(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(formfactor_river double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - FORM FACTOR
    (BASED ON MAIN RIVER AS AXIAL LENGTH)
    USING DRA_PK
  
*/
BEGIN
    RETURN
    QUERY

    SELECT
        1./pgh_hgm.pghfn_upa_shapefactor_river(dra_pk_,srid_area,srid_length) as formfactor_river;
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
  


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_formfactor_schumm(
    IN dra_pk_ integer)
  RETURNS TABLE(formfactor_schumm double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - FORM FACTOR
    (BASED SCHUMM'S AXIAL LENGTH)
    USING DRA_PK
  
*/
BEGIN
    RETURN
    QUERY

    SELECT 1./pgh_hgm.pghfn_upa_shapefactor_schumm(dra_pk_) as formfactor_schumm;
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_geometries_of_maindrainagelines(
    IN dra_pk_ integer)
RETURNS TABLE(drn_pk integer, dra_pk integer, drn_gm_length numeric, drn_gm geometry) AS
$BODY$
/*
    SELECT 'MAIN DRAINAGE LINES UPSTREAM OF DRA_PK (INCLUDING THE INITIAL)'
    USING DRA_PK

    notes:
        returns pre-calculated DRN_PK, DRA_PK, PGHYDRO LENGTHS AND LINE GEOMETRIES
        first step on merge_maindrainagelines
 
    depends on:
        pghydro.pghfn_main_watercourse_drainagelines(drn_pk_)
*/

DECLARE
    drn_pk_ref integer; 

BEGIN

    -- SET DRN_PK_ CORRESPONDING TO DRA_PK
    -- required for pghydro.pghfn_main_watercourse_drainagelines()
    SELECT drn.drn_pk INTO drn_pk_ref
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
    WHERE dra.dra_pk = dra_pk_;

    -- BEGIN QUERY
    RETURN QUERY

    SELECT
        drn.drn_pk,
        drn.drn_dra_pk AS dra_pk,
        drn.drn_gm_length,
        drn.drn_gm
    FROM pghydro.pghfn_main_watercourse_drainagelines(drn_pk_ref) AS wtc
    JOIN pghydro.pghft_drainage_line drn ON (wtc.drn_pk_ = drn.drn_pk)
    ORDER BY drn.drn_nu_upstreamarea ASC;

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_geometries_of_upstreamdrainageareas(
    IN dra_pk_ integer)
RETURNS TABLE(drn_pk integer, dra_pk integer, dra_gm geometry)
AS
$BODY$
/*
    SELECT 'DRAINAGE AREAS UPSTREAM OF DRA_PK (INCLUDING THE INITIAL)'
    USING DRA_PK

    notes:
        returns DRN_PK, DRA_PK and AREA GEOMETRIES (DRA_GM)
        first step on merge_upstreamdrainageareas

    depends on:
        pghydro.pghfn_upstreamDrainageLines(drn_pk_)
*/

DECLARE
drn_pk_ integer; 

BEGIN

    -- SET DRN_PK CORRESPONDING TO DRA_PK
    -- required for pghydro.pghfn_upstreamDrainageLines
    SELECT drn.drn_pk INTO drn_pk_
    FROM pghydro.pghft_drainage_area dra
    INNER JOIN pghydro.pghft_drainage_line drn ON dra.dra_pk = drn.drn_dra_pk
    WHERE dra.dra_pk = dra_pk_;

    -- BEGIN QUERY
    RETURN
    QUERY

    WITH
    -- GET UPSTREAM DRAINAGE LINES (INCLUSIVE)
    tb_dru AS (
        SELECT
            drn.drn_pk as drn_pk__,
            drn.drn_dra_pk
        FROM pghydro.pghft_drainage_line drn
        WHERE drn.drn_pk IN (SELECT pghydro.pghfn_upstreamdrainagelines(drn_pk_) a)
    ),
    -- JOIN WITH DRAINAGE AREA TABLE
    tb_join AS (
        SELECT
            tb_dru.drn_pk__,
            dra.dra_pk as dra_pk__,
            dra.dra_gm as dra_gm_
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN tb_dru
        ON tb_dru.drn_dra_pk = dra.dra_pk
    )
    -- MAIN QUERY
    SELECT
        drn_pk__ as drn_pk,
        dra_pk__ as dra_pk,
        dra_gm_ as dra_gm
    FROM tb_join

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_hydrodensity(
    IN dra_pk_ integer,
    IN _to_km2 double precision)
  RETURNS TABLE(hydrodensity double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - HYDRODENSITY
    (NUMBER OF REACHES PER UNIT AREA)
    USING DRA_PK

    depends on:
        pghydro.pghfn_upstreamdrainagelines()

    notes:
        it does not account for drainage area bypasses
        it expects and assumes the drainage area is the max value

*/

BEGIN
    RETURN
    QUERY

    SELECT
        COUNT(drn_up)/(MAX(areamon)*_to_km2) :: double precision  AS hydrodensity
    FROM(
        SELECT 
            pghydro.pghfn_upstreamdrainagelines(drn_pk) AS drn_up,
            drn_nu_upstreamarea AS areamon
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
        WHERE dra.dra_pk = dra_pk_ 
    ) a
    GROUP BY dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_kirpicha(IN dra_pk_ integer)
  RETURNS TABLE(
  tc_kirpicha double precision
  ) AS
$BODY$
/*
    QUERY UPSTREAM AREA  - KIRPICH'S TIME OF CONCENTRATION BASED ON CATCHMENT DROP
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    - hig_upn_length_km
    - hig_upa_elevationdrop_m

*/

DECLARE
    cur_drop double precision;

BEGIN

    SELECT INTO cur_drop COALESCE(hig_upa_elevationdrop_m,-9999.)
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_ ;


    IF cur_drop>0 THEN

        RETURN
        QUERY
        
        SELECT
            57.0 * (hig_upn_length_km^3. / (hig_upa_elevationdrop_m))^0.385 AS tc_kirpicha     
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_;
    
    ELSE

        RETURN
        QUERY

        SELECT -9999. ::double precision AS tc_kirpicha;
            
    END IF;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_merge_maindrainagelines(
    IN dra_pk_ integer,
    IN to_srid_drn integer
    )
 RETURNS TABLE (dra_pk integer, upn_gm geometry)
AS
$BODY$
/*
    MERGE 'MAIN DRAINAGE LINES UPSTREAM
    USING DRA_PK

    notes:
        'to_srid_drn' may be important for further calculations
    
    depends on:
     - pgh_hgm.pghfn_upa_geometries_of_maindrainagelines(dra_pk) + dependencies
 
*/

BEGIN
    RETURN
    QUERY

    SELECT
        dra_pk_ as dra_pk,
        ST_TRANSFORM(ST_MAKELINE(pts),to_srid_drn) as upn_gm
    FROM (
        SELECT
            (ST_DUMPPOINTS(drn_gm)).geom  as pts
        FROM
            ( SELECT drn_gm FROM pgh_hgm.pghfn_upa_geometries_of_maindrainagelines(dra_pk_) ) a
    ) a;

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_merge_upstreamdrainageareas(
    IN dra_pk_ integer,
    IN to_srid_dra integer)
 RETURNS TABLE(dra_pk integer, upa_gm geometry)
AS
$BODY$
/*
    MERGE GEOMETRY/POLYGON OF 'UPSTREAM AREAS' BASED ON SPATIAL UNION   
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_upa_geometries_of_upstreamdrainageareas(dra_pk_)

*/

BEGIN
    RETURN
    QUERY

    --3rd step: GET EXTERIOR RING AND COLLECT POLYGON (helps against inner artifacts)
    SELECT
        dra_pk_ AS dra_pk,
        ST_Collect(ST_MakePolygon(ST_ExteriorRing(upa_union_gm))) as upa_gm
    FROM (
        -- 2nd step: MAKES SPATIAL UNION/MERGE
        SELECT
            ST_Union(ST_Transform(dra_gm, to_srid_dra)) as upa_union_gm
        FROM (
            -- 1s step: GET UPSTREAM AREA POLYGONS
            SELECT a.dra_gm
            FROM pgh_hgm.pghfn_upa_geometries_of_upstreamdrainageareas(dra_pk_) a
        ) a
    ) a;   

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_perimeter(
    IN dra_pk_ integer,
    IN srid_length integer,
    IN divfactor double precision default 1.)
  RETURNS TABLE(perimeter double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - PERIMETER
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        perimeter_/divfactor AS perimeter
    FROM (
        SELECT       
            ST_Perimeter(ST_Transform(hig_upa_gm,srid_length)) AS perimeter_
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    )  a ; 
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_reachgradient(
    IN dra_pk_ integer)
  RETURNS TABLE(reachgradient double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - MAIN REACH GRADIENT (m/km)
    BASED ON MAXMIN SLOPE
    FROM THE DRAINAGE ELEVATION PROFILE
    USING DRA_PK

    depends on:
    - 'hig_drn_elevationdrop_maxmin'

*/

BEGIN
    RETURN
    QUERY

    -- SELECT 1000.*pgh_hgm.pghfn_upn_slope_maxmin(dra_pk_) AS reachgradient
       
    SELECT
        1000.*hig_upn_slope_maxmin AS reachgradient
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_ ;      
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_reliefratio(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(reliefratio double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - RELIEF RATIO (m/km)
    RATIO BETWEEN THE ELEVATION DROP FROM THE UPSTREAM AREA ELEVATIONS
    AND THE AXIAL LENGTH (AS MAX DISTANCE FROM CATCHMENT BOUNDARY TO OUTLET)
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_elevations(dra_pk_)
    -- queries elevations internally

*/

BEGIN

    RETURN
    QUERY

    -- -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) as dz
    --     FROM pgh_hgm.pghfn_upa_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP    
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_upa_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),
    -- GET MERGED UPSTREAM AREA GEOMETRY AND MAIN RIVER GEOMETRY
    tb_upa AS (
        SELECT
            hig_dra_pk,
            hig_upn_gm,
            hig_upa_gm
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_    
    ),
    -- JOIN GEOMETRY TABLES AND CALCULATE EXTERIOR RING AND OUTLET POINT
    tb_geom AS (
        SELECT
            dz,
            ST_ExteriorRing((ST_Dump(ST_Transform(hig_upa_gm, srid_length))).geom) as ring_gm, 
            ST_EndPoint((ST_Dump(ST_Transform(hig_upn_gm, srid_length))).geom) as foz_gm
        FROM tb_upa
        INNER JOIN tb_dz ON tb_upa.hig_dra_pk = tb_dz.dra_pk
    )
    -- FINAL CALCULATION
    SELECT
        dz/ST_MaxDistance(foz_gm,ring_gm) AS reliefratio
    FROM tb_geom
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_reliefratio_ring(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(reliefratio_ring double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - RELIEF RATIO (m/km)
    RATIO BETWEEN THE ELEVATION DROP FROM THE UPSTREAM AREA ELEVATIONS
    AND THE AXIAL LENGHTH (AS MAX DISTANCE FROM CATCHMENT BOUNDARY TO OUTLET)
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_drn_elevation(drn_pk_,srid_dem)
    -- queries elevations internally

*/

BEGIN
    RETURN
    QUERY

    -- -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) as dz
    --     FROM pgh_hgm.pghfn_upa_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP    
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_upa_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),    

    -- GET MERGED UPSTREAM AREA GEOMETRY AND MAIN RIVER GEOMETRY
    tb_upa AS (
        SELECT
            hig_dra_pk,
            hig_upn_gm,
            hig_upa_gm
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_    
    ),
    -- JOIN GEOMETRY TABLES AND CALCULATE EXTERIOR RING AND OUTLET POINT
    tb_geom AS (
        SELECT
            dz,
            ST_ExteriorRing((ST_Dump(ST_Transform(hig_upa_gm, srid_length))).geom) as ring_gm
        FROM tb_upa
        INNER JOIN tb_dz ON tb_upa.hig_dra_pk = tb_dz.dra_pk
    )
    -- FINAL CALCULATION
    SELECT
        dz/ST_MaxDistance(ring_gm,ring_gm) AS reliefratio_ring
    FROM tb_geom
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_reliefratio_river(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(reliefratio_river double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - RELIEF RATIO (m/km)
    RATIO BETWEEN THE ELEVATION DROP FROM THE UPSTREAM AREA ELEVATIONS
    AND THE AXIAL LENGHTH AS THE MAIN RIVER LENGTH
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_elevations(dra_pk_)
    -- queries elevations internally

*/

BEGIN
    RETURN
    QUERY

    -- -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) as dz
    --     FROM pgh_hgm.pghfn_upa_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP    
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_upa_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),
    -- GET MERGED UPSTREAM AREA GEOMETRY AND MAIN RIVER GEOMETRY
    tb_upa AS (
        SELECT
            hig_dra_pk,
            ST_LENGTH(ST_TRANSFORM(hig_upn_gm,srid_length)) as upn_length
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_    
    ),
    -- JOIN GEOMETRY TABLES AND CALCULATE EXTERIOR RING AND OUTLET POINT
    tb_geom AS (
        SELECT
            dz,
            upn_length*1000. ::double precision AS axlen_riv
        FROM tb_upa
        INNER JOIN tb_dz ON tb_upa.hig_dra_pk = tb_dz.dra_pk
    )
    -- FINAL CALCULATION
    SELECT
        dz/axlen_riv AS reliefratio_river
    FROM tb_geom

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_reliefratio_schumm(
    IN dra_pk_ integer)
  RETURNS TABLE(reliefratio_schumm double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - RELIEF RATIO (m/km)
    RATIO BETWEEN THE ELEVATION DROP FROM THE UPSTREAM AREA ELEVATIONS
    AND THE AXIAL LENGHTH (GIVEN BY SCHUMM'S EQUATION)
    USING DRA_PK

    depends on:
    - pgh_hgm.pghfn_dra_elevations(dra_pk_)
    -- queries elevations internally

*/

BEGIN
    RETURN
    QUERY

    -- -- PRE-PROCESS ELEVATION DROP
    -- WITH
    -- tb_dz AS (
    --     SELECT
    --         dra_pk,
    --         MAX(pixels)-MIN(pixels) as dz
    --     FROM pgh_hgm.pghfn_upa_elevations(dra_pk_)
    --     GROUP BY dra_pk
    -- ),
    -- GET STORED ELEVATION DROP    
    WITH
    tb_dz AS (
        SELECT
            dra_pk_ AS dra_pk,
            hig_upa_elevationdrop_m AS dz
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ),    

    -- GET MERGED UPSTREAM AREA GEOMETRY AND MAIN RIVER GEOMETRY
    tb_upa AS (
        SELECT
            hig_dra_pk,
            hig_upn_gm,
            hig_upa_gm,
            hig_upa_area_km2
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_    
    ),
    -- JOIN GEOMETRY TABLES AND CALCULATE EXTERIOR RING (USING EQUATION) AND OUTLET POINT
    tb_geom AS (
        SELECT
            dz,
            (1.312 * (hig_upa_area_km2)^0.568)*1000. ::double precision AS axlen_schumm
        FROM tb_upa
        INNER JOIN tb_dz ON tb_upa.hig_dra_pk = tb_dz.dra_pk
    )
    -- FINAL CALCULATION
    SELECT
        dz/axlen_schumm AS reliefratio_schumm
    FROM tb_geom

        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_shapefactor(
    IN dra_pk_ integer, 
    IN srid_area integer,    
    IN srid_length integer)
  RETURNS TABLE(shapefactor double precision) AS
  
$BODY$
/*
    QUERY UPSTREAM AREA - SHAPE FACTOR
    USING DRA_PK
 
*/
BEGIN
    RETURN
    QUERY

    SELECT
        (ST_MaxDistance(ring, foz)^2)/upa_area as shapefactor
    FROM (
        SELECT
            ST_Area(ST_TRANSFORM(hig_upa_gm,srid_area)) as upa_area,
            ST_ExteriorRing((ST_Dump(ST_Transform(hig_upa_gm, srid_length))).geom) as ring, 
            ST_EndPoint((ST_Dump(ST_Transform(hig_upn_gm, srid_length))).geom) as foz 
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
    ) a;
        
    RETURN;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_shapefactor_ring(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer)
  RETURNS TABLE(shapefactor_ring double precision) AS
  
$BODY$
/*
    QUERY UPSTREAM AREA - SHAPE FACTOR
    (BASED ON EXTERIOR RING AXIS)
    USING DRA_PK
 
*/
BEGIN
    RETURN
    QUERY

    SELECT
        (ST_MaxDistance(ring, ring)^2)/upa_area as shapefactor_ring
    FROM (
        SELECT
            ST_Area(ST_TRANSFORM(hig_upa_gm,srid_area)) as upa_area,
            ST_ExteriorRing((ST_Dump(ST_Transform(hig_upa_gm, srid_length))).geom) as ring
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
        ) a;     
        
    RETURN;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_shapefactor_river(
    IN dra_pk_ integer,
    IN srid_area integer,
    IN srid_length integer
    )
  RETURNS TABLE(shapefactor_river double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - SHAPE FACTOR
    BASED ON MAIN RIVER AS AXIAL LENGTH
    USING DRA_PK
  
*/
BEGIN
    RETURN
    QUERY

    SELECT
        (upn_length^2)/upa_area as shapefactor_river
    FROM (

        SELECT   
            ST_Area(ST_TRANSFORM(hig_upa_gm,srid_area)) as upa_area,
            ST_Length(ST_TRANSFORM(hig_upn_gm,srid_length)) as upn_length        
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_

    ) a;   
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
  


 


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_shapefactor_schumm(
    IN dra_pk_ integer)
  RETURNS TABLE(shapefactor_schumm double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - SHAPE FACTOR
    (BASED SCHUMM'S AXIAL LENGTH)
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT 
        axislength_schumm^2/area_m2 AS shapefactor_schumm
    FROM (    
        SELECT
            hig_upa_area_km2*1e6 AS area_m2,
            (1.312 * (hig_upa_area_km2)^0.568)*1000. ::double precision AS axislength_schumm
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_    
    )  a;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_timeofconcentration(IN dra_pk_ integer)
  RETURNS TABLE(
  tc_armycorps double precision,
  tc_carter double precision,
  tc_dooge double precision,
  tc_kirpich double precision,
  tc_wattchow double precision,
  tc_georgeribeiro double precision,
  tc_pasini double precision,
  tc_ventura double precision,
  tc_dnosk1 double precision
  ) AS
$BODY$
/*
    QUERY UPSTREAM AREA - TIME OF CONCENTRATION  (MINUTES)
    USING EQUATIONS FROM ARMY CORPS, CARTER, DOOGE, KIRPICH, WATT&CHOW,
    MANUAL DNIT: GEORGE RIBEIRO (60% RURAL), PASINI, VENTURA, DNOS(K=1)
    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    - hig_upn_length_km
    - hig_upn_slope_adim
    - hig_upa_area_km2  -> for Dooge's model       

*/
DECLARE
    cur_slope double precision;

BEGIN

    SELECT INTO cur_slope COALESCE(hig_upn_slope_adim,-1.)
    FROM pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_ ;

    IF cur_slope>0 THEN

        RETURN
        QUERY
        
        SELECT
            11.46 * (hig_upn_length_km^0.76)/(hig_upn_slope_adim^0.19) AS tc_armycorps,
            5.96*(hig_upn_length_km^0.6)/(hig_upn_slope_adim^0.3) AS tc_carter,
            21.88*(hig_upa_area_km2^0.41)/(hig_upn_slope_adim^0.17) AS tc_dooge,
            57.0 * (hig_upn_length_km^3. / (hig_upn_slope_adim*hig_upn_length_km*1000.))^0.385 AS tc_kirpich,
            7.68*(hig_upn_length_km/(hig_upn_slope_adim^0.5))^0.79 AS tc_wattchow,
            16.*hig_upn_length_km/(1.05-0.2*(0.6))*(100.*hig_upn_slope_adim)^0.04 AS tc_georgeribeiro, --assuming p=0.6
            (60)*0.107*(hig_upa_area_km2*hig_upn_length_km)^(1./3.)/((100.*hig_upn_slope_adim)^0.5) AS tc_pasini,
            (60)*0.127*SQRT(hig_upa_area_km2/(100.*hig_upn_slope_adim)) AS tc_ventura,
            10./(1.0)*(hig_upa_area_km2^0.3)*(hig_upn_length_km^0.2)/((100.*hig_upn_slope_adim)^0.4) AS tc_dnosk1 --assume K=1        
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_;
    
    ELSE

        RETURN
        QUERY

        SELECT
            -9999. ::double precision AS tc_armycorps,
            -9999. ::double precision AS tc_carter,
            -9999. ::double precision AS tc_dooge,
            -9999. ::double precision AS tc_kirpich,
            -9999. ::double precision AS tc_wattchow,  
            -9999. ::double precision AS tc_georgeribeiro,
            -9999. ::double precision AS tc_pasini,
            -9999. ::double precision AS tc_ventura,
            -9999. ::double precision AS tc_dnosk1;
            
    END IF;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upa_totaldrainagelength(
    IN dra_pk_ integer,
    IN _to_km double precision)
  RETURNS TABLE(totaldrainagelength double precision) AS
$BODY$
/*
    QUERY UPSTREAM AREA - TOTAL (SUM OF) LENGTH(S) OF DRAINAGE LINES
    USING DRA_PK

    depends on:
    -pghydro.pghfn_variableupstream(,,'drn_gm_length')
*/

BEGIN
    RETURN
    QUERY

    SELECT
        sum_lengths_*_to_km AS totaldrainagelength
    FROM (
        SELECT
            pghydro.pghfn_variableupstream(
                drn_pk,
                'pghydro.pghft_drainage_line',
                'drn_pk',
                'drn_gm_length'
                ) ::double precision AS sum_lengths_
        FROM pghydro.pghft_drainage_area dra
        INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
        WHERE dra.dra_pk = dra_pk_ 
    ) a;

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_elevationprofiledrop_from_slopes(
    IN dra_pk_ integer)
  RETURNS TABLE(
    elevationdrop_maxmin double precision,
    elevationdrop_s1585 double precision,
    elevationdrop_pipf double precision,
    elevationdrop_z1585 double precision, 
    elevationdrop_harmonic double precision,
    elevationdrop_weighted double precision,       
    elevationdrop_linreg double precision
  ) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - ELEVATION PROFILE DROP 
    FROM SLOPES STORED IN PGHFT_HYDRO_INTEL
    SLOPE MAXMIN, S15-85, PIPF, Z15-85, HARMONIC, WEIGHTED, LINREG

    USING DRA_PK

    requires attributes from 'pgh_hgm.pghft_hydro_intel':
    -hig_upn_length_km
    -hig_upn_slope_maxmin,
    -hig_upn_slope_s1585,
    -hig_upn_slope_pipf,
    -hig_upn_slope_z1585,
    -hig_upn_slope_harmonic,
    -hig_upn_slope_weighted,
    -hig_upn_slope_linreg

*/

BEGIN

    RETURN
    QUERY

    SELECT
        1000.*hig_upn_length_km*hig_upn_slope_maxmin,
        1000.*hig_upn_length_km*hig_upn_slope_s1585,
        1000.*hig_upn_length_km*hig_upn_slope_pipf,
        1000.*hig_upn_length_km*hig_upn_slope_z1585,
        1000.*hig_upn_length_km*hig_upn_slope_harmonic,
        1000.*hig_upn_length_km*hig_upn_slope_weighted,
        1000.*hig_upn_length_km*hig_upn_slope_linreg   
    FROM 
        pgh_hgm.pghft_hydro_intel
    WHERE hig_dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_elevationprofile(
    IN dra_pk_ integer)
  RETURNS TABLE(dra_pk integer, xy integer, z double precision, gm geometry) AS
$BODY$
/*
    QUERY UPSTREAM MAIN-RIVER DRAINAGE LINE  - ELEVATION PROFILE
    USING DRA_PK

    note:
    - queries from 'hig_upn_gm'

*/


DECLARE
    srid_dem integer;

BEGIN

    -- get DEM srid
    SELECT srid INTO srid_dem
    FROM public.raster_columns
    WHERE r_table_schema = 'pgh_raster' AND r_table_name = 'pghrt_elevation';

    --main query
    RETURN QUERY
    SELECT
        dra_pk_ as dra_pk,
        (pgh_raster.pghfn_elevation_profile(line_gm)).*  -- original spacing using pgh_raster
        -- (pgh_raster.pghfn_elevation_profile(line_gm,60)).*    -- 60 m spacing using pgh_raster
        --(pgh_hgm.pghfn_geom_elevationprofile(line_gm)).*  -- original spacing using pgh_hgm standalone function
    FROM
        (
        SELECT ST_TRANSFORM( (ST_DUMP(hig_upn_gm)).geom, srid_dem)    AS line_gm  
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_
        ) a;

    RETURN;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_elevationprofile_onthefly(
    IN dra_pk_ integer,
    IN to_srid_drn integer)
  RETURNS TABLE(dra_pk integer, xy integer, z double precision, gm geometry) AS
$BODY$
/*
    QUERY UPSTREAM MAIN-RIVER DRAINAGE LINE - ELEVATION PROFILE
    (ALTERNATIVE METHOD TO CALL ON THE FLY)
    USING DRN_PK

    note:
    - full query internally -> get-merge upstream geometry
    - operates over query, not over pghft_upn_elevaionprofile table

    depends on:
    - pgh_raster.pghfn_elevation_profile() -> returns (xy integer, z double precision gm geometry)
    - pgh_hgm.pghfn_upa_merge_maindrainagelines(dra_pk_, to_srid_drn)

*/

DECLARE
    srid_dem integer;

BEGIN

    -- get DEM srid
    SELECT srid INTO srid_dem
    FROM public.raster_columns
    WHERE r_table_schema = 'pgh_raster' AND r_table_name = 'pghrt_elevation';

    RETURN QUERY
    SELECT
        dra_pk_ AS dra_pk,
        a.xy,
        a.z,
        a.gm
    FROM (
        -- CALL PGH_RASTER
        SELECT
            (pgh_raster.pghfn_elevation_profile(line_gm)).*  -- original spacing using pgh_raster
            -- (pgh_raster.pghfn_elevation_profile(line_gm,60)).*    -- 60 m spacing using pgh_raster
            --(pgh_hgm.pghfn_geom_elevationprofile(line_gm)).*  -- original spacing using pgh_hgm standalone function
        FROM
            (
            SELECT ST_TRANSFORM( (ST_DUMP(upn_gm)).geom, srid_dem)    AS line_gm  
            FROM pgh_hgm.pghfn_upa_merge_maindrainagelines(dra_pk_, to_srid_drn)
            ) a
    ) a;

    RETURN;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_elevationprofile_stats(
    IN dra_pk_ integer)
  RETURNS TABLE(
      elevation_avg double precision,
      elevation_max double precision,
      elevation_min double precision,
      elevationdrop_maxmin double precision,
      slope_maxmin double precision) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - ELEVATION STATISTICS
    AVERAGE, MAX, MIN, MAXMIN-DROP, MAXMIN-SLOPE
    USING DRA_PK

    note:
    - queries .pghfn_upn_elevationprofile from 'hig_upn_gm'
    - does not query from table 'pghft_upn_elevationprofile'    
    
*/

BEGIN
    RETURN
    QUERY

    SELECT
        AVG(z) AS elevation_avg,
        MAX(z) AS elevation_max,
        MIN(z) AS elevation_min,
        MAX(z) - MIN(z) AS elevationdrop_maxmin,
        (MAX(z) - MIN(z))/MAX(xy) AS slope_maxmin
    FROM 
        (
        SELECT xy,z
        FROM pgh_hgm.pghfn_upn_elevationprofile(dra_pk_)
        ) a;
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_length_1(
    IN dra_pk_ integer,
    IN den_factor double precision default 1.)
RETURNS TABLE(upn_length double precision) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - LENGTH
    WHEN DRAINAGE IS ON WATER COURSE OF ORDER LEVEL == 1
    BASED ON PRE-CALCULATED WATERCOURSES LENGTH AND DISTANCES
    
    note:
        only when "wtc.wtc_nu_pfafstetterwatercoursecodeorder = 1"

*/

BEGIN
    RETURN
    QUERY

	SELECT
        (wtc.wtc_gm_length - drn.drn_nu_distancetosea)/den_factor AS upn_length
    FROM pgh_hgm.pghft_hydro_intel hig
    INNER JOIN pghydro.pghft_drainage_area dra ON dra.dra_pk = hig.hig_dra_pk
    INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
	INNER JOIN pghydro.pghft_watercourse wtc ON wtc.wtc_pk = drn.drn_wtc_pk
    WHERE dra.dra_pk = dra_pk_ AND wtc.wtc_nu_pfafstetterwatercoursecodeorder = 1;

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;








 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_length_2(
    IN dra_pk_ integer,
    IN den_factor double precision default 1.)
RETURNS TABLE(upn_length double precision) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - LENGTH
    WHEN DRAINAGE IS ON WATER COURSE OF ORDER LEVEL > 1
    BASED ON PRE-CALCULATED WATERCOURSES LENGTH AND DISTANCES
    
    note:
        only when "wtc.wtc_nu_pfafstetterwatercoursecodeorder > 1"

*/

BEGIN
    RETURN
    QUERY

	SELECT
        (wtc.wtc_gm_length - drn.drn_nu_distancetowatercourse)/den_factor AS upn_length
    FROM pgh_hgm.pghft_hydro_intel hig
    INNER JOIN pghydro.pghft_drainage_area dra ON dra.dra_pk = hig.hig_dra_pk
    INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_dra_pk = dra.dra_pk
	INNER JOIN pghydro.pghft_watercourse wtc ON wtc.wtc_pk = drn.drn_wtc_pk
    WHERE dra.dra_pk = dra_pk_ AND wtc.wtc_nu_pfafstetterwatercoursecodeorder > 1;
   

    RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_sinuosity(
    IN dra_pk_ integer,
    IN srid_length integer)
  RETURNS TABLE(sinuosity double precision) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - SINUOSITY 
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

    SELECT
        ST_Length(drn_line)/ST_Distance(p1,p2)  :: double precision AS sinuosity
    FROM (
        
        SELECT
            ST_Transform(ST_StartPoint((ST_Dump(hig_upn_gm)).geom),srid_length) AS p1,
            ST_Transform(ST_EndPoint((ST_Dump(hig_upn_gm)).geom),srid_length) AS p2,
            ST_Transform(hig_upn_gm,srid_length) AS drn_line
        FROM
            pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = dra_pk_

        ) a;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_slope_maxmin(
    IN dra_pk_ integer
    )
  RETURNS TABLE(slope_maxmin double precision) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - SLOPE
    BY USING MAXIMUM AND MINIMUM ELEVATIONS 
    
    USING DRA_PK

    note:
    - queries .pghfn_upn_elevationprofile from 'hig_upn_gm'
    - does not query from table 'pghft_upn_elevationprofile'    
*/

BEGIN
    RETURN
    QUERY

    SELECT
        ( MAX(z)-MIN(z))/MAX(xy) AS slope_maxmin
    FROM 
        pgh_hgm.pghfn_upn_elevationprofile(dra_pk_)
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_elevationprofile_stats(
    IN dra_pk_ integer)
  RETURNS TABLE(
    elevation_avg double precision,
    elevation_max double precision,
    elevation_min double precision,
    elevationdrop_maxmin double precision,
    slope_maxmin double precision   
    ) AS
$BODY$
/*
    QUERY UPSTREAM MAIN DRAINAGE-LINE - ELEVATION STATISTICS
    AVERAGE, MAX, MIN MAXMIN-DROP, MAXMIN-SLOPE
    FROM THE TEMPORARY ELEVATION PROFILE OF THE UPSTREAM MAIN-STREAM
    'pgh_hgm.pghft_upn_elevationprofile'
    USING DRA_PK
 
*/

BEGIN
    RETURN
    QUERY

    SELECT
        AVG(z) AS elevation_avg,
        MAX(z) AS elevation_max,
        MIN(z) AS elevation_min,
        MAX(z) - MIN(z) AS elevationdrop_maxmin,
        (MAX(z) - MIN(z))/MAX(xy) AS slope_maxmin
    FROM pgh_hgm.pghft_upn_elevationprofile
    WHERE dra_pk = dra_pk_;
    
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_harmonic(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_harmonic double precision) AS
$BODY$
/*

    QUERY UPSTREAM MAIN DRAINAGE-LINE - SLOPE
    BY USING HARMONIC SLOPE METHOD

    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_upn_elevationprofile' 
    
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    WITH
    -- ELEVATION PROFILE WITH INDEX, NEIGHBOURING POINTS AND MAX VALUE
    tb_elevations AS (
        SELECT
            ROW_NUMBER() OVER (ORDER BY xy) AS idx,  -- auxiliary index
            LAG(xy) OVER (ORDER BY xy) AS xy_previous,
            LAG(z) OVER (ORDER BY xy) AS z_previous,
            xy AS xy_current,
            z AS z_current,
            MAX(xy) OVER() AS profile_length
        FROM pgh_hgm.pghft_upn_elevationprofile
        WHERE dra_pk = dra_pk_
        OFFSET 1
        ),
    -- REMOVES REPEATED COORDINATES
    tb_valid AS (
        SELECT *
        FROM tb_elevations
        WHERE xy_current != xy_previous
        ORDER BY idx
        ),
    -- CALCULATION OF LOCAL SLOPES
    tb_harmelev AS (
        SELECT
            idx,
            xy_previous, xy_current, z_previous, z_current, profile_length,
            -(z_current - z_previous)/(xy_current - xy_previous) AS local_slope,
            (xy_current - xy_previous) AS local_length
        FROM tb_valid
        ORDER BY idx
        ),
    -- FILTER ZERO SLOPES AND PREPARE SLOPE SIGNALS
    tb_harmelev_adj AS (
        SELECT
            idx,
            xy_previous, xy_current, z_previous, z_current, profile_length,
            local_slope,
            local_length,
            -- calculations
            SIGN(local_slope) AS slp_sgn,
            ABS(local_slope) AS slp_abs
        FROM tb_harmelev
        WHERE abs(local_slope)>0
        ), 
    -- POSITIVE DENOMINATOR CHECK (SIGN() TO AVOID ERRORS WITH NEGATIVE SLOPE)
    tb_calc AS (
        SELECT
            CASE WHEN SUM( slp_sgn*local_length/SQRT(slp_abs) )>0 AND COUNT(*)>0 THEN
                --( MAX(xy_current)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
                --( MAX(profile_length)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
                --( SUM(xy_current)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
                ( SUM(local_length)/SUM(slp_sgn*local_length/SQRT(slp_abs)) )^2
            ELSE
                NULL
            END AS slope_harm_
        FROM tb_harmelev_adj
        )
    -- FINAL QUERY THE HARMONIC SLOPE 
    SELECT
        slope_harm_ AS slope_harmonic
    FROM tb_calc
        
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_linreg(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_linreg double precision) AS
$BODY$
/*
    QUERY SLOPE OF MAIN DRAINGE LINE - SLOPE
    BY USING LINEAR REGRESSION SLOPE COEFFICIENT
    
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_drn_elevationprofile'
    
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        slope_regress_ AS slope_linreg
    FROM (
        SELECT
            -regr_slope(z,xy) AS slope_regress_
        FROM pgh_hgm.pghft_upn_elevationprofile
        WHERE dra_pk = dra_pk_
    ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_maxmin(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_maxmin double precision) AS
$BODY$
/*
    QUERY SLOPE OF MAIN DRAINGE LINE - SLOPE
    USING MAXIMUM AND MINIMUM ELEVATIONS 
    
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_upn_elevationprofile'
    
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        ( MAX(z)-MIN(z))/MAX(xy) AS slope_maxmin
    FROM pgh_hgm.pghft_upn_elevationprofile
    WHERE dra_pk = dra_pk_;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_pipf(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_pipf double precision) AS
$BODY$
/*
    QUERY SLOPE OF MAIN DRAINGE LINE - SLOPE
    USING START POINT AND END POINTS
    
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_upn_elevationprofile'
    
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    SELECT
        -(z_pf - z_pi)/(xy_pf - xy_pi) AS slope_pipf
    FROM (
        -- ORGANIZE THE INFORMATION IN ONE LINE
        SELECT
            xy AS xy_pi,
            z AS z_pi,
            LEAD(xy) OVER (ORDER BY xy) AS xy_pf,
            LEAD(z) OVER (ORDER BY xy) AS z_pf       
        FROM (   
            -- RETURN THE START POINT AND END POINT BY ORDERING
            SELECT
                xy,
                z,            
                ROW_NUMBER () OVER (ORDER BY xy DESC) AS idesc,
                ROW_NUMBER () OVER (ORDER BY xy) AS iasc
            FROM pgh_hgm.pghft_upn_elevationprofile
            WHERE dra_pk = dra_pk_
            ) a
            WHERE iasc=1 OR idesc = 1
        ) a
        LIMIT 1;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_s1585(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_s1585 double precision) AS
$BODY$
/*
    QUERY SLOPE OF MAIN DRAINGE LINE - SLOPE   
    BY USING ELEVATIONS LOCATED IN THE 15-85 PERCENTILES S-COORDINATE ALONG THE LENGTH OF THE SECTION 
    
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_upn_elevationprofile'
    
    USING DRA_PK
*/

BEGIN
    RETURN
    QUERY

    WITH
    -- ELEVATION PROFILE WITH INDEX 
    tb_cotas AS (
        SELECT
            ROW_NUMBER() OVER (ORDER BY xy) AS idx,
            xy,
            z
        FROM pgh_hgm.pghft_upn_elevationprofile
        WHERE dra_pk = dra_pk_
    ),

    -- INDEXES OF 15-85 PERCENTILES ALONG THE DRAINAGE LENGTH, ACTUALLY FROM INDEXES.
    tb_percL AS (
    SELECT
        PERCENTILE_DISC(0.15) WITHIN GROUP (ORDER BY idx) AS i1,
        PERCENTILE_DISC(0.85) WITHIN GROUP (ORDER BY idx) AS i2
    FROM tb_cotas
    ),

    -- ELEVATION VALUES AT THE 15-85 POSITIONS
    tb_percZ AS (
    SELECT
        idx,
        xy AS xy1,
        z AS z1,
        LEAD(xy) OVER (ORDER BY xy) AS xy2,
        LEAD(z) OVER (ORDER BY xy) AS z2
    FROM tb_cotas
    WHERE (idx IN (SELECT i1 FROM tb_percL)) OR (idx IN (SELECT i2 FROM tb_percL))
    LIMIT 1
    )

    -- QUERY SLOPE CALCULATION
    -- negative sign adjust reference por positive downslope
    SELECT
        -(z2-z1)/((xy2-xy1)) AS slope_S1585 
    FROM tb_percZ;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_weighted(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_weighted double precision) AS
$BODY$
/*
    QUERY SLOPE OF MAIN DRAINGE LINE - SLOPE
    BY USING WEIGHTED/INTEGRAL METHOD
    
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_upn_elevationprofile' 
    
    USING DRA_PK 
*/

BEGIN
    RETURN
    QUERY

    SELECT
        slope_nint AS slope_weighted
    FROM
        (
        SELECT
            SUM(areainc)*2./((MAX(xyCurrent)^2)) AS slope_nint
        FROM (
            SELECT
                *,
                ( (xyCurrent - xyPrevious) * (zCurrent + zPrevious - 2.*zmin) )/2 AS areainc        
            FROM (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY xy) AS id,  -- index from 1 to nline
                    xy AS xyCurrent,
                    z AS zCurrent,
                    LAG(xy) OVER (ORDER BY xy) AS xyPrevious,
                    LAG(z) OVER (ORDER BY xy) AS zPrevious,
                    MIN(z) OVER ()  AS zmin 
                FROM pgh_hgm.pghft_upn_elevationprofile
                WHERE dra_pk = dra_pk_
                ) a
            ORDER BY id ASC
            OFFSET 1
        ) a
    ) a;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_upn_tmp_slope_z1585(
    IN dra_pk_ integer)
  RETURNS TABLE(slope_z1585 double precision) AS
$BODY$
/*
    QUERY SLOPE OF MAIN DRAINGE LINE - SLOPE
    BY USING THE 15-85 PERCENTILES OF ELEVATIONS
    
    FROM THE TEMPORARY ELEVATION PROFILE
    'pgh_hgm.pghft_upn_elevationprofile' 
    
    USING DRA_PK

*/

BEGIN
    RETURN
    QUERY

        SELECT
            slope_Z1585_ AS slope_Z1585
        FROM (
            SELECT
                (zu - zl)/profile_length AS slope_Z1585_
            FROM (
                SELECT
                    PERCENTILE_CONT(0.15) WITHIN GROUP(ORDER BY z) AS zl,
                    PERCENTILE_CONT(0.85) WITHIN GROUP(ORDER BY z) AS zu,
                    MAX(xy) AS profile_length        
                FROM pgh_hgm.pghft_upn_elevationprofile
                WHERE dra_pk = dra_pk_
                ) a
            ) a;
            
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_drn_hydraulics_defaults(
    dra_pk_ integer)
RETURNS character varying
AS 
$BODY$
/*
    HELPER FUNCTION TO QUERY/UPDATE 'pgh_hgm.pghft_hydro_intel'    
    WITH DEFAULT VALUES FOR REACH HYDRAULIC ATTRIBUTES
    USING DRA_PK

        'hig_drn_manning_n'         :: ~0.035 (Allen etal.)
        'hig_drn_slope_adim'        :: using slope_maxmin
        'hig_drn_elevationdrop_m'   :: using elevationprofiledrop_maxmin
        'hig_drn_width_m'           :: using pghfn_drn_amhg_widthfromarea(dra_pk_,_to_km2)
        'hig_drn_depth_m'           :: using pghfn_drn_amhg_depthfromarea(dra_pk_,_to_km2)


*/
BEGIN

    -- CHANNEL ROUGHNESS MANNING'S
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_drn_manning_n = 0.035
    WHERE hig_dra_pk = dra_pk_;


    -- DRAINAGE SLOPE AND ELEVATION DROP (BASED ON MAXMIN)
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_drn_slope_adim = slope_maxmin,
        hig_drn_elevationdrop_m = elevationdrop_maxmin
        FROM (
            SELECT *
            FROM pgh_hgm.pghfn_drn_elevationprofile_stats(dra_pk_)
            ) a
    WHERE hig_dra_pk=dra_pk_;


    -- DEPTH
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_drn_depth_m = a.hig_drn_depth_m
    FROM (
        SELECT hig_drn_depth_m
        FROM
            pgh_hgm.pghfn_drn_amhg_depthfromarea(dra_pk_,1.)
        ) a
    WHERE hig_dra_pk = dra_pk_;   

    -- WIDTH
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_drn_width_m = a.hig_drn_width_m
    FROM (
        SELECT hig_drn_width_m
        FROM
            pgh_hgm.pghfn_drn_amhg_widthfromarea(dra_pk_,1.)
        ) a
    WHERE hig_dra_pk = dra_pk_;

    RETURN 'OK';        
   

END;
$BODY$
LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_drn_jobson_defaults(
    dra_pk_ integer)
RETURNS character varying
AS 
$BODY$
/*
    HELPER FUNCTION TO QUERY/UPDATE 'pgh_hgm.pghft_hydro_intel'
    WITH DEFAULT VALUES for JOBSON'S MODEL
    USING DRA_PK

        'hig_drn_annual_flow'   :: ~0.025 m³/s.km² (TODO: get from water availability dataset)
        'hig_drn_event_flow'    :: assumed 100% of annual mean flow

    also requires:
        pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i)

*/
BEGIN

    -- ANNUAL MEAN FLOW ASSUMING SPECIFIC FLOW OF 0.025 m³/s.km²
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_drn_annual_flow = 0.025* hig_upa_area_km2
    WHERE hig_dra_pk = dra_pk_;     

    -- EVENT FLOW (m3/s) ASSUMING 100% OF ANNUAL MEAN FLOW
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_drn_event_flow = 1.* hig_drn_annual_flow
    WHERE hig_dra_pk = dra_pk_;  

    RETURN 'OK';

END;
$BODY$
LANGUAGE plpgsql VOLATILE;




 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_index_dropcreate(
    only_drop boolean,
    index_drn_dra boolean,
    index_dra_wtc boolean,
    index_upa boolean,
    index_elpdrn boolean,
    index_elpupn boolean
)
RETURNS character varying
AS $BODY$
/*
   DROP/CREATE INDEXES    
*/

DECLARE

BEGIN

    IF index_drn_dra THEN
        -- MAIN INDEXES DRA, DRN, DRN-DRA
        DROP INDEX IF EXISTS pgh_hgm.hig_drn_idx;
        DROP INDEX IF EXISTS pgh_hgm.hig_dra_idx;
        DROP INDEX IF EXISTS pgh_hgm.hig_drn_dra_idx;
        RAISE NOTICE 'DROP MAIN INDEXES';

        IF NOT only_drop THEN
            CREATE INDEX hig_drn_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_drn_pk);
            CREATE INDEX hig_dra_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_dra_pk);
            CREATE INDEX hig_drn_dra_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_drn_pk,hig_dra_pk);
            RAISE NOTICE 'CREATE MAIN INDEXES';
        END IF;
    END IF;


    -- INDEXES FOR WATERCOURSES + DRA
    IF index_dra_wtc THEN
        DROP INDEX IF EXISTS pgh_hgm.hig_wtc_idx; 
        DROP INDEX IF EXISTS pgh_hgm.hig_dra_wtc_idx;
        RAISE NOTICE 'DROP DRA-WTC INDEXES';

        IF NOT only_drop THEN
            CREATE INDEX hig_wtc_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_wtc_pk);
            CREATE INDEX hig_dra_wtc_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_dra_pk,hig_wtc_pk);
            RAISE NOTICE 'CREATE DRA-WTC INDEXES';
        END IF;

    END IF;

    
    -- INDEXES FOR WATERCOURSES + STRAHLER (FILTER UPA FUNCTIONS)
    IF index_upa THEN
        DROP INDEX IF EXISTS pgh_hgm.hig_dra_wtc_strahler_idx;
        RAISE NOTICE 'DROP UPA INDEXES';
        
        IF NOT only_drop THEN
            CREATE INDEX hig_dra_wtc_strahler_idx ON pgh_hgm.pghft_hydro_intel USING btree(hig_dra_pk,hig_wtc_pk,hig_drn_strahler);    
            RAISE NOTICE 'CREATE UPA INDEXES';
        END IF;

    END IF;
    
    
    -- INDEXES FOR DRN ELEVATION PROFILE TABLE
    IF index_elpdrn THEN  
        DROP INDEX IF EXISTS pgh_hgm.elpdrn_dra_idx;
        RAISE NOTICE 'DROP DRN ELEVATION PROFILE INDEXES';
        
        IF NOT only_drop THEN
            CREATE INDEX elpdrn_dra_idx ON pgh_hgm.pghft_drn_elevationprofile USING btree(dra_pk);
            RAISE NOTICE 'CREATE DRN ELEVATION PROFILE INDEXES';
        END IF;

    END IF;

    -- INDEXES FOR UPN ELEVATION PROFILE TABLE
    IF index_elpupn THEN      
        DROP INDEX IF EXISTS pgh_hgm.elpupn_dra_idx;
        RAISE NOTICE 'DROP UPN ELEVATION PROFILE INDEXES';
        
        IF NOT only_drop THEN
            CREATE INDEX elpupn_dra_idx ON pgh_hgm.pghft_upn_elevationprofile USING btree(dra_pk);
            RAISE NOTICE 'CREATE UPN ELEVATION PROFILE INDEXES';
        END IF;

    END IF;

    RETURN 'OK';
END;

$BODY$
LANGUAGE PLPGSQL VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_mergedgeometries_getupdate(
    IN dra_pk_ integer,
    IN to_srid_dra integer,
    IN to_srid_drn integer)
  RETURNS character varying AS
$BODY$
/*
QUERY/MERGE/UPDATE UPSTREAM AREA GEOMETRY ('hig_upa_gm') AND MAIN RIVER UPSTREAM GEOMETRY ('hig_upn_gm')
USING DRA_PK

*/

DECLARE
time_ timestamp;
i integer;
upn_gm_ geometry;
upa_gm_ geometry;

BEGIN

    -- AUXILIARY VARIABLE
    i:= dra_pk_;

    -- UPSTREAM DRAINAGE AREA
    SELECT a.upa_gm INTO upa_gm_
    FROM (SELECT dra_pk, upa_gm FROM pgh_hgm.pghfn_upa_merge_upstreamdrainageareas(i,to_srid_dra)) a;

    -- UPSTREAM MAIN RIVER
    SELECT a.upn_gm INTO upn_gm_
    FROM (SELECT dra_pk, upn_gm FROM pgh_hgm.pghfn_upa_merge_maindrainagelines(i,to_srid_drn)) a;
    
    UPDATE pgh_hgm.pghft_hydro_intel
    SET    
        hig_upa_gm = upa_gm_,
        hig_upn_gm = upn_gm_    
    WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;
   
RETURN 'OK';

END;
$BODY$
LANGUAGE plpgsql VOLATILE;


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_mergedgeometries_nullify(
    IN dra_pk_ integer)
  RETURNS character varying AS
$BODY$
/*
NULLIFY UPSTREAM AREA GEOMETRY ('hig_upa_gm') AND MAIN RIVER UPSTREAM GEOMETRY ('hig_upn_gm')
USING DRA_PK

*/

DECLARE

BEGIN

    UPDATE pgh_hgm.pghft_hydro_intel
    SET    
        hig_upa_gm = NULL,   -- upstream area
        hig_upn_gm = NULL    -- upstream main river 
    WHERE hig_dra_pk = dra_pk_;
    
RETURN 'OK';

END;
$BODY$
LANGUAGE plpgsql VOLATILE;  


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_srid_create_albers(
    new_srid integer)
  RETURNS character varying AS
$BODY$
/*
    CREATE BRAZIL ALBERS EQUAL AREA CONIC PROJECTION
        EXAMPLE:
        SELECT pgh_hgm.pghfn_utils_srid_create_albers(55555);
*/
DECLARE

existe BOOLEAN;

BEGIN

    SELECT EXISTS (
        SELECT 1
        FROM public.spatial_ref_sys
        WHERE srid = new_srid LIMIT 1
        ) INTO existe;

    IF NOT existe THEN
        INSERT INTO public.spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext)
        VALUES
        (
        new_srid,
        'IBGE',
        new_srid,
        '+proj=aea +lat_1=-2 +lat_2=-22 +lat_0=-12 +lon_0=-54 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ',
        'PROJCS["Brazil_Albers_Equal_Area_Conic",GEOGCS["SIRGAS 2000",DATUM["Sistema_de_Referencia_Geocentrico_para_las_AmericaS_2000",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6674"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4674"]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-54],PARAMETER["Standard_Parallel_1",-2],PARAMETER["Standard_Parallel_2",-22],PARAMETER["latitude_of_center",-12],UNIT["Meter",1],AUTHORITY["IBGE","srid_area"]]'
        );
        RETURN 'BR ALBERS CREATED AT SRID '||quote_literal(new_srid);
    END IF;

RETURN 'SRID '||quote_literal(new_srid)||' ALREADY EXISTS';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_tmp_elevprof_delete(
    IN dra_pk_ integer,
    IN prefix_pk character varying DEFAULT 'drn')
  RETURNS character(2) AS
$BODY$
/*
    DELETE RECORD FROM DRAINAGE LINE ELEVATION PROFILE TABLE
    OR DRAINAGE LINE ELEVATION PROFILE TABLE
    USING DRA_PK
*/


BEGIN

    IF  prefix_pk = 'drn' THEN
    
        DELETE FROM pgh_hgm.pghft_drn_elevationprofile
        WHERE dra_pk = dra_pk_;
    
    ELSIF (prefix_pk = 'upn') THEN -- get from stored upn_gm

        DELETE FROM pgh_hgm.pghft_upn_elevationprofile
        WHERE dra_pk = dra_pk_;
    
    END IF; 

RETURN 'OK';
    

END;
$BODY$
LANGUAGE plpgsql VOLATILE;      


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(
    IN dra_pk_ integer,
    IN prefix_pk character varying DEFAULT 'drn',
    IN srid_length integer DEFAULT NULL)    
  RETURNS character varying AS
$BODY$
/*
    FRESH QUERY FOR
    ELEVATION PROFILE ('drn' OR 'upn')
    AND UPDATE INTO TEMPORARY TABLES
    ('pgh_hgm.pghtb_drn_elevprofile' OR 'pgh_hgm.pghtb_upn_elevprofile')
    
    USING DRA_PK

    note:
    - srid_length only has effect for upn profile.
    --If provided it will make the full query (get-merge drainage) instead of using the stored upn_gm geometry.

*/

DECLARE

BEGIN
    
    IF  prefix_pk = 'drn' THEN
    
        --TRUNCATE TABLE pgh_hgm.pghft_drn_elevationprofile;

        DELETE FROM pgh_hgm.pghft_drn_elevationprofile
        WHERE dra_pk = dra_pk_;

        INSERT INTO pgh_hgm.pghft_drn_elevationprofile
        (SELECT dra_pk, xy, z, gm geometry FROM pgh_hgm.pghfn_drn_elevationprofile(dra_pk_));
    
    ELSIF (prefix_pk = 'upn' AND srid_length IS NULL) THEN -- get from stored upn_gm

        --TRUNCATE TABLE pgh_hgm.pghft_upn_elevationprofile;

        DELETE FROM pgh_hgm.pghft_upn_elevationprofile
        WHERE dra_pk = dra_pk_;

        INSERT INTO pgh_hgm.pghft_upn_elevationprofile
         (SELECT dra_pk, xy, z, gm geometry FROM pgh_hgm.pghfn_upn_elevationprofile(dra_pk_));

    ELSIF (prefix_pk = 'upn' AND srid_length IS NOT NULL) THEN -- build upn_gm internally first.

        --TRUNCATE TABLE pgh_hgm.pghft_upn_elevationprofile;

        DELETE FROM pgh_hgm.pghft_upn_elevationprofile
        WHERE dra_pk = dra_pk_;

        INSERT INTO pgh_hgm.pghft_upn_elevationprofile
        (SELECT dra_pk, xy, z, gm geometry FROM pgh_hgm.pghfn_upn_elevationprofile_onthefly(dra_pk_, srid_length));
    END IF; 

RETURN 'OK';
END;
$BODY$
LANGUAGE plpgsql VOLATILE;    


 

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_tmp_elevprof_truncate(
    IN prefix_pk character varying DEFAULT 'drn')
  RETURNS character varying AS
$BODY$
/*
    TRUNCATE ELEVATION PROFILE TEMPORARY TABLE ('drn' OR 'upn')
    'pgh_hgm.pghft_drn_elevationprofile' OR 
    'pgh_hgm.pghft_upn_elevationprofile'

*/
BEGIN
   
    IF  prefix_pk = 'drn' THEN
    
        TRUNCATE TABLE pgh_hgm.pghft_drn_elevationprofile;

    
    ELSIF prefix_pk = 'upn' THEN
    
        TRUNCATE TABLE pgh_hgm.pghft_upn_elevationprofile;
 

    END IF;  
    
RETURN 'OK';

END;
$BODY$
LANGUAGE plpgsql VOLATILE;    


 
CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_utils_upn_hydraulics_defaults(
    dra_pk_ integer)
    RETURNS character varying

AS $BODY$
/*
    HELPER FUNCTION TO QUERY/UPDATE 'pgh_hgm.pghft_hydro_intel'
    WITH DEFAULT STATS FOR MAIN RIVER UPSTREAM

        'hig_upn_length_'  :: using pghfn_upa_maindrainagesumlength
        'hig_upn_length_km'  :: using maindrainagesumlength
        'hig_upn_slope_adim'  :: using pghfn_upn_elevationprofile_stats
        'hig_upn_elevationdrop_m'  :: using pghfn_upn_elevationprofile_stats

    USING DRA_PK

*/
BEGIN

    -- MAIN-RIVER TOTAL LENGTH
    /*
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_upn_length_ = a.upn_length,
        hig_upn_length_km = a.upn_length
    FROM (
        SELECT upn_length
        FROM pgh_hgm.pghfn_upn_length(dra_pk_,1.)
        ) a
    WHERE hig_dra_pk = dra_pk_;
    */

    -- MAIN-RIVER DEM STATS
    UPDATE pgh_hgm.pghft_hydro_intel
    SET
        hig_upn_elevationdrop_m  = a.elevationdrop_maxmin,
        hig_upn_slope_adim  = a.slope_maxmin
    FROM (
        SELECT
            elevationdrop_maxmin,
            slope_maxmin
        FROM pgh_hgm.pghfn_upn_elevationprofile_stats(dra_pk_)
        ) a
    WHERE hig_dra_pk = dra_pk_; 
    
RETURN 'OK';
   
END;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_core_main(
    ilower integer,
    iupper integer,
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
   CORE REFERENCE FOR
   CALCULATION OF LOCAL CATCHMENT AND DRAINAGE LINE ATTRIBUTES 
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;
    cur_slope double precision;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    -- CHECK BOUNDS
    IF (iupper = 0) THEN
        iupper := imax;
        RAISE NOTICE 'IUPPER NOT SPECIFIED, USING MAX(HIG_DRA_PK)';
        --iupper := ilower;
        --RAISE NOTICE 'IUPPER NOT SPECIFIED, RUNNING SINGLE HIG_DRA_PK';
    END IF;

    IF (ilower = 0 AND iupper = imax) THEN
        RAISE NOTICE 'RUNNING FOR MIN(HIG_DRA_PK)...MAX(HIG_DRA_PK)';
    ELSE
        IF (ilower < imin OR ilower>imax OR ilower> iupper OR iupper<imin OR iupper>imax) THEN
            RAISE NOTICE 'CHECK DRA_PK BOUNDS';
            RETURN 'CHECK DRA_PK BOUNDS';
        ELSE
            imin := ilower;
            imax := iupper;
        END IF;
    END IF;    
    
    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax; 

    --------------------------------------------------------
    -- DROP AND CREATE INDEXES
    --------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE);


    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP


        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        -- QUERY AND INSERT ELEVATION PROFILE INTO 'pghft_drn_elevationprofile'
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'drn');

        /*
        -- check if table was updated properly
        IF NOT EXISTS( SELECT 1 FROM pgh_hgm.pghft_drn_elevationprofile WHERE drn_pk = i) THEN
            RAISE EXCEPTION 'CURRENT "drn_pk" % NOT FOUND in "pgh_hgm.pghft_drn_elevationprofile":%', i,now();
        END IF;
        */

        -- EXTRACT REACH/STREAM ELEVATION STATISTICS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_elevation_avg = a.elevation_avg,
            hig_drn_elevation_max = a.elevation_max,
            hig_drn_elevation_min = a.elevation_min
        FROM (
            SELECT
                elevation_avg, elevation_max, elevation_min
            FROM pgh_hgm.pghfn_drn_tmp_elevationprofile_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;
    
       
        -- EXTRACT REACH/STREAM SLOPE
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_slope_maxmin = a.slope_maxmin,
            hig_drn_slope_pipf = a.slope_pipf,
            hig_drn_slope_s1585 = a.slope_s1585,
            hig_drn_slope_z1585 = a.slope_z1585,
            hig_drn_slope_linreg = a.slope_linreg,
            hig_drn_slope_weighted = a.slope_weighted,
            hig_drn_slope_harmonic = a.slope_harmonic        
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_drn_tmp_slope_maxmin(i),
                pgh_hgm.pghfn_drn_tmp_slope_pipf(i),
                pgh_hgm.pghfn_drn_tmp_slope_s1585(i),
                pgh_hgm.pghfn_drn_tmp_slope_z1585(i),        
                pgh_hgm.pghfn_drn_tmp_slope_linreg(i),
                pgh_hgm.pghfn_drn_tmp_slope_weighted(i),
                pgh_hgm.pghfn_drn_tmp_slope_harmonic(i)  --NULL               
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


        -- EXTRACT REACH/STREAM EQUIVALENT DROP   
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_elevationdrop_maxmin = a.elevationdrop_maxmin,
            hig_drn_elevationdrop_s1585 = a.elevationdrop_s1585,
            hig_drn_elevationdrop_pipf = a.elevationdrop_pipf,
            hig_drn_elevationdrop_z1585  = a.elevationdrop_z1585,
            hig_drn_elevationdrop_harmonic = a.elevationdrop_harmonic,
            hig_drn_elevationdrop_weighted = a.elevationdrop_weighted,
            hig_drn_elevationdrop_linreg = a.elevationdrop_linreg
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_drn_elevationprofiledrop_from_slopes(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;              

        
        ----------------------------------------------------------------
        -- OPERATIONS RELATED TO HGM INDEXES AND GEOMETRIC ATTRIBUTES
        --------------------------------------------------------------
        -- LOCAL AREA ATTRIBUTES (good to gofrom pghydro)
        -- -> THESE ARE MORE INTERPRETABLE FOR UPA
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_drainagedensity = a.drainagedensity,
            hig_dra_hydrodensity = a.hydrodensity,
            hig_dra_avglengthoverlandflow = a.avglengthoverlandflow
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_drainagedensity(i,1.,1.),
                pgh_hgm.pghfn_dra_hydrodensity(i,1.),
                pgh_hgm.pghfn_dra_avglengthoverlandflow(i,1.,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;   

        -- LOCAL CATCHMENT ELEVATION STATISTICS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_elevation_avg = a.dra_elevation_avg,
            hig_dra_elevation_max = a.dra_elevation_max,
            hig_dra_elevation_min = a.dra_elevation_min,            
            hig_dra_elevationdrop_m = a.dra_elevationdrop_maxmin
        FROM (
            SELECT
                dra_elevation_avg,
                dra_elevation_max,
                dra_elevation_min,
                dra_elevationdrop_maxmin
            FROM pgh_hgm.pghfn_dra_elevations_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;          

        -- LOCAL CATCHMENT ATTRIBUTES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_perimeter_ = a.perimeter,
            hig_dra_perimeter_km = a.perimeter/1000,
            hig_dra_circularity = a.circularity,
            hig_dra_compacity = a.compacity,
            hig_dra_axislength = a.axislength,
            hig_dra_shapefactor = a.shapefactor,
            hig_dra_formfactor = a.formfactor,          
            --hig_dra_reliefratio = a.reliefratio,
            --hig_dra_reachgradient = a.reachgradient,
            hig_drn_sinuosity = a.sinuosity        
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_perimeter(i,srid_length,1.),   -- perimeter in m              
                pgh_hgm.pghfn_dra_circularity(i,srid_area,srid_length), --circularity
                pgh_hgm.pghfn_dra_compacity(i,srid_area,srid_length), -- compacity
                pgh_hgm.pghfn_dra_axislength(i,srid_length), -- axial length     
                pgh_hgm.pghfn_dra_shapefactor(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor(i,srid_area,srid_length),  -- form factor                    
                --pgh_hgm.pghfn_dra_reliefratio(i,srid_length), -- relief ratio (require catchment dra_elevationdrop)
                --pgh_hgm.pghfn_dra_reachgradient(i),  -- reach gradient (redundant to slope drn_slope_maxmin)
                pgh_hgm.pghfn_drn_sinuosity(i,srid_length) -- sinuosity, actually a drainage attribute
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

        -- REACH GRADIENT  (BASED ON PRE-CALCULATED DRN MAXMIN SLOPE)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_reachgradient = a.reachgradient
        FROM ( SELECT * FROM pgh_hgm.pghfn_dra_reachgradient(i) ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

        -- RELIEF RATIO (BASED ON PRE-CALCULATED DRA MAXMIN SLOPE)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_reliefratio = a.reliefratio
        FROM ( SELECT * FROM pgh_hgm.pghfn_dra_reliefratio(i,srid_length) ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;

        -------------------------------------------------------------
        -- EXPERIMENTAL: VARIANTS OF SOME CATCHMENTS ATTRIBUTES  ("AXIS-LENGTH METHOD")
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_axislength_ring = a.axislength_ring,
            hig_dra_shapefactor_ring = a.shapefactor_ring,
            hig_dra_formfactor_ring = a.formfactor_ring,          
            hig_dra_reliefratio_ring = a.reliefratio_ring,

            hig_dra_axislength_river = a.axislength_river,
            hig_dra_shapefactor_river = a.shapefactor_river,
            hig_dra_formfactor_river = a.formfactor_river,          
            hig_dra_reliefratio_river = a.reliefratio_river,

            hig_dra_axislength_schumm = a.axislength_schumm,
            hig_dra_shapefactor_schumm = a.shapefactor_schumm,
            hig_dra_formfactor_schumm = a.formfactor_schumm,          
            hig_dra_reliefratio_schumm = a.reliefratio_schumm

        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_dra_axislength_ring(i,srid_length), -- axial length            
                pgh_hgm.pghfn_dra_shapefactor_ring(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor_ring(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_dra_reliefratio_ring(i,srid_length), -- relief ratio (require catchment DEM)

                pgh_hgm.pghfn_dra_axislength_river(i,srid_length), -- axial length            
                pgh_hgm.pghfn_dra_shapefactor_river(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor_river(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_dra_reliefratio_river(i,srid_length), -- relief ratio (require catchment DEM)

                pgh_hgm.pghfn_dra_axislength_schumm(i,1.), -- axial length            
                pgh_hgm.pghfn_dra_shapefactor_schumm(i,1.),  -- shape factor
                pgh_hgm.pghfn_dra_formfactor_schumm(i,1.),  -- form factor        
                pgh_hgm.pghfn_dra_reliefratio_schumm(i,1.) -- relief ratio (require catchment DEM)                        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;  





        -------------------------------------------------------------------------------
        -- DEPTH/WIDTH FROM AT-MANY-STATION HYDRAULIC GEOMETRY (GEOMORPHOLOGY RELATIONS)
        -------------------------------------------------------------------------------
        /* -- NOW IN pghfn_utils_drn_hydraulics_defaults()
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_depth_m = a.hig_drn_depth_m,
            hig_drn_width_m = a.hig_drn_width_m
        FROM (
            SELECT 
                *
            FROM
                pgh_hgm.pghfn_drn_amhg_depthfromarea(i,1.),
                pgh_hgm.pghfn_drn_amhg_widthfromarea(i,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    
        */

        -------------------------------------------------------------------------------
        -- BEGIN OPERATIONS USING HGM HYDRO INTEL
        -------------------------------------------------------------------------------    
        -- COPY SLOPE AND STREAMDROP TO USE AS REFERENCE
        UPDATE pgh_hgm.pghft_hydro_intel    
        SET       
            hig_drn_slope_adim = hig_drn_slope_maxmin,
            hig_drn_elevationdrop_m = hig_drn_elevationdrop_maxmin
        WHERE hig_dra_pk=i;

        
        -- TIME OF CONCENTRATION
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_tc_armycorps = a.tc_armycorps,
            hig_dra_tc_carter = a.tc_carter,
            hig_dra_tc_dooge = a.tc_dooge,
            hig_dra_tc_kirpich = a.tc_kirpich,
            hig_dra_tc_wattchow = a.tc_wattchow,
            hig_dra_tc_georgeribeiro = a.tc_georgeribeiro,
            hig_dra_tc_pasini = a.tc_pasini,
            hig_dra_tc_ventura = a.tc_ventura,
            hig_dra_tc_dnosk1 = a.tc_dnosk1              
        FROM (
            SELECT
                tc_armycorps,
                tc_carter,
                tc_dooge,
                tc_kirpich,
                tc_wattchow,
                tc_georgeribeiro,
                tc_pasini,
                tc_ventura,
                tc_dnosk1
            FROM pgh_hgm.pghfn_dra_timeofconcentration(i)   
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;    

        -- TIME OF CONCENTRATION BASED ON LOCAL CATCHMENT DROP
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_dra_tc_kirpicha = a.tc_kirpicha 
        FROM (
            SELECT
                tc_kirpicha
            FROM pgh_hgm.pghfn_dra_kirpicha(i)   
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;            
        

        -----------------------------------------------------------------------------
        -- FOLLOWING STEPS ONLY MAKE SENSE FOR POSITIVE SLOPES
        -----------------------------------------------------------------------------
        -- CHECK NULL/NEGATIVE SLOPE
        SELECT INTO cur_slope COALESCE(hig_drn_slope_adim,-1.)
        FROM pgh_hgm.pghft_hydro_intel
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;
    
        IF NOT (cur_slope > 0. ::numeric ) THEN        
            RAISE NOTICE ' ** SKIP: NEGATIVE OR NULL SLOPE **';
            CONTINUE;
        ELSE
            RAISE NOTICE ' --SLOPE= %',cur_slope;
        END IF;

        -----------------------------------------------------------------------------
        -- STREAM VELOCITY, CELERITY AND TRAVEL TIME BASED ON MANNING'S EQUATION
        -----------------------------------------------------------------------------
        -- PREPARE
        PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
    

        -- KINEMATIC HYDRAULICS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_velmann = a.hig_drn_velmann,
            hig_drn_celmann = a.hig_drn_celmann,
            hig_drn_trlmann = a.hig_drn_trlmann_minutes,
            hig_drn_velmann_lr = a.hig_drn_velmann_lr,
            hig_drn_celmann_lr = a.hig_drn_celmann_lr,
            hig_drn_trlmann_lr = a.hig_drn_trlmann_lr_minutes        
        FROM (
            SELECT 
                hig_drn_velmann,
                hig_drn_celmann,
                hig_drn_trlmann_minutes,
                hig_drn_velmann_lr,
                hig_drn_celmann_lr,
                hig_drn_trlmann_lr_minutes
            FROM pgh_hgm.pghfn_drn_wavetravel_kinematic(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_slope_adim>0.;


        -- DYNAMIC WAVE
        UPDATE pgh_hgm.pghft_hydro_intel
        SET 
            hig_drn_celdyna = a.hig_drn_celdyna,
            hig_drn_trldyna = a.hig_drn_trldyna_minutes
        FROM (
            SELECT
                hig_drn_celdyna,
                hig_drn_trldyna_minutes
            FROM pgh_hgm.pghfn_drn_wavetravel_dynamic(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL; 

        
        -----------------------------------------------------------------------------
        -- JOBSON TRAVEL TIMES
        -----------------------------------------------------------------------------
        -- PREPARE
        --PERFORM pgh_hgm.pghfn_utils_drn_hydraulics_defaults(i);
        PERFORM pgh_hgm.pghfn_utils_drn_jobson_defaults(i);
        
        -- TIME OF PEAK AND TIME OF LEAD-EDGING (FROM START TO END OF REACH LENGTH)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_drn_jobson_tpeak = a.hig_drn_jobson_tpeak,
            hig_drn_jobson_tlead = a.hig_drn_jobson_tlead,
            hig_drn_jobson_tpeak_shortest = a.hig_drn_jobson_tpeak_shortest,
            hig_drn_jobson_tlead_shortest = a.hig_drn_jobson_tlead_shortest        
        FROM (
            SELECT 
                hig_drn_jobson_tpeak,
                hig_drn_jobson_tlead,
                hig_drn_jobson_tpeak_shortest,
                hig_drn_jobson_tlead_shortest
            FROM pgh_hgm.pghfn_drn_jobson_traveltime(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;        

        --RAISE NOTICE 'DRAINAGE %/%', i, imax;  

        
        ----------------------------------------------------------------
        -- DELETE RECORDS OF CURRENT DRA_PK FROM ELEVATION PROFILE
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_delete(i,'drn');
    
    
    -- FINISH
    END LOOP;


    --------------------------------------------------------
    -- DROP INDEXES
    --------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE);

    RETURN 'OK';
    
    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION pgh_hgm.pghfn_calculate_core_main_upa(
    ilower integer,
    iupper integer,    
    srid_area integer,
    srid_length integer)
  RETURNS character varying AS
$BODY$
/*
   CORE REFERENCE FOR
   CALCULATION OF UPSTREAM AREA/RIVER ATTRIBUTES
   
   note:
    - sequentially make and store upstream geometries (upn_gm and upa_gm) into pghft_hydro_intel
    - nullifies upn_gm and upa_gm at end of each loop
*/

DECLARE
    time_ timestamp;
    i integer;
    imin integer;
    imax integer;
    cur_slope double precision;

BEGIN

    -- TABLE ROWS REFERENCES
    imin := min(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;
    imax := max(hig_dra_pk) FROM pgh_hgm.pghft_hydro_intel;

    -- CHECK BOUNDS
    IF (iupper = 0) THEN
        iupper := imax;
        RAISE NOTICE 'IUPPER NOT SPECIFIED, USING MAX(HIG_DRA_PK)';
        --iupper := ilower;
        --RAISE NOTICE 'IUPPER NOT SPECIFIED, RUNNING SINGLE HIG_DRA_PK';
    END IF;

    IF (ilower = 0 AND iupper = imax) THEN
        RAISE NOTICE 'RUNNING FOR MIN(HIG_DRA_PK)...MAX(HIG_DRA_PK)';
    ELSE
        IF (ilower < imin OR ilower>imax OR ilower> iupper OR iupper<imin OR iupper>imax) THEN
            RAISE NOTICE 'CHECK DRA_PK BOUNDS';
            RETURN 'CHECK DRA_PK BOUNDS';
        ELSE
            imin := ilower;
            imax := iupper;
        END IF;
    END IF;        

    RAISE NOTICE 'LOOP SETUP DRA_PK = % - %',imin,imax;
    

    --------------------------------------------------------
    -- DROP AND CREATE INDEXES
    --------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(FALSE, TRUE, FALSE, TRUE, FALSE, TRUE);


    --------------------------------------------------------
    -- MAIN LOOP - ASSUMES EXISTING DRA_PK FROM IMIN TO IMAX
    --------------------------------------------------------
    FOR i IN imin..imax LOOP

        
        RAISE NOTICE 'BEGIN OF PROCESS %/%: %', i,imax,timeofday();

        ----------------------------------------------------------------
        -- MAKE AND STORE UPSTREAM GEOMETRIES IN HYDRO_INTEL 
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_mergedgeometries_getupdate(i,srid_area,srid_length);
        

        ----------------------------------------------------------------
        -- OPERATIONS RELATED TO HGM INDEXES AND GEOMETRIC ATTRIBUTES
        --------------------------------------------------------------        
        -- UPSTREAM AREA ATTRIBUTES (good to gofrom pghydro)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_drainagedensity = a.drainagedensity,
            hig_upa_hydrodensity = a.hydrodensity,
            hig_upa_avglengthoverlandflow = a.avglengthoverlandflow,
            hig_upa_totaldrainagelength = a.totaldrainagelength
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_drainagedensity(i,1.,1.),
                pgh_hgm.pghfn_upa_hydrodensity(i,1.),
                pgh_hgm.pghfn_upa_avglengthoverlandflow(i,1.,1.),
                pgh_hgm.pghfn_upa_totaldrainagelength(i,1.)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

   
        ------------------------------------------------------------------------------------
        -- OPERATIONS OF CATCHMENT AND GEOMETRIC ATTRIBUTES ON "MERGED UPSTREAM AREA"
        -------------------------------------------------------------------------------------
        -- UPSTREAM CATCHMENT ELEVATION STATISTICS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_elevation_avg = a.upa_elevation_avg,
            hig_upa_elevation_max = a.upa_elevation_max,
            hig_upa_elevation_min = a.upa_elevation_min,
            hig_upa_elevationdrop_m = a.upa_elevationdrop_maxmin
        FROM (
            SELECT
                upa_elevation_avg,
                upa_elevation_max,
                upa_elevation_min,
                upa_elevationdrop_maxmin
            FROM pgh_hgm.pghfn_upa_elevations_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;   


        -- UPSTREAM AREA GEOMETRIC INDEXES
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_perimeter_ = a.perimeter,
            hig_upa_perimeter_km = a.perimeter/1000.,
            hig_upa_circularity = a.circularity,
            hig_upa_compacity = a.compacity,
            hig_upa_axislength = a.axislength,        
            hig_upa_shapefactor = a.shapefactor,
            hig_upa_formfactor = a.formfactor,
            --hig_upa_reachgradient = a.reachgradient,
            --hig_upa_reliefratio = a.reliefratio,
            hig_upn_sinuosity = a.sinuosity
        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_perimeter(i,srid_length,1.),    -- perimeter in m
                pgh_hgm.pghfn_upa_circularity(i,srid_area,srid_length), --circularity        
                pgh_hgm.pghfn_upa_compacity(i,srid_area,srid_length), -- compacity  
                pgh_hgm.pghfn_upa_axislength(i,srid_length), -- axial length              
                pgh_hgm.pghfn_upa_shapefactor(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor(i,srid_area,srid_length),  -- form factor                    
                --pgh_hgm.pghfn_upa_reachgradient(i), -- reach gradient (requires upn_slope_maxmin)
                --pgh_hgm.pghfn_upa_reliefratio(i,srid_length), -- relief ratio (requires upa_elevationdrop_m)
                pgh_hgm.pghfn_upn_sinuosity(i,srid_length)  -- sinuosity, actually main river drainage
                
            ) a        
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        -- RELIEF RATIO (BASED ON PRE-CALCULATED UPA MAXMIN SLOPE)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_reliefratio = a.reliefratio
        FROM ( SELECT * FROM pgh_hgm.pghfn_upa_reliefratio(i,srid_length) ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;


        -- EXPERIMENTAL: VARIANTS OF SOME CATCHMENTS ATTRIBUTES ("AXIS-LENGTH METHOD")
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_axislength_ring = a.axislength_ring,
            hig_upa_shapefactor_ring = a.shapefactor_ring,
            hig_upa_formfactor_ring = a.formfactor_ring,          
            hig_upa_reliefratio_ring = a.reliefratio_ring,

            hig_upa_axislength_river = a.axislength_river,
            hig_upa_shapefactor_river = a.shapefactor_river,
            hig_upa_formfactor_river = a.formfactor_river,          
            hig_upa_reliefratio_river = a.reliefratio_river,

            hig_upa_axislength_schumm = a.axislength_schumm,
            hig_upa_shapefactor_schumm = a.shapefactor_schumm,
            hig_upa_formfactor_schumm = a.formfactor_schumm,          
            hig_upa_reliefratio_schumm = a.reliefratio_schumm

        FROM (
            SELECT
                *
            FROM
                pgh_hgm.pghfn_upa_axislength_ring(i,srid_length), -- axial length            
                pgh_hgm.pghfn_upa_shapefactor_ring(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor_ring(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_upa_reliefratio_ring(i,srid_length), -- relief ratio (require catchment DEM)

                pgh_hgm.pghfn_upa_axislength_river(i,srid_length), -- axial length            
                pgh_hgm.pghfn_upa_shapefactor_river(i,srid_area,srid_length),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor_river(i,srid_area,srid_length),  -- form factor        
                pgh_hgm.pghfn_upa_reliefratio_river(i,srid_length), -- relief ratio (require catchment DEM)

                pgh_hgm.pghfn_upa_axislength_schumm(i), -- axial length            
                pgh_hgm.pghfn_upa_shapefactor_schumm(i),  -- shape factor
                pgh_hgm.pghfn_upa_formfactor_schumm(i),  -- form factor        
                pgh_hgm.pghfn_upa_reliefratio_schumm(i) -- relief ratio (require catchment DEM)                        
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;    

    

        ------------------------------------------------------------------------
        -- OPERATIONS RELATED TO DEM ALONG THE MAIN-STREAM "MERGED" DRAINAGE 
        ------------------------------------------------------------------------
        -- QUERY AND UPDATE ELEVATION PROFILE OF THE MAIN RIVER INTO 'pghft_upn_elevationprofile'
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_getinsert(i,'upn');

        -- DEFAULTS FOR MAIN UPSTREAM RIVER (LENGTH, SLOPE)
        PERFORM pgh_hgm.pghfn_utils_upn_hydraulics_defaults(i);

        
        -- TIME OF CONCENTRATION FOR THE MAIN-RIVER
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_tc_armycorps = a.tc_armycorps,
            hig_upa_tc_carter = a.tc_carter,
            hig_upa_tc_dooge = a.tc_dooge,
            hig_upa_tc_kirpich = a.tc_kirpich,
            hig_upa_tc_wattchow = a.tc_wattchow,
            hig_upa_tc_georgeribeiro = a.tc_georgeribeiro,
            hig_upa_tc_pasini = a.tc_pasini,
            hig_upa_tc_ventura = a.tc_ventura,
            hig_upa_tc_dnosk1 = a.tc_dnosk1
        FROM (
            SELECT
                tc_armycorps,
                tc_carter,
                tc_dooge,
                tc_kirpich,
                tc_wattchow,
                tc_georgeribeiro,
                tc_pasini,
                tc_ventura,
                tc_dnosk1
            FROM pgh_hgm.pghfn_upa_timeofconcentration(i)   
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;   

        -- TIME OF CONCENTRATION BASED ON WATERSHED DROP
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_tc_kirpicha = a.tc_kirpicha 
        FROM (
            SELECT
                tc_kirpicha
            FROM pgh_hgm.pghfn_upa_kirpicha(i)   
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler > 1;   

        -- UPSTREAM MAIN RIVER ELEVATION STATISTICS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_elevation_avg = a.elevation_avg,
            hig_upn_elevation_max = a.elevation_max,
            hig_upn_elevation_min = a.elevation_min
        FROM (
            SELECT
                elevation_avg, elevation_max, elevation_min
            FROM pgh_hgm.pghfn_upn_tmp_elevationprofile_stats(i)
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;
        

        -- UPSTREAM MAIN RIVER SLOPE FROM DIFFERENT METHODS
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_slope_maxmin = a.slope_maxmin,
            hig_upn_slope_pipf = a.slope_pipf,
            hig_upn_slope_s1585 = a.slope_s1585,
            hig_upn_slope_z1585 = a.slope_z1585,
            hig_upn_slope_linreg = a.slope_linreg,
            hig_upn_slope_weighted = a.slope_weighted,
            hig_upn_slope_harmonic = a.slope_harmonic        
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_tmp_slope_maxmin(i),
                pgh_hgm.pghfn_upn_tmp_slope_pipf(i),
                pgh_hgm.pghfn_upn_tmp_slope_s1585(i),
                pgh_hgm.pghfn_upn_tmp_slope_z1585(i),        
                pgh_hgm.pghfn_upn_tmp_slope_linreg(i),
                pgh_hgm.pghfn_upn_tmp_slope_weighted(i),
                pgh_hgm.pghfn_upn_tmp_slope_harmonic(i)             
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;


        -- UPSTREAM MAIN RIVER ELEVATION DROP (BASED ON PRE-CALCULATED SLOPES)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upn_elevationdrop_maxmin = a.elevationdrop_maxmin,
            hig_upn_elevationdrop_s1585 = a.elevationdrop_s1585,
            hig_upn_elevationdrop_pipf = a.elevationdrop_pipf,
            hig_upn_elevationdrop_z1585  = a.elevationdrop_z1585,
            hig_upn_elevationdrop_harmonic = a.elevationdrop_harmonic,
            hig_upn_elevationdrop_weighted = a.elevationdrop_weighted,
            hig_upn_elevationdrop_linreg = a.elevationdrop_linreg
        FROM (
            SELECT *
            FROM
                pgh_hgm.pghfn_upn_elevationprofiledrop_from_slopes(i)            
            ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL AND hig_drn_strahler  > 1;

        -- MAIN RIVER REACH GRADIENT (BASED ON PRE-CALCULATED MAXMIN SLOPE)
        UPDATE pgh_hgm.pghft_hydro_intel
        SET
            hig_upa_reachgradient = a.reachgradient
        FROM ( SELECT * FROM pgh_hgm.pghfn_upa_reachgradient(i) ) a
        WHERE hig_dra_pk = i AND hig_wtc_pk IS NOT NULL;        

    
        ----------------------------------------------------------------
        -- NULLIFY UPSTREAM GEOMETRIES WHICH ARE STORED IN HYDRO_INTEL TO SAVE MEMORY
        ----------------------------------------------------------------
        -- PERFORM pgh_hgm.pghfn_utils_mergedgeometries_nullify(i);

        ----------------------------------------------------------------
        -- DELETE RECORDS OF CURRENT DRA_PK FROM ELEVATION PROFILE
        ----------------------------------------------------------------
        PERFORM pgh_hgm.pghfn_utils_tmp_elevprof_delete(i,'upn');


    END LOOP;

    --------------------------------------------------------
    -- DROP INDEXES
    --------------------------------------------------------
    -- args: (only_drop, index_drn_dra, index_dra_wtc, index_upa, index_elpdrn, index_elpupn)
    PERFORM pgh_hgm.pghfn_utils_index_dropcreate(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE);

    RETURN 'OK';

    time_ := timeofday();
    RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

