
########################################################
# Baseflow summary
########################################################
baseflow_boxplot <- function(hyd,carea,k=NULL,title=NULL, DTrng=NULL){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$mnt <- format(hyd$Date, "%b")
  hyd$mnt <- as.factor(hyd$mnt)
  unit <- 'm?/s'
  if(!is.null(carea)){
    hyd$BF.med <- hyd$BF.med * 2592/carea # mm/30 days
    unit <- 'mm' #'mm/month'
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
    labs(x=NULL,y = paste0("median separated baseflow (",unit,")"), title=NULL)
  
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


######################
### plots
######################
output$BF.mnt <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.bf_date_window
      sfx <- ''
      if(!is.null(rng)) sfx <- paste0(': ',substr(rng[1],1,4),'-',substr(rng[2],1,4))
      baseflow_boxplot(sta$hyd,sta$carea,sta$k,paste0(sta$label,'\nmonthly baseflow range',sfx),rng)
    }
  )
})

output$BFI.mnt <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.bf_date_window
      sfx <- ''
      if(!is.null(rng)) sfx <- paste0(': ',substr(rng[1],1,4),'-',substr(rng[2],1,4))
      baseflow_BFI(sta$hyd,sta$carea,sta$k,paste0(sta$label,'\nmonthly baseflow index (BFI)',sfx),rng)
    }
  )
})

output$rng.bf <- renderDygraph({
  if (!is.null(sta$hyd)){
    if (!sta$BFbuilt) separateHydrograph()
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})