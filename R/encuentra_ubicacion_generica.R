#' Encuentra las ubicaciones latlon asociadas a un conjunto de datos
#' @description Esta función toma el data frame datos y ciertos campos del mismo, y encuentra sus ubicaciones genericas.
#' @param datos Un data frame con los campos_a_domicilio presentes
#' @param campos_genericos Los campos a ser pegados
#' @param ubicaciones_genericas_path El path al archivo con las ubicaciones genericas.
#' @param texto_a_eliminar Texto a ser omitido en caso de ser encontrado (por comparación exacta). Por default c('*SIN DATO* (*SIN DATO*)','NULL',paste('COMUNA',1:20))
#' @param prefijo Un campo de texto a ser agregado previo al resto. Por default "ARGENTINA"
#' @param sep El separador a ser usado cuando se peguen los campos. Por default ", "
#' @param campoNumero Campo con el número de la calle
#' @param apikey  La clave api de google. Por default, busca apikey.txt
#' @param invertir Dado que la lógica de construccion de busqueda es Prefijo-Campo1-Campo2-...-CampoN, con esta opción se puede invertir la construccion a CampoN-...-Campo1-Prefijo. Por default, FALSE
#' @return El mismo dataset, pero con columnas LAT_GENERICA y LON_GENERICA
#' @export
encuentra_ubicacion_generica_ggmap = function(data_ggmap,campos_genericos,ubicaciones_genericas_path,prefijo='ARGENTINA',apikey=readLines('apikey.txt'),invertir=F){
  campos_genericos_ausentes = setdiff(campos_genericos,colnames(data_ggmap))
  if(length(campos_genericos_ausentes)>0){
    print('Hay campos que no están presentes. Continuando con el resto')
    campos_genericos = intersect(campos_genericos,colnames(data_ggmap))
  }
  if(file.exists(ubicaciones_genericas_path)){
    ubicaciones_genericas_ggmap = read.csv(ubicaciones_genericas_path,stringsAsFactors=F)
    loc_genericas = genera_loc_domicilios(data_ggmap,campos_genericos,prefijo = prefijo,invertir=invertir)
    loc_genericas = str_trim(loc_genericas)
    loc_genericas = gsub(',$','',loc_genericas)
    ubicaciones_genericas_ggmap$BUSQUEDA=gsub(',$','',str_trim(toupper(ubicaciones_genericas_ggmap$BUSQUEDA)))
    data_generica = ubicaciones_genericas_ggmap[match(gsub(',','',loc_genericas),gsub(',','',ubicaciones_genericas_ggmap$BUSQUEDA)),]
    if(any(is.na(data_generica$lat))){
      print('Agregando campos nuevos')
      loc_genericas_sub = loc_genericas[is.na(data_generica$lat)]
      actualiza_ubicaciones_genericas_ggmap(loc_genericas_sub,ubicaciones_genericas_path,apikey)
      ubicaciones_genericas_ggmap = read.csv(ubicaciones_genericas_path,stringsAsFactors=F)
      ubicaciones_genericas_ggmap$BUSQUEDA=gsub(',$','',str_trim(toupper(ubicaciones_genericas_ggmap$BUSQUEDA)))
      data_generica = ubicaciones_genericas_ggmap[match(gsub(',','',loc_genericas),gsub(',','',ubicaciones_genericas_ggmap$BUSQUEDA)),]
    }
    colnames(data_generica) = c('LON_GENERICA','LAT_GENERICA','BUSQUEDA_GENERICA')
    data_ggmap = cbind(data_ggmap,data_generica)
    data_ggmap$BUSQUEDA_GENERICA = loc_genericas
  }else{
    print('ERROR: archivo de ubicaciones genericas no existe')
  }
  return(data_ggmap)
}
