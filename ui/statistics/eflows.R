
fluidPage(
  h2('E-Flows'),
  tabsetPanel(type = "tabs",
              tabPanel(title = 'Streamflow Analysis and Assessment Software',
                       sidebarLayout(
                         sidebarPanel(
                           # plotOutput("cumu.iah",height=300), br(),
                           # h4("select date range 1:"),
                           dygraphOutput("rng.saas",height=300), br(),
                           shiny::includeMarkdown("md/dtrng.md"), br(),
                           p("NOTE: certain SAAS plots shown here will not render for short period (<10yr) hydrographs")
                           # h4("select date range 2:"),
                           # dygraphOutput("rng.iah2",height=240)
                         ),
                         mainPanel(
                           fluidRow(
                             h2('Streamflow Analysis and Assessment Software (SAAS)'),
                             h5("(after Metcalfe et.al., 2013)"),
                             # p("NOTE: Group descriptions given below. Values shown in red show a significant change (p<0.05)"),
                             
                             hr(),
                             h5("Hydrologic regime components and associated indicators selected to assess hydrologic alteration:"),
                             
                             h3("Baseflow"),
                             shiny::includeMarkdown("md/saas_mmbf.md"), br(),
                             plotOutput('saas.mmbf'), br(),
                             plotOutput('saas.mmbf2'),
                             formattableOutput('tabSAAS.mmbf'), hr(), br(),
                             
                             h3("Subsistence flow"),
                             p("Monthly exceedance flow magnitudes of total streamflow (preliminary assessment)"),
                             plotOutput('saas.m95q'),
                             formattableOutput('tabSAAS.m95q'), hr(), br(),
                             
                             h3("High flow pulses (less than bankfull)"),
                             p("Monthly median frequency and duration (days) of flow events less than the bankfull flow magnitude."),
                             plotOutput('saas.hfp'), hr(), br(),
                             
                             h3("Channel forming flow"),
                             p("Magnitude, duration (days) and timing (month) of flows with a recurrence interval > 1.5 years."),
                             plotOutput('saas.cff'), hr(), br(),
                             
                             h3("Riparian flow"),
                             p("Magnitude, duration (days) and timing (month) of flows with recurrence intervals of 2, 10, and 20 years."),
                             h4("2 year recurrence"),
                             plotOutput('saas.rf.2'),
                             h4("10 year recurrence"),
                             plotOutput('saas.rf.10'),
                             h4("20 year recurrence"),
                             plotOutput('saas.rf.20'), hr(), br(),
                             
                             h3("Rate of change of flow"),
                             p("Monthly median rate-of-change of flow (m3/sec/hr) for rising and falling limbs of flow events."),
                             plotOutput('saas.roc')
                             
                           )
                         )    
                       )
              ),
              tabPanel(
                title = 'Indicators of Hydrologic Alteration', br(),
                sidebarLayout(
                  sidebarPanel(
                    plotOutput("cumu.iah",height=300), br(),
                    h4("select date range 1:"),
                    dygraphOutput("rng.iah1",height=240), br(),
                    h4("select date range 2:"),
                    dygraphOutput("rng.iah2",height=240), br(),
                    shiny::includeMarkdown("md/dtrng.md")
                  ),
                  mainPanel(
                    fluidRow(
                      h2('Indicators of Hydrologic Alteration (IHA)'), hr(),
                      htmlOutput("hdr.iha"),
                      h5("NOTE: Group descriptions given below. Values shown in red show a significant change (p<0.05)"),
                      h4("Group 1: Magnitude of monthly water conditions"),
                      formattableOutput('tabIHA.01'),
                      h4("Group 2: Magnitude and duration of annual extreme water conditions"),
                      formattableOutput('tabIHA.02'),
                      h4("Group 3: Timing (julian date) of annual extreme water conditions"),
                      formattableOutput('tabIHA.03'),
                      h4("Group 4: Frequency and duration of high/low pulses"),
                      formattableOutput('tabIHA.04'),
                      h4("Group 5: Rate and frequency of change in conditions"),
                      formattableOutput('tabIHA.05')
                    ), hr(), 
                    shiny::includeMarkdown("md/ihanotes.md")
                  )    
                )
              )
  )
)