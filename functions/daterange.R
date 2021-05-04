

# from https://stackoverflow.com/questions/49215000/synchronise-dygraph-and-daterangeinput-in-shiny
ntrig <- 10 # Note that I added a reset of the counters when above 10. This is too avoid the trigger value to be to high for R. When the counter resets, you may notice a small outburst, depending on the speed your users change the slider. You can increase this value to make it appear less often.

r <- reactiveValues(
  change_datewindow = 0,
  change_rngselect = 0,
  change_datewindow_auto = 0,
  change_rngselect_auto = 0,
  rngselect = NULL #c(loc$DTb, loc$DTe)
)

updated_date_window <- function(date_window,inputId) {
  r$change_datewindow <- r$change_datewindow + 1
  if (r$change_datewindow > r$change_datewindow_auto) {
    r$change_rngselect_auto <- r$change_rngselect_auto + 1
    r$change_datewindow_auto <- r$change_datewindow
    
    start <- as.Date(ymd_hms(date_window[[1]]))
    stop  <- as.Date(ymd_hms(date_window[[2]]))
    updateDateRangeInput(session = session,
                         inputId = inputId,
                         start = start,end = stop
    )
  } else {
    if (r$change_datewindow >= ntrig) {
      r$change_datewindow_auto <- r$change_datewindow <- 0
    }
  }
}

updated_date_selector <- function(rng) {
  r$change_rngselect <- r$change_rngselect + 1
  if (r$change_rngselect > r$change_rngselect_auto) {
    r$change_datewindow_auto <- r$change_datewindow_auto + 1
    r$change_rngselect_auto <- r$change_rngselect
    r$rngselect <- rng
  } else {
    if (r$change_rngselect >= ntrig) {
      r$change_rngselect_auto <- r$change_rngselect <- 0
    }
  }    
}


###################################

# # Sample
# observe(updateDateRangeInput(session, "DATERANGE", start = loc$DTb, end = loc$DTe, min = loc$DTb, max = loc$DTe))
# 
# observeEvent(input$DYGRAPH_date_window, {
#   updated_date_window(input$DYGRAPH_date_window,"DATERANGE")
# })
# 
# observeEvent(input$DATERANGE, {
#   updated_date_selector(input$DATERANGE)
# })

