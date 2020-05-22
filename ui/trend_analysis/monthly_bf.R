
fluidPage(
  headerPanel('Monthly baseflow summary'),
  fluidRow(
    sidebarPanel(
      h4("select date range:"),
      dygraphOutput("rng.bf")
    ),
    mainPanel(
      column(6, plotOutput('BF.mnt')),
      column(6, plotOutput('BFI.mnt')), br(),
      shiny::includeMarkdown("md/rightclick.md"), br(),
      shiny::includeMarkdown("md/bfmntnotes.md") 
    )
  )
)
