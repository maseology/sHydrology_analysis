
fluidPage(
  withMathJax(),
  headerPanel('Automated streamflow recession computation'),
  sidebarPanel(
    numericInput('k.val','Recession coefficient',NULL,min=0.001,max=0.9999,step=0.0001),
    fluidRow(
      column(3, actionButton("k.reset", "Recompute k")),
      column(9, align="right", actionButton("k.update","Update plot"))
    ),
    width = 2
  ),
  mainPanel(
    fluidRow(
      column(6, plotOutput('k.coef', height = "600px")),
      column(6, plotOutput('m.coef', height = "600px"))
    ),
    fluidRow(column(8, shiny::includeMarkdown("md/knotes.md"))),
    width = 10
  )
)
