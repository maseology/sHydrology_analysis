
getQ <- function(fa,rp) {
  o <- fa[round(fa$rp,5)==rp, 'estimate']
  if (length(o)==0) {
    r1 <- fa[round(fa$rp,5)<rp, ] %>% slice(which.max(estimate))
    r2 <- fa[round(fa$rp,5)>rp, ] %>% slice(which.min(estimate))
    o <- (r2$rp-rp)/(r2$rp-r1$rp)*(r2$estimate-r1$estimate)+r1$estimate
  }
  return(o)
}

returnQ <- function(hyd, rp) {
  extrms <- hyd %>%
    mutate(yr=year(Date)) %>%
    dplyr::select(yr,Flow) %>%
    group_by(yr) %>%
    dplyr::summarise(max = max(Flow, na.rm=TRUE)) %>%
    ungroup() %>%
    slice(-which.min(yr)) %>%
    slice(-which.max(yr))
  
  fa <- FrequencyAnalysis(extrms$max, 'lp3')
  getQ(fa$output, rp)  
}
