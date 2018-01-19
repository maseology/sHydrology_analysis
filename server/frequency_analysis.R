#### peak flow
output$pk.q <- renderPlot({
  mdl <- input$pk.freq
  nrsm <- input$pk.rsmpl
  ci <- input$pk.ci
  isolate(
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering plot..', value = 0.1, {peak_flow_frequency(sta$hyd, mdl, nrsm, ci, sta$label)})
    }
  )
})

output$pk.dist <- renderPlot({
  isolate(
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering plot..', value = 0.1, {peak_flow_histogram(sta$hyd, sta$label)})
    }
  )
})