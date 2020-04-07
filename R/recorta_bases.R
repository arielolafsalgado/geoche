#' Recorta una base segun los casos presentes en otra
#' @description Esta función remueve casos repetidos del dataset 2, que esten presentes en el 1. Para esto, compara las columnas en columnas
#' @param inputArchivo1 El primer archivo, como path hasta el archivo.
#' @param inputArchivo2 El segundo archivo, como path hasta el archivo
#' @param outputArchivo El archivo de salida en el cual escribir el resultado
#' @param columnas Las columnas mediante las cuales matchear los datasets
#' @param ... Se pasa a read.csv
#' @return El dataset recortado.
#' @export
recorta_bases = function(inputArchivo1,inputArchivo2,outputArchivo=paste(sub('.csv','',inputArchivo1),inputArchivo2,sep='_recortado_'),columnas='IDEVENTOCASO',...){
  b1 = read.csv(inputArchivo1,stringsAsFactors=F,...)
  b2 = read.csv(inputArchivo2,stringsAsFactors=F,...)
  t1 = ''
  t2 = ''
  for(cn in columnas){
    t1 = paste(t1,b1[,cn],sep='--')
    t2 = paste(t2,b2[,cn],sep='--')
  }
  repeated = is.element(t1,t2)
  bout = b1[!repeated,]
  write.csv(bout,outputArchivo,row.names=F)
  return(bout)
}
