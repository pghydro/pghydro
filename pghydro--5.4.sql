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
--PosgreSQL: postgresql-9.3.5-3-windows-x64.exe
--postgis-bundle-pg93x64-setup-2.1.4-1.exe
---------------------------------------------------------------------------------
--pghYDRO Database Scheme version 5.4 of 10/03/2016
---------------------------------------------------------------------------------
--------
--SCHEMA
--------
--REPLACE pghydro. -> schema.
--REPLACE 'pghydro' -> 'schema'

-----------------------------
--CREATE TABLES AND SEQUENCES
-----------------------------
--BEGIN;

DROP SCHEMA IF EXISTS pghydro CASCADE;

CREATE SCHEMA pghydro;

CREATE TABLE pghydro.pghft_shoreline (
    sho_pk integer,
    sho_gm_length numeric,
    sho_bo_flowdirection boolean,
    sho_nm character varying
);


CREATE SEQUENCE pghydro.sho_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.sho_pk_seq OWNED BY pghydro.pghft_shoreline.sho_pk;


SELECT pg_catalog.setval('pghydro.sho_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_domain (
    tdm_pk integer,
    tdm_ds character varying
);


CREATE SEQUENCE pghydro.tdm_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tdm_pk_seq OWNED BY pghydro.pghtb_type_domain.tdm_pk;


SELECT pg_catalog.setval('pghydro.tdm_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_reservoir (
    trs_pk integer,
    trs_ds character varying
);


CREATE SEQUENCE pghydro.trs_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.trs_pk_seq OWNED BY pghydro.pghtb_type_reservoir.trs_pk;


SELECT pg_catalog.setval('pghydro.trs_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_water_mass (
    twm_pk integer,
    twm_ds character varying
);


CREATE SEQUENCE pghydro.twm_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.twm_pk_seq OWNED BY pghydro.pghtb_type_water_mass.twm_pk;


SELECT pg_catalog.setval('pghydro.twm_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_dam (
dam_pk integer,
dam_nm character varying,
dam_nm_alternative character varying,
dam_drn_pk integer,
dam_rcl_pk_drn integer,
dam_wtm_pk integer,
dam_rcl_pk_wtm integer,
dam_nu_flow_out numeric,
dam_tof_pk_flow_out integer,
dam_snb_pk integer
);


CREATE SEQUENCE pghydro.dam_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pghydro.dam_pk_seq OWNED BY pghydro.pghft_dam.dam_pk;

SELECT pg_catalog.setval('pghydro.dam_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_drn_wtm(
	pdw_pk integer,
	pdw_drn_pk integer,
	pdw_wtm_pk integer
);

CREATE SEQUENCE pghydro.pdw_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pghydro.pdw_pk_seq OWNED BY pghydro.pghtb_drn_wtm.pdw_pk;

SELECT pg_catalog.setval('pghydro.pdw_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_flow (
    tof_pk integer,
    tof_ds character varying
);


CREATE SEQUENCE pghydro.tof_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tof_pk_seq OWNED BY pghydro.pghtb_type_flow.tof_pk;


SELECT pg_catalog.setval('pghydro.tof_pk_seq', 1, false);


--


CREATE TABLE pghydro.pghtb_type_water_mass_operation (
    top_pk integer,
    top_ds character varying
);


CREATE SEQUENCE pghydro.top_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.top_pk_seq OWNED BY pghydro.pghtb_type_water_mass_operation.top_pk;


SELECT pg_catalog.setval('pghydro.top_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_hydro_intel(
	hin_pk integer,
	hin_drn_pk integer,
	hin_dra_pk integer,
	hin_count_drn_pk integer,
	hin_count_dra_pk integer,
	hin_strahler integer
);

CREATE SEQUENCE pghydro.hin_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pghydro.hin_pk_seq OWNED BY pghydro.pghft_hydro_intel.hin_pk;

SELECT pg_catalog.setval('pghydro.hin_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_drainage_point (
    drp_pk integer,
    drp_nu_valence smallint
);


CREATE SEQUENCE pghydro.drp_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.drp_pk_seq OWNED BY pghydro.pghft_drainage_point.drp_pk;


SELECT pg_catalog.setval('pghydro.drp_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_drainage_line (
    drn_pk integer,
    drn_drp_pk_sourcenode integer,
    drn_rcl_pk_drp_sourcenode integer,
    drn_drp_pk_targetnode integer,
    drn_rcl_pk_drp_targetnode integer,
    drn_drn_pk_upstreamdrainageline integer,
    drn_drn_pk_downstreamdrainageline integer,
    drn_nu_distancetosea numeric,
    drn_nu_distancetowatercourse numeric,
    drn_bo_flowdirection boolean,
    drn_nm character varying,
    drn_gm_length numeric,
    drn_dra_pk integer,
    drn_rcl_pk_dra integer,
    drn_nu_upstreamarea numeric,
    drn_wtc_pk integer,
    drn_rcl_pk_wtc integer,
    drn_wmb_pk integer,
    drn_rcl_pk_wmb integer,
    drn_hdr_pk integer,
    drn_rcl_pk_hdr integer,
    drn_tdm_pk integer
);


CREATE SEQUENCE pghydro.drn_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.drn_pk_seq OWNED BY pghydro.pghft_drainage_line.drn_pk;


SELECT pg_catalog.setval('pghydro.drn_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_monitoring_point (
    mnp_pk integer,
    mnp_drn_pk integer,
    mnp_rcl_pk_drn integer,
    mnp_wtm_pk integer,
    mnp_rcl_pk_wtm integer
);


CREATE SEQUENCE pghydro.mnp_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.mnp_pk_seq OWNED BY pghydro.pghft_monitoring_point.mnp_pk;


SELECT pg_catalog.setval('pghydro.mnp_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_drainage_area (
    dra_pk integer,
    dra_cd_pfafstetterbasin character varying,
    dra_nu_pfafstetterbasincodelevel smallint,
    dra_gm_area numeric
);


CREATE SEQUENCE pghydro.dra_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.dra_pk_seq OWNED BY pghydro.pghft_drainage_area.dra_pk;


SELECT pg_catalog.setval('pghydro.dra_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_hydronym (
    hdr_pk integer,
    hdr_cd character varying,
    hdr_tnc_pk integer,
    hdr_nu_distancetosea numeric,
    hdr_gm_area numeric,
    hdr_gm_length numeric
);


CREATE SEQUENCE pghydro.hdr_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.hdr_pk_seq OWNED BY pghydro.pghft_hydronym.hdr_pk;


SELECT pg_catalog.setval('pghydro.hdr_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_shoreline_ending_point (
    sep_pk integer,
    sep_drp_pk integer,
    sep_rcl_pk_drp integer,
    sep_drn_pk integer,
    sep_rcl_pk_drn integer,
    sep_sho_pk integer,
    sep_rcl_pk_sho integer
);


CREATE SEQUENCE pghydro.sep_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.sep_pk_seq OWNED BY pghydro.pghft_shoreline_ending_point.sep_pk;


SELECT pg_catalog.setval('pghydro.sep_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_shoreline_starting_point (
    ssp_pk integer,
    ssp_drp_pk integer,
    ssp_rcl_pk_drp integer,
    ssp_drn_pk integer,
    ssp_rcl_pk_drn integer,
    ssp_sho_pk integer,
    ssp_rcl_pk_sho integer
);


CREATE SEQUENCE pghydro.ssp_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.ssp_pk_seq OWNED BY pghydro.pghft_shoreline_starting_point.ssp_pk;


SELECT pg_catalog.setval('pghydro.ssp_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_stream_mouth (
    stm_pk integer,
    stm_drp_pk integer,
    stm_rcl_pk_drp integer,
    stm_wtc_pk integer,
    stm_rcl_pk_wtc integer
);


CREATE SEQUENCE pghydro.stm_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.stm_pk_seq OWNED BY pghydro.pghft_stream_mouth.stm_pk;


SELECT pg_catalog.setval('pghydro.stm_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_water_mass (
    wtm_pk integer,
    wtm_nm character varying,
    wtm_nm_alternative character varying,
    wtm_ds_owner character varying,
    wtm_ds_domain character varying,
    wtm_ds_source character varying,
    wtm_ds_remote_sensing character varying,
    wtm_ds_flow_source character varying,
    wtm_ds_surveillance character varying,
    wtm_ds_observation character varying,
    wtm_top_pk integer,
    wtm_twm_pk integer,
    wtm_trs_pk integer,
    wtm_tdm_pk integer,
    wtm_tof_pk_flow_regulated integer,
    --wtm_tof_pk_flow_out integer,
    wtm_tof_pk_flow_backwater integer,
    wtm_nu_flow_regulated numeric,
    --wtm_nu_flow_out numeric,
    wtm_nu_flow_backwater numeric,
    wtm_gm_perimeter numeric,
    wtm_gm_area numeric,
    wtm_gm_area_m2 numeric,
    wtm_gm_area_ha numeric,
    wtm_gm_volume numeric,
    wtm_esp_cd integer
);

CREATE SEQUENCE pghydro.wtm_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wtm_pk_seq OWNED BY pghydro.pghft_water_mass.wtm_pk;


SELECT pg_catalog.setval('pghydro.wtm_pk_seq', 1, false);


CREATE SEQUENCE pghydro.wtm_esp_cd_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wtm_esp_cd_seq OWNED BY pghydro.pghft_water_mass.wtm_esp_cd;


SELECT pg_catalog.setval('pghydro.wtm_esp_cd_seq', 1, false);

--

CREATE TABLE pghydro.pghft_water_mass_boundary (
    wmb_pk integer,
    wmb_wtm_pk integer,
    wmb_rcl_pk_wtm integer,
    wmb_gm_length numeric
);


CREATE SEQUENCE pghydro.wmb_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wmb_pk_seq OWNED BY pghydro.pghft_water_mass_boundary.wmb_pk;


SELECT pg_catalog.setval('pghydro.wmb_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_watercourse (
    wtc_pk integer,
    wtc_nu_distancetosea numeric,
    wtc_cd_pfafstetterwatercourse_downstream character varying,
    wtc_cd_pfafstetterwatercourse character varying,
    wtc_nu_pfafstetterwatercoursecodelevel smallint,
    wtc_nu_pfafstetterwatercoursecodeorder smallint,
    wtc_gm_area numeric,
    wtc_gm_length numeric,
    wtc_tdm_pk integer
);

CREATE SEQUENCE pghydro.wtc_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wtc_pk_seq OWNED BY pghydro.pghft_watercourse.wtc_pk;


SELECT pg_catalog.setval('pghydro.wtc_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_watercourse_starting_point (
    wsp_pk integer,
    wsp_drp_pk integer,
    wsp_rcl_pk_drp integer,
    wsp_wtc_pk integer,
    wsp_rcl_pk_wtc integer
);


CREATE SEQUENCE pghydro.wsp_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wsp_pk_seq OWNED BY pghydro.pghft_watercourse_starting_point.wsp_pk;


SELECT pg_catalog.setval('pghydro.wsp_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_watercourse_ending_point (
    wep_pk integer,
    wep_drp_pk integer,
    wep_rcl_pk_drp integer,
    wep_wtc_pk integer,
    wep_rcl_pk_wtc integer
);

CREATE SEQUENCE pghydro.wep_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wep_pk_seq OWNED BY pghydro.pghft_watercourse_ending_point.wep_pk;


SELECT pg_catalog.setval('pghydro.wep_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghft_watershed (
    wts_pk integer,
    wts_cd_pfafstetterbasin character varying,
    wts_cd_pfafstetterbasincodelevel smallint,
    wts_gm_area numeric
);


CREATE SEQUENCE pghydro.wts_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.wts_pk_seq OWNED BY pghydro.pghft_watershed.wts_pk;


SELECT pg_catalog.setval('pghydro.wts_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_de9im (
    dim_pk integer,
    dim_ds character varying(9)
);


CREATE SEQUENCE pghydro.dim_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.dim_pk_seq OWNED BY pghydro.pghtb_type_de9im.dim_pk;


SELECT pg_catalog.setval('pghydro.dim_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_geometry (
    tgm_pk integer,
    tgm_ds character varying
);


CREATE SEQUENCE pghydro.tgm_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tgm_pk_seq OWNED BY pghydro.pghtb_type_geometry.tgm_pk;


SELECT pg_catalog.setval('pghydro.tgm_pk_seq', 8, true);

--

CREATE TABLE pghydro.pghtb_type_name_complete (
    tnc_pk integer,
    tnc_ds character varying,
    tnc_tng_pk integer,
    tnc_tcn_pk integer,
    tnc_tns_pk integer
);


CREATE SEQUENCE pghydro.tnc_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tnc_pk_seq OWNED BY pghydro.pghtb_type_name_complete.tnc_pk;


SELECT pg_catalog.setval('pghydro.tnc_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_name_connection (
    tcn_pk integer,
    tcn_ds character varying
);


CREATE SEQUENCE pghydro.tcn_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tcn_pk_seq OWNED BY pghydro.pghtb_type_name_connection.tcn_pk;


SELECT pg_catalog.setval('pghydro.tcn_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_name_generic (
    tng_pk integer,
    tng_ds character varying
);


CREATE SEQUENCE pghydro.tng_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tng_pk_seq OWNED BY pghydro.pghtb_type_name_generic.tng_pk;


SELECT pg_catalog.setval('pghydro.tng_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_name_specific (
    tns_pk integer,
    tns_ds character varying
);


CREATE SEQUENCE pghydro.tns_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tns_pk_seq OWNED BY pghydro.pghtb_type_name_specific.tns_pk;


SELECT pg_catalog.setval('pghydro.tns_pk_seq', 1, false);

--

CREATE TABLE pghydro.pghtb_type_relationship_class (
    rcl_pk integer,
    rcl_tgm_pk_class_a integer,
    rcl_tgm_ds_class_a character varying,
    rcl_tgm_pk_class_b integer,
    rcl_tgm_ds_class_b character varying,
    rcl_tpr_pk integer,
    rcl_tpr_ds character varying,
    rcl_dim_pk integer,
    rcl_dim_ds character varying
);


CREATE SEQUENCE pghydro.rcl_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.rcl_pk_seq OWNED BY pghydro.pghtb_type_relationship_class.rcl_pk;



SELECT pg_catalog.setval('pghydro.rcl_pk_seq', 14, true);

--

CREATE TABLE pghydro.pghtb_type_topology_relationship (
    tpr_pk integer,
    tpr_ds character varying
);


CREATE SEQUENCE pghydro.tpr_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.tpr_pk_seq OWNED BY pghydro.pghtb_type_topology_relationship.tpr_pk;


SELECT pg_catalog.setval('pghydro.tpr_pk_seq', 5, true);

--

CREATE TABLE pghydro.pghtb_pghydro_version
(
vrs_pk integer,
vrs_pghydroschema character varying,
vrs_pghydrotools character varying,
vrs_date date
);

CREATE SEQUENCE pghydro.vrs_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pghydro.vrs_pk_seq OWNED BY pghydro.pghtb_pghydro_version.vrs_pk;


SELECT pg_catalog.setval('pghydro.vrs_pk_seq', 1, true);

--

