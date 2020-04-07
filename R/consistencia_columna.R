#' Verifica consistencia entre la ubicación y la provincia esperada
#' @description Esta funcion chequea la consistencia con el testeo presentado en una columna.
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param data_osm El dataset con las ubicaciones obtenidas por OSM
#' @param row_ggmap La fila de data_ggmap a ser considerada
#' @param row_osm Las filas de data_osm asociadas a row_ggmap
#' @param na.value Como consideran en terminos de puntaje aquellos checkeos que hayan dado NA. Por default, es FALSE
#' @return Un vector con TRUE y FALSE según si pasó o no el criterio. En caso de ser NA se asigna na.value
#' @export
calcula_consistencia_columna = function(data_ggmap,data_osm,row_ggmap,row_osm,na.value,columna='LAT_LON_EN_PROVINCIA'){
  L = length(row_ggmap) + length(row_osm)
  if(all(!is.null(data_ggmap[,columna]))){
    consistencia = rep(NA,L)
    consistencia[1] = data_ggmap[row_ggmap,columna]
    consistencia[2:L] = data_osm[row_osm,columna]
    consistencia[is.na(consistencia)] = na.value
  }else{
    consistencia = rep(na.value,L)
  }
  return(consistencia)
}
