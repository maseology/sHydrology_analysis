

########################################################
# Flow disaggregation
########################################################
flow_hydrograph_parsed <- function(hyd,InclEV=TRUE){

  # Timeseries prep
  h1 <- data.frame(Date = hyd$Date,q = hyd$Flow,qtyp = hyd$qtyp)
  h1$qtyp <- rollapply(h1$qtyp, width=list(-1:1), function(x) if(x[1]==1 || x[2]==1){1}, fill=NA)
  h1$q[is.na(h1$qtyp)] <- NA
  h2 <- data.frame(Date = hyd$Date,q = hyd$Flow,qtyp = hyd$qtyp)
  h2$qtyp <- rollapply(h2$qtyp, width=list(-1:1), function(x) if(x[1]==2 || x[2]==2){2}, fill=NA)
  h2$q[is.na(h2$qtyp)] <- NA
  h3 <- data.frame(Date = hyd$Date,q = hyd$Flow,qtyp = hyd$qtyp)
  h3$qtyp <- rollapply(h3$qtyp, width=list(-1:1), function(x) if(x[1]==3 || x[2]==3){3}, fill=NA)
  h3$q[is.na(h3$qtyp)] <- NA
  x1 <- xts(h1$q, order.by = hyd$Date)
  x2 <- xts(h2$q, order.by = hyd$Date)
  x3 <- xts(h3$q, order.by = hyd$Date)
  
  if(InclEV){
    xe <- xts(hyd$evnt, order.by = hyd$Date)
    qx <- cbind(x2,x3,x1,xe)
    colnames(qx) <- c('falling limb','recession','rising limb','event yield')
    p <- dygraph(qx) %>%
      dySeries("recession", color = "green", strokeWidth=2) %>% #, fillGraph = TRUE) %>%
      dySeries("falling limb", color = "blue", strokeWidth=2) %>% #, fillGraph = TRUE) %>%
      dySeries("rising limb", color = "red", strokeWidth=2) %>% #, fillGraph = TRUE) %>%
      dyBarSeries("event yield", color = "#0153c5", axis = 'y2') %>% ### BUG: these don't seem to appear as of 191126 (see https://github.com/rstudio/dygraphs/issues/237)
      # dySeries("event yield", color = "brown", axis = 'y2', stepPlot = TRUE) %>% #, fillGraph = TRUE) %>%
      dyAxis('y', label=dylabcms) %>%
      dyAxis('y2', label='Event yield (mm)', valueRange = c(max(hyd$evnt,na.rm=T), 0)) %>%
      dyLegend(show = 'always') %>%  
      dyOptions(axisLineWidth = 1.5, fillAlpha = 0.5, stepPlot = FALSE) %>%
      dyLegend(width = 500) %>%
      dyRangeSelector(fillColor='', height=80) %>%
      dyOptions(retainDateWindow = TRUE)
  }else{
    qx <- cbind(x2,x3,x1)
    colnames(qx) <- c('falling limb','recession','rising limb')
    p <- dygraph(qx) %>%
      dySeries("recession", color = "green",strokeWidth=2, fillGraph = TRUE) %>%
      dySeries("falling limb", color = "blue",strokeWidth=2, fillGraph = TRUE) %>%
      dySeries("rising limb", color = "red",strokeWidth=2, fillGraph = TRUE) %>%
      dyAxis('y', label=dylabcms) %>%
      dyLegend(show = 'always') %>%  
      dyOptions(axisLineWidth = 1.5, fillAlpha = 0.5, stepPlot = FALSE) %>%
      dyLegend(width = 500) %>%
      dyRangeSelector(fillColor='', height=80) %>%
      dyOptions(retainDateWindow = TRUE)
  }
  
  return(p)
}

# flow_hydrograph_parsed2 <- function(hyd,carea,k,InclEV=TRUE){
#   if(is.null(carea)) InclEV=FALSE
#   hyd <- parse_hydrograph(hyd,k)
#   if(InclEV) hyd <- discretize_hydrograph(hyd,carea,k)
#   return(flow_hydrograph_parsed(hyd,InclEV))
# }