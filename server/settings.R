#### recession coefficient
observeEvent(input$k.auto, {isolate(
  updateNumericInput(session,'k.val',value=recession_coef(sta$hyd$Flow))
)})
output$k.coef <- renderPlot({
  input$k.set
  isolate(
    if (!is.null(sta$hyd)){
      if(!is.na(input$k.val)) sta$k <- input$k.val
      recession_coef_plot(sta$hyd$Flow, sta$k, sta$label)
    }
  )
})