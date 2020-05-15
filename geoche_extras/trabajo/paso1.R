require(geoche)
apikey  = readLines('apikey.txt')
inputArchivo = 'bases/ejemplo/ejemplo.csv'

campos_a_domicilio = c("PROVINCIA_RESIDENCIA",
                       "LOCALIDAD_RESIDENCIA",
                       "CALLE_DOMICILIO",
                       "NUMERO_DOMICILIO")

campos_a_domicilio2 = c("PROVINCIA_RESIDENCIA",
                       "DEPARTAMENTO_RESIDENCIA",
                       "CALLE_DOMICILIO",
                       "NUMERO_DOMICILIO")

prefijo_domicilio = 'ARGENTINA'
id_column = 'IDEVENTOCASO'
timeout = 5
output = georreferencia_ggmap_y_osm(inputArchivo,campos_a_domicilio,campos_a_domicilio2,prefijo_domicilio,id_column,apikey,timeout,sep=',')
