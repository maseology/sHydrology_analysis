
fluidPage(
  titlePanel("Aggregated summary"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create and copy summaries of queried data."),
      
      selectInput("var", 
                  label = "Choose statistic",
                  choices = c("mean", 
                              "median"),
                  selected = "mean"),
      
      sliderInput("range", 
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100))
      ),
    
    mainPanel(
      verbatimTextOutput("selected_var")
    )
  )
  )