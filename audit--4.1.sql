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
--PgHYDRO Audit Scheme version 4.1 of 30/08/2016
---------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS pghtb_audit_drainage_line ON pghydro.pghft_drainage_line;

DROP TRIGGER IF EXISTS pghtb_audit_drainage_area ON pghydro.pghft_drainage_area;

DROP FUNCTION IF EXISTS pghydro.pghfn_audit_drainage_line();

DROP FUNCTION IF EXISTS pghydro.pghfn_audit_drainage_area();

DROP VIEW IF EXISTS pghydro.pghvw_DrainageLineDeleted;

DROP VIEW IF EXISTS pghydro.pghvw_DrainageAreaDeleted;

DROP TABLE IF EXISTS pghydro.pghtb_audit_drainage_line;

DROP TABLE IF EXISTS pghydro.pghtb_audit_drainage_area;

CREATE TABLE pghydro.pghtb_audit_drainage_line(
    ads_operation         char(1),
    ads_stamp             timestamp,
    ads_userid            text,
    ads_drn_pk            integer,
    ads_drn_nm            text,
    ads_drn_nm_old        text,
    ads_drn_gm            geometry
);


CREATE OR REPLACE FUNCTION pghydro.pghfn_audit_drainage_line() RETURNS TRIGGER AS $pghtb_audit_drainage_line$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO pghydro.pghtb_audit_drainage_line(ads_operation, ads_stamp, ads_userid, ads_drn_pk, ads_drn_nm, ads_drn_gm)
            SELECT 'D', now(), user, OLD.drn_pk, OLD.drn_nm, OLD.drn_gm;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO pghydro.pghtb_audit_drainage_line(ads_operation, ads_stamp, ads_userid, ads_drn_pk, ads_drn_nm, ads_drn_nm_old, ads_drn_gm)
            SELECT 'U', now(), user, NEW.drn_pk, NEW.drn_nm, OLD.drn_nm, NEW.drn_gm;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO pghydro.pghtb_audit_drainage_line(ads_operation, ads_stamp, ads_userid, ads_drn_pk, ads_drn_nm, ads_drn_gm)
            SELECT 'I', now(), user, NEW.drn_pk, NEW.drn_nm, NEW.drn_gm;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$pghtb_audit_drainage_line$ LANGUAGE plpgsql;

CREATE TRIGGER pghtb_audit_drainage_line
AFTER INSERT OR UPDATE OR DELETE ON pghydro.pghft_drainage_line
    FOR EACH ROW EXECUTE PROCEDURE pghydro.pghfn_audit_drainage_line();

CREATE TABLE pghydro.pghtb_audit_drainage_area(
    adh_operation         char(1),
    adh_stamp             timestamp,
    adh_userid            text,
    adh_dra_pk           integer,
    adh_dra_gm           geometry
);


CREATE OR REPLACE FUNCTION pghydro.pghfn_audit_drainage_area() RETURNS TRIGGER AS $pghtb_audit_drainage_area$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO pghydro.pghtb_audit_drainage_area SELECT 'D', now(), user, OLD.dra_pk, OLD.dra_gm;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO pghydro.pghtb_audit_drainage_area SELECT 'U', now(), user, NEW.dra_pk, NEW.dra_gm;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO pghydro.pghtb_audit_drainage_area SELECT 'I', now(), user, NEW.dra_pk, NEW.dra_gm;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$pghtb_audit_drainage_area$ LANGUAGE plpgsql;

CREATE TRIGGER pghtb_audit_drainage_area
AFTER INSERT OR UPDATE OR DELETE ON pghydro.pghft_drainage_area
    FOR EACH ROW EXECUTE PROCEDURE pghydro.pghfn_audit_drainage_area();

---------------------------------------
--VIEW pghydro.pghvw_DrainagelineDeleted
---------------------------------------

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageLineDeleted AS
SELECT ads_drn_pk as drn_pk, ads_stamp, ads_userid, ads_drn_nm as drn_nm, ads_drn_gm as drn_gm
FROM pghydro.pghtb_audit_drainage_line
WHERE ads_operation = 'D';

---------------------------------------
--VIEW pghydro.pghvw_DrainageAreaDeleted
---------------------------------------

CREATE OR REPLACE VIEW pghydro.pghvw_DrainageAreaDeleted AS
SELECT adh_dra_pk as dra_pk, adh_stamp, adh_userid, adh_dra_gm as dra_gm
FROM pghydro.pghtb_audit_drainage_area
WHERE adh_operation = 'D';
