
output$hdr21 <- renderUI({shiny::HTML(paste0("<h2>",sta$label,"</h2>"))})
output$hdr22 <- renderUI({shiny::HTML(paste0("<h2>",sta$label,"</h2>"))})


#### baseflow hydrograph
output$hydgrph.bf <- renderDygraph({isolate(
  if (!is.null(sta$hyd)){
    if (!sta$BFbuilt) separateHydrograph()
    Baseflow_hydrograph()
  }
)})

Baseflow_hydrograph <- function(){
  qxts <- xts(sta$hyd[,c('Flow','BF.min','BF.max',
                     'BF.LH','BF.CM','BF.BE','BF.JH','BF.Cl',
                     'BF.UKn','BF.UKm','BF.UKx',
                     'BF.HYSEP.FI','BF.HYSEP.SI','BF.HYSEP.LM',
                     'BF.PART1','BF.PART2','BF.PART3')], order.by = sta$hyd$Date)
  p <- dygraph(qxts) %>%
    dySeries(c('BF.min','Flow','BF.max'),label='Discharge',strokeWidth=3) %>%
    dyOptions(axisLineWidth = 1.5) %>%
    dyAxis(name='y', label='Discharge (m³/s)') %>%
    dyLegend(width = 500) %>%
    dyRangeSelector(height=80)
  
  return(p)
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


###########################################################
#### hydro-parse
output$hydgrph.prse <- renderDygraph({isolate(
  if (!is.null(sta$hyd)){
    inclEV <- TRUE
    withProgress(message = 'parsing hydrograph..', value = 0.1, {
      if(is.null(sta$hyd$qtyp)) sta$hyd <- parse_hydrograph(sta$hyd,sta$k)
      if(!is.null(sta$carea) && is.null(sta$hyd$evnt)){sta$hyd <- discretize_hydrograph(sta$hyd,sta$carea,sta$k)}else{inclEV <- FALSE}
    })
    withProgress(message = 'rendering plot..', value = 0.1, {
      flow_hydrograph_parsed(sta$hyd,inclEV)
    })
  }
)})