
########################################################
# general functions and globals
########################################################
# cms <- "m³/s" # "m<sup>3</sup>/s"
# km2 <- "km²"
# m3 <- "m³"
gglabcms <- expression('Discharge ' ~ (m^3/s))
dylabcms <- "Discharge (m<sup>3</sup>/s)"

month <- function (x) as.numeric(format(x, "%m"))
montho <- function (x) (month(x)+2) %% 12
