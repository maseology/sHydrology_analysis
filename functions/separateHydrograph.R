
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
    qBF <- baseflow_range(sta$hyd,sta$carea,sta$k,BFp,updateProgress) %>% subset(select=-c(Flow,Flag))
    sta$hyd <- merge(sta$hyd, qBF, 'Date')
    sta$BFbuilt <- TRUE
    progress$set(value = 1)
  }
}