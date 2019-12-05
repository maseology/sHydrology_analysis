
fluidRow(
  withMathJax(),
  htmlOutput("hdr0"), br(),
  dygraphOutput("hydgrph.bf"), br(),
  column(2),
  column(10,
         checkboxInput("bf.shwall", "show each individual baseflow hydrographs (**This process will take time to render large datasets.)", width='100%')
  ), br(), 
  shiny::includeMarkdown("md/bfnotes.md")
)