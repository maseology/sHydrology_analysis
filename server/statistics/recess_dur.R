
########################################################
# recession duration analysis
########################################################


######################
### plots
######################
output$rsdr.hist <- renderPlot({
  isolate({
    if (!is.null(sta$hyd)){
      if (is.null(sta$hyd$qtyp)) {
        withProgress(message = 'parsing hydrograph..', value = 0.1, {
          sta$hyd <- parse_hydrograph(sta$hyd,sta$k)
        })
      }

      sta$hyd$grp <- cumsum(c(0,as.numeric(diff(sta$hyd$qtyp))!=0))
      sta$hyd$cnt <- sequence(rle(as.numeric(sta$hyd$qtyp))$lengths)
      
      df <- sta$hyd[sta$hyd$qtyp==3,] %>%
        group_by(grp) %>%
        summarize(dur = max(cnt, na.rm = TRUE))
      
      ggplot(df,aes(dur)) +
        theme_bw() +
        geom_histogram() + 
        labs(x='duration of streamflow recession (days)', title=sta$label)
        # facet_wrap(~(dur > 21), scale = 'free')
    }
  })
})

output$rsdr.time <- renderPlot({
  isolate({
    if (!is.null(sta$hyd)) {
      Q50 <- median(sta$hyd$Flow)
      brks <- quantile(sta$hyd$Flow, c(0.01,0.05,0.25,0.5,0.75,0.95,0.99))
      minor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))
      names(brks) <- rev(names(brks))
      fun.1 <- function(t) Q50/exp(-sta$k*t)
      fun.inv <- function(q) -log(Q50/q)/sta$k
      
      ggplot(data.frame(t = 0),aes(x=t)) + # dummy dataframe
        theme_bw() +
        stat_function(fun = fun.1, size=1) + 
        geom_hline(yintercept=Q50, linetype = "dashed") +
        # geom_vline(xintercept=0, linetype = "dashed") +
        scale_x_reverse(limits = c(fun.inv(max(sta$hyd$Flow)),fun.inv(min(sta$hyd$Flow))), breaks = pretty_breaks(10)) +
        scale_y_continuous(trans='log10', minor_breaks = minor_breaks, 
                           sec.axis = sec_axis(~.*1, breaks = brks, name = 'discharge percent exceedance')) +
        labs(x="days to median discharge",y=gglabcms, title=sta$label)
    }
  })
})