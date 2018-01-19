#### annual summary
output$yr.q <- renderPlot({isolate(
  if (!is.null(sta$hyd)){
    flow_summary_annual(sta$hyd,sta$carea,sta$k,sta$label)
  }
)})

output$yr.q.rel <- renderPlot({isolate(
  if (!is.null(sta$hyd)){
    flow_summary_annual(sta$hyd,sta$carea,sta$k,NULL,TRUE)
  }
)})


#### daily summary
output$dy.q <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.mdd_date_window
      flow_summary_daily(sta$hyd,sta$carea,sta$k,sta$label,rng)
    }
  )
})

output$rng.mdd <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label='Discharge (m³/s)') %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})


#### bf summary
output$BF.mnt <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.bf_date_window
      baseflow_boxplot(sta$hyd,sta$carea,sta$k,sta$label,rng)
    }
  )
})

output$rng.bf <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label='Discharge (m³/s)') %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})

output$BFI.mnt <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.bf_date_window
      baseflow_BFI(sta$hyd,sta$carea,sta$k,sta$label,rng)
    }
  )
})


#### cumulative discharge
output$cum.q <- renderPlot({
  input$mouseup
  isolate(
    if (!is.null(sta$hyd)){
      rng <- input$rng.cd_date_window
      flow_summary_cumu(sta$hyd,sta$carea,sta$label,rng)
    }
  )
})

output$rng.cd <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label='Discharge (m³/s)') %>%
      dyRangeSelector(strokeColor = '', height=80)
  }
})