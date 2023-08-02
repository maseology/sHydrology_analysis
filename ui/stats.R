navbarMenu("Statistics",
  tabPanel("peak flow frequency",
           source(file.path("ui/statistics", "peak.R"), local = TRUE)$value
  ),
  tabPanel("low flow frequency",
           source(file.path("ui/statistics", "mam.R"), local = TRUE)$value
  ),
  tabPanel("recession duration",
           source(file.path("ui/statistics", "recess_dur.R"), local = TRUE)$value
  ),
  # tabPanel("flow regime: IHA",
  #          source(file.path("ui/statistics", "iha.R"), local = TRUE)$value
  # ),
  # tabPanel("flow regime: SAAS",
  #          shiny::includeMarkdown("md/todo.md")
  # ), br(), 
  tabPanel("environmental flows",
           source(file.path("ui/statistics", "eflows.R"), local = TRUE)$value
  ), br(), 
  tabPanel("recession coefficient",
           source(file.path("ui/statistics", "recession.R"), local = TRUE)$value
  )
)