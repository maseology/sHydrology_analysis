
fluidPage(
  withMathJax(),
  titlePanel('Cumulative discharge'),
  # title = 'Cumulative discharge',
  # headerPanel('Cumulative discharge'),
  sidebarLayout(
    sidebarPanel(
      h4("select date range:"),
      dygraphOutput("rng.cd")
    ),
    mainPanel(
      fluidRow(
        column(6,
               plotOutput('cum.q')
        ),
        column(6,
               plotOutput('cum.bf')
        ), br(),
        shiny::includeMarkdown("md/rightclick.md"), br(),
        shiny::includeMarkdown("md/cumu.md")
      )
    )    
  )
)