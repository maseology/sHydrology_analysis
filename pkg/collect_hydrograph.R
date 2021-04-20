
##############################################################
### collect data from API
##############################################################
collect_hydrograph <- function(LOC_ID) {
  isolate(withProgress(message = 'collecting station info..', value = 0.1, {
    sta$lid <- LOC_ID
    info <- qStaInfo(ldbc, qStaAgg(sta$lid))
    # print(info)
    if (is.null(info)) showNotification(paste0("Error LOC_ID: ",sta$lid," not found."))
    info.main <- info[info$LID==LOC_ID,] #################  mm: currently LOC_ID picked, should we default to master loc??????
    # info <- info.main # for testing
    sta$info <- info
    sta$carea <- info.main$DA
    if (length(sta$carea)==0 || sta$carea<=0) sta$carea=NULL
    sta$iid <- info.main$IID
    sta$name <- info.main$NAM1
    sta$name2 <- info.main$NAM2
    sta$label <- paste0(sta$name,': ',sta$name2)
    if (nrow(info)>1) {
      showNotification("aggregating co-located stations")
      sta$nam2 <- paste0(sta$nam2,' (AGGREGATED)')
      sta$label <- paste0(sta$label,' (AGGREGATED)')
    }
    setProgress(message = 'querying databases..',value=0.45)
    hyds <- qTemporal(idbc,info$IID)
    setProgress(message = 'rendering plot..',value=0.65)
    sta$hyd <- hyds[[1]]
    sta$intrp <- hyds[[2]]
    if (nrow(sta$hyd)<=0) showNotification(paste0("Error no data found for ",sta$name2))
    sta$DTb <- min(sta$hyd$Date, na.rm=T)
    sta$DTe <- max(sta$hyd$Date, na.rm=T)
    sta$k <- recession_coef(sta$hyd$Flow)
    stat <- c(mean(sta$hyd$Flow),quantile(sta$hyd$Flow,probs=c(0.5,0.95,0.05),na.rm=T))
    sta$info.html <- html.hyd.info(sta$label,nrow(sta$hyd)-1,min(sta$hyd$Date,na.rm=T),max(sta$hyd$Date,na.rm=T),sta$carea,stat)
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
