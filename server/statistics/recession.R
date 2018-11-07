
######################
### plots
######################
observe({
  updateNumericInput(session,'k.val',value=sta$k)
})

observeEvent(input$k.reset,isolate({
  sta$k <- recession_coef(sta$hyd$Flow)
  updateNumericInput(session,'k.val',value=sta$k)
}))

output$k.coef <- renderPlot({
  input$k.update
  isolate({
    if(!is.na(input$k.val)) sta$k <- input$k.val
    recession_coef_plot(sta$hyd$Flow, sta$k, sta$label)
  })
})