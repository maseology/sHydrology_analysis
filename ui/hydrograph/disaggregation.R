
fluidRow(
  shiny::includeMarkdown("md/parsenotes.md"),
  hr(),
  htmlOutput("hdr1"),
  dygraphOutput("hydgrph.prse"),
  br(),
  plotOutput("hydgrph.prse.scatter")
)