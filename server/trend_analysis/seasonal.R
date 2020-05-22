

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
      ggtitle(paste0(sta$label,'\nmean discharge by season')) + 
      ylab(ylab) + xlab('water year (oct-sept)')
  }
})