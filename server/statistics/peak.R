
########################################################
# Peakflow frequency
########################################################
peak_flow_frequency <- function(hyd, dist='lp3', n = 2.5E4, ci = 0.90, title=NULL) {
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  input_data <- aggregate(Flow ~ yr, hyd, max)[,2]
  
  ci <- BootstrapCI(series=input_data, # flow data
                    distribution=dist, # distribution
                    n.resamples = n,   # number of re-samples to conduct
                    ci = ci)           # confidence interval level
  
  # generate frequency plot
  return(frequencyPlot(series=input_data, ci$ci, title))
}

peak_flow_histogram <- function(hyd, title=NULL){
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  df <- data.frame(peak=aggregate(Flow ~ yr, hyd, max)[,2])
  
  p <- ggplot(df,aes(peak)) +
    theme_bw() +
    geom_density(colour='blue', size=1, fill='blue', alpha=0.2) +
    labs(x=expression('Annual maximum daily discharge' ~ (m^3/s)), title=NULL)
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}


######################
### plots
######################
output$pk.q <- renderPlot({
  input$pk.regen
  isolate({
    mdl <- input$pk.freq
    nrsm <- input$pk.rsmpl
    ci <- input$pk.ci
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering plots..', value = 0.1, {peak_flow_frequency(sta$hyd, mdl, nrsm, ci, 'Peak flow frequency')})
    }
  })
})

output$pk.dist <- renderPlot({
  isolate(
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering distribution..', value = 0.8, {peak_flow_histogram(sta$hyd, 'Peak flow distribution')})
    }
  )
})