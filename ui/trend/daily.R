
fluidPage(
  titlePanel('Distributions of mean-daily discharge'),
  fluidRow(
    sidebarPanel(
     h4("select date range:"),
     dygraphOutput("rng.mdd"), br(),
     shiny::includeMarkdown("md/dtrng.md")
    ),
    mainPanel(
     plotOutput('dy.q'),
     plotOutput('dy.qmmm')
     # plotOutput('dy.qbox')
   )
  )  
)

