# Avid Geo Meetup

[at MAPC, June 14th 2012, about MAPC's Basemap toolchain](http://www.meetup.com/avidgeo/events/65674052/)

Agenda, in a nutshell:

1. [MassGIS data](http://www.mass.gov/mgis/massgis.htm) - public domain data
2. [TileMill](http://mapbox.com/tilemill/) - cartography studio
3. [TileStache](http://tilestache.org/) - simple tile server
4. [Amazon S3](http://aws.amazon.com/s3/) - efficient storage
5. [Leaflet](http://leaflet.cloudmade.com/) - client map

## Our Basemap

<iframe src="http://tiles.mapc.org/basemap.html#zoom=10&amp;lat=42.35752&amp;lon=-71.06097" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" width="600" height="400"></iframe>

**Why create and host our own basemap?**  

It's easy enough, doesn't require much resources and gives us most flexibility for our online maps.

Find the TileMill project (with branches for the Trailmap or Parkmap) in our [GitHub repository](https://github.com/MAPC/basemap).

[Instructions](https://gist.github.com/2923720) about how to include MAPC layers in your own mapping project.

## Data

Get it from [MassGIS data](http://www.mass.gov/mgis/massgis.htm) or OpenStreetMap (e.g. [Metro Extracts](http://metro.teczno.com/) and [Imposm](http://imposm.org/docs/imposm/latest/) is a good start)

Create a Postgres/PostGIS database, noticeable faster than Shapefiles, and load some data:

... import Shapefiles

    $ createdb -T template_postgis -O avidgeo avidgeo
    $ shp2pgsql -s 26986 -I myshape.shp public.myshape | psql -d avidgeo

...or load the prepared dump file

    $ createdb -T template0 -O avidgeo avidgeo
    $ pg_restore -d avidgeo -O avidgeo.dump

## Cartography

Know CSS and GIS? Use [TileMill](http://mapbox.com/tilemill/)!

For MassGIS data you'll need to add the Spatial Reference:

    +proj=lcc +lat_1=42.68333333333333 +lat_2=41.71666666666667 +lat_0=41 +lon_0=-71.5 +x_0=200000 +y_0=750000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs

Export your map as Mapnik XML style file or readily rendered MBTiles.

## Tile Rendering

TileStache is a lightweight tile server, supporing a range of data providers - MBTiles, Vector (PostGIS, GeoJSON, Shapefiles), Mapnik, etc. - and caches - Memcache, Disk, Amazon S3.

Run the server for on-demand Tile rendering behind your web server:

    HTTP request <=> Web Server <=proxy=> WSGI server <=> TileStache

e.g. at MAPC we use a combination of [Nginx](http://nginx.org/) as web server, [Gunicorn](http://gunicorn.org/) as WSGI and [TileStache](http://tilestache.org/) as tile server.

Sample TileStache configuration for rendering to the disk cache and adding the avidgeo mapnik xml:

    {
      "cache": {
        "name": "Disk",
        "path": "/home/avidgeo/www",
        "umask": "0000",
        "dirs": "portable"
      },
      "layers": 
      {
        "avidgeo":
        {
            "provider": {"name": "mapnik", "mapfile": "avidgeo.xml"},
            "projection": "spherical mercator",
            "metatile":
              {
                "rows": 4,
                "columns": 4,
                "buffer": 128
              },
            "preview":
              {
                "lat": 42.3551,
                "lon": -71.0618,
                "zoom": 14,
                "ext": "png"
              }
        }
      }
    }


For production, pre-seed tiles to Amazon S3 and turn tile server off. S3 is great for serving static tiles and will save you some resources.

    $ tilestache-seed.py -x -c tilestache-s3.cfg -l basemap -b 40.59 -75.58 43.98 -69.98 9 10

**Extra points**: add [UTFGrid](http://mapbox.com/developers/utfgrid/) tiles for attribute data in your raster map.

## Client side map

Most JavaScript mapping libraries can consume tile server. Below is a simple example using Leaflet:

    var avidgeo = new L.TileLayer('http://render.mapc.org/avidgeo/{z}/{x}/{y}.png', {
        attribution: 'Tiles: MAPC, Data: MassGIS',
        maxZoom: 18
    });

    var map = new L.Map("map",{
        minZoom: 14,
        maxZoom: 18
    })
    .setView(new L.LatLng(42.3551, -71.0618), 14)
    .addLayer(avidgeo);

[Wax](http://mapbox.com/wax/) will allow you're client map to consume UTFGrid tiles.
