#' Actualiza las ubicaciones genericas obtenidas por OSM
#' @description Esta función actualiza y carga la base de datos de ubicaciones genericas de OSM
#' @param loc_genericas Las ubicaciones genericas a ser buscadas
#' @param ubicaciones_genericas_path El path hacia el archivo de ubicaciones genericas. Si no existe, se creará en ese lugar el archivo nuevo.
#' @return Un data frame con las ubicaciones genericas cargadas
actualiza_ubicaciones_genericas_osm = function(loc_genericas,ubicaciones_genericas_path='ubicaciones_genericas_osm.csv',timeout=5,verbose=T){
  require(stringr)
  ubicaciones_genericas_osm = NULL
  if(file.exists(ubicaciones_genericas_path)){
    ubicaciones_genericas_osm = read.csv(ubicaciones_genericas_path,stringsAsFactors=F)
  }
  loc_genericas = str_trim(loc_genericas)
  ubicaciones_genericas_osm$BUSQUEDA=str_trim(ubicaciones_genericas_osm$BUSQUEDA)
  loc_genericas=gsub(',$','',loc_genericas)
  ubicaciones_genericas_osm$BUSQUEDA=gsub(',$','',ubicaciones_genericas_osm$BUSQUEDA)
  if(is.null(ubicaciones_genericas_osm) | any(!is.element(loc_genericas,toupper(ubicaciones_genericas_osm$BUSQUEDA)))){
    nuevas_loc_genericas = setdiff(loc_genericas,toupper(ubicaciones_genericas_osm$BUSQUEDA))
    require(tmaptools)
    NLG_ll_OSM = NULL
    for( q in 1:length(nuevas_loc_genericas)){
      if(verbose) print(paste('BUSCANDO EN OSM:',nuevas_loc_genericas[q]))
      gOSM = geocode_OSM_ariel(nuevas_loc_genericas[q],timeout = timeout)
      if(!is.null(gOSM)){
        result = data.frame('lon'=as.numeric(gOSM$x),'lat'=as.numeric(gOSM$y),'BUSQUEDA'=nuevas_loc_genericas[q],stringsAsFactors=F)
      }else{
        result=NULL
      }
      NLG_ll_OSM = rbind(NLG_ll_OSM,result)
    }
    ubicaciones_genericas_osm = rbind(ubicaciones_genericas_osm,NLG_ll_OSM)
    write.csv(ubicaciones_genericas_osm,ubicaciones_genericas_path,row.names=F)
  }
  return(ubicaciones_genericas_osm)
}
