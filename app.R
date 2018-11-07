##########################################################
##################### sHydrology ######################### 
#### A Shiny-Leaflet interface to the YPDT database.  ####
##########################################################
# Hydrological analysis tools
#
# By M. Marchildon
# v.1.2.1
# Nov, 2018
##########################################################

source("pkg/packages.R", local = TRUE)
sta.id <- "04HA001"


shinyApp(
  ui <- fluidPage(
    useShinyjs(),
    tags$head(includeCSS("pkg/styles.css")),
    tags$head(tags$script(HTML(jscode.mup))),
    inlineCSS(appLoad),
    
    # Loading message
    div(
      id = "loading-content",
      div(class='space300'),
      h2("Loading..."),
      div(img(src='ORMGP_logo_no_text_bw_small.png')), br(),
      shiny::img(src='loading_bar_rev.gif')
    ),

    # The main app
    hidden(
      div(
        id = "app-content",
        list(tags$head(HTML('<link rel="icon", href="favicon.png",type="image/png" />'))),
        div(style="padding: 1px 0px; width: '100%'", titlePanel(title="", windowTitle="sHydrology")),
        navbarPage(
          title=div(img(src="ORMGP_logo_no_text_short.png", height=11), "sHydrology v1.2.1"),
          source(file.path("ui", "hydrograph.R"), local = TRUE)$value,
          source(file.path("ui", "trend_analysis.R"), local = TRUE)$value,
          source(file.path("ui", "stats.R"), local = TRUE)$value,
          # source(file.path("ui", "settings.R"), local = TRUE)$value,
          source(file.path("ui", "data_table.R"), local = TRUE)$value,
          source(file.path("ui", "about.R"), local = TRUE)$value
        )
      )
    )
  ),
  
  server <- function(input, output, session){
    ###################
    ### Parameters & methods:
    source("pkg/app_members.R", local = TRUE)$value
    
    
    ###################
    ### Load station ID:
    if(!is.null(sta.id)) collect_hydrograph(sta.id) # for testing
    # observe({
    #   query <- parseQueryString(session$clientData$url_search)
    #   if (!is.null(query[['sID']])) {
    #     collect_hydrograph(query[['sID']])
    #   } else {
    #     showNotification(paste0("Error: URL invalid."))
    #   }
    # })
    
    
    ### sources:
    source(file.path("server/hydrograph", "discharge.R"), local = TRUE)$value
    source(file.path("server/hydrograph", "separation.R"), local = TRUE)$value
    source(file.path("server/hydrograph", "disaggregation.R"), local = TRUE)$value
    source(file.path("server/trend_analysis", "annual.R"), local = TRUE)$value
    source(file.path("server/trend_analysis", "daily.R"), local = TRUE)$value
    source(file.path("server/trend_analysis", "baseflow.R"), local = TRUE)$value
    source(file.path("server/trend_analysis", "cumu.R"), local = TRUE)$value
    source(file.path("server/statistics", "peak.R"), local = TRUE)$value
    source(file.path("server/statistics", "mam.R"), local = TRUE)$value
    source(file.path("server/statistics", "recession.R"), local = TRUE)$value
    source(file.path("server", "data_table.R"), local = TRUE)$value
    
    session$onSessionEnded(stopApp)
  }
)
