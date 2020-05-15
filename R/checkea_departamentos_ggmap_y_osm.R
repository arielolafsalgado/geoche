#' Comprueba consistencia entre los departamentos y las posiciones georreferenciadas
#' @description Realiza la validación de las posiciones en base a la provincia indicada.
#' @param inputArchivo Path a partir del cual construir los paths para ggmap y osm. El archivo que fue usado para construirlos.
#' @param departamentos_path Path al archivo shp de las provincias. Por default 'shp/provincias/provincias.shp'
#' @param depto_id_column Columna con el id de las provincias, por default 'ID_PROVINCIA'
#' @param lonlat_columns_ggmap Columnas con las ubicaciones lon y lat de las filas en data_ggmap. Por default c('LON_RESIDENCIA','LAT_RESIDENCIA')
#' @param lonlat_columns_osm Columnas con las ubicaciones lon y lat de las filas en data_osm. Por default c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM')
#' @param crs crs usado para buscar la interseccion. Por default 22185
#' @param id_column Columna con los ids en el archivo OSM. Por default, 'IDEVENTOCASO'
#' @param verbose Booleano ¿debe imprimir el progreso? Default TRUE
#' @param write.it Se deben escribir los archivos? Por default TRUE
#' @return Una lista con ambos data frames.
#' @export
checkea_departamentos_ggmap_y_osm = function(inputArchivo = 'bases/ejemplo/ejemplo.csv',departamentos_path='shp/departamentos/censo_por_departamento_polígonos.shp',depto_id_column='ID_DEPTO',lonlat_columns_ggmap=c('LON_RESIDENCIA','LAT_RESIDENCIA'),lonlat_columns_osm=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),crs=22185,id_column='IDEVENTOCASO',verbose=T,write.it=T){
  require(sf)
  inputGGMAP = sub('.csv','_georrefGGMAP.csv',inputArchivo)
  inputOSM = sub('.csv','_georrefOSM.csv',inputArchivo)
  data_ggmap = read.csv(inputGGMAP,stringsAsFactors=F)
  data_osm = read.csv(inputOSM,stringsAsFactors=F)
  departamentos = read_sf(departamentos_path) # El shp de las provincias
  data_ggmap = check_departamentos_ggmap(data_ggmap,departamentos,depto_id_column=depto_id_column,lonlat_columns=lonlat_columns_ggmap,verbose=verbose)
  data_osm = check_departamentos_osm(data_osm,data_ggmap,departamentos,depto_id_column=depto_id_column,lonlat_columns=lonlat_columns_osm,id_column=id_column,verbose=verbose)

  ## RESUMEN
  if(verbose){
    print(paste('RESUMEN DEPARTAMENTOS:'))
    print('El punto estaba dentro del departamento (GGMAP)?')
    print(table(data_ggmap$LAT_LON_EN_DEPARTAMENTO,useNA="ifany"))
    print('El punto estaba dentro del departamento (OSM)?')
    print(table(data_osm$LAT_LON_EN_DEPARTAMENTO,useNA="ifany"))
  }
  if(write.it){
    # Vuelvo a guardar los archivos, ahora con su nueva columna
    write.csv(data_ggmap,inputGGMAP,row.names=F)
    write.csv(data_osm,inputOSM,row.names=F)
  }
  return(list('ggmap'=data_ggmap,'osm'=data_osm))
}
