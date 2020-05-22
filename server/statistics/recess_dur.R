
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
