
output$gghydgrph <- renderPlot({
  wflg <- input$chk.flg
  if (!is.null(sta$hyd)){
    df <- dRange()
    if(!wflg){
      ggplot(df,aes(x=Date)) +
        theme_bw() + theme(panel.grid.major = element_line(colour = "#808080"), panel.grid.minor = element_line(colour = "#808080")) +
        geom_line(aes(y=Flow), color="blue") + 
        xlab(gglabcms)
    } else {
      ggplot(df,aes(x=Date,y=Flow,color=factor(Flag))) +
        theme_bw() + theme(panel.grid.major = element_line(colour = "#808080"), panel.grid.minor = element_line(colour = "#808080"), 
                           axis.title.x = element_blank()) +
        theme(legend.position=c(0.97,0.97), legend.justification=c(1,1), legend.title=element_blank()) +
        geom_line(aes(group=1),size=1) +
        scale_color_manual(name="",
                      values = c("blue", "ice_conditions"="#ffa552", "estimate"="#008000", "partial"="lightblue", "realtime_uncorrected"="#6635b5"),
                      labels = c("Flow","Ice conditions","Estimate","Partial","Uncorrected")) + 
        ylab(gglabcms) + ggtitle(sta$label)
    }
  }
})
