
output$hydgrph.prse <- renderDygraph({isolate(
  if (!is.null(sta$hyd)){
    inclEV <- TRUE
    withProgress(message = 'parsing hydrograph..', value = 0.1, {
      if(is.null(sta$hyd$qtyp)) sta$hyd <- parse_hydrograph(sta$hyd,sta$k)
      if(!is.null(sta$carea) && is.null(sta$hyd$evnt)){sta$hyd <- discretize_hydrograph(sta$hyd, sta$carea, sta$k)}else{inclEV <- FALSE}
    })
    withProgress(message = 'rendering plot..', value = 0.1, {
      flow_hydrograph_parsed(sta$hyd,inclEV)
    })
  }
)})