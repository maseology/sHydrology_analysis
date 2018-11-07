
fluidPage(
  sidebarPanel(
    numericInput('k.val','Recession coefficient',NULL,min=0.001,max=0.9999,step=0.0001),
    fluidRow(
      column(3, actionButton("k.reset", "Recompute k")),
      column(9, align="right", actionButton("k.update","Update plot"))
    )
  ),
  mainPanel(
    plotOutput('k.coef', height = "800px")
  ), br(), 
  shiny::includeMarkdown("md/knotes.md")
)
