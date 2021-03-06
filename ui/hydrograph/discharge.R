fluidRow(
  sidebarPanel(
    htmlOutput('info.main'),
    dateRangeInput("dt.rng",label='select date range:'),
    checkboxInput('chk.flg','show observation flags'),
    checkboxInput('chk.yld','show catchment simulation (where applied)'),
    width = 2
  ),
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Dynamic", dygraphOutput("dyhydgrph")),
                tabPanel("Printable", plotOutput("gghydgrph"))
    ), br(),
    column(6, plotOutput('fdc')),
    column(6, plotOutput('mnt.q')),
    width = 10
  )
)
