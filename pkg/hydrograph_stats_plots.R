##########################################################
######### Hydrograph statistics and plots ################
##########################################################
# By M. Marchildon
#
# Dec 11, 2017
##########################################################



########################################################
# general functions and globals
########################################################
month <- function (x) as.numeric(format(x, "%m"))
montho <- function (x) (month(x)+2) %% 12
#v.mnt <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')


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
        labs(x = "Discharge (day after)", y = "Discharge (m³/s)")
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}



########################################################
# Flow summary
########################################################
flow_summary_annual <- function(hyd,carea,k=NULL,title=NULL,relative=FALSE){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  unit <- 'm³/s'
  if(!is.null(carea)){
    hyd$BF.med <- hyd$BF.med * 31557.6/carea # mm/yr
    hyd$Flow <- hyd$Flow * 31557.6/carea # mm/yr
    unit <- 'mm/yr'
  }

  mQ <- mean(hyd$Flow, na.rm=TRUE)
  mBF <- mean(hyd$BF.med, na.rm=TRUE)

  if(relative){
    hyd$Flow <- hyd$Flow - mQ
    hyd$BF.med <- hyd$BF.med - mBF
  }
  
  p <- ggplot(hyd,aes(yr)) +
    theme_bw() + theme(legend.position=c(0.01,0.01), legend.justification=c(0,0), legend.title=element_blank(), 
                       legend.background = element_rect(fill=alpha('white', 0.4))) +
    stat_summary(aes(y=Flow,fill='Total Flow'),fun.y="mean", geom="bar") +
    stat_summary(aes(y=BF.med,fill='Baseflow', width=0.75),fun.y="mean", geom="bar") +
    scale_fill_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca"), guide=guide_legend(reverse=T)) +
    scale_x_continuous(breaks=seq(min(hyd$yr, na.rm=TRUE),max(hyd$yr, na.rm=TRUE),by=5))

  if(!relative){
    p <- p + geom_hline(yintercept = mQ, size=1, linetype='dotted') +
      annotate("text", x=min(hyd$yr), y=mQ, label=paste0("mean discharge = ",round(mQ,0),unit), hjust=0,vjust=-1,size=4) +
      geom_hline(yintercept = mBF, size=1, linetype='dotted') +
      annotate("text", x=min(hyd$yr), y=mBF, label=paste0("mean baseflow discharge = ",round(mBF,0),unit), hjust=0,vjust=-1,size=4) +
      labs(y = paste0("Discharge (",unit,")"), x=NULL)
  }else{
    p <- p + labs(y = paste0("Relative discharge (",unit,")"), x=NULL)
  }
  if(!is.null(title)) p <- p + ggtitle(title)

  return(p)
}

flow_monthly_bar <- function(pg1,pg2=NULL){
  if(is.null(pg2)){
    p <- ggplot() +
      theme_bw() +
      geom_bar(data=pg1, aes(x,y), stat='identity')     
  }else{
    pg1$name <- "complete data range"
    pg2$name <- "selected data range"
    d <- rbind(pg1, pg2)
    p <- ggplot(d, aes(x, y, fill = name)) +
      theme_bw() + theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
      geom_bar(position = "dodge", stat='identity') +
      scale_fill_manual(values=c("selected data range"="#ffa552", "complete data range"="#001a7f"))
  }
  
  return(
      p + scale_x_discrete(limits=c('Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep'), expand=c(0.01,0.01)) +
          labs(y = "Discharge (mm/month)", x=NULL)
    )
}
flow_monthly_bar2 <- function(hyd,carea,DTrng=NULL){
  if(is.null(DTrng)){
    flow_monthly_bar(flow_monthly_bar_build(hyd,carea))
  }else{
    flow_monthly_bar(flow_monthly_bar_build(hyd,carea),flow_monthly_bar_build(hyd,carea,DTrng))
  }
}

flow_monthly_bar_build <- function(hyd,carea=NULL,DTrng=NULL){
  hyd$mnt <- format(hyd$Date, "%b")
  hyd$mnt <- as.factor(hyd$mnt)
  if(!is.null(carea)) hyd$Flow <- hyd$Flow * 2592/carea # mm/30 days
  
  if(is.null(DTrng)){
    p <- ggplot(hyd, aes(x = reorder(mnt, montho(hyd$Date)), y = Flow)) +
          stat_summary(fun.y="mean", geom="bar")
  }else{
    hyd2 <- subset(hyd, Date>=min(DTrng) & Date<=max(DTrng))
    p <- ggplot(hyd2, aes(x = reorder(mnt, montho(hyd2$Date)), y = Flow)) +
          stat_summary(fun.y="mean", geom="bar")    
  }
  
  return(ggplot_build(p)$data[[1]])
}

