navbarMenu("Trends",
   tabPanel("annual series",
            source(file.path("ui/trend", "annual.R"), local = TRUE)$value
   ),
   tabPanel("seasonal summary",
            source(file.path("ui/trend", "seasonal.R"), local = TRUE)$value
   ),
   tabPanel("monthly distributions",
            source(file.path("ui/trend", "monthly.R"), local = TRUE)$value
   ),   
   tabPanel("monthly, baseflow",
            source(file.path("ui/trend", "monthly_bf.R"), local = TRUE)$value
   ),
   tabPanel("day-of-year",
            source(file.path("ui/trend", "daily.R"), local = TRUE)$value
   ),
   tabPanel("cumulative",
            source(file.path("ui/trend", "cumu.R"), local = TRUE)$value
   )
)