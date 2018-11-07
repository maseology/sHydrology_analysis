
fluidPage(
  headerPanel('Monthly range in baseflow'),
  fluidRow(
    sidebarPanel(
      h4("select date range:"),
      dygraphOutput("rng.bf")
    ),
    mainPanel(
      column(6, plotOutput('BF.mnt')),
      column(6, plotOutput('BFI.mnt'))
    ) 
  ),
  shiny::includeMarkdown("md/bfmntnotes.md")
)
