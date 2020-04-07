#' Comprueba cercanía con el punto de atención (OSM)
#' @description La funcion genera en el archivo de datos una columna indicando si la ubicacion lonlat de cada fila esta lo suficientemente cerca del hospital o no.
#' @param data_osm El dataset con las ubicaciones obtenidas por OSM
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param hospis_datos_shp Un vector con nombres en los establecimientos clinicos de data_ggmap, y valores en las filas correspondientes en hospitales
#' @param hospitales Un objeto SF con los puntos de los hospitales
#' @param max_distancia La máxima distancia aceptable a la que puede estar el hospital, en metros
#' @param lonlat_columns Las columnas en las que se encuentras las ubicaciones lon y lat
#' @param hospi_name_column La columna que contiene el nombre de las clinicas en data_ggmap
#' @param id_column Columna para vincular data_ggmap con data_osm. Por default IDEVENTOCASO
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return El mismo data frame, pero con una columna nueva que indica si pasó el check
#' @export
checkea_clinica_osm = function(data_osm,data_ggmap,hospis_datos_shp,hospitales,max_distancia=200*1000,lonlat_columns=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),hospi_name_column='ESTAB_CLINICA',id_column='IDEVENTOCASO',verbose=T){
  data_osm$CERCA_CLINICA = NA
  for(row_osm in 1:nrow(data_osm)){
    row_ggmap = which(data_ggmap[,id_column]==data_osm[row_osm,id_column])
    hospi = data_ggmap[row_ggmap,hospi_name_column]
    if(!is.na(hospis_datos_shp[hospi])){
      if(all(!is.na(data_osm[row_osm,lonlat_columns]))){
        punto = st_as_sf(data_osm[row_osm,],crs=4326,coords=lonlat_columns)
        punto_hospi = hospitales[hospis_datos_shp[hospi],]
        distancia = st_distance(st_transform(punto,crs=22185),st_transform(punto_hospi,crs=22185),sparse=F)
        result = as.numeric(distancia) <=max_distancia
        if(verbose) print(paste('Fila',row_osm,'de OSM', ifelse(result,'ESTA CERCA','NO ESTA CERCA'),'DE SU CLINICA'))
      }else{
        if(verbose) print(paste('Fila',row_osm,'de OSM sin LAT-LON'))
        result=NA
      }
    }else{
      if(verbose) print(paste('Fila de OSM',row_osm,'NO HAY UBICACION DE SU CLINICA'))
      result = NA
    }
    data_osm$CERCA_CLINICA[row_osm] = result
  }
  return(data_osm)
}
