#' Genera dos archivos con las georreferenciaciones obtenidas
#' @description Esta función calcula la georreferenciación de los datos mediante ggmap y osm
#' @param inputArchivo El path al archivo de datos
#' @param campos_a_domicilio Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param campos_a_domicilio2 Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param prefijo_domicilio Si se desea, se puede agregar un prefijo al texto de busqueda
#' @param apikey  La clave api de google. Por default, busca apikey.txt
#' @param sep El separador de columnas en inputArchivo
#' @param write.it Debe escribirse el resultado? Por default TRUE
#' @param verbose Boleano, ¿debe indicarse el resultado? Por default TRUE
#' @param timeout La cantidad de tiempo máxima a esperar por busqueda en OSM
#' @description Esta función calcula la georreferenciación de los datos mediante osm y devuelve el data frame, con columnas LAT_RESIDENCIA_OSM y LON_RESIDENCIA_OSM.
#' @return Devuelve una lista con ambos datasets
#' @export
georreferencia_ggmap_y_osm = function(inputArchivo = sub('.csv','_recortados.csv','bases/francoA/ListadoA.csv'),campos_a_domicilio=c("Localidad","Calle","Número"),campos_a_domicilio2=c("Partido","Localidad","Calle","Número"),prefijo_domicilio='ARGENTINA',id_column='IDEVENTOCASO',apikey  = readLines('apikey.txt'),sep=',',write.it=T,verbose=T,timeout=5){
  d1 = georreferencia_ggmap(inputArchivo,campos_a_domicilio,prefijo_domicilio,apikey,sep,write.it,verbose)
  d2 = georreferencia_osm(inputArchivo,id_column,campos_a_domicilio,campos_a_domicilio2,prefijo_domicilio,sep,write.it,verbose,timeout)
  return(list('ggmap'=d1,'osm'=d2))
}
