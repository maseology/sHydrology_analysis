
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
  # print(DTrng)
  # if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  hyd2 <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  
  # collect all boxplot stats for selected range
  m1 <- matrix(nrow=12,ncol=5)
  t1 <- by(hyd$BF.med,hyd$mnt,boxplot.stats)
  for (i in 1:12){
    m1[i,] <- t1[[i]][[1]]
  }
  
  p <- ggplot() + theme_bw()
  
  if(is.null(DTrng)) {
    p <- p + geom_boxplot(aes(x = reorder(mnt, montho(Date)), y = BF.med), hyd, size = 1, outlier.shape = NA)
  } else {
    p <- p + 
      geom_boxplot(aes(x = reorder(mnt, montho(Date)), y = BF.med, color='black'), hyd, size = 1, outlier.shape = NA) +
      geom_boxplot(aes(x = reorder(mnt, montho(Date)), y = BF.med, colour='red'), hyd2, width=0.5, outlier.shape=NA, fill=NA)
  }
    
  p <- p + coord_cartesian(ylim = c(0,max(m1[,5]))*1.05) +
    labs(x=NULL,y = paste0("median separated baseflow (",unit,")"), title=NULL)
  
  if(!is.null(DTrng)) p <- p + 
    theme(legend.position = c(.99,.99), legend.justification = c(1, 1),) +
    scale_colour_manual(name=element_blank(), values=c('black'='black','red'='red'), labels=c('full record','selected record'))
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}

baseflow_BFI <- function(hyd,carea,k=NULL,title=NULL, DTrng=NULL){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  
  hyd$mnt <- format(hyd$Date, "%b")
  hyd$mnt <- as.factor(hyd$mnt)
  hyd$BFI <- hyd$BF.med/hyd$Flow
  
  # BFI.sum <- ddply(hyd, .(reorder(mnt, montho(hyd$Date))), summarize, 
  #                  mean = round(mean(BFI, na.rm = TRUE), 2), 
  #                  sd = round(sd(BFI, na.rm = TRUE), 2), 
  #                  n = length(Flow))
  BFI.sum <- ddply(hyd, .(reorder(mnt, montho(hyd$Date))), summarize, 
                   mean = sum(BF.med, na.rm = TRUE)/sum(Flow, na.rm = TRUE), 
                   sd = sd(BFI, na.rm = TRUE), 
                   n = length(Flow))
  names(BFI.sum)[names(BFI.sum) == 'reorder(mnt, montho(hyd$Date))'] <- 'mnt'
  BFI.sum$se <- 1.96*BFI.sum$sd/sqrt(BFI.sum$n)
  meanBFI <- sum(hyd$BF.med, na.rm = TRUE)/sum(hyd$Flow, na.rm = TRUE) #mean(hyd$BFI, na.rm = TRUE)
  
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
    qxts <- xts(cbind(sta$hyd$Flow, sta$hyd$BF.med), order.by = sta$hyd$Date)
    colnames(qxts) <- c('Discharge','Baseflow')
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(fillColor='', height=80)
  }
})

output$tab.mntbf <- renderFormattable({
  req(rng <- input$rng.bf_date_window)
  if (!is.null(sta$hyd)){
    if (!sta$BFbuilt) separateHydrograph()
    sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] %>%
      mutate(Month=month(Date)) %>%
      group_by(Month) %>%
      dplyr::summarise(mean = mean(BF.med,na.rm=TRUE),
                       st.Dev = sd(BF.med,na.rm=TRUE),
                       p5 = quantile(BF.med,.05,na.rm=TRUE),
                       median = median(BF.med,na.rm=TRUE),
                       p95 = quantile(BF.med,.95,na.rm=TRUE),
                       n = sum(!is.na(BF.med)),
                       .groups = "keep") %>%     
      ungroup()%>%
      mutate(Month=month.abb[Month]) %>%
      formattable()
  }
})

output$info.mntbf <- renderUI({
  req(rng <- input$rng.bf_date_window)
  DTb <- as.Date(strftime(rng[[1]], "%Y-%m-%d"))
  DTe <- as.Date(strftime(rng[[2]], "%Y-%m-%d"))
  isolate({
    por <- as.integer(difftime(DTe, DTb, units = "days"))
    shiny::HTML(paste0(
      '<body>',
      paste0(
        '<div><h4>Baseflow distribution summary:</h4></div>',
        sta$label,';  ',strftime(DTb, "%b %Y"),' to ',strftime(DTe, "%b %Y"),' (',por+1,' days)</div>'
      ),
      '</body>'
    ))
  })
})