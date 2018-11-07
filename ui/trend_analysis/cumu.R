pageWithSidebar(
  headerPanel('Cumulative discharge'),
  sidebarPanel(
    h4("select date range:"),
    dygraphOutput("rng.cd")
  ),
  mainPanel(
    fluidRow(
      column(6,
             plotOutput('cum.q')
      ),
      column(6,
             plotOutput('cum.bf')
      )
    )
  )
)