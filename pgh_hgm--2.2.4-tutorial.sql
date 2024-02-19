
TRAVA


-- MOSTRA ALGUMAS COISAS
--SELECT * FROM pgh_hgm.pghft_hydro_intel;
--SELECT * FROM pgh_hgm.pghft_drn_elevationprofile;
--SELECT * FROM pgh_hgm.pghft_upn_elevationprofile;


-- TRUNCATE ELEVATION PROFILES
--SELECT pgh_hgm.pghfn_utils_tmp_elevprof_truncate('drn');
--SELECT pgh_hgm.pghfn_utils_tmp_elevprof_truncate('upn');

-- EXPORTA RESULTADOS PARA 'geoft_bho_hgm'
--SELECT pgh_hgm.pghfn_utils_export_output()

------------------------------------------------------------------
-- CONFIGURAR BANCO DE DADOS
-- 0. conectar banco com schema pghydro
-- 1. carregar extensao pgh_raster -> carregar pghrt_elevation
-- 2. carregar extensao pgh_hgm
------------------------------------------------------------------

------------------------------------------------------------------
-- INICIALIZA A TABELA DO PGH-HGM -> atualiza com dados do pghydro
-------------------------------------------------------------------
SELECT pgh_hgm.pghfn_tables_initialize();


------------------------------------------------------------
-- ESCALA LOCAL:  TRECHO (DRN) E BACIA (DRA)
------------------------------------------------------------
-- pre-processamento
SELECT pgh_hgm.pghfn_prepro_calculate();

-- declividades dos trechos
SELECT pgh_hgm.pghfn_calculate_drn_slope_harmonic(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_linreg(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_maxmin(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_pipf(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_s1585(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_weighted(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_slope_z1585(55555, 5880);

-- estatisticas do perfil de elevacao do trecho e elevation-drop
SELECT pgh_hgm.pghfn_calculate_drn_elevationprofile_stats(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_elevationprofiledrop_from_slopes(55555, 5880);

-- atributos do trecho
SELECT pgh_hgm.pghfn_calculate_drn_sinuosity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_amhg_depth_width(55555, 5880); -- profundidade e largura

-- atributos de bacia
SELECT pgh_hgm.pghfn_calculate_dra_avglengthoverlandflow(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_axislength(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_circularity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_compacity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_drainagedensity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_formfactor(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_hydrodensity(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_perimeter(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_shapefactor(55555, 5880);


-- estatisticas de MDE da bacia
SELECT pgh_hgm.pghfn_calculate_dra_elevations_stats(55555, 5880);  -- a operacao mais pesada!

-- atributos com dependencia
SELECT pgh_hgm.pghfn_calculate_dra_reachgradient(55555, 5880); -- utiliza hig_drn_slope_maxmin
SELECT pgh_hgm.pghfn_calculate_dra_reliefratio(55555, 5880);  -- utiliza hig_dra_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_dra_bonus_ring(55555, 5880);  -- utiliza hig_dra_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_dra_bonus_river(55555, 5880);  -- utiliza hig_dra_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_dra_bonus_schumm(55555, 5880);  -- utiliza hig_dra_elevationdrop_m


--> Daqui pra baixo tambem ha dependencias
--> no geral, areas, declividades, larguras, profundidades, etc.

-- modelo de jobson
SELECT pgh_hgm.pghfn_calculate_drn_jobson_initialize(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_drn_jobson_traveltime(55555, 5880);

-- celeridades, velocidades, etc.
SELECT pgh_hgm.pghfn_calculate_drn_wavetravel(55555, 5880);

-- tempos de concentracao
SELECT pgh_hgm.pghfn_calculate_dra_timeofconcentration(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_dra_kirpicha(55555, 5880);




------------------------------------------------------------
-- ESCALA DE MONTANTE:  TRECHO (UPN) E BACIA (UPA)
------------------------------------------------------------
-- pre-processamento
SELECT pgh_hgm.pghfn_prepro_calculate_upa(55555, 5880);


--- declividades do rio principal a montante
SELECT pgh_hgm.pghfn_calculate_upn_slope_harmonic(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upn_slope_linreg(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_maxmin(55555, 5880); 
SELECT pgh_hgm.pghfn_calculate_upn_slope_pipf(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_s1585(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_weighted(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_slope_z1585(55555, 5880);

-- estatisticas do perfil de elevacao do rio a montante e elevation-drop
SELECT pgh_hgm.pghfn_calculate_upn_elevationprofile_stats(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upn_elevationprofiledrop_from_slopes(55555, 5880); --utiliza hig_upn_slope_xxxx




-- atributos do rio principal a montante
SELECT pgh_hgm.pghfn_calculate_upn_sinuosity(55555, 5880); 

-- atributos da bacia a montante
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


-- estatisticas do MDE a montante
--SELECT pgh_hgm.pghfn_calculate_upa_elevations_stats(55555, 5880); -- a operacao mais pesada!
SELECT pgh_hgm.pghfn_calculate_upa_elevations_stats_agg(); -- pelo metodo da agregacao


-- atributos com dependencia
SELECT pgh_hgm.pghfn_calculate_upa_reachgradient(55555, 5880); -- utiiza de hig_upn_slope_maxmin
SELECT pgh_hgm.pghfn_calculate_upa_reliefratio(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_bonus_ring(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_bonus_river(55555, 5880);  -- utiliza hig_upa_elevationdrop_m
SELECT pgh_hgm.pghfn_calculate_upa_bonus_schumm(55555, 5880);  -- utiliza hig_upa_elevationdrop_m

--> Daqui pra baixo ha dependencias
SELECT pgh_hgm.pghfn_calculate_upa_timeofconcentration(55555, 5880);
SELECT pgh_hgm.pghfn_calculate_upa_kirpicha(55555, 5880);


--> Copia os atributos de cabeceiras para upn/upa
SELECT pgh_hgm.pghfn_postpro_updateheadwaters()


/*
SELECT
hig_upa_elevation_max,hig_upa_elevation_min,hig_upa_elevation_avg,hig_upa_elevationdrop_m,
hig_upa_reachgradient,
hig_upa_reliefratio_ring,
hig_upa_axislength_schumm,
hig_upa_tc_kirpich
FROM pgh_hgm.pghft_hydro_intel;
*/