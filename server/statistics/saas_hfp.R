

output$saas.hfp <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    if(is.null(sta$hyd$qtyp)) {
      showNotification("parsing hydrograph..")
      sta$hyd <- parse_hydrograph(sta$hyd,sta$k)
      if(!is.null(sta$carea) && is.null(sta$hyd$evnt)) sta$hyd <- discretize_hydrograph(sta$hyd, sta$carea, sta$k)  
    }

    qbf <- returnQ(sta$hyd, 1.5)
    
    evnts <- sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] %>%  
      dplyr::select(c('Date','Flow','evnt')) %>%
      mutate(new = ifelse(evnt > 0, 1, 0)) %>%
      mutate(new2 = cumsum(new)) %>%
      group_by(new2) %>%
      mutate(pkflw=max(Flow, na.rm = TRUE), dur=n()) %>%
      ungroup() %>%
      filter(new==1, pkflw<qbf)
    
    p1 <- evnts %>%
      mutate(yr=year(Date), mnt=month(Date)) %>%
      group_by(yr,mnt) %>%
      summarise(freq=n()) %>% 
      ungroup() %>%
      dplyr::select(-yr) %>%
      mutate(mnt=month.abb[mnt]) %>%
      mutate(mnt=factor(mnt,levels=month.abb)) %>%
      group_by(mnt) %>%
      summarise(med.f=median(freq, na.rm=TRUE)) %>%
      ggplot(aes(mnt,med.f)) + 
        theme_bw() +
        geom_bar(stat = 'identity') +
        labs(x=NULL, y="median frequency of flow events less than bankfull flow") +
        scale_y_continuous(breaks = integer_breaks())
    
    p2 <- evnts %>%
      mutate(mnt=month(Date)) %>%
      group_by(mnt) %>%
      summarise(med.d=median(dur, na.rm=TRUE)) %>%
      mutate(mnt=month.abb[mnt]) %>%
      mutate(mnt=factor(mnt,levels=month.abb)) %>%
      ggplot(aes(mnt,med.d)) + 
        theme_bw() +
        geom_bar(stat = 'identity') +
        labs(x=NULL, y="median duration (days) of flow events less than bankfull flow") +
        scale_y_continuous(breaks = integer_breaks())
      
    grid.arrange(p1, p2, nrow = 1, top=sta$label)
  }
})