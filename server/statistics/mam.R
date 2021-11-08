
########################################################
# MAM frequency
########################################################
mam_frequency <- function(hyd, dist='lp3', s = 7, n = 2.5E4, ci = 0.90, title=NULL) {
  hyd <- hyd[!(hyd$Flow<=0),]
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  hyd$mam <- rollapply(hyd$Flow, s, mean, fill = NA)
  agg <- aggregate(Flow ~ yr, hyd, max)
  input_data <- agg[,2]
  
  ci <- BootstrapCI(series=input_data, # flow data
                    distribution=dist, # distribution
                    n.resamples = n,   # number of re-samples to conduct
                    ci = ci)           # confidence interval level
  
  # generate frequency plot
  return(frequencyPlot(input_data, agg[,1], ci$ci, title, inverted=TRUE))
}

mam_histogram <- function(hyd, s) {
  hyd$yr <- as.numeric(format(hyd$Date, "%Y"))
  hyd$mam <- rollapply(hyd$Flow, s, mean, fill = NA)
  df <- hyd %>% 
    group_by(yr) %>% 
    summarise(
      Value = min(mam),
      Date = Date[which.min(mam)]) %>% 
    ungroup()
  return(df)
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

output$hist.q1 <- renderPlot({
  isolate({
    if (!is.null(sta$hyd)){
      df <- mam_histogram(sta$hyd,1)
      df$mo <- as.numeric(format(df$Date, "%m"))
      df$mnt <- format(df$Date, "%b")
      df$mnt <- ordered(df$mnt, levels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'))
      
      ggplot(df,aes(mnt)) +
        theme_bw() +
        geom_histogram(stat='count') +
        scale_x_discrete(drop = FALSE) +
        labs(x=NULL, title=paste0(sta$label,'\noccurrence of annual extreme minima'))
    }
  })
})

output$hist.q7 <- renderPlot({
  isolate({
    if (!is.null(sta$hyd)){
      df <- mam_histogram(sta$hyd,7)
      df$mo <- as.numeric(format(df$Date, "%m"))
      df$mnt <- format(df$Date, "%b")
      df$mnt <- ordered(df$mnt, levels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'))
      
      ggplot(df,aes(mnt)) +
        theme_bw() +
        geom_histogram(stat='count') +
        scale_x_discrete(drop = FALSE) +
        labs(x=NULL, title=paste0(sta$label,'\ndistribution of 7-day MAM occurrence'))
    }
  })
})

output$hist.q30 <- renderPlot({
  isolate({
    if (!is.null(sta$hyd)){
      df <- mam_histogram(sta$hyd,30)
      df$mo <- as.numeric(format(df$Date, "%m"))
      df$mnt <- format(df$Date, "%b")
      df$mnt <- ordered(df$mnt, levels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'))
      
      ggplot(df,aes(mnt)) +
        theme_bw() +
        geom_histogram(stat='count') +
        scale_x_discrete(drop = FALSE) +
        labs(x=NULL, title=paste0(sta$label,'\ndistribution of 30-day MAM occurrence'))
    }
  })
})