flow_summary_daily <- function(hyd,carea,k=NULL,title=NULL,DTrng=NULL){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$doy <- as.numeric(format(hyd$Date, "%j"))
  unit <- 'm³/s'
  if(!is.null(carea)){
    hyd$BF.med <- hyd$BF.med * 31557.6/carea # mm/yr
    hyd$Flow <- hyd$Flow * 31557.6/carea # mm/yr    
    unit <- 'mm/yr'
  }

  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]

  hyd$dQ <- rollapply(hyd$Flow,5,mean,align='center',partial=TRUE)
  hyd$dBF <- rollapply(hyd$BF.med,5,mean,align='center',partial=TRUE)
  dQ <- aggregate(dQ ~ doy, hyd, mean)[,2]
  dBF <- aggregate(dBF ~ doy, hyd, mean)[,2]
  df <- data.frame(doy=seq(1,366),dQ,dBF)
  df$doy <- as.Date(df$doy - 1, origin = "2008-01-01")
  
  p <- ggplot(df,aes(doy)) +
      theme_bw() + theme(legend.position=c(0.03,0.03), legend.justification=c(0,0), legend.title=element_blank(),
                         legend.background = element_rect(fill=alpha('white', 0.4))) +
      geom_area(aes(y=dQ,fill='Total Flow')) + geom_area(aes(y=dBF,fill='Baseflow')) +
      scale_fill_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca"), guide=guide_legend(reverse=T)) +
      scale_x_date(date_labels="%b", date_breaks = 'month') +
      labs(y = paste0("Discharge (",unit,")"), x='Day of year')
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)  
}

flow_summary_cumu <- function(hyd,carea,title=NULL,DTrng=NULL){
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  if(!is.null(carea)){
    df <- data.frame(d=hyd$Date, c=cumsum(hyd$Flow)*86.4/carea)
    unit = 'mm'
  }else{
    df <- data.frame(d=hyd$Date, c=cumsum(hyd$Flow)*86400)
    unit = 'm³'
  }
  
  p <- ggplot(df,aes(d,c)) +
        theme_bw() + theme(legend.position=c(0.03,0.97), legend.justification=c(0,1), legend.title=element_blank()) +
        geom_line(aes(color="Actual"),size=2) +
        geom_segment(aes(x=min(d),xend=max(d),y=0,yend=max(c), color="Long term average"),size=1.25,linetype="dashed") + 
        scale_colour_manual(values=c("Actual"="orange", "Long term average"="blue")) +
        labs(x = NULL, y = "Cumulative streamflow (",unit,")") +
        scale_x_date()
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p) 
}


########################################################
# Baseflow summary
########################################################
baseflow_boxplot <- function(hyd,carea,k=NULL,title=NULL, DTrng=NULL){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$mnt <- format(hyd$Date, "%b")
  hyd$mnt <- as.factor(hyd$mnt)
  unit <- 'm³/s'
  if(!is.null(carea)){
    hyd$BF.med <- hyd$BF.med * 2592/carea # mm/30 days
    unit <- 'mm/month'
  }
  
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  
  # collect all boxplot stats
  m1 <- matrix(nrow=12,ncol=5)
  t1 <- by(hyd$BF.med,hyd$mnt,boxplot.stats)
  for (i in 1:12){
    m1[i,] <- t1[[i]][[1]]
  }
  
  p <- ggplot(hyd, aes(x = reorder(mnt, montho(hyd$Date)), y = BF.med)) +
        theme_bw() +
        geom_boxplot(outlier.shape = NA) +
        coord_cartesian(ylim = c(0,max(m1[,5]))*1.05) +
        labs(x=NULL,y = paste0("Baseflow discharge (",unit,")"), title=NULL)
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}

baseflow_BFI <- function(hyd,carea,k=NULL,title=NULL, DTrng=NULL){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$mnt <- format(hyd$Date, "%b")
  hyd$mnt <- as.factor(hyd$mnt)
  hyd$BFI <- hyd$BF.med/hyd$Flow
    
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  
  BFI.sum <- ddply(hyd, .(reorder(mnt, montho(hyd$Date))), summarize, 
                   mean = round(mean(BFI, na.rm = TRUE), 2), 
                   sd = round(sd(BFI, na.rm = TRUE), 2), 
                   n = length(Flow))
  names(BFI.sum)[names(BFI.sum) == 'reorder(mnt, montho(hyd$Date))'] <- 'mnt'
  BFI.sum$se <- 1.96*BFI.sum$sd/sqrt(BFI.sum$n)
  meanBFI <- mean(hyd$BFI, na.rm = TRUE)
  
  p <- ggplot(BFI.sum, aes(x = mnt, y = mean, group=1)) +
    theme_bw() +
    geom_point() +
    geom_hline(yintercept = meanBFI, size=1, linetype='dotted') +
    annotate("text", x='Oct', y=meanBFI, label=paste0("annual BFI = ",round(meanBFI,2)), hjust=0,vjust=-1,size=4) +
    # geom_line(size=1,linetype='dotted') +
    geom_errorbar(aes(ymin=mean-se,ymax=mean+se)) +
    # geom_ribbon(aes(ymin=mean-se,ymax=mean+se),alpha=0.15) +
    labs(x=NULL,y = "Baseflow Index (BFI)", title=NULL)
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}


