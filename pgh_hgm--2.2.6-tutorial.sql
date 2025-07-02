--
-- Copyright (c) 2025 Alexandre de Amorim Teixeira, pghydro.project@gmail.com
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

--Postgresql version 9+
--PostGIS version 3
--PostGIS Raster version 3
--PgHydro version 6.6
--Pgh_Raster version 6.6
--pgh_raster.pghrt_elevation loaded in SRID 3857

--INSTALLATION

--1 - Download the last pghydro stable release file Source code (zip) from the site https://github.com/pghydro/pghydro/releases
--2 - Unzip, copy and paste *.sql and *.control files to \PostgreSQL\x.x\share\extension

--Authors:  

--Mino V Sorribas, mino.sorribas@gmail.com
--Fernando M Fan, fernando.fan@ufrgs.br
--Stefany G Lima, stefglima@gmail.com
--Maria Eduarda P Alves, duda.epa@gmail.com
--Alexandre de Amorim Teixeira, pghydro.project@gmail.com  

---------------------------------------------------------------------------------------------------
--PGH_HGM_Tutorial: PgHydro Hydrological Geomorphology Calculations Extension - v.2.2.6 (2025.06.24)
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------
-- INSTALL EXTENSIONS
------------------------------------------------------------------------

CREATE EXTENSION postgis_raster;
CREATE EXTENSION pgh_raster;
CREATE EXTENSION pgh_hgm;

------------------------------------------------------------------------
-- IMPORT DEM (ELEVATION)
------------------------------------------------------------------------

raster2pgsql -s 3857 -I -C -M -a outputDem.tif -F -t 200x200 pgh_raster.pghrt_elevation | psql -U postgres -d database -h localhost -p 5432

------------------------------------------------------------------------
-- START UP TABLE PGH-HGM -> update table with data from pghydro
------------------------------------------------------------------------
SELECT pgh_hgm.pghfn_tables_initialize();

------------------------------------------------------------
-- LOCAL SCALE:  Drainage line (DRN) and Drainage Area (DRA)
------------------------------------------------------------
-- pre-processing
SELECT pgh_hgm.pghfn_prepro_calculate();

