# PGHYDRO - PostgreSQL/PostGIS extension for Water Resources Decision Making
PgHydro extends the PostGIS/PostgreSQL geospatial database to provide drainage network analysis functionality to support decision making in Water Resources.

# STATUS

## Branches

The master branch has the latest minor release. (6.6)

The develop branch has the next minor release. (6.7-dev)

# INTRODUCTION

PgHydro extends the PostGIS/PostgreSQL geospatial database to provide drainage network analysis functionality to support decision making in Water Resources.

Hydrographic objects are all  tables, constrains, procedures, queries, functions or views developed in PostGIS/PostgreSQL in order to build a consistent river network and calculates the correct direction of flow vector water, Otto Pfafstetter’s basin coding system, selection of  upstream/downstream stretches, distance to the the mouth of the basin, upstream calculation area, river orders, basin levels, and other information to assist in decision making in water resources.

# REQUIREMENTS

Postgresql version 9.1+

PostGIS version 3.x

PostGIS Raster

## INSTALLATION (v.6.6)

1 - Download the last pghydro stable release file Source code (zip) from the site https://github.com/pghydro/pghydro/releases

2 - Unzip, copy and paste *.sql and *.control files to \PostgreSQL\x.x\share\extension

Postgresql 9.1+

	createdb mydatabase
	psql mydatabase -c "CREATE EXTENSION postgis"
	psql mydatabase -c "CREATE EXTENSION postgis_raster"
	psql mydatabase -c "CREATE EXTENSION pghydro"
	psql mydatabase -c "CREATE EXTENSION pgh_raster"
	psql mydatabase -c "CREATE EXTENSION pgh_hgm"
	psql mydatabase -c "CREATE EXTENSION pgh_consistency"
	psql mydatabase -c "CREATE EXTENSION pgh_output"
	

## Tutorial (v.6.6) - Also can be used for versions 6.2 or 6.4

Youtube: https://www.youtube.com/channel/UCgkCUQ-i72bBY41a1bhVWyw

## Notes

IMPORTANT : the changes are made in the current project, and will be saved only if you save the project.

Previous versions 6.2 and 6.4 still works with PostgreSQL 9-11 and PostGIS 2.x.

PGHYDRO (extension for PostgreSQL/PostGIS) works better with PgQGIS PgHydroTools Plugin (https://github.com/pghydro/pghydrotools).

## Authors

Alexandre de Amorim Teixeira

## Licence

PgHydro is Open Source, available under the GPLv2 license and is supported by a growing community of individuals, companies and organizations with an interest in management and decision making in water resources.
