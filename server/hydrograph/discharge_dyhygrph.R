

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
