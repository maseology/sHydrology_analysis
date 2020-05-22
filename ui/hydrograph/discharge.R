fluidRow(
  sidebarPanel(
    htmlOutput('info.main'), 
    checkboxInput('chk.flg','show observation flags'),
    checkboxInput('chk.yld','show catchment simulation (where applied)'),
    width = 2
  ),
  mainPanel(
    dygraphOutput("hydgrph"), br(),
    column(6, plotOutput('fdc')),
    column(6, plotOutput('mnt.q')),
    width = 10
  )
)