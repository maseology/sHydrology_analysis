

tabPanel("References",
         fluidPage(
           column(2),
           column(8, 
                  shiny::includeMarkdown("md/references.md")
           )
         )
)