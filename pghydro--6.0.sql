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

--Postgresql version >= 9.1
--PostGIS version >= 2.0

---------------------------------------------------------------------------------
--PgHydro Extension Version 6.0 of 25/07/2017
---------------------------------------------------------------------------------

-------------------------------------
--CREATE SCHEMA, TABLES AND SEQUENCES
-------------------------------------

DROP SCHEMA IF EXISTS pghydro CASCADE;

CREATE SCHEMA pghydro;

--

CREATE TABLE pghydro.pghft_shoreline (
    sho_pk integer,
    sho_gm_length numeric,
    sho_bo_flowdirection boolean,
    sho_nm character varying,
    sho_gm geometry(MultiLineString)
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

CREATE TABLE pghydro.pghft_hydro_intel(
	hin_pk integer,
	hin_drn_pk integer,
	hin_dra_pk integer,
	hin_count_drn_pk integer,
	hin_count_dra_pk integer,
	hin_strahler integer,
	hin_gm_point geometry(Point),
	hin_gm_line geometry(MultiLineString),
	hin_gm_polygon geometry(MultiPolygon)
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
    drp_nu_valence smallint,
    drp_gm geometry(Point)
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
    drn_tnc_pk integer,
    drn_gm_length numeric,
    drn_dra_pk integer,
    drn_rcl_pk_dra integer,
    drn_nu_upstreamarea numeric,
    drn_wtc_pk integer,
    drn_rcl_pk_wtc integer,
    drn_tdm_pk integer,
    drn_gm_point geometry(Multipoint),
    drn_gm geometry(MultiLineString)
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

CREATE TABLE pghydro.pghft_drainage_area (
    dra_pk integer,
    dra_cd_pfafstetterbasin character varying,
    dra_nu_pfafstetterbasincodelevel smallint,
    dra_gm_area numeric,
    dra_gm geometry(MultiPolygon)    
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

CREATE TABLE pghydro.pghft_shoreline_ending_point (
    sep_pk integer,
    sep_drp_pk integer,
    sep_rcl_pk_drp integer,
    sep_drn_pk integer,
    sep_rcl_pk_drn integer,
    sep_sho_pk integer,
    sep_rcl_pk_sho integer,
    sep_gm geometry(Point)
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
    ssp_rcl_pk_sho integer,
    ssp_gm geometry(Point)
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
    stm_rcl_pk_wtc integer,
    stm_gm geometry(Point)
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

CREATE TABLE pghydro.pghft_watercourse (
    wtc_pk integer,
    wtc_nu_distancetosea numeric,
    wtc_cd_pfafstetterwatercourse_downstream character varying,
    wtc_cd_pfafstetterwatercourse character varying,
    wtc_nu_pfafstetterwatercoursecodelevel smallint,
    wtc_nu_pfafstetterwatercoursecodeorder smallint,
    wtc_gm_area numeric,
    wtc_gm_length numeric,
    wtc_tdm_pk integer,
    wtc_gm geometry(MultiLineString)
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
    wsp_rcl_pk_wtc integer,
    wsp_gm geometry(Point)
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
    wep_rcl_pk_wtc integer,
    wep_gm geometry(Point)
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
    wts_gm_area numeric,
    wts_gm geometry(MultiPolygon)
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

CREATE TABLE pghydro.pghtb_primary_key_columns (
    f_table_catalog character varying(256),
    f_table_schema character varying(256),
    f_table_name character varying(256),
    f_primary_key_column character varying(256)
);

--

CREATE TABLE pghydro.pghtb_foreign_key_columns (
    f_table_catalog character varying(256),
    f_table_schema character varying(256),
    f_table_name character varying(256),
    f_foreign_key_column character varying(256),
    f_table_catalog_reference character varying(256),
    f_table_schema_reference character varying(256),
    f_table_name_reference character varying(256),
    f_primary_key_column_reference character varying(256)
);

--

CREATE TABLE pghydro.pghtb_index_columns (
    f_table_catalog character varying(256),
    f_table_schema character varying(256),
    f_table_name character varying(256),
    f_index_column character varying(256),
    f_index_column_method character varying(256)
);


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

ALTER TABLE pghydro.pghft_shoreline ALTER COLUMN sho_pk SET DEFAULT nextval('pghydro.sho_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_domain ALTER COLUMN tdm_pk SET DEFAULT nextval('pghydro.tdm_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_hydro_intel ALTER COLUMN hin_pk SET DEFAULT nextval('pghydro.hin_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_drainage_point ALTER COLUMN drp_pk SET DEFAULT nextval('pghydro.drp_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_drainage_line ALTER COLUMN drn_pk SET DEFAULT nextval('pghydro.drn_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_drainage_area ALTER COLUMN dra_pk SET DEFAULT nextval('pghydro.dra_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_shoreline_ending_point ALTER COLUMN sep_pk SET DEFAULT nextval('pghydro.sep_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_shoreline_starting_point ALTER COLUMN ssp_pk SET DEFAULT nextval('pghydro.ssp_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_stream_mouth ALTER COLUMN stm_pk SET DEFAULT nextval('pghydro.stm_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_watercourse ALTER COLUMN wtc_pk SET DEFAULT nextval('pghydro.wtc_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_watercourse_starting_point ALTER COLUMN wsp_pk SET DEFAULT nextval('pghydro.wsp_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_watercourse_ending_point ALTER COLUMN wep_pk SET DEFAULT nextval('pghydro.wep_pk_seq'::regclass);

ALTER TABLE pghydro.pghft_watershed ALTER COLUMN wts_pk SET DEFAULT nextval('pghydro.wts_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_de9im ALTER COLUMN dim_pk SET DEFAULT nextval('pghydro.dim_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_geometry ALTER COLUMN tgm_pk SET DEFAULT nextval('pghydro.tgm_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_relationship_class ALTER COLUMN rcl_pk SET DEFAULT nextval('pghydro.rcl_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_topology_relationship ALTER COLUMN tpr_pk SET DEFAULT nextval('pghydro.tpr_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_name_complete ALTER COLUMN tnc_pk SET DEFAULT nextval('pghydro.tnc_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_name_generic ALTER COLUMN tng_pk SET DEFAULT nextval('pghydro.tng_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_name_connection ALTER COLUMN tcn_pk SET DEFAULT nextval('pghydro.tcn_pk_seq'::regclass);

ALTER TABLE pghydro.pghtb_type_name_specific ALTER COLUMN tns_pk SET DEFAULT nextval('pghydro.tns_pk_seq'::regclass);

-----------------------------
--INSERT DATA
-----------------------------

--

DELETE FROM pghydro.pghtb_type_geometry;

INSERT INTO pghydro.pghtb_type_geometry VALUES (1, 'POINT');
INSERT INTO pghydro.pghtb_type_geometry VALUES (2, 'LINESTRING');
INSERT INTO pghydro.pghtb_type_geometry VALUES (3, 'POLYGON');
INSERT INTO pghydro.pghtb_type_geometry VALUES (4, 'MULTIPOINT');
INSERT INTO pghydro.pghtb_type_geometry VALUES (5, 'MULTILINESTRING');
INSERT INTO pghydro.pghtb_type_geometry VALUES (6, 'MULTIPOLYGON');
INSERT INTO pghydro.pghtb_type_geometry VALUES (7, 'GEOMETRY');
INSERT INTO pghydro.pghtb_type_geometry VALUES (8, 'GEOMETRYCOLLECTION');

--

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

--

DELETE FROM pghydro.pghtb_type_topology_relationship;

INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (1, 'IN');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (2, 'TOUCH');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (3, 'OVERLAP');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (4, 'CROSS');
INSERT INTO pghydro.pghtb_type_topology_relationship VALUES (5, 'DISJOINT');

--

DELETE FROM pghydro.pghtb_type_domain;

INSERT INTO pghydro.pghtb_type_domain VALUES (0, 'Estadual');
INSERT INTO pghydro.pghtb_type_domain VALUES (1, 'Federal');
INSERT INTO pghydro.pghtb_type_domain VALUES (2, 'Internacional');
INSERT INTO pghydro.pghtb_type_domain VALUES (3, 'Linha de Costa');

--

DELETE FROM pghydro.pghtb_primary_key_columns;

INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline', 'sho_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_domain', 'tdm_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_hydro_intel', 'hin_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_area', 'dra_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse', 'wtc_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghft_watershed', 'wts_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_de9im', 'dim_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_geometry', 'tgm_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_topology_relationship', 'tpr_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_connection', 'tcn_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_generic', 'tng_pk');
INSERT INTO pghydro.pghtb_primary_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_specific', 'tns_pk');

--

DELETE FROM pghydro.pghtb_foreign_key_columns;

INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_hydro_intel', 'hin_drn_pk', current_database(), 'pghydro', 'pghft_drainage_line', 'drn_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_hydro_intel', 'hin_dra_pk', current_database(), 'pghydro', 'pghft_drainage_area', 'dra_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_wtc_pk', current_database(), 'pghydro', 'pghft_watercourse', 'wtc_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_drp_pk', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_sho_pk', current_database(), 'pghydro', 'pghft_shoreline', 'sho_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_drp_pk', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_sho_pk', current_database(), 'pghydro', 'pghft_shoreline', 'sho_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_drp_pk', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_drp_pk', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_tgm_pk_class_a', current_database(), 'pghydro', 'pghtb_type_geometry', 'tgm_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_rcl_pk_drp', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_drp_pk', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_rcl_pk_drp', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_rcl_pk_drp', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_rcl_pk_drp', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_rcl_pk_drp', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_tgm_pk_class_b', current_database(), 'pghydro', 'pghtb_type_geometry', 'tgm_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_drp_pk_sourcenode', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_wtc_pk', current_database(), 'pghydro', 'pghft_watercourse', 'wtc_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_wtc_pk', current_database(), 'pghydro', 'pghft_watercourse', 'wtc_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_wtc_pk', current_database(), 'pghydro', 'pghft_watercourse', 'wtc_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_dim_pk', current_database(), 'pghydro', 'pghtb_type_de9im', 'dim_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_drp_pk_targetnode', current_database(), 'pghydro', 'pghft_drainage_point', 'drp_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_rcl_pk_wtc', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_rcl_pk_wtc', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_rcl_pk_wtc', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_tpr_pk', current_database(), 'pghydro', 'pghtb_type_topology_relationship', 'tpr_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_drp_targetnode', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_drp_sourcenode', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_dra_pk', current_database(), 'pghydro', 'pghft_drainage_area', 'dra_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_dra', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_wtc', current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_tdm_pk', current_database(), 'pghydro', 'pghtb_type_domain', 'tdm_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse', 'wtc_tdm_pk', current_database(), 'pghydro', 'pghtb_type_domain', 'tdm_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_tns_pk', current_database(), 'pghydro', 'pghtb_type_name_specific', 'tns_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_tng_pk', current_database(), 'pghydro', 'pghtb_type_name_generic', 'tng_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_tcn_pk', current_database(), 'pghydro', 'pghtb_type_name_connection', 'tcn_pk');
INSERT INTO pghydro.pghtb_foreign_key_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_tnc_pk', current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_pk');

--

DELETE FROM pghydro.pghtb_index_columns;

INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_hydro_intel', 'hin_drn_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_hydro_intel', 'hin_dra_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_wtc_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_drp_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_sho_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_drp_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_sho_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_drp_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_drp_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_tgm_pk_class_a', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_rcl_pk_drp', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_drp_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_starting_point', 'ssp_rcl_pk_drp', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_shoreline_ending_point', 'sep_rcl_pk_drp', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_rcl_pk_drp', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_rcl_pk_drp', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_tgm_pk_class_b', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_drp_pk_sourcenode', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_wtc_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_wtc_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_wtc_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_dim_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_drp_pk_targetnode', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_starting_point', 'wsp_rcl_pk_wtc', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_stream_mouth', 'stm_rcl_pk_wtc', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse_ending_point', 'wep_rcl_pk_wtc', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_relationship_class', 'rcl_tpr_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_drp_targetnode', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_drp_sourcenode', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_dra_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_dra', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_rcl_pk_wtc', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_tdm_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_watercourse', 'wtc_tdm_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_point', 'drp_nu_valence', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_hydro_intel', 'hin_strahler', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_area', 'dra_cd_pfafstetterbasin', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_area', 'dra_nu_pfafstetterbasincodelevel', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_tng_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_tcn_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghtb_type_name_complete', 'tnc_tns_pk', 'btree');
INSERT INTO pghydro.pghtb_index_columns VALUES (current_database(), 'pghydro', 'pghft_drainage_line', 'drn_tnc_pk', 'btree');

---------------------------------------------------------------------------------------------------
--PGHYDRO FUNCTIONS
---------------------------------------------------------------------------------------------------
----------------------------------------------------
--FUNCTION pghydro.pghfn_DropPrimaryKeys()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_DropPrimaryKeys()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;


    FOR r IN SELECT f_table_catalog, f_table_schema, f_table_name, f_primary_key_column FROM pghydro.pghtb_primary_key_columns
    
    LOOP

	EXECUTE '
	ALTER TABLE ONLY '||r.f_table_schema||'.'||r.f_table_name||' DROP CONSTRAINT IF EXISTS '||r.f_primary_key_column||'_pkey;
	';

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-----------------------------------------
--FUNCTION pghydro.pghfn_AddPrimaryKeys()
-----------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_AddPrimaryKeys()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropPrimaryKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;


    FOR r IN SELECT f_table_catalog, f_table_schema, f_table_name, f_primary_key_column FROM pghydro.pghtb_primary_key_columns
    
    LOOP

	EXECUTE '
	ALTER TABLE ONLY '||r.f_table_schema||'.'||r.f_table_name||' ADD CONSTRAINT '||r.f_primary_key_column||'_pkey PRIMARY KEY ('||r.f_primary_key_column||');
	';

    END LOOP;

  
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropForeignKeys()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_DropForeignKeys()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;


    FOR r IN SELECT f_table_catalog, f_table_schema, f_table_name, f_foreign_key_column FROM pghydro.pghtb_foreign_key_columns
    
    LOOP

	EXECUTE '
	ALTER TABLE ONLY '||r.f_table_schema||'.'||r.f_table_name||' DROP CONSTRAINT IF EXISTS '||r.f_foreign_key_column||'_fkey;
	';

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-----------------------------------------
--FUNCTION pghydro.pghfn_AddForeignKeys()
-----------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_AddForeignKeys()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropForeignKeys();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;


    FOR r IN SELECT f_table_catalog, f_table_schema, f_table_name, f_foreign_key_column, f_table_catalog_reference, f_table_schema_reference, f_table_name_reference, f_primary_key_column_reference FROM pghydro.pghtb_foreign_key_columns
    
    LOOP

	EXECUTE '
	ALTER TABLE ONLY '||r.f_table_schema||'.'||r.f_table_name||' ADD CONSTRAINT '||r.f_foreign_key_column||'_fkey FOREIGN KEY ('||r.f_foreign_key_column||') REFERENCES '||r.f_table_schema_reference||'.'||r.f_table_name_reference||'('||r.f_primary_key_column_reference||');
	';


    END LOOP;

  
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropGeometryIndex()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_DropGeometryIndex()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;


    FOR r IN SELECT f_table_schema, f_geometry_column FROM public.geometry_columns
    
    LOOP

	EXECUTE '
	DROP INDEX IF EXISTS '||r.f_table_schema||'.'||r.f_geometry_column||'_idx;
	';

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CreateGeometryIndex()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateGeometryIndex()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropGeometryIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;


    FOR r IN SELECT f_table_schema, f_table_name, f_geometry_column FROM public.geometry_columns
    
    LOOP

	EXECUTE '
	CREATE INDEX '||r.f_geometry_column||'_idx ON '||r.f_table_schema||'.'||r.f_table_name||' USING GIST('||r.f_geometry_column||');
	';

    END LOOP;

  
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_DropIndex()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_DropIndex()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;


    FOR r IN SELECT f_table_schema, f_index_column FROM pghydro.pghtb_index_columns
    
    LOOP

	EXECUTE '
	DROP INDEX IF EXISTS '||r.f_table_schema||'.'||r.f_index_column||'_idx;
	';

    END LOOP;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_CreateIndex()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_CreateIndex()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;


    FOR r IN SELECT f_table_schema, f_table_name, f_index_column, f_index_column_method FROM pghydro.pghtb_index_columns
    
    LOOP

	EXECUTE '
	CREATE INDEX '||r.f_index_column||'_idx ON '||r.f_table_schema||'.'||r.f_table_name||' USING '||r.f_index_column_method||' ('||r.f_index_column||');
	';

    END LOOP;
  
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateGeometrySRID()
----------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_UpdateGeometrySRID()
RETURNS varchar AS
$$
DECLARE

r record;
time_ timestamp;
_srid integer;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS IN : %', time_;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 1 : %', time_;

PERFORM pghydro.pghfn_DropIndex();

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 2 : %', time_;

SELECT srid INTO _srid
FROM geometry_columns
WHERE f_table_name = 'pghft_drainage_line'
AND f_table_schema = 'pghydro';

    FOR r IN SELECT f_table_schema, f_table_name, f_geometry_column FROM public.geometry_columns WHERE srid <> _srid
    
    LOOP

	EXECUTE '
	SELECT UpdateGeometrySRID('||quote_literal(r.f_table_schema)||','||quote_literal(r.f_table_name)||','||quote_literal(r.f_geometry_column)||','||_srid||');
	';

    END LOOP;
  
time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--FUNCTION pghydro.pghfn_TurnOffKeysIndex()
----------------------------------------------------

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


----------------------------------------------------
--FUNCTION pghydro.pghfn_TurnOnKeysIndex()
----------------------------------------------------

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


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_input_data_drainage_line(input_drainage_line_schema varchar, input_drainage_line_table varchar, input_drainage_line_table_geom_atribute varchar, input_drainage_line_table_name_atribute varchar)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_input_data_drainage_line(input_drainage_line_schema varchar, input_drainage_line_table varchar, input_drainage_line_table_geom_atribute varchar, input_drainage_line_table_name_atribute varchar)
RETURNS varchar AS
$$
DECLARE

_srid integer;
time_ timestamp;
r record;

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

SELECT srid INTO _srid
FROM geometry_columns
WHERE f_table_name = input_drainage_line_table 
AND f_table_schema = input_drainage_line_schema;


    FOR r IN SELECT f_table_schema, f_table_name, f_geometry_column FROM public.geometry_columns WHERE srid <> _srid
    
    LOOP

	EXECUTE '
	SELECT UpdateGeometrySRID('||quote_literal(r.f_table_schema)||','||quote_literal(r.f_table_name)||','||quote_literal(r.f_geometry_column)||','||_srid||');
	';

    END LOOP;

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

IF input_drainage_line_table_name_atribute = 'none' THEN

EXECUTE '
INSERT INTO pghydro.pghft_drainage_line (drn_gm)
SELECT '||input_drainage_line_table_geom_atribute||'
FROM '||input_drainage_line_schema||'.'||input_drainage_line_table||';
';

ELSE

EXECUTE '
INSERT INTO pghydro.pghft_drainage_line (drn_nm, drn_gm)
SELECT '||input_drainage_line_table_name_atribute||'::varchar, '||input_drainage_line_table_geom_atribute||'
FROM '||input_drainage_line_schema||'.'||input_drainage_line_table||';
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

EXECUTE '
DROP TABLE IF EXISTS '||input_drainage_line_schema||'.'||input_drainage_line_table||';
';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;
  
END;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_input_data_drainage_area(input_drainage_area_schema varchar, input_drainage_area_table varchar, input_drainage_area_table_geom_atribute varchar)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_input_data_drainage_area(input_drainage_area_schema varchar, input_drainage_area_table varchar, input_drainage_area_table_geom_atribute varchar)
RETURNS varchar AS
$$
DECLARE
r record;
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

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 3 : %', time_;    

--DELETE DATA ON TABLES RELATED TO pghydro.pghft_drainage_area

TRUNCATE pghydro.pghft_drainage_area;

TRUNCATE pghydro.pghft_watershed;

RAISE NOTICE 'BEGIN OF PROCESS 4 : %', time_;

PERFORM pg_catalog.setval('pghydro.dra_pk_seq', 1, false);

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 5 : %', time_;    

SELECT srid INTO _srid
FROM geometry_columns
WHERE f_table_name = input_drainage_area_table --'input_drainage_area_table'
AND f_table_schema = input_drainage_area_schema; --'public';

    FOR r IN SELECT f_table_schema, f_table_name, f_geometry_column FROM public.geometry_columns WHERE srid <> _srid
    
    LOOP

	EXECUTE '
	SELECT UpdateGeometrySRID('||quote_literal(r.f_table_schema)||','||quote_literal(r.f_table_name)||','||quote_literal(r.f_geometry_column)||','||_srid||');
	';

    END LOOP;


--INSERT DATA INTO TABLE pghydro.pghft_drainage_area

EXECUTE '
INSERT INTO pghydro.pghft_drainage_area (dra_gm)
SELECT '||input_drainage_area_table_geom_atribute||'
FROM '||input_drainage_area_schema||'.'||input_drainage_area_table||';
';

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

EXECUTE '
DROP TABLE IF EXISTS '||input_drainage_area_schema||'.'||input_drainage_area_table||';
';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 8 : %', time_;

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;    

--END OF FUNCTION
  
END;

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;

---------------------------------------------------------
--FUNCTION pghydro.pghfn_assign_vertex_id(off_set bigint)
---------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_assign_vertex_id(off_set bigint)
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

EXECUTE '
ALTER SEQUENCE pghydro.drp_pk_seq RESTART WITH '||off_set||';
';

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 11 : %', time_;    

INSERT INTO pghydro.pghft_drainage_point (drp_gm)
SELECT drp_gm
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

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;    

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

-----------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateValence()
-----------------------------------------------------------------------

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

------------------------------------
--FUNCTION pghydro.pghfn_Valence(integer)
------------------------------------

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


-------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateShorelineStartingPoint(integer)
-------------------------------------------------------

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


-------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateShorelineEndingPoint(integer)
-------------------------------------------------------

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



-------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateFlowDirection()
-------------------------------------------------------

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


----------------------------------------------------
--FUNCTION pghydro.pghfn_ReverseDrainageLine()
----------------------------------------------------

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


-------------------------------------------------------
--FUNCTION pghydro.pghfn_FlowDirection(integer)
-------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_FlowDirection(integer)
RETURNS boolean AS
$$
SELECT drn_bo_flowdirection
FROM pghydro.pghft_drainage_line
WHERE drn_pk = $1;
$$
LANGUAGE SQL;



------------------------------------------------------------------
--FUNCTION pghydro.pghfn_AssociateDrainageLine_DrainageArea()
------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_AssociateDrainageLine_DrainageArea()
RETURNS varchar AS
$$
DECLARE

time_ timestamp;

BEGIN

time_ := timeofday();
RAISE NOTICE 'BEGIN OF ALL PROCESS IN : %', time_;    

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

UPDATE pghydro.pghft_drainage_line SET drn_dra_pk = null, drn_rcl_pk_dra = null;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 17 : %', time_;    

UPDATE pghydro.pghft_drainage_line drn
SET drn_dra_pk = hin.hin_dra_pk, drn_rcl_pk_dra = 12
FROM pghydro.pghft_hydro_intel hin
WHERE drn.drn_pk = hin.hin_drn_pk;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 18 : %', time_;    

DROP INDEX IF EXISTS pghydro.hin_drn_pk_idx;

DROP INDEX IF EXISTS pghydro.hin_dra_pk_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_pk_idx;

DROP INDEX IF EXISTS pghydro.dra_gm_idx;

DROP INDEX IF EXISTS pghydro.drn_gm_point_idx;

time_ := timeofday();
RAISE NOTICE 'END OF ALL PROCESS IN : %', time_;    

RETURN 'OK';

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDrainageLineLength(integer, integer)
----------------------------------------------------------------------

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


--------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDrainageAreaArea(integer, integer)
--------------------------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_Downstream_DrainageLines(integer)
----------------------------------------------------------

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


-------------------------------------------------------------------
--FUNCTION pghydro.pghfn_Downstream_DrainageLines(integer, integer)
-------------------------------------------------------------------

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


---------------------------------------------------------
--FUNCTION pghydro.pghfn_DownstreamDrainageLines(integer)
---------------------------------------------------------

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


------------------------------------------------------------
--FUNCTION pghydro.pghfn_numDownstreamDrainageLines(integer)
------------------------------------------------------------

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


-------------------------------------------------------------------
--FUNCTION pghydro.pghfn_DownstreamDrainageLinesN(integer, integer)
-------------------------------------------------------------------

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


------------------------------------------------------------
--FUNCTION pghydro.pghfn_distance_to_mouth(integer, numeric)
------------------------------------------------------------
--DROP FUNCTION pghydro.pghfn_distance_to_mouth(IN integer, OUT distance_to_mouth numeric)


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
LANGUAGE PLPGSQL;


----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLines(integer)
----------------------------------------------------------

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
LANGUAGE PLPGSQL;


------------------------------------------------
--FUNCTION pghydro.pghfn_numUpstreamDrainageLines(integer)
------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLinesN(integer, integer)
----------------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLines(integer, integer)
----------------------------------------------------------

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
LANGUAGE PLPGSQL;


--------------------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLinesArea(integer, numeric)
--------------------------------------------------------------------

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
LANGUAGE PLPGSQL;


----------------------------------------------------------
--FUNCTION pghydro.pghfn_DownstreamDrainageLine(integer)
----------------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpstreamDrainageLine(integer)
----------------------------------------------------------

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


--------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDistanceToSea(numeric)
--------------------------------------------------------


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


----------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateUpstreamArea()
----------------------------------------------------


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

---------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateUpstreamDrainageLine()
---------------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateDownstreamDrainageLine()
----------------------------------------------------------

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


--------------------------------------------------------
--FUNCTION pghydro.pghfn_ExportTopologicalTable(varchar)
--------------------------------------------------------

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


--------------------------------------------------------
--FUNCTION pghydro.pghfn_ImportTopologicalTable(varchar)
--------------------------------------------------------

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


----------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_DrainageLines(integer)
----------------------------------------------------------------

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
LANGUAGE PLPGSQL;

-------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_DrainageLines(integer, integer)
-------------------------------------------------------------------------

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
LANGUAGE PLPGSQL;

--------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_confluences(integer)
--------------------------------------------------------------

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
LANGUAGE PLPGSQL;

-----------------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_confluences(integer, integer)
-----------------------------------------------------------------------

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
LANGUAGE PLPGSQL;

-------------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_4_confluences(in integer)
-------------------------------------------------------------------


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
LANGUAGE PLPGSQL;

-------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_4_confluences(integer, integer)
-------------------------------------------------------------------------

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
LANGUAGE PLPGSQL;


-------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_main_watercourse_9_confluences(integer, integer)
-------------------------------------------------------------------------

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
LANGUAGE PLPGSQL;


-------------------------------------------------------------------
--FUNCTION pghydro.pghfn_pfafstetter_codification(integer, integer)
-------------------------------------------------------------------
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
LANGUAGE PLPGSQL;

--------------------------------------------------------------------
--FUNCTION pghydro.pghfn_pfafstetter_codifications(integer, integer)
--------------------------------------------------------------------
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
LANGUAGE PLPGSQL;

-----------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_Calculate_Pfafstetter_Codification(integer, integer)
-----------------------------------------------------------------------------

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


---------------------------------------------------------------------
--FUNCTION pghydro.pghfn_Calculate_Pfafstetter_Codification()
---------------------------------------------------------------------

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


------------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdatePfafstetterBasinCode(varchar)
------------------------------------------------------------

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


------------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdatePfafstetterWatercourseCode()
------------------------------------------------------------

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


----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatercourse()
----------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevel()
----------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevel()
RETURNS SETOF smallint AS
$$
SELECT DISTINCT dra_nu_pfafstetterbasincodelevel
FROM pghydro.pghft_drainage_area
ORDER BY dra_nu_pfafstetterbasincodelevel;
$$
LANGUAGE SQL;


--------------------------------------------------------
--FUNCTION pghydro.pghfn_numPfafstetterBasinCodeLevel()
--------------------------------------------------------

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


----------------------------------------------------------
--FUNCTION pghydro.pghfn_PfafstetterBasinCodeLevelN(integer)
----------------------------------------------------------

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


--------------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatershedDrainageArea(integer)
--------------------------------------------------------------

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



END;
$$
LANGUAGE PLPGSQL;



----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatershed(integer)
----------------------------------------------------

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

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------------------
--FUNCTION pghydro.pghfn_InsertColumnPfafstetterBasinCodeLevel()
----------------------------------------------------------------

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



END;
$$
LANGUAGE PLPGSQL;


-----------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatercourse_Starting_Point()
-----------------------------------------------------------

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



END;
$$
LANGUAGE PLPGSQL;


---------------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateWatercourse_Ending_Point()
---------------------------------------------------------

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

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateStream_Mouth()
----------------------------------------------------

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

END;
$$
LANGUAGE PLPGSQL;


----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateShoreline()
----------------------------------------------------

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


----------------------------------------------------
--FUNCTION pghydro.pghfn_UpdateDomainColumn()
----------------------------------------------------


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



END;
$$
LANGUAGE PLPGSQL;


------------------------------------------------------------------
--FUNCTION pghydro.pghfn_downstream_drainageline_strahler(integer)
------------------------------------------------------------------

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


------------------------------------------------------------------
--FUNCTION pghydro.pghfn_calculatestrahlernumber()
------------------------------------------------------------------

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
LANGUAGE PLPGSQL;

---------------------------------------------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_VariableToSea(id integer, variable_table varchar, variable_fk varchar, variable_attribute varchar)
---------------------------------------------------------------------------------------------------------------------------

--DROP FUNCTION pghydro.pghfn_VariableToSea(id integer, variable_table varchar, variable_fk varchar, variable_attribute varchar)

CREATE OR REPLACE FUNCTION pghydro.pghfn_VariableToSea(id integer, variable_table varchar, variable_fk varchar, variable_attribute varchar)
RETURNS numeric
AS $$

DECLARE
variable numeric;

BEGIN

EXECUTE '
SELECT COALESCE(sum(c.'||variable_attribute||'),0)
FROM
(

SELECT a.drn_pk, vat.'||variable_attribute||'::numeric
FROM
(
SELECT pghydro.pghfn_downstreamDrainageLines('||id||') as drn_pk
) as a, '||variable_table||' vat
WHERE a.drn_pk = vat.'||variable_fk||'

) as c;
' INTO variable;

RETURN variable;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pghydro.pghfn_VariableToSea(251994, 'pghydro.pghft_sparrow', 'spr_drn_pk', 'spr_nu_tp_eq14');

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateVariableToSea(offset_value numeric, variable_table varchar, variable_fk varchar, variable_attribute varchar, final_variable_attribute varchar)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateVariableToSea(offset_value numeric, variable_table varchar, variable_fk varchar, variable_attribute varchar, final_variable_attribute varchar)
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

j := max(drn_pk) FROM pghydro.pghft_drainage_line;

FOR i IN 1..j LOOP

EXECUTE '

UPDATE '||variable_table||' vat
SET '||final_variable_attribute||' = pghydro.pghfn_VariableToSea('||i||', '''||variable_table||''', '''||variable_fk||''', '''||variable_attribute||''') + '||offset_value||'
FROM pghydro.pghft_drainage_line drn
WHERE drn.drn_pk = '||i||'
AND vat.'||variable_fk||' = '||i||';

';

RAISE NOTICE '%/%', i, j;

END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

SELECT INTO var1 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

IF var1 >=0 THEN

EXECUTE '

UPDATE '||variable_table||' vat
SET '||final_variable_attribute||' = null
FROM
(
SELECT pghydro.pghfn_downstream_drainagelines('||var1||') as drn_pk
UNION
SELECT '||var1||' as drn_pk
) as a
WHERE vat.'||variable_fk||' = a.drn_pk;

';

END IF;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pghydro.pghfn_CalculateVariableToSea('pghydro.pghft_sparrow', 'spr_drn_pk', 'spr_nu_tp_eq14');

-------------------------------------------------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_VariableUpstream(id integer, variable_table varchar, variable_fk varchar, variable_attribute varchar)
-------------------------------------------------------------------------------------------------------------------------------

--DROP FUNCTION pghydro.pghfn_VariableUpstream(id integer, variable_table varchar, variable_fk varchar, variable_attribute varchar)

CREATE OR REPLACE FUNCTION pghydro.pghfn_VariableUpstream(id integer, variable_table varchar, variable_fk varchar, variable_attribute varchar)
RETURNS numeric
AS $$

DECLARE
variable numeric;

BEGIN

EXECUTE '
SELECT COALESCE(sum(c.'||variable_attribute||'),0)
FROM
(
SELECT a.drn_pk, vat.'||variable_attribute||'::numeric
FROM
(
SELECT pghydro.pghfn_upstreamDrainageLines('||id||') as drn_pk
) as a, '||variable_table||' vat
WHERE a.drn_pk = vat.'||variable_fk||'
) as c;
' INTO variable;

RETURN variable;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pghydro.pghfn_VariableUpstream(5, 'pghydro.pghft_drainage_line', 'drn_pk', 'drn_gm_length');

------------------------------------------------------------------------------------------------------------------------------------
--FUNCTION pghydro.pghfn_CalculateVariableUpstream(variable_table varchar, variable_fk varchar, variable_attribute varchar)
------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pghydro.pghfn_CalculateVariableUpstream(offset_value numeric, variable_table varchar, variable_fk varchar, variable_attribute varchar, final_variable_attribute varchar)
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

j := max(drn_pk) FROM pghydro.pghft_drainage_line;

FOR i IN 1..j LOOP

EXECUTE '

UPDATE '||variable_table||' vat
SET '||final_variable_attribute||' = pghydro.pghfn_VariableUpstream('||i||', '''||variable_table||''', '''||variable_fk||''', '''||variable_attribute||''') + '||offset_value||'
FROM pghydro.pghft_drainage_line drn
WHERE drn.drn_pk = '||i||'
AND vat.'||variable_fk||' = '||i||';

';

RAISE NOTICE '%/%', i, j;

END LOOP;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 6 : %', time_;

SELECT INTO var1 ssp_drn_pk FROM pghydro.pghft_shoreline_starting_point;

IF var1 >=0 THEN

EXECUTE '

UPDATE '||variable_table||' vat
SET '||final_variable_attribute||' = '||variable_attribute||'
FROM
(
SELECT pghydro.pghfn_downstream_drainagelines('||var1||') as drn_pk
UNION
SELECT '||var1||' as drn_pk
) as a
WHERE vat.'||variable_fk||' = a.drn_pk;

';

END IF;

time_ := timeofday();
RAISE NOTICE 'BEGIN OF PROCESS 7 : %', time_;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_sourcenode_idx;

DROP INDEX IF EXISTS pghydro.drn_drp_pk_targetnode_idx;

DROP INDEX IF EXISTS pghydro.drn_pk_idx;

RETURN 'OK';

time_ := timeofday();
RAISE NOTICE 'END OF PROCESS IN : %', time_;

END;
$$
LANGUAGE PLPGSQL;

--SELECT pghydro.pghfn_CalculateVariableUpstream('pghydro.pghft_drainage_area', 'dra_drn_pk', 'dra_gm_area');