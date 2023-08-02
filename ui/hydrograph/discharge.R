fluidRow(
  sidebarPanel(
    htmlOutput('info.main'),
    dateRangeInput("dt.rng",label='select date range:'),
    checkboxInput('chk.flg','show observation flags'),
    # shiny::includeMarkdown("md/todo.md"),
    htmlOutput("link.shydrograph"),
    width = 2
  ),
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Dynamic", dygraphOutput("dyhydgrph")),
                tabPanel("Printable", plotOutput("gghydgrph")),
                tabPanel("Map", leafletOutput("leaflet", height = "600px"))
    ), br(),
    column(6, plotOutput('fdc')),
    column(6, plotOutput('mnt.q')),
    width = 10
  )
)

