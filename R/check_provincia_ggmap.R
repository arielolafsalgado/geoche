#' Comprueba consistencia entre la provincia y las posiciones georreferenciadas (GOOGLE)
#' @description Esta función toma un data frame, y un objeto sf con las provincias, y checkea que las ubicaciones coincidan con las provincias esperadas
#' @param data_ggmap El data frame con ubicaciones, y provincias asociadas
#' @param provincias El objeto SF que contiene los poligonos de las provincias. Se asume que tiene una columna "link" con los ids del indec de la provincia.
#' @param prov_id_colum La columna en la que está el id de la provincia en data_ggmap
#' @param lonlat_column Las columnas lon y lat en las que están las ubicaciones del caso
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @param crs Sistema coordenado de referencia sobre el cual buscar las intersecciones. Por default 22185
#' @return Un data frame identico a data_ggmap, pero que también contiene una columna con TRUE,FALSE,NA segun cumpla o no el criterio, o no se haya podido checkear.
#' @export
check_provincia_ggmap = function(data_ggmap,provincias,prov_id_column='ID_PROV_INDEC_RESIDENCIA',lonlat_columns=c('LON_RESIDENCIA','LAT_RESIDENCIA'),verbose=T,crs=22185){
  data_ggmap$LAT_LON_EN_PROVINCIA = NA # Una columna en la que voy a anotar el éxito de la búsqueda
  for(row_ggmap in 1:nrow(data_ggmap)){
    prov_id = as.numeric(data_ggmap[row_ggmap,prov_id_column])
    if(is.na(prov_id)){
      if(verbose) print(paste('Fila',row_ggmap,'de ggmap con ID VACIO'))
      result = NA
    }else{
      if(all(!is.na(data_ggmap[row_ggmap,lonlat_columns]))){
        punto = st_as_sf(data_ggmap[row_ggmap,],crs=4326,coords=lonlat_columns)
        prov_idx = which(as.numeric(prov_id)==as.numeric(provincias$link))
        if(length(prov_idx)>0){
          subSF = st_combine(provincias[prov_idx,])
          result = st_intersects(st_transform(punto,crs=crs),st_transform(subSF,crs=crs),sparse=F)
          if(verbose)   print(paste('Fila',row_ggmap,'de ggmap', ifelse(result,'ESTA EN','NO ESTA EN'),'PROVINCIA'))
        }else{
          if(verbose) print(paste('Fila',row_ggmap,'de ggmap', 'SIN ID PROVINCIA'))
          result = NA
        }
      }else{
        if(verbose) print(paste('Fila',row_ggmap,'de ggmap sin LAT-LON'))
        result=NA
      }
    }
    data_ggmap$LAT_LON_EN_PROVINCIA[row_ggmap] = result
  }
  return(data_ggmap)
}
