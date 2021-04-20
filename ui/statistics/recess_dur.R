
fluidPage(
  headerPanel('Recession duration analysis'),
  column(6, plotOutput('rsdr.hist'),
         shiny::includeMarkdown("md/recess_dur.md")),
  column(6, plotOutput('rsdr.time'),
         shiny::includeMarkdown("md/recess_durTime.md")), br(),
  shiny::includeMarkdown("md/rightclick.md")
)