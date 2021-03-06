navbarMenu("Hydrograph",
 tabPanel("discharge",
#           # tags$head(tags$script(HTML(jscode.mup))),
          source(file.path("ui/hydrograph", "discharge.R"), local = TRUE)$value
 ),
 tabPanel("(baseflow) separation",
          source(file.path("ui/hydrograph", "separation.R"), local = TRUE)$value
 ),
 tabPanel("disaggregation",
          source(file.path("ui/hydrograph", "disaggregation.R"), local = TRUE)$value
 ),
 tabPanel("data quality summary",
         source(file.path("ui/hydrograph/data", "data_qual.R"), local = TRUE)$value
 ),    
 tabPanel("Download data",
          source(file.path("ui/hydrograph/data", "data_table.R"), local = TRUE)$value
 )
)
