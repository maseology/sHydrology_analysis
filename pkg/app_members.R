
##############################################################
### headers
##############################################################

output$hdr0 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})
output$hdr1 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})
output$hdr2 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})
output$hdr3 <- renderUI({shiny::HTML(paste0("<h2>&emsp;",sta$label,"</h2>"))})

output$hdr.qual <- renderUI({shiny::HTML(paste0("<h3>&emsp;",sta$label,"</h3>"))})


##############################################################
### members
##############################################################

sta <- reactiveValues(lid=NULL, iid=NULL, name=NULL, name2=NULL, 
                      carea=NULL, k=NULL, hyd=NULL, intrp=NULL,
                      DTb=NULL, DTe=NULL, label=NULL, info.html=NULL, 
                      info=NULL, BFbuilt=FALSE, HPbuilt=FALSE)

sta.fdc <- reactiveValues(cmplt=NULL,prtl=NULL)
sta.mnt <- reactiveValues(cmplt=NULL,prtl=NULL)
BFp <- list(LHa=0.925, LHp=3, BFIx=0.8, JHC=0.3) # default baseflow parameters



##############################################################
### other sources
##############################################################
source(file.path("pkg", "collect_hydrograph.R"), local = TRUE)$value
source(file.path("functions", "separateHydrograph.R"), local = TRUE)$value
source(file.path("functions", "daterange.R"), local = TRUE)$value

