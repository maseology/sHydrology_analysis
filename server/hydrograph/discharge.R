

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
  wyld <- input$chk.yld
  if (!is.null(sta$hyd)){
    if(!wflg){
      if (wyld && !is.null(sta$intrp)){
        qFlw <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
        qPre <- xts(sta$intrp$yld, order.by = sta$intrp$Date)
        qSim <- xts(sta$intrp$sim, order.by = sta$intrp$Date)
        qx <- cbind(qFlw,qSim,qPre)
        colnames(qx) <- c('Observed','Simulated','Atmospheric yield')
        dygraph(qx) %>%
          dySeries("Observed", color = "blue") %>%
          dySeries("Simulated", color = "red", strokePattern='dotted') %>%
          # dyBarSeries("Atmospheric yield", axis = 'y2') %>%  ### BUG: these don't seem to appear as of 191126
          dySeries("Atmospheric yield", axis = 'y2', color="#008080", stepPlot = TRUE, fillGraph = TRUE) %>%
          dyAxis('y', label=dylabcms) %>%
          dyAxis('y2', label='Atmospheric yield (mm)', valueRange = c(100, 0)) %>%
          dyRangeSelector(strokeColor = '', height=80) %>%
          dyOptions(retainDateWindow = TRUE)
      } else {
        qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
        colnames(qxts) <- 'Discharge'
        dygraph(qxts) %>%
          dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
          dyAxis(name='y', label=dylabcms) %>%
          dyRangeSelector(strokeColor = '', height=80) %>%
          dyOptions(retainDateWindow = TRUE)        
      }
    }else{
      hIce <- data.frame(Date = sta$hyd$Date,q = sta$hyd$Flow,flg = sta$hyd$Flag)
      hIce[hIce$flg!='ice_conditions',]$q <- NA
      hEst <- data.frame(Date = sta$hyd$Date,q = sta$hyd$Flow,flg = sta$hyd$Flag)
      hEst[hEst$flg!='estimate',]$q <- NA
      hRaw <- data.frame(Date = sta$hyd$Date,q = sta$hyd$Flow,flg = sta$hyd$Flag)
      hRaw[hRaw$flg!='realtime_uncorrected',]$q <- NA
      
      x1 <- xts(hIce$q, order.by = hIce$Date)
      x2 <- xts(hEst$q, order.by = hEst$Date)
      x3 <- xts(hRaw$q, order.by = hRaw$Date)
      xm <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
      
      qxts <- cbind(xm, x1, x2, x3)
      colnames(qxts) <- c('Discharge','Ice conditions','Estimate','Uncorrected')
      dygraph(qxts) %>%
        dySeries("Discharge", stepPlot = TRUE, fillGraph = TRUE, color = "blue") %>%
        dySeries("Ice conditions", stepPlot = TRUE, fillGraph = TRUE, color = "#ffa552", drawPoints=TRUE, strokeWidth=3) %>%
        dySeries("Estimate", stepPlot = TRUE, fillGraph = TRUE, color = "#008000", drawPoints=TRUE, strokeWidth=3) %>%
        dySeries("Uncorrected", stepPlot = TRUE, fillGraph = TRUE, color = "#6635b5", drawPoints=TRUE, strokeWidth=3) %>%
        dyOptions() %>%
        dyAxis(name='y', label=dylabcms) %>%
        dyRangeSelector(strokeColor = '', height=80) %>%
        dyOptions(retainDateWindow = TRUE)
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