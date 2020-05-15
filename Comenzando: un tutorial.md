# Geolocalizando con geoche
## *PREAMBULO*

**geoche** es un paquete diseñado para realizar geolocalización en el marco de la pandemia COVID-19. Fue diseñado con la idea de fondo
de que en el proceso de geolocalización se cuenta con información extra de checkeo que puede ser usada para evaluar rápidamente la calidad
de una georreferenciación, y por lo tanto, gran parte de los casos de búsqueda, que usualmente son realizados a mano, pueden ahorrarse
de los que usualmente son buscados a mano. Esta información incluye regiones a las que con seguridad debería pertenecer el
punto obtenido, que deben ser acompañadas con capas de poligonos que los representen sobre el mapa. En particular, en el problema original
se contaba con un método de chequeo basado en la distancia a ciertos puntos de referencia, correspondientes a clinicas de atencion.

### *ALGUNAS CONSIDERACIONES SOBRE LA INFORMACIÓN DE ENTRADA*

En la versión actual, su uso está orientado a georreferenciar casos en los que se cuenta con información de su domicilio, el
cual se espera que pueda dividirse en campos DOMICILIO  (refiriendose por este a la calle y al número, que pueden estar subdivididos
en otros campos como CALLE y NÚMERO), LOCALIDAD, DEPARTAMENTO, PROVINCIA, PAIS (o un subconjunto de estas).
Contar con menos columnas genera obviamente deterioro en la calidad de las geolocalizaciones, pero contar con exceso de
información también puede generar deterioro. Por ejemplo, considere el caso

ARGENTINA, Ciudad Autonoma de Buenos Aires, CALLLE ABCDE NUMERO 123

La palabra CALLE y NUMERO son espureas y sobran, deteriorando la calidad de la búsqueda. Algo así es preferible:

ARGENTINA, Ciudad Autonoma de Buenos Aires, ABCDE 123

Ser inespecifico a niveles menores, genera ubicaciones representativas del poligono más grande que incluya la búsqueda:

ARGENTINA, Ciudad Autonoma de Buenos Aires

dará por resultado una ubicación representativa de la Ciudad Autónoma de Buenos Aires. En cambio, algo como

ARGENTINA, ABCDE 123

inevitablemente llevará a un resultado erroneo, debido a la multiplicidad de valores asociados a una calle que puede estar
repetida muchas veces por toda la ciudad.

La calidad de la búsqueda mejora si no hay caracteres extraños en los nombres. Es preferible que no tengan ningun tipo de tilde
evitar caracteres como N°, ^ # y otros. El programa cuenta con un depurador de texto, pero es preferible realizar ese proceso a conciencia
Mientras más completos estén los campos, mayor confianza se le puede tener al resultado.

Los inputs de la geolocalización son archivos .csv, separados por commas.

### *ALGUNOS COMENTARIOS SOBRE EL OUTPUT*

El resultado de la geolocalización es un archivo .csv, idéntico al archivo input, pero con el agregado de algunas columnas.
Estas columnas contienen información útil para contrastar la calidad del resultado, con el objetivo de proveer una manera rápida 
checkeo del resultado. También se incluyen funciones para hacer mapas, para poder vizualizar los puntos de forma rápida y decidir si
algo funcionó por fuera de los esperado.

*En resumen*, si bien este paquete facilita la automatización del proceso de georreferenciación, no elimina la necesidad de un checkeo
previo y posterior de la información que se emplea y se obtiene.

## PASOS PARA LA GEORREFERENCIACION.
El código del paquete se acompaña con varios scripts modelo, para dar una base de como usar el paquete. El proceso de georreferenciación
propuesto consta de 6 pasos.
- El primer paso corresponde con georreferenciar los domicilios usando el API de GOOGLEMAPS (a través del paquete *ggmap* y el API de OPENS STREET MAPS (a través del paquete *tmaptools*). La función de geocoding de *ggmap* retorna un_ único punto para cada *query* (búsqueda), mientras que la de *tmaptools* permite obtener varios resultados para una misma *query*. Los resultados de estas georreferenciaciones son guardados en dos archivos csv, que se van actualizando en los siguientes pasos.
- Los siguientes pasos constan de chequeos posibles de ser realizados:
  * Paso 2: Si se cuenta con información de los departamentos, se puede chequear que la ubicación encontrada esté en el departamento.  
  * Paso 3: Si se cuenta con información de la provincia, se puede chequear que la ubicación encontrada esté en la provincia.
  * Paso 4: Si se cuenta con información de el hospital en el que se atendió la persona, se puede chequear que la dirección esté dentro de cierta distancia máxima al hospital. A futuro, esta opción representará distancia a una ubicación genérica que sea de interés para el usuario. En ambos casos, el poligono con los hospitales (en formato shp) debería ser provisto por el usuario.
  * Paso 5: Se checkea que la ubicación obtenida no corresponda con una ubicación genérica equivalente a no poner la dirección exacta (con calle y número) sino solo una formada por un subconjunto de los datos (por ejemplo, solo pais y provincia). Este checkeo surge del hecho de que a veces los geocoders, al no encontrar el resultado, retornan algun resultado de búsqueda por default.
  * Paso 6: Se compara entre las ubicaciones obtenidas, y se queda con la ubicación que más criterios haya pasado. Además, se incorpora un criterio extra que se basa en la coherencia interna de las georreferenciaciones: todos los resultados deberían estar dentro de un radio. Resultados que se encuentren muy alejados, son penalizados. Ubicaciones con puntaje perfecto son tomadas como _buenas_. Ubicaciones con varias fallas pueden ser _medias_ o _malas_, en base a un criterio establecido por el usuario en base al nivel de penalización para cada falla.

Por ejemplo, si consideramos la búsqueda _Argentina, Ciudad autónoma de Buenos Aires, Alcorta 123_, esta puede referirse a la calle _Figueroa Alcorta número 123_, al igual que a la calle _Amancio Alcorta 123_, mientras que la búsqueda _Argentina, Ciudad autónoma de Buenos Aires, Comuna 4, Alcorta 123_ podría no tener ningún resultado exitoso. Aún así, con la información de los polígonos de las comunas de la C.A.B.A. podemos distinguir si el resultado se encuentra en la _Comuna 4_ o nó, y penalizarlo en base a eso. Si tenemos buena confianza en la información de la comuna asignada a cada domicilio, podemos penalizar duramente que la ubicación no se encuentre en el departamento, y calificar como _mala_ a toda ubicación (sea de *ggmap* o de *tmaptools*) que hayamos obtenido y no coincida lo obtenido con el departamento. La razón para no tomar descartar de plano esta ubicación es que podría haber error en la información incluida sobre del departamento (supongamos que en vez de decir _Comuna 4_ decía _Comuna 3_) y entonces no queramos descartar completamente a un resultado que falle a este nivel, pero por ejemplo a uno que no coincida con la provincia asignada.




