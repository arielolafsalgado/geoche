#' Georreferencia usando tmaptools
#' @description Esta función calcula la georreferenciación de los datos mediante osm y devuelve el data frame, con columnas LAT_RESIDENCIA_OSM y LON_RESIDENCIA_OSM.
#' @param inputArchivo El path al archivo de datos
#' @param campos_a_domicilio Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param campos_a_domicilio2 Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param prefijo_domicilio Si se desea, se puede agregar un prefijo al texto de busqueda
#' @param sep El separador de columnas en inputArchivo
#' @param write.it Debe escribirse el resultado? Por default TRUE
#' @param verbose Boleano, ¿debe indicarse el resultado? Por default TRUE
#' @return Devuelve el dataset con las columnas agregadas.
#' @export
georreferencia_osm = function(inputArchivo = sub('.csv','_recortados.csv','bases/francoA/ListadoA.csv'),id_column='IDEVENTOCASO',campos_a_domicilio=c("Localidad","Calle","Número"),campos_a_domicilio2=c("Partido","Localidad","Calle","Número"),prefijo_domicilio='ARGENTINA',sep=',',write.it=T,verbose=T,timeout=5){
  require(stringr)
  datos = read.csv(inputArchivo,stringsAsFactors=F,sep=sep)
  campos_a_domicilio_no_estan = campos_a_domicilio[!is.element(campos_a_domicilio),colnames(datos)]
  if(length(campos_a_domicilio_no_estan)>0){
    print(paste('Warning: Los campos',paste(campos_a_domicilio_no_estan,collapse=', '),'no estan en el dataset. Continuando con los que si estan'))
  }
  campos_a_domicilio = campos_a_domicilio[is.element(campos_a_domicilio),colnames(datos)]
  if(length(campos_a_domicilio)>0){
    loc_domicilio = genera_loc_domicilios(datos,campos_a_domicilio,prefijo=prefijo_domicilio)
    output_dom = geocode_OSM_ariel(loc_domicilio = loc_domicilio,timeout=timeout)
    aun_por = setdiff(1:nrow(datos),output_dom$fila)
    loc_domicilio2 = genera_loc_domicilios(datos[aun_por,],campos_a_domicilio2,prefijo = prefijo_domicilio)
    output_dom2 = geocode_OSM_ariel(loc_domicilio2,aun_por = aun_por,timeout = max(timeout/2,1),verbose=verbose)
    # ACOMODO VARIABLES PARA MANTENER COMPATIBILIDAD
    output_dom = rbind(output_dom,output_dom2)
    if(is.null(output_dom)){
      output_dom = data.frame('LON_RESIDENCIA_OSM'=numeric(),'LAT_RESIDENCIA_OSM'=numeric())
      output_dom[,id_column] = numeric()
    }else{
      output_dom[,id_column] = datos[output_dom$fila,id_column]
      output_dom$LON_RESIDENCIA_OSM = output_dom$x
      output_dom$LAT_RESIDENCIA_OSM = output_dom$y
      output_dom = output_dom[,intersect(colnames(output_dom),c(id_column,'LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'))]
    }
    if(write.it) write.csv(output_dom,sub('.csv','_georrefOSM.csv',inputArchivo),row.names=F)

    # RESUMEN
    if(verbose){
      print('RESUMEN GEORREFERENCIACION OSM:')
      print(paste('SE ENCONTRARON',nrow(output_dom),'UBICACIONES'))
      print(paste('PARA',length(unique(output_dom[,id_column])),'CASOS DISTINTOS'))
      print(paste('% de casos con al menos un caso:',round(length(unique(output_dom[,id_column]))/nrow(datos),3)*100))
    }
  }else{
    print('ERROR: Ninguno de los campos de domicilio ingresados está en los datos')
  }
  return(output_dom)
}
