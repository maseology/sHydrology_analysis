navbarMenu("Hydrograph",
# tabPanel("raw queried data",
#           # tags$head(tags$script(HTML(jscode.mup))),
 tabPanel("daily-mean data",
          source(file.path("ui/hydrograph", "discharge.R"), local = TRUE)$value
 ),
 tabPanel("(baseflow) separation",
          source(file.path("ui/hydrograph", "separation.R"), local = TRUE)$value
 ),
 tabPanel("disaggregation",
          source(file.path("ui/hydrograph", "disaggregation.R"), local = TRUE)$value
 ),
 tabPanel("data quality (counts)",
         source(file.path("ui/hydrograph/data", "data_qual.R"), local = TRUE)$value
 ),  
 tabPanel("aggregated data summary",
         source(file.path("ui/hydrograph/data", "data_summary.R"), local = TRUE)$value
 ),
 tabPanel("Download data",
          source(file.path("ui/hydrograph/data", "data_table.R"), local = TRUE)$value
 )
)
