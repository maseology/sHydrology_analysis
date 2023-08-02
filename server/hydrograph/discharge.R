
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