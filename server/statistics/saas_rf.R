
sass.rf.plot <- function(hyd, qp) {
  evnts <- hyd %>%  
    dplyr::select(c('Date','Flow','evnt')) %>%
    mutate(new = ifelse(evnt > 0, 1, 0)) %>%
    mutate(new2 = cumsum(new)) %>%
    group_by(new2) %>%
    mutate(pkflw=max(Flow, na.rm = TRUE), dur=n()) %>%
    ungroup() %>%
    # filter(new==1, (pkflw>=qp*.9 & pkflw<qp*1.1) )
    filter(new==1, (pkflw>=qp) )
  
  p1 <- evnts %>% ggplot(aes(pkflw)) + theme_bw() + geom_density() + xlab("peak flow (m3/s)")
  p2 <- evnts %>% ggplot(aes(dur)) + theme_bw() + geom_density() + xlab("duration (days)")
  p3 <- evnts %>% 
    mutate(mnt=month(Date)) %>% 
    group_by(mnt) %>%
    summarise(nevnt=n()) %>%
    mutate(mnt=month.abb[mnt]) %>%
    mutate(mnt=factor(mnt,levels=month.abb)) %>%
    ggplot(aes(mnt,nevnt)) + theme_bw() + geom_bar(stat='identity') + scale_x_discrete(drop=FALSE) + labs(x="timing (month)",y="count")
  
  grid.arrange(p1, p2, p3, nrow = 1, top=sta$label)  
}


output$saas.rf.2 <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    qp <- returnQ(sta$hyd, 2)
    sass.rf.plot(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],], qp)
  }
})


output$saas.rf.10 <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    qp <- returnQ(sta$hyd, 10)
    sass.rf.plot(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],], qp)
    # evnts <- sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] # %>%  
    #   dplyr::select(c('Date','Flow','evnt')) %>%
    #   mutate(new = ifelse(evnt > 0, 1, 0)) %>%
    #   mutate(new2 = cumsum(new)) %>%
    #   group_by(new2) %>%
    #   mutate(pkflw=max(Flow, na.rm = TRUE), dur=n()) %>%
    #   ungroup() %>%
    #   # filter(new==1, (pkflw>=qp*.9 & pkflw<qp*1.1) )
    #   filter(new==1, (pkflw>=qp) )
    # 
    # p1 <- evnts %>% ggplot(aes(pkflw)) + theme_bw() + geom_density() + xlab("peak flow (m3/s)")
    # p2 <- evnts %>% ggplot(aes(dur)) + theme_bw() + geom_density() + xlab("duration (days)")
    # p3 <- evnts %>% 
    #   mutate(mnt=month(Date)) %>% 
    #   group_by(mnt) %>%
    #   summarise(nevnt=n()) %>%
    #   mutate(mnt=month.abb[mnt]) %>%
    #   mutate(mnt=factor(mnt,levels=month.abb)) %>%
    #   ggplot(aes(mnt,nevnt)) + theme_bw() + geom_bar(stat='identity') + scale_x_discrete(drop=FALSE) + labs(x="timing (month)",y="count")
    # 
    # grid.arrange(p1, p2, p3, nrow = 1, top=sta$label)
  }
})


output$saas.rf.20 <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    qp <- returnQ(sta$hyd, 20)
    sass.rf.plot(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],], qp)
    # evnts <- sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] %>%  
    #   dplyr::select(c('Date','Flow','evnt')) %>%
    #   mutate(new = ifelse(evnt > 0, 1, 0)) %>%
    #   mutate(new2 = cumsum(new)) %>%
    #   group_by(new2) %>%
    #   mutate(pkflw=max(Flow, na.rm = TRUE), dur=n()) %>%
    #   ungroup() %>%
    #   # filter(new==1, (pkflw>=qp*.9 & pkflw<qp*1.1) )
    #   filter(new==1, (pkflw>=qp) )
    # 
    # p1 <- evnts %>% ggplot(aes(pkflw)) + theme_bw() + geom_density() + xlab("peak flow (m3/s)")
    # p2 <- evnts %>% ggplot(aes(dur)) + theme_bw() + geom_density() + xlab("duration (days)")
    # p3 <- evnts %>% 
    #   mutate(mnt=month(Date)) %>% 
    #   group_by(mnt) %>%
    #   summarise(nevnt=n()) %>%
    #   mutate(mnt=month.abb[mnt]) %>%
    #   mutate(mnt=factor(mnt,levels=month.abb)) %>%
    #   ggplot(aes(mnt,nevnt)) + theme_bw() + geom_bar(stat='identity') + scale_x_discrete(drop=FALSE) + labs(x="timing (month)",y="count")
    # 
    # grid.arrange(p1, p2, p3, nrow = 1, top=sta$label)
  }
})