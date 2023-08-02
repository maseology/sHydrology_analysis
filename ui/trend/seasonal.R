
fluidPage(
  titlePanel('Seasonal summary'),
  # title = 'Seasonal summary',
  # headerPanel('Seasonal summary'),
  column(6, 
           plotOutput('se.q', height='600px'), br(),
           shiny::includeMarkdown("md/rightclick.md") 
         ),
  column(6, 
           h4("Annual time-series overlay"), hr(),
           fluidRow(dygraphOutput('rng.se', height='450px')), br(),
           fluidRow(formattableOutput('tab.se'))
         )
)