navbarMenu("Settings",
  tabPanel("recession coefficient",
          sidebarPanel(
            numericInput('k.val','Recession coefficient',NULL,min=0.001,max=0.9999,step=0.0001),
            br(),
            actionButton("k.set","Update"), actionButton("k.auto", "Reset")
          ),
          mainPanel(
            plotOutput('k.coef')
          )
  ),
  tabPanel("baseflow separation",
           shiny::includeMarkdown("md/todo.md")
  )
)