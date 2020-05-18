# geoche

Georreferenciación en *R* con validación vía poligonos, busquedas múltiples y distancia a puntos de referencia. 

Geocoding in *R* with polygon shapes based validation, multiple queries and distance to reference points. 

Este paquete fue diseñado para validar georreferenciaciones en el marco de la pandemia COVID-19. La lógica que persigue consiste en realizar georreferenciaciones mediante dos buscadores: google (provisto por el paquete ggmap) y openstreetmap (provisto por tmaptools). Además, emplea poligonos referidos a la estructura político-territorial del país (en Argentina, provistos por *INDEC*) para validar las ubicaciones obtenidas, las compara con ubicaciones de referencia asociadas a las localidades y departamentos a los que pertenece la dirección buscada, valida en base a la distancia a un punto de referencia (en nuestro caso, un punto de atención clínico) y revisa la consistencia interna entre los distintos puntos encontrados (corroborando que esten razonablemente cerca entre sí). 
El resultado se presenta como una serie de columnas adicionales en los datos, indicando el resultado de pasar cada validación, así como un puntaje de la ubicación, Basandose en un puntaje mínimo, cada ubicación obtenida es calificada como BUENA, MEDIA o MALA. 

This package was designed to validate geocodings in the context of the COVID-19 pandemic. It aims to geocode using two providers: google (provided by ggmap) and openstreetmap (provided by tmaptools). Also, it uses shape polygons referred to the geo political structure of the country (in Argentina, provided by the *INDEC*) to validate the obtained locations, comparing them to reference locations of each location's department, measures the distance to some reference places (in our case, clinical attention points) and checks for inner consistency between the different found points (ensuring that they are too far from each other).
The result consists in a series of new columns in the dataset, indicating the result of each validation step, along with a location score. Based on a threshold score, each location is qualified as GOOD, MID or BAD,



# Instalacion

**geoche** requiere para funciona tener instalados los paquetes **ggmap**, **tmaptools**, **sf**, **stringr**, **R.utils**.

```
install.packages(c('sf','ggmap','tmaptools','stringr'))
```

Ademaś, para georreferencia usando el API de google se necesita una clave API, obtenible a través de una cuenta en google cloud https://cloud.google.com/

Clone el repositorio en su disco, y desde dentro de la carpeta _geoche_
corra desde **R** `devtools::install()`


# Guia

En la carpeta vignettes encontrará un mini tutorial de uso, y en la carpeta geoche_extras/ encontrará una carpeta trabajo con scripts de ejemplo.
