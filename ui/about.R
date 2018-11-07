

# tabPanel("About", shiny::includeMarkdown("md/about.md"))


tabPanel("About",
  fluidPage(
    column(2),
    column(8, 
           shiny::includeMarkdown("md/about.md")
           )
  )
)