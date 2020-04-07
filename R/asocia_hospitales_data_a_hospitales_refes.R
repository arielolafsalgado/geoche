#' Asocia clinicas con un archivo de referencia mediante asociación de texto
#' @description Esta función auxiliar encuentra las filas asociadas en el shp hospitales a los hospitales en data_ggmap
#' @param data_ggmap El dataset con las ubicaciones obtenidas por ggmap
#' @param hospi_name_column La columna que contiene el nombre de las clinicas en data_ggmap
#' @param hospitales Objecto sf conteniendo las ubicaciones de los hospitales.
#' @return Una lista con las filas de hospitales, nombrada con los hospitales en data_ggmap
#' @export
asocia_hospitales_data_a_hospitales_refes = function(data_ggmap,hospitales,hospi_name_column='ESTAB_CLINICA'){
  hospis_datos = unique(data_ggmap[,hospi_name_column])
  hospis_datos_shp = sapply(hospis_datos,function(hospi){
    idx = match(hospi,hospitales$Nombre)
    if(length(idx)>0){
      result = idx
    }else{
      idx = agrep(hospi,hospitales$Nombre)
      if(length(idx)==1){
        result = idx
      }else{
        result = NA
      }
    }
    return(result)
  })
  names(hospis_datos_shp) = hospis_datos
  return(hospis_datos_shp)
}
