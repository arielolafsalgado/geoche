require(geoche)
inputArchivo = 'bases/ejemplo/ejemplo.csv'
provincias_path = 'shp/provincias/provincias.shp'
prov_id_column='ID_PROVINCIA_INDEC'
output = checkea_provincia_ggmap_y_osm(inputArchivo,provincias_path,prov_id_column)

