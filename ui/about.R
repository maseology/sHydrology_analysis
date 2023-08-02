

# tabPanel("About", shiny::includeMarkdown("md/about.md"))


tabPanel("About",
  withMathJax(),
  fluidPage(
    column(2),
    column(8, 
           shiny::includeMarkdown("md/about.md"),
           shiny::includeMarkdown("md/references.md")
           )
  )
)