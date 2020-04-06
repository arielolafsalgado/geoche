#' Realiza la busqueda mediante OSM, con limitador de tiempo
#' @description Esta función genera un dataframe con x (lon) y y (lat), asociandoles un indice que referencia a la fila en datos (aun_por)
#' @param loc_domicilio Los domicilios a ser buscados
#' @param aun_por El índice que vamos a asociar a cada domicilio para poder relacionarlo con la base de datos. Por defecto, el orden de loc_domicilios
#' @param timeout Dado que muchas veces OSM se cuelga esperando la respuesta, la función espera timeout segundos o pasa al siguiente elemento a ser buscado.
#' @param verbose Boleano, ¿Imprimir progreso? Por default TRUE
#' @return Un data frame con las ubicaciones georreferenciadas. Solo las exitosas aparecen, y puede haber más de una ubicacion por domicilio.
geocode_OSM_ariel = function(loc_domicilio,aun_por=1:length(loc_domicilio),timeout=5,verbose=T){
  require(tmaptools)
  require(R.utils)
  output_dom = NULL # Preparo un data frame vacio
  for(fila in 1:length(loc_domicilio)){ # Georreferencio 1 por 1
    ll = withTimeout(tryCatch(geocode_OSM(loc_domicilio[fila],as.data.frame=F,return.first.only=F),error=function(e) NULL, warning=function(e) NULL),onTimeout='silent',timeout=timeout)
    if(!is.null(ll)){
      if(!is.null(names(ll))){
        if(verbose) print(paste('Fila-domicilio',fila,'encontrada con 1 caso'))
        ll = ll$coords
        ll$fila = aun_por[fila]
        ll$busqueda = loc_domicilio[fila]
        ll = as.data.frame(ll,stringsAsFactors=F)
        output_dom = rbind(output_dom,ll)
      }else{
        if(verbose) print(paste('Fila-domicilio',fila,'encontrada con',length(ll),'casos'))
        for(resultado in 1:length(ll)){
          lli = ll[[resultado]]$coords
          lli$fila = aun_por[fila]
          lli$busqueda = loc_domicilio[fila]
          lli = as.data.frame(lli,stringsAsFactors=F)
          output_dom = rbind(output_dom,lli)
        }
      }
    }else{
      if(verbose) print(paste('Fila-domicilio',fila,'no encontrada'))
    }
  }
  return(output_dom)
}
