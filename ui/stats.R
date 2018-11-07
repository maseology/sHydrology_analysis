navbarMenu("Statistics",
  tabPanel("peak flow frequency",
           source(file.path("ui/statistics", "peak.R"), local = TRUE)$value
  ),
  tabPanel("low flow frequency",
           source(file.path("ui/statistics", "mam.R"), local = TRUE)$value
  ),
  tabPanel("flow regime: IHA",
           shiny::includeMarkdown("md/todo.md") #Richter, B.D., J.V. Baumgertner, J. Powell, D.P. Braun, 1996. A Method for Assessing Hydrologic Alteration within Ecosystems. Conservation Biology 10(4): 1163-1174.
  ),
  tabPanel("flow regime: SAAS",
           shiny::includeMarkdown("md/todo.md")
  ),
  tabPanel("recession coefficient",
           source(file.path("ui/statistics", "recession.R"), local = TRUE)$value
  )
)