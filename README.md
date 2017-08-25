# PGHYDRO - PostgreSQL/PostGIS extension for Water Resources Decision Making
PgHydro extends the PostGIS/PostgreSQL geospatial database to provide drainage network analysis functionality to support decision making in Water Resources.

# STATUS

## Branches

The master branch has the latest minor release. (6.0)

The develop branch has the next minor release. (6.0.1-dev)

# INTRODUCTION

PgHydro extends the PostGIS/PostgreSQL geospatial database to provide drainage network analysis functionality to support decision making in Water Resources.

Hydrographic objects are all  tables, constrains, procedures, queries, functions or views developed in PostGIS/PostgreSQL in order to build a consistent river network and calculates the correct direction of flow vector water, Otto Pfafstetter’s basin coding system, selection of  upstream/downstream stretches, distance to the the mouth of the basin, upstream calculation area, river orders, basin levels, and other information to assist in decision making in water resources.

# REQUIREMENTS

Postgresql version = postgresql-9.3.5-3-windows-x64
(https://drive.google.com/file/d/0B2u6WhefYxhZMmlPazUwR2pZYWs/view?usp=sharing)

PostGIS version = postgis-bundle-pg93x64-setup-2.1.4-1
(https://drive.google.com/file/d/0B2u6WhefYxhZdTIyVlRBWllPeXc/view?usp=sharing)

## INSTALLATION (v.6.0)

Download the files below and copy the content to \PostgreSQL\x.x\share\extension

(https://drive.google.com/drive/folders/0B2u6WhefYxhZR1QyY24wYUV6WnM?usp=sharing)

Postgresql 9.1+

	createdb mydatabase
	psql mydatabase -c "CREATE EXTENSION postgis"
	psql mydatabase -c "CREATE EXTENSION pghydro"
	psql mydatabase -c "CREATE EXTENSION pghconsistency"
	psql mydatabase -c "CREATE EXTENSION pgh_output"

## Notes

IMPORTANT : the changes are made in the current project, and will be saved only if you save the project.

## Authors

Alexandre de Amorim Teixeira

## Licence

PgHydro is Open Source, available under the GPLv2 license and is supported by a growing community of individuals, companies and organizations with an interest in management and decision making in water resources.
