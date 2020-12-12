
########################################################
# hydrograph info
########################################################
html.hyd.info <- function(title,ndat,DTb,DTe,carea,stat){
  por <- as.integer(difftime(DTe, DTb, units = "days"))+1
  stat <- round(stat,2)
  if(is.null(carea)){
    st.carea <- '<div>Contributing area: unknown</div>'
  }else{
    st.carea <- paste0('<div>Contributing area: ',round(carea,1),' km<sup>2</sup></div>')
  }
  
  paste0(
    "<h4>",title,"</h4>", br(),
    st.carea, br(),
    '<div>Period of Record: ',strftime(DTb, "%b %Y"),' to ',strftime(DTe, "%b %Y"),' (',por,' days)</div>',
    '<div>total missing: ',por-ndat-1,' days (',round((1-ndat/por)*100,0),'%)</div>', br(),
    
    '<div>Average discharge: ',stat[1],' m<sup>3</sup>/s</div>',
    '<div>Median discharge: ',stat[2],' m<sup>3</sup>/s</div>',
    '<div>95th percentile discharge: ',stat[3],' m<sup>3</sup>/s</div>',
    '<div>5th percentile discharge: ',stat[4],' m<sup>3</sup>/s</div>'
  )
}

hyd.info.rng <- function(ndat,DTb,DTe,stat){
  por <- as.integer(difftime(DTe, DTb, units = "days"))+1
  stat <- round(stat,2)
  return(paste0(
    
    '<h4>selected data range:</h4>', br(),
    
    '<div>Period of Record: ',strftime(DTb, "%b %Y"),' to ',strftime(DTe, "%b %Y"),' (',por,' days)</div>',
    '<div>total missing: ',por-ndat-1,' days (',round((1-ndat/por)*100,0),'%)</div>', br(),
    
    '<div>Average discharge: ',stat[1],' m<sup>3</sup>/s</div>',
    '<div>Median discharge: ',stat[2],' m<sup>3</sup>/s</div>',
    '<div>95th percentile discharge: ',stat[3],' m<sup>3</sup>/s</div>',
    '<div>5th percentile discharge: ',stat[4],' m<sup>3</sup>/s</div>', br()
  ))
}