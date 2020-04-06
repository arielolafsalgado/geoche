#' Genera la lista de domicilios para buscar
#' @description Esta función toma el data frame datos y ciertos campos del mismo, y los usa para generar un vector de strings para ser georreferenciados
#' @param datos Un data frame con los campos_a_domicilio presentes
#' @param campos Los campos a ser pegados
#' @param texto_a_omitir Texto a ser omitido en caso de ser encontrado (por comparación exacta). Por default c('*SIN DATO* (*SIN DATO*)','NULL',paste('COMUNA',1:20))
#' @param prefijo Un campo de texto a ser agregado previo al resto. Por default "ARGENTINA"
#' @param sep El separador a ser usado cuando se peguen los campos. Por default ", "
#' @param campoNumero Campo con el número de la calle
#' @return Un vector de campos para ser georreferenciados.
genera_loc_domicilios = function(datos,campos,texto_a_eliminar=c('*SIN DATO* (*SIN DATO*)','NULL',paste('COMUNA',1:20)),prefijo='ARGENTINA',sep=', ',campoNumero=NULL){
  loc_domicilio = prefijo
  if(is.null(campoNumero)) campoNumero = campos[length(campos)]
  for(campo in campos){
    a_pegar = datos[,campo] # Agarro la tira de nombres asociada a este campo
    a_pegar[is.element(a_pegar,texto_a_eliminar)] = '' # convierto el texto a eliminar en vacío
    a_pegar = preprocesa_texto(a_pegar)
    loc_domicilio = paste(loc_domicilio,a_pegar,sep= ifelse(campo==campoNumero,' ',sep)) # Pego
  }
  # Lo paso a mayusculas para uniformizar

  #Convierto los CABA CIUDAD DE BUENOS AIRES EN CIUDAD DE BUENOS AIRES
  loc_domicilio = gsub('CABA, CIUDAD DE BUENOS AIRES','CIUDAD DE BUENOS AIRES',loc_domicilio)
  # LOS CABA que quedaron los despliego
  loc_domicilio = gsub('CABA','CIUDAD DE BUENOS AIRES',loc_domicilio)
  # Remuevo multiples comas
  loc_domicilio = gsub('(, )\\1+', '\\1', loc_domicilio)
  return(loc_domicilio)
}
