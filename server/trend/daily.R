

########################################################
# annual-average daily discharge
########################################################
flow_summary_daily <- function(hyd,carea,k=NULL,title=NULL,DTrng=NULL,minmaxmean=FALSE){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$doy <- as.numeric(format(hyd$Date, "%j"))
  unit <- 'm?/s'
  if(!is.null(carea)){
    hyd$BF.med <- hyd$BF.med * 31557.6/carea # mm/yr
    hyd$Flow <- hyd$Flow * 31557.6/carea # mm/yr    
    unit <- 'mm/yr'
  }
  
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  
  hyd$dQ <- rollapply(hyd$Flow,5,mean,align='center',partial=TRUE)
  hyd$dBF <- rollapply(hyd$BF.med,5,mean,align='center',partial=TRUE)
  dQ <- aggregate(dQ ~ doy, hyd, mean)[,2]
  dQn <- aggregate(dQ ~ doy, hyd, min)[,2]
  dQx <- aggregate(dQ ~ doy, hyd, max)[,2]
  dBF <- aggregate(dBF ~ doy, hyd, mean)[,2]
  df <- data.frame(doy=seq(1,366),dQ,dQn,dQx,dBF)
  df$doy <- as.Date(df$doy - 1, origin = "2008-01-01")
  
  if (minmaxmean) {
    plotnam = "Range of observed mean-daily discharge"
    p <- ggplot(df,aes(doy)) +
      theme_bw() + theme(legend.position=c(0.03,0.8), legend.justification=c(0,0), legend.title=element_blank(),
                         legend.background = element_rect(fill=alpha('white', 0.4))) +
      geom_line(aes(y=dQ, linetype="mean")) + 
      geom_line(aes(y=dQn, linetype="min")) +
      geom_line(aes(y=dQx, linetype="max")) +
      scale_linetype_manual(values=c("min" = "dashed", "mean"="solid", "max" = "dashed")) +
      scale_x_date(date_labels="%b", date_breaks = 'month') +
      labs(y = paste0("Discharge (",unit,")"), x='Day of year')    
  } else {
    plotnam = "Julian-day mean of mean-daily discharge"
    p <- ggplot(df,aes(doy)) +
      theme_bw() + theme(legend.position=c(0.03,0.03), legend.justification=c(0,0), legend.title=element_blank(),
                         legend.background = element_rect(fill=alpha('white', 0.4))) +
      geom_area(aes(y=dQ,fill='Total Flow')) + geom_area(aes(y=dBF,fill='Baseflow')) +
      scale_fill_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca"), guide=guide_legend(reverse=T)) +
      scale_x_date(date_labels="%b", date_breaks = 'month') +
      labs(y = paste0("Discharge (",unit,")"), x='Day of year')    
  }
  
  if(!is.null(carea)) p <- p + scale_y_continuous(sec.axis = sec_axis( trans=~.*carea/31557.6, name=gglabcms) )
  
  if(!is.null(title)) p <- p + ggtitle(paste0(plotnam,"\n",title))
  
  return(p)  
}

# flow_summary_box <- function(hyd, carea, title, DTrng=NULL) {
#   hyd <- hyd %>% mutate(Date=as.Date(Date), mnt=factor(strftime(Date, format="%b"),levels=c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'))) 
#   
#   if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
#   
#   unit <- 'm?/s'
#   if(!is.null(carea)){
#     hyd$Flow <- hyd$Flow * 31557.6/carea # mm/yr    
#     unit <- 'mm/yr'
#   }  
#   
#   # collect all boxplot stats for selected range
#   m1 <- matrix(nrow=12,ncol=5)
#   t1 <- by(hyd$Flow,hyd$mnt,boxplot.stats)
#   for (i in 1:12){
#     m1[i,] <- t1[[i]][[1]]
#   }
#   
#   ggplot(hyd) + 
#     theme_bw() +
#     geom_boxplot(aes(x = mnt, y = Flow), size = 1) + #, outlier.shape = NA) +
#     # coord_cartesian(ylim = c(0,max(m1[,5]))*1.05) +
#     scale_y_log10(name = paste0("Discharge (",unit,")"), sec.axis = sec_axis( trans=~.*carea/31557.6, name=gglabcms)) +
#     ggtitle(title) + xlab('Month')
# }



######################
### plots
######################
output$dy.q <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.mdd_date_window
      flow_summary_daily(sta$hyd,sta$carea,sta$k,sta$label,rng)
    }
  )
})

output$dy.qmmm <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.mdd_date_window
      flow_summary_daily(sta$hyd,sta$carea,sta$k,sta$label,rng,minmaxmean=TRUE)
    }
  )
})

# output$dy.qbox <- renderPlot({
#   input$mouseup
#   isolate(
#     if (!is.null(sta$hyd)){
#       rng <- input$rng.mdd_date_window
#       flow_summary_box(sta$hyd,sta$carea,sta$label,rng)
#     }
#   )
# })

output$rng.mdd <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})