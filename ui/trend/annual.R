
fluidPage(
  titlePanel('Annual series'),
  column(6, plotOutput('yr.q')),
  column(6, plotOutput('yr.q.rel')), br(),
  shiny::includeMarkdown("md/rightclick.md"), br(),
  shiny::includeMarkdown("md/bfannnotes.md") 
)