

########################################################
# baseflow hydrograph
########################################################
output$hydgrph.bf <- renderDygraph({
  if (input$bf.shwall) {
    isolate(
      if (!is.null(sta$hyd)){
        if (!sta$BFbuilt) separateHydrograph()
        build_hydrograph(c('Flow','BF.min','BF.max',
                           'BF.LH','BF.CM','BF.BE','BF.JH','BF.Cl',
                           'BF.UKn','BF.UKm','BF.UKx',
                           'BF.HYSEP.FI','BF.HYSEP.SI','BF.HYSEP.LM',
                           'BF.PART1','BF.PART2','BF.PART3'))
      }
    )
  } else {
    isolate(
      if (!is.null(sta$hyd)){
        if (!sta$BFbuilt) separateHydrograph()
        build_hydrograph(c('Flow','BF.min','BF.max'))
      }
    )
  }

})

build_hydrograph <- function(sset){
  # sset <- c('Flow','BF.min','BF.max')
  qxts <- xts(sta$hyd[,sset], order.by = sta$hyd$Date)
  showNotification('plot rendering, please be patient..', duration = 10)
  p <- dygraph(qxts) %>%
    dySeries(c('BF.min','Flow','BF.max'),label='Discharge',strokeWidth=3) %>%
    dyOptions(axisLineWidth = 1.5) %>%
    dyAxis(name='y', label=dylabcms) %>%
    dyLegend(width = 500) %>%
    dyRangeSelector(height=80)
  
  return(p)
}

select_hydrographs <- function(){
  showNotification('asdfasdf')
  s <- c('Flow','BF.min','BF.max')
  if (input$BF.LH) s <- append(s, 'BF.LH')
  return(s)
}

separateHydrograph <- function(){
  # progress bar
  progress <- shiny::Progress$new()
  progress$set(message = "separating hydrograph..", detail = 'initializing..', value = 0.1)
  on.exit(progress$close())
  updateProgress <- function(value = NULL, detail = NULL) {
    if (is.null(value)) {
      value <- progress$getValue()
      value <- value + (progress$getMax() - value) / 5
    }
    progress$set(value = value, detail = detail)
  }
  
  if (!is.null(sta$hyd) & !sta$BFbuilt){
    sta$hyd <- baseflow_range(sta$hyd,sta$carea,sta$k,BFp,updateProgress)
    sta$BFbuilt <- TRUE
    progress$set(value = 1)
  }
}
