fluidRow(
  sidebarPanel(
    htmlOutput('info.main'), 
    checkboxInput('chk.flg','show observation flags')
  ),
  mainPanel(
    dygraphOutput("hydgrph"), br(),
    column(6, plotOutput('fdc')),
    column(6, plotOutput('mnt.q'))
  )
)