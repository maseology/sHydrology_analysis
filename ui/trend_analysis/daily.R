
pageWithSidebar(
 headerPanel('Mean-daily discharge'),
 sidebarPanel(
   h4("select date range:"),
   dygraphOutput("rng.mdd")
 ),
 mainPanel(
   plotOutput('dy.q')
 )
)