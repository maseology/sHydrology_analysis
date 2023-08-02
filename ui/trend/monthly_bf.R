
fluidPage(
  titlePanel('Monthly distributions of baseflow'),
  # headerPanel('Monthly baseflow summary'),
  fluidRow(
    sidebarPanel(
      h4("select date range:"),
      dygraphOutput("rng.bf"), br(),
      shiny::includeMarkdown("md/dtrng.md")
    ),
    mainPanel(
      shiny::includeMarkdown("md/bfmntnotes.md"), 
      column(6, plotOutput('BF.mnt')),
      column(6, plotOutput('BFI.mnt')), br(),
      shiny::includeMarkdown("md/rightclick.md"),br(),
      htmlOutput('info.mntbf'),
      fluidRow(formattableOutput('tab.mntbf'))
    )
  )
)
