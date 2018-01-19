navbarMenu("Flow frequency",
  tabPanel("peak flow",
          pageWithSidebar(
            headerPanel('Peak flow analysis'),
            sidebarPanel(
              selectInput('pk.freq', 'Flow frequency model', c('Log Pearson III'='lp3',
                                                               'Generalized Extreme Value'='gev',
                                                               'Weibull'='wei',
                                                               'Gumbel'='gum',
                                                               'three-parameter lognormal'='ln3')),
              numericInput('pk.rsmpl','n Boostrap resamples',10000,min=1000,max=100000),
              numericInput('pk.ci','Confidence interval',0.9,min=0.05,max=0.999,step=0.01),
              width = 2
            ),
            mainPanel(
              column(6, plotOutput('pk.q')),
              column(6, plotOutput('pk.dist')),
              width = 10
            )
          )
  ),
  tabPanel("low flow",
           shiny::includeMarkdown("md/todo.md")
  )
)