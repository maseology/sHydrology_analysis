
fluidPage(
  title = 'Indicators of Hydrologic Alteration',
  headerPanel('Indicators of Hydrologic Alteration'),
  sidebarLayout(
    sidebarPanel(
      plotOutput("cumu.iah",height=300), br(),
      h4("select date range 1:"),
      dygraphOutput("rng.iah1",height=240), br(),
      h4("select date range 2:"),
      dygraphOutput("rng.iah2",height=240)
    ),
    mainPanel(
      fluidRow(
        h5("NOTE: Group descriptions given below. Values shown in red show a significant change (p<0.05)"),
        h4("Group 1: Magnitude of monthly water conditions"),
        formattableOutput('tabIHA.01'),
        h4("Group 2: Magnitude and duration of annual extreme weather conditions"),
        formattableOutput('tabIHA.02'),
        h4("Group 3: Timing (julian date) of annual extream water conditions"),
        formattableOutput('tabIHA.03'),
        h4("Group 4: Frequency and duration of high/low pulses"),
        formattableOutput('tabIHA.04'),
        h4("Group 5: Rate and frequency of change in conditions"),
        formattableOutput('tabIHA.05')
      )
    )    
  ), br(), 
  shiny::includeMarkdown("md/ihanotes.md")
)