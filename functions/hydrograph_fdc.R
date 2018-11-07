
########################################################
# Flow Duration Curve
########################################################

flow_duration_curve <- function(pg1,pg2=NULL) {
  p <- ggplot() + theme_bw() +
    theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
    geom_step(data=pg1, aes(x = x, y = (1-y)*100, color="complete data range"), size=2.5) +
    coord_flip() + scale_x_log10() +
    labs(x = gglabcms, y = "Exceedance frequency (%)")
  
  if(!is.null(pg2)){
    p <- p + geom_step(data=pg2, aes(x = x, y = (1-y)*100, color="selected data range"), size=2) +
      scale_colour_manual(values=c("selected data range"="#ffa552", "complete data range"="#001a7f"))
  }
  
  return(p)
}

flow_duration_curve2 <- function(hyd,DTrng=NULL) {
  if(is.null(DTrng)){
    flow_duration_curve(flow_duration_curve_build(hyd))
  }else{
    flow_duration_curve(flow_duration_curve_build(hyd,DTrng))
  }
}

flow_duration_curve_build <- function(hyd,DTrng=NULL){
  if(is.null(DTrng)){
    p <- ggplot(hyd, aes(Flow)) + stat_ecdf()
  }else{
    p <- ggplot(subset(hyd, Date>=min(DTrng) & Date<=max(DTrng)), aes(Flow)) + stat_ecdf()
  }
  return(ggplot_build(p)$data[[1]])
}