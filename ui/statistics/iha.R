
fluidPage(
  title = 'Indicators of Hydrologic Alteration',
  headerPanel('Indicators of Hydrologic Alteration'),
  sidebarLayout(
    sidebarPanel(
      h4("select date range 1:"),
      dygraphOutput("rng.iah1",height=240), br(),
      h4("select date range 2:"),
      dygraphOutput("rng.iah2",height=240)
    ),
    mainPanel(
      fluidRow(
        column(6,
          h3("selected date range 1:"),
          h4("Group 1:"),
          tableOutput('tabIHA.01'),
          h4("Group 2:"),
          tableOutput('tabIHA.02'),
          h4("Group 3:"),
          tableOutput('tabIHA.03'),
          h4("Group 4:"),
          tableOutput('tabIHA.04'),
          h4("Group 5:"),
          tableOutput('tabIHA.05')
        ),
        column(6,
          h3("selected date range 2:"),
          h4("Group 1:"),
          tableOutput('tabIHA.11'),
          h4("Group 2:"),
          tableOutput('tabIHA.12'),
          h4("Group 3:"),
          tableOutput('tabIHA.13'),
          h4("Group 4:"),
          tableOutput('tabIHA.14'),
          h4("Group 5:"),
          tableOutput('tabIHA.15')
        )
      )
    )    
  ), br(), 
  shiny::includeMarkdown("md/ihanotes.md")
)