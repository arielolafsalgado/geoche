#' Preprocesa el texto para hacer más exitosa la búsqueda.
#' @description Esta función hace ciertos preprocesamientos básicos sobre el texto para que sea más fácilmente aceptado por los buscadores. Elimina caracteres especiales, remueve tildes, separa texto de números, y desabrevia la palabra número.
#' @param texto El vector con los campos a procesar
#' @param remueve.post.entre Si es igual a TRUE, remueve todo el texto que aparezca después de una expresión asociada a "ENTRE"
#' @return El vector, ya preprocesado.
preprocesa_texto = function(texto,remueve.post.entre=F){
  require(stringr)
  texto = toupper(texto)
  texto = gsub('Á|Â|À|Ä','A',texto)
  texto = gsub('É|Ê|È|Ë','E',texto)
  texto = gsub('Í|Î|Ì|Ï','I',texto)
  texto = gsub('Ó|Ô|Ò|Ö','O',texto)
  texto = gsub('Ú|Û|Ù|Ü','U',texto)
  texto = gsub('\\#','N',texto)
  texto = gsub('\\·',' ',texto)
  texto = gsub('Nº|Nª|N\\||N°','NUMERO',texto)
  texto = gsub('Bª','',texto)
  texto = gsub('E/|E\\\\',' ENTRE ',texto)
  texto = gsub("([A-Z])([0-9])", "\\1  \\2", texto)
  texto = gsub("([0-9])([A-Z])", "\\1  \\2", texto)
  texto = gsub(',','',texto)
  texto = gsub('\\^','',texto)
  texto = gsub(' E ',' ENTRE ',texto)
  texto = gsub('^NUM ','NUMERO',texto)
  texto = gsub('NRO\\.','NUMERO',texto)
  texto = gsub(' N ',' NUMERO ',texto)
  texto = gsub(' N | NUM ',' NUMERO ',texto)
  texto = gsub('S\\/N','SIN NUMERO ',texto)
  if(remueve.post.entre){
    texto = gsub('ENTRE.*','',texto)
  }
  texto = gsub("\\s+", " ", str_trim(texto))
  return(texto)
}
