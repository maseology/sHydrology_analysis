fluidPage(
  title = 'sHydrology peak flow analysis',
  fluidRow(
    headerPanel('Peak flow analysis'),
    htmlOutput("hdr2"),
    column(3, 
           selectInput('pk.freq', 'flow frequency model', c('Log Pearson III'='lp3',
                                                            'Generalized Extreme Value'='gev',
                                                            'Weibull'='wei',
                                                            'Gumbel'='gum',
                                                            'three-parameter lognormal'='ln3'))
    ),
    column(3,
           numericInput('pk.rsmpl','number of boostrap resamples',10000,min=1000,max=100000)
    ),
    column(3,
           numericInput('pk.ci','confidence interval',0.9,min=0.05,max=0.999,step=0.01)
    ),
    column(2, br(),
           actionButton('pk.regen',"Regenerate"),
           offset = 1
    )
  ), hr(),
  fluidRow(
    column(4, plotOutput('pk.q')),
    column(4, plotOutput('pk.dist')),
    column(4, plotOutput('pk.hist')) 
  ), br(),
  shiny::includeMarkdown("md/rightclick.md")
)
