% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geocode_OSM_ariel.R
\name{geocode_OSM_ariel}
\alias{geocode_OSM_ariel}
\title{Realiza la busqueda mediante OSM, con limitador de tiempo}
\usage{
geocode_OSM_ariel(loc_domicilio, aun_por = 1:length(loc_domicilio),
  timeout = 5, verbose = T)
}
\arguments{
\item{loc_domicilio}{Los domicilios a ser buscados}

\item{aun_por}{El índice que vamos a asociar a cada domicilio para poder relacionarlo con la base de datos. Por defecto, el orden de loc_domicilios}

\item{timeout}{Dado que muchas veces OSM se cuelga esperando la respuesta, la función espera timeout segundos o pasa al siguiente elemento a ser buscado.}

\item{verbose}{Boleano, ¿Imprimir progreso? Por default TRUE}
}
\value{
Un data frame con las ubicaciones georreferenciadas. Solo las exitosas aparecen, y puede haber más de una ubicacion por domicilio.
}
\description{
Esta función genera un dataframe con x (lon) y y (lat), asociandoles un indice que referencia a la fila en datos (aun_por)
}
