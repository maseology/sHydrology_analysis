


######################
### PLOTS
######################

output$rng.saas <- renderDygraph({
  if (!is.null(sta$hyd)){
    if (!sta$BFbuilt) separateHydrograph()
    qxts <- xts(sta$hyd[, c('Flow','BF.med')], order.by = sta$hyd$Date)
    colnames(qxts) <- c('Discharge',"Baseflow")
    dygraph(qxts) %>%
      dyOptions(axisLineWidth = 1.5, fillGraph = TRUE, stepPlot = TRUE) %>%
      dyAxis(name='y', label=dylabcms) %>%
      dyRangeSelector(fillColor='', height=60)
  }
})

saas.stat <- function(hyd) {
  hyd %>%
    mutate(Month=month(Date)) %>%
    group_by(Month) %>%
    dplyr::summarise(mean = mean(Flow,na.rm=TRUE),
                     st.Dev = sd(Flow,na.rm=TRUE),
                     p5 = quantile(Flow,.05,na.rm=TRUE),
                     p125 = quantile(Flow,.125,na.rm=TRUE),
                     p375 = quantile(Flow,.375,na.rm=TRUE),
                     median = median(Flow,na.rm=TRUE),
                     p625 = quantile(Flow,.625,na.rm=TRUE),
                     p875 = quantile(Flow,.875,na.rm=TRUE),
                     p95 = quantile(Flow,.95,na.rm=TRUE),
                     n = sum(!is.na(Flow)),
                     .groups = "keep") %>%     
    ungroup() %>%
    mutate(Month=month.abb[Month])
}
saas.stat.bf <- function(hyd) {
  hyd %>%
    mutate(Month=month(Date)) %>%
    group_by(Month) %>%
    dplyr::summarise(mean = mean(BF.med,na.rm=TRUE),
                     st.Dev = sd(BF.med,na.rm=TRUE),
                     p5 = quantile(BF.med,.05,na.rm=TRUE),
                     p125 = quantile(BF.med,.125,na.rm=TRUE),
                     p375 = quantile(BF.med,.375,na.rm=TRUE),
                     median = median(BF.med,na.rm=TRUE),
                     p625 = quantile(BF.med,.625,na.rm=TRUE),
                     p875 = quantile(BF.med,.875,na.rm=TRUE),
                     p95 = quantile(BF.med,.95,na.rm=TRUE),
                     n = sum(!is.na(BF.med)),
                     .groups = "keep") %>%     
    ungroup() %>%
    mutate(Month=month.abb[Month])
}

output$saas.mmbf <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    # sta$hyd %>%
    sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],] %>%
      mutate(mnt=month(Date)) %>%
      mutate(mnt=month.abb[mnt]) %>%
      ggplot() +
        theme_bw() +
        geom_boxplot(aes(x = reorder(mnt, montho(Date)), y = BF.med), size = 1) + #, outlier.shape = NA)
        labs(title = sta$label, y="Monthly median baseflow magnitude (m³/s)")
  }
})

output$saas.mmbf2 <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    saas.stat.bf(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],]) %>%
      mutate(Month=factor(Month,levels=montha)) %>%
      # fct_reorder(Month, montha) %>%
      ggplot(aes(x=Month, group = 1)) +
      theme_bw() +
      theme(legend.position = c(.05,.95),
            legend.justification = c(0,1)) +
      geom_line(aes(y=p875, linetype='87.5%')) +
      geom_line(aes(y=p625, linetype='62.5%')) + #, linetype='dashed') +
      geom_line(aes(y=median, linetype='50%'), linewidth=1) +
      geom_line(aes(y=p375, linetype='37.5%')) + #, linetype='dashed') +
      geom_line(aes(y=p125, linetype='12.5%')) +
      scale_linetype_manual(name= "exceedance", values = c('solid','dashed','solid','dashed','solid')) +
      labs(title = sta$label, y="Monthly exceedances of baseflow (m³/s)", x="Month")
  }
})

output$saas.m95q <- renderPlot({
  req(rng <- input$rng.saas_date_window)
  if (!is.null(sta$hyd)){
    saas.stat(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],]) %>%
      mutate(Month=factor(Month,levels=montha)) %>%
      # fct_reorder(Month, montha) %>%
      ggplot(aes(x=Month, group = 1)) +
      theme_bw() +
      theme(legend.position = c(.05,.95),
            legend.justification = c(0,1)) +
      geom_line(aes(y=p875, linetype='87.5%')) +
      geom_line(aes(y=p625, linetype='62.5%')) + #, linetype='dashed') +
      geom_line(aes(y=median, linetype='50%'), linewidth=1) +
      geom_line(aes(y=p375, linetype='37.5%')) + #, linetype='dashed') +
      geom_line(aes(y=p125, linetype='12.5%')) +
      scale_linetype_manual(name= "exceedance", values = c('solid','dashed','solid','dashed','solid')) +
      labs(title = sta$label, y="Monthly exceedances of total streamflow magnitude (m³/s)")
  }
})


######################
### TABLES
######################
output$tabSAAS.mmbf <- renderFormattable({
  req(rng <- input$rng.saas_date_window)
  saas.stat.bf(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],]) %>% formattable()
  # saas.stat.bf(sta$hyd) %>% formattable()
})

output$tabSAAS.m95q <- renderFormattable({
  req(rng <- input$rng.saas_date_window)
  saas.stat(sta$hyd[sta$hyd$Date >= rng[1] & sta$hyd$Date <= rng[2],]) %>% formattable()
  # saas.stat(sta$hyd) %>% formattable()
})

