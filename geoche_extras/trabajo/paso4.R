require(geoche)
inputArchivo = 'bases/ejemplo/ejemplo.csv'

ubicaciones_genericas_ggmap_path = 'ubicaciones_genericas/ubicaciones_genericas_ggmap.csv'
ubicaciones_genericas_osm_path = 'ubicaciones_genericas/ubicaciones_genericas_osm.csv'
campos_genericos1 = c("PROVINCIA_RESIDENCIA","LOCALIDAD_RESIDENCIA")
campos_genericos2 = c("PROVINCIA_RESIDENCIA","DEPARTAMENTO_RESIDENCIA","LOCALIDAD_RESIDENCIA")
prefijo = 'ARGENTINA'
timeout = 5
apikey = readLines("apikey.txt")
id_column = 'IDEVENTOCASO'
output = check_ubicacion_generica_ggmap_y_osm(inputArchivo,ubicaciones_genericas_ggmap_path,ubicaciones_genericas_osm_path,campos_genericos1,campos_genericos2,prefijo,id_column,apikey,timeout=timeout)
