#' Comprueba consistencia entre los departamentos y las posiciones georreferenciadas (OSM)
#' @description Esta función toma un data frame, y un objeto sf con los departamentos, y checkea que las ubicaciones coincidan con los departamentos esperados
#' @param data_osm El data frame de osm con ubicaciones
#' @param data_ggmap El data frame de ggmap con ubicaciones, y provincias asociadas
#' @param departamentos El objeto SF que contiene los poligonos de los departamentos. Se asume que tiene una columna "link" con los ids del indec del departamento.
#' @param depto_id_colum La columna en la que está el id del departamento en data_ggmap
#' @param lonlat_column Las columnas lon y lat en las que están las ubicaciones del caso en data_osm
#' @param id_column Columna para vincular los casos en data_ggmap con los casos en data_osm. Por default IDEVENTOCASO
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return  Un data frame identico a data_osm, pero que también contiene una columna con TRUE,FALSE,NA segun cumpla o no el criterio, o no se haya podido checkear.
#' @export
check_departamentos_osm = function(data_osm,data_ggmap,departamentos,depto_id_column='ID_DEPTO_INDEC_RESIDENCIA',lonlat_columns=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),id_column='IDEVENTOCASO',verbose=T){
  data_osm$LAT_LON_EN_DEPARTAMENTO = NA
  data_osm$LAT_LON_DEPARTAMENTO = NA
  data_osm$LAT_LON_PROVINCIA = NA
  for(row_osm in 1:nrow(data_osm)){
    row_ggmap = which(data_ggmap[,id_column]==data_osm[row_osm,id_column])
    depto_id = as.numeric(data_ggmap[row_ggmap,depto_id_column])
    if(is.na(depto_id)){
      if(verbose) print(paste('Fila',row_osm,'de OSM con ID VACIO'))
      result = NA
      provincia_ll = NA
      depto_ll = NA
    }else{
      if(all(!is.na(data_osm[row_osm,lonlat_columns]))){
        punto = st_as_sf(data_osm[row_osm,],crs=4326,coords=lonlat_columns)
        depto_idx = which(as.numeric(depto_id)==as.numeric(departamentos$link))
        if(length(depto_idx)>0){
          subSF = departamentos[depto_idx,]
          inters = st_intersects(st_transform(punto,crs=22185),st_transform(subSF,crs=22185),sparse=F)
          result = inters
          if(result){
            provincia_ll = subSF$provincia
            depto_ll = subSF$departamen
          }else{
            provincia_ll = NA
            depto_ll = NA
          }
          if(verbose) print(paste('Fila',row_osm,'de OSM', ifelse(result,'ESTA EN','NO ESTA EN'),'DEPARTAMENTOS'))
        }else{
          if(verbose) print(paste('Fila',row_osm,'de OSM', 'SIN ID DEPARTAMENTO'))
          result = NA
          provincia_ll = NA
          depto_ll = NA
        }
      }else{
        if(verbose) print(paste('Fila',row_osm,'de OSM sin LAT-LON'))
        result=NA
        provincia_ll = NA
        depto_ll = NA
      }
    }
    data_osm$LAT_LON_EN_DEPARTAMENTO[row_osm] = result
    data_osm$LAT_LON_DEPARTAMENTO[row_osm] = toupper(depto_ll)
    data_osm$LAT_LON_PROVINCIA[row_osm] = toupper(provincia_ll)
  }
  return(data_osm)
}
