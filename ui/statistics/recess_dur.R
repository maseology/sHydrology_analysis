
fluidPage(
  headerPanel('Recession duration analysis'),
  column(6, plotOutput('rsdr.hist')), br(),
  shiny::includeMarkdown("md/rightclick.md"),
  shiny::includeMarkdown("md/recess_dur.md")
)