
fluidPage(
  titlePanel('Monthly distribution'),
  fluidRow(
    sidebarPanel(
     h4("select date range:"),
     dygraphOutput("rng.mnt")
    ),
    mainPanel(
     fluidRow(plotOutput('mnt.qbox')),
     br(), htmlOutput('info.mnt'),
     fluidRow(formattableOutput('tab.mnt'))
   )
  )  
)

