

### main hydrograph
observe({
  isolate(withProgress(message = 'collecting station info..', value = 0.1, {
    sta$loc <- staID
    info <- qStaInfo(dbc,staID)
    sta$carea <- info$drainage_area
    if(sta$carea<=0) sta$carea=NULL
    sta$id <- info$sID
    sta$name <- info$sName
    sta$name2 <- info$sName2
    sta$label <- paste0(sta$name,': ',sta$name2)
    setProgress(message = 'rendering plot..',value=0.45)
    sta$hyd <- qTemporal(dbc,sta$id)
    sta$DTb <- min(sta$hyd$Date, na.rm=T)
    sta$DTe <- max(sta$hyd$Date, na.rm=T)
    sta$k <- recession_coef(sta$hyd$Flow)
    stat <- c(mean(sta$hyd$Flow),quantile(sta$hyd$Flow,probs=c(0.5,0.95,0.05), na.rm=T))
    sta$info.html <- hyd.info(sta$label,nrow(sta$hyd)-1,min(sta$hyd$Date,na.rm=T),max(sta$hyd$Date,na.rm=T),sta$carea,stat)
    updateNumericInput(session,'k.val',value=sta$k)
    sta.fdc$cmplt <- flow_duration_curve_build(sta$hyd)
    sta.mnt$cmplt <- flow_monthly_bar_build(sta$hyd,sta$carea)
  }))
  shinyjs::hide(id = "loading-content", anim = TRUE, animType = "fade")
  shinyjs::show("app-content")
})

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
      stat <- c(mean(hyd2$Flow),quantile(hyd2$Flow,probs=c(0.5,0.95,0.05), na.rm=T))

      shiny::HTML(paste0(
        '<body>',
        sta$info.html, br(),
        
        hyd.info.rng(nrow(hyd2)-1,DTb,DTe,stat),
        '</body>'
      ))
    }
  })
})

output$hydgrph <- renderDygraph({
  wflg <- input$chk.flg
  if (!is.null(sta$hyd)){
    if(!wflg){
      qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
      colnames(qxts) <- 'Discharge'
      dygraph(qxts) %>%
        dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
        dyAxis(name='y', label='Discharge (m³/s)') %>%
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
        dyAxis(name='y', label='Discharge (m³/s)') %>%
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