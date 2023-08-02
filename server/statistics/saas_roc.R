

output$saas.roc <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    
    sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] %>%  
      dplyr::select(c('Date','Flow','evnt')) %>%
      mutate(new = ifelse(evnt > 0, 1, 0)) %>%
      mutate(evntid = cumsum(new)) %>%
      group_by(evntid) %>%
      mutate(pkflw=max(Flow, na.rm = TRUE), dur=n()) %>%
      mutate(new3 = case_when(Flow == pkflw ~ Date)) %>%
      mutate(peakDate = max(new3, na.rm = TRUE)) %>%
      mutate(daysToPeak = as.integer(peakDate-Date)) %>%
      mutate(new6 = min(daysToPeak)) %>%
      mutate(new7 = case_when(new6 == daysToPeak ~ Flow)) %>%
      mutate(lastFlow = max(new7, na.rm = TRUE)) %>%
      ungroup() %>%
      filter(new==1) %>%
      dplyr::select(-c('new','new3','new6','new7')) %>%
      mutate(rise=(pkflw-Flow)/daysToPeak/24, fall=(pkflw-lastFlow)/(dur-daysToPeak)/24) %>%
      mutate(mnt=month(Date)) %>%
      group_by(mnt) %>%
      summarise(rising=median(rise, na.rm=TRUE),falling=median(fall, na.rm=TRUE)) %>%
      mutate(mnt=month.abb[mnt]) %>%
      mutate(mnt=factor(mnt,levels=month.abb)) %>%
      gather(key = "Limb", value = "val", -mnt) %>%
      ggplot(aes(mnt,val)) + 
        theme_bw() + 
        geom_bar(aes(fill=Limb), stat='identity', position = "dodge") + 
        scale_x_discrete(drop=FALSE) +  
        labs(title=sta$label,x=NULL,y="median rate-of-change of flow (m3 sec-1 hr-1)")
    
  }
})