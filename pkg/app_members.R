
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
                      BFbuilt=FALSE, HPbuilt=FALSE)

sta.fdc <- reactiveValues(cmplt=NULL,prtl=NULL)
sta.mnt <- reactiveValues(cmplt=NULL,prtl=NULL)
BFp <- list(LHa=0.925, LHp=3, BFIx=0.8, JHC=0.3) # default baseflow parameters


##############################################################
### collect data from API
##############################################################
collect_hydrograph <- function(LOC_ID) {
  isolate(withProgress(message = 'collecting station info..', value = 0.1, {
    sta$lid <- LOC_ID
    info <- qStaInfo(ldbc,sta$lid)
    if (is.null(info)) showNotification(paste0("Error LOC_ID: ",sta$lid," not found."))
    sta$carea <- info$DA
    if (length(sta$carea)==0 || sta$carea<=0) sta$carea=NULL
    sta$iid <- info$IID
    sta$name <- info$NAM1
    sta$name2 <- info$NAM2
    sta$label <- paste0(sta$name,': ',sta$name2)
    setProgress(message = 'rendering plot..',value=0.45)
    hyds <- qTemporal(idbc,sta$iid)
    sta$hyd <- hyds[[1]]
    sta$intrp <- hyds[[2]]
    if (nrow(sta$hyd)<=0) showNotification(paste0("Error no data found for ",sta$name2))
    sta$DTb <- min(sta$hyd$Date, na.rm=T)
    sta$DTe <- max(sta$hyd$Date, na.rm=T)
    sta$k <- recession_coef(sta$hyd$Flow)
    stat <- c(mean(sta$hyd$Flow),quantile(sta$hyd$Flow,probs=c(0.5,0.95,0.05),na.rm=T))
    sta$info.html <- hyd.info(sta$label,nrow(sta$hyd)-1,min(sta$hyd$Date,na.rm=T),max(sta$hyd$Date,na.rm=T),sta$carea,stat)
    # updateNumericInput(session,'k.val',value=sta$k)
    setProgress(message = 'computing flow duration and monthly statistics..',value=0.65)
    sta.fdc$cmplt <- flow_duration_curve_build(sta$hyd)
    sta.mnt$cmplt <- flow_monthly_bar_build(sta$hyd,sta$carea)    
  }))
  shinyjs::hide(id = "loading-content", anim = TRUE, animType = "fade")
  shinyjs::show("app-content")
}

collect_hydrograph_csv <- function(fp) {
  isolate({
    sta$lid <- -1
    sta$carea <- 100
    sta$iid <- -1
    sta$name <- 'test'
    sta$name2 <- paste0('from csv: ',fp)
    sta$label <- paste0(sta$name,': ',sta$name2)
    sta$hyd <- qTemporal_csv(fp)
    sta$DTb <- min(sta$hyd$Date, na.rm=T)
    sta$DTe <- max(sta$hyd$Date, na.rm=T)
    sta$k <- recession_coef(sta$hyd$Flow)
    stat <- c(mean(sta$hyd$Flow),quantile(sta$hyd$Flow,probs=c(0.5,0.95,0.05),na.rm=T))
    sta$info.html <- hyd.info(sta$label,nrow(sta$hyd)-1,min(sta$hyd$Date,na.rm=T),max(sta$hyd$Date,na.rm=T),sta$carea,stat)
    sta.fdc$cmplt <- flow_duration_curve_build(sta$hyd)
    sta.mnt$cmplt <- flow_monthly_bar_build(sta$hyd,sta$carea)
  })
}


#################
### functions ###
#################
separateHydrograph <- function(){
  # progress bar
  progress <- shiny::Progress$new()
  progress$set(message = "separating hydrograph..", detail = 'initializing..', value = 0.1)
  on.exit(progress$close())
  updateProgress <- function(value = NULL, detail = NULL) {
    if (is.null(value)) {
      value <- progress$getValue()
      value <- value + (progress$getMax() - value) / 5
    }
    progress$set(value = value, detail = detail)
  }
  
  if (!is.null(sta$hyd) & !sta$BFbuilt){
    sta$hyd <- baseflow_range(sta$hyd,sta$carea,sta$k,BFp,updateProgress)
    sta$BFbuilt <- TRUE
    progress$set(value = 1)
  }
}