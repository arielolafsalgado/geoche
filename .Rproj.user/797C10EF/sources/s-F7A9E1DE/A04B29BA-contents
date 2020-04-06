#' Compara los resultados obtenidos con GGMAP y OSM y elige el mejor resultado
#' @description La funcion genera im data frame con las posiciones exitosas de comparar GGMAP y OSM. Al final, la ubicación propuesta es acompañada de una etiqueta según su confiabilidad sea BUENA, MEDIA o BAJA.
#' @param inputArchivo Path a partir del cual construir los paths para ggmap y osm. El archivo que fue usado para construirlos.
#' @param peso_hospital El peso asociado al checkeo.
#' @param peso_hospital El peso asociado a los distintos checkeos.
#' @param peso_provincia El peso asociado a los distintos checkeos.
#' @param peso_distancia El peso asociado a los distintos checkeos.
#' @param puntaje_de_corte El puntaje a partir del cual se indica la ubicacion de la clinica en vez de la georreferenciada. Además, las ubicaciones BAJAS son las que quedan por debajo de este valor
#' @param max_dist La máxima distancia aceptable puede estar una ubicacion de las otras
#' @param lonlat_columns_ggmap Las columnas en las que se encuentras las ubicaciones lon y lat en data_ggmap
#' @param lonlat_columns_osm Las columnas en las que se encuentras las ubicaciones lon y lat en data_osm
#' @param id_column Columna para vincular data_ggmap con data_osm. Por default IDEVENTOCASO
#' @param na.value Como consideran en terminos de puntaje aquellos checkeos que hayan dado NA. Por default, es FALSE
#' @param verbose Boleano ¿Debe imprimirse el progreso? Por default TRUE
#' @return Un data frame con la ubicacion elegida para cada caso, indicando el puntaje que obtuvo y de donde proviene, así como el agregado de la ubicación de la clinica.
compara_GGMAP_OSM = function(inputArchivo = 'bases/Base_p_ariel_y_yamila.csv',peso_hospital=10,peso_generico=1,peso_provincia=1,peso_departamento=1,peso_distancia=1,puntaje_de_corte=-5,lonlat_columns_ggmap=c('LON_RESIDENCIA','LAT_RESIDENCIA'),lonlat_columns_osm=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),max_dist=1000,id_column='IDEVENTOCASO',na.value=FALSE,verbose=T){
  inputGGMAP = sub('.csv','_georrefGGMAP.csv',inputArchivo)
  inputOSM = sub('.csv','_georrefOSM.csv',inputArchivo)
  data_ggmap = read.csv(inputGGMAP,stringsAsFactors=F)
  data_osm = read.csv(inputOSM,stringsAsFactors=F)

  data_check = data_ggmap
  data_check$COMPARACION_PUNTAJE = NA
  data_check$COMPARACION_ELECTO = NA
  for(row_ggmap in 1:nrow(data_ggmap)){
    if(verbose) print(paste('Investigando fila',row_ggmap))
    row_osm = which(data_ggmap[row_ggmap,id_column]==data_osm[,id_column])  # Agarro las filas que corresponden al mismo caso
    puntaje = c(1,rep(0,length(row_osm)))
    # Si hay alguna de OSM que vaya con este caso
    if(length(row_osm)>0){
      # Me armo objetos tipo punto para cada uno
      consistencia_distancia = calcula_consistencia_distancia(data_ggmap,data_osm,row_ggmap,row_osm,lonlat_columns_ggmap,lonlat_columns_osm,id_column,max_dist)
      consistencia_provincia = calcula_consistencia_columna(data_ggmap,data_osm,row_ggmap,row_osm,na.value,columna='LAT_LON_EN_PROVINCIA')
      consistencia_depto = calcula_consistencia_columna(data_ggmap,data_osm,row_ggmap,row_osm,na.value,columna='LAT_LON_EN_DEPARTAMENTO')
      consistencia_nogenerico = calcula_consistencia_columna(data_ggmap,data_osm,row_ggmap,row_osm,na.value,columna='MATCH_GENERICO')
      consistencia_hospital = calcula_consistencia_columna(data_ggmap,data_osm,row_ggmap,row_osm,na.value,columna='CERCA_CLINICA')

      # Cambio los puntajes restando en lo que no acertaron
      puntaje = puntaje - consistencia_distancia*peso_distancia
      puntaje = puntaje - ifelse(consistencia_provincia,0,peso_provincia)
      puntaje = puntaje - ifelse(consistencia_depto,0,peso_departamento)
      puntaje = puntaje - ifelse(consistencia_nogenerico,0,peso_generico)
      puntaje = puntaje - ifelse(consistencia_hospital,0,peso_hospital)
      # Me quedo con la fila ganadora y anoto sus datos en el dataset final
      winner_row = which.max(puntaje)
      data_check$COMPARACION_PUNTAJE[row_ggmap] = max(puntaje)
      if(winner_row==1){
        data_check$COMPARACION_ELECTO[row_ggmap] = 'GGMAP'
      }else{
        # Si gano uno de OSM, cambio la posición en el dataset final
        data_check$COMPARACION_ELECTO[row_ggmap] = 'OSM'
        row_osm_winner = row_osm[winner_row-1]
        lat = data_osm[row_osm_winner,latlon_columns_osm[2]]
        lon = data_osm[row_osm_winner,latlon_columns_osm[1]]
        data_check$LAT_RESIDENCIA[row_ggmap] = lat
        data_check$LON_RESIDENCIA[row_ggmap] = lon
        if(all(!is.null(data_check$CERCA_CLINICA))) data_check$CERCA_CLINICA[row_ggmap] = consistencia_hospital[winner_row]
        if(all(!is.null(data_check$MATCH_GENERICO))) data_check$MATCH_GENERICO[row_ggmap] = consistencia_nogenerico[winner_row]
        if(all(!is.null(data_check$LAT_LON_EN_PROVINCIA))) data_check$LAT_LON_EN_PROVINCIA[row_ggmap] = consistencia_provincia[winner_row]
        if(all(!is.null(data_check$LAT_LON_EN_DEPARTAMENTO))) data_check$LAT_LON_EN_DEPARTAMENTO[row_ggmap] = consistencia_depto[winner_row]
      }
    }else{
      comp_score = 1
      columnas = c('LAT_LON_EN_PROVINCIA','LAT_LON_EN_DEPARTAMENTO','CERCA_CLINICA','MATCH_GENERICO')
      pesos = c(peso_provincia,peso_departamento,peso_hospital,peso_generico)
      names(pesos) = columnas
      for(cn in columnas){
        flag = is.element(cn,colnames(data_check))
        if(flag){
          nopass = !data_check[row_ggmap,cn]
          if(is.na(nopass)) nopass=TRUE
          comp_score = comp_score - pesos[cn]*nopass
        }
      }
      data_check$COMPARACION_PUNTAJE[row_ggmap] = comp_score
      data_check$COMPARACION_ELECTO[row_ggmap] = 'GGMAP'
    }
  }

  data_check$LAT_RESIDENCIA_MEJOR = data_check$LAT_RESIDENCIA
  data_check$LON_RESIDENCIA_MEJOR = data_check$LON_RESIDENCIA
  if(all(!is.null(data_check$CERCA_CLINICA))){
    data_check$LATLON_DE_CLINICA = FALSE
    for(row_check in 1:nrow(data_check)){
      if(data_check$COMPARACION_PUNTAJE[row_check]<=puntaje_de_corte){
        data_check$LAT_RESIDENCIA[row_check] = data_check$LAT_CLINICA[row_check]
        data_check$LON_RESIDENCIA[row_check] = data_check$LON_CLINICA[row_check]
        data_check$LATLON_DE_CLINICA[row_check] =  TRUE
      }
    }
  }
  data_check$CONFIABILIDAD = sapply(1:nrow(data_check),function(row_check){
    puntaje = data_check$COMPARACION_PUNTAJE[row_check]
    if(is.na(puntaje)){
      result = 'BAJA'
    }else{
      if(puntaje>=0){
        result = 'BUENA'
      }else{
        if(puntaje<=puntaje_de_corte){
          result = 'BAJA'
        }else{
          result = 'MEDIA'
        }
      }
    }
    return(result)
  })
  if(write.it){
    write.csv(data_check,sub('.csv','_finalGGMAP_OSM.csv',inputArchivo),row.names=F)
  }

  if(verbose){
    print('RESUMEN SCRIPT 6:')
    print(paste('ELEGIDOS GGMAP:',sum(data_check$COMPARACION_ELECTO=='GGMAP')))
    print(paste('ELEGIDOS OSM:',sum(data_check$COMPARACION_ELECTO=='OSM')))
    print(paste('ELEGIDOS GGMAP:',sum(data_check$COMPARACION_ELECTO=='GGMAP')))
    print(paste('ELEGIDOS CLINICA:',sum(data_check$LATLON_DE_CLINICA)))
    print('PUNTAJES DE CADA VALOR')
    print(table(data_check$COMPARACION_PUNTAJE))
  }
  return(data_check)
}
