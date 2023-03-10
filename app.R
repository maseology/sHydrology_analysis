##########################################################
##################### sHydrology ######################### 
#### A Shiny-Leaflet interface to the YPDT database.  ####
##########################################################
# Hydrological analysis tools
#
# By M. Marchildon
# v.1.6.7
# Jan, 2023
##########################################################


source("pkg/packages.R", local = TRUE)
source("pkg/sources.R", local = TRUE)
sta.id.test <- NULL # 149118 # '149130' # '731100016'#' '02EC009' #'149343' # 


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
        div(style="padding: 1px 0px; height: 0px", titlePanel(title="", windowTitle="sHydrology")), # height: 0px
        navbarPage(
          title=div(img(src="ORMGP_logo_no_text_short.png", height=11), "sHydrology v1.6.7"),
          source(file.path("ui", "hydrograph.R"), local = TRUE)$value,
          source(file.path("ui", "trends.R"), local = TRUE)$value,
          source(file.path("ui", "stats.R"), local = TRUE)$value,
          # source(file.path("ui", "settings.R"), local = TRUE)$value,
          # source(file.path("ui", "data.R"), local = TRUE)$value,
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
    ### (hard-coded) Load station ID:
    if(!is.null(sta.id.test)) collect_hydrograph(sta.id.test) # for testing
    hide('chk.yld')
    ### Load from URL:
    observe({
      query <- parseQueryString(session$clientData$url_search)
      if (!is.null(query[['sID']])) {
        collect_hydrograph(query[['sID']])
      } else {
        showNotification(paste0("Error: URL invalid."))
      }
    })

    
    ### load external code:
    source("server/server_sources.R", local = TRUE)$value
    
    session$onSessionEnded(stopApp)
  }
)
