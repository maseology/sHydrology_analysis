
fluidPage(
  headerPanel('Annual summary'),
  column(6, plotOutput('yr.q')),
  column(6, plotOutput('yr.q.rel')), br(),
  shiny::includeMarkdown("md/rightclick.md")
)