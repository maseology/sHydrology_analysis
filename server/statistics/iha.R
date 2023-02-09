

########################################################
# indicators of hydrologic alteration
########################################################

output$tabIHA.01 <- renderFormattable({
  input$mouseup
  isolate({
    # Group 1: Magnitude of monthly water conditions
    if (!is.null(sta$hyd)){
      withProgress(
        message = 'rendering Group 1: Magnitude of monthly water conditions..', value = 0.5, {
          # merge datasets
          g1 <- group1(getzoo1(), median)
          t1 <- t(apply(g1, 2, mean.cv)) # mean of monthly medians    
          g2 <- group1(getzoo2(), median)
          t2 <- t(apply(g2, 2, mean.cv)) # mean of monthly medians  
          tm <- merge(t1, t2, by=0, all=TRUE) %>%
            rename('Month'='Row.names', 'range 1 mean'='mean.x', 'range 1 CV'='cv.x', 'range 2 mean'='mean.y', 'range 2 CV'='cv.y') %>% 
            mutate_at(vars(-Month), funs(round(., 2)))
          
          # test for differences
          dftest <- data.frame(t(sapply(intersect(colnames(g1),colnames(g2)), function(x) f(g1[,x], g2[,x]))))
          tm <- merge(tm, dftest, by.x='Month', by.y=0 , all=TRUE) %>%
            arrange(factor(Month, levels = c('October','November','December','January','February','March','April','May','June','July','August','September')))
          
          createFormattable(tm)
        }
      )
    }    
  })
})

output$tabIHA.02 <- renderFormattable({
  input$mouseup
  isolate({
    # Group 2: Magnitude and duration of annual extreme weather conditions
    if (!is.null(sta$hyd)){
      withProgress(
        message = 'rendering Group 2: Magnitude and duration of annual extreme weather conditions..', value = 0.5, {
          # merge datasets
          g1 <- group2(getzoo1())[-1]
          t1 <- t(apply(g1, 2, mean.cv))
          g2 <- group2(getzoo2())[-1]
          t2 <- t(apply(g2, 2, mean.cv))
          tm <- merge(t1, t2, by=0, all=TRUE) %>%
            rename('indicator'='Row.names', 'range 1 mean'='mean.x', 'range 1 CV'='cv.x', 'range 2 mean'='mean.y', 'range 2 CV'='cv.y') %>% 
            mutate_at(vars(-indicator), funs(round(., 2)))
          
          # test for differences
          dftest <- data.frame(t(sapply(intersect(colnames(g1),colnames(g2)), function(x) f(g1[,x], g2[,x]))))
          createFormattable(merge(tm, dftest, by.x='indicator', by.y=0 , all=TRUE))
        }
      )
    }  
  })
})

output$tabIHA.03 <- renderFormattable({
  input$mouseup
  isolate({
    # Group 3: Timing of Annual Extream Water conditions
    if (!is.null(sta$hyd)){
      withProgress(
        message = 'rendering Group 3: Timing of Annual Extream Water Conditions..', value = 0.5, {
          # merge datasets
          g1 <- group3(getzoo1())
          t1 <- t(apply(g1, 2, mean.cv))
          g2 <- group3(getzoo2())
          t2 <- t(apply(g2, 2, mean.cv))
          tm <- merge(t1, t2, by=0, all=TRUE) %>%
            rename('indicator'='Row.names', 'range 1 mean'='mean.x', 'range 1 CV'='cv.x', 'range 2 mean'='mean.y', 'range 2 CV'='cv.y') %>% 
            mutate_at(vars(-indicator), funs(round(., 2)))
          
          # test for differences
          dftest <- data.frame(t(sapply(intersect(colnames(g1),colnames(g2)), function(x) f(g1[,x], g2[,x]))))
          createFormattable(merge(tm, dftest, by.x='indicator', by.y=0 , all=TRUE))
        }
      )
    }
  })
})

