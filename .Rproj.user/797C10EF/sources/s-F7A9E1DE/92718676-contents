#' Comprueba cercanía con el punto de atencion (GOOGLE)
#' @description La funcion genera en el archivo de datos una columna indicando si la ubicacion lonlat de cada fila esta lo suficientemente cerca del hospital o no.
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param hospis_datos_shp Un vector con nombres en los establecimientos clinicos de data_ggmap, y valores en las filas correspondientes en hospitales
#' @param hospitales Un objeto SF con los puntos de los hospitales
#' @param max_distancia La máxima distancia aceptable a la que puede estar el hospital, en metros
#' @param lolat_columns Las columnas en las que se encuentras las ubicaciones lon y lat
#' @param hospi_name_column La columna que contiene el nombre de las clinicas en data_ggmap
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return El mismo data frame, pero con una columna nueva que indica si pasó el check, y además la posición lonlat de la clinica
checkea_clinica_ggmap = function(data_ggmap,hospis_datos_shp,hospitales,max_distancia=200*1000,lonlat_columns=c('LON_RESIDENCIA','LAT_RESIDENCIA'),hospi_name_column='ESTAB_CLINICA',verbose=T){
  data_ggmap$CERCA_CLINICA = NA
  data_ggmap$LAT_CLINICA = NA
  data_ggmap$LON_CLINICA = NA
  for(row_ggmap in 1:nrow(data_ggmap)){
    hospi = data_ggmap[row_ggmap,hospi_name_column]
    if(!is.na(hospis_datos_shp[hospi])){
      if(all(!is.na(data_ggmap[row_ggmap,lonlat_columns]))){
        punto = st_as_sf(data_ggmap[row_ggmap,],crs=4326,coords=lonlat_columns)
        punto_hospi = hospitales[hospis_datos_shp[hospi],]
        distancia = st_distance(st_transform(punto,crs=22185),st_transform(punto_hospi,crs=22185),sparse=F)
        result = as.numeric(distancia) <=max_distancia
        if(verbose) print(paste('Fila',row_ggmap,'de ggmap', ifelse(result,'ESTA CERCA','NO ESTA CERCA'),'DE SU CLINICA'))
        ll_clinica = st_coordinates(punto_hospi)
        data_ggmap$LAT_CLINICA[row_ggmap] = ll_clinica[2]
        data_ggmap$LON_CLINICA[row_ggmap] = ll_clinica[1]
      }else{
        if(verbose) print(paste('Fila',row_ggmap,'de ggmap sin LAT-LON'))
        result=NA
      }
    }else{
      if(verbose) print(paste('Fila de GGMAP',row_ggmap,'NO HAY UBICACION DE SU CLINICA'))
      result = NA
    }
    data_ggmap$CERCA_CLINICA[row_ggmap] = result
  }
  return(data_ggmap)
}
