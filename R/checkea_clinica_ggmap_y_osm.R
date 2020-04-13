#' Comprueba cercanía con el punto de atencion
#' @description Realiza la validación de las posiciones en base a la provincia indicada.
#' @param inputArchivo Path a partir del cual construir los paths para ggmap y osm. El archivo que fue usado para construirlos.
#' @param hospitales_path Path al archivo shp de las provincias. Por default 'shp/provincias/provincias.shp'
#' @param hospi_name_column Columna con el id de las provincias, por default 'ID_PROVINCIA'
#' @param lonlat_columns_ggmap Columnas con las ubicaciones lon y lat de las filas en data_ggmap. Por default c('LON_RESIDENCIA','LAT_RESIDENCIA')
#' @param lonlat_columns_osm Columnas con las ubicaciones lon y lat de las filas en data_osm. Por default c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM')
#' @param id_column Columna con los ids en el archivo OSM. Por default, 'IDEVENTOCASO'
#' @param write.it Se deben escribir los archivos? Por default TRUE
#' @param verbose Booleano ¿debe imprimir el progreso? Default TRUE
#' @return Una lista con ambos data frames.
#' @export
checkea_clinica_ggmap_y_osm = function(inputArchivo = 'bases/Base_p_ariel_y_yamila.csv',hospitales_path='shp/hospitales/ListadoREFES.shp',hospi_name_column='ESTAB_CLINICA',lonlat_columns_ggmap=c('LON_RESIDENCIA','LAT_RESIDENCIA'),lonlat_columns_osm=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),max_distancia = 200*1000,id_column='IDEVENTOCASO',write.it=T,verbose=T){
  require(sf)
  inputGGMAP = sub('.csv','_georrefGGMAP.csv',inputArchivo)
  inputOSM = sub('.csv','_georrefOSM.csv',inputArchivo)
  data_ggmap = read.csv(inputGGMAP,stringsAsFactors=F)
  data_osm = read.csv(inputOSM,stringsAsFactors=F)
  hospitales = read_sf(hospitales_path)
  hospis_datos_shp = asocia_hospitales_data_a_hospitales_refes(data_ggmap,hospitales,hospi_name_column=hospi_name_column)
  data_ggmap = checkea_clinica_ggmap(data_ggmap,hospis_datos_shp,hospitales,max_distancia,lonlat_columns=lonlat_columns_ggmap,hospi_name_column,verbose)
  data_osm = checkea_clinica_osm(data_osm,data_ggmap,hospis_datos_shp,hospitales,max_distancia,lonlat_columns=lonlat_columns_osm,hospi_name_column,id_column,verbose)




  ## RESUMEN
  if(verbose){
    print('RESUMEN CLINICAS:')
    print('En datos GGMAP, estaban cerca de su clinica:')
    print(table(data_ggmap$CERCA_CLINICA,useNA='ifany'))
    print('En datos OSM, estaban cerca de su clinica:')
    print(table(data_osm$CERCA_CLINICA,useNA='ifany'))
  }
  # Guardo
  if(write.it){
    write.csv(data_ggmap,inputGGMAP,row.names=F)
    write.csv(data_osm,inputOSM,row.names=F)
  }
  return(list('ggmap'=data_ggmap,'osm'=data_osm))

}
