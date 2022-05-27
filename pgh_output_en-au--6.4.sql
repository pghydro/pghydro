--pgh_output.drainage_line;

DROP TABLE IF EXISTS pgh_output.drainage_line;

CREATE TABLE pgh_output.drainage_line AS
(
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
FULL OUTER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_drn_pk = drn.drn_pk
);

--TABLE pgh_output.drainage_area;

DROP TABLE IF EXISTS pgh_output.drainage_area;

CREATE TABLE pgh_output.drainage_area AS
(
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
WHERE hin.hin_drn_pk is null
);

--TABLE pgh_output.geoft_bho_ponto_drenagem

DROP TABLE IF EXISTS pgh_output.drainage_point;

CREATE TABLE pgh_output.drainage_point AS
(
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
AND wtc.wtc_cd_pfafstetterwatercourse is null
);
