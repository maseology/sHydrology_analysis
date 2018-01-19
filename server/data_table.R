#### data table
output$tabhyd <- renderDataTable({
    if (!is.null(sta$hyd)) sta$hyd[sta$hyd$Date >= input$tabRng[1] & sta$hyd$Date <= input$tabRng[2],]
  }, 
  options = list(scrollY='100%', scrollX=TRUE,
            lengthMenu = c(30, 100, 365, 3652),
            pageLength = 100,
            searching=FALSE)
)

observe(updateDateRangeInput(session, "tabRng", start = sta$DTb, end = sta$DTe, min = sta$DTb, max = sta$DTe))

output$tabCsv <- downloadHandler(
  filename <- function() { paste0(sta$name, '.csv') },
  content <- function(file) {
    if (!is.null(sta$hyd)){
      dat.out <- sta$hyd[sta$hyd$Date >= input$tabRng[1] & sta$hyd$Date <= input$tabRng[2],]
      write.csv(dat.out[!is.na(dat.out$Flow),], file, row.names = FALSE)
    }
  }
)