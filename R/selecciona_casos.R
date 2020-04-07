#' Subselecciona una base segun los casos de una columna
#' @description Esta funcion recorta un dataset en base a una columna, quedandose con ciertos casos.
#' @param dataset La base de datos
#' @param columna La columna en la que buscar casos
#' @param casos Los casos a retener de esa columna
#' @return El dataset recortado.
#' @export
selecciona_casos = function(dataset,columna,casos){
  idx = which(is.element(dataset[,columna],casos))
  return(dataset[idx,])
}
