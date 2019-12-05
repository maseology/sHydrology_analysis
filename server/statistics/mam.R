
########################################################
# MAM frequency
########################################################
mam_frequency <- function(hyd, dist='lp3', s = 7, n = 2.5E4, ci = 0.90, title=NULL) {
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  hyd$mam <- rollapply(hyd$Flow, s, mean, fill = NA)
  input_data <- aggregate(mam ~ yr, hyd, min)[,2]
  
  ci <- BootstrapCI(series=input_data, # flow data
                    distribution=dist, # distribution
                    n.resamples = n,   # number of re-samples to conduct
                    ci = ci)           # confidence interval level
  
  # generate frequency plot
  return(frequencyPlot(series=input_data, ci$ci, title, inverted=TRUE))
}


######################
### plots
######################
output$mam.q1 <- renderPlot({
  input$mam.regen
  isolate({
    mdl <- input$mam.freq
    nrsm <- input$mam.rsmpl
    ci <- input$mam.ci
    if (!is.null(sta$hyd)){
      
      withProgress(message = 'rendering plot 1 of 3..', value = 0.1, {mam_frequency(sta$hyd, mdl, 1, nrsm, ci, paste0(sta$label,'\nannual extreme minimum (1-day MAM)'))})
    }
  })
})

output$mam.q7 <- renderPlot({
  input$mam.regen
  isolate({
    mdl <- input$mam.freq
    nrsm <- input$mam.rsmpl
    ci <- input$mam.ci
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering plot 2 of 3..', value = 0.5, {mam_frequency(sta$hyd, mdl, 7, nrsm, ci, paste0(sta$label,'\n7-day MAM'))})
    }
  })
})

output$mam.q30 <- renderPlot({
  input$mam.regen
  isolate({
    mdl <- input$mam.freq
    nrsm <- input$mam.rsmpl
    ci <- input$mam.ci
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering plot 3 of 3..', value = 0.8, {mam_frequency(sta$hyd, mdl, 30, nrsm, ci, paste0(sta$label,'\n30-day MAM'))})
    }
  })
})