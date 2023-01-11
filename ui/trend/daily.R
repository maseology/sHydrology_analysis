
fluidPage(
  titlePanel('Mean-daily discharge'),
  fluidRow(
    sidebarPanel(
     h4("select date range:"),
     dygraphOutput("rng.mdd")
    ),
    mainPanel(
     plotOutput('dy.q'),
     plotOutput('dy.qmmm'),
     plotOutput('dy.qbox')
   )
  )  
)

