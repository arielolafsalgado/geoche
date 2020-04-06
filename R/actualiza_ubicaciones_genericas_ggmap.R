#' Actualiza y genera el listado de ubicaciones genericas
#' @description Esta función actualiza y carga la base de datos de ubicaciones genericas de google maps
#' @param loc_genericas Las ubicaciones genericas a ser buscadas
#' @param ubicaciones_genericas_path El path hacia el archivo de ubicaciones genericas. Si no existe, se creará en ese lugar el archivo nuevo.
#' @param apikey La clave api para las busquedas en google. Por default, espera que se encuentre en un archivo llamado "apikey.txt"
#' @return Un data frame con las ubicaciones genericas cargadas
actualiza_ubicaciones_genericas_ggmap = function(loc_genericas,ubicaciones_genericas_path='ubicaciones_genericas_ggmap.csv',apikey=readLines('apikey.txt')){
  require(stringr)
  ubicaciones_genericas_ggmap = NULL
  if(file.exists(ubicaciones_genericas_path)){
    ubicaciones_genericas_ggmap = read.csv(ubicaciones_genericas_path,stringsAsFactors=F)
  }
  loc_genericas = str_trim(loc_genericas)
  ubicaciones_genericas_ggmap$BUSQUEDA=str_trim(ubicaciones_genericas_ggmap$BUSQUEDA)
  loc_genericas=gsub(',$','',loc_genericas)
  ubicaciones_genericas_ggmap$BUSQUEDA=gsub(',$','',ubicaciones_genericas_ggmap$BUSQUEDA)
  if(is.null(ubicaciones_genericas_ggmap) | any(!is.element(loc_genericas,toupper(ubicaciones_genericas_ggmap$BUSQUEDA)))){
    nuevas_loc_genericas = setdiff(loc_genericas,toupper(ubicaciones_genericas_ggmap$BUSQUEDA))
    require(ggmap)
    register_google(key = apikey)
    NLG_ll = geocode(nuevas_loc_genericas)
    NLG_ll$BUSQUEDA =nuevas_loc_genericas
    ubicaciones_genericas_ggmap = rbind(ubicaciones_genericas_ggmap,NLG_ll)
    write.csv(ubicaciones_genericas_ggmap,ubicaciones_genericas_path,row.names=F)
  }
  return(ubicaciones_genericas_ggmap)
}
