#' Georreferencia usando ggmap
#' @description Esta función calcula la georreferenciación de los datos mediante ggmap y devuelve el data frame, con columnas LAT_RESIDENCIA y LON_RESIDENCIA.
#' @param inputArchivo El path al archivo de datos
#' @param campos_a_domicilio Los campos del dataset en los cuales se encuentra la dirección. Deben ser indicados de mayor a menor, de país a numero. Por default c("Localidad","Calle","Número")
#' @param prefijo_domicilio Si se desea, se puede agregar un prefijo al texto de busqueda
#' @param apikey  La clave api de google. Por default, busca apikey.txt
#' @param sep El separador de columnas en inputArchivo
#' @param write.it Debe escribirse el resultado? Por default TRUE
#' @param verbose Boleano, ¿debe indicarse el resultado? Por default TRUE
#' @return Devuelve el dataset con las columnas agregadas.
#' @export
georreferencia_ggmap = function(inputArchivo = sub('.csv','_recortados.csv','bases/francoA/ListadoA.csv'),campos_a_domicilio=c("Localidad","Calle","Número"),prefijo_domicilio='ARGENTINA',apikey  = readLines('apikey.txt'),sep=',',write.it=T,verbose=T){
  require(stringr)
  require(ggmap)
  register_google(key = apikey)
  datos = read.csv(inputArchivo,stringsAsFactors=F,sep=sep)
  campos_a_domicilio_no_estan = campos_a_domicilio[!is.element(campos_a_domicilio),colnames(datos)]
  if(length(campos_a_domicilio_no_estan)>0){
    print(paste('Warning: Los campos',paste(campos_a_domicilio_no_estan,collapse=', '),'no estan en el dataset. Continuando con los que si estan'))
  }
  campos_a_domicilio = campos_a_domicilio[is.element(campos_a_domicilio),colnames(datos)]
  if(length(campos_a_domicilio)>0){
    loc_domicilio = genera_loc_domicilios(datos,campos_a_domicilio,sep = ', ',prefijo = prefijo_domicilio)
    latlon_google = geocode(loc_domicilio)
    datos$LAT_RESIDENCIA = latlon_google$lat
    datos$LON_RESIDENCIA = latlon_google$lon
    datos$BUSQUEDA_RESIDENCIA = loc_domicilio
    if(write.it) write.csv(datos,sub('.csv','_georrefGGMAP.csv',inputArchivo),row.names=F)
    if(verbose){
      print('GEORREFERENCIACION GGMAP:')
      print(paste('SE ENCONTRARON',!is.na(latlon_google$lat),'UBICACIONES'))
      print('CADA UNA PARA UN CASO DISTINTO')
      print(paste('% DE CASOS CON UNA UBICACION:',round(sum(!is.na(latlon_google$lat))/nrow(datos),3)*100))
      if(length(campos_a_domicilio_no_estan)>0){
        print(paste('Warning: Los campos',paste(campos_a_domicilio_no_estan,collapse=', '),'no estaban presentes y no fueron considerados.'))
      }
    }
  }else{
    print('ERROR: Ninguno de los campos de domicilio ingresados está en los datos')
  }
  return(datos)
}

