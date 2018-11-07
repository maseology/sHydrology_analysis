

observe({
  input$mouseup
  isolate({
    if (!is.null(sta$hyd)){
      rng <- input$hydgrph_date_window
      sta.fdc$prtl <- flow_duration_curve_build(sta$hyd,rng)
      sta.mnt$prtl <- flow_monthly_bar_build(sta$hyd,sta$carea,rng)
    }
  })
  
})

output$info.main <- renderUI({
  DTb <- as.Date(strftime(req(input$hydgrph_date_window[[1]]), "%Y-%m-%d"))
  DTe <- as.Date(strftime(req(input$hydgrph_date_window[[2]]), "%Y-%m-%d"))
  isolate({
    if (!is.null(sta$hyd)){
      hyd2 <- subset(sta$hyd, Date>=DTb & Date<=DTe)
      stat <- c(mean(hyd2$Flow),quantile(hyd2$Flow,probs=c(0.5,0.95,0.05),na.rm=T))
      
      shiny::HTML(paste0(
        '<body>',
        sta$info.html, br(),
        
        hyd.info.rng(nrow(hyd2)-1,DTb,DTe,stat),
        '</body>'
      ))
    }
  })
})


######################
### plots
######################
output$hydgrph <- renderDygraph({
  wflg <- input$chk.flg
  if (!is.null(sta$hyd)){
    if(!wflg){
      qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
      colnames(qxts) <- 'Discharge'
      dygraph(qxts) %>%
        dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
        dyAxis(name='y', label=dylabcms) %>%
        dyRangeSelector(strokeColor = '', height=80) 
    }else{
      hIce <- data.frame(Date = sta$hyd$Date,q = sta$hyd$Flow,flg = sta$hyd$Flag)
      hIce[hIce$flg!='ice_conditions',]$q <- NA
      hEst <- data.frame(Date = sta$hyd$Date,q = sta$hyd$Flow,flg = sta$hyd$Flag)
      hEst[hIce$flg!='estimate',]$q <- NA
      
      x1 <- xts(hIce$q, order.by = hIce$Date)
      x2 <- xts(hEst$q, order.by = hEst$Date)
      xm <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
      
      qxts <- cbind(xm, x1, x2)
      colnames(qxts) <- c('Discharge','Ice conditions','Estimate')
      dygraph(qxts) %>%
        dySeries("Discharge", stepPlot = TRUE, fillGraph = TRUE, color = "#008080") %>%
        dySeries("Ice conditions", stepPlot = TRUE, fillGraph = TRUE, color = "#ffa552", drawPoints=TRUE, strokeWidth=3) %>%
        dySeries("Estimate", stepPlot = TRUE, fillGraph = TRUE, color = "#008000", drawPoints=TRUE, strokeWidth=3) %>%
        dyOptions() %>%
        dyAxis(name='y', label=dylabcms) %>%
        dyRangeSelector(strokeColor = '', height=80)
    }
  }
})

output$fdc <- renderPlot({
  if (!is.null(sta.fdc$prtl)){
    flow_duration_curve(sta.fdc$cmplt,sta.fdc$prtl)
  }
})

output$mnt.q <- renderPlot({
  if (!is.null(sta.mnt$prtl)){
    flow_monthly_bar(sta.mnt$cmplt,sta.mnt$prtl)
  }
})