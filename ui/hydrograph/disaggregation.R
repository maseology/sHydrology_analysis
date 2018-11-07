
fluidRow(
  htmlOutput("hdr1"),
  dygraphOutput("hydgrph.prse"),
  shiny::includeMarkdown("md/parsenotes.md")
)