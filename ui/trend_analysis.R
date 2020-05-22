navbarMenu("Longterm Trends",
   tabPanel("annual summary",
            source(file.path("ui/trend_analysis", "annual.R"), local = TRUE)$value
   ),
   tabPanel("seasonal summary",
            source(file.path("ui/trend_analysis", "seasonal.R"), local = TRUE)$value
   ),
   tabPanel("monthly baseflow summary",
            source(file.path("ui/trend_analysis", "monthly_bf.R"), local = TRUE)$value
   ),
   tabPanel("cumulative discharge",
            source(file.path("ui/trend_analysis", "cumu.R"), local = TRUE)$value
   )
)