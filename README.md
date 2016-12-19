# pghydro
PgHydro extends the PostGIS/PostgreSQL geospatial database to provide drainage network analysis functionality to support decision making in Water Resources.

# STATUS

## Branches

The master branch reflects the current 5.4 release. The develop branch reflects the 5.5-dev

# LINKS

http://pghydro.org/

http://pghydro.org/documentation/

http://pghydro.org/downloads/

# INTRODUCTION

PgHydro extends the PostGIS/PostgreSQL geospatial database to provide drainage network analysis functionality to support decision making in Water Resources.

Hydrographic objects are all  tables, constrains, procedures, queries, functions or views developed in PostGIS/PostgreSQL in order to build a consistent river network and calculates the correct direction of flow vector water, Otto Pfafstetter’s basin coding system, selection of  upstream/downstream stretches, distance to the the mouth of the basin, upstream calculation area, river orders, basin levels, and other information to assist in decision making in water resources.

# REQUIREMENTS

Postgresql version >= 9.1

PostGIS version >= 2.0

## INSTALLATION

Copy the content of this repository to \PostgreSQL\x.x\share\extension

Postgresql 9.1+

	createdb mydatabase
	psql mydatabase -c "CREATE EXTENSION postgis"
	psql mydatabase -c "CREATE EXTENSION pghydro"

## Notes

IMPORTANT : the changes are made in the current project, and will be saved only if you save the project.

## Authors

Alexandre de Amorim Teixeira

## Licence

PgHydro is Open Source, available under the GPLv2 license and is supported by a growing community of individuals, companies and organizations with an interest in management and decision making in water resources.
