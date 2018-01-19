##########################################################
##################### sHydrology ######################### 
#### A Shiny-Leaflet interface to the HYDAT database. ####
##########################################################
# Hydrological analysis tools
#
# By M. Marchildon
# v.1.0.1
# Jan 19, 2018
##########################################################

source("pkg/packages_HYDAT.R", local = TRUE)

staID <- '02HB025' ### WSC Station Name
dbc <- dbcnxn('<...path of Hydat.sqlite3 file goes here...>')

shinyApp(
  ui <- fluidPage(
    useShinyjs(),
    tags$head(includeCSS("styles.css")),
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
          #"sHydrology v1.0",
          title=div(img(src="ORMGP_logo_no_text_short.png", height=11), "sHydrology v1.0"),
          source(file.path("ui", "main_hydrograph.R"), local = TRUE)$value,
          source(file.path("ui", "disaggregation.R"), local = TRUE)$value,
          source(file.path("ui", "trend_analysis.R"), local = TRUE)$value,
          source(file.path("ui", "frequency_analysis.R"), local = TRUE)$value,
          source(file.path("ui", "flow_regime.R"), local = TRUE)$value,
          source(file.path("ui", "settings.R"), local = TRUE)$value,
          source(file.path("ui", "data_table.R"), local = TRUE)$value,
          tabPanel("About", shiny::includeMarkdown("md/about.md"))
        )        
      )
    )
  ),
  
  server <- function(input, output, session){
    ### Parameters:
    sta <- reactiveValues(loc=NULL, id=NULL, name=NULL, name2=NULL, 
                          carea=NULL, k=NULL, hyd=NULL, DTb=NULL, DTe=NULL, 
                          label=NULL, info.html=NULL, 
                          BFbuilt=FALSE, HPbuilt=FALSE)
    
    sta.fdc <- reactiveValues(cmplt=NULL,prtl=NULL)
    sta.mnt <- reactiveValues(cmplt=NULL,prtl=NULL)
    BFp <- list(LHa=0.925, LHp=3, BFIx=0.8, JHC=0.3) # baseflow parameters
    
    ### sources:
    source(file.path("server", "main_hydrograph.R"),  local = TRUE)$value
    source(file.path("server", "disaggregation.R"),  local = TRUE)$value
    source(file.path("server", "trend_analysis.R"),  local = TRUE)$value
    source(file.path("server", "frequency_analysis.R"),  local = TRUE)$value
    # source(file.path("server", "flow_regime.R"),  local = TRUE)$value
    source(file.path("server", "settings.R"),  local = TRUE)$value # recession coeficient, BF params, etc.
    source(file.path("server", "data_table.R"),  local = TRUE)$value
    
    session$onSessionEnded(stopApp)
  }
)