########################################################
# Peakflow frequency
########################################################
peak_flow_frequency <- function(hyd, dist='lp3', n = 2.5E4, ci = 0.90, title=NULL) {
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  input_data <- aggregate(Flow ~ yr, hyd, max)[,2]
  
  ci <- BootstrapCI(series=input_data, # flow data
                    distribution=dist, # distribution
                    n.resamples = n,   # number of re-samples to conduct
                    ci = ci)           # confidence interval level
  
  # generate frequency plot
  return(frequencyPlot(series=input_data, ci$ci, title))
}

peak_flow_histogram <- function(hyd, title=NULL){
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  df <- data.frame(peak=aggregate(Flow ~ yr, hyd, max)[,2])
  
  p <- ggplot(df,aes(peak)) +
    theme_bw() +
    geom_density(colour='blue', size=1, fill='blue', alpha=0.2) +
    labs(x='Annual maximum daily discharge (m³/s)', title=NULL)
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}


########################################################
# Flow Duration Curve
########################################################
flow_duration_curve <- function(pg1,pg2=NULL) {
  p <- ggplot() + theme_bw() +
    theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
    geom_step(data=pg1, aes(x = x, y = (1-y)*100, color="complete data range"), size=2.5) +
    coord_flip() + scale_x_log10() +
    labs(x = "Discharge (m³/s)", y = "Exceedance frequency (%)")
  
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


########################################################
# Flow Duration Curve
########################################################
flow_hydrograph_parsed <- function(hyd,InclEV=TRUE){
  
  h1 <- data.frame(Date = hyd$Date,q = hyd$Flow,qtyp = hyd$qtyp)
  h1$qtyp <- rollapply(h1$qtyp, width=list(-1:0), function(x) if(!any(is.na(x)) && x[1]==1 && x[2]!=1){1}else{x[2]}, fill=NA)
  h1$q[h1$qtyp!=1] <- NA
  h2 <- data.frame(Date = hyd$Date,q = hyd$Flow,qtyp = hyd$qtyp)
  h2$qtyp <- rollapply(h2$qtyp, width=list(-1:0), function(x) if(!any(is.na(x)) && x[1]==2 && x[2]!=2){2}else{x[2]}, fill=NA)
  h2$q[h2$qtyp!=2] <- NA
  h4 <- data.frame(Date = hyd$Date,q = hyd$Flow,qtyp = hyd$qtyp)
  h4$qtyp <- rollapply(h4$qtyp, width=list(-1:0), function(x) if(!any(is.na(x)) && x[1]==4 && x[2]!=4){4}else{x[2]}, fill=NA)
  h4$q[h4$qtyp!=4] <- NA
  
  x1 <- xts(h1$q, order.by = hyd$Date)
  x2 <- xts(h2$q, order.by = hyd$Date)
  x4 <- xts(h4$q, order.by = hyd$Date)
  if(InclEV){
    xe <- xts(hyd$evnt, order.by = hyd$Date)
    qx <- cbind(x1,x2,x4,xe)
    colnames(qx) <- c('falling limb','recession','rising limb','event volume')
    p <- dygraph(qx) %>%
      dySeries("recession", color = "green",strokeWidth=2, fillGraph = TRUE) %>%
      dySeries("falling limb", color = "blue",strokeWidth=2, fillGraph = TRUE) %>%
      dySeries("rising limb", color = "red",strokeWidth=2, fillGraph = TRUE) %>%
      dyBarSeries("event volume", color = "brown", axis = 'y2') %>%
      dyAxis('y', label='Discharge (m³/s)') %>%
      dyAxis('y2', label='Event volume (mm)', valueRange = c(max(hyd$evnt,na.rm=T), 0)) %>%
      dyLegend(show = 'always') %>%  
      dyOptions(axisLineWidth = 1.5, fillAlpha = 0.5, stepPlot = FALSE) %>%
      dyLegend(width = 500) %>%
      dyRangeSelector(height=80)
  }else{
    qx <- cbind(x1,x2,x4)
    colnames(qx) <- c('falling limb','recession','rising limb')
    p <- dygraph(qx) %>%
      dySeries("recession", color = "green",strokeWidth=2, fillGraph = TRUE) %>%
      dySeries("falling limb", color = "blue",strokeWidth=2, fillGraph = TRUE) %>%
      dySeries("rising limb", color = "red",strokeWidth=2, fillGraph = TRUE) %>%
      dyAxis('y', label='Discharge (m³/s)') %>%
      dyLegend(show = 'always') %>%  
      dyOptions(axisLineWidth = 1.5, fillAlpha = 0.5, stepPlot = FALSE) %>%
      dyLegend(width = 500) %>%
      dyRangeSelector(height=80)
  }
  
  return(p)
}

flow_hydrograph_parsed2 <- function(hyd,carea,k,InclEV=TRUE){
  if(is.null(carea)) InclEV=FALSE
  hyd <- parse_hydrograph(hyd,k)
  if(InclEV) hyd <- discretize_hydrograph(hyd,carea,k)
  return(flow_hydrograph_parsed(hyd,InclEV))
}