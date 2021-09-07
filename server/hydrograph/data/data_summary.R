
output$selected_var <- renderText({ 
  if (!is.null(sta$hyd)) {
    if (!sta$BFbuilt) separateHydrograph()
    # df <- sta$hyd[sta$hyd$Date >= input$tabRng[1] & sta$hyd$Date <= input$tabRng[2],]
    df <- sta$hyd
    if (ncol(df) > 4) {
      nl <- df %>% summarise_each(funs(mean(., na.rm = TRUE)))
      # print(nl)
      # paste(summarise_each(df, funs(mean)), collapse='\n' )
      paste(sta$name,paste(names(nl),nl,sep="\t",collapse="\n"),sep="\n")
    } else {
      "best to have all computed.."
    }
  }
  #paste("You have selected", input$var)
})