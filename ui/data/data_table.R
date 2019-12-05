fluidRow(
  sidebarPanel(
    dateRangeInput("tabRng", label = "Date range"),
    br(), actionButton("tabCmplt", "Include all computations"),
    br(), br(), downloadButton("tabCsv", "Download csv.."),
    width=2
  ),
  mainPanel(
    dataTableOutput('tabhyd'),
    width=10
  )
)