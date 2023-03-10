


monthly_summary_box <- function(hyd, carea, title, DTrng=NULL) {
  hyd <- hyd %>% mutate(Date=as.Date(Date), mnt=factor(strftime(Date, format="%b"),levels=c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'))) 
  
  if(!is.null(DTrng)) hyd <- hyd[hyd$Date >= DTrng[1] & hyd$Date <= DTrng[2],]

  
  # collect all boxplot stats for selected range
  m1 <- matrix(nrow=12,ncol=5)
  t1 <- by(hyd$Flow,hyd$mnt,boxplot.stats)
  for (i in 1:12){
    m1[i,] <- t1[[i]][[1]]
  }
  
  p <- ggplot(hyd) + 
    theme_bw() +
    geom_boxplot(aes(x = mnt, y = Flow), size = 1) + #, outlier.shape = NA) +
    # coord_cartesian(ylim = c(0,max(m1[,5]))*1.05) +
    ggtitle(title) + xlab('Month')
  
  if (!is.null(carea)) {
    p + scale_y_log10(name = gglabcms, sec.axis = sec_axis( trans=~.*31557.6/carea, name=paste0("Discharge (mm/yr)")))
  } else {
    p + scale_y_log10(name = gglabcms)
  }
}



output$mnt.qbox <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.mnt_date_window
      monthly_summary_box(sta$hyd,sta$carea,sta$label,rng)
    }
  )
})



output$rng.mnt <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})



output$tab.mnt <- renderFormattable({
  req(rng <- input$rng.mnt_date_window)
  if (!is.null(sta$hyd)){
    sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] %>%
      mutate(Month=month(Date)) %>%
      group_by(Month) %>%
      dplyr::summarise(mean = mean(Flow,na.rm=TRUE),
                       st.Dev = sd(Flow,na.rm=TRUE),
                       p5 = quantile(Flow,.05,na.rm=TRUE),
                       median = median(Flow,na.rm=TRUE),
                       p95 = quantile(Flow,.95,na.rm=TRUE),
                       n = sum(!is.na(Flow)),
                       .groups = "keep") %>%     
      ungroup()%>%
      mutate(Month=month.abb[Month]) %>%
      formattable()
  }
})

output$info.mnt <- renderUI({
  req(rng <- input$rng.mnt_date_window)
  DTb <- as.Date(strftime(rng[[1]], "%Y-%m-%d"))
  DTe <- as.Date(strftime(rng[[2]], "%Y-%m-%d"))
  isolate({
    por <- as.integer(difftime(DTe, DTb, units = "days"))
    shiny::HTML(paste0(
      '<body>',
      paste0(
        '<div><h4>Distribution summary:</h4></div>',
        sta$label,';  ',strftime(DTb, "%b %Y"),' to ',strftime(DTe, "%b %Y"),' (',por+1,' days)</div>'
      ),
      '</body>'
    ))
  })
})