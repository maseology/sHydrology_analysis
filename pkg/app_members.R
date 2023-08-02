
##############################################################
### headers
##############################################################

output$hdr0 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})
output$hdr1 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})
output$hdr2 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})
output$hdr3 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})

output$hdr.iha <- renderUI({shiny::HTML(paste0("<h4>",sta$label," ",iha.dates(),"</h4>"))})

output$hdr.qual <- renderUI({shiny::HTML(paste0("<h3>&emsp;",sta$label,"</h3>"))})

output$link.shydrograph <- renderUI({ shiny::HTML(paste0('<a href="https://owrc.shinyapps.io/shydrograph/?t=5&i=',sta$iid,'" target="_blank" rel="noopener noreferrer">open in general timeseries analysis tool</a>'))})


##############################################################
### members
##############################################################

sta <- reactiveValues(lid=NULL, iid=NULL, name=NULL, name2=NULL, 
                      carea=NULL, k=NULL, hyd=NULL,
                      DTb=NULL, DTe=NULL, label=NULL, info.html=NULL, 
                      LONG=NULL, LAT=NULL, 
                      info=NULL, BFbuilt=FALSE, HPbuilt=FALSE)

sta.fdc <- reactiveValues(cmplt=NULL,prtl=NULL)
sta.mnt <- reactiveValues(cmplt=NULL,prtl=NULL)
BFp <- list(LHa=0.925, LHp=3, BFIx=0.8, JHC=0.3) # default baseflow parameters



##############################################################
### other sources
##############################################################
source(file.path("functions", "collect_hydrograph.R"), local = TRUE)$value
source(file.path("functions", "separateHydrograph.R"), local = TRUE)$value
source(file.path("functions", "daterange.R"), local = TRUE)$value
source(file.path("functions", "owrc-api.R"), local = TRUE)$value

