
########################################################
# annual flow summary
########################################################
flow_summary_annual <- function(hyd,carea,k=NULL,title=NULL,relative=FALSE){
  if (!"BF.med" %in% colnames(hyd)){hyd <- baseflow_range(hyd,carea,k)}
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  unit <- 'm?/s'
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
  
  # NEW
  # summarize by year
  dfm35 <- df.annual.simple(hyd)
  df <- hyd %>%
    mutate(year = year(Date)) %>%
    group_by(year) %>%
    dplyr::summarise(mf = mean(Flow, na.rm = TRUE), mb = mean(BF.med, na.rm = TRUE), n = sum(!is.na(Flow)))

  df <- merge(x = df, y = dfm35, by = "year", all.x = TRUE)
  df$wmo <- df$wmo>=1
  df$wmoc <- ''
  df$wmoc[!df$wmo] = 'black'

  p <- ggplot(df, aes(year)) +
    theme_bw() + theme(legend.position=c(0.01,0.01), legend.justification=c(0,0), legend.title=element_blank(), 
                       legend.background = element_rect(fill=alpha('white', 0.4))) +
    geom_bar(stat="identity",aes(y=mf, fill='Total Flow', colour=wmo), size=1) + 
    geom_bar(stat="identity",aes(y=mb, fill='Baseflow', colour=wmo), size=1 , width=0.75) + 
    scale_fill_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca"), guide=guide_legend(reverse=T)) +
    scale_colour_manual(values=c('TRUE'=NA, 'FALSE'="red"), guide=FALSE) +
    scale_x_continuous(breaks=seq(min(hyd$yr, na.rm=TRUE),max(hyd$yr, na.rm=TRUE),by=5))
  
  # # OLD
  # p <- ggplot(hyd,aes(yr)) +
  #   theme_bw() + theme(legend.position=c(0.01,0.01), legend.justification=c(0,0), legend.title=element_blank(),
  #                      legend.background = element_rect(fill=alpha('white', 0.4))) +
  #   stat_summary(aes(y=Flow,fill='Total Flow'),fun.y="mean", geom="bar") +
  #   stat_summary(aes(y=BF.med,fill='Baseflow', width=0.75),fun.y="mean", geom="bar") +
  #   scale_fill_manual(values=c("Total Flow" = "#ef8a62", "Baseflow" = "#43a2ca"), guide=guide_legend(reverse=T)) +
  #   scale_x_continuous(breaks=seq(min(hyd$yr, na.rm=TRUE),max(hyd$yr, na.rm=TRUE),by=5))
  # 
  
  if(!relative){
    p <- p + geom_hline(yintercept = mQ, size=1, linetype='dotted') +
      annotate("text", x=min(hyd$yr), y=mQ, label=paste0("mean discharge = ",round(mQ,0),unit), hjust=0,vjust=-1,size=4) +
      geom_hline(yintercept = mBF, size=1, linetype='dotted') +
      annotate("text", x=min(hyd$yr), y=mBF, label=paste0("mean baseflow discharge = ",round(mBF,0),unit), hjust=0,vjust=-1,size=4) +
      labs(y = paste0("Discharge (",unit,")"), x=NULL)
  }else{
    p <- p + labs(y = paste0("discharge relative to mean (",unit,")"), x=NULL)
  }

  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}

######################
### plots
######################
output$yr.q <- renderPlot({isolate({
  if (!sta$BFbuilt) separateHydrograph()  
  if (!is.null(sta$hyd)){
    flow_summary_annual(sta$hyd,sta$carea,sta$k,sta$label)
  }
})})

output$yr.q.rel <- renderPlot({isolate({
  if (!sta$BFbuilt) separateHydrograph()
  if (!is.null(sta$hyd)){
    flow_summary_annual(sta$hyd,sta$carea,sta$k,sta$label,TRUE)
  }
})})