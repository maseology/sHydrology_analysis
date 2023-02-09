
########################################################
# cumulative flow summary
########################################################
flow_summary_cumu <- function(hyd,carea,title=NULL,DTrng=NULL){
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  
  # infill NAs
  df <- data.frame(d=hyd$Date, q=hyd$Flow, b=hyd$BF.med) %>%
    mutate(Date = as.Date(d)) %>%
    complete(Date = seq.Date(min(d), max(d), by="day")) %>%
    replace_na(list(q=mean(hyd$Flow,na.rm=TRUE),b=mean(hyd$BF.med,na.rm=TRUE)))
  
  if(!is.null(carea)){
    # df <- data.frame(d=hyd$Date, c=cumsum(hyd$Flow)*86.4/carea, b=cumsum(hyd$BF.med)*86.4/carea)
    df <- data.frame(d=df$Date, c=cumsum(df$q)*86.4/carea, b=cumsum(df$b)*86.4/carea, infil=is.na(df$d))
    unit = expression('Cumulative streamflow ' ~ (mm))
  }else{
    # df <- data.frame(d=hyd$Date, c=cumsum(hyd$Flow)*86400, b=cumsum(hyd$BF.med)*86400)
    df <- data.frame(d=df$Date, c=cumsum(df$q)*86400, b=cumsum(df$b)*86400, infil=is.na(df$d))
    unit = expression('Cumulative streamflow ' ~ (m^3))
  }
  
  # blank-out infilled data
  df$c[df$infil] = NA
  df$b[df$infil] = NA
  
  pwc <- piecewise.regression.line(data.frame(x=df$d,y=df$c))
  pwb <- piecewise.regression.line(data.frame(x=df$d,y=df$b))
 
  p <- ggplot(df, aes(d)) +
    theme_bw() + theme(legend.position=c(0.03,0.97), legend.justification=c(0,1), legend.title=element_blank()) +
    theme(panel.grid.major = element_line(colour = "#808080"), panel.grid.minor = element_line(colour = "#808080")) +
    geom_line(aes(y=c, color="Total Flow"), size=2) +
    geom_line(aes(y=b, color="Baseflow"), size=2) +
    geom_line(aes(x=d,y=v), pwc$df, color="blue", size=1, alpha=0.7) +
    geom_line(aes(x=d,y=v), pwb$df, color="blue", size=1, alpha=0.7) +
    { if (length(pwc$brk$x)>0) geom_point(aes(x=pwc$brk$x,y=pwc$brk$y), shape=19, size=5, color="blue") } +
    { if (length(pwb$brk$x)>0) geom_point(aes(x=pwb$brk$x,y=pwb$brk$y), shape=19, size=5, color="blue") } +
    geom_segment(aes(x=min(d,na.rm=TRUE),xend=max(d,na.rm=TRUE),y=0,yend=max(c,na.rm=TRUE)),size=1,linetype="dotted") +
    geom_segment(aes(x=min(d,na.rm=TRUE),xend=max(d,na.rm=TRUE),y=0,yend=max(b,na.rm=TRUE)),size=1,linetype="dotted") +
    scale_colour_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca")) +
    labs(x = NULL, y = unit) +
    scale_x_date()
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p) 
}

flow_summary_cumu_bf <- function(hyd,carea,title=NULL,DTrng=NULL){
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]
  # df <- data.frame(d=hyd$Date, b=rollmean(hyd$BF.med/hyd$Flow, 365, fill=NA))
  df <- data.frame(d=hyd$Date, b=rollsum(hyd$BF.med, 365, fill=NA)/rollsum(hyd$Flow, 365, fill=NA))
  
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
      sfx <- ''
      if(!is.null(rng)) sfx <- paste0(': ',substr(rng[1],1,4),'-',substr(rng[2],1,4))
      withProgress(
        message = 'rendering cumulative discharge plot..', value = 0.5, {
          flow_summary_cumu(sta$hyd,sta$carea,paste0(sta$label,'\ncumulative discharge',sfx),rng)
        }
      )
    }
  })
})

output$cum.bf <- renderPlot({
  input$mouseup
  isolate({
    if (!sta$BFbuilt) separateHydrograph()
    if (!is.null(sta$hyd)){
      rng <- input$rng.cd_date_window
      sfx <- ''
      if(!is.null(rng)) sfx <- paste0(': ',substr(rng[1],1,4),'-',substr(rng[2],1,4))
      withProgress(
        message = 'rendering baseflow index plot..', value = 0.5, {
          flow_summary_cumu_bf(sta$hyd,sta$carea,paste0(sta$label,'\nbaseflow index',sfx),rng)
        }
      )
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
      dyRangeSelector(fillColor='', height=80)
  }
})