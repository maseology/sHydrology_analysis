navbarMenu("Data",
    tabPanel("Download data",
    source(file.path("ui/data", "data_table.R"), local = TRUE)$value
  ),
    tabPanel("data quality summary",
    source(file.path("ui/data", "data_qual.R"), local = TRUE)$value
  )
)