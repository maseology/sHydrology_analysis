navbarMenu("Longterm Trends",
   tabPanel("annual summary",
            source(file.path("ui/trend_analysis", "annual.R"), local = TRUE)$value
   ),
   tabPanel("monthly summary",
            source(file.path("ui/trend_analysis", "monthly.R"), local = TRUE)$value
   ),
   tabPanel("cumulative discharge",
            source(file.path("ui/trend_analysis", "cumu.R"), local = TRUE)$value
   )
)