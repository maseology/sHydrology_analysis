navbarMenu("Trend analysis",
   tabPanel("annual flow summary",
            fluidPage(
              headerPanel('Annual flow summary'),
              column(6, plotOutput('yr.q')),
              column(6, plotOutput('yr.q.rel'))
            )
   ),
   tabPanel("mean-daily discharge",
            pageWithSidebar(
              headerPanel('Mean-daily discharge'),
              sidebarPanel(
                h4("select date range:"),
                dygraphOutput("rng.mdd")
              ),
              mainPanel(
                plotOutput('dy.q')
              )
            )
   ),
   tabPanel("monthly baseflow",
            fluidPage(
              headerPanel('Monthly range in baseflow'),
              sidebarPanel(
                h4("select date range:"),
                dygraphOutput("rng.bf")
              ),
              mainPanel(
                column(6, plotOutput('BF.mnt')),
                column(6, plotOutput('BFI.mnt'))
              )
            ),
            shiny::includeMarkdown("md/bfmntnotes.md")
   ),
   tabPanel("cumulative discharge",
            pageWithSidebar(
              headerPanel('Cumulative discharge'),
              sidebarPanel(
                h4("select date range:"),
                dygraphOutput("rng.cd")
              ),
              mainPanel(
                plotOutput('cum.q')
              )
            )
   )
)