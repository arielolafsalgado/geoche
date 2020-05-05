#' Combina dos bases
#' @description Esta función combina dos datasets en uno, poniendo primicia en el primero. Casos que estén repetidos en el segundo seran removidos.
#' @param inputArchivo1 El primer archivo, como path hasta el archivo.
#' @param inputArchivo2 El segundo archivo, como path hasta el archivo
#' @param outputArchivo El archivo de salida en el cual escribir el resultado
#' @param id_column La columna en base a la cual matchear casos en ambos datasets
#' @param ... Se pasa a read.csv
#' @return El dataset combinado, como data.frame.
#' @export
combina_bases = function(inputArchivo1,inputArchivo2,outputArchivo=NULL,id_column='IDEVENTOCASO',...){
  require(stringr)
  if(is.null(outputArchivo)) outputArchivo = paste(sub('.csv','',inputArchivo1),gsub('.*/','',inputArchivo2),sep='_pegado_')
  b1 = read.csv(inputArchivo1,stringsAsFactors=F,...)
  b2 = read.csv(inputArchivo2,stringsAsFactors=F,...)
  b2 = b2[!is.element(b2[,id_column],b1[,id_column]),]
  for(cn in colnames(b1)){
    if(!is.element(cn,colnames(b2))){
      b2[,cn] = NA
    }
  }
  b2 = b2[,colnames(b1)]
  bout = rbind(b1,b2)
  write.csv(bout,outputArchivo,row.names=F)
  return(bout)
}
