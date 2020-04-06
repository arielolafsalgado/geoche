#' Comprueba consistencia entre la provincia y las posiciones georreferenciadas (OSM)
#' @description Esta función toma un data frame, y un objeto sf con las provincias, y checkea que las ubicaciones coincidan con las provincias esperadas
#' @param data_osm El data frame de osm con ubicaciones
#' @param data_ggmap El data frame de ggmap con ubicaciones, y provincias asociadas
#' @param provincias El objeto SF que contiene los poligonos de las provincias. Se asume que tiene una columna "link" con los ids con los cuales comparar en data_ggmap.
#' @param prov_id_colum La columna en la que está el id de la provincia en data_ggmap
#' @param lonlat_column Las columnas lon y lat en las que están las ubicaciones del caso en data_osm
#' @param id_column Columna para vincular los casos en data_ggmap con los casos en data_osm. Por default IDEVENTOCASO
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return Un data frame identico a data_osm, pero que también contiene una columna con TRUE,FALSE,NA segun cumpla o no el criterio, o no se haya podido checkear.
check_provincia_osm = function(data_osm,data_ggmap,provincias,prov_id_column='ID_PROV_INDEC_RESIDENCIA',lonlat_columns=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),verbose=T,id_column='IDEVENTOCASO'){
  data_osm$LAT_LON_EN_PROVINCIA = NA
  for(row_osm in 1:nrow(data_osm)){
    row_ggmap = which(data_ggmap[,id_column]==data_osm[row_osm,id_column])
    prov_id = as.numeric(data_ggmap[row_ggmap,prov_id_column])
    if(is.na(prov_id)){
      if(verbose) print(paste('Fila',row_osm,'de OSM con ID VACIO'))
      result = NA
    }else{
      if(all(!is.na(data_osm[row_osm,lonlat_columns]))){
        punto = st_as_sf(data_osm[row_osm,],crs=4326,coords=lonlat_columns)
        prov_idx = which(as.numeric(prov_id)==as.numeric(provincias$link))
        if(length(prov_idx)>0){
          subSF = st_combine(provincias[prov_idx,])
          result = st_intersects(st_transform(punto,crs=22185),st_transform(subSF,crs=22185),sparse=F)
          if(verbose)  print(paste('Fila',row_osm,'de OSM', ifelse(result,'ESTA EN','NO ESTA EN'),'PROVINCIA'))
        }else{
          if(verbose) print(paste('Fila',row_osm,'de OSM', 'SIN ID PROVINCIA'))
          result = NA
        }
      }else{
        if(verbose) print(paste('Fila',row_osm,'de OSM sin LAT-LON'))
        result=NA
      }
    }
    data_osm$LAT_LON_EN_PROVINCIA[row_osm] = result
  }
  return(data_osm)
}
