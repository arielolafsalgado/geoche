#' Compruebas las ubicaciones genericas de OSM
#' @description La funcion genera en el archivo de datos una columna indicando si la ubicacion lonlat de cada fila es generica o no.
#' @param data_osm El dataset con las ubicaciones obtenidas por osm
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param ubicaciones_genericas_osm El dataset con las ubicaciones genericas para osm
#' @param campos_genericos1 Los campos a partir de los cuales reconstruir la ubicación generica
#' @param campos_genericos2 Los campos a partir de los cuales reconstruir la ubicación generica, en una segunda versión
#' @param lolat_columns Las columnas en las que se encuentras las ubicaciones lon y lat
#' @param text_a_eliminar El texto a ser eliminado en la construcción de las ubicaciones genericas. Por default c('*SIN DATO* (*SIN DATO*)','NULL')
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @param invertir Dado que la lógica de construccion de busqueda es Prefijo-Campo1-Campo2-...-CampoN, con esta opción se puede invertir la construccion a CampoN-...-Campo1-Prefijo. Por default, FALSE
#' @return El mismo data frame, pero con una columna nueva que indica si pasó el check
#' @export
check_ubicacion_generica_osm = function(data_osm,data_ggmap,ubicaciones_genericas_osm,campos_genericos1,campos_genericos2,lonlat_columns=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),texto_a_eliminar=c('*SIN DATO* (*SIN DATO*)','NULL'),verbose=T,invertir=F){
  data_osm$MATCH_GENERICO = NA
  for(row_osm in 1:nrow(data_osm)){
    if(verbose) print(paste('Checkeando fila',row_osm,'OSM'))
    latlon = data_osm[row_osm,lonlat_columns]
    if(all(!is.na(latlon))){
      row_ggmap = which(data_osm$IDEVENTOCASO[row_osm]==data_ggmap$IDEVENTOCASO)
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
      if(invertir){
        b1 = str_split(busqueda1,', ')
        b1 = sapply(b1,funciton(q) paste(rev(q),collapse=', '))
        busqueda1 = b1
      }
      if(invertir){
        b2 = str_split(busqueda2,', ')
        b2 = sapply(b2,funciton(q) paste(rev(q),collapse=', '))
        busqueda2 = b2
      }
      match_ids = agrep(busqueda1,ubicaciones_genericas_osm$BUSQUEDA,ignore.case = T)
      match_ids = unique(c(match_ids,agrep(busqueda2,ubicaciones_genericas_osm$BUSQUEDA,ignore.case = T)))
      if(length(match_ids)>0){
        match_generico = ubicaciones_genericas_osm$lon[match_ids]==latlon[1] & ubicaciones_genericas_osm$lat[match_ids]==latlon[2]
        result = any(match_generico)
      }else{
        result = FALSE
      }
    }else{
      result = NA
    }
    data_osm$MATCH_GENERICO[row_osm] = result
  }
  return(data_osm)
}
