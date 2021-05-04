
########################################################
# Flow Duration Curve
########################################################

flow_duration_curve <- function(pg1,pg2=NULL) {
  breaks <- 10^(-10:10)
  minor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))
  
  p <- ggplot() + 
    theme_bw() + theme(panel.grid.major = element_line(colour = "#808080"), panel.grid.minor = element_line(colour = "#808080")) +
    theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
    geom_step(data=pg1, aes(x = x, y = (1-y)*100, color="complete data range"), size=2.5) +
    coord_flip() + scale_x_log10(breaks = breaks, minor_breaks = minor_breaks) +
    labs(x = gglabcms, y = "Exceedance frequency (%)",title='Flow Duration Curve')
  
  if(!is.null(pg2)){
    p <- p + geom_step(data=pg2, aes(x = x, y = (1-y)*100, color="selected data range"), size=2) +
      scale_colour_manual(values=c("selected data range"="#ffa552", "complete data range"="#001a7f"))
  }
  
  return(p) 
}

flow_duration_curve2 <- function(hyd,DTrng=NULL) {
  if(is.null(DTrng)){
    stat <- quantile(pg1$x,probs=c(0.5,0.95,0.05),na.rm=T)
    flow_duration_curve(flow_duration_curve_build(hyd), stat)
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