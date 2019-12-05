#### data table
output$tabhyd <- renderDataTable({
    if (!is.null(sta$hyd)){
      df <- sta$hyd[sta$hyd$Date >= input$tabRng[1] & sta$hyd$Date <= input$tabRng[2],]
      if (!is.null(df$qtyp)){
        df$qtyp <- as.character(df$qtyp)
        df$qtyp[df$qtyp=="1"] <- "Rising Limb"
        df$qtyp[df$qtyp=="2"] <- "Falling Limb"
        df$qtyp[df$qtyp=="3"] <- "Flow Recession"
      }
      df
    }
  }, 
  options = list(scrollY='100%', scrollX=TRUE,
            lengthMenu = c(30, 100, 365, 3652),
            pageLength = 100,
            searching=FALSE)
)

observe(updateDateRangeInput(session, "tabRng", start = sta$DTb, end = sta$DTe, min = sta$DTb, max = sta$DTe))

observe({
  if (input$tabCmplt == 0) return()
  isolate({
    if (!sta$BFbuilt) separateHydrograph()
    if (is.null(sta$hyd$qtyp)) {
      sta$hyd <- parse_hydrograph(sta$hyd,sta$k)
      if(!is.null(sta$carea) && is.null(sta$hyd$evnt)) sta$hyd <- discretize_hydrograph(sta$hyd,sta$carea,sta$k)
    }
  })
})

output$tabCsv <- downloadHandler(
  filename <- function() { paste0(sta$name, '.csv') },
  content <- function(file) {
    if (!is.null(sta$hyd)){
      dat.out <- sta$hyd[sta$hyd$Date >= input$tabRng[1] & sta$hyd$Date <= input$tabRng[2],]
      write.csv(dat.out[!is.na(dat.out$Flow),], file, row.names = FALSE)
    }
  }
)
