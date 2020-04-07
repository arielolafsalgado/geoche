#' Comprueba consistencia entre los departamentos y las posiciones georreferenciadas (GOOGLE)
#' @description Esta función toma un data frame, y un objeto sf con los departamentos, y checkea que las ubicaciones coincidan con los departamentos esperados
#' @param data_ggmap El data frame con ubicaciones, y provincias asociadas
#' @param departamentos El objeto SF que contiene los poligonos de los departamentos. Se asume que tiene una columna "link" con los ids del indec del departamento.
#' @param depto_id_colum La columna en la que está el id del departamento en data_ggmap
#' @param lonlat_column Las columnas lon y lat en las que están las ubicaciones del caso
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return  Un data frame identico a data_ggmap, pero que también contiene una columna con TRUE,FALSE,NA segun cumpla o no el criterio, o no se haya podido checkear.
#' @export
check_departamentos_ggmap = function(data_ggmap,departamentos,depto_id_column='ID_DEPTO_INDEC_RESIDENCIA',lonlat_columns=c('LON_RESIDENCIA','LAT_RESIDENCIA'),verbose=TRUE){
  data_ggmap$LAT_LON_EN_DEPARTAMENTO = NA # Una columna en la que voy a anotar el éxito de la búsqueda
  data_ggmap$LAT_LON_DEPARTAMENTO = NA
  data_ggmap$LAT_LON_PROVINCIA = NA
  for(row_ggmap in 1:nrow(data_ggmap)){
    depto_id = as.numeric(data_ggmap[row_ggmap,depto_id_column])
    if(is.na(depto_id)){
      if(verbose) print(paste('Fila',row_ggmap,'de ggmap con ID VACIO'))
      result = NA
      provincia_ll = NA
      depto_ll = NA
    }else{
      if(all(!is.na(data_ggmap[row_ggmap,lonlat_columns]))){
        punto = st_as_sf(data_ggmap[row_ggmap,],crs=4326,coords=lonlat_columns)
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
          if(verbose) print(paste('Fila',row_ggmap,'de ggmap', ifelse(result,'ESTA EN','NO ESTA EN'),'DEPARTAMENTO'))
        }else{
          if(verbose) print(paste('Fila',row_ggmap,'de ggmap', 'SIN ID DEPARTAMENTO'))
          result = NA
          provincia_ll = NA
          depto_ll = NA
        }
      }else{
        if(verbose) print(paste('Fila',row_ggmap,'de ggmap sin LAT-LON'))
        result=NA
        provincia_ll = NA
        depto_ll = NA
      }
    }
    data_ggmap$LAT_LON_EN_DEPARTAMENTO[row_ggmap] = result
    data_ggmap$LAT_LON_DEPARTAMENTO[row_ggmap] = toupper(depto_ll)
    data_ggmap$LAT_LON_PROVINCIA[row_ggmap] = toupper(provincia_ll)
  }
  return(data_ggmap)
}
