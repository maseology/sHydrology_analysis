
observe({
  input$mouseup
  isolate({
    if (!is.null(sta$hyd)){
      rng <- input$dyhydgrph_date_window
      sta.fdc$prtl <- flow_duration_curve_build(sta$hyd,rng)
      sta.mnt$prtl <- flow_monthly_bar_build(sta$hyd,sta$carea,rng)
    }
  })
})

observe({
  if (!is.null(sta$hyd)) 
    updateDateRangeInput(session, "dt.rng", start = sta$DTb, end = sta$DTe, min = sta$DTb, max = sta$DTe)
})

observeEvent(input$dyhydgrph_date_window, {
  updated_date_window(input$dyhydgrph_date_window,"dt.rng")
})

observeEvent(input$dt.rng, {
  rng <- input$dt.rng
  updated_date_selector(rng)
  # isolate({
  #   sta.fdc$prtl <- flow_duration_curve_build(sta$hyd,rng)
  #   sta.mnt$prtl <- flow_monthly_bar_build(sta$hyd,sta$carea,rng)    
  # })
})

output$info.main <- renderUI({
  DTb <- as.Date(strftime(req(input$dyhydgrph_date_window[[1]]), "%Y-%m-%d"))
  DTe <- as.Date(strftime(req(input$dyhydgrph_date_window[[2]]), "%Y-%m-%d"))
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
dRange <- reactive({
  req(rng <- input$dt.rng)
  sta$hyd[sta$hyd$Date >= as.character(rng[1]) & sta$hyd$Date <= as.character(rng[2]),]
})


output$gghydgrph <- renderPlot({
  wflg <- input$chk.flg
  if (!is.null(sta$hyd)){
    df <- dRange()
    if(!wflg){
      ggplot(df,aes(x=Date)) +
        theme_bw() + theme(panel.grid.major = element_line(colour = "#808080"), panel.grid.minor = element_line(colour = "#808080")) +
        geom_line(aes(y=Flow), color="blue") + 
        xlab(gglabcms)
    } else {
      ggplot(df,aes(x=Date,y=Flow,color=factor(Flag))) +
        theme_bw() + theme(panel.grid.major = element_line(colour = "#808080"), panel.grid.minor = element_line(colour = "#808080"), 
                           axis.title.x = element_blank()) +
        theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
        geom_line(aes(group=1),size=1) +
        scale_color_manual(name="",
                      values = c("blue", "ice_conditions"="#ffa552", "estimate"="#008000", "partial"="lightblue", "realtime_uncorrected"="#6635b5"),
                      labels = c("Flow","Ice conditions","Estimate","Partial","Uncorrected")) + 
        ylab(gglabcms) + ggtitle(sta$label)
    }
  }
})


output$dyhydgrph <- renderDygraph({
  wflg <- input$chk.flg
  req(rng <- r$rngselect+1)
  print(rng)
  if (!is.null(sta$hyd) && rng[[1]]!=rng[[2]]){
    if(!wflg){
      if ("Tx" %in% colnames(sta$hyd)){
        print(colnames(sta$hyd))
        qFlw <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
        qRf <- xts(sta$hyd$Rf, order.by = sta$hyd$Date)
        qSm <- xts(sta$hyd$Sm, order.by = sta$hyd$Date)
        
        qx <- cbind(qFlw,qRf,qSm)
        colnames(qx) <- c('Observed','Rainfall','Snowmelt')
        dygraph(qx) %>%
          dySeries("Observed", color = "blue") %>%
          dyBarSeries("Rainfall", axis = 'y2', color="#1f78b4") %>%
          dyBarSeries("Snowmelt", axis = 'y2', color="#a6cee3") %>%
          dyAxis('y', label=dylabcms) %>%
          dyAxis('y2', label='Atmospheric yield (mm)', valueRange = c(100, 0)) %>%
          dyRangeSelector(fillColor='', height=80, dateWindow = rng) %>%
          dyOptions(retainDateWindow = TRUE)
      } else {
        qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
        colnames(qxts) <- 'Discharge'
        if (rng[1]==rng[2]) { # occurs upon opening (bug fix)
          dygraph(qxts) %>%
            dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
            dyAxis(name='y', label=dylabcms) %>%
            dyRangeSelector(fillColor='', height=80) %>%
            dyOptions(retainDateWindow = TRUE)
        } else {
          dygraph(qxts) %>%
            dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
            dyAxis(name='y', label=dylabcms) %>%
            dyRangeSelector(fillColor='', height=80, dateWindow = rng) %>%
            dyOptions(retainDateWindow = TRUE) 
        }
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
        dyRangeSelector(fillColor='', height=80, dateWindow = rng) %>%
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