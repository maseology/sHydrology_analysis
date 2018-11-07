
########################################################
# cumulative flow summary
########################################################
flow_summary_cumu <- function(hyd,carea,title=NULL,DTrng=NULL){
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  if(!is.null(carea)){
    df <- data.frame(d=hyd$Date, c=cumsum(hyd$Flow)*86.4/carea, b=cumsum(hyd$BF.med)*86.4/carea)
    unit = expression('Cumulative streamflow ' ~ (mm))
  }else{
    df <- data.frame(d=hyd$Date, c=cumsum(hyd$Flow)*86400, b=cumsum(hyd$BF.med)*86400)
    unit = expression('Cumulative streamflow ' ~ (m^3))
  }
  
  p <- ggplot(df, aes(d)) +
    theme_bw() + theme(legend.position=c(0.03,0.97), legend.justification=c(0,1), legend.title=element_blank()) +
    geom_line(aes(y=c, color="Total Flow"),size=2) +
    geom_line(aes(y=b, color="Baseflow"),size=2) +
    geom_segment(aes(x=min(d),xend=max(d),y=0,yend=max(c)),size=1,linetype="dotted") + 
    geom_segment(aes(x=min(d),xend=max(d),y=0,yend=max(b)),size=1,linetype="dotted") + 
    scale_colour_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca")) +
    labs(x = NULL, y = unit) +
    scale_x_date()
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p) 
}

flow_summary_cumu_bf <- function(hyd,carea,title=NULL,DTrng=NULL){
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  df <- data.frame(d=hyd$Date, b=rollmean(hyd$BF.med/hyd$Flow, 365, fill=NA))
  
  p <- ggplot(df, aes(d,b)) +
    theme_bw() + #theme(legend.position=c(0.03,0.97), legend.justification=c(0,1), legend.title=element_blank()) +
    geom_line() +
    labs(x = NULL, y = "Baseflow Index (BFI)") +
    scale_x_date()
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p) 
}


######################
### plots
######################
output$cum.q <- renderPlot({
  input$mouseup
  isolate({
    if (!sta$BFbuilt) separateHydrograph()
    if (!is.null(sta$hyd)){
      rng <- input$rng.cd_date_window
      flow_summary_cumu(sta$hyd,sta$carea,'Cumulative discharge',rng)
    }
  })
})

output$cum.bf <- renderPlot({
  input$mouseup
  isolate({
    if (!sta$BFbuilt) separateHydrograph()
    if (!is.null(sta$hyd)){
      rng <- input$rng.cd_date_window
      flow_summary_cumu_bf(sta$hyd,sta$carea,'Baseflow index',rng)
    }
  })
})

output$rng.cd <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})