--> drainage lines slope(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_drn_slope_maxmin(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_pipf(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_s1585(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_z1585(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_linreg(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_weighted(55555, 5880); 
--SELECT pgh_hgm.pghfn_calculate_drn_slope_harmonic(55555, 5880); -- not recomended

-- elevation  profile and elevation-drop stats(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_drn_elevationprofile_stats(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_elevationprofiledrop_from_slopes(55555, 5880);

-- drainage line attributes(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_drn_sinuosity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_amhg_depth_width(55555, 5880); -- depth and width

-- drainage area attributes(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_dra_avglengthoverlandflow(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_axislength(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_circularity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_compacity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_drainagedensity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_formfactor(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_hydrodensity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_perimeter(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_shapefactor(55555, 5880);

-- watershed DEM stats

DROP INDEX IF EXISTS pghydro.dra_gm_idx_2;

CREATE INDEX IF NOT EXISTS dra_gm_idx_2 ON pghydro.pghft_drainage_area USING gist (ST_TRANSFORM(dra_gm,3857));

SELECT pgh_hgm.pghfn_calculate_dra_elevations_stats(55555, 5880);  -- heaviest processing (conformal projection, equidistant projection)

--Small Drainage area update with no altimeter data

UPDATE pgh_hgm.pghft_hydro_intel int
SET hig_dra_elevation_avg = a.dra_elevation_avg, hig_dra_elevation_max = a.dra_elevation_max, hig_dra_elevation_min = a.dra_elevation_min, hig_dra_elevationdrop_m = a.dra_elevationdrop_maxmin
FROM
(
WITH clipped_tiles AS (
SELECT a.dra_pk, ST_Clip(dem.rast, a.geom) AS rast, dem.rid
FROM pgh_raster.pghrt_elevation dem
JOIN (
SELECT dra_pk, ST_TRANSFORM(ST_PointOnSurface(dra_gm), 3857) as geom
FROM pghydro.pghft_drainage_area dra
INNER JOIN 
(
SELECT hig_dra_pk
FROM pgh_hgm.pghft_hydro_intel
WHERE hig_dra_elevationdrop_m IS NULL AND hig_wtc_pk IS NOT NULL
) a ON (dra.dra_pk = a.hig_dra_pk)
) as a
ON ST_Intersects(a.geom, ST_ConvexHull(dem.rast))
)
SELECT
dra_pk,
(ST_SummaryStatsAgg(rast, 1, true)).mean as dra_elevation_avg,
(ST_SummaryStatsAgg(rast, 1, true)).max as dra_elevation_max,
(ST_SummaryStatsAgg(rast, 1, true)).min as dra_elevation_min,
((ST_SummaryStatsAgg(rast, 1, true)).max - (ST_SummaryStatsAgg(rast, 1, true)).min) as dra_elevationdrop_maxmin
FROM clipped_tiles
GROUP BY dra_pk
) as a
WHERE a.dra_pk = int.hig_dra_pk;

-- Dependency attributes(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_dra_reachgradient(55555, 5880); -- uses hig_drn_slope_maxmin
SELECT pgh_hgm.pghfn_calculate_dra_reliefratio(55555, 5880);  -- uses hig_dra_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_dra_bonus_ring(55555, 5880);  -- uses hig_dra_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_dra_bonus_river(55555, 5880);  -- uses hig_dra_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_dra_bonus_schumm(55555, 5880);  -- uses hig_dra_elevationdrop_m

-- jobson model(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_drn_jobson_initialize(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_jobson_traveltime(55555, 5880);

-- celerity, timetravel, etc.(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_drn_wavetravel(55555, 5880);

-- concentration time(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_dra_timeofconcentration(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_kirpicha(55555, 5880);

--------------------------------------------------------------
-- UPSTREAM SCALE: Drainage line (UPN) and Drainage Area (UPB)
--------------------------------------------------------------
-- pre-processing(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_prepro_calculate_upa(55555, 5880);

--- upstream water course slope(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_upn_slope_maxmin(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upn_slope_pipf(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_s1585(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_z1585(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_linreg(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_weighted(55555, 5880);
-- SELECT pgh_hgm.pghfn_calculate_upn_slope_harmonic(55555, 5880); -- not recomended

-- upstream elevation profile and elevation-drop stats(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_upn_elevationprofile_stats(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_elevationprofiledrop_from_slopes(55555, 5880);

-- upstream water course attributes(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_upn_sinuosity(55555, 5880); 

-- upstream watershed attributes(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_upa_avglengthoverlandflow(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_axislength(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upa_circularity(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_compacity(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_drainagedensity(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_formfactor(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_hydrodensity(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_perimeter(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upa_shapefactor(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upa_totaldrainagelength(55555, 5880);

--SELECT *
--FROM pgh_hgm.pghft_hydro_intel
--LIMIT 100

-- Upstream DEM stats(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_upa_elevations_stats_agg(); -- heaviest processing

-- dependency attributes(conformal projection, equidistant projection)
SELECT pgh_hgm.pghfn_calculate_upa_reachgradient(55555, 5880); -- utiiza de hig_upn_slope_maxmin
SELECT pgh_hgm.pghfn_calculate_upa_reliefratio(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_bonus_ring(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_bonus_river(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_bonus_schumm(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_timeofconcentration(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upa_kirpicha(55555, 5880);

--> Copy the headwater attribute data from upn to upa
SELECT pgh_hgm.pghfn_postpro_updateheadwaters();

--EXPORT EN-US DATA

DROP TABLE IF EXISTS pgh_output.geoft_bho_drainage_line_hgm;
CREATE TABLE pgh_output.geoft_bho_drainage_line_hgm AS
SELECT
drn.v001,
drn.v002,
drn.v003,
drn.v004,
drn.v005,
drn.v006,
drn.v007,
drn.v008,
drn.v009,
drn.v010,
drn.v011,
drn.v012,
drn.v013,
drn.v014,
drn.v015,
drn.v016,
drn.v017,
drn.v018,
drn.v019,
drn.v020,
drn.v021,
drn.v022,
drn.v023,
drn.v024,
drn.v025,
drn.v026,
hgm.hig_pk,
hgm.hig_drn_pk,
hgm.hig_dra_pk,
hgm.hig_wtc_pk,
hgm.hig_drn_strahler,
hgm.hig_drn_elevation_avg,
hgm.hig_drn_elevation_max,
hgm.hig_drn_elevation_min,
hgm.hig_drn_elevationdrop_maxmin,
hgm.hig_drn_elevationdrop_s1585,
hgm.hig_drn_elevationdrop_pipf,
hgm.hig_drn_elevationdrop_z1585,
hgm.hig_drn_elevationdrop_harmonic,
hgm.hig_drn_elevationdrop_weighted,
hgm.hig_drn_elevationdrop_linreg,
hgm.hig_drn_slope_maxmin,
hgm.hig_drn_slope_s1585,
hgm.hig_drn_slope_pipf,
hgm.hig_drn_slope_z1585,
hgm.hig_drn_slope_harmonic,
hgm.hig_drn_slope_weighted,
hgm.hig_drn_slope_linreg,
hgm.hig_dra_area_,
hgm.hig_dra_area_km2,
hgm.hig_dra_perimeter_,
hgm.hig_dra_perimeter_km,
hgm.hig_dra_axislength,
hgm.hig_dra_circularity,
hgm.hig_dra_compacity,
hgm.hig_dra_shapefactor,
hgm.hig_dra_formfactor,
hgm.hig_drn_sinuosity,
hgm.hig_dra_reliefratio,
hgm.hig_dra_reachgradient,
hgm.hig_dra_elevation_avg,
hgm.hig_dra_elevation_max,
hgm.hig_dra_elevation_min,
hgm.hig_dra_elevationdrop_m,
hgm.hig_dra_drainagedensity,
hgm.hig_dra_hydrodensity,
hgm.hig_dra_avglengthoverlandflow,
hgm.hig_drn_length_,
hgm.hig_drn_length_km,
hgm.hig_drn_depth_m,
hgm.hig_drn_width_m,
hgm.hig_drn_elevationdrop_m,
hgm.hig_drn_slope_adim,
hgm.hig_drn_manning_n,
hgm.hig_drn_velmann,
hgm.hig_drn_celmann,
hgm.hig_drn_trlmann,
hgm.hig_drn_velmann_lr,
hgm.hig_drn_celmann_lr,
hgm.hig_drn_trlmann_lr,
hgm.hig_drn_celdyna,
hgm.hig_drn_trldyna,
hgm.hig_upa_area_,
hgm.hig_upa_area_km2,
hgm.hig_upa_perimeter_,
hgm.hig_upa_perimeter_km,
hgm.hig_upa_drainagedensity,
hgm.hig_upa_hydrodensity,
hgm.hig_upa_avglengthoverlandflow,
hgm.hig_upa_totaldrainagelength,
hgm.hig_upa_axislength,
hgm.hig_upa_circularity,
hgm.hig_upa_compacity,
hgm.hig_upa_shapefactor,
hgm.hig_upa_formfactor,
hgm.hig_upn_sinuosity,
hgm.hig_upa_elevation_avg,
hgm.hig_upa_elevation_max,
hgm.hig_upa_elevation_min,
hgm.hig_upa_elevationdrop_m,
hgm.hig_upa_reliefratio,
hgm.hig_upa_reachgradient,
hgm.hig_dra_tc_kirpich,
hgm.hig_dra_tc_dooge,
hgm.hig_dra_tc_carter,
hgm.hig_dra_tc_armycorps,
hgm.hig_dra_tc_wattchow,
hgm.hig_dra_tc_kirpicha,
hgm.hig_dra_tc_georgeribeiro,
hgm.hig_dra_tc_pasini,
hgm.hig_dra_tc_ventura,
hgm.hig_dra_tc_dnosk1,
hgm.hig_upa_tc_kirpich,
hgm.hig_upa_tc_dooge,
hgm.hig_upa_tc_carter,
hgm.hig_upa_tc_armycorps,
hgm.hig_upa_tc_wattchow,
hgm.hig_upa_tc_kirpicha,
hgm.hig_upa_tc_georgeribeiro,
hgm.hig_upa_tc_pasini,
hgm.hig_upa_tc_ventura,
hgm.hig_upa_tc_dnosk1,
hgm.hig_upn_elevation_avg,
hgm.hig_upn_elevation_max,
hgm.hig_upn_elevation_min,
hgm.hig_upn_length_,
hgm.hig_upn_length_km,
hgm.hig_upn_elevationdrop_m,
hgm.hig_upn_slope_adim,
hgm.hig_upn_slope_maxmin,
hgm.hig_upn_slope_s1585,
hgm.hig_upn_slope_pipf,
hgm.hig_upn_slope_z1585,
hgm.hig_upn_slope_harmonic,
hgm.hig_upn_slope_weighted,
hgm.hig_upn_slope_linreg,
hgm.hig_upn_elevationdrop_maxmin,
hgm.hig_upn_elevationdrop_s1585,
hgm.hig_upn_elevationdrop_pipf,
hgm.hig_upn_elevationdrop_z1585,
hgm.hig_upn_elevationdrop_harmonic,
hgm.hig_upn_elevationdrop_weighted,
hgm.hig_upn_elevationdrop_linreg,
hgm.hig_drn_annual_flow,
hgm.hig_drn_event_flow,
hgm.hig_drn_jobson_tpeak,
hgm.hig_drn_jobson_tlead,
hgm.hig_drn_jobson_tpeak_shortest,
hgm.hig_drn_jobson_tlead_shortest,
hgm.hig_drn_reservoir_depth_m,
hgm.hig_drn_reservoir_length_m,
hgm.hig_drn_reservoir_celwave,
hgm.hig_drn_reservoir_trlwave,
hgm.hig_dra_axislength_schumm,
hgm.hig_dra_shapefactor_schumm,
hgm.hig_dra_formfactor_schumm,
hgm.hig_dra_reliefratio_schumm,
hgm.hig_dra_axislength_ring,
hgm.hig_dra_shapefactor_ring,
hgm.hig_dra_formfactor_ring,
hgm.hig_dra_reliefratio_ring,
hgm.hig_dra_axislength_river,
hgm.hig_dra_shapefactor_river,
hgm.hig_dra_formfactor_river,
hgm.hig_dra_reliefratio_river,
hgm.hig_upa_axislength_schumm,
hgm.hig_upa_shapefactor_schumm,
hgm.hig_upa_formfactor_schumm,
hgm.hig_upa_reliefratio_schumm,
hgm.hig_upa_axislength_ring,
hgm.hig_upa_shapefactor_ring,
hgm.hig_upa_formfactor_ring,
hgm.hig_upa_reliefratio_ring,
hgm.hig_upa_axislength_river,
hgm.hig_upa_shapefactor_river,
hgm.hig_upa_formfactor_river,
hgm.hig_upa_reliefratio_river,
drn.v027
FROM pgh_output.geoft_bho_drainage_line drn
INNER JOIN pgh_hgm.pghft_hydro_intel hgm ON (drn.v001 = hgm.hig_drn_pk);

DROP TABLE IF EXISTS pgh_output.geoft_bho_drainage_area_hgm;
CREATE TABLE pgh_output.geoft_bho_drainage_area_hgm AS
SELECT
dra.v001,
dra.v002,
dra.v003,
dra.v004,
dra.v005,
dra.v006,
dra.v007,
dra.v008,
dra.v009,
dra.v010,
dra.v011,
dra.v012,
dra.v013,
dra.v014,
hgm.hig_pk,
hgm.hig_drn_pk,
hgm.hig_dra_pk,
hgm.hig_wtc_pk,
hgm.hig_drn_strahler,
hgm.hig_drn_elevation_avg,
hgm.hig_drn_elevation_max,
hgm.hig_drn_elevation_min,
hgm.hig_drn_elevationdrop_maxmin,
hgm.hig_drn_elevationdrop_s1585,
hgm.hig_drn_elevationdrop_pipf,
hgm.hig_drn_elevationdrop_z1585,
hgm.hig_drn_elevationdrop_harmonic,
hgm.hig_drn_elevationdrop_weighted,
hgm.hig_drn_elevationdrop_linreg,
hgm.hig_drn_slope_maxmin,
hgm.hig_drn_slope_s1585,
hgm.hig_drn_slope_pipf,
hgm.hig_drn_slope_z1585,
hgm.hig_drn_slope_harmonic,
hgm.hig_drn_slope_weighted,
hgm.hig_drn_slope_linreg,
hgm.hig_dra_area_,
hgm.hig_dra_area_km2,
hgm.hig_dra_perimeter_,
hgm.hig_dra_perimeter_km,
hgm.hig_dra_axislength,
hgm.hig_dra_circularity,
hgm.hig_dra_compacity,
hgm.hig_dra_shapefactor,
hgm.hig_dra_formfactor,
hgm.hig_drn_sinuosity,
hgm.hig_dra_reliefratio,
hgm.hig_dra_reachgradient,
hgm.hig_dra_elevation_avg,
hgm.hig_dra_elevation_max,
hgm.hig_dra_elevation_min,
hgm.hig_dra_elevationdrop_m,
hgm.hig_dra_drainagedensity,
hgm.hig_dra_hydrodensity,
hgm.hig_dra_avglengthoverlandflow,
hgm.hig_drn_length_,
hgm.hig_drn_length_km,
hgm.hig_drn_depth_m,
hgm.hig_drn_width_m,
hgm.hig_drn_elevationdrop_m,
hgm.hig_drn_slope_adim,
hgm.hig_drn_manning_n,
hgm.hig_drn_velmann,
hgm.hig_drn_celmann,
hgm.hig_drn_trlmann,
hgm.hig_drn_velmann_lr,
hgm.hig_drn_celmann_lr,
hgm.hig_drn_trlmann_lr,
hgm.hig_drn_celdyna,
hgm.hig_drn_trldyna,
hgm.hig_upa_area_,
hgm.hig_upa_area_km2,
hgm.hig_upa_perimeter_,
hgm.hig_upa_perimeter_km,
hgm.hig_upa_drainagedensity,
hgm.hig_upa_hydrodensity,
hgm.hig_upa_avglengthoverlandflow,
hgm.hig_upa_totaldrainagelength,
hgm.hig_upa_axislength,
hgm.hig_upa_circularity,
hgm.hig_upa_compacity,
hgm.hig_upa_shapefactor,
hgm.hig_upa_formfactor,
hgm.hig_upn_sinuosity,
hgm.hig_upa_elevation_avg,
hgm.hig_upa_elevation_max,
hgm.hig_upa_elevation_min,
hgm.hig_upa_elevationdrop_m,
hgm.hig_upa_reliefratio,
hgm.hig_upa_reachgradient,
hgm.hig_dra_tc_kirpich,
hgm.hig_dra_tc_dooge,
hgm.hig_dra_tc_carter,
hgm.hig_dra_tc_armycorps,
hgm.hig_dra_tc_wattchow,
hgm.hig_dra_tc_kirpicha,
hgm.hig_dra_tc_georgeribeiro,
hgm.hig_dra_tc_pasini,
hgm.hig_dra_tc_ventura,
hgm.hig_dra_tc_dnosk1,
hgm.hig_upa_tc_kirpich,
hgm.hig_upa_tc_dooge,
hgm.hig_upa_tc_carter,
hgm.hig_upa_tc_armycorps,
hgm.hig_upa_tc_wattchow,
hgm.hig_upa_tc_kirpicha,
hgm.hig_upa_tc_georgeribeiro,
hgm.hig_upa_tc_pasini,
hgm.hig_upa_tc_ventura,
hgm.hig_upa_tc_dnosk1,
hgm.hig_upn_elevation_avg,
hgm.hig_upn_elevation_max,
hgm.hig_upn_elevation_min,
hgm.hig_upn_length_,
hgm.hig_upn_length_km,
hgm.hig_upn_elevationdrop_m,
hgm.hig_upn_slope_adim,
hgm.hig_upn_slope_maxmin,
hgm.hig_upn_slope_s1585,
hgm.hig_upn_slope_pipf,
hgm.hig_upn_slope_z1585,
hgm.hig_upn_slope_harmonic,
hgm.hig_upn_slope_weighted,
hgm.hig_upn_slope_linreg,
hgm.hig_upn_elevationdrop_maxmin,
hgm.hig_upn_elevationdrop_s1585,
hgm.hig_upn_elevationdrop_pipf,
hgm.hig_upn_elevationdrop_z1585,
hgm.hig_upn_elevationdrop_harmonic,
hgm.hig_upn_elevationdrop_weighted,
hgm.hig_upn_elevationdrop_linreg,
hgm.hig_drn_annual_flow,
hgm.hig_drn_event_flow,
hgm.hig_drn_jobson_tpeak,
hgm.hig_drn_jobson_tlead,
hgm.hig_drn_jobson_tpeak_shortest,
hgm.hig_drn_jobson_tlead_shortest,
hgm.hig_drn_reservoir_depth_m,
hgm.hig_drn_reservoir_length_m,
hgm.hig_drn_reservoir_celwave,
hgm.hig_drn_reservoir_trlwave,
hgm.hig_dra_axislength_schumm,
hgm.hig_dra_shapefactor_schumm,
hgm.hig_dra_formfactor_schumm,
hgm.hig_dra_reliefratio_schumm,
hgm.hig_dra_axislength_ring,
hgm.hig_dra_shapefactor_ring,
hgm.hig_dra_formfactor_ring,
hgm.hig_dra_reliefratio_ring,
hgm.hig_dra_axislength_river,
hgm.hig_dra_shapefactor_river,
hgm.hig_dra_formfactor_river,
hgm.hig_dra_reliefratio_river,
hgm.hig_upa_axislength_schumm,
hgm.hig_upa_shapefactor_schumm,
hgm.hig_upa_formfactor_schumm,
hgm.hig_upa_reliefratio_schumm,
hgm.hig_upa_axislength_ring,
hgm.hig_upa_shapefactor_ring,
hgm.hig_upa_formfactor_ring,
hgm.hig_upa_reliefratio_ring,
hgm.hig_upa_axislength_river,
hgm.hig_upa_shapefactor_river,
hgm.hig_upa_formfactor_river,
hgm.hig_upa_reliefratio_river,
dra.v015
FROM pgh_output.geoft_bho_drainage_area dra
LEFT JOIN pgh_hgm.pghft_hydro_intel hgm ON (dra.v001 = hgm.hig_dra_pk);

--EXPORT PT-BR DATA

DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bhae_trecho_drenagem_hgm;
CREATE TABLE pgh_output_pt_br.geoft_bhae_trecho_drenagem_hgm AS
SELECT
drn.drn_pk,
drn.cotrecho,
drn.noorigem,
drn.nodestino,
drn.cocursodag,
drn.cobacia,
drn.nucomptrec,
drn.nudistbact,
drn.nudistcdag,
drn.nuareacont,
drn.nuareamont,
drn.nogenerico,
drn.noligacao,
drn.noespecif,
drn.noriocomp,
drn.nooriginal,
drn.cocdadesag,
drn.nutrjus,
drn.nudistbacc,
drn.nuareabacc,
drn.nuordemcda,
drn.nucompcda,
drn.nunivotto,
drn.nunivotcda,
drn.nustrahler,
drn.dedominial,
drn.dsversao,
hgm.hig_pk,
hgm.hig_drn_pk,
hgm.hig_dra_pk,
hgm.hig_wtc_pk,
hgm.hig_drn_strahler,
hgm.hig_drn_elevation_avg,
hgm.hig_drn_elevation_max,
hgm.hig_drn_elevation_min,
hgm.hig_drn_elevationdrop_maxmin,
hgm.hig_drn_elevationdrop_s1585,
hgm.hig_drn_elevationdrop_pipf,
hgm.hig_drn_elevationdrop_z1585,
hgm.hig_drn_elevationdrop_harmonic,
hgm.hig_drn_elevationdrop_weighted,
hgm.hig_drn_elevationdrop_linreg,
hgm.hig_drn_slope_maxmin,
hgm.hig_drn_slope_s1585,
hgm.hig_drn_slope_pipf,
hgm.hig_drn_slope_z1585,
hgm.hig_drn_slope_harmonic,
hgm.hig_drn_slope_weighted,
hgm.hig_drn_slope_linreg,
hgm.hig_dra_area_,
hgm.hig_dra_area_km2,
hgm.hig_dra_perimeter_,
hgm.hig_dra_perimeter_km,
hgm.hig_dra_axislength,
hgm.hig_dra_circularity,
hgm.hig_dra_compacity,
hgm.hig_dra_shapefactor,
hgm.hig_dra_formfactor,
hgm.hig_drn_sinuosity,
hgm.hig_dra_reliefratio,
hgm.hig_dra_reachgradient,
hgm.hig_dra_elevation_avg,
hgm.hig_dra_elevation_max,
hgm.hig_dra_elevation_min,
hgm.hig_dra_elevationdrop_m,
hgm.hig_dra_drainagedensity,
hgm.hig_dra_hydrodensity,
hgm.hig_dra_avglengthoverlandflow,
hgm.hig_drn_length_,
hgm.hig_drn_length_km,
hgm.hig_drn_depth_m,
hgm.hig_drn_width_m,
hgm.hig_drn_elevationdrop_m,
hgm.hig_drn_slope_adim,
hgm.hig_drn_manning_n,
hgm.hig_drn_velmann,
hgm.hig_drn_celmann,
hgm.hig_drn_trlmann,
hgm.hig_drn_velmann_lr,
hgm.hig_drn_celmann_lr,
hgm.hig_drn_trlmann_lr,
hgm.hig_drn_celdyna,
hgm.hig_drn_trldyna,
hgm.hig_upa_area_,
hgm.hig_upa_area_km2,
hgm.hig_upa_perimeter_,
hgm.hig_upa_perimeter_km,
hgm.hig_upa_drainagedensity,
hgm.hig_upa_hydrodensity,
hgm.hig_upa_avglengthoverlandflow,
hgm.hig_upa_totaldrainagelength,
hgm.hig_upa_axislength,
hgm.hig_upa_circularity,
hgm.hig_upa_compacity,
hgm.hig_upa_shapefactor,
hgm.hig_upa_formfactor,
hgm.hig_upn_sinuosity,
hgm.hig_upa_elevation_avg,
hgm.hig_upa_elevation_max,
hgm.hig_upa_elevation_min,
hgm.hig_upa_elevationdrop_m,
hgm.hig_upa_reliefratio,
hgm.hig_upa_reachgradient,
hgm.hig_dra_tc_kirpich,
hgm.hig_dra_tc_dooge,
hgm.hig_dra_tc_carter,
hgm.hig_dra_tc_armycorps,
hgm.hig_dra_tc_wattchow,
hgm.hig_dra_tc_kirpicha,
hgm.hig_dra_tc_georgeribeiro,
hgm.hig_dra_tc_pasini,
hgm.hig_dra_tc_ventura,
hgm.hig_dra_tc_dnosk1,
hgm.hig_upa_tc_kirpich,
hgm.hig_upa_tc_dooge,
hgm.hig_upa_tc_carter,
hgm.hig_upa_tc_armycorps,
hgm.hig_upa_tc_wattchow,
hgm.hig_upa_tc_kirpicha,
hgm.hig_upa_tc_georgeribeiro,
hgm.hig_upa_tc_pasini,
hgm.hig_upa_tc_ventura,
hgm.hig_upa_tc_dnosk1,
hgm.hig_upn_elevation_avg,
hgm.hig_upn_elevation_max,
hgm.hig_upn_elevation_min,
hgm.hig_upn_length_,
hgm.hig_upn_length_km,
hgm.hig_upn_elevationdrop_m,
hgm.hig_upn_slope_adim,
hgm.hig_upn_slope_maxmin,
hgm.hig_upn_slope_s1585,
hgm.hig_upn_slope_pipf,
hgm.hig_upn_slope_z1585,
hgm.hig_upn_slope_harmonic,
hgm.hig_upn_slope_weighted,
hgm.hig_upn_slope_linreg,
hgm.hig_upn_elevationdrop_maxmin,
hgm.hig_upn_elevationdrop_s1585,
hgm.hig_upn_elevationdrop_pipf,
hgm.hig_upn_elevationdrop_z1585,
hgm.hig_upn_elevationdrop_harmonic,
hgm.hig_upn_elevationdrop_weighted,
hgm.hig_upn_elevationdrop_linreg,
hgm.hig_drn_annual_flow,
hgm.hig_drn_event_flow,
hgm.hig_drn_jobson_tpeak,
hgm.hig_drn_jobson_tlead,
hgm.hig_drn_jobson_tpeak_shortest,
hgm.hig_drn_jobson_tlead_shortest,
hgm.hig_drn_reservoir_depth_m,
hgm.hig_drn_reservoir_length_m,
hgm.hig_drn_reservoir_celwave,
hgm.hig_drn_reservoir_trlwave,
hgm.hig_dra_axislength_schumm,
hgm.hig_dra_shapefactor_schumm,
hgm.hig_dra_formfactor_schumm,
hgm.hig_dra_reliefratio_schumm,
hgm.hig_dra_axislength_ring,
hgm.hig_dra_shapefactor_ring,
hgm.hig_dra_formfactor_ring,
hgm.hig_dra_reliefratio_ring,
hgm.hig_dra_axislength_river,
hgm.hig_dra_shapefactor_river,
hgm.hig_dra_formfactor_river,
hgm.hig_dra_reliefratio_river,
hgm.hig_upa_axislength_schumm,
hgm.hig_upa_shapefactor_schumm,
hgm.hig_upa_formfactor_schumm,
hgm.hig_upa_reliefratio_schumm,
hgm.hig_upa_axislength_ring,
hgm.hig_upa_shapefactor_ring,
hgm.hig_upa_formfactor_ring,
hgm.hig_upa_reliefratio_ring,
hgm.hig_upa_axislength_river,
hgm.hig_upa_shapefactor_river,
hgm.hig_upa_formfactor_river,
hgm.hig_upa_reliefratio_river,
drn.drn_gm
FROM pgh_output_pt_br.geoft_bho_trecho_drenagem drn
INNER JOIN pgh_hgm.pghft_hydro_intel hgm ON (drn.drn_pk = hgm.hig_drn_pk);

DROP TABLE IF EXISTS pgh_output_pt_br.geoft_bhae_area_drenagem_hgm;
CREATE TABLE pgh_output_pt_br.geoft_bhae_area_drenagem_hgm AS
SELECT
dra_pk,
dra.idbacia,
dra.cotrecho,
dra.cocursodag,
dra.cobacia,
dra.nuareacont,
dra.nuordemcda,
dra.nunivotto1,
dra.nunivotto2,
dra.nunivotto3,
dra.nunivotto4,
dra.nunivotto5,
dra.nunivotto6,
dra.nunivotto,
dra.dsversao,
hgm.hig_pk,
hgm.hig_drn_pk,
hgm.hig_dra_pk,
hgm.hig_wtc_pk,
hgm.hig_drn_strahler,
hgm.hig_drn_elevation_avg,
hgm.hig_drn_elevation_max,
hgm.hig_drn_elevation_min,
hgm.hig_drn_elevationdrop_maxmin,
hgm.hig_drn_elevationdrop_s1585,
hgm.hig_drn_elevationdrop_pipf,
hgm.hig_drn_elevationdrop_z1585,
hgm.hig_drn_elevationdrop_harmonic,
hgm.hig_drn_elevationdrop_weighted,
hgm.hig_drn_elevationdrop_linreg,
hgm.hig_drn_slope_maxmin,
hgm.hig_drn_slope_s1585,
hgm.hig_drn_slope_pipf,
hgm.hig_drn_slope_z1585,
hgm.hig_drn_slope_harmonic,
hgm.hig_drn_slope_weighted,
hgm.hig_drn_slope_linreg,
hgm.hig_dra_area_,
hgm.hig_dra_area_km2,
hgm.hig_dra_perimeter_,
hgm.hig_dra_perimeter_km,
hgm.hig_dra_axislength,
hgm.hig_dra_circularity,
hgm.hig_dra_compacity,
hgm.hig_dra_shapefactor,
hgm.hig_dra_formfactor,
hgm.hig_drn_sinuosity,
hgm.hig_dra_reliefratio,
hgm.hig_dra_reachgradient,
hgm.hig_dra_elevation_avg,
hgm.hig_dra_elevation_max,
hgm.hig_dra_elevation_min,
hgm.hig_dra_elevationdrop_m,
hgm.hig_dra_drainagedensity,
hgm.hig_dra_hydrodensity,
hgm.hig_dra_avglengthoverlandflow,
hgm.hig_drn_length_,
hgm.hig_drn_length_km,
hgm.hig_drn_depth_m,
hgm.hig_drn_width_m,
hgm.hig_drn_elevationdrop_m,
hgm.hig_drn_slope_adim,
hgm.hig_drn_manning_n,
hgm.hig_drn_velmann,
hgm.hig_drn_celmann,
hgm.hig_drn_trlmann,
hgm.hig_drn_velmann_lr,
hgm.hig_drn_celmann_lr,
hgm.hig_drn_trlmann_lr,
hgm.hig_drn_celdyna,
hgm.hig_drn_trldyna,
hgm.hig_upa_area_,
hgm.hig_upa_area_km2,
hgm.hig_upa_perimeter_,
hgm.hig_upa_perimeter_km,
hgm.hig_upa_drainagedensity,
hgm.hig_upa_hydrodensity,
hgm.hig_upa_avglengthoverlandflow,
hgm.hig_upa_totaldrainagelength,
hgm.hig_upa_axislength,
hgm.hig_upa_circularity,
hgm.hig_upa_compacity,
hgm.hig_upa_shapefactor,
hgm.hig_upa_formfactor,
hgm.hig_upn_sinuosity,
hgm.hig_upa_elevation_avg,
hgm.hig_upa_elevation_max,
hgm.hig_upa_elevation_min,
hgm.hig_upa_elevationdrop_m,
hgm.hig_upa_reliefratio,
hgm.hig_upa_reachgradient,
hgm.hig_dra_tc_kirpich,
hgm.hig_dra_tc_dooge,
hgm.hig_dra_tc_carter,
hgm.hig_dra_tc_armycorps,
hgm.hig_dra_tc_wattchow,
hgm.hig_dra_tc_kirpicha,
hgm.hig_dra_tc_georgeribeiro,
hgm.hig_dra_tc_pasini,
hgm.hig_dra_tc_ventura,
hgm.hig_dra_tc_dnosk1,
hgm.hig_upa_tc_kirpich,
hgm.hig_upa_tc_dooge,
hgm.hig_upa_tc_carter,
hgm.hig_upa_tc_armycorps,
hgm.hig_upa_tc_wattchow,
hgm.hig_upa_tc_kirpicha,
hgm.hig_upa_tc_georgeribeiro,
hgm.hig_upa_tc_pasini,
hgm.hig_upa_tc_ventura,
hgm.hig_upa_tc_dnosk1,
hgm.hig_upn_elevation_avg,
hgm.hig_upn_elevation_max,
hgm.hig_upn_elevation_min,
hgm.hig_upn_length_,
hgm.hig_upn_length_km,
hgm.hig_upn_elevationdrop_m,
hgm.hig_upn_slope_adim,
hgm.hig_upn_slope_maxmin,
hgm.hig_upn_slope_s1585,
hgm.hig_upn_slope_pipf,
hgm.hig_upn_slope_z1585,
hgm.hig_upn_slope_harmonic,
hgm.hig_upn_slope_weighted,
hgm.hig_upn_slope_linreg,
hgm.hig_upn_elevationdrop_maxmin,
hgm.hig_upn_elevationdrop_s1585,
hgm.hig_upn_elevationdrop_pipf,
hgm.hig_upn_elevationdrop_z1585,
hgm.hig_upn_elevationdrop_harmonic,
hgm.hig_upn_elevationdrop_weighted,
hgm.hig_upn_elevationdrop_linreg,
hgm.hig_drn_annual_flow,
hgm.hig_drn_event_flow,
hgm.hig_drn_jobson_tpeak,
hgm.hig_drn_jobson_tlead,
hgm.hig_drn_jobson_tpeak_shortest,
hgm.hig_drn_jobson_tlead_shortest,
hgm.hig_drn_reservoir_depth_m,
hgm.hig_drn_reservoir_length_m,
hgm.hig_drn_reservoir_celwave,
hgm.hig_drn_reservoir_trlwave,
hgm.hig_dra_axislength_schumm,
hgm.hig_dra_shapefactor_schumm,
hgm.hig_dra_formfactor_schumm,
hgm.hig_dra_reliefratio_schumm,
hgm.hig_dra_axislength_ring,
hgm.hig_dra_shapefactor_ring,
hgm.hig_dra_formfactor_ring,
hgm.hig_dra_reliefratio_ring,
hgm.hig_dra_axislength_river,
hgm.hig_dra_shapefactor_river,
hgm.hig_dra_formfactor_river,
hgm.hig_dra_reliefratio_river,
hgm.hig_upa_axislength_schumm,
hgm.hig_upa_shapefactor_schumm,
hgm.hig_upa_formfactor_schumm,
hgm.hig_upa_reliefratio_schumm,
hgm.hig_upa_axislength_ring,
hgm.hig_upa_shapefactor_ring,
hgm.hig_upa_formfactor_ring,
hgm.hig_upa_reliefratio_ring,
hgm.hig_upa_axislength_river,
hgm.hig_upa_shapefactor_river,
hgm.hig_upa_formfactor_river,
hgm.hig_upa_reliefratio_river,
dra.dra_gm
FROM pgh_output_pt_br.geoft_bho_area_drenagem dra
LEFT JOIN pgh_hgm.pghft_hydro_intel hgm ON (dra.dra_pk = hgm.hig_dra_pk);