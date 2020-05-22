
fluidPage(
  title = 'Seasonal summary',
  headerPanel('Seasonal summary'),
  column(12, plotOutput('se.q', height='600px')), br(),
  shiny::includeMarkdown("md/rightclick.md") 
)