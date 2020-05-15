#' Comprueba que las ubicaciones obtenidas no sean genericas
#' @description Esta función calcula la georreferenciación de los datos mediante ggmap y osm
#' @param inputArchivo El path al archivo de datos
#' @param campos_genericos1  Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param campos_genericos2 Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param prefijo Si se desea, se puede agregar un prefijo al texto de busqueda
#' @param apikey  La clave api de google. Por default, busca apikey.txt
#' @param write.it Debe escribirse el resultado? Por default TRUE
#' @param verbose Boleano, ¿debe indicarse el resultado? Por default TRUE
#' @param timeout La cantidad de tiempo máxima a esperar por busqueda en OSM
#' @description Esta función calcula la georreferenciación de los datos mediante osm y devuelve el data frame, con columnas LAT_RESIDENCIA_OSM y LON_RESIDENCIA_OSM.
#' @return Devuelve una lista con ambos datasets
#' @export
check_ubicacion_generica_ggmap_y_osm = function(inputArchivo = 'bases/ejemplo/ejemplo.csv',ubicaciones_genericas_ggmap_path = 'ubicaciones_genericas/ubicaciones_genericas_ggmap.csv',ubicaciones_genericas_osm_path = 'ubicaciones_genericas/ubicaciones_genericas_osm.csv',campos_genericos1=c("Localidad","Calle","Número"),campos_genericos2=c("Partido","Localidad","Calle","Número"),prefijo='ARGENTINA',id_column='IDEVENTOCASO',apikey  = readLines('apikey.txt'),write.it=T,verbose=T,timeout=5,texto_a_eliminar=c('*SIN DATO* (*SIN DATO*)','NULL'),lonlat_columns_ggmap=c('LON_RESIDENCIA','LAT_RESIDENCIA'),lonlat_columns_osm=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM')){
  inputGGMAP = sub('.csv','_georrefGGMAP.csv',inputArchivo)
  inputOSM = sub('.csv','_georrefOSM.csv',inputArchivo)
  data_ggmap = read.csv(inputGGMAP,stringsAsFactors=F)
  data_osm = read.csv(inputOSM,stringsAsFactors=F)

  # Me fijo que estén todas las que nos interesan:
  loc_genericas = genera_loc_domicilios(data_ggmap,campos_genericos1,prefijo = prefijo)
  loc_genericas = c(loc_genericas,genera_loc_domicilios(data_ggmap,campos_genericos2,prefijo = prefijo))
  loc_genericas = unique(loc_genericas)
  ubicaciones_genericas_ggmap = actualiza_ubicaciones_genericas_ggmap(loc_genericas,ubicaciones_genericas_ggmap_path,apikey)
  ubicaciones_genericas_osm = actualiza_ubicaciones_genericas_osm(loc_genericas,ubicaciones_genericas_osm_path,timeout = timeout)

  if(file.exists(ubicaciones_genericas_ggmap_path)){
    data_ggmap = check_ubicacion_generica_ggmap(data_ggmap,ubicaciones_genericas_ggmap,campos_genericos1,campos_genericos2,lonlat_columns_ggmap,texto_a_eliminar,verbose)
  }else{
    print('No existe archivo de ubicaciones genericas para GOOGLE')
  }
  if(file.exists(ubicaciones_genericas_osm_path)){
    data_osm = check_ubicacion_generica_osm(data_osm,data_ggmap,ubicaciones_genericas_osm,campos_genericos1,campos_genericos2,lonlat_columns_osm,texto_a_eliminar,verbose)
  }else{
    print('No existe archivo de ubicaciones genericas para OSM')
  }

  # GUARDO LOS DATOS
  if(write.it){
    write.csv(data_ggmap,inputGGMAP,row.names=F)
    write.csv(data_osm,inputOSM,row.names=F)
  }
  #BALANCE
  if(verbose){
    print('RESUMEN UBICACIONES GENERICAS:')
    print('GGMAP DIO UBICACIONES GENERICAS?')
    print(table(data_ggmap$MATCH_GENERICO,useNA='ifany'))
    if(!file.exists(ubicaciones_genericas_ggmap_path)) print('No existe archivo de ubicaciones genericas para GOOGLE')
    print('OSM DIO UBICACIONES GENERICAS?')
    print(table(data_osm$MATCH_GENERICO,useNA='ifany'))
    if(!file.exists(ubicaciones_genericas_osm_path)) print('No existe archivo de ubicaciones genericas para OSM')

  }
  return(list('ggmap'=data_ggmap,'osm'=data_osm))

}
