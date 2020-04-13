#' Comprueba consistencia entre la provincia y las posiciones georreferenciadas
#' @description Realiza la validación de las posiciones en base a la provincia indicada.
#' @param inputArchivo Path a partir del cual construir los paths para ggmap y osm. El archivo que fue usado para construirlos.
#' @param provincias_path Path al archivo shp de las provincias. Por default 'shp/provincias/provincias.shp'
#' @param prov_id_column Columna con el id de las provincias, por default 'ID_PROVINCIA'
#' @param lonlat_columns_ggmap Columnas con las ubicaciones lon y lat de las filas en data_ggmap. Por default c('LON_RESIDENCIA','LAT_RESIDENCIA')
#' @param lonlat_columns_osm Columnas con las ubicaciones lon y lat de las filas en data_osm. Por default c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM')
#' @param crs crs usado para buscar la interseccion. Por default 22185
#' @param id_column Columna con los ids en el archivo OSM. Por default, 'IDEVENTOCASO'
#' @param verbose Booleano ¿debe imprimir el progreso? Default TRUE
#' @param write.it Se deben escribir los archivos? Por default TRUE
#' @return Una lista con ambos data frames.
#' @export
checkea_provincia_ggmap_y_osm = function(inputArchivo = 'bases/Base_p_ariel_y_yamila.csv',provincias_path='shp/provincias/provincias.shp',prov_id_column='ID_PROVINCIA',lonlat_columns_ggmap=c('LON_RESIDENCIA','LAT_RESIDENCIA'),lonlat_columns_osm=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),crs=22185,id_column='IDEVENTOCASO',verbose=T,write.it=T){
  require(sf)
  inputGGMAP = sub('.csv','_georrefGGMAP.csv',inputArchivo)
  inputOSM = sub('.csv','_georrefOSM.csv',inputArchivo)
  data_ggmap = read.csv(inputGGMAP,stringsAsFactors=F)
  data_osm = read.csv(inputOSM,stringsAsFactors=F)
  provincias = read_sf(provincias_path) # El shp de las provincias
  data_ggmap = check_provincia_ggmap(data_ggmap,provincias,prov_id_column=prov_id_column,lonlat_columns=lonlat_columns_ggmap,verbose=verbose,crs=crs)
  data_osm = check_provincia_osm(data_osm,data_ggmap,provincias,prov_id_column=prov_id_column,lonlat_columns=lonlat_columns_osm,verbose=verbose,id_column=id_column)

  ## RESUMEN
  if(verbose){
    print(paste('RESUMEN PROVINCIAS:'))
    print('El punto estaba dentro de la pronvincia (GGMAP)?')
    print(table(data_ggmap$LAT_LON_EN_PROVINCIA,useNA="ifany"))
    print('El punto estaba dentro de la pronvincia (OSM)?')
    print(table(data_osm$LAT_LON_EN_PROVINCIA,useNA="ifany"))
  }
  if(write.it){
    write.csv(data_ggmap,inputGGMAP,row.names=F)
    write.csv(data_osm,inputOSM,row.names=F)
  }
  return(list('ggmap'=data_ggmap,'osm'=data_osm))
}
