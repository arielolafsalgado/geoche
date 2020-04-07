#' Corrobora las ubicaciones genericas de GOOGLE
#' @description La funcion genera en el archivo de datos una columna indicando si la ubicacion lonlat de cada fila es generica o no.
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param ubicaciones_genericas_ggmap El dataset con las ubicaciones genericas para ggmap
#' @param campos_genericos1 Los campos a partir de los cuales reconstruir la ubicación generica
#' @param campos_genericos2 Los campos a partir de los cuales reconstruir la ubicación generica, en una segunda versión
#' @param lolat_columns Las columnas en las que se encuentras las ubicaciones lon y lat
#' @param text_a_eliminar El texto a ser eliminado en la construcción de las ubicaciones genericas. Por default c('*SIN DATO* (*SIN DATO*)','NULL')
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return El mismo data frame, pero con una columna nueva que indica si pasó el check
#' @export
check_ubicacion_generica_ggmap = function(data_ggmap,ubicaciones_genericas_ggmap,campos_genericos1,campos_genericos2,lonlat_columns=c('LON_RESIDENCIA','LAT_RESIDENCIA'),texto_a_eliminar=c('*SIN DATO* (*SIN DATO*)','NULL'),verbose=T){
  data_ggmap$MATCH_GENERICO = NA
  for(row_ggmap in 1:nrow(data_ggmap)){
    if(verbose) print(paste('Checkeando fila',row_ggmap,'GGMAP'))
    latlon = data_ggmap[row_ggmap,lonlat_columns]
    if(all(!is.na(latlon))){
      text1 = data_ggmap[row_ggmap,campos_genericos1]
      text1[is.element(text1,texto_a_eliminar)] = ''
      text2 = data_ggmap[row_ggmap,campos_genericos2]
      text2[is.element(text2,texto_a_eliminar)] = ''
      busqueda1 = paste(c('ARGENTINA',text1),collapse=', ')
      busqueda1 = gsub('CABA, CIUDAD DE BUENOS AIRES','CIUDAD DE BUENOS AIRES',busqueda1)
      busqueda1 = gsub('CABA','CIUDAD DE BUENOS AIRES',busqueda1)
      busqueda1 = gsub('(, )\\1+', '\\1', busqueda1)
      busqueda2 = paste(c('ARGENTINA',text2),collapse=', ')
      busqueda2 = gsub('CABA, CIUDAD DE BUENOS AIRES','CIUDAD DE BUENOS AIRES',busqueda2)
      busqueda2 = gsub('CABA','CIUDAD DE BUENOS AIRES',busqueda2)
      busqueda2 = gsub('(, )\\1+', '\\1', busqueda2)
      busqueda1 = toupper(gsub(', $','',busqueda1))
      busqueda2 = toupper(gsub(', $','',busqueda2))
      match_ids = agrep(busqueda1,ubicaciones_genericas_ggmap$BUSQUEDA,ignore.case = T)
      match_ids = unique(c(match_ids,agrep(busqueda2,ubicaciones_genericas_ggmap$BUSQUEDA,ignore.case = T)))
      if(length(match_ids)>0){
        match_generico = ubicaciones_genericas_ggmap$lon[match_ids]==latlon[1] & ubicaciones_genericas_ggmap$lat[match_ids]==latlon[2]
        result = any(match_generico)
      }else{
        result = FALSE
      }
    }else{
      result = NA
    }
    data_ggmap$MATCH_GENERICO[row_ggmap] = result
  }
  return(data_ggmap)
}
