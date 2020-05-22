

df.monthly <- function(df) {

  # detect consecutive NAs
  df$consNA <- sequence(rle(is.na(df$Flow))$lengths)
  df[!is.na(df$Flow),'consNA'] = 0

  df <- df %>%
    mutate(year = year(Date)) %>%
    mutate(month = month(Date)) %>%
    group_by(year, month)
  
  df <- df %>% dplyr::summarise(stat = mean(Flow, na.rm = TRUE), 
                                n = sum(!is.na(Flow)), 
                                xcon = max(consNA))
  
  df$Date <- zoo::as.Date(paste(df$year, df$month, '1'), "%Y %m %d")
  df$ntot <- days_in_month(df$Date)
  df$wmo <- ifelse((df$ntot-df$n>4) | (df$xcon>2),0,1) # WMO 3/5 rule: 5+ total days missing OR 3+ consecutive days missing
  df[df$n==0,'stat'] = NA
  
  return(df)
}


df.monthly.simple <- function(df) {
  return(df.monthly(df)[-c(3:7)])
}

df.annual.simple <- function(df) {
  df <- df.monthly(df) %>%
    ungroup() %>%
    group_by(year) %>%
    dplyr::summarise(wmo = sum(wmo, na.rm = TRUE)/12)
  return(df)
}