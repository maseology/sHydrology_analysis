

########################################################
# seasonal flow summary
########################################################

output$se.q <- renderPlot({
  if (!is.null(sta$hyd)){

    # summarize by month
    df <- sta$hyd
    df$month <- as.numeric(format(df$Date, "%m"))

    df$wy = wtr_yr(df$Date)
    df$se <- NA
    df[df$month<3 | df$month>11,]$se = 'DJF'
    df[df$month<6 & df$month>2,]$se = 'MAM'
    df[df$month<9 & df$month>5,]$se = 'JJA'
    df[df$month<12 & df$month>8,]$se = 'SON'
    df$se_f <- factor(df$se,levels=c('DJF','MAM','JJA','SON'))
    
    df <- df %>% group_by(wy,se_f)
    if(is.null(sta$carea)){
      df <- df %>% dplyr::summarise(stat = mean(Flow, na.rm = TRUE), n = sum(!is.na(Flow)))
      ylab <- expression('Mean seasonal discharge ' ~ (m^3/s))
    } else {
      df <- df %>% dplyr::summarise(stat = sum(Flow, na.rm = TRUE)*86.4/sta$carea, n = sum(!is.na(Flow)))
      ylab <- 'Total discharge (mm)'
    }
      
    if (nrow(df[df$n==0,])>0) df[df$n==0,]$stat <- NA
    
    ggplot(df, aes(wy,stat)) + 
      theme_bw() +
      geom_step(na.rm = TRUE) + 
      geom_smooth(na.rm=TRUE) +
      facet_grid(rows = vars(se_f)) + #, scales = "free") +
      ggtitle(paste0(sta$label,'\nmean annual discharge by season')) + 
      ylab(ylab) + xlab('water year (oct-sept)')
  }
})



output$rng.se <- renderDygraph({
  if (!is.null(sta$hyd)){
    jhyd <- sta$hyd %>%
      dplyr::select(Date,Flow) %>%
      mutate(year=year(Date), julian=yday(Date)) %>% 
      dplyr::select(-Date) %>%
      spread(year,Flow) %>%
      mutate(julian=as.POSIXct(as.Date(julian-1, origin = as.Date("2001-01-01"))))
    
    don=xts( x=jhyd[,-1], order.by=jhyd$julian)
    p<-dygraph(don) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
      dyAxis("x",
             axisLabelFormatter=JS('function(d){
                                   var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                   return monthNames[d.getMonth()];
                                   }'),
             valueFormatter = 'function(ms) { return moment(ms).format("DD MMM"); }') 
      # %>% dyLegend(show = "never")

    # nice effect here, but screws with everything else
    p$x$css = "
    .dygraph-legend > span {display:none;}
    .dygraph-legend > span.highlight { display: inline; }
    "
    return(p)
  }
})


output$tab.se <- renderFormattable({
  req(rng <- input$rng.se_date_window)
  if (!is.null(sta$hyd)){
    jb <- yday(rng[1])
    je <- yday(rng[2])
    if ( je==1 ) je <- 365

    sta$hyd %>%
      mutate(julian=yday(Date)) %>%
      filter(julian>=jb & julian<=je ) %>%
      dplyr::summarise(mean = mean(Flow,na.rm=TRUE),
                       st.Dev = sd(Flow,na.rm=TRUE),
                       p5 = quantile(Flow,.05,na.rm=TRUE),
                       median = median(Flow,na.rm=TRUE),
                       p95 = quantile(Flow,.95,na.rm=TRUE),
                       n = sum(!is.na(Flow)),
                       .groups = "keep") %>%
      formattable()
  }
})