ALTER TABLE pghydro.pghft_shoreline ALTER COLUMN sho_pk SET DEFAULT nextval('pghydro.sho_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_dam ALTER COLUMN dam_pk SET DEFAULT nextval('pghydro.dam_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_drn_wtm ALTER COLUMN pdw_pk SET DEFAULT nextval('pghydro.pdw_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_water_mass ALTER COLUMN twm_pk SET DEFAULT nextval('pghydro.twm_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_reservoir ALTER COLUMN trs_pk SET DEFAULT nextval('pghydro.trs_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_domain ALTER COLUMN tdm_pk SET DEFAULT nextval('pghydro.tdm_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_water_mass_operation ALTER COLUMN top_pk SET DEFAULT nextval('pghydro.top_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_flow ALTER COLUMN tof_pk SET DEFAULT nextval('pghydro.tof_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_hydro_intel ALTER COLUMN hin_pk SET DEFAULT nextval('pghydro.hin_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_drainage_point ALTER COLUMN drp_pk SET DEFAULT nextval('pghydro.drp_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_drainage_line ALTER COLUMN drn_pk SET DEFAULT nextval('pghydro.drn_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_monitoring_point ALTER COLUMN mnp_pk SET DEFAULT nextval('pghydro.mnp_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_drainage_area ALTER COLUMN dra_pk SET DEFAULT nextval('pghydro.dra_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_hydronym ALTER COLUMN hdr_pk SET DEFAULT nextval('pghydro.hdr_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_shoreline_ending_point ALTER COLUMN sep_pk SET DEFAULT nextval('pghydro.sep_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_shoreline_starting_point ALTER COLUMN ssp_pk SET DEFAULT nextval('pghydro.ssp_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_stream_mouth ALTER COLUMN stm_pk SET DEFAULT nextval('pghydro.stm_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_water_mass ALTER COLUMN wtm_pk SET DEFAULT nextval('pghydro.wtm_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_water_mass_boundary ALTER COLUMN wmb_pk SET DEFAULT nextval('pghydro.wmb_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_watercourse ALTER COLUMN wtc_pk SET DEFAULT nextval('pghydro.wtc_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_watercourse_starting_point ALTER COLUMN wsp_pk SET DEFAULT nextval('pghydro.wsp_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_watercourse_ending_point ALTER COLUMN wep_pk SET DEFAULT nextval('pghydro.wep_pk_seq'::regclass);


ALTER TABLE pghydro.pghft_watershed ALTER COLUMN wts_pk SET DEFAULT nextval('pghydro.wts_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_de9im ALTER COLUMN dim_pk SET DEFAULT nextval('pghydro.dim_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_geometry ALTER COLUMN tgm_pk SET DEFAULT nextval('pghydro.tgm_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_name_complete ALTER COLUMN tnc_pk SET DEFAULT nextval('pghydro.tnc_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_name_connection ALTER COLUMN tcn_pk SET DEFAULT nextval('pghydro.tcn_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_name_generic ALTER COLUMN tng_pk SET DEFAULT nextval('pghydro.tng_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_name_specific ALTER COLUMN tns_pk SET DEFAULT nextval('pghydro.tns_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_relationship_class ALTER COLUMN rcl_pk SET DEFAULT nextval('pghydro.rcl_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_type_topology_relationship ALTER COLUMN tpr_pk SET DEFAULT nextval('pghydro.tpr_pk_seq'::regclass);


ALTER TABLE pghydro.pghtb_pghydro_version ALTER COLUMN vrs_pk SET DEFAULT nextval('pghydro.vrs_pk_seq'::regclass);

-----------------------------
--INSERT DATA
-----------------------------

DELETE FROM pghydro.pghtb_type_geometry;

INSERT INTO pghydro.pghtb_type_geometry VALUES (1, 'POINT');
INSERT INTO pghydro.pghtb_type_geometry VALUES (2, 'LINESTRING');
INSERT INTO pghydro.pghtb_type_geometry VALUES (3, 'POLYGON');
INSERT INTO pghydro.pghtb_type_geometry VALUES (4, 'MULTIPOINT');
INSERT INTO pghydro.pghtb_type_geometry VALUES (5, 'MULTILINESTRING');
INSERT INTO pghydro.pghtb_type_geometry VALUES (6, 'MULTIPOLYGON');
INSERT INTO pghydro.pghtb_type_geometry VALUES (7, 'GEOMETRY');
INSERT INTO pghydro.pghtb_type_geometry VALUES (8, 'GEOMETRYCOLLECTION');

DELETE FROM pghydro.pghtb_type_relationship_class;

INSERT INTO pghydro.pghtb_type_relationship_class VALUES (1, 1, 'POINT', 1, 'POINT', 5, 'DISJOINT', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (15, 1, 'POINT', 2, 'LINESTRING', 2, 'TOUCH', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (16, 1, 'POINT', 3, 'POLYGON', 2, 'TOUCH', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (21, 3, 'POLYGON', 3, 'POLYGON', 3, 'OVERLAP', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (20, 2, 'LINESTRING', 2, 'LINESTRING', 3, 'OVERLAP', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (19, 3, 'POLYGON', 3, 'POLYGON', 2, 'TOUCH', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (18, 2, 'LINESTRING', 2, 'LINESTRING', 2, 'TOUCH', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (17, 2, 'LINESTRING', 3, 'POLYGON', 2, 'TOUCH', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (2, 1, 'POINT', 2, 'LINESTRING', 5, 'DISJOINT', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (3, 1, 'POINT', 3, 'POLYGON', 5, 'DISJOINT', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (4, 2, 'LINESTRING', 3, 'POLYGON', 5, 'DISJOINT', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (5, 2, 'LINESTRING', 2, 'LINESTRING', 5, 'DISJOINT', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (6, 3, 'POLYGON', 3, 'POLYGON', 5, 'DISJOINT', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (7, 2, 'LINESTRING', 3, 'POLYGON', 4, 'CROSS', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (8, 2, 'LINESTRING', 2, 'LINESTRING', 4, 'CROSS', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (9, 1, 'POINT', 1, 'POINT', 1, 'IN', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (10, 1, 'POINT', 2, 'LINESTRING', 1, 'IN', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (11, 1, 'POINT', 3, 'POLYGON', 1, 'IN', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (12, 2, 'LINESTRING', 3, 'POLYGON', 1, 'IN', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (13, 2, 'LINESTRING', 2, 'LINESTRING', 1, 'IN', NULL, NULL);
INSERT INTO pghydro.pghtb_type_relationship_class VALUES (14, 3, 'POLYGON', 3, 'POLYGON', 1, 'IN', NULL, NULL);

DELETE FROM pghydro.pghtb_type_topology_relationship;

INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (1, 'IN');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (2, 'TOUCH');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (3, 'OVERLAP');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (4, 'CROSS');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (5, 'DISJOINT');

DELETE FROM pghydro.pghtb_pghydro_version;

INSERT INTO pghydro.pghtb_pghydro_version (vrs_pk, vrs_pghydroschema, vrs_pghydrotools, vrs_date)
SELECT 1, 'pghydro_schema_05_04', 'pghydro_Tools_05_04', CURRENT_DATE;

DELETE FROM pghydro.pghtb_type_flow;

INSERT INTO pghydro.pghtb_type_flow VALUES (1, 'Q95');

DELETE FROM pghydro.pghtb_type_domain;

INSERT INTO pghydro.pghtb_type_domain VALUES (0, 'Estadual');
INSERT INTO pghydro.pghtb_type_domain VALUES (1, 'Federal');
INSERT INTO pghydro.pghtb_type_domain VALUES (2, 'Internacional');
INSERT INTO pghydro.pghtb_type_domain VALUES (3, 'Linha de Costa');

-----------------------------
--CREATE GEOMETRY COLUMNS
-----------------------------

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_shoreline', 'sho_gm', 0, 'MULTILINESTRING', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_hydro_intel', 'hin_gm_point', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_hydro_intel', 'hin_gm_line', 0, 'MULTILINESTRING', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_hydro_intel', 'hin_gm_polygon', 0, 'MULTIPOLYGON', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_dam', 'dam_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_dam', 'dam_gm_original', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_drainage_point', 'drp_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_drainage_line', 'drn_gm', 0, 'MULTILINESTRING', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_monitoring_point', 'mnp_gm', 0, 'MULTIPOINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_monitoring_point', 'mnp_gm_original', 0, 'MULTIPOINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_drainage_area', 'dra_gm', 0, 'MULTIPOLYGON', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_hydronym', 'hdr_gm', 0, 'MULTILINESTRING', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_shoreline_ending_point', 'sep_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_shoreline_starting_point', 'ssp_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_stream_mouth', 'stm_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_water_mass', 'wtm_gm', 0, 'MULTIPOLYGON', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_water_mass', 'wtm_gm_point', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_water_mass_boundary', 'wmb_gm', 0, 'MULTILINESTRING', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_watercourse', 'wtc_gm', 0, 'MULTILINESTRING', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_watercourse_starting_point', 'wsp_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_watercourse_ending_point', 'wep_gm', 0, 'POINT', 2);
--COMMIT;

--BEGIN;
SELECT addgeometrycolumn ('pghydro', 'pghft_watershed', 'wts_gm', 0, 'MULTIPOLYGON', 2);
--COMMIT;

---------------------------------------------------------------------------------------------------
--pghYDRO FUNCTIONS
---------------------------------------------------------------------------------------------------
----------------------------------------------------
--FUNCTION pghydro.pghfn_DropPrimaryKeys()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropPrimaryKeys()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

ALTER TABLE ONLY pghydro.pghft_shoreline
    DROP CONSTRAINT IF EXISTS sho_pk_pkey;

ALTER TABLE ONLY pghydro.pghft_dam
    DROP CONSTRAINT IF EXISTS dam_pk_pkey;

ALTER TABLE ONLY pghydro.pghtb_drn_wtm
    DROP CONSTRAINT IF EXISTS pdw_pk_pkey;

ALTER TABLE ONLY pghydro.pghft_hydro_intel
    DROP CONSTRAINT IF EXISTS hin_pk_pkey;

ALTER TABLE ONLY pghydro.pghtb_type_water_mass_operation
    DROP CONSTRAINT IF EXISTS top_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_reservoir
    DROP CONSTRAINT IF EXISTS trs_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_domain
    DROP CONSTRAINT IF EXISTS tdm_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_water_mass
    DROP CONSTRAINT IF EXISTS twm_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_flow
    DROP CONSTRAINT IF EXISTS tof_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_point
    DROP CONSTRAINT IF EXISTS drp_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    DROP CONSTRAINT IF EXISTS mnp_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_area
    DROP CONSTRAINT IF EXISTS dra_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_hydronym
    DROP CONSTRAINT IF EXISTS hdr_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    DROP CONSTRAINT IF EXISTS sep_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    DROP CONSTRAINT IF EXISTS ssp_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    DROP CONSTRAINT IF EXISTS stm_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass_boundary
    DROP CONSTRAINT IF EXISTS wmb_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse
    DROP CONSTRAINT IF EXISTS wtc_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    DROP CONSTRAINT IF EXISTS wsp_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    DROP CONSTRAINT IF EXISTS wep_pk_pkey ;

ALTER TABLE ONLY pghydro.pghft_watershed
    DROP CONSTRAINT IF EXISTS wts_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_de9im
    DROP CONSTRAINT IF EXISTS dim_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_geometry
    DROP CONSTRAINT IF EXISTS tgm_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    DROP CONSTRAINT IF EXISTS tnc_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_connection
    DROP CONSTRAINT IF EXISTS tcn_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_generic
    DROP CONSTRAINT IF EXISTS tng_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_specific
    DROP CONSTRAINT IF EXISTS tns_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    DROP CONSTRAINT IF EXISTS rcl_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_type_topology_relationship
    DROP CONSTRAINT IF EXISTS tpr_pk_pkey ;

ALTER TABLE ONLY pghydro.pghtb_pghydro_version
    DROP CONSTRAINT IF EXISTS vrs_pk_pkey ;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-----------------------------------------
--FUNCTION pghydro.pghfn_AddPrimaryKeys()
-----------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_AddPrimaryKeys()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropPrimaryKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

ALTER TABLE ONLY pghydro.pghft_shoreline
    ADD CONSTRAINT sho_pk_pkey PRIMARY KEY (sho_pk);

ALTER TABLE ONLY pghydro.pghft_dam
    ADD CONSTRAINT dam_pk_pkey PRIMARY KEY (dam_pk);

ALTER TABLE ONLY pghydro.pghtb_drn_wtm
    ADD CONSTRAINT pdw_pk_pkey PRIMARY KEY (pdw_pk);

ALTER TABLE ONLY pghydro.pghtb_type_reservoir
    ADD CONSTRAINT trs_pk_pkey PRIMARY KEY (trs_pk);

ALTER TABLE ONLY pghydro.pghtb_type_domain
    ADD CONSTRAINT tdm_pk_pkey PRIMARY KEY (tdm_pk);

ALTER TABLE ONLY pghydro.pghtb_type_water_mass
    ADD CONSTRAINT twm_pk_pkey PRIMARY KEY (twm_pk);

ALTER TABLE ONLY pghydro.pghtb_type_water_mass_operation
    ADD CONSTRAINT top_pk_pkey PRIMARY KEY (top_pk);

ALTER TABLE ONLY pghydro.pghtb_type_flow
    ADD CONSTRAINT tof_pk_pkey PRIMARY KEY (tof_pk);

ALTER TABLE ONLY pghydro.pghft_hydro_intel
    ADD CONSTRAINT hin_pk_pkey PRIMARY KEY (hin_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_point
    ADD CONSTRAINT drp_pk_pkey PRIMARY KEY (drp_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_pk_pkey PRIMARY KEY (drn_pk);

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    ADD CONSTRAINT mnp_pk_pkey PRIMARY KEY (mnp_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_area
    ADD CONSTRAINT dra_pk_pkey PRIMARY KEY (dra_pk);

ALTER TABLE ONLY pghydro.pghft_hydronym
    ADD CONSTRAINT hdr_pk_pkey PRIMARY KEY (hdr_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    ADD CONSTRAINT sep_pk_pkey PRIMARY KEY (sep_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    ADD CONSTRAINT ssp_pk_pkey PRIMARY KEY (ssp_pk);

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    ADD CONSTRAINT stm_pk_pkey PRIMARY KEY (stm_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_pk_pkey PRIMARY KEY (wtm_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass_boundary
    ADD CONSTRAINT wmb_pk_pkey PRIMARY KEY (wmb_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse
    ADD CONSTRAINT wtc_pk_pkey PRIMARY KEY (wtc_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    ADD CONSTRAINT wsp_pk_pkey PRIMARY KEY (wsp_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    ADD CONSTRAINT wep_pk_pkey PRIMARY KEY (wep_pk);

ALTER TABLE ONLY pghydro.pghft_watershed
    ADD CONSTRAINT wts_pk_pkey PRIMARY KEY (wts_pk);

ALTER TABLE ONLY pghydro.pghtb_type_de9im
    ADD CONSTRAINT dim_pk_pkey PRIMARY KEY (dim_pk);

ALTER TABLE ONLY pghydro.pghtb_type_geometry
    ADD CONSTRAINT tgm_pk_pkey PRIMARY KEY (tgm_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    ADD CONSTRAINT tnc_pk_pkey PRIMARY KEY (tnc_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_connection
    ADD CONSTRAINT tcn_pk_pkey PRIMARY KEY (tcn_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_generic
    ADD CONSTRAINT tng_pk_pkey PRIMARY KEY (tng_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_specific
    ADD CONSTRAINT tns_pk_pkey PRIMARY KEY (tns_pk);

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    ADD CONSTRAINT rcl_pk_pkey PRIMARY KEY (rcl_pk);

ALTER TABLE ONLY pghydro.pghtb_type_topology_relationship
    ADD CONSTRAINT tpr_pk_pkey PRIMARY KEY (tpr_pk);

ALTER TABLE ONLY pghydro.pghtb_pghydro_version
    ADD CONSTRAINT vrs_pk_pkey PRIMARY KEY (vrs_pk);

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropForeignKeys()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropForeignKeys()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

ALTER TABLE ONLY pghydro.pghft_dam
    DROP CONSTRAINT IF EXISTS dam_drn_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_dam
    DROP CONSTRAINT IF EXISTS dam_wtm_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_dam
    DROP CONSTRAINT IF EXISTS dam_rcl_pk_drn_fkey ;

ALTER TABLE ONLY pghydro.pghft_dam
    DROP CONSTRAINT IF EXISTS dam_rcl_pk_wtm_fkey ;

ALTER TABLE ONLY pghydro.pghft_dam
    DROP CONSTRAINT IF EXISTS dam_tof_pk_flow_out_fkey ;

ALTER TABLE ONLY pghydro.pghft_hydro_intel
    DROP CONSTRAINT IF EXISTS hin_drn_pk_fkey;

ALTER TABLE ONLY pghydro.pghft_hydro_intel
    DROP CONSTRAINT IF EXISTS hin_dra_pk_fkey;

ALTER TABLE ONLY pghydro.pghtb_drn_wtm
    DROP CONSTRAINT IF EXISTS pdw_drn_pk_fkey;

ALTER TABLE ONLY pghydro.pghtb_drn_wtm
    DROP CONSTRAINT IF EXISTS pdw_wtm_pk_fkey;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_trs_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_tdm_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_twm_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_tof_pk_flow_regulated_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_tof_pk_flow_backwater_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass
    DROP CONSTRAINT IF EXISTS wtm_top_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_wtc_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    DROP CONSTRAINT IF EXISTS ssp_drp_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    DROP CONSTRAINT IF EXISTS ssp_sho_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    DROP CONSTRAINT IF EXISTS sep_drp_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    DROP CONSTRAINT IF EXISTS sep_sho_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    DROP CONSTRAINT IF EXISTS stm_drp_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    DROP CONSTRAINT IF EXISTS wep_drp_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_hydronym
    DROP CONSTRAINT IF EXISTS hdr_tnc_pk_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    DROP CONSTRAINT IF EXISTS tnc_tng_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    DROP CONSTRAINT IF EXISTS mnp_drn_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass_boundary
    DROP CONSTRAINT IF EXISTS wmb_wtm_pk_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    DROP CONSTRAINT IF EXISTS rcl_tgm_pk_class_a_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_hdr_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    DROP CONSTRAINT IF EXISTS wsp_rcl_pk_drp_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    DROP CONSTRAINT IF EXISTS wsp_drp_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    DROP CONSTRAINT IF EXISTS ssp_rcl_pk_drp_fkey ;

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    DROP CONSTRAINT IF EXISTS sep_rcl_pk_drp_fkey ;

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    DROP CONSTRAINT IF EXISTS stm_rcl_pk_drp_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    DROP CONSTRAINT IF EXISTS wep_rcl_pk_drp_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    DROP CONSTRAINT IF EXISTS tnc_tcn_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    DROP CONSTRAINT IF EXISTS mnp_rcl_pk_drn_fkey ;

ALTER TABLE ONLY pghydro.pghft_water_mass_boundary
    DROP CONSTRAINT IF EXISTS wmb_rcl_pk_wtm_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    DROP CONSTRAINT IF EXISTS rcl_tgm_pk_class_b_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_drp_pk_sourcenode_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    DROP CONSTRAINT IF EXISTS wsp_wtc_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    DROP CONSTRAINT IF EXISTS stm_wtc_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    DROP CONSTRAINT IF EXISTS wep_wtc_pk_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    DROP CONSTRAINT IF EXISTS tnc_tns_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    DROP CONSTRAINT IF EXISTS mnp_wtm_pk_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    DROP CONSTRAINT IF EXISTS rcl_dim_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_drp_pk_targetnode_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    DROP CONSTRAINT IF EXISTS wsp_rcl_pk_wtc_fkey ;

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    DROP CONSTRAINT IF EXISTS stm_rcl_pk_wtc_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    DROP CONSTRAINT IF EXISTS wep_rcl_pk_wtc_fkey ;

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    DROP CONSTRAINT IF EXISTS mnp_rcl_pk_wtm_fkey ;

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    DROP CONSTRAINT IF EXISTS rcl_tpr_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_rcl_pk_drp_targetnode_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_rcl_pk_drp_sourcenode_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_dra_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_rcl_pk_dra_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_rcl_pk_wtc_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_wmb_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_rcl_pk_wmb_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_rcl_pk_hdr_fkey ;

ALTER TABLE ONLY pghydro.pghft_drainage_line
    DROP CONSTRAINT IF EXISTS drn_tdm_pk_fkey ;

ALTER TABLE ONLY pghydro.pghft_watercourse
    DROP CONSTRAINT IF EXISTS wtc_tdm_pk_fkey ;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-----------------------------------------
--FUNCTION pghydro.pghfn_AddForeignKeys()
-----------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_AddForeignKeys()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropForeignKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

ALTER TABLE ONLY pghydro.pghft_dam
    ADD CONSTRAINT dam_drn_pk_fkey FOREIGN KEY (dam_drn_pk) REFERENCES pghydro.pghft_drainage_line(drn_pk);

ALTER TABLE ONLY pghydro.pghft_dam
    ADD CONSTRAINT dam_wtm_pk_fkey FOREIGN KEY (dam_wtm_pk) REFERENCES pghydro.pghft_water_mass(wtm_pk);

ALTER TABLE ONLY pghydro.pghft_dam
    ADD CONSTRAINT dam_rcl_pk_drn_fkey FOREIGN KEY (dam_rcl_pk_drn) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_dam
    ADD CONSTRAINT dam_rcl_pk_wtm_fkey FOREIGN KEY (dam_rcl_pk_wtm) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_dam
    ADD CONSTRAINT dam_tof_pk_flow_out_fkey FOREIGN KEY (dam_tof_pk_flow_out) REFERENCES pghydro.pghtb_type_flow(tof_pk);

ALTER TABLE ONLY pghydro.pghft_hydro_intel
    ADD CONSTRAINT hin_drn_pk_fkey FOREIGN KEY (hin_drn_pk) REFERENCES pghydro.pghft_drainage_line(drn_pk);

ALTER TABLE ONLY pghydro.pghft_hydro_intel
    ADD CONSTRAINT hin_dra_pk_fkey FOREIGN KEY (hin_dra_pk) REFERENCES pghydro.pghft_drainage_area(dra_pk);

ALTER TABLE ONLY pghydro.pghtb_drn_wtm
    ADD CONSTRAINT pdw_drn_pk_fkey FOREIGN KEY (pdw_drn_pk) REFERENCES pghydro.pghft_drainage_line(drn_pk);

ALTER TABLE ONLY pghydro.pghtb_drn_wtm
    ADD CONSTRAINT pdw_wtm_pk_fkey FOREIGN KEY (pdw_wtm_pk) REFERENCES pghydro.pghft_water_mass(wtm_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_trs_pk_fkey FOREIGN KEY (wtm_trs_pk) REFERENCES pghydro.pghtb_type_reservoir(trs_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_twm_pk_fkey FOREIGN KEY (wtm_twm_pk) REFERENCES pghydro.pghtb_type_water_mass(twm_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_tdm_pk_fkey FOREIGN KEY (wtm_tdm_pk) REFERENCES pghydro.pghtb_type_domain(tdm_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_tof_pk_flow_regulated_fkey FOREIGN KEY (wtm_tof_pk_flow_regulated) REFERENCES pghydro.pghtb_type_flow(tof_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_tof_pk_flow_backwater_fkey FOREIGN KEY (wtm_tof_pk_flow_backwater) REFERENCES pghydro.pghtb_type_flow(tof_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass
    ADD CONSTRAINT wtm_top_pk_fkey FOREIGN KEY (wtm_top_pk) REFERENCES pghydro.pghtb_type_water_mass_operation(top_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_wtc_pk_fkey FOREIGN KEY (drn_wtc_pk) REFERENCES pghydro.pghft_watercourse(wtc_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    ADD CONSTRAINT ssp_drp_pk_fkey FOREIGN KEY (ssp_drp_pk) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    ADD CONSTRAINT ssp_sho_pk_fkey FOREIGN KEY (ssp_sho_pk) REFERENCES pghydro.pghft_shoreline(sho_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    ADD CONSTRAINT sep_drp_pk_fkey FOREIGN KEY (sep_drp_pk) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    ADD CONSTRAINT sep_sho_pk_fkey FOREIGN KEY (sep_sho_pk) REFERENCES pghydro.pghft_shoreline(sho_pk);

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    ADD CONSTRAINT stm_drp_pk_fkey FOREIGN KEY (stm_drp_pk) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    ADD CONSTRAINT wep_drp_pk_fkey FOREIGN KEY (wep_drp_pk) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_hydronym
    ADD CONSTRAINT hdr_tnc_pk_fkey FOREIGN KEY (hdr_tnc_pk) REFERENCES pghydro.pghtb_type_name_complete(tnc_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    ADD CONSTRAINT tnc_tng_pk_fkey FOREIGN KEY (tnc_tng_pk) REFERENCES pghydro.pghtb_type_name_generic(tng_pk);

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    ADD CONSTRAINT mnp_drn_pk_fkey FOREIGN KEY (mnp_drn_pk) REFERENCES pghydro.pghft_drainage_line(drn_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass_boundary
    ADD CONSTRAINT wmb_wtm_pk_fkey FOREIGN KEY (wmb_wtm_pk) REFERENCES pghydro.pghft_water_mass(wtm_pk);

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    ADD CONSTRAINT rcl_tgm_pk_class_a_fkey FOREIGN KEY (rcl_tgm_pk_class_a) REFERENCES pghydro.pghtb_type_geometry(tgm_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_hdr_pk_fkey FOREIGN KEY (drn_hdr_pk) REFERENCES pghydro.pghft_hydronym(hdr_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    ADD CONSTRAINT wsp_rcl_pk_drp_fkey FOREIGN KEY (wsp_rcl_pk_drp) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    ADD CONSTRAINT wsp_drp_pk_fkey FOREIGN KEY (wsp_drp_pk) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_starting_point
    ADD CONSTRAINT ssp_rcl_pk_drp_fkey FOREIGN KEY (ssp_rcl_pk_drp) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_shoreline_ending_point
    ADD CONSTRAINT sep_rcl_pk_drp_fkey FOREIGN KEY (sep_rcl_pk_drp) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    ADD CONSTRAINT stm_rcl_pk_drp_fkey FOREIGN KEY (stm_rcl_pk_drp) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    ADD CONSTRAINT wep_rcl_pk_drp_fkey FOREIGN KEY (wep_rcl_pk_drp) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    ADD CONSTRAINT tnc_tcn_pk_fkey FOREIGN KEY (tnc_tcn_pk) REFERENCES pghydro.pghtb_type_name_connection(tcn_pk);

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    ADD CONSTRAINT mnp_rcl_pk_drn_fkey FOREIGN KEY (mnp_rcl_pk_drn) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_water_mass_boundary
    ADD CONSTRAINT wmb_rcl_pk_wtm_fkey FOREIGN KEY (wmb_rcl_pk_wtm) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    ADD CONSTRAINT rcl_tgm_pk_class_b_fkey FOREIGN KEY (rcl_tgm_pk_class_b) REFERENCES pghydro.pghtb_type_geometry(tgm_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_drp_pk_sourcenode_fkey FOREIGN KEY (drn_drp_pk_sourcenode) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    ADD CONSTRAINT wsp_wtc_pk_fkey FOREIGN KEY (wsp_wtc_pk) REFERENCES pghydro.pghft_watercourse(wtc_pk);

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    ADD CONSTRAINT stm_wtc_pk_fkey FOREIGN KEY (stm_wtc_pk) REFERENCES pghydro.pghft_watercourse(wtc_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    ADD CONSTRAINT wep_wtc_pk_fkey FOREIGN KEY (wep_wtc_pk) REFERENCES pghydro.pghft_watercourse(wtc_pk);

ALTER TABLE ONLY pghydro.pghtb_type_name_complete
    ADD CONSTRAINT tnc_tns_pk_fkey FOREIGN KEY (tnc_tns_pk) REFERENCES pghydro.pghtb_type_name_specific(tns_pk);

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    ADD CONSTRAINT mnp_wtm_pk_fkey FOREIGN KEY (mnp_wtm_pk) REFERENCES pghydro.pghft_water_mass(wtm_pk);

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    ADD CONSTRAINT rcl_dim_pk_fkey FOREIGN KEY (rcl_dim_pk) REFERENCES pghydro.pghtb_type_de9im(dim_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_drp_pk_targetnode_fkey FOREIGN KEY (drn_drp_pk_targetnode) REFERENCES pghydro.pghft_drainage_point(drp_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_starting_point
    ADD CONSTRAINT wsp_rcl_pk_wtc_fkey FOREIGN KEY (wsp_rcl_pk_wtc) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_stream_mouth
    ADD CONSTRAINT stm_rcl_pk_wtc_fkey FOREIGN KEY (stm_rcl_pk_wtc) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse_ending_point
    ADD CONSTRAINT wep_rcl_pk_wtc_fkey FOREIGN KEY (wep_rcl_pk_wtc) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_monitoring_point
    ADD CONSTRAINT mnp_rcl_pk_wtm_fkey FOREIGN KEY (mnp_rcl_pk_wtm) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghtb_type_relationship_class
    ADD CONSTRAINT rcl_tpr_pk_fkey FOREIGN KEY (rcl_tpr_pk) REFERENCES pghydro.pghtb_type_topology_relationship(tpr_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_rcl_pk_drp_targetnode_fkey FOREIGN KEY (drn_rcl_pk_drp_targetnode) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_rcl_pk_drp_sourcenode_fkey FOREIGN KEY (drn_rcl_pk_drp_sourcenode) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_dra_pk_fkey FOREIGN KEY (drn_dra_pk) REFERENCES pghydro.pghft_drainage_area(dra_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_rcl_pk_dra_fkey FOREIGN KEY (drn_rcl_pk_dra) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_rcl_pk_wtc_fkey FOREIGN KEY (drn_rcl_pk_wtc) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_wmb_pk_fkey FOREIGN KEY (drn_wmb_pk) REFERENCES pghydro.pghft_water_mass_boundary(wmb_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_rcl_pk_wmb_fkey FOREIGN KEY (drn_rcl_pk_wmb) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_rcl_pk_hdr_fkey FOREIGN KEY (drn_rcl_pk_hdr) REFERENCES pghydro.pghtb_type_relationship_class(rcl_pk);

ALTER TABLE ONLY pghydro.pghft_drainage_line
    ADD CONSTRAINT drn_tdm_pk_fkey FOREIGN KEY (drn_tdm_pk) REFERENCES pghydro.pghtb_type_domain(tdm_pk);

ALTER TABLE ONLY pghydro.pghft_watercourse
    ADD CONSTRAINT wtc_tdm_pk_fkey FOREIGN KEY (wtc_tdm_pk) REFERENCES pghydro.pghtb_type_domain(tdm_pk);

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropGeometryIndex()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropGeometryIndex()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.sho_gm_idx;

DROP INDEX IF EXISTS pghydro.hin_gm_point_idx;

DROP INDEX IF EXISTS pghydro.hin_gm_line_idx;

DROP INDEX IF EXISTS pghydro.hin_gm_polygon_idx;

DROP INDEX IF EXISTS pghydro.dam_gm_idx;

DROP INDEX IF EXISTS pghydro.dam_gm_original_idx;

DROP INDEX IF EXISTS pghydro.drp_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

DROP INDEX IF EXISTS pghydro.mnp_gm_idx;

DROP INDEX IF EXISTS pghydro.mnp_gm_original_idx;

DROP INDEX IF EXISTS pghydro.dra_gm_idx;

DROP INDEX IF EXISTS pghydro.hdr_gm_idx;

DROP INDEX IF EXISTS pghydro.sep_gm_idx;

DROP INDEX IF EXISTS pghydro.ssp_gm_idx;

DROP INDEX IF EXISTS pghydro.stm_gm_idx;

DROP INDEX IF EXISTS pghydro.wtm_gm_idx;

DROP INDEX IF EXISTS pghydro.wtm_gm_point_idx;

DROP INDEX IF EXISTS pghydro.wmb_gm_idx;

DROP INDEX IF EXISTS pghydro.wtc_gm_idx;

DROP INDEX IF EXISTS pghydro.wep_gm_idx;

DROP INDEX IF EXISTS pghydro.wsp_gm_idx;

DROP INDEX IF EXISTS pghydro.wts_gm_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CreateGeometryIndex()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateGeometryIndex()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropGeometryIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX sho_gm_idx ON pghydro.pghft_shoreline USING GIST(sho_gm);

CREATE INDEX hin_gm_point_idx ON pghydro.pghft_hydro_intel USING GIST(hin_gm_point);

CREATE INDEX hin_gm_line_idx ON pghydro.pghft_hydro_intel USING GIST(hin_gm_line);

CREATE INDEX hin_gm_polygon_idx ON pghydro.pghft_hydro_intel USING GIST(hin_gm_polygon);

CREATE INDEX dam_gm_idx ON pghydro.pghft_dam USING GIST(dam_gm);

CREATE INDEX dam_gm_original_idx ON pghydro.pghft_dam USING GIST(dam_gm_original);

CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);

CREATE INDEX drn_gm_idx ON pghydro.pghft_drainage_line USING GIST(drn_gm);

CREATE INDEX mnp_gm_idx ON pghydro.pghft_monitoring_point USING GIST(mnp_gm);

CREATE INDEX mnp_gm_original_idx ON pghydro.pghft_monitoring_point USING GIST(mnp_gm_original);

CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING GIST(dra_gm);

CREATE INDEX hdr_gm_idx ON pghydro.pghft_hydronym USING GIST(hdr_gm);

CREATE INDEX sep_gm_idx ON pghydro.pghft_shoreline_ending_point USING GIST(sep_gm);

CREATE INDEX ssp_gm_idx ON pghydro.pghft_shoreline_starting_point USING GIST(ssp_gm);

CREATE INDEX stm_gm_idx ON pghydro.pghft_stream_mouth USING GIST(stm_gm);

CREATE INDEX wtm_gm_idx ON pghydro.pghft_water_mass USING GIST(wtm_gm);

CREATE INDEX wtm_gm_point_idx ON pghydro.pghft_water_mass USING GIST(wtm_gm_point);

CREATE INDEX wmb_gm_idx ON pghydro.pghft_water_mass_boundary USING GIST(wmb_gm);

CREATE INDEX wtc_gm_idx ON pghydro.pghft_watercourse USING GIST(wtc_gm);

CREATE INDEX wep_gm_idx ON pghydro.pghft_watercourse_ending_point USING GIST(wep_gm);

CREATE INDEX wsp_gm_idx ON pghydro.pghft_watercourse_starting_point USING GIST(wsp_gm);

CREATE INDEX wts_gm_idx ON pghydro.pghft_watershed USING GIST(wts_gm);

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropIndex()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropIndex()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.ssp_sho_pk_idx;

DROP INDEX IF EXISTS pghydro.sep_sho_pk_idx;

DROP INDEX IF EXISTS pghydro.dam_drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dam_wtm_pk_idx;

DROP INDEX IF EXISTS pghydro.dam_rcl_pk_drn_idx;

DROP INDEX IF EXISTS pghydro.dam_rcl_pk_wtm_idx;

DROP INDEX IF EXISTS pghydro.dam_tof_pk_flow_out_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.hin_drn_pk_idx;

DROP INDEX IF EXISTS pghydro.hin_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pdw_drn_pk_idx;

DROP INDEX IF EXISTS pghydro.pdw_wtm_pk_idx;

DROP INDEX IF EXISTS pghydro.wtm_trs_pk_idx;

DROP INDEX IF EXISTS pghydro.wtm_tdm_pk_idx;

DROP INDEX IF EXISTS pghydro.wtm_twm_pk_idx;

DROP INDEX IF EXISTS pghydro.wtm_tof_pk_flow_regulated_idx;

DROP INDEX IF EXISTS pghydro.wtm_tof_pk_flow_backwater_idx;

DROP INDEX IF EXISTS pghydro.wtm_top_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.ssp_drp_pk_idx;

DROP INDEX IF EXISTS pghydro.sep_drp_pk_idx;

DROP INDEX IF EXISTS pghydro.stm_drp_pk_idx;

DROP INDEX IF EXISTS pghydro.wep_drp_pk_idx;

DROP INDEX IF EXISTS pghydro.hdr_tnc_pk_idx;

DROP INDEX IF EXISTS pghydro.tnc_tng_pk_idx;

DROP INDEX IF EXISTS pghydro.mnp_drn_pk_idx;

DROP INDEX IF EXISTS pghydro.wmb_wtm_pk_idx;

DROP INDEX IF EXISTS pghydro.rcl_tgm_pk_class_a_idx;

DROP INDEX IF EXISTS pghydro.drn_hdr_pk_idx;

DROP INDEX IF EXISTS pghydro.wsp_rcl_pk_drp_idx;

DROP INDEX IF EXISTS pghydro.wsp_drp_pk_idx;

DROP INDEX IF EXISTS pghydro.ssp_rcl_pk_drp_idx;

DROP INDEX IF EXISTS pghydro.sep_rcl_pk_drp_idx;

DROP INDEX IF EXISTS pghydro.stm_rcl_pk_drp_idx;

DROP INDEX IF EXISTS pghydro.wep_rcl_pk_drp_idx;

DROP INDEX IF EXISTS pghydro.tnc_tcn_pk_idx;

DROP INDEX IF EXISTS pghydro.mnp_rcl_pk_drn_idx;

DROP INDEX IF EXISTS pghydro.wmb_rcl_pk_wtm_idx;

DROP INDEX IF EXISTS pghydro.rcl_tgm_pk_class_b_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.wsp_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.stm_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.wep_wtc_pk_idx;

DROP INDEX IF EXISTS pghydro.tnc_tns_pk_idx;

DROP INDEX IF EXISTS pghydro.mnp_wtm_pk_idx;

DROP INDEX IF EXISTS pghydro.rcl_dim_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.wsp_rcl_pk_wtc_idx;

DROP INDEX IF EXISTS pghydro.stm_rcl_pk_wtc_idx;

DROP INDEX IF EXISTS pghydro.wep_rcl_pk_wtc_idx;

DROP INDEX IF EXISTS pghydro.mnp_rcl_pk_wtm_idx;

DROP INDEX IF EXISTS pghydro.rcl_tpr_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_rcl_pk_drp_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_rcl_pk_drp_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_rcl_pk_dra_idx;

DROP INDEX IF EXISTS pghydro.drn_rcl_pk_wtc_idx;

DROP INDEX IF EXISTS pghydro.drn_wmb_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_rcl_pk_wmb_idx;

DROP INDEX IF EXISTS pghydro.drn_rcl_pk_hdr_idx;

DROP INDEX IF EXISTS pghydro.drn_tdm_pk_idx;

DROP INDEX IF EXISTS pghydro.wtc_tdm_pk_idx;

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

DROP INDEX IF EXISTS pghydro.hin_strahler_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CreateIndex()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateIndex()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX dam_drn_pk_idx ON pghydro.pghft_dam(dam_drn_pk);

CREATE INDEX dam_wtm_pk_idx ON pghydro.pghft_dam(dam_wtm_pk);

CREATE INDEX dam_rcl_pk_drn_idx ON pghydro.pghft_dam(dam_rcl_pk_drn);

CREATE INDEX dam_rcl_pk_wtm_idx ON pghydro.pghft_dam(dam_rcl_pk_wtm);

CREATE INDEX dam_tof_pk_flow_out_idx ON pghydro.pghft_dam(dam_tof_pk_flow_out);

CREATE INDEX hin_drn_pk_idx ON pghydro.pghft_hydro_intel(hin_drn_pk);

CREATE INDEX hin_dra_pk_idx ON pghydro.pghft_hydro_intel(hin_dra_pk);

CREATE INDEX pdw_drn_pk_idx ON pghydro.pghtb_drn_wtm(pdw_drn_pk);

CREATE INDEX pdw_wtm_pk_idx ON pghydro.pghtb_drn_wtm(pdw_wtm_pk);

CREATE INDEX wtm_trs_pk_idx ON pghydro.pghft_water_mass(wtm_trs_pk);

CREATE INDEX wtm_twm_pk_idx ON pghydro.pghft_water_mass(wtm_twm_pk);

CREATE INDEX wtm_tdm_pk_idx ON pghydro.pghft_water_mass(wtm_tdm_pk);

CREATE INDEX wtm_top_pk_idx ON pghydro.pghft_water_mass(wtm_top_pk);

CREATE INDEX wtm_tof_pk_flow_regulated_idx ON pghydro.pghft_water_mass(wtm_tof_pk_flow_regulated);

CREATE INDEX wtm_tof_pk_flow_backwater_idx ON pghydro.pghft_water_mass(wtm_tof_pk_flow_backwater);

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

CREATE INDEX ssp_drp_pk_idx ON pghydro.pghft_shoreline_starting_point(ssp_drp_pk);

CREATE INDEX ssp_sho_pk_idx ON pghydro.pghft_shoreline_starting_point(ssp_sho_pk);

CREATE INDEX sep_drp_pk_idx ON pghydro.pghft_shoreline_ending_point(sep_drp_pk);

CREATE INDEX sep_sho_pk_idx ON pghydro.pghft_shoreline_ending_point(sep_sho_pk);

CREATE INDEX stm_drp_pk_idx ON pghydro.pghft_stream_mouth(stm_drp_pk);

CREATE INDEX wep_drp_pk_idx ON pghydro.pghft_watercourse_ending_point(wep_drp_pk);

CREATE INDEX hdr_tnc_pk_idx ON pghydro.pghft_hydronym(hdr_tnc_pk);

CREATE INDEX tnc_tng_pk_idx ON pghydro.pghtb_type_name_complete(tnc_tng_pk);

CREATE INDEX mnp_drn_pk_idx ON pghydro.pghft_monitoring_point(mnp_drn_pk);

CREATE INDEX wmb_wtm_pk_idx ON pghydro.pghft_water_mass_boundary(wmb_wtm_pk);

CREATE INDEX rcl_tgm_pk_class_a_idx ON pghydro.pghtb_type_relationship_class(rcl_tgm_pk_class_a);

CREATE INDEX drn_hdr_pk_idx ON pghydro.pghft_drainage_line(drn_hdr_pk);

CREATE INDEX wsp_rcl_pk_drp_idx ON pghydro.pghft_watercourse_starting_point(wsp_rcl_pk_drp);

CREATE INDEX wsp_drp_pk_idx ON pghydro.pghft_watercourse_starting_point(wsp_drp_pk);

CREATE INDEX ssp_rcl_pk_drp_idx ON pghydro.pghft_shoreline_starting_point(ssp_rcl_pk_drp);

CREATE INDEX sep_rcl_pk_drp_idx ON pghydro.pghft_shoreline_ending_point(sep_rcl_pk_drp);

CREATE INDEX stm_rcl_pk_drp_idx ON pghydro.pghft_stream_mouth(stm_rcl_pk_drp);

CREATE INDEX wep_rcl_pk_drp_idx ON pghydro.pghft_watercourse_ending_point(wep_rcl_pk_drp);

CREATE INDEX tnc_tcn_pk_idx ON pghydro.pghtb_type_name_complete(tnc_tcn_pk);

CREATE INDEX mnp_rcl_pk_drn_idx ON pghydro.pghft_monitoring_point(mnp_rcl_pk_drn);

CREATE INDEX wmb_rcl_pk_wtm_idx ON pghydro.pghft_water_mass_boundary(wmb_rcl_pk_wtm);

CREATE INDEX rcl_tgm_pk_class_b_idx ON pghydro.pghtb_type_relationship_class(rcl_tgm_pk_class_b);

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

CREATE INDEX wsp_wtc_pk_idx ON pghydro.pghft_watercourse_starting_point(wsp_wtc_pk);

CREATE INDEX stm_wtc_pk_idx ON pghydro.pghft_stream_mouth(stm_wtc_pk);

CREATE INDEX wep_wtc_pk_idx ON pghydro.pghft_watercourse_ending_point(wep_wtc_pk);

CREATE INDEX tnc_tns_pk_idx ON pghydro.pghtb_type_name_complete(tnc_tns_pk);

CREATE INDEX mnp_wtm_pk_idx ON pghydro.pghft_monitoring_point(mnp_wtm_pk);

CREATE INDEX rcl_dim_pk_idx ON pghydro.pghtb_type_relationship_class(rcl_dim_pk);

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

CREATE INDEX wsp_rcl_pk_wtc_idx ON pghydro.pghft_watercourse_starting_point(wsp_rcl_pk_wtc);

CREATE INDEX stm_rcl_pk_wtc_idx ON pghydro.pghft_stream_mouth(stm_rcl_pk_wtc);

CREATE INDEX wep_rcl_pk_wtc_idx ON pghydro.pghft_watercourse_ending_point(wep_rcl_pk_wtc);

CREATE INDEX mnp_rcl_pk_wtm_idx ON pghydro.pghft_monitoring_point(mnp_rcl_pk_wtm);

CREATE INDEX rcl_tpr_pk_idx ON pghydro.pghtb_type_relationship_class(rcl_tpr_pk);

CREATE INDEX drn_rcl_pk_drp_targetnode_idx ON pghydro.pghft_drainage_line(drn_rcl_pk_drp_targetnode);

CREATE INDEX drn_rcl_pk_drp_sourcenode_idx ON pghydro.pghft_drainage_line(drn_rcl_pk_drp_sourcenode);

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

CREATE INDEX drn_rcl_pk_dra_idx ON pghydro.pghft_drainage_line(drn_rcl_pk_dra);

CREATE INDEX drn_rcl_pk_wtc_idx ON pghydro.pghft_drainage_line(drn_rcl_pk_wtc);

CREATE INDEX drn_wmb_pk_idx ON pghydro.pghft_drainage_line(drn_wmb_pk);

CREATE INDEX drn_rcl_pk_wmb_idx ON pghydro.pghft_drainage_line(drn_rcl_pk_wmb);

CREATE INDEX drn_rcl_pk_hdr_idx ON pghydro.pghft_drainage_line(drn_rcl_pk_hdr);

CREATE INDEX drn_tdm_pk_idx ON pghydro.pghft_drainage_line(drn_tdm_pk);

CREATE INDEX wtc_tdm_pk_idx ON pghydro.pghft_watercourse(wtc_tdm_pk);

CREATE INDEX drp_nu_valence_idx ON pghydro.pghft_drainage_point(drp_nu_valence);

CREATE INDEX hin_strahler_idx ON pghydro.pghft_hydro_intel(hin_strahler);

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-----------------------------------------
--FUNCTION pghydro.pghfn_CreateConsistencyViews()
-----------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateConsistencyViews()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropConsistencyViews();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

--VIEW pghydro.pghvw_DrainageLineIsNotSingle

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineIsNotSingle AS
SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE ST_NumGeometries(drn_gm) >1;

--VIEW pghydro.pghvw_DrainageLineIsNotSimple

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineIsNotSimple AS
SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE ST_IsSimple(drn_gm) <> 't';

--VIEW pghydro.pghvw_DrainageLineIsNotValid

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineIsNotValid AS
SELECT drn_pk, ST_IsValidReason(drn_gm), drn_gm
FROM pghydro.pghft_drainage_line
WHERE ST_IsValidReason(drn_gm) <> 'Valid Geometry';

--VIEW pghydro.pghvw_DrainageLineHaveSelfIntersection

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineHaveSelfIntersection AS
SELECT (ROW_NUMBER() OVER ())::integer AS drn_pk, drn_gm
FROM
(
SELECT a.drn_pk as drn_pk, b.drn_pk as drn_pk_b, a.drn_gm as drn_gm
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND ST_Intersects(a.drn_gm,b.drn_gm)
AND NOT ST_touches(a.drn_gm,b.drn_gm)
AND a.drn_pk != b.drn_pk
) as a;

--VIEW pghydro.pghvw_DrainageLineLoops

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineLoops AS
SELECT (ROW_NUMBER() OVER ())::integer AS drn_pk, plg_gm
FROM
(
SELECT drn_pk, (ST_Dump(b.plg_gm)).geom as plg_gm
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

--VIEW pghydro.pghvw_PointValenceValue2

CREATE OR REPLACE VIEW pghydro.pghvw_PointValenceValue2 AS
SELECT drp_pk, drp_gm
FROM pghydro.pghft_drainage_point
WHERE drp_nu_valence = 2;

--VIEW pghydro.pghvw_PointValenceValue4

CREATE OR REPLACE VIEW pghydro.pghvw_PointValenceValue4 AS
SELECT drp_pk, drp_gm
FROM pghydro.pghft_drainage_point
WHERE drp_nu_valence >= 4;

--VIEW pghydro.pghvw_DrainageLineIsDisconnected()

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineIsDisconnected AS
SELECT drn_pk, drn_gm
FROM pghydro.pghft_drainage_line
WHERE drn_bo_flowdirection is null;

--VIEW pghydro.pghvw_DrainageAreaIsNotSingle

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaIsNotSingle AS
SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE ST_NumGeometries(dra_gm) >1;

--VIEW pghydro.pghvw_DrainageAreaIsNotSimple

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaIsNotSimple AS
SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE ST_IsSimple(dra_gm) <> 't';

--VIEW pghydro.pghvw_DrainageAreaIsNotValid

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaIsNotValid AS
SELECT dra_pk, dra_gm
FROM pghydro.pghft_drainage_area
WHERE ST_IsValidReason(dra_gm) <> 'Valid Geometry';

--VIEW pghydro.pghvw_DrainageAreaHaveSelfIntersection

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaHaveSelfIntersection AS
SELECT (ROW_NUMBER() OVER (ORDER BY dra_pk ASC))::integer AS dra_pk, dra_gm
FROM
(
SELECT dra_pk, dra_gm
FROM
(
SELECT a.dra_pk, b.dra_pk as dra_pk_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as dra_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_Relate(a.dra_gm, b.dra_gm) in ('212111212','212101212')
AND a.dra_pk < b.dra_pk
) as c
WHERE st_geometrytype(dra_gm) = 'ST_MultiPolygon'
) as a;

--VIEW pghydro.pghvw_DrainageAreaHaveDuplication

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaHaveDuplication AS
SELECT dra_pk, dra_gm
FROM
(
SELECT a.dra_pk, b.dra_pk as dra_pk_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as dra_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_Relate(a.dra_gm, b.dra_gm) = '2FFF1FFF2'
AND a.dra_pk < b.dra_pk
) as c
WHERE st_geometrytype(dra_gm) = 'ST_MultiPolygon';

--VIEW pghydro.pghvw_DrainageAreaNoDrainageLine

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaNoDrainageLine AS
SELECT a.hin_dra_pk as dra_pk, b.dra_gm as dra_gm
FROM pghydro.pghft_drainage_area b, pghydro.pghft_hydro_intel a
WHERE a.hin_drn_pk isnull
AND a.hin_dra_pk = b.dra_pk;

--VIEW pghydro.pghvw_DrainageLineNoDrainageArea

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineNoDrainageArea AS
SELECT a.hin_drn_pk as drn_pk, b.drn_gm
FROM pghydro.pghft_drainage_line b, pghydro.pghft_hydro_intel a
WHERE a.hin_dra_pk isnull
AND a.hin_drn_pk = b.drn_pk;

--VIEW pghydro.pghvw_DrainageAreaMoreOneDrainageLine

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaMoreOneDrainageLine AS
SELECT DISTINCT a.hin_dra_pk as dra_pk, b.dra_gm as dra_gm
FROM pghydro.pghft_drainage_area b, pghydro.pghft_hydro_intel a
WHERE hin_count_dra_pk >=2 
AND a.hin_dra_pk = b.dra_pk;

--VIEW pghydro.pghvw_DrainageLineMoreOneDrainageArea

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineMoreOneDrainageArea AS
SELECT DISTINCT a.hin_drn_pk as drn_pk, b.drn_gm
FROM pghydro.pghft_drainage_line b, pghydro.pghft_hydro_intel a
WHERE hin_count_drn_pk >=2 
AND a.hin_drn_pk = b.drn_pk;

--VIEW pghydro.pghvw_pointdivergent

CREATE OR REPLACE VIEW pghydro.pghvw_pointdivergent AS
SELECT a.drp_pk, b.drp_gm
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
) as a, pghydro.pghft_drainage_point b
WHERE a.drp_pk = b.drp_pk;

--VIEW pghydro.pghvw_drainage_line_point

CREATE OR REPLACE VIEW pghydro.pghvw_drainage_line_point AS
SELECT drn_pk, ST_Line_Interpolate_Point((ST_Dump(drn_gm)).geom, 0.5) as drp_gm
FROM pghydro.pghft_drainage_line;

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
--FUNCTION pghydro.pghfn_DropConsistencyViews()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropConsistencyViews()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineIsNotSingle;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineIsNotSimple;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineIsNotValid;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineHaveSelfIntersection;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineLoops;

DROP VIEW IF EXISTS  pghydro.pghvw_PointValenceValue2;

DROP VIEW IF EXISTS  pghydro.pghvw_PointValenceValue4;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineIsDisconnected;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaIsNotSingle;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaIsNotSimple;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaIsNotValid;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaHaveSelfIntersection;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaHaveDuplication;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaNoDrainageLine;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineNoDrainageArea;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageAreaMoreOneDrainageLine;

DROP VIEW IF EXISTS  pghydro.pghvw_DrainageLineMoreOneDrainageArea;

DROP VIEW IF EXISTS  pghydro.pghvw_pointdivergent;

DROP VIEW IF EXISTS  pghydro.pghvw_drainage_line_point;

DROP VIEW IF EXISTS  pghydro.pghvw_confluencehydronym;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CreateExportViews()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateExportViews()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

PERFORM pghydro.pghfn_DropExportViews();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

--VIEW pghydro.BHO_TRECHODRENAGEM

DROP VIEW IF EXISTS pghydro.BHO_TRECHODRENAGEM;

CREATE OR REPLACE VIEW pghydro.BHO_TRECHODRENAGEM as
SELECT
drn_pk,
drn.drn_pk as cotrecho,
drn.drn_drp_pk_sourcenode as noorigem,
drn.drn_drp_pk_targetnode as nodestino,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
dra.dra_cd_pfafstetterbasin as cobacia,
drn.drn_gm_length as nucomptrec,
drn.drn_nu_distancetosea as nudistbact,
drn.drn_nu_distancetowatercourse as nudistcdag,
dra.dra_gm_area as nuareacont,
drn.drn_nu_upstreamarea as nuareamont,
hdr.hdr_cd as corio,
tng.tng_ds as nogenerico,
tcn.tcn_ds as noligacao,
tns.tns_ds as noespecif,
tnc.tnc_ds as noriocomp,
drn.drn_nm as nooriginal,
hdr.hdr_gm_length as nucomprio,
hdr.hdr_nu_distancetosea as nudistbacr,
wtc.wtc_cd_pfafstetterwatercourse_downstream as cocdadesag,
drn.drn_drn_pk_downstreamdrainageline as nutrjus,
wtc.wtc_nu_distancetosea as nudistbacc,
wtc.wtc_gm_area as nuareabacc,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as nuordemcda,
wtc.wtc_gm_length as nucompcda,
dra.dra_nu_pfafstetterbasincodelevel as nunivotto,
wtc.wtc_nu_pfafstetterwatercoursecodelevel as nunivotcda,
hin.hin_strahler as nustrahler,
tdm.tdm_ds as dedominial,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drn_gm
FROM pghydro.pghft_drainage_line drn
INNER JOIN pghydro.pghft_drainage_area dra ON drn.drn_dra_pk = dra.dra_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
FULL OUTER JOIN pghydro.pghft_hydronym hdr ON drn.drn_hdr_pk = hdr.hdr_pk
FULL OUTER JOIN pghydro.pghtb_type_name_complete tnc ON hdr.hdr_tnc_pk = tnc.tnc_pk
FULL OUTER JOIN pghydro.pghtb_type_name_generic tng ON tnc.tnc_tng_pk = tng.tng_pk
FULL OUTER JOIN pghydro.pghtb_type_name_connection tcn ON tnc.tnc_tcn_pk = tcn.tcn_pk
FULL OUTER JOIN pghydro.pghtb_type_name_specific tns ON tnc.tnc_tns_pk = tns.tns_pk
FULL OUTER JOIN pghydro.pghtb_type_domain tdm ON tdm.tdm_pk = drn.drn_tdm_pk
FULL OUTER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_drn_pk = drn.drn_pk;

--VIEW pghydro.BHO_AREACONTRIBUICAO

DROP VIEW IF EXISTS pghydro.BHO_AREACONTRIBUICAO;

CREATE OR REPLACE VIEW pghydro.BHO_AREACONTRIBUICAO as
SELECT
dra_pk,
dra.dra_pk as idbacia,
drn.drn_pk as cotrecho,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
dra.dra_cd_pfafstetterbasin as cobacia,
dra.dra_gm_area as nuareacont,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as nuordemcda,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 1) as nunivotto1,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 2) as nunivotto2,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 3) as nunivotto3,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 4) as nunivotto4,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 5) as nunivotto5,
substring(dra.dra_cd_pfafstetterbasin FROM 1 FOR 6) as nunivotto6,
dra.dra_nu_pfafstetterbasincodelevel as nunivotto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
dra_gm
FROM pghydro.pghft_drainage_line drn
INNER JOIN pghydro.pghft_drainage_area dra ON drn.drn_dra_pk = dra.dra_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
UNION
SELECT 
dra.dra_pk,
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
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
dra.dra_gm
FROM pghydro.pghft_drainage_area dra
INNER JOIN pghydro.pghft_hydro_intel hin ON hin.hin_dra_pk = dra.dra_pk
WHERE hin.hin_drn_pk is null;

--VIEW pghydro.BHO_CURSODAGUA

DROP VIEW IF EXISTS pghydro.BHO_CURSODAGUA;

CREATE OR REPLACE VIEW pghydro.BHO_CURSODAGUA AS
SELECT
wtc.wtc_pk,
wtc.wtc_pk as idcda,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
wtc.wtc_nu_distancetosea as nudistbacc,
wtc.wtc_gm_length as nucompcda,
wtc.wtc_gm_area as nuareabacc,
wtc.wtc_cd_pfafstetterwatercourse_downstream as cocdadesag,
wtc.wtc_nu_pfafstetterwatercoursecodelevel as nunivotcda,
wtc.wtc_nu_pfafstetterwatercoursecodeorder as nuordemcda,
tdm.tdm_ds as dedominial,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
wtc.wtc_gm
FROM pghydro.pghft_watercourse wtc
FULL OUTER JOIN pghydro.pghtb_type_domain tdm ON tdm.tdm_pk = wtc.wtc_tdm_pk;

--VIEW pghydro.BHO_PONTODRENAGEM

DROP VIEW IF EXISTS pghydro.BHO_PONTODRENAGEM;

CREATE OR REPLACE VIEW pghydro.BHO_PONTODRENAGEM AS
--watercourse starting point
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Inicio do Curso Dagua'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
UNION
--Shoreline starting point
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Inicio da Linha de Costa'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_sourcenode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null
UNION
--watercourse ending point
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Fim do Curso Dagua'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea > 0
UNION
--foz
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Foz Maritima'::text as deponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
INNER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea = 0
UNION
--Shoreline ending point
SELECT
drp.drp_pk,
drp.drp_pk as idponto,
wtc.wtc_cd_pfafstetterwatercourse as cocursodag,
'Fim da Linha de Costa'::text as dsponto,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
drp.drp_gm
FROM pghydro.pghft_drainage_point drp
INNER JOIN pghydro.pghft_drainage_line drn ON drn.drn_drp_pk_targetnode = drp.drp_pk
FULL OUTER JOIN pghydro.pghft_watercourse wtc ON drn.drn_wtc_pk = wtc.wtc_pk
WHERE drp.drp_nu_valence = 1
AND wtc.wtc_cd_pfafstetterwatercourse is null;

--VIEW pghydro.BHO_HIDRONIMO

DROP VIEW IF EXISTS pghydro.BHO_HIDRONIMO;

CREATE OR REPLACE VIEW pghydro.BHO_HIDRONIMO AS
SELECT
hdr.hdr_pk as idrio,
hdr.hdr_cd as corio,
tnc.tnc_ds as noriocomp,
hdr.hdr_nu_distancetosea as nudistbacr,
hdr.hdr_gm_length as nucomprio,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
hdr.hdr_gm
FROM pghydro.pghtb_type_name_complete tnc, pghydro.pghft_hydronym hdr
WHERE hdr.hdr_tnc_pk = tnc.tnc_pk;

--VIEW pghydro.BHO_BARRAGEM

DROP VIEW IF EXISTS pghydro.BHO_BARRAGEM;

CREATE OR REPLACE VIEW pghydro.BHO_BARRAGEM as
SELECT
dam.dam_pk as cobar,
dam.dam_nm as nobar,
dam.dam_drn_pk as cotrecho,
dam.dam_wtm_pk as comassadag,
dam.dam_nu_flow_out as nuvazaodef,
dam.dam_snb_pk as snisb,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
dam.dam_gm_original as dam_gm
FROM pghydro.pghft_dam dam;

--VIEW pghydro.BHO_MASSA_DAGUA

DROP VIEW IF EXISTS pghydro.BHO_MASSA_DAGUA;

CREATE OR REPLACE VIEW pghydro.BHO_MASSA_DAGUA AS 
SELECT
wtm.wtm_pk AS comassadag,
wtm.wtm_nm AS nooriginal,
wtm.wtm_nm_alternative AS noalternat,
wtm.wtm_ds_owner AS noprop,
wtm.wtm_ds_domain AS dedominio,
wtm.wtm_ds_source AS defonte,
wtm.wtm_ds_remote_sensing AS desatelite,
wtm.wtm_ds_flow_source AS defontevaz,
wtm.wtm_ds_surveillance AS defiscaliz,
wtm.wtm_ds_observation AS deobs,
wtm.wtm_nu_flow_regulated AS nuvazaoreg,
wtm.wtm_gm_perimeter AS nuperimet,
wtm.wtm_gm_area AS nuareakm2,
wtm.wtm_gm_area_m2 AS nuaream2,
wtm.wtm_gm_area_ha AS nuareaha,
wtm.wtm_gm_volume AS nuvolumkm3,
twm.twm_ds AS detipomass,
trs.trs_ds AS detiporese,
top.top_ds AS detipooper,
'BHO '||current_database()||' de '||CURRENT_DATE::text as dsversao,
wtm.wtm_gm
FROM pghydro.pghft_water_mass wtm
FULL JOIN pghydro.pghtb_type_reservoir trs ON wtm.wtm_trs_pk = trs.trs_pk
FULL JOIN pghydro.pghtb_type_water_mass twm ON wtm.wtm_twm_pk = twm.twm_pk
FULL JOIN pghydro.pghtb_type_water_mass_operation top ON wtm.wtm_top_pk = top.top_pk;

--VIEW pghydro.BHO_LINHA_COSTA

DROP VIEW IF EXISTS pghydro.BHO_LINHA_COSTA;

CREATE OR REPLACE VIEW pghydro.BHO_LINHA_COSTA AS 
SELECT
sho.sho_pk AS colinhacosta,
sho.sho_nm AS nooriginal,
sho.sho_gm
FROM pghydro.pghft_shoreline sho;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropExportViews()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DropExportViews()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP VIEW IF EXISTS pghydro.bho_cursodagua;

DROP VIEW IF EXISTS pghydro.bho_areacontribuicao;

DROP VIEW IF EXISTS pghydro.bho_pontodrenagem;

DROP VIEW IF EXISTS pghydro.bho_hidronimo;

DROP VIEW IF EXISTS pghydro.bho_trechodrenagem;

DROP VIEW IF EXISTS pghydro.bho_linha_costa;

DROP VIEW IF EXISTS pghydro.bho_barragem;

DROP VIEW IF EXISTS pghydro.bho_massa_dagua;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_TurnOffKeysIndex()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_TurnOffKeysIndex()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

--DROP EXPORT VIEWS

PERFORM pghydro.pghfn_DropExportViews();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

--DROP GEOMETRY INDEX

PERFORM pghydro.pghfn_DropGeometryIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--DROP INDEX

PERFORM pghydro.pghfn_DropIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

--DROP FOREIGN KEYS

PERFORM pghydro.pghfn_DropForeignKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

--DROP PRIMARY KEYS

PERFORM pghydro.pghfn_DropPrimaryKeys();

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_TurnOnKeysIndex()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_TurnOnKeysIndex()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

PERFORM pghydro.pghfn_TurnOffKeysIndex();

UPDATE pghydro.pghft_drainage_line
SET drn_wtc_pk = null
WHERE drn_wtc_pk = 0;

UPDATE pghydro.pghft_drainage_line
SET drn_rcl_pk_wtc = null
WHERE drn_rcl_pk_wtc = 0;

UPDATE pghydro.pghft_drainage_line
SET drn_hdr_pk = null
WHERE drn_hdr_pk = 0;

UPDATE pghydro.pghft_drainage_line
SET drn_rcl_pk_hdr = null
WHERE drn_rcl_pk_hdr = 0;

UPDATE pghydro.pghft_drainage_line
SET drn_wmb_pk = null
WHERE drn_wmb_pk = 0;

UPDATE pghydro.pghft_drainage_line
SET drn_rcl_pk_wmb = null
WHERE drn_rcl_pk_wmb = 0;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

--ADD PRIMARY KEYS

PERFORM pghydro.pghfn_AddPrimaryKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--ADD FOREIGN KEYS

PERFORM pghydro.pghfn_AddForeignKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

--ADD GEOMETRY INDEX

PERFORM pghydro.pghfn_CreateGeometryIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

--ADD INDEX

PERFORM pghydro.pghfn_CreateIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_input_data_drainage_line(name varchar)
----------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_input_data_drainage_line(name varchar)
RETURNS varchar AS
$$
DECLARE

_srid integer;
time_ timestamp;

BEGIN

BEGIN

--UPDATE CONSTRAINTS THAT SET 'srid' AT GEOMETRY COLUMN IN EACH GEOMETRY TABLE

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

PERFORM pghydro.pghfn_TurnOffKeysIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

PERFORM pghydro.pghfn_dropconsistencyviews();
    
time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

SELECT srid INTO _srid
FROM geometry_columns
WHERE f_table_name = 'input_drainage_line'
AND f_table_schema = 'public';

PERFORM UpdateGeometrySRID('pghydro', 'pghft_hydro_intel', 'hin_gm_point', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_hydro_intel', 'hin_gm_line', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_hydro_intel', 'hin_gm_polygon', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_dam', 'dam_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_dam', 'dam_gm_original', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_water_mass', 'wtm_gm_point', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_watercourse_ending_point', 'wep_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_drainage_point', 'drp_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_drainage_line', 'drn_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_monitoring_point', 'mnp_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_monitoring_point', 'mnp_gm_original', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_drainage_area', 'dra_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_hydronym', 'hdr_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_shoreline_ending_point', 'sep_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_shoreline_starting_point', 'ssp_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_stream_mouth', 'stm_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_water_mass', 'wtm_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_water_mass_boundary', 'wmb_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_watercourse', 'wtc_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_watercourse_starting_point', 'wsp_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_watershed', 'wts_gm', _srid);

PERFORM UpdateGeometrySRID('pghydro', 'pghft_shoreline', 'sho_gm', _srid);

--UPDATE geometry_columns
--SET srid = _srid
--WHERE f_table_name like 'pghydro.pghvw%';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--DELETE DATA ON TABLES RELATED TO pghydro.pghft_drainage_line

TRUNCATE pghydro.pghft_drainage_line;

TRUNCATE pghydro.pghft_drainage_point;

TRUNCATE pghydro.pghft_shoreline_starting_point;

TRUNCATE pghydro.pghft_shoreline_ending_point;

TRUNCATE pghydro.pghft_stream_mouth;

TRUNCATE pghydro.pghft_watercourse;

TRUNCATE pghydro.pghft_watercourse_starting_point;

TRUNCATE pghydro.pghft_watercourse_ending_point;

TRUNCATE pghydro.pghft_hydronym;

TRUNCATE pghydro.pghtb_type_name_complete;

TRUNCATE pghydro.pghtb_type_name_generic;

TRUNCATE pghydro.pghtb_type_name_connection;

TRUNCATE pghydro.pghtb_type_name_specific;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

PERFORM pg_catalog.setval('pghydro.drn_pk_seq', 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

--INSERT THE NAME OF THE FIELD WITH THE RIVER NAME IN input_drainage_line

IF name = 'none' THEN

EXECUTE '
INSERT INTO pghydro.pghft_drainage_line (drn_pk, drn_gm)
SELECT gid, the_geom
FROM input_drainage_line;
';

ELSE

EXECUTE '
INSERT INTO pghydro.pghft_drainage_line (drn_pk, drn_nm, drn_gm)
SELECT gid, '||name||', the_geom
FROM input_drainage_line;
';

END IF;

--'name' - column with the name of the drainage

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

PERFORM setval(('pghydro.drn_pk_seq'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(drn_pk)+1 as nextval
FROM pghydro.pghft_drainage_line
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

PERFORM DROPGEOMETRYTABLE ('input_drainage_line');

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

PERFORM pghydro.pghfn_createconsistencyviews();

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    
  
END;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

--------------------------------------------------
--FUNCTION pghydro.pghfn_input_data_drainage_area()
--------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_input_data_drainage_area()
RETURNS varchar AS
$$
DECLARE

_srid integer;
time_ timestamp;

BEGIN

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

PERFORM pghydro.pghfn_TurnOffKeysIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

PERFORM pghydro.pghfn_dropconsistencyviews();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--DELETE DATA ON TABLES RELATED TO pghydro.pghft_drainage_area

TRUNCATE pghydro.pghft_drainage_area;

TRUNCATE pghydro.pghft_watershed;

RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

PERFORM pg_catalog.setval('pghydro.dra_pk_seq', 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

--INSERT DATA INTO TABLE pghydro.pghft_drainage_area

INSERT INTO pghydro.pghft_drainage_area (dra_pk, dra_gm)
SELECT gid, the_geom
FROM input_drainage_area;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

PERFORM setval(('pghydro.dra_pk_seq'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(dra_pk)+1 as nextval
FROM pghydro.pghft_drainage_area
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

--DROP INPUT DATA

PERFORM DROPGEOMETRYTABLE ('input_drainage_area');

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

PERFORM pghydro.pghfn_createconsistencyviews();

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

--END OF FUNCTION
  
END;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsNotSingle()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsNotSingle()
RETURNS SETOF integer AS
$$
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE ST_NumGeometries(drn_gm) > 1;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineIsNotSingle()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineIsNotSingle()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineIsNotSingle() as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsNotSingleN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsNotSingleN(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DrainageLineIsNotSingle() as drn_pk
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-----------------------------------------
--FUNCTION pghydro.pghfn_ExplodeDrainageLine()
-----------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ExplodeDrainageLine()
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
AS SELECT drn_gm 
FROM
(
SELECT (ST_Dump(drn_gm)).geom AS drn_gm
FROM
(
SELECT drn_gm
FROM pghydro.pghft_drainage_line
WHERE ST_NumGeometries(drn_gm) >1
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
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE ST_NumGeometries(drn_gm) >1
) as b
);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

INSERT INTO pghydro.pghft_drainage_line (drn_pk, drn_gm)
SELECT drn_pk, ST_Multi(drn_gm)
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
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsNotSimple()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsNotSimple()
RETURNS SETOF integer AS
$$
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE ST_IsSimple(drn_gm) <> 't';
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineIsNotSimple()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineIsNotSimple()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineIsNotSimple() as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsNotSimpleN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsNotSimpleN(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DrainageLineIsNotSimple() as drn_pk
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsNotValid()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsNotValid()
RETURNS SETOF integer AS
$$
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE ST_IsValidReason(drn_gm) <> 'Valid Geometry';
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineIsNotValid()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineIsNotValid()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineIsNotValid() as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsNotValidN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsNotValidN(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DrainageLineIsNotValid() as drn_pk
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineHaveSelfIntersection()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineHaveSelfIntersection()
RETURNS SETOF integer AS
$$
SELECT drn_pk
FROM
(
SELECT a.drn_pk as drn_pk, b.drn_pk as drn_pk_b, a.drn_gm as drn_gm
FROM pghydro.pghft_drainage_line AS a, pghydro.pghft_drainage_line AS b
WHERE (a.drn_gm && b.drn_gm)
AND ST_Intersects(a.drn_gm,b.drn_gm)
AND NOT ST_touches(a.drn_gm,b.drn_gm)
AND a.drn_pk != b.drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;


----------------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineHaveSelfIntersection()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineHaveSelfIntersection()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineHaveSelfIntersection() as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

--------------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineHaveSelfIntersectionN(integer)
--------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineHaveSelfIntersectionN(integer)
RETURNS SETOF integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DrainageLineHaveSelfIntersection() as drn_pk
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineLoops()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineLoops()
RETURNS SETOF integer AS
$$
SELECT (ROW_NUMBER() OVER ())::integer AS plg_pk
FROM
(
SELECT drn_pk, (ST_Dump(b.plg_gm)).geom as clp_gm
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
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineLoops()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineLoops()
RETURNS bigint AS
$$
SELECT count(plg_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineLoops() as plg_pk
) as c;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineLoopsN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineLoopsN(integer)
RETURNS integer AS
$$
SELECT plg_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS plg_pk
FROM
(
SELECT drn_pk, (ST_Dump(b.plg_gm)).geom as clp_gm
FROM
(
SELECT max(drn_pk) as drn_pk, ST_Polygonize(drn_gm) as plg_gm
FROM
(
SELECT drn_pk, (st_dump(drn_gm)).geom AS drn_gm
FROM pghydro.pghft_drainage_line
) as a
) as b
) as c
) as d
WHERE plg_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

--------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_point_to_id( p geometry, tolerance double precision)
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- This function should not be used directly. Use 'pghydro.pghfn_assign_vertex_id'
-- 
-- Inserts a point into a temporary vertices table, and return an id
--  of a new point or an existing point. Tolerance is the minimal distance
--  between existing points and the new point to create a new point.
--
-- Last changes: 31.07.2013
-- Author: Christian Gonzalez modified by Alexandre de Amorim Teixeira
--------------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_point_to_id(p geometry, tolerance double precision)
RETURNS bigint AS
$$
DECLARE
    _r record; 
    _id bigint; 
    _srid integer;

BEGIN
    _srid := Find_SRID('pghydro', 'pghydro.pghft_drainage_point', 'drp_gm');

    FOR _r IN SELECT distance(drp_gm, GeometryFromText((AsText( p )),_srid)) as d, drp_pk as id
              FROM pghydro.pghft_drainage_point
              WHERE distance(drp_gm, GeometryFromText((AsText( p )), _srid)) < tolerance
              AND drp_gm && Expand(GeometryFromText(( AsText( p ) ), _srid), tolerance) ORDER BY d LIMIT 1
    LOOP
    RETURN _r.id;
    END LOOP;
    
    INSERT INTO pghydro.pghft_drainage_point(drp_gm) VALUES (GeometryFromText((AsText(SetSRID( p , _srid))),_srid));
    _id:=lastval();          
    RETURN _id;
END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-----------------------------------------------------------------------
--FUNCTION pghydro.pghfn_assign_vertex_id(tolerance double precision)
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Fill the source and target_id column for all lines. All line ends
--  with a distance less than tolerance, are assigned the same id
--
-- Last changes: 31.07.2013
-- Author: Christian Gonzalez modified by Alexandre de Amorim Teixeira
-----------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_assign_vertex_id(tolerance double precision)
RETURNS character varying AS
$$
DECLARE
_r record;
source_id int;
target_id int;
srid_ integer;
time_ timestamp;

BEGIN

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    
    
UPDATE pghydro.pghft_drainage_line SET drn_drp_pk_sourcenode = NULL, drn_drp_pk_targetnode = NULL, drn_rcl_pk_drp_sourcenode = 15, drn_rcl_pk_drp_targetnode = 15;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

TRUNCATE pghydro.pghft_drainage_point;

TRUNCATE pghydro.pghft_shoreline_starting_point;

TRUNCATE pghydro.pghft_shoreline_ending_point;

TRUNCATE pghydro.pghft_stream_mouth;

TRUNCATE pghydro.pghft_watercourse_starting_point;

TRUNCATE pghydro.pghft_watercourse_ending_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

ALTER SEQUENCE pghydro.drp_pk_seq RESTART WITH 1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    


    EXCEPTION 
              WHEN UNDEFINED_TABLE THEN
              WHEN UNDEFINED_COLUMN THEN
    END;
   
    FOR _r IN SELECT srid
              FROM geometry_columns
              WHERE f_table_name = 'pghft_drainage_line'
              AND f_table_schema = 'pghydro'
    LOOP
	    srid_ := _r.srid;
    END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING GIST(drp_gm);

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    
			
    FOR _r IN SELECT drn_pk AS id, ST_StartPoint(drn_gm) AS source, ST_EndPoint(drn_gm) as target
	      FROM  pghydro.pghft_drainage_line 
    LOOP
        
        source_id := pghydro.pghfn_point_to_id(setsrid(_r.source, srid_), tolerance);
        target_id := pghydro.pghfn_point_to_id(setsrid(_r.target, srid_), tolerance);
								
	UPDATE pghydro.pghft_drainage_line 
	SET drn_drp_pk_sourcenode = source_id, drn_drp_pk_targetnode = target_id 
	WHERE drn_pk = _r.id;

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

--------------------------------------------
--FUNCTION pghydro.pghfn_assign_vertex_id()
--------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_assign_vertex_id()
RETURNS character varying AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DELETE FROM pghydro.pghft_drainage_line
WHERE ST_length(ST_SnapToGrid(drn_gm, 0.00000000001)) = 0
OR drn_gm is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;
    
UPDATE pghydro.pghft_drainage_line SET drn_drp_pk_sourcenode = NULL, drn_drp_pk_targetnode = NULL, drn_rcl_pk_drp_sourcenode = 15, drn_rcl_pk_drp_targetnode = 15;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

TRUNCATE pghydro.pghft_drainage_point;

TRUNCATE pghydro.pghft_shoreline_starting_point;

TRUNCATE pghydro.pghft_shoreline_ending_point;

TRUNCATE pghydro.pghft_stream_mouth;

TRUNCATE pghydro.pghft_watercourse_starting_point;

TRUNCATE pghydro.pghft_watercourse_ending_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

PERFORM addgeometrycolumn('pghydro', 'pghft_drainage_line', 'drn_gm_startpoint',
(
SELECT srid FROM geometry_columns
WHERE f_table_name = 'pghft_drainage_area'
AND f_table_schema = 'pghydro'
)
, 'POINT', 2);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

PERFORM addgeometrycolumn('pghydro', 'pghft_drainage_line', 'drn_gm_endpoint',
(
SELECT srid FROM geometry_columns
WHERE f_table_name = 'pghft_drainage_area'
AND f_table_schema = 'pghydro'
)
, 'POINT', 2);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

UPDATE pghydro.pghft_drainage_line a
SET drn_gm_startpoint = ST_StartPoint((ST_Dump(drn_gm)).geom);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

UPDATE pghydro.pghft_drainage_line a
SET drn_gm_endpoint = ST_EndPoint((ST_Dump(drn_gm)).geom);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_gm_startpoint_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_endpoint_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

CREATE INDEX drn_gm_startpoint_idx ON pghydro.pghft_drainage_line USING gist (drn_gm_startpoint);

CREATE INDEX drn_gm_endpoint_idx ON pghydro.pghft_drainage_line USING gist (drn_gm_endpoint);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

ALTER SEQUENCE pghydro.drp_pk_seq RESTART WITH 1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

INSERT INTO pghydro.pghft_drainage_point (drp_pk, drp_gm)
SELECT row_number() OVER ()::integer AS drp_pk, drp_gm
FROM
(
SELECT DISTINCT ON (drp_gm) drp_gm
FROM
(
SELECT DISTINCT ON (drn_gm_startpoint) drn_gm_startpoint as drp_gm FROM pghydro.pghft_drainage_line
UNION
SELECT DISTINCT ON (drn_gm_endpoint) drn_gm_endpoint as drp_gm FROM pghydro.pghft_drainage_line
) as a
) as b;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drp_gm_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;    

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

CREATE INDEX drp_gm_idx ON pghydro.pghft_drainage_point USING gist (drp_gm);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;    

UPDATE pghydro.pghft_drainage_line drn
SET drn_drp_pk_sourcenode = drp.drp_pk
FROM pghydro.pghft_drainage_point drp
WHERE ST_Intersects(drp.drp_gm, drn.drn_gm_startpoint)
AND (drp.drp_gm && drn.drn_gm_startpoint);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;    

UPDATE pghydro.pghft_drainage_line drn
SET drn_drp_pk_targetnode = drp.drp_pk
FROM pghydro.pghft_drainage_point drp
WHERE ST_Intersects(drp.drp_gm, drn.drn_gm_endpoint)
AND (drp.drp_gm && drn.drn_gm_endpoint);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;    

--DELETE FROM geometry_columns
--WHERE f_geometry_column = 'drn_gm_startpoint';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;    

--DELETE FROM geometry_columns
--WHERE f_geometry_column = 'drn_gm_endpoint';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;    

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN drn_gm_startpoint;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 19 : %', time_;    

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN drn_gm_endpoint;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 20 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drp_gm_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-----------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateValence()
-----------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateValence()
RETURNS varchar AS
$$
DECLARE
subQuerySource varchar;
subQueryTarget varchar;
unionNode varchar;
finalQuery varchar;
_r record;
time_ timestamp;
       
BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    


    subQuerySource := 'SELECT drp_pk as id, count(drn_drp_pk_sourcenode) as qt FROM pghydro.pghft_drainage_point INNER JOIN pghydro.pghft_drainage_line ON drp_pk = drn_drp_pk_sourcenode GROUP BY drp_pk';

    subQueryTarget := 'SELECT drp_pk as id, count(drn_drp_pk_targetnode) as qt FROM pghydro.pghft_drainage_point INNER JOIN pghydro.pghft_drainage_line ON drp_pk = drn_drp_pk_targetnode GROUP BY drp_pk';
        
    unionNode := 'SELECT id, Sum(UNION_NODE.qt) as valence FROM (' || subQuerySource || ' UNION ALL ' || subQueryTarget ||') as UNION_NODE GROUP BY id';
        
    finalQuery := 'SELECT NODE_FINAL.id as node_id, NODE_FINAL.valence FROM ('|| unionNode || ') as NODE_FINAL INNER JOIN pghydro.pghft_drainage_point ON NODE_FINAL.id = drp_pk';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

    FOR _r IN EXECUTE finalQuery LOOP
    
        UPDATE pghydro.pghft_drainage_point SET drp_nu_valence = _r.valence WHERE drp_pk = _r.node_id;
        
    END LOOP;        

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';
     
END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

------------------------------------
--FUNCTION pghydro.pghfn_Valence(integer)
------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_valence(integer)
RETURNS bigint AS
$$
SELECT count(drp_pk) as valence
FROM
(
SELECT drn_drp_pk_targetnode as drp_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_targetnode = $1
UNION ALL
SELECT drn_drp_pk_sourcenode as drp_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_sourcenode = $1
) as a;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_PointValenceValue2()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PointValenceValue2()
RETURNS SETOF integer AS
$$
SELECT drp_pk
FROM pghydro.pghft_drainage_point
WHERE drp_nu_valence = 2;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_numPointValenceValue2()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numPointValenceValue2()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM 
(
SELECT pghydro.pghfn_PointValenceValue2() as drp_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_PointValenceValue2N(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PointValenceValue2N(integer)
RETURNS integer AS
$$
SELECT drp_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drp_pk, drp_pk
FROM
(
SELECT pghydro.pghfn_PointValenceValue2() as drp_pk
) as a
) as b
WHERE seq_drp_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_unionDrainageLine(integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_unionDrainageLine(integer)
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
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_unionDrainageLine(integer, integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_unionDrainageLine(integer, integer)
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
--COMMIT;

-----------------------------------------------
--FUNCTION pghydro.pghfn_unionDrainageLinevalence2()
-----------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_unionDrainageLinevalence2()
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

	PERFORM pghydro.pghfn_unionDrainageLine(_r.drp_pk);
   
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
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_PointValenceValue4()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PointValenceValue4()
RETURNS SETOF integer AS
$$
SELECT drp_pk
FROM pghydro.pghft_drainage_point
WHERE drp_nu_valence >= 4;
$$
LANGUAGE SQL;
--COMMIT;


----------------------------------------------------------
--FUNCTION pghydro.pghfn_numPointValenceValue4()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numPointValenceValue4()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM 
(
SELECT pghydro.pghfn_PointValenceValue4() as drp_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_PointValenceValue4N(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PointValenceValue4N(integer)
RETURNS integer AS
$$
SELECT drp_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drp_pk, drp_pk
FROM
(
SELECT pghydro.pghfn_PointValenceValue4() as drp_pk
) as a
) as b
WHERE seq_drp_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateShorelineStartingPoint(integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateShorelineStartingPoint(integer)
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DELETE FROM pghydro.pghft_shoreline_starting_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

INSERT INTO pghydro.pghft_shoreline_starting_point (ssp_pk, ssp_drp_pk, ssp_rcl_pk_drp, ssp_rcl_pk_drn, ssp_sho_pk, ssp_rcl_pk_sho, ssp_gm)
SELECT drp_pk, drp_pk, 9, 15, 1, 15, drp_gm
FROM pghydro.pghft_drainage_point
WHERE drp_pk = $1; ---shoreline starting point

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

UPDATE pghydro.pghft_shoreline_starting_point a
SET ssp_drn_pk = b.drn_pk
FROM pghydro.pghft_drainage_line b
WHERE b.drn_drp_pk_targetnode = $1
OR b.drn_drp_pk_sourcenode = $1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateShorelineEndingPoint(integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateShorelineEndingPoint(integer)
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DELETE
FROM pghydro.pghft_shoreline_ending_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

INSERT INTO pghydro.pghft_shoreline_ending_point (sep_pk, sep_drp_pk, sep_rcl_pk_drp, sep_rcl_pk_drn, sep_sho_pk, sep_rcl_pk_sho, sep_gm)
SELECT drp_pk, drp_pk, 9, 15, 1, 15, drp_gm
FROM pghydro.pghft_drainage_point
WHERE drp_pk = $1; ---shoreline ending point

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

UPDATE pghydro.pghft_shoreline_ending_point a
SET sep_drn_pk = b.drn_pk
FROM pghydro.pghft_drainage_line b
WHERE b.drn_drp_pk_targetnode = $1
OR b.drn_drp_pk_sourcenode = $1;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    
 
RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateFlowDirection()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateFlowDirection()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;    

DROP TABLE IF EXISTS pghydro.pghtb_tmp_direction;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

CREATE TABLE pghydro.pghtb_tmp_direction (id_tmp serial, id_table_net_tmp integer, target_table_net_tmp integer, source_table_net_tmp integer, direction_table_net_tmp boolean);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

INSERT INTO pghydro.pghtb_tmp_direction (id_table_net_tmp, target_table_net_tmp, source_table_net_tmp, direction_table_net_tmp)
SELECT * FROM (
WITH RECURSIVE tmp_direction(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_bo_flowdirection) AS (
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, (CASE WHEN drn_drp_pk_sourcenode = (SELECT sep_pk FROM pghydro.pghft_shoreline_ending_point) THEN false ELSE true END)
	FROM pghydro.pghft_drainage_line
	WHERE drn_drp_pk_sourcenode = (SELECT sep_pk FROM pghydro.pghft_shoreline_ending_point) ---shoreline ending point 
	OR drn_drp_pk_targetnode = (SELECT sep_pk FROM pghydro.pghft_shoreline_ending_point) ---shoreline ending point
UNION
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode, s
	FROM (
SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, false as s
FROM pghydro.pghft_drainage_line
UNION ALL
SELECT drn_pk, drn_drp_pk_sourcenode, drn_drp_pk_targetnode, true as s
FROM pghydro.pghft_drainage_line
) as a, tmp_direction c
	WHERE a.drn_drp_pk_sourcenode = c.drn_drp_pk_targetnode
)
SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_bo_flowdirection
FROM tmp_direction
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

UPDATE pghydro.pghft_drainage_line
SET drn_bo_flowdirection = null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

CREATE INDEX id_table_net_tmp_idx ON pghydro.pghtb_tmp_direction(id_table_net_tmp);

CREATE INDEX id_tmp_idx ON pghydro.pghtb_tmp_direction(id_tmp);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;--can be better!    

UPDATE pghydro.pghft_drainage_line drn
SET drn_bo_flowdirection = direction_table_net_tmp
FROM (
SELECT id_table_net_tmp, direction_table_net_tmp FROM pghydro.pghtb_tmp_direction a, (SELECT id_table_net_tmp as min_id_table_net_tmp, min(id_tmp) as min_id_tmp
FROM pghydro.pghtb_tmp_direction 
GROUP BY min_id_table_net_tmp) as b
WHERE a.id_tmp = b.min_id_tmp
) as d
WHERE d.id_table_net_tmp = drn.drn_pk; 

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP INDEX IF EXISTS pghydro.id_table_net_tmp_idx;

DROP INDEX IF EXISTS pghydro.id_tmp_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

DROP TABLE IF EXISTS pghydro.pghtb_tmp_direction;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_ReverseDrainageLine()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ReverseDrainageLine()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

UPDATE pghydro.pghft_drainage_line
SET drn_gm = ST_Reverse(drn_gm)
WHERE drn_bo_flowdirection = false;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

DROP TABLE IF EXISTS direction_temp;

CREATE TABLE direction_temp as
SELECT drn_pk, drn_drp_pk_sourcenode, drn_drp_pk_targetnode
FROM pghydro.pghft_drainage_line
WHERE drn_bo_flowdirection = false;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

DROP INDEX IF EXISTS pghydro.drn_pk_temp_idx;    

CREATE INDEX drn_pk_temp_idx ON direction_temp(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

UPDATE pghydro.pghft_drainage_line a
SET drn_drp_pk_sourcenode = b.drn_drp_pk_targetnode, drn_drp_pk_targetnode = b.drn_drp_pk_sourcenode, drn_bo_flowdirection = true
FROM direction_temp b
WHERE a.drn_pk = b.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_pk_temp_idx;    

DROP TABLE direction_temp;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_FlowDirection(integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_FlowDirection(integer)
RETURNS boolean AS
$$
SELECT drn_bo_flowdirection
FROM pghydro.pghft_drainage_line
WHERE drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsDisconnected()
-------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsDisconnected()
RETURNS SETOF integer AS
$$
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_bo_flowdirection is null;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineIsDisconnected()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineIsDisconnected()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM pghydro.pghft_drainage_line
WHERE drn_bo_flowdirection is null;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineIsDisconnectedN()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineIsDisconnectedN(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_bo_flowdirection is null
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------
--FUNCTION pghydro.pghfn_PointDivergent()
-------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PointDivergent()
RETURNS SETOF integer AS
$$
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
WHERE c.sep_drp_pk <> b.drn_drp_pk_targetnode;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_numPointDivergent()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numPointDivergent()
RETURNS bigint AS
$$
SELECT count(drp_pk)
FROM pghydro.pghfn_PointDivergent() as drp_pk;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_PointDivergentN()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PointDivergentN(integer)
RETURNS integer AS
$$
SELECT drp_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drp_pk, drp_pk
FROM
(
SELECT pghydro.pghfn_PointDivergent() as drp_pk
) as a
) as b
WHERE seq_drp_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;
---------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaIsNotSingle()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaIsNotSingle()
RETURNS SETOF integer AS
$$
SELECT dra_pk
FROM pghydro.pghft_drainage_area
WHERE ST_NumGeometries(dra_gm) > 1;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaIsNotSingle()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaIsNotSingle()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaIsNotSingle() as dra_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaIsNotSingleN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaIsNotSingleN(integer)
RETURNS integer AS
$$
SELECT dra_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_pk, dra_pk
FROM
(
SELECT pghydro.pghfn_DrainageAreaIsNotSingle() as dra_pk
) as a
) as b
WHERE seq_dra_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_ExplodeDrainageArea()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ExplodeDrainageArea()
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
SELECT dra_gm
FROM pghydro.pghft_drainage_area
WHERE ST_NumGeometries(dra_gm) >1
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
SELECT dra_pk
FROM pghydro.pghft_drainage_area
WHERE ST_NumGeometries(dra_gm) >1
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
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaIsNotSimple()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaIsNotSimple()
RETURNS SETOF integer AS
$$
SELECT dra_pk
FROM pghydro.pghft_drainage_area
WHERE ST_IsSimple(dra_gm) <> 't';
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaIsNotSimple()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaIsNotSimple()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaIsNotSimple() as dra_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaIsNotSimpleN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaIsNotSimpleN(integer)
RETURNS integer AS
$$
SELECT dra_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_pk, dra_pk
FROM
(
SELECT pghydro.pghfn_DrainageAreaIsNotSimple() as dra_pk
) as a
) as b
WHERE seq_dra_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

---------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaIsNotValid()
---------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaIsNotValid()
RETURNS SETOF integer AS
$$
SELECT dra_pk
FROM pghydro.pghft_drainage_area
WHERE ST_IsValidReason(dra_gm) <> 'Valid Geometry';
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaIsNotValid()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaIsNotValid()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaIsNotValid() as dra_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaIsNotValidN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaIsNotValidN(integer)
RETURNS integer AS
$$
SELECT dra_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_pk, dra_pk
FROM
(
SELECT dra_pk
FROM pghydro.pghft_drainage_area
WHERE ST_IsValidReason(dra_gm) <> 'Valid Geometry'
) as a
) as b
WHERE seq_dra_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaHaveSelfIntersection()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaHaveSelfIntersection()
RETURNS SETOF integer AS
$$
SELECT int_pk
FROM
(
SELECT (ROW_NUMBER() OVER (ORDER BY dra_pk ASC))::integer AS int_pk
FROM
(
SELECT dra_pk
FROM
(
SELECT a.dra_pk, b.dra_pk as dra_pk_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as dra_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_Relate(a.dra_gm, b.dra_gm) in ('212111212','212101212')
AND a.dra_pk < b.dra_pk
) as c
WHERE st_geometrytype(dra_gm) = 'ST_MultiPolygon'
) as a
) as b;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaHaveSelfIntersection()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaHaveSelfIntersection()
RETURNS bigint AS
$$
SELECT count(int_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaHaveSelfIntersection() as int_pk
) as b;
$$
LANGUAGE SQL;
--COMMIT;

--------------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaHaveSelfIntersectionN(integer)
--------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaHaveSelfIntersectionN(integer)
RETURNS integer AS
$$
SELECT int_pk
FROM
(
SELECT (ROW_NUMBER() OVER (ORDER BY dra_pk ASC))::integer AS int_pk
FROM
(
SELECT dra_pk
FROM
(
SELECT a.dra_pk, b.dra_pk as dra_pk_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as dra_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_Relate(a.dra_gm, b.dra_gm) in ('212111212','212101212')
AND a.dra_pk < b.dra_pk
) as c
WHERE st_geometrytype(dra_gm) = 'ST_MultiPolygon'
) as a
) as b
WHERE int_pk = 1
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaHaveDuplication()
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaHaveDuplication()
RETURNS SETOF integer AS
$$
SELECT dra_pk
FROM
(
SELECT a.dra_pk, b.dra_pk as dra_pk_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as dra_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_Relate(a.dra_gm, b.dra_gm) = '2FFF1FFF2'
AND a.dra_pk < b.dra_pk
) as c
WHERE st_geometrytype(dra_gm) = 'ST_MultiPolygon';
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaHaveDuplication()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaHaveDuplication()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaHaveDuplication() as dra_pk
) as b;
$$
LANGUAGE SQL;
--COMMIT;

--------------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaHaveDuplicationN(integer)
--------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaHaveDuplicationN(integer)
RETURNS integer AS
$$
SELECT dra_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_pk, dra_pk
FROM
(
SELECT dra_pk
FROM
(
SELECT a.dra_pk, b.dra_pk as dra_pk_b, ST_Multi((ST_Dump(ST_Intersection(a.dra_gm, b.dra_gm))).geom) as dra_gm
FROM pghydro.pghft_drainage_area AS a, pghydro.pghft_drainage_area AS b
WHERE (a.dra_gm && b.dra_gm)
AND ST_Relate(a.dra_gm, b.dra_gm) = '2FFF1FFF2'
AND a.dra_pk < b.dra_pk
) as c
WHERE st_geometrytype(dra_gm) = 'ST_MultiPolygon'
) as a
) as b
WHERE seq_dra_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------------------------
--FUNCTION pghydro.pghfn_AssociateDrainageLine_DrainageArea()
------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_AssociateDrainageLine_DrainageArea()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF ALL PROCESS IN : %', time_;    

PERFORM addgeometrycolumn('pghydro','pghft_drainage_line', 'drn_gm_point',
(
SELECT srid FROM geometry_columns
WHERE f_table_name = 'pghft_drainage_line'
AND f_table_schema = 'pghydro'
)
, 'MULTIPOINT', 2);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_gm_idx;

UPDATE pghydro.pghft_drainage_line
SET drn_gm_point = ST_Multi((ST_Dump(ST_Line_Interpolate_Point((ST_Dump(drn_gm)).geom, 0.5))).geom);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_gm_point_idx;

CREATE INDEX drn_gm_point_idx ON pghydro.pghft_drainage_line USING gist (drn_gm_point);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP INDEX IF EXISTS pghydro.dra_gm_idx;

CREATE INDEX dra_gm_idx ON pghydro.pghft_drainage_area USING gist (dra_gm);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

TRUNCATE pghydro.pghft_hydro_intel;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

PERFORM setval(('pghydro.hin_pk_seq'::text)::regclass, 1);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

INSERT INTO pghydro.pghft_hydro_intel (hin_drn_pk)
SELECT drn_pk
FROM pghydro.pghft_drainage_line;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP INDEX IF EXISTS pghydro.hin_drn_pk_idx;

CREATE INDEX hin_drn_pk_idx ON pghydro.pghft_hydro_intel(hin_drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

UPDATE pghydro.pghft_hydro_intel hin
SET hin_dra_pk = b.dra_pk
FROM
(
SELECT dra_pk, drn_pk
FROM pghydro.pghft_drainage_area dra, pghydro.pghft_drainage_line drn 
WHERE ST_Intersects(drn.drn_gm_point, dra.dra_gm)
AND (drn.drn_gm_point && dra.dra_gm) 
) as b
WHERE b.drn_pk = hin.hin_drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

DROP INDEX IF EXISTS pghydro.hin_dra_pk_idx;

CREATE INDEX hin_dra_pk_idx ON pghydro.pghft_hydro_intel(hin_dra_pk);

INSERT INTO pghydro.pghft_hydro_intel (hin_dra_pk)
SELECT dra_pk
FROM pghydro.pghft_drainage_area a
WHERE NOT EXISTS
(
SELECT hin_dra_pk
FROM pghydro.pghft_hydro_intel b
WHERE b.hin_dra_pk = a.dra_pk
);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;    

UPDATE pghydro.pghft_hydro_intel a
SET hin_count_drn_pk = b.hin_count_drn_pk
FROM
(
SELECT hin_drn_pk, count(hin_drn_pk) as hin_count_drn_pk
FROM pghydro.pghft_hydro_intel
GROUP BY hin_drn_pk
) as b
WHERE a.hin_drn_pk = b.hin_drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;    

UPDATE pghydro.pghft_hydro_intel a
SET hin_count_dra_pk = b.hin_count_dra_pk
FROM
(
SELECT hin_dra_pk, count(hin_dra_pk) as hin_count_dra_pk
FROM pghydro.pghft_hydro_intel
GROUP BY hin_dra_pk
) as b
WHERE a.hin_dra_pk = b.hin_dra_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;    

PERFORM setval(('pghydro.drn_pk_seq'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(drn_pk)+1 as nextval
FROM pghydro.pghft_drainage_line
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;    

PERFORM setval(('pghydro.dra_pk_seq'::text)::regclass, a.nextval::bigint, false)
FROM
(
SELECT max(dra_pk)+1 as nextval
FROM pghydro.pghft_drainage_area
) as a;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;    

--DELETE FROM geometry_columns
--WHERE f_geometry_column = 'drn_gm_point';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;    

ALTER TABLE pghydro.pghft_drainage_line
DROP COLUMN drn_gm_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;    

UPDATE pghydro.pghft_drainage_line SET drn_dra_pk = null, drn_rcl_pk_dra = null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 19 : %', time_;    

UPDATE pghydro.pghft_drainage_line drn
SET drn_dra_pk = hin.hin_dra_pk, drn_rcl_pk_dra = 12
FROM pghydro.pghft_hydro_intel hin
WHERE drn.drn_pk = hin.hin_drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 20 : %', time_;    

DROP INDEX IF EXISTS pghydro.hin_drn_pk_idx;

DROP INDEX IF EXISTS pghydro.hin_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_gm_idx;

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaNoDrainageLine()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaNoDrainageLine()
RETURNS SETOF integer AS
$$
SELECT hin_dra_pk as dra_pk
FROM pghydro.pghft_hydro_intel
WHERE hin_drn_pk isnull;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaNoDrainageLine()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaNoDrainageLine()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaNoDrainageLine() as dra_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaNoDrainageLineN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaNoDrainageLineN(integer)
RETURNS integer AS
$$
SELECT dra_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_pk, dra_pk
FROM
(
SELECT pghydro.pghfn_DrainageAreaNoDrainageLine() as dra_pk
) as a
) as b
WHERE seq_dra_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineNoDrainageArea()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineNoDrainageArea()
RETURNS SETOF integer AS
$$
SELECT hin_drn_pk as drn_pk
FROM pghydro.pghft_hydro_intel
WHERE hin_dra_pk isnull;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineNoDrainageArea()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineNoDrainageArea()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineNoDrainageArea() as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineNoDrainageAreaN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineNoDrainageAreaN(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DrainageLineNoDrainageArea() as drn_pk
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaMoreOneDrainageLine()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaMoreOneDrainageLine()
RETURNS SETOF integer AS
$$
SELECT DISTINCT hin_dra_pk as dra_pk
FROM pghydro.pghft_hydro_intel
WHERE hin_count_dra_pk >=2;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageAreaMoreOneDrainageLine()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageAreaMoreOneDrainageLine()
RETURNS bigint AS
$$
SELECT count(dra_pk)
FROM
(
SELECT pghydro.pghfn_DrainageAreaMoreOneDrainageLine() as dra_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageAreaMoreOneDrainageLineN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageAreaMoreOneDrainageLineN(integer)
RETURNS integer AS
$$
SELECT dra_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_pk, dra_pk
FROM
(
SELECT pghydro.pghfn_DrainageAreaMoreOneDrainageLine() as dra_pk
) as a
) as b
WHERE seq_dra_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineMoreOneDrainageArea()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineMoreOneDrainageArea()
RETURNS SETOF integer AS
$$
SELECT DISTINCT hin_drn_pk as drn_pk
FROM pghydro.pghft_hydro_intel
WHERE hin_count_drn_pk >=2; 
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDrainageLineMoreOneDrainageArea()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDrainageLineMoreOneDrainageArea()
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DrainageLineMoreOneDrainageArea() as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DrainageLineMoreOneDrainageAreaN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DrainageLineMoreOneDrainageAreaN(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DrainageLineMoreOneDrainageArea() as drn_pk
) as a
) as b
WHERE seq_drn_pk = $1;
$$
LANGUAGE SQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_UnionDrainageArea(integer, integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UnionDrainageArea(integer, integer)
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
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_uniondrainageareanodrainageline()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_uniondrainageareanodrainageline()
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

SELECT INTO numdrainageareanodrainageline pghydro.pghfn_numdrainageareanodrainageline();

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
    FROM pghydro.pghft_drainage_area dra, (SELECT pghydro.pghfn_drainageareanodrainageline() as dra_pk) as a
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

	PERFORM pghydro.pghfn_UnionDrainageArea(_r.dra_pk, _r.dra_pk_touch);
   
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
--COMMIT;

------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDrainageLineLength(integer, integer)
------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateDrainageLineLength(integer, integer)
RETURNS character varying AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

UPDATE pghydro.pghft_drainage_line
SET drn_gm_length = ST_Length(ST_Transform(drn_gm, $1))/$2;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDrainageAreaArea(integer, integer)
-------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateDrainageAreaArea(integer, integer)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

UPDATE pghydro.pghft_drainage_area
SET dra_gm_area = ST_Area(ST_Transform(dra_gm, $1))/$2;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_Downstream_DrainageLines(integer)
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_Downstream_DrainageLines(integer)
RETURNS SETOF integer
AS $$
DECLARE

r record;

BEGIN

FOR r IN
WITH RECURSIVE downstream(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode) AS (
	SELECT b.drn_pk, b.drn_drp_pk_targetnode, b.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line b,
	(
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line
	WHERE drn_pk = $1
	) as d
	WHERE d.drn_drp_pk_targetnode = b.drn_drp_pk_sourcenode 
UNION ALL
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line a, downstream c
	WHERE a.drn_drp_pk_sourcenode = c.drn_drp_pk_targetnode
)
SELECT drn_pk
FROM downstream

LOOP

RETURN NEXT r.drn_pk;

END LOOP;

RETURN;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-------------------------------------------------------
--FUNCTION pghydro.pghfn_Downstream_DrainageLines(integer, integer)
-------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_Downstream_DrainageLines(integer, integer)
RETURNS SETOF integer
AS $$
DECLARE

var1 integer;

BEGIN

IF $1 <> $2 THEN

SELECT INTO var1 drn_drp_pk_targetnode FROM pghydro.pghft_drainage_line WHERE drn_pk = $2;

RETURN QUERY

WITH RECURSIVE downstream(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode) AS
(
	SELECT b.drn_pk, b.drn_drp_pk_targetnode, b.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line b,
	(
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line
	WHERE drn_pk = $1
	) as d
	WHERE d.drn_drp_pk_targetnode = b.drn_drp_pk_sourcenode 
UNION ALL
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line a, downstream c
	WHERE a.drn_drp_pk_sourcenode = c.drn_drp_pk_targetnode
	AND c.drn_drp_pk_targetnode <> var1
)
SELECT drn_pk
FROM downstream;

END IF;

RETURN;

END;

$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DownstreamDrainageLines(integer)
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DownstreamDrainageLines(integer)
RETURNS SETOF integer
AS $$
DECLARE
r record;
var1 integer;

BEGIN

SELECT INTO var1 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

FOR r IN
WITH RECURSIVE downstream(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode) AS (
	SELECT b.drn_pk, b.drn_drp_pk_targetnode, b.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line b,
	(
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line
	WHERE drn_pk = $1 --DrainageLine_target
	) as d
	WHERE d.drn_drp_pk_targetnode = b.drn_drp_pk_sourcenode 
UNION ALL
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line a, downstream c
	WHERE a.drn_drp_pk_sourcenode = c.drn_drp_pk_targetnode
)
SELECT b.drn_pk
FROM downstream b
WHERE NOT EXISTS
(
SELECT drn_pk
FROM
(
SELECT var1 as drn_pk --DrainageLine_source
UNION ALL
SELECT pghydro.pghfn_downstream_DrainageLines(var1) as drn_pk --DrainageLine_source
) as a
WHERE a.drn_pk = b.drn_pk  
)
LOOP

RETURN NEXT r.drn_pk;

END LOOP;

RETURN;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numDownstreamDrainageLines(integer)
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numDownstreamDrainageLines(integer)
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_DownstreamDrainageLines($1) as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DownstreamDrainageLinesN(integer, integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DownstreamDrainageLinesN(integer, integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT ROW_NUMBER() OVER() AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_DownstreamDrainageLines($1) as drn_pk --DrainageLine
) as a
) as b
WHERE seq_drn_pk = $2;--sequencial
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_distance_to_mouth(integer, numeric)
----------------------------------------------------------
--DROP FUNCTION pghydro.pghfn_distance_to_mouth(IN integer, OUT distance_to_mouth numeric)

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_distance_to_mouth(IN integer, OUT distance_to_mouth numeric)
AS $$
BEGIN
SELECT INTO distance_to_mouth COALESCE(sum(c.drn_gm_length),0)
FROM
(
SELECT b.drn_pk, a.drn_gm_length--::numeric
FROM pghydro.pghft_drainage_line a,
(
SELECT pghydro.pghfn_downstreamDrainageLines($1) as drn_pk
) as b
WHERE a.drn_pk = b.drn_pk
) as c;
END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLines(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_upstreamDrainageLines(integer)
RETURNS SETOF integer
AS $$
DECLARE
r record;
BEGIN
FOR r IN
WITH RECURSIVE upstream(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode) AS (
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line
	WHERE drn_pk = $1
UNION ALL
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line a, upstream c
	WHERE a.drn_drp_pk_targetnode = c.drn_drp_pk_sourcenode 
)
SELECT drn_pk
FROM upstream
LOOP
RETURN NEXT r.drn_pk;
END LOOP;
RETURN;
END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numUpstreamDrainageLines(integer)
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numUpstreamDrainageLines(integer)
RETURNS bigint AS
$$
SELECT count(drn_pk)
FROM
(
SELECT pghydro.pghfn_upstreamDrainageLines($1) as drn_pk
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLinesN(integer, integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpstreamDrainageLinesN(integer, integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM
(
SELECT ROW_NUMBER() OVER() AS seq_drn_pk, drn_pk
FROM
(
SELECT pghydro.pghfn_upstreamDrainageLines($1) as drn_pk --DrainageLine
) as a
) as b
WHERE seq_drn_pk = $2;--sequencial
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLines(integer, integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_upstreamDrainageLines(integer, integer)
RETURNS SETOF integer
AS $$
DECLARE

var1 integer;

BEGIN

SELECT INTO var1 drn_drp_pk_sourcenode FROM pghydro.pghft_drainage_line WHERE drn_pk = $2;

RETURN QUERY

WITH RECURSIVE upstream(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode) AS
(
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode
	FROM  pghydro.pghft_drainage_line
	WHERE drn_pk = $1
UNION ALL
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode
	FROM pghydro.pghft_drainage_line a, upstream c
	WHERE a.drn_drp_pk_targetnode = c.drn_drp_pk_sourcenode
	AND  c.drn_drp_pk_sourcenode <> var1
	
)
SELECT drn_pk
FROM upstream;

RETURN;

END;

$$
LANGUAGE plpgsql;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLinesArea(integer, numeric)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpstreamDrainageLinesArea(IN integer, OUT upstream_area numeric)
AS $$
BEGIN
SELECT INTO upstream_area COALESCE(sum(c.dra_gm_area),0)
FROM
(
SELECT b.drn_pk, c.dra_gm_area
FROM pghydro.pghft_drainage_line a,
(
SELECT pghydro.pghfn_upstreamDrainageLines($1) as drn_pk
) as b,
pghydro.pghft_drainage_area c
WHERE a.drn_pk = b.drn_pk
AND a.drn_dra_pk = c.dra_pk
) as c;
END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_DownstreamDrainageLine(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_DownstreamDrainageLine(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_sourcenode =
(
SELECT drn_drp_pk_targetnode
FROM pghydro.pghft_drainage_line
WHERE drn_pk = $1
)
AND drn_pk <> $1;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLine(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpstreamDrainageLine(integer)
RETURNS integer AS
$$
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_targetnode =
(
SELECT drn_drp_pk_targetnode
FROM pghydro.pghft_drainage_line
WHERE drn_pk = $1
)
AND drn_pk <> $1;
$$
LANGUAGE SQL;
--COMMIT;

--------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDistanceToSea(numeric)
--------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateDistanceToSea(numeric)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;
var1 integer;
i integer;
j integer;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

SELECT INTO var1 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

j := max(drn_pk) FROM pghydro.pghft_drainage_line;

FOR i IN 1..j LOOP

UPDATE pghydro.pghft_drainage_line drn
SET drn_nu_distancetosea = pghydro.pghfn_distance_to_mouth(drn_pk)+$1--offset distance to sea
WHERE drn.drn_pk = i;

RAISE NOTICE 'DRAINAGE %/%', i, j;  

END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_nu_distancetosea = null
FROM
(
SELECT pghydro.pghfn_downstream_drainagelines(var1) as drn_pk
UNION
SELECT var1 as drn_pk
) as a
WHERE drn.drn_pk = a.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateUpstreamArea()
----------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateUpstreamArea()
RETURNS character varying AS
$$
DECLARE
var1 integer;
time_ timestamp;
i integer;
j integer;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

SELECT INTO var1 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

j := max(drn_pk) FROM pghydro.pghft_drainage_line;

FOR i IN 1..j LOOP

UPDATE pghydro.pghft_drainage_line drn
SET drn_nu_upstreamarea = pghydro.pghfn_Upstreamdrainagelinesarea(drn_pk)
WHERE drn.drn_pk = i;

RAISE NOTICE 'DRAINAGE %/%', i, j;  

END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_nu_upstreamarea = dra.dra_gm_area
FROM
(
SELECT pghydro.pghfn_downstream_drainagelines(var1) as drn_pk
UNION
SELECT var1 as drn_pk
) as a, pghydro.pghft_drainage_area dra
WHERE drn.drn_pk = a.drn_pk
AND drn.drn_dra_pk = dra.dra_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;
----------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateUpstreamDrainageLine()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateUpstreamDrainageLine()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

UPDATE pghydro.pghft_drainage_line
SET drn_drn_pk_upstreamDrainageLine = pghydro.pghfn_UpstreamDrainageLine(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDownstreamDrainageLine()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateDownstreamDrainageLine()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

UPDATE pghydro.pghft_drainage_line
SET drn_drn_pk_downstreamDrainageLine = pghydro.pghfn_DownstreamDrainageLine(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_ExportTopologicalTable(varchar)
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ExportTopologicalTable(varchar)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

EXECUTE '
COPY
(
SELECT drn.drn_pk, drn.drn_drp_pk_sourcenode, drn.drn_drp_pk_targetnode, drn.drn_gm_length, dra.dra_gm_area
FROM pghydro.pghft_drainage_line drn, pghydro.pghft_drainage_area dra
WHERE drn.drn_dra_pk = dra.dra_pk
) 
TO '''||$1||''' WITH DELIMITER '' '';
';

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_ImportTopologicalTable(varchar)
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_ImportTopologicalTable(varchar)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pbc_drn_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_input_pfafstetterbasincode;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE TABLE pghydro.pghtb_input_pfafstetterbasincode(
pbc_drn_pk integer,
pbc_drn_wtc_cd_pfafstetterwatercourse varchar,
pbc_dra_cd_pfafstetterbasin varchar,
pbc_drn_bo_flowdirection varchar,
pbc_drn_gm_length numeric,
pbc_drn_nu_distancetosea numeric,
pbc_drn_wtc_nu_distancetosea numeric,
pbc_drn_dra_gm_area numeric,
pbc_drn_nu_upstreamarea numeric
);

--Importar as tabelas com as informações do topologia hídrica

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

EXECUTE '
COPY
pghydro.pghtb_input_pfafstetterbasincode
FROM '''||$1||'''
WITH CSV;

';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

CREATE INDEX pbc_drn_pk_idx ON pghydro.pghtb_input_pfafstetterbasincode(pbc_drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

UPDATE pghydro.pghft_drainage_area dra
SET dra_cd_pfafstetterbasin = pbc.pbc_dra_cd_pfafstetterbasin
FROM pghydro.pghtb_input_pfafstetterbasincode pbc, pghydro.pghft_drainage_line drn
WHERE pbc.pbc_drn_pk = drn.drn_pk
AND drn.drn_dra_pk = dra.dra_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

DROP TABLE pghydro.pghtb_input_pfafstetterbasincode;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pbc_drn_pk_idx;    

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_DrainageLines(integer)
----------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_DrainageLines(integer)
RETURNS TABLE(drn_pk_ integer, n_ integer)
AS $$
DECLARE

var1 integer;

BEGIN

SELECT INTO var1 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

IF $1 IN (SELECT pghydro.pghfn_Downstream_DrainageLines(var1)) THEN

RETURN QUERY

SELECT drn_pk, (ROW_NUMBER() OVER ())::integer AS n
FROM
(
SELECT drn_pk, (ROW_NUMBER() OVER ())::integer AS m
FROM
(
SELECT var1 as drn_pk
UNION ALL
SELECT pghydro.pghfn_Downstream_DrainageLines(var1) as drn_pk
) as l
WHERE NOT EXISTS
(
SELECT drn_pk
FROM
(
SELECT pghydro.pghfn_Downstream_DrainageLines($1) as drn_pk
) as r
WHERE r.drn_pk = l.drn_pk
)
ORDER BY m DESC
) as a;

ELSE 

RETURN QUERY

WITH RECURSIVE main_watercourse_DrainageLines(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_nu_upstreamarea) AS
(
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_nu_upstreamarea
	FROM pghydro.pghft_drainage_line
	WHERE drn_pk = $1
UNION ALL
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_nu_upstreamarea
	FROM
	(
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode, a.drn_nu_upstreamarea
	FROM pghydro.pghft_drainage_line a, main_watercourse_DrainageLines c
	WHERE a.drn_drp_pk_targetnode = c.drn_drp_pk_sourcenode
	ORDER BY drn_nu_upstreamarea DESC
	LIMIT 1
	) as foo
)
SELECT drn_pk, (ROW_NUMBER() OVER ())::integer AS n
FROM main_watercourse_DrainageLines;

RETURN;

END IF;

END;
$$
LANGUAGE 'plpgsql';

-------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_DrainageLines(integer, integer)
-------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_DrainageLines(integer, integer)
RETURNS TABLE(drn_pk_ integer, n_ integer)
AS $$
DECLARE

var1 integer;
var2 integer;

BEGIN

SELECT INTO var1 drn_drp_pk_sourcenode FROM pghydro.pghft_drainage_line WHERE drn_pk = $2;

SELECT INTO var2 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

IF $1 IN (SELECT pghydro.pghfn_Downstream_DrainageLines(var2)) THEN

RETURN QUERY

SELECT drn_pk, (ROW_NUMBER() OVER ())::integer AS n
FROM
(
SELECT drn_pk, (ROW_NUMBER() OVER ())::integer AS m
FROM
(
SELECT $2 as drn_pk
UNION ALL
SELECT pghydro.pghfn_Downstream_DrainageLines($2) as drn_pk
) as l
WHERE NOT EXISTS
(
SELECT drn_pk
FROM
(
SELECT pghydro.pghfn_Downstream_DrainageLines($1) as drn_pk
) as r
WHERE r.drn_pk = l.drn_pk
)
ORDER BY m DESC
) as a;

ELSE

RETURN QUERY

WITH RECURSIVE main_watercourse_DrainageLines(drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_nu_upstreamarea) AS
(
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_nu_upstreamarea
	FROM pghydro.pghft_drainage_line
	WHERE drn_pk = $1
UNION ALL
	SELECT drn_pk, drn_drp_pk_targetnode, drn_drp_pk_sourcenode, drn_nu_upstreamarea
	FROM
	(
	SELECT a.drn_pk, a.drn_drp_pk_targetnode, a.drn_drp_pk_sourcenode, a.drn_nu_upstreamarea
	FROM pghydro.pghft_drainage_line a, main_watercourse_DrainageLines c
	WHERE a.drn_drp_pk_targetnode = c.drn_drp_pk_sourcenode
	AND  c.drn_drp_pk_sourcenode <> var1
	ORDER BY drn_nu_upstreamarea DESC
	LIMIT 1
	) as foo
)
SELECT drn_pk, (ROW_NUMBER() OVER ())::integer AS n
FROM main_watercourse_DrainageLines;

RETURN;

END IF;

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;
------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_confluences(integer)
------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_confluences(integer)
RETURNS TABLE(_drn_pk integer, _n integer)
AS $$
DECLARE

var1 integer;

BEGIN

RETURN QUERY

SELECT drn_pk, n
FROM
(
SELECT drn.drn_pk, drn.drn_nu_upstreamarea, pwc.n
FROM pghydro.pghft_drainage_line drn
INNER JOIN
(
SELECT drn_pk_ as drn_pk, n_ as n
FROM pghydro.pghfn_main_watercourse_DrainageLines($1)
EXCEPT ALL
SELECT $1 as drn_pk, 1 as n
) pwc ON pwc.drn_pk = drn.drn_drn_pk_upstreamDrainageLine
ORDER BY pwc.n
) as a
ORDER BY drn_nu_upstreamarea DESC;

RETURN;

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;
---------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_confluences(integer, integer)
---------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_confluences(integer, integer)
RETURNS TABLE(_drn_pk integer, _n integer)
AS $$

BEGIN

RETURN QUERY

SELECT drn_pk, n
FROM
(
SELECT drn.drn_pk, drn.drn_nu_upstreamarea, pwc.n
FROM pghydro.pghft_drainage_line drn
INNER JOIN
(
SELECT drn_pk_ as drn_pk, n_ as n
FROM pghydro.pghfn_main_watercourse_DrainageLines($1, $2)
EXCEPT ALL
SELECT $1 as drn_pk, 1 as n
) pwc ON pwc.drn_pk = drn.drn_drn_pk_upstreamDrainageLine
ORDER BY pwc.n
) as a
ORDER BY drn_nu_upstreamarea DESC;

RETURN;

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;
-----------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_4_confluences(in integer)
-----------------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_4_confluences(in integer)
RETURNS SETOF integer
AS $$
BEGIN

RETURN QUERY

SELECT drn_pk
FROM
(
SELECT _drn_pk as drn_pk, _n as n
FROM pghydro.pghfn_main_watercourse_confluences($1)
LIMIT 4
) as a
ORDER BY n;

RETURN;

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;
-----------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_4_confluences(integer, integer)
-----------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_4_confluences(integer, integer)
RETURNS SETOF integer
AS $$

BEGIN

RETURN QUERY

SELECT drn_pk
FROM
(
SELECT _drn_pk as drn_pk, _n as n
FROM pghydro.pghfn_main_watercourse_confluences($1, $2)
LIMIT 4
) as a
ORDER BY n;

RETURN;

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

-----------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_9_confluences(integer, integer)
-----------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_main_watercourse_9_confluences(integer, integer)
RETURNS TABLE(vard integer, varu integer)AS $$

DECLARE

var1d integer;
var1u integer;
var2 integer;
var3d integer;
var3u integer;
var4 integer;
var5d integer;
var5u integer;
var6 integer;
var7d integer;
var7u integer;
var8 integer;
var9d integer;
var9u integer;
var9 integer;
con4 integer[];
drn_pk_count integer;

BEGIN

IF $2 = -99 THEN

SELECT INTO con4 ARRAY(SELECT pghydro.pghfn_main_watercourse_4_confluences($1));

ELSE

SELECT INTO con4 ARRAY(SELECT pghydro.pghfn_main_watercourse_4_confluences($1, $2));

END IF;

SELECT INTO drn_pk_count array_length(con4, 1);

SELECT INTO var2 con4[1];

SELECT INTO var4 con4[2];

SELECT INTO var6 con4[3];

SELECT INTO var8 con4[4];

var9 = var8;

var1d = $1;

SELECT INTO var1u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var2;

SELECT INTO var3d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var2;

SELECT INTO var3u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var4;

SELECT INTO var5d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var4;

SELECT INTO var5u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var6;

SELECT INTO var7d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var6;

SELECT INTO var7u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var8;

SELECT INTO var9d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var8;

SELECT INTO var9u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var9;

IF $2 = -99 AND drn_pk_count = 1 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, -99 as u, 3 as i
) as a
ORDER BY i;

ELSIF $2 = -99 AND drn_pk_count = 2 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, var3u as u, 3 as i
UNION
SELECT var4 as d, -99 as u, 4 as i
UNION
SELECT var5d as d, -99 as u, 5 as i
) as a
ORDER BY i;

ELSIF $2 = -99 AND drn_pk_count = 3 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, var3u as u, 3 as i
UNION
SELECT var4 as d, -99 as u, 4 as i
UNION
SELECT var5d as d, var5u as u, 5 as i
UNION
SELECT var6 as d, -99 as u, 6 as i
UNION
SELECT var7d as d, -99 as u, 7 as i
) as a
ORDER BY i;

ELSIF $2 = -99 AND drn_pk_count = 4 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, var3u as u, 3 as i
UNION
SELECT var4 as d, -99 as u, 4 as i
UNION
SELECT var5d as d, var5u as u, 5 as i
UNION
SELECT var6 as d, -99 as u, 6 as i
UNION
SELECT var7d as d, var7u as u, 7 as i
UNION
SELECT var8 as d, -99 as u, 8 as i
UNION
SELECT var9d as d, -99 as u, 9 as i
) as a
ORDER BY i;

ELSIF $2 <> -99 AND drn_pk_count = 1 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, $2 as u, 3 as i
) as a
ORDER BY i;

ELSIF $2 <> -99 AND drn_pk_count = 2 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, var3u as u, 3 as i
UNION
SELECT var4 as d, -99 as u, 4 as i
UNION
SELECT var5d as d, $2 as u, 5 as i
) as a
ORDER BY i;

ELSIF $2 <> -99 AND drn_pk_count = 3 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, var3u as u, 3 as i
UNION
SELECT var4 as d, -99 as u, 4 as i
UNION
SELECT var5d as d, var5u as u, 5 as i
UNION
SELECT var6 as d, -99 as u, 6 as i
UNION
SELECT var7d as d, $2 as u, 7 as i
) as a
ORDER BY i;

ELSIF $2 <> -99 AND drn_pk_count = 4 THEN RETURN QUERY
SELECT d, u
FROM
(
SELECT var1d as d, var1u as u, 1 as i
UNION
SELECT var2 as d, -99 as u, 2 as i
UNION
SELECT var3d as d, var3u as u, 3 as i
UNION
SELECT var4 as d, -99 as u, 4 as i
UNION
SELECT var5d as d, var5u as u, 5 as i
UNION
SELECT var6 as d, -99 as u, 6 as i
UNION
SELECT var7d as d, var7u as u, 7 as i
UNION
SELECT var8 as d, -99 as u, 8 as i
UNION
SELECT var9d as d, $2 as u, 9 as i
) as a
ORDER BY i;

END IF
;
END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

-----------------------------------------------------------
--FUNCTION pghydro.pghfn_pfafstetter_codification(integer, integer)
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION pghydro.pghfn_pfafstetter_codification(integer, integer)
RETURNS TABLE(drn_pk_ integer, pfafstetter_codification_ integer)
AS $$

DECLARE

var1d integer;
var1u integer;
var2 integer;
var3d integer;
var3u integer;
var4 integer;
var5d integer;
var5u integer;
var6 integer;
var7d integer;
var7u integer;
var8 integer;
var9d integer;
con4 integer[];

BEGIN


IF $2 = -99 THEN

SELECT INTO con4 ARRAY(SELECT pghydro.pghfn_main_watercourse_4_confluences($1));

ELSE

SELECT INTO con4 ARRAY(SELECT pghydro.pghfn_main_watercourse_4_confluences($1, $2));

END IF;

SELECT INTO var2 con4[1];

SELECT INTO var4 con4[2];

SELECT INTO var6 con4[3];

SELECT INTO var8 con4[4];

var1d = $1;

SELECT INTO var1u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var2;

SELECT INTO var3d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var2;

SELECT INTO var3u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var4;

SELECT INTO var5d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var4;

SELECT INTO var5u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var6;

SELECT INTO var7d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var6;

SELECT INTO var7u drn_drn_pk_downstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var8;

SELECT INTO var9d drn_drn_pk_upstreamDrainageLine FROM pghydro.pghft_drainage_line WHERE drn_pk = var8;

IF $2 = -99 THEN RETURN QUERY

---pfafstetter_basin_codification 1

SELECT pghydro.pghfn_upstreamDrainageLines($1, var1u) as drn_pk, 1 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 2

SELECT pghydro.pghfn_upstreamDrainageLines(var2) as drn_pk, 2 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 3

SELECT pghydro.pghfn_upstreamDrainageLines(var3d, var3u) as drn_pk, 3 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 4

SELECT pghydro.pghfn_upstreamDrainageLines(var4) as drn_pk, 4 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 5

SELECT pghydro.pghfn_upstreamDrainageLines(var5d, var5u) as drn_pk, 5 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 6

SELECT pghydro.pghfn_upstreamDrainageLines(var6) as drn_pk, 6 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 7

SELECT pghydro.pghfn_upstreamDrainageLines(var7d, var7u) as drn_pk, 7 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 8

SELECT pghydro.pghfn_upstreamDrainageLines(var8) as drn_pk, 8 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 9

SELECT pghydro.pghfn_upstreamDrainageLines(var9d) as drn_pk, 9 as pfafstetter_codification;

ELSIF $2 <> -99 THEN RETURN QUERY

SELECT pghydro.pghfn_upstreamDrainageLines($1, var1u) as drn_pk, 1 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 2

SELECT pghydro.pghfn_upstreamDrainageLines(var2) as drn_pk, 2 as pfafstetter_codification

UNION ALL

-----pfafstetter_basin_codification 3

SELECT pghydro.pghfn_upstreamDrainageLines(var3d, var3u) as drn_pk, 3 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 4

SELECT pghydro.pghfn_upstreamDrainageLines(var4) as drn_pk, 4 as pfafstetter_codification
UNION ALL

-----pfafstetter_basin_codification 5

SELECT pghydro.pghfn_upstreamDrainageLines(var5d, var5u) as drn_pk, 5 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 6

SELECT pghydro.pghfn_upstreamDrainageLines(var6) as drn_pk, 6 as pfafstetter_codification

UNION ALL

-----pfafstetter_basin_codification 7

SELECT pghydro.pghfn_upstreamDrainageLines(var7d, var7u) as drn_pk, 7 as pfafstetter_codification

UNION ALL

---pfafstetter_basin_codification 8

SELECT pghydro.pghfn_upstreamDrainageLines(var8) as drn_pk, 8 as pfafstetter_codification
UNION ALL

---pfafstetter_basin_codification 9

SELECT pghydro.pghfn_upstreamDrainageLines(var9d, $2) as drn_pk, 9 as pfafstetter_codification;

END IF

;
END;
$$
LANGUAGE 'plpgsql';

------------------------------------------------------------
--FUNCTION pghydro.pghfn_pfafstetter_codifications(integer, integer)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION pghydro.pghfn_pfafstetter_codifications(integer, integer)
RETURNS TABLE(drn_pk_ integer, pfafstetter_codification_ integer)
AS $$
BEGIN

RETURN QUERY

SELECT (pghfn_pfafstetter_codification).drn_pk_, (pghfn_pfafstetter_codification).pfafstetter_codification_
FROM
(
-----
SELECT pghydro.pghfn_pfafstetter_codification(vard, varu)
FROM
(
----
WITH cod as
(
WITH RECURSIVE cod(vard, varu, vard2, varu2) AS
(
	SELECT $1 as vard, $2 as varu, 0 as vard2, 0 as varu
UNION ALL
	SELECT (pghfn_main_watercourse_9_confluences).vard as vard, (pghfn_main_watercourse_9_confluences).varu, vard2, varu2
	FROM
	(
	SELECT pghydro.pghfn_main_watercourse_9_confluences(vard, varu), c.vard as vard2, c.varu as varu2
	FROM cod c 
	WHERE vard = c.vard
	AND varu = c.varu
	) as b
)
SELECT vard, varu, vard2, varu2
FROM cod
WHERE vard <> varu
)
SELECT vard, varu
FROM cod
WHERE vard in (SELECT DISTINCT vard2 FROM cod)
----
) as e
-----
) as d

;
END;
$$
LANGUAGE 'plpgsql';

---------------------------------------------------------------------
--FUNCTION pghydro.pghfn_Calculate_Pfafstetter_Codification(integer, integer)
---------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_Calculate_Pfafstetter_Codification(integer, integer)
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

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pbc_drn_pk_idx;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;
    
DROP INDEX IF EXISTS pghydro.drn_drn_pk_downstreamDrainageLine_idx;

DROP INDEX IF EXISTS pghydro.drn_drn_pk_upstreamDrainageLine_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

CREATE INDEX drn_drn_pk_downstreamDrainageLine_idx ON pghydro.pghft_drainage_line(drn_drn_pk_downstreamDrainageLine);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

CREATE INDEX drn_drn_pk_upstreamDrainageLine_idx ON pghydro.pghft_drainage_line(drn_drn_pk_upstreamDrainageLine);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_input_pfafstetterbasincode;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;

CREATE TABLE pghydro.pghtb_input_pfafstetterbasincode AS
SELECT drn_pk_ as pbc_drn_pk, 'R'||string_agg((pfafstetter_codification_),'' ORDER BY id) as pbc_dra_cd_pfafstetterbasin
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS id, (pghfn_pfafstetter_codifications).drn_pk_, ((pghfn_pfafstetter_codifications).pfafstetter_codification_)::text
FROM pghydro.pghfn_pfafstetter_codifications($1, $2)
) as a
GROUP BY drn_pk_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;
    
DROP INDEX IF EXISTS pghydro.drn_drn_pk_downstreamDrainageLine_idx;

DROP INDEX IF EXISTS pghydro.drn_drn_pk_upstreamDrainageLine_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;

CREATE INDEX pbc_drn_pk_idx ON pghydro.pghtb_input_pfafstetterbasincode(pbc_drn_pk);

UPDATE pghydro.pghft_drainage_area dra
SET dra_cd_pfafstetterbasin = pbc.pbc_dra_cd_pfafstetterbasin
FROM pghydro.pghtb_input_pfafstetterbasincode pbc, pghydro.pghft_drainage_line drn
WHERE pbc.pbc_drn_pk = drn.drn_pk
AND drn.drn_dra_pk = dra.dra_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;

DROP TABLE pghydro.pghtb_input_pfafstetterbasincode;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pbc_drn_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

---------------------------------------------------------------------
--FUNCTION pghydro.pghfn_Calculate_Pfafstetter_Codification()
---------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_Calculate_Pfafstetter_Codification()
RETURNS varchar AS
$$
DECLARE
time_ timestamp;
var1 integer;
var2 integer;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pbc_drn_pk_idx;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;
    
DROP INDEX IF EXISTS pghydro.drn_drn_pk_downstreamDrainageLine_idx;

DROP INDEX IF EXISTS pghydro.drn_drn_pk_upstreamDrainageLine_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

CREATE INDEX drn_drn_pk_downstreamDrainageLine_idx ON pghydro.pghft_drainage_line(drn_drn_pk_downstreamDrainageLine);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

CREATE INDEX drn_drn_pk_upstreamDrainageLine_idx ON pghydro.pghft_drainage_line(drn_drn_pk_upstreamDrainageLine);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

SELECT INTO var1 drn_pk
FROM
(
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_targetnode = 
(
SELECT sep_drp_pk
FROM pghydro.pghft_shoreline_ending_point
)
) as a;

SELECT INTO var2 drn_pk 
FROM
(
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_drp_pk_sourcenode = 
(
SELECT ssp_drp_pk
FROM pghydro.pghft_shoreline_starting_point
)
) as a;

IF var2 is null THEN var2 = -99;
END IF;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;

DROP TABLE IF EXISTS pghydro.pghtb_input_pfafstetterbasincode;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;

CREATE TABLE pghydro.pghtb_input_pfafstetterbasincode AS

SELECT drn_pk_ as pbc_drn_pk, 'R'||string_agg((pfafstetter_codification_),'' ORDER BY id) as pbc_dra_cd_pfafstetterbasin
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS id, (pghfn_pfafstetter_codifications).drn_pk_, ((pghfn_pfafstetter_codifications).pfafstetter_codification_)::text
FROM pghydro.pghfn_pfafstetter_codifications(var1, var2)
) as a
GROUP BY drn_pk_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;
    
DROP INDEX IF EXISTS pghydro.drn_drn_pk_downstreamDrainageLine_idx;

DROP INDEX IF EXISTS pghydro.drn_drn_pk_upstreamDrainageLine_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;

CREATE INDEX pbc_drn_pk_idx ON pghydro.pghtb_input_pfafstetterbasincode(pbc_drn_pk);

UPDATE pghydro.pghft_drainage_area dra
SET dra_cd_pfafstetterbasin = pbc.pbc_dra_cd_pfafstetterbasin
FROM pghydro.pghtb_input_pfafstetterbasincode pbc, pghydro.pghft_drainage_line drn
WHERE pbc.pbc_drn_pk = drn.drn_pk
AND drn.drn_dra_pk = dra.dra_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;

DROP TABLE pghydro.pghtb_input_pfafstetterbasincode;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.pbc_drn_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdatePfafstetterBasinCode(varchar)
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdatePfafstetterBasinCode(varchar)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

UPDATE pghydro.pghft_drainage_area
SET dra_cd_pfafstetterbasin = $1||ltrim(dra_cd_pfafstetterbasin, 'R');

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

UPDATE pghydro.pghft_drainage_area
SET dra_nu_pfafstetterbasincodelevel = length(dra_cd_pfafstetterbasin);

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdatePfafstetterWatercourseCode()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdatePfafstetterWatercourseCode()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DROP TABLE IF EXISTS pghydro.pghft_drainage_line_temp;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

CREATE TABLE pghydro.pghft_drainage_line_temp(
drn_pk integer,
wtc_cd_pfafstetterwatercourse character varying,
wtc_nu_pfafstetterwatercoursecodeorder smallint,
wtc_nu_pfafstetterwatercoursecodelevel smallint,
wtc_gm_area numeric,
wtc_nu_distancetosea numeric,
wtc_cd_pfafstetterwatercourse_downstream character varying,
wtc_gm_length numeric
);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

--drn_pk

INSERT INTO pghydro.pghft_drainage_line_temp(drn_pk)
SELECT drn_pk
FROM pghydro.pghft_drainage_line
WHERE drn_nu_distancetosea is not null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

CREATE INDEX dra_pk_idx ON pghydro.pghft_drainage_area(dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

CREATE INDEX drn_dra_pk_idx ON pghydro.pghft_drainage_line(drn_dra_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;

--wtc_cd_pfafstetterwatercourse

UPDATE pghydro.pghft_drainage_line_temp tmp
SET wtc_cd_pfafstetterwatercourse = rtrim(dra.dra_cd_pfafstetterbasin, '13579')
FROM pghydro.pghft_drainage_area dra, pghydro.pghft_drainage_line drn
WHERE drn.drn_dra_pk = dra.dra_pk
AND drn.drn_pk = tmp.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;

--wtc_nu_pfafstetterwatercoursecodeorder

UPDATE pghydro.pghft_drainage_line_temp
SET wtc_nu_pfafstetterwatercoursecodeorder = length(translate(wtc_cd_pfafstetterwatercourse, '13579', ''));

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;

--wtc_nu_pfafstetterwatercoursecodelevel

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;

UPDATE pghydro.pghft_drainage_line_temp
SET wtc_nu_pfafstetterwatercoursecodelevel = length(wtc_cd_pfafstetterwatercourse);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;

--wtc_nu_distancetosea

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;

UPDATE pghydro.pghft_drainage_line_temp tmp
SET wtc_nu_distancetosea = a.wtc_nu_distancetosea
FROM
(
SELECT tmp.wtc_cd_pfafstetterwatercourse, min(drn.drn_nu_distancetosea) as wtc_nu_distancetosea
FROM pghydro.pghft_drainage_line_temp tmp, pghydro.pghft_drainage_line drn
WHERE drn.drn_pk = tmp.drn_pk
GROUP BY tmp.wtc_cd_pfafstetterwatercourse
) as a
WHERE tmp.wtc_cd_pfafstetterwatercourse = a.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;

--wtc_gm_area

UPDATE pghydro.pghft_drainage_line_temp tmp
SET wtc_gm_area = a.wtc_gm_area
FROM
(
SELECT tmp.wtc_cd_pfafstetterwatercourse, max(drn.drn_nu_upstreamarea) as wtc_gm_area
FROM pghydro.pghft_drainage_line_temp tmp, pghydro.pghft_drainage_line drn
WHERE drn.drn_pk = tmp.drn_pk
GROUP BY tmp.wtc_cd_pfafstetterwatercourse
) as a
WHERE tmp.wtc_cd_pfafstetterwatercourse = a.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;

--wtc_cd_pfafstetterwatercourse_downstream

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;

UPDATE pghydro.pghft_drainage_line_temp
SET wtc_cd_pfafstetterwatercourse_downstream = rtrim(substring(wtc_cd_pfafstetterwatercourse from 1 for (wtc_nu_pfafstetterwatercoursecodelevel-1)), '13579');

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 19 : %', time_;

--wtc_gm_length

UPDATE pghydro.pghft_drainage_line_temp tmp
SET wtc_gm_length = a.wtc_gm_length
FROM
(
SELECT tmp.wtc_cd_pfafstetterwatercourse, sum(drn.drn_gm_length) as wtc_gm_length
FROM pghydro.pghft_drainage_line_temp tmp, pghydro.pghft_drainage_line drn
WHERE drn.drn_pk = tmp.drn_pk
GROUP BY tmp.wtc_cd_pfafstetterwatercourse
) as a
WHERE tmp.wtc_cd_pfafstetterwatercourse = a.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 20 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 21 : %', time_;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 22 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_dra_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;

END;

$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatercourse()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateWatercourse()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF ALL PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

TRUNCATE pghydro.pghft_watercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

TRUNCATE pghydro.pghft_stream_mouth;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;

TRUNCATE pghydro.pghft_watercourse_ending_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

TRUNCATE pghydro.pghft_watercourse_starting_point;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;

PERFORM setval(('pghydro.wtc_pk_seq'::text)::regclass, 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;

DROP INDEX IF EXISTS pghydro.tmp_drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;

DROP INDEX IF EXISTS pghydro.tmp_wtc_cd_pfafstetterwatercourse_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;

--wtc_cd_pfafstetterwatercourse

INSERT INTO pghydro.pghft_watercourse
(
wtc_cd_pfafstetterwatercourse
)
SELECT DISTINCT 
wtc_cd_pfafstetterwatercourse
FROM pghydro.pghft_drainage_line_temp;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;

CREATE INDEX tmp_drn_pk_idx ON pghydro.pghft_drainage_line_temp(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;

CREATE INDEX tmp_wtc_cd_pfafstetterwatercourse_idx ON pghydro.pghft_drainage_line_temp(wtc_cd_pfafstetterwatercourse);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;

--wtc_gm

UPDATE pghydro.pghft_watercourse wtc
SET wtc_gm = a.wtc_gm
FROM
(
SELECT tmp.wtc_cd_pfafstetterwatercourse, ST_UNION(drn.drn_gm) as wtc_gm
FROM pghydro.pghft_drainage_line_temp tmp, pghydro.pghft_drainage_line drn
WHERE tmp.drn_pk = drn.drn_pk
GROUP BY tmp.wtc_cd_pfafstetterwatercourse
) as a
WHERE a.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;

--wtc_nu_distancetosea

UPDATE pghydro.pghft_watercourse wtc
SET wtc_nu_distancetosea = tmp.wtc_nu_distancetosea
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;

--wtc_cd_pfafstetterwatercourse_downstream

UPDATE pghydro.pghft_watercourse wtc
SET wtc_cd_pfafstetterwatercourse_downstream = tmp.wtc_cd_pfafstetterwatercourse_downstream
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;

--wtc_gm_area

UPDATE pghydro.pghft_watercourse wtc
SET wtc_gm_area = tmp.wtc_gm_area
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 19 : %', time_;

--wtc_cd_pfafstetterwatercourse

UPDATE pghydro.pghft_watercourse wtc
SET wtc_cd_pfafstetterwatercourse = tmp.wtc_cd_pfafstetterwatercourse
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 20 : %', time_;

--wtc_nu_pfafstetterwatercoursecodelevel

UPDATE pghydro.pghft_watercourse wtc
SET wtc_nu_pfafstetterwatercoursecodelevel = tmp.wtc_nu_pfafstetterwatercoursecodelevel
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 21 : %', time_;

--wtc_nu_pfafstetterwatercoursecodeorder

UPDATE pghydro.pghft_watercourse wtc
SET wtc_nu_pfafstetterwatercoursecodeorder = tmp.wtc_nu_pfafstetterwatercoursecodeorder
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 22 : %', time_;

--wtc_gm_length

UPDATE pghydro.pghft_watercourse wtc
SET wtc_gm_length = tmp.wtc_gm_length
FROM pghydro.pghft_drainage_line_temp tmp
WHERE tmp.wtc_cd_pfafstetterwatercourse = wtc.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 23 : %', time_;

--drn_wtc_pk

UPDATE pghydro.pghft_drainage_line drn
SET drn_wtc_pk = wtc.wtc_pk
FROM pghydro.pghft_watercourse wtc, pghydro.pghft_drainage_line_temp tmp
WHERE drn.drn_pk = tmp.drn_pk
AND wtc.wtc_cd_pfafstetterwatercourse = tmp.wtc_cd_pfafstetterwatercourse;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 24 : %', time_;

--drn_rcl_pk_wtc

UPDATE pghydro.pghft_drainage_line
SET drn_rcl_pk_wtc = 13;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 25 : %', time_;

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 26 : %', time_;

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 27 : %', time_;

--drn_nu_distancetowatercourse

UPDATE pghydro.pghft_drainage_line drn
SET drn_nu_distancetowatercourse = drn.drn_nu_distancetosea - wtc.wtc_nu_distancetosea
FROM pghydro.pghft_watercourse wtc
WHERE drn.drn_wtc_pk = wtc.wtc_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 28 : %', time_;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 29 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 30 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 31 : %', time_;

DROP INDEX IF EXISTS pghydro.tmp_drn_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 32 : %', time_;

DROP INDEX IF EXISTS pghydro.tmp_wtc_cd_pfafstetterwatercourse_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 33 : %', time_;

DROP TABLE IF EXISTS pghydro.pghft_drainage_line_temp;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

RETURN 'OK';
END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevel()
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevel()
RETURNS SETOF smallint AS
$$
SELECT DISTINCT dra_nu_pfafstetterbasincodelevel
FROM pghydro.pghft_drainage_area
ORDER BY dra_nu_pfafstetterbasincodelevel;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------
--FUNCTION pghydro.pghfn_numPfafstetterBasinCodeLevel()
------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_numPfafstetterBasinCodeLevel()
RETURNS bigint AS
$$
SELECT count(dra_nu_pfafstetterbasincodelevel)
FROM
(
SELECT pghydro.pghfn_PfafstetterBasinCodeLevel() as dra_nu_pfafstetterbasincodelevel
) as a;
$$
LANGUAGE SQL;
--COMMIT;

----------------------------------------------------------
--FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevelN(integer)
----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevelN(integer)
RETURNS smallint AS
$$
SELECT dra_nu_pfafstetterbasincodelevel
FROM
(
SELECT (ROW_NUMBER() OVER ())::integer AS seq_dra_nu_pfafstetterbasincodelevel, dra_nu_pfafstetterbasincodelevel
FROM
(
SELECT pghydro.pghfn_PfafstetterBasinCodeLevel() as dra_nu_pfafstetterbasincodelevel
) as a
) as b
WHERE seq_dra_nu_pfafstetterbasincodelevel = $1;
$$
LANGUAGE SQL;
--COMMIT;

------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatershedDrainageArea(integer)
------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateWatershedDrainageArea(integer)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

INSERT INTO pghydro.pghft_watershed (wts_cd_pfafstetterbasin, wts_cd_pfafstetterbasincodelevel, wts_gm_area, wts_gm)
SELECT dra_cd_pfafstetterbasin, $1 as dra_nu_pfafstetterbasincodelevel, SUM(dra_gm_area) as dra_gm_area, ST_Multi(ST_UNION(dra_gm)) as dra_gm
FROM
(
SELECT substring(dra_cd_pfafstetterbasin FROM 1 FOR $1) as dra_cd_pfafstetterbasin, dra_gm_area, dra_gm
FROM pghydro.pghft_drainage_area
) as a
GROUP BY dra_cd_pfafstetterbasin;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RAISE NOTICE 'BASIN LEVEL % FINISHED', $1;

RETURN 'OK';

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;


----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatershed(integer)
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateWatershed(integer)
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.wts_cd_pfafstetterbasincodelevel_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

CREATE INDEX wts_cd_pfafstetterbasincodelevel_idx ON pghydro.pghft_watershed(wts_cd_pfafstetterbasincodelevel);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

INSERT INTO pghydro.pghft_watershed (wts_cd_pfafstetterbasin, wts_cd_pfafstetterbasincodelevel, wts_gm_area, wts_gm)
SELECT wts_cd_pfafstetterbasin, $1-1 as wts_cd_pfafstetterbasincodelevel, SUM(wts_gm_area) as wts_gm_area, ST_Multi(ST_UNION(wts_gm)) as wts_gm
FROM
(
SELECT substring(wts_cd_pfafstetterbasin FROM 1 FOR $1-1) as wts_cd_pfafstetterbasin, wts_gm_area, wts_gm
FROM
(
SELECT wts_cd_pfafstetterbasin, wts_cd_pfafstetterbasincodelevel, wts_gm_area, wts_gm
FROM pghydro.pghft_watershed
WHERE wts_cd_pfafstetterbasincodelevel = $1
) as b
) as a
GROUP BY wts_cd_pfafstetterbasin;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

DROP INDEX IF EXISTS pghydro.wts_cd_pfafstetterbasincodelevel_idx;

RAISE NOTICE 'BASIN LEVEL % FINISHED', $1-1;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

--------------------------------------------------------
--FUNCTION pghydro.pghfn_InsertColumnPfafstetterBasinCodeLevel()
--------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_InsertColumnPfafstetterBasinCodeLevel()
RETURNS character varying AS
$$

DECLARE
min_var integer;
max_var integer;
time_ timestamp;
i integer;
j integer;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

SELECT INTO max_var max(dra_nu_pfafstetterbasincodelevel) FROM pghydro.pghft_drainage_area;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

SELECT INTO min_var min(dra_nu_pfafstetterbasincodelevel) FROM pghydro.pghft_drainage_area;

i := max_var;
j := min_var;

RAISE NOTICE 'MAX LEVEL : %', i;
RAISE NOTICE 'MIN LEVEL : %', j;

WHILE (i >= j) LOOP

time_ := timeofday();
RAISE NOTICE 'BEGIN OF LOOP : %', time_;
RAISE NOTICE 'LEVEL : %', i;

BEGIN
EXECUTE '
ALTER TABLE pghydro.pghft_drainage_area
DROP COLUMN dra_cd_pfafstetterbasin_level_'||i||';';
EXCEPTION WHEN undefined_column THEN
               --DO NOTHING
END;

BEGIN   
EXECUTE '
ALTER TABLE pghydro.pghft_drainage_area
ADD COLUMN dra_cd_pfafstetterbasin_level_'||i||' character varying;';
EXCEPTION WHEN duplicate_column THEN
               --DO NOTHING
END;

EXECUTE '
UPDATE pghydro.pghft_drainage_area
SET dra_cd_pfafstetterbasin_level_'||i||' = substring(dra_cd_pfafstetterbasin FROM 1 FOR '||i||');';

i := i - 1;

END LOOP;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

-----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatercourse_Starting_Point()
-----------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateWatercourse_Starting_Point()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

TRUNCATE pghydro.pghft_watercourse_starting_point CASCADE;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

PERFORM setval(('pghydro.wsp_pk_seq'::text)::regclass, 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

CREATE INDEX drp_nu_valence_idx ON pghydro.pghft_drainage_point(drp_nu_valence);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;    

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;    

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;    

CREATE INDEX wtc_cd_pfafstetterwatercourse_idx ON pghydro.pghft_watercourse(wtc_cd_pfafstetterwatercourse);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;    

INSERT INTO pghydro.pghft_watercourse_starting_point(wsp_drp_pk, wsp_rcl_pk_drp, wsp_wtc_pk, wsp_rcl_pk_wtc, wsp_gm)
SELECT drp.drp_pk, 9 as wsp_rcl_pk_drp, drn.drn_wtc_pk, 15 as wsp_rcl_pk_wtc, drp.drp_gm
FROM pghydro.pghft_drainage_point drp, pghydro.pghft_drainage_line drn, pghydro.pghft_watercourse wtc
WHERE drn.drn_drp_pk_sourcenode = drp.drp_pk
AND drp.drp_nu_valence = 1
AND drn.drn_wtc_pk = wtc.wtc_pk
AND wtc.wtc_cd_pfafstetterwatercourse <> '';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 19 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 20 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 21 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_cd_pfafstetterwatercourse_idx;

RETURN 'OK';

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

---------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatercourse_Ending_Point()
---------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateWatercourse_Ending_Point()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

TRUNCATE pghydro.pghft_watercourse_ending_point CASCADE;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

PERFORM setval(('pghydro.wep_pk_seq'::text)::regclass, 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

INSERT INTO pghydro.pghft_watercourse_ending_point(wep_drp_pk, wep_rcl_pk_drp, wep_wtc_pk, wep_rcl_pk_wtc, wep_gm)
SELECT drp.drp_pk, 9 as con_rcl_pk_drp, drn.drn_wtc_pk, 15 as con_rcl_pk_wtc, drp.drp_gm
FROM pghydro.pghft_drainage_point drp, pghydro.pghft_drainage_line drn, pghydro.pghft_watercourse wtc
WHERE drn.drn_drp_pk_targetnode = drp.drp_pk
AND drn.drn_wtc_pk = wtc.wtc_pk
AND drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea > 0;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateStream_Mouth()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateStream_Mouth()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

TRUNCATE pghydro.pghft_stream_mouth CASCADE;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

PERFORM setval(('pghydro.stm_pk_seq'::text)::regclass, 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

INSERT INTO pghydro.pghft_stream_mouth(stm_drp_pk, stm_rcl_pk_drp, stm_wtc_pk, stm_rcl_pk_wtc, stm_gm)
SELECT drp.drp_pk, 9 as con_rcl_pk_drp, drn.drn_wtc_pk, 15 as con_rcl_pk_wtc, drp.drp_gm
FROM pghydro.pghft_drainage_point drp, pghydro.pghft_drainage_line drn, pghydro.pghft_watercourse wtc
WHERE drn.drn_drp_pk_targetnode = drp.drp_pk
AND drn.drn_wtc_pk = wtc.wtc_pk
AND drn.drn_nu_distancetowatercourse = 0
AND drn.drn_nu_distancetosea = 0;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;    

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateShoreline()
----------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateShoreline()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

DELETE FROM pghydro.pghft_shoreline;

INSERT INTO pghydro.pghft_shoreline(sho_pk, sho_nm, sho_gm_length, sho_gm)
SELECT 1 as sho_pk, 'Linha de Costa'::text as sho_nm,  SUM(drn_gm_length) as sho_gm_length, ST_UNION(drn_gm) as sho_gm
FROM pghydro.pghft_drainage_line
WHERE drn_nu_distancetosea is null;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;

END;

$$
LANGUAGE PLPGSQL;
--COMMIT;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateDomainColumn()
----------------------------------------------------

--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateDomainColumn()
RETURNS character varying AS
$$
DECLARE
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;    

CREATE INDEX drn_wtc_pk_idx ON pghydro.pghft_drainage_line(drn_wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_tdm_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;    

CREATE INDEX drn_tdm_pk_idx ON pghydro.pghft_drainage_line(drn_tdm_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

UPDATE pghydro.pghft_drainage_line a
SET drn_tdm_pk = 1
FROM
(
SELECT drn_wtc_pk
FROM pghydro.pghft_drainage_line
WHERE drn_tdm_pk = 1
) as b
WHERE b.drn_wtc_pk = a.drn_wtc_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;    

UPDATE pghydro.pghft_watercourse a
SET wtc_tdm_pk = null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;    

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;    

CREATE INDEX wtc_pk_idx ON pghydro.pghft_watercourse(wtc_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 9 : %', time_;    

UPDATE pghydro.pghft_watercourse a
SET wtc_tdm_pk = 1
FROM
(
SELECT drn_wtc_pk
FROM pghydro.pghft_drainage_line
WHERE drn_tdm_pk = 1
) as b
WHERE b.drn_wtc_pk = a.wtc_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 10 : %', time_;    

UPDATE pghydro.pghft_drainage_line
SET drn_tdm_pk = 0
WHERE drn_tdm_pk is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

UPDATE pghydro.pghft_watercourse
SET wtc_tdm_pk = 0
WHERE wtc_tdm_pk is null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 12 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 13 : %', time_;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 14 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 15 : %', time_;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 16 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;

UPDATE pghydro.pghft_drainage_line drn
SET drn_tdm_pk = 3
FROM
(
SELECT ssp_drn_pk as drn_pk
FROM pghydro.pghft_shoreline_starting_point 
UNION
SELECT pghydro.pghfn_downstream_drainagelines(drn_pk) as drn_pk
FROM
(
SELECT ssp_drn_pk as drn_pk
FROM pghydro.pghft_shoreline_starting_point 
) as a
) as a
WHERE a.drn_pk = drn.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 19 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 20 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 21 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;    

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 22 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_wtc_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 23 : %', time_;    

DROP INDEX IF EXISTS pghydro.drn_tdm_pk_idx;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 24 : %', time_;

DROP INDEX IF EXISTS pghydro.wtc_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

--COMMIT;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

------------------------------------------------------------------
--FUNCTION pghydro.pghfn_downstream_drainageline_strahler(integer)
------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_downstream_drainageline_strahler(integer)
RETURNS SETOF integer AS
$$

BEGIN

RETURN QUERY

SELECT drn_1 as drn_pk
FROM
(
SELECT pghydro.pghfn_downstreamdrainageline(hin_drn_pk) as drn_1, hin_drn_pk as drn_2, pghydro.pghfn_upstreamdrainageline(hin_drn_pk) as drn_3
FROM pghydro.pghft_hydro_intel
WHERE hin_strahler = $1
ORDER BY drn_1
) as a
GROUP BY drn_1
HAVING count(drn_1) > 1;

RETURN;

END;
$$
LANGUAGE PLPGSQL;
--COMMIT;

------------------------------------------------------------------
--FUNCTION pghydro.pghfn_calculatestrahlernumber()
------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION pghydro.pghfn_calculatestrahlernumber()
RETURNS varchar AS
$$

DECLARE

time_ timestamp;
i INTEGER;
j INTEGER;
	                
BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1: %', time_;

UPDATE pghydro.pghft_hydro_intel hin
SET hin_strahler = null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2: %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

CREATE INDEX drn_pk_idx ON pghydro.pghft_drainage_line(drn_pk);

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

CREATE INDEX drn_drp_pk_sourcenode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_sourcenode);

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

CREATE INDEX drn_drp_pk_targetnode_idx ON pghydro.pghft_drainage_line(drn_drp_pk_targetnode);

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

CREATE INDEX drp_nu_valence_idx ON pghydro.pghft_drainage_point(drp_nu_valence);

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

CREATE INDEX drp_pk_idx ON pghydro.pghft_drainage_point(drp_pk);

DROP INDEX IF EXISTS pghydro.hin_drn_pk_idx;

CREATE INDEX hin_drn_pk_idx ON pghydro.pghft_hydro_intel(hin_drn_pk);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3: %', time_;

UPDATE pghydro.pghft_hydro_intel hin
SET hin_strahler = 1
FROM
(
SELECT drn_pk
FROM
(
SELECT drn.drn_pk
FROM pghydro.pghft_drainage_line drn, pghydro.pghft_drainage_point drp
WHERE drp.drp_nu_valence = 1
AND drp.drp_pk = drn.drn_drp_pk_sourcenode
) as a
WHERE drn_pk NOT IN
(
SELECT ssp_drn_pk as drn_pk
FROM pghydro.pghft_shoreline_starting_point 
)
) as a
WHERE hin.hin_drn_pk = a.drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 4: %', time_;

i = 1;

LOOP

DROP INDEX IF EXISTS pghydro.hin_strahler_idx;

CREATE INDEX hin_strahler_idx ON pghydro.pghft_hydro_intel(hin_strahler);

SELECT INTO j count(drn_pk) 
FROM
(
SELECT pghydro.pghfn_downstream_drainageline_strahler(i) as drn_pk
) as a;

RAISE NOTICE 'STRAHLER NUMBER/OCORRENCES %/% IN %', i, j, time_;

EXIT WHEN j < 1;

UPDATE pghydro.pghft_hydro_intel hin
SET hin_strahler = i+1
FROM
(
SELECT pghydro.pghfn_downstream_drainageline_strahler(i) as drn_pk
UNION
SELECT DISTINCT pghydro.pghfn_downstreamdrainagelines(drn_pk) as drn_pk
FROM
(
SELECT pghydro.pghfn_downstream_drainageline_strahler(i) as drn_pk
) as a
) as a
WHERE hin.hin_drn_pk = a.drn_pk;

i = i+1;

END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5: %', time_;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drp_nu_valence_idx;

DROP INDEX IF EXISTS pghydro.drp_pk_idx;

DROP INDEX IF EXISTS pghydro.hin_drn_pk_idx;

RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE 'plpgsql';
--COMMIT;

--COMMIT;