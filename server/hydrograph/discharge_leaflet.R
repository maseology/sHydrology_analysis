

points <- eventReactive(input$recalc, {
  if (!is.null(sta)) cbind(sta$LONG, sta$LAT)
}, ignoreNULL = FALSE)


output$leaflet <- renderLeaflet({
  if (!is.null(sta)) {
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points())    
  }
})
