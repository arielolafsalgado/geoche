#' Compara los resultados obtenidos con GGMAP y OSM y elige el mejor resultado
#' @description La funcion genera im data frame con las posiciones exitosas de comparar GGMAP y OSM. Al final, la ubicación propuesta es acompañada de una etiqueta según su confiabilidad sea BUENA, MEDIA o BAJA.
#' @param inputArchivo Path a partir del cual construir los paths para ggmap y osm. El archivo que fue usado para construirlos.
#' @param ventaja_ggmap La ventaja inicial que lleva en puntos GOOGLE (puede ser cualquier numero, positivo o negativo). Por default, 1.
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
#' @param columna_depto Columna con los departamentos. Default: 'DEPARTAMENTO_RESIDENCIA'
#' @param columna_prov Columna con las provincias. Default:'PROVINCIA_RESIDENCIA'
#' @param write.it Se deben escribir los archivos? Por default TRUE
#' @param mapa_check Si es TRUE, guarda también un mapa generado con leaflet con los casos y colores según su calidad.
#' @return Un data frame con la ubicacion elegida para cada caso, indicando el puntaje que obtuvo y de donde proviene, así como el agregado de la ubicación de la clinica.
#' @export
compara_GGMAP_OSM = function(inputArchivo = "bases/ejemplo/ejemplo.csv",ventaja_ggmap=1,peso_hospital=10,peso_generico=1,peso_provincia=1,peso_departamento=1,peso_distancia=1,puntaje_de_corte=-5,lonlat_columns_ggmap=c('LON_RESIDENCIA','LAT_RESIDENCIA'),lonlat_columns_osm=c('LON_RESIDENCIA_OSM','LAT_RESIDENCIA_OSM'),max_dist=1000,id_column='IDEVENTOCASO',na.value=FALSE,write.it=T,verbose=T,mapa_check=F,columna_depto='DEPARTAMENTO_RESIDENCIA',columna_prov='PROVINCIA_RESIDENCIA'){
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
    puntaje = c(ventaja_ggmap,rep(0,length(row_osm)))
    if(is.na(data_ggmap$LAT_RESIDENCIA[row_ggmap]))
      puntaje = c(puntaje_de_corte-1,rep(0,length(row_osm)))
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
      puntaje = puntaje - ifelse(consistencia_nogenerico,peso_generico,0)
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
        lat = data_osm[row_osm_winner,lonlat_columns_osm[2]]
        lon = data_osm[row_osm_winner,lonlat_columns_osm[1]]
        data_check$LAT_RESIDENCIA[row_ggmap] = lat
        data_check$LON_RESIDENCIA[row_ggmap] = lon
        if(all(!is.null(data_check$LATLON_DEPARTAMENTO))){
          LL_D = data_osm[row_osm_winner,'LATLON_DEPARTAMENTO']
          data_check$LATLON_DEPARTAMENTO[row_ggmap] = LL_D
        }
        if(all(!is.null(data_check$LATLON_PROVINCIA))){
          LL_P = data_osm[row_osm_winner,'LATLON_PROVINCIA']
          data_check$LATLON_PROVINCIA[row_ggmap] = LL_P
        }
        if(all(!is.null(data_check$CERCA_CLINICA))) data_check$CERCA_CLINICA[row_ggmap] = consistencia_hospital[winner_row]
        if(all(!is.null(data_check$MATCH_GENERICO))) data_check$MATCH_GENERICO[row_ggmap] = consistencia_nogenerico[winner_row]
        if(all(!is.null(data_check$LAT_LON_EN_PROVINCIA))) data_check$LAT_LON_EN_PROVINCIA[row_ggmap] = consistencia_provincia[winner_row]
        if(all(!is.null(data_check$LAT_LON_EN_DEPARTAMENTO))) data_check$LAT_LON_EN_DEPARTAMENTO[row_ggmap] = consistencia_depto[winner_row]
      }
    }else{
      comp_score = ventaja_ggmap
      columnas = c('LAT_LON_EN_PROVINCIA','LAT_LON_EN_DEPARTAMENTO','CERCA_CLINICA','MATCH_GENERICO')
      pesos = c(peso_provincia,peso_departamento,peso_hospital,peso_generico)
      names(pesos) = columnas
      for(cn in columnas){
        flag = is.element(cn,colnames(data_check))
        if(flag){
          nopass = ifelse(cn=='MATCH_GENERICO',yes=data_check[row_ggmap,cn],no=!data_check[row_ggmap,cn])
          if(is.na(nopass)) nopass=TRUE
          comp_score = comp_score - pesos[cn]*nopass
        }
      }
      data_check$COMPARACION_PUNTAJE[row_ggmap] = comp_score
      data_check$COMPARACION_ELECTO[row_ggmap] = 'GGMAP'
    }
  }

  data_check$LAT_GEOCHE = data_check$LAT_RESIDENCIA
  data_check$LON_GEOCHE = data_check$LON_RESIDENCIA
  data_check$LAT_RESIDENCIA = NULL
  data_check$LON_RESIDENCIA = NULL
  if(is.element(columna_depto,colnames(data_check))){
    data_check$DEPTO_GEOCHE = data_check[,columna_depto]
  }else{
    print('columna_depto incorrecta, colocando NA')
    data_check$DEPTO_GEOCHE = NA
  }
  if(is.element(columna_prov,colnames(data_check))){
    data_check$PROV_GEOCHE = data_check[,columna_prov]
  }else{
    print('columna_prov incorrecta, colocando NA')
    data_check$PROV_GEOCHE = NA
  }
  if(all(!is.null(data_check$CERCA_CLINICA))){
    data_check$LATLON_DE_CLINICA = FALSE
    for(row_check in 1:nrow(data_check)){
      if(data_check$COMPARACION_PUNTAJE[row_check]<=puntaje_de_corte){
        if(all(!is.null(data_check$CERCA_CLINICA))){
          if((!is.na(data_check$CERCA_CLINICA[row_check]) & !data_check$CERCA_CLINICA[row_check] & !is.na(data_check$LAT_CLINICA[row_check])) |
              (is.na(data_check$CERCA_CLINICA[row_check]) & !is.na(data_check$LAT_CLINICA[row_check]) & is.na(data_check$LAT_GEOCHE[row_check]))
                ){
            data_check$LAT_GEOCHE[row_check] = data_check$LAT_CLINICA[row_check]
            data_check$LON_GEOCHE[row_check] = data_check$LON_CLINICA[row_check]
            data_check$LATLON_DE_CLINICA[row_check] =  TRUE
          }
        }
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
    print('RESUMEN COMPARACION:')
    print(paste('ELEGIDOS GGMAP:',sum(data_check$COMPARACION_ELECTO=='GGMAP')))
    print(paste('ELEGIDOS OSM:',sum(data_check$COMPARACION_ELECTO=='OSM')))
    print(paste('ELEGIDOS GGMAP:',sum(data_check$COMPARACION_ELECTO=='GGMAP')))
    print(paste('ELEGIDOS CLINICA:',sum(data_check$LATLON_DE_CLINICA)))
    print('PUNTAJES DE CADA VALOR')
    print(table(data_check$COMPARACION_PUNTAJE))
  }
  result = data_check
  if(mapa_check){
    require(leaflet)
    map = leaflet() %>% addProviderTiles(providers$OpenStreetMap)
    markerColors = c('BUENA'='green','MEDIA'='yellow','BAJA'='red')
    map = map %>% addCircles(data=data_check,lat=~LAT_GEOCHE,lng = ~LON_GEOCHE,popup= ~paste('ID:', IDEVENTOCASO,'- BUSQUEDA:', BUSQUEDA_RESIDENCIA,'- CONFIABILIDAD:',CONFIABILIDAD, '- PUNTAJE:',COMPARACION_PUNTAJE,' - ID:',IDEVENTOCASO),color=~as.character(markerColors[CONFIABILIDAD]))
    map = map %>% addLegend(position = 'topright',labels = names(markerColors),colors = as.character(markerColors))
    result = list('dataset'=data_check,'map'=map)
  }
  return(result)
}
