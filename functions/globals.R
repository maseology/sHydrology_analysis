
########################################################
# general functions and globals
########################################################
# cms <- "m³/s" # "m<sup>3</sup>/s"
# km2 <- "km²"
# m3 <- "m³"
gglabcms <- expression('Mean Daily Discharge ' ~ (m^3/s))
dylabcms <- "Discharge (m<sup>3</sup>/s)"

month <- function (x) as.numeric(format(x, "%m"))
montho <- function (x) (month(x)+2) %% 12
montha <- c("Oct","Nov","Dec", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep")

wtr_yr <- function(dates, start_month=10) {
  # Convert dates into POSIXlt
  dates.posix = as.POSIXlt(dates)
  # Year offset
  offset = ifelse(dates.posix$mon >= start_month - 1, 1, 0)
  # Water year
  adj.year = dates.posix$year + 1900 + offset
  # Return the water year
  adj.year
}