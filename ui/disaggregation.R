navbarMenu("Disaggregation",
           tabPanel("baseflow separation",
                    htmlOutput("hdr21"),
                    dygraphOutput("hydgrph.bf"),
                    shiny::includeMarkdown("md/bfnotes.md")
           ),
           tabPanel("hydrograph parsing",
                    htmlOutput("hdr22"),
                    dygraphOutput("hydgrph.prse"),
                    shiny::includeMarkdown("md/parsenotes.md")
           )
)