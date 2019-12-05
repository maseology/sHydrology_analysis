

########################################################
# indicators of hydrologic alteration
########################################################
# UNSELECTED RANGE
output$tabIHA.01 <- renderTable({
  input$mouseup
  isolate({
    # Group 1: Magnitude of monthly water conditions
    if (!is.null(sta$hyd)){
      g1 <- group1(getzoo1(), median)
      t(apply(g1, 2, mean.cv)) # mean of monthly medians    
    }    
  })
},rownames = TRUE)
output$tabIHA.02 <- renderTable({
  input$mouseup
  isolate({
    # Group 2: Magnitude and duration of annual extreme weather conditions
    if (!is.null(sta$hyd)){
      g2 <- group2(getzoo1())
      t(apply(g2[-1], 2, mean.cv))
    }    
  })
},rownames = TRUE)
output$tabIHA.03 <- renderTable({
  input$mouseup
  isolate({
    # Group 3: Timing of Annual Extream Water conditions
    if (!is.null(sta$hyd)){
      g3 <- group3(getzoo1())
      t(apply(g3, 2, mean.cv))
    }    
  })
},rownames = TRUE)
output$tabIHA.04 <- renderTable({
  input$mouseup
  isolate({
    # Group 4: Frequency and Duration of High/Low Pulses
    if (!is.null(sta$hyd)){
      g4 <- group4(getzoo1())
      t(apply(g4, 2, mean.cv))
    }    
  })
},rownames = TRUE)
output$tabIHA.05 <- renderTable({
  input$mouseup
  isolate({
    # Group 5: Rate and frequency of change in conditions
    if (!is.null(sta$hyd)){
      g5 <- group5(getzoo1())
      t(apply(g5, 2, mean.cv))
    }    
  })
},rownames = TRUE)


# SELECTED RANGE
output$tabIHA.11 <- renderTable({
  input$mouseup
  isolate({
    # Group 1: Magnitude of monthly water conditions
    if (!is.null(sta$hyd)){
      g1 <- group1(getzoo2(), median)
      t(apply(g1, 2, mean.cv)) # mean of monthly medians    
    }    
  })
},rownames = TRUE)
output$tabIHA.12 <- renderTable({
  input$mouseup
  isolate({
    # Group 2: Magnitude and duration of annual extreme weather conditions
    if (!is.null(sta$hyd)){
      g2 <- group2(getzoo2())
      t(apply(g2[-1], 2, mean.cv))
    }    
  })
},rownames = TRUE)
output$tabIHA.13 <- renderTable({
  input$mouseup
  isolate({
    # Group 3: Timing of Annual Extream Water conditions
    if (!is.null(sta$hyd)){
      g3 <- group3(getzoo2())
      t(apply(g3, 2, mean.cv))
    }    
  })
},rownames = TRUE)
output$tabIHA.14 <- renderTable({
  input$mouseup
  isolate({
    # Group 4: Frequency and Duration of High/Low Pulses
    if (!is.null(sta$hyd)){
      g4 <- group4(getzoo2())
      t(apply(g4, 2, mean.cv))
    }    
  })
},rownames = TRUE)
output$tabIHA.15 <- renderTable({
  input$mouseup
  isolate({
    # Group 5: Rate and frequency of change in conditions
    if (!is.null(sta$hyd)){
      g5 <- group5(getzoo2())
      t(apply(g5, 2, mean.cv))
    }    
  })
},rownames = TRUE)


######################
### functions
######################
getzoo1 <- function() {
  z <- read.zoo(sta$hyd[,1:2])
  rng <- input$rng.iah1_date_window
  if (!is.null(rng)) {
    z <- window(z,start=as.Date(rng[1]),end=as.Date(rng[2]))
  } else {
    z <- window(z,start=sta$DTb,end=median(sta$hyd$Date))
  }
  return(z)
}
getzoo2 <- function() {
  z <- read.zoo(sta$hyd[,1:2])
  rng <- input$rng.iah2_date_window
  if (!is.null(rng)) {
    z <- window(z,start=as.Date(rng[1]),end=as.Date(rng[2])) 
  } else {
    z <- window(z,start=median(sta$hyd$Date),end=sta$DTe)
  }
  return(z)
}

######################
### plots
######################
output$rng.iah1 <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(strokeColor = '', height=60, dateWindow=c(sta$DTb,median(sta$hyd$Date)))
  }
})
output$rng.iah2 <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(strokeColor = '', height=60, dateWindow=c(median(sta$hyd$Date),sta$DTe))
  }
})