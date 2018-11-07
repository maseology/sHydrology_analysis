
########################################################
# automated extraction of the baseflow recession coefficient k as in Linsley, Kohler, Paulhus (1975) pg.230
# ref: Linsley, R.K., M.A. Kohler, J.L.H. Paulhus, 1975. Hydrology for Engineers 2nd ed. McGraw-Hill. 482pp.
########################################################
recession_coef <- function(Flow){
  r2 <- 0
  m <- 1.0
  RPt <- recession_coef_Qp1(Flow)
  repeat{
    fit <- lm(Q ~ 0 + Qp1, data=RPt)
    # summary(fit)
    m <- as.numeric(coef(fit)) 
    r2 <- summary(fit)$r.squared
    if (r2>=0.999){break}
    RPt <- RPt[fit$residuals < 0,]
  }
  k <- 1/m
  return(k)
}

recession_coef_Qp1 <- function(Flow){
  # collect recession points
  RP <- data.frame(Q=Flow, Qp1=rep(NA, length(Flow)))
  for(i in 2:length(Flow)) {
    RP$Qp1[i] <- RP$Q[i-1]
  }
  # View(RP)
  RP <- na.omit(RP)
  RP <- RP[RP$Qp1 <= RP$Q & RP$Q > 0,]
  return(RP)
}
recession_coef_plot <- function(Flow, k=NULL, title=NULL){
  if (is.null(k)){k <- recession_coef(Flow)}
  RP <- recession_coef_Qp1(Flow)
  rng <- c(min(RP$Q),max(RP$Q))
  mb <- as.numeric(1:10 %o% 10^(floor(log10(rng[1])):floor(log10(rng[2]))))
  t1 <- paste0('recession coefficient: ',round(k,3),'; n = ',length(RP$Q))
  p <- ggplot(RP, aes(x = Qp1, y = Q)) +
    theme_bw() + theme(panel.grid.minor = element_line(colour="grey90", size=0.5)) +
    #geom_abline(slope=1/k,intercept=0, color="orange",size=2) +
    geom_segment(aes(x=rng[1],xend=rng[2],y=rng[1],yend=rng[2]/k), color="orange",size=2) +
    geom_point(size=2, colour='blue', alpha=0.2) +
    #geom_abline(slope=1/k,intercept=0, size=0.5) +
    geom_segment(aes(x=rng[1],xend=rng[2],y=rng[1],yend=rng[2]/k), size=0.5) +
    scale_x_log10(minor_breaks = mb) + scale_y_log10(minor_breaks = mb) + 
    annotate("text", x=0.9*rng[2], y=1.3*rng[1], label=t1, hjust=1,vjust=1,size=4) +
    labs(x = "Discharge (day after)", y = gglabcms)
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}