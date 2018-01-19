tabPanel("Data table",
  sidebarPanel(
   dateRangeInput("tabRng", label = "Date range"),
   checkboxInput("tabCmplt", "Include all computations", FALSE),
   br(), downloadButton("tabCsv", "Download csv.."),
   width=2
  ),
  mainPanel(
   dataTableOutput('tabhyd'),
   width=10
  )
)