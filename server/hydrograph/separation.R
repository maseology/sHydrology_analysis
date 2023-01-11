

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
        build_hydrograph(c('Flow','BF.min','BF.max','BF.med'))
      }
    )
  }

})

build_hydrograph <- function(sset){
  qxts <- xts(sta$hyd[,sset], order.by = sta$hyd$Date)
  showNotification('plot rendering, please be patient..', duration = 10)
  if ('BF.med' %in% sset) {
    p <- dygraph(qxts) %>%
      dySeries(c('BF.min','Flow','BF.max'),label='Discharge',strokeWidth=3) %>%
      dySeries('BF.med',label='Median baseflow',strokeWidth=2) %>%
      dyOptions(axisLineWidth = 1.5) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyLegend(width = 500) %>%
      dyRangeSelector(fillColor='', height=80) %>%
      dyOptions(retainDateWindow = TRUE)
  } else {
    p <- dygraph(qxts)  %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
      dySeries(c('BF.min','Flow','BF.max'),label='Discharge',strokeWidth=3) %>%
      dyOptions(axisLineWidth = 1.5) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyLegend(width = 500) %>%
      dyRangeSelector(fillColor='', height=80) %>%
      dyOptions(retainDateWindow = TRUE)
  }

  return(p)
}

select_hydrographs <- function(){
  showNotification('asdfasdf')
  s <- c('Flow','BF.min','BF.max')
  if (input$BF.LH) s <- append(s, 'BF.LH')
  return(s)
}
