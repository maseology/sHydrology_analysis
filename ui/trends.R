navbarMenu("Longterm Trends",
   tabPanel("annual summary",
            source(file.path("ui/trend", "annual.R"), local = TRUE)$value
   ),
   tabPanel("seasonal summary",
            source(file.path("ui/trend", "seasonal.R"), local = TRUE)$value
   ),
   tabPanel("monthly summary",
            source(file.path("ui/trend", "monthly.R"), local = TRUE)$value
   ),   
   tabPanel("monthly baseflow summary",
            source(file.path("ui/trend", "monthly_bf.R"), local = TRUE)$value
   ),
   tabPanel("daily summary",
            source(file.path("ui/trend", "daily.R"), local = TRUE)$value
   ),
   tabPanel("cumulative discharge",
            source(file.path("ui/trend", "cumu.R"), local = TRUE)$value
   )
)