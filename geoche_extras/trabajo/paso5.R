require(geoche)
inputArchivo = 'bases/ejemplo/ejemplo.csv'
hospitales_path = 'shp/hospitales/hospitales.shp'
hospi_name_column='ESTABLECIMIENTO_CARGA'
max_distancia = 200*1000 # 200km
output = checkea_clinica_ggmap_y_osm(inputArchivo,hospitales_path,hospi_name_column,max_distancia = max_distancia)
