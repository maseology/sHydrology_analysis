


owrc.api <- function(lat,lng) {
  # collect interpolated data
  df <- jsonlite::fromJSON(paste0('https://golang.oakridgeswater.ca/cmet/',lat,'/',lng))
  df[df == -999] <- NA # do this before converting date
  df$Date = as.Date(df$Date)
  df$Pa = df$Pa/1000 # to kPa
  return(df)  
}

