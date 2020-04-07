#' Calcula el puntaje de consistencia de distancia entre las ubicaciones encontradas.
#' @description Esta funcion revisa que sean consistentes los puntos ubicados por ggmap y tmaptools
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param data_osm El dataset con las ubicaciones obtenidas por OSM
#' @param row_ggmap La fila de data_ggmap a ser considerada
#' @param row_osm Las filas de data_osm asociadas a row_ggmap
#' @param lonlat_columns_ggmap Las columnas en las que se encuentras las ubicaciones lon y lat en data_ggmap
#' @param lonlat_columns_osm Las columnas en las que se encuentras las ubicaciones lon y lat en data_osm
#' @param max_dist La máxima distancia aceptable puede estar una ubicacion de las otras
#' @param id_column Columna para vincular data_ggmap con data_osm. Por default IDEVENTOCASO
#' @return Un vector de longitud igual al numero de filas considerado, indicando lejos de cuantos puntos se encontraba cada ubicacion.
#' @export
calcula_consistencia_distancia = function(data_ggmap,data_osm,row_ggmap,row_osm,lonlat_columns_ggmap,lonlat_columns_osm,id_column,max_dist){
  if(all(!is.na(data_ggmap[row_ggmap,lonlat_columns_ggmap]))){
    sf_ggmap = st_as_sf(data_ggmap[row_ggmap,],coords=lonlat_columns_ggmap,crs=4326)
    sf_osm = st_as_sf(data_osm[row_osm,],coords=lonlat_columns_osm,crs=4326)
    sf_ll = rbind(sf_ggmap[,c('geometry',id_column)],sf_osm[,c('geometry',id_column)])
    # Reviso la consistencia entre las variables, que esten juntos los puntos
    # que esten cerca del hospital, etc
    result = sapply(1:nrow(sf_ll),function(row_ll){
      sf1 = sf_ll[row_ll,]
      sf2 = sf_ll[setdiff(1:nrow(sf_ll),row_ll),]
      distancias = as.numeric(st_distance(sf1,sf2)) # CALCULO LAS DISTANCIAS EN METROS
      pasa = sum(distancias>=max_dist) # ME FIJO SI AL MENOS UNA PASA EL CRITERIO
      return(pasa)
    })
  }else{
    sf_osm = st_as_sf(data_osm[row_osm,],coords=lonlat_columns_osm,crs=4326)
    result = sapply(1:nrow(sf_osm),function(row_ll){
      sf1 = sf_osm[row_ll,]
      sf2 = sf_osm[setdiff(1:nrow(sf_osm),row_ll),]
      distancias = as.numeric(st_distance(sf1,sf2)) # CALCULO LAS DISTANCIAS EN METROS
      pasa = sum(distancias>=max_dist) # ME FIJO SI AL MENOS UNA PASA EL CRITERIO
      return(pasa)
    })
    result = c(length(result),result)
  }
  return(result)
}
