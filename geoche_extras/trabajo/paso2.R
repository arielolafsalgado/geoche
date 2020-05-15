require(geoche)
inputArchivo = 'bases/ejemplo/ejemplo.csv'
departamentos_path = 'shp/departamentos/censo_por_departamento_polígonos.shp'
depto_id_column='ID_DEPTO_INDEC_RESIDENCIA'
output = checkea_departamentos_ggmap_y_osm(inputArchivo,departamentos_path,depto_id_column)