output$tabIHA.04 <- renderFormattable({
  input$mouseup
  isolate({
    # Group 4: Frequency and Duration of High/Low Pulses
    if (!is.null(sta$hyd)){
      withProgress(
        message = 'rendering Group 4: Frequency and Duration of High/Low Pulses..', value = 0.5, {
          # merge datasets
          g1 <- group4(getzoo1())
          t1 <- t(apply(g1, 2, mean.cv))
          g2 <- group4(getzoo2())
          t2 <- t(apply(g2, 2, mean.cv))
          tm <- merge(t1, t2, by=0, all=TRUE) %>%
            rename('indicator'='Row.names', 'range 1 mean'='mean.x', 'range 1 CV'='cv.x', 'range 2 mean'='mean.y', 'range 2 CV'='cv.y') %>% 
            mutate_at(vars(-indicator), funs(round(., 2)))
          
          # test for differences
          dftest <- data.frame(t(sapply(intersect(colnames(g1),colnames(g2)), function(x) f(g1[,x], g2[,x]))))
          createFormattable(merge(tm, dftest, by.x='indicator', by.y=0 , all=TRUE))
        }
      )
    }
  })
})

output$tabIHA.05 <- renderFormattable({
  input$mouseup
  isolate({
    # Group 5: Rate and frequency of change in conditions
    if (!is.null(sta$hyd)){
      withProgress(
        message = 'rendering Group 5: Rate and frequency of change in conditions..', value = 0.5, {
          # merge datasets
          g1 <- group5(getzoo1())
          t1 <- t(apply(g1, 2, mean.cv))
          g2 <- group5(getzoo2())
          t2 <- t(apply(g2, 2, mean.cv))
          tm <- merge(t1, t2, by=0, all=TRUE) %>%
            rename('indicator'='Row.names', 'range 1 mean'='mean.x', 'range 1 CV'='cv.x', 'range 2 mean'='mean.y', 'range 2 CV'='cv.y') %>% 
            mutate_at(vars(-indicator), funs(round(., 2)))
          
          # test for differences
          dftest <- data.frame(t(sapply(intersect(colnames(g1),colnames(g2)), function(x) f(g1[,x], g2[,x]))))
          createFormattable(merge(tm, dftest, by.x='indicator', by.y=0 , all=TRUE))
        }
      )
    }
  })
})


######################
### functions
######################
f <- function(x,y){
  # https://stackoverflow.com/questions/15865112/r-find-matching-columns-in-two-data-frames-for-t-test-statistics-r-beginner
  mtest <- t.test(x,y) # compare means
  x1 <- c(x[!is.na(x)],y[!is.na(y)])
  y1 <- c(replicate(length(x[!is.na(x)]), 1),replicate(length(y[!is.na(y)]), 2))
  ctest <- asymptotic_test(x1,y1) # compare CVs
  data.frame(pvalm = mtest$p.value,
             pvalc = ctest$p_value)
}

createFormattable <- function(tm) {
  formattable(tm, align =c("l","c","c","c","c", "c", "c"), list(
      `range 1 mean` = formatter("span", style = ~ style(color = ifelse(`pvalm` < 0.05, "red", "black"))),
      `range 2 mean` = formatter("span", style = ~ style(color = ifelse(`pvalm` < 0.05, "red", "black"))),
      `range 1 CV` = formatter("span", style = ~ style(color = ifelse(`pvalc` < 0.05, "red", "black"))),
      `range 2 CV` = formatter("span", style = ~ style(color = ifelse(`pvalc` < 0.05, "red", "black"))),
      `pvalm` = FALSE, `pvalc` = FALSE # hide columns
    )
  )
}

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
output$cumu.iah <- renderPlot({
  if (!is.null(sta$hyd)){
    if (!sta$BFbuilt) separateHydrograph()
    withProgress(
      message = 'rendering cumulative discharge plot..', value = 0.5, {
        flow_summary_cumu(sta$hyd,sta$carea,paste0(sta$label,'\ncumulative discharge'))
      }
    )
  }
})

output$rng.iah1 <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(fillColor='', height=60, dateWindow=c(sta$DTb,median(sta$hyd$Date)))
  }
})
output$rng.iah2 <- renderDygraph({
  if (!is.null(sta$hyd)){
    qxts <- xts(sta$hyd$Flow, order.by = sta$hyd$Date)
    colnames(qxts) <- 'Discharge'
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(fillColor='', height=60, dateWindow=c(median(sta$hyd$Date),sta$DTe))
  }
})


yr.fmt <- function(odt) format(as.Date(odt), format="%Y")

iha.dates <- reactive({
  rng1 <- input$rng.iah1_date_window
  rng2 <- input$rng.iah2_date_window
  if (!is.null(rng1) & !is.null(rng2)) {
    paste0("(",yr.fmt(rng1[1]),"-",yr.fmt(rng1[2])," vs. ",yr.fmt(rng2[1]),"-",yr.fmt(rng2[2]),")")
  }
})

# (1967-1988 vs. 1989-2021)