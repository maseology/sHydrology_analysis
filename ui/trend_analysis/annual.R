
fluidPage(
  headerPanel('Annual flow summary'),
  column(6, plotOutput('yr.q')),
  column(6, plotOutput('yr.q.rel'))
)