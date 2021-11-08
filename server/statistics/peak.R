
########################################################
# Peakflow frequency
########################################################
peak_flow_frequency <- function(hyd, dist='lp3', n = 2.5E4, ci = 0.90, title=NULL) {
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  agg <- aggregate(Flow ~ yr, hyd, max)
  input_data <- agg[,2]
  
  ci <- BootstrapCI(series=input_data, # flow data
                    distribution=dist, # distribution
                    n.resamples = n,   # number of re-samples to conduct
                    ci = ci)           # confidence interval level
  
  # generate frequency plot
  return(frequencyPlot(input_data, agg[,1], ci$ci, title))
}

peak_flow_density <- function(hyd, title=NULL){
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  df <- data.frame(peak=aggregate(Flow ~ yr, hyd, max)[,2])
  
  p <- ggplot(df,aes(peak)) +
    theme_bw() +
    geom_density(colour='blue', size=1, fill='blue', alpha=0.2) +
    geom_rug() +
    labs(x=expression('Annual maximum daily mean discharge' ~ (m^3/s)), title=NULL)
  
  if(!is.null(title)) p <- p + ggtitle(title)
  
  return(p)
}

peak_flow_histogram <- function(hyd, title=NULL){
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  df <- hyd %>% 
    group_by(yr) %>% 
    summarise(
      Value = max(Flow,na.rm=TRUE),
      Date = Date[which.max(Flow)]) %>% 
    ungroup()
  
  df$mo <- as.numeric(format(df$Date, "%m"))
  df$mnt <- format(df$Date, "%b")
  df$mnt <- ordered(df$mnt, levels = c('Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep'))

  p <- ggplot(df,aes(mnt)) +
    theme_bw() +
    geom_histogram(stat='count') +
    scale_x_discrete(drop = FALSE) +
    labs(x=NULL, title=NULL)

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
      withProgress(message = 'rendering plots..', value = 0.1, {peak_flow_frequency(sta$hyd, mdl, nrsm, ci, paste0(sta$label,'\npeak flow frequency'))})
    }
  })
})

output$pk.dist <- renderPlot({
  isolate(
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering extreme distribution..', value = 0.5, {peak_flow_density(sta$hyd, paste0(sta$label,'\ndistribution of annual extreme values'))})
    }
  )
})

output$pk.hist <- renderPlot({
  isolate(
    if (!is.null(sta$hyd)){
      withProgress(message = 'rendering seasonal distribution..', value = 0.8, {peak_flow_histogram(sta$hyd, paste0(sta$label,'\nseasonal distribution of annual extremes'))})
    }
  )
})