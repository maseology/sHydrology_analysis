
hyd.info <- function(title,ndat,DTb,DTe,carea,stat){
  por <- as.integer(difftime(DTe, DTb, units = "days"))+1
  stat <- round(stat,2)
  if(is.null(carea)){
    st.carea <- '<div>Contributing area: unknown</div>'
  }else{
    st.carea <- paste0('<div>Contributing area: ',round(carea,1),' km²</div>')
  }
  paste0(
    "<h4>",title,"</h4>", br(),
    
    '<div>Period of Record: ',strftime(DTb, "%b %Y"),' to ',strftime(DTe, "%b %Y"),' (',por,' days)</div>',
    '<div>total missing: ',por-ndat-1,' days (',round((1-ndat/por)*100,0),'%)</div>', br(),
    st.carea, br(),
    
    '<div>Average discharge: ',stat[1],' m³/s</div>',
    '<div>Median discharge: ',stat[2],' m³/s</div>',
    '<div>95th percentile discharge: ',stat[3],' m³/s</div>',
    '<div>5th percentile discharge: ',stat[4],' m³/s</div>'
  )
}

hyd.info.rng <- function(ndat,DTb,DTe,stat){
  por <- as.integer(difftime(DTe, DTb, units = "days"))+1
  stat <- round(stat,2)
  return(paste0(
    
    '<h4>selected data range:</h4>', br(),
    
    '<div>Period of Record: ',strftime(DTb, "%b %Y"),' to ',strftime(DTe, "%b %Y"),' (',por,' days)</div>',
    '<div>total missing: ',por-ndat-1,' days (',round((1-ndat/por)*100,0),'%)</div>', br(),
    
    '<div>Average discharge: ',stat[1],' m³/s</div>',
    '<div>Median discharge: ',stat[2],' m³/s</div>',
    '<div>95th percentile discharge: ',stat[3],' m³/s</div>',
    '<div>5th percentile discharge: ',stat[4],' m³/s</div>', br()
  ))
}