require(geoche)
inputArchivo = 'bases/ejemplo/ejemplo.csv'
id_column='IDEVENTOCASO'
max_dist = 1000 # Distancia en metros
peso_hospital = 0
peso_generico = 1
peso_provincia = 10
peso_departamento = 10
peso_distancia = 1
puntaje_de_corte = -10
ventaja_ggmap = 0
na.value= FALSE
mapa_check=T
output = compara_GGMAP_OSM(inputArchivo,ventaja_ggmap,peso_hospital,peso_generico,peso_provincia,peso_departamento,peso_distancia,puntaje_de_corte,max_dist = max_dist,na.value = na.value,id_column = id_column,mapa_check = mapa_check)
print(output$map)
