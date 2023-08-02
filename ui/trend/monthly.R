
fluidPage(
  titlePanel('Monthly distributions'),
  fluidRow(
    sidebarPanel(
     h4("select date range:"),
     dygraphOutput("rng.mnt"), br(),
     shiny::includeMarkdown("md/dtrng.md")
    ),
    mainPanel(
     fluidRow(plotOutput('mnt.qbox')),
     shiny::includeMarkdown("md/rightclick.md"),
     shiny::includeMarkdown("md/boxplot-info.md"), br(),
     htmlOutput('info.mnt'),
     fluidRow(formattableOutput('tab.mnt'))
   )
  )  
)

