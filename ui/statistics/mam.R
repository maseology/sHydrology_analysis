fluidPage(
  title = 'sHydrology MAM analysis',
  fluidRow(
    headerPanel('n-day annual minima recurrence'),
    htmlOutput("hdr3"),
    column(3, 
           selectInput('mam.freq', 'frequency model', c('Log Pearson III'='lp3',
                                                            'Generalized Extreme Value'='gev',
                                                            'Weibull'='wei',
                                                            'Gumbel'='gum',
                                                            'three-parameter lognormal'='ln3'))
    ),
    column(3,
           numericInput('mam.rsmpl','number of boostrap resamples',10000,min=1000,max=100000)
    ),
    column(3,
           numericInput('mam.ci','confidence interval',0.9,min=0.05,max=0.999,step=0.01)
    ),
    column(2, br(),
            actionButton('mam.regen',"Regenerate"),
            offset = 1
           )
  ), hr(),
  fluidRow(
    column(4, plotOutput('mam.q1')),
    column(4, plotOutput('mam.q7')),
    column(4, plotOutput('mam.q30')) 
  ),
  fluidRow(
    column(4, plotOutput('hist.q1')),
    column(4, plotOutput('hist.q7')),
    column(4, plotOutput('hist.q30')) 
  ),br(),
  shiny::includeMarkdown("md/rightclick.md"), 
  shiny::includeMarkdown("md/mamnotes.md")
)