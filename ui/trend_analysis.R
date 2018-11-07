navbarMenu("Longterm trend analysis",
   tabPanel("annual flow summary",
            source(file.path("ui/trend_analysis", "annual.R"), local = TRUE)$value
   ),
   # tabPanel("mean-daily discharge",
   #          source(file.path("ui/trend_analysis", "daily.R"), local = TRUE)$value
   # ),
   tabPanel("monthly baseflow",
            source(file.path("ui/trend_analysis", "baseflow.R"), local = TRUE)$value
   ),
   tabPanel("cumulative discharge",
            source(file.path("ui/trend_analysis", "cumu.R"), local = TRUE)$value
   )
)