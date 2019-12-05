fluidRow(
  headerPanel('Data summary'),
  htmlOutput("hdr.qual"), br(),
  column(6, h4('count'),
         tableOutput('qaqc.cnt')),
  column(6, h4('average discharge'),
         tableOutput('qaqc.avg'))
)
