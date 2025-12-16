# app.R
# list the packages your app needs
required_packages <- c('shiny', 'ggplot2', 'dplyr', 
                       'bslib', 'markdown', 'plotly')

# install any that are missing
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)

ui <- fluidPage(
  fluidRow(
    column(
      width = 4,
      # Student ID / Seed panel
      wellPanel(
        textInput('student_id', 'Enter Last Four Digits of Student ID:', 
                  value = '1234')
      ),
      # Instructions card
      wellPanel(
        includeMarkdown('instructions.md')
      )
    ),
    column(
      width = 8,
      # Controls above the plot
      wellPanel(
        selectInput('n_flips', 'Number of Flips per Run:', 
                    choices = c('1000', '5000','10000'), 
                    selected = '1000'),
        numericInput('n_runs', 'Number of Runs:', 
                     value = 1, min = 1, max = 10, step = 1),
        sliderInput('p_heads', 'Probability of Heads:', 
                    min = 0, max = 1, value = 0.5, step = 0.05),
        actionButton('runSim', 'Start Simulation')
      ),
      plotlyOutput('simPlot')
    )
  )
)

server <- function(input, output, session) {
  
  simData <- eventReactive(input$runSim, {
    n_flips <- as.numeric(input$n_flips)
    n_runs <- as.numeric(input$n_runs)
    p_heads <- input$p_heads
    
    # use Student ID as seed
    if (nzchar(input$student_id)) {
      set.seed(as.numeric(input$student_id))
    }
    
    # simulate coin flips
    flips <- matrix(rbinom(n_flips * n_runs, size = 1, prob = p_heads),
                    nrow = n_flips, ncol = n_runs)
    probs <- apply(flips, 2, function(x) cumsum(x) / seq_along(x))
    
    df <- data.frame(
      flip = rep(1:n_flips, times = n_runs),
      prob = as.vector(probs),
      run  = rep(paste0('Run ', 1:n_runs), each = n_flips)
    )
    
    df
  })
  
  output$simPlot <- renderPlotly({
    req(simData())
    df <- simData()
    
    g <- ggplot(df, aes(x = flip, y = prob, group = run, color = run,
                        text = paste('Run:', run, '<br>Flip:', flip, 
                                     '<br>Prob:', round(prob, 3)))) +
      geom_line(alpha = 0.7) +
      geom_point(data = df %>% group_by(run) %>% slice_tail(n = 1), size = 2) +
      geom_hline(yintercept = input$p_heads, linetype = 'dashed') +
      labs(
        x = 'Flip Number', 
        y = 'Running Probability of Heads',
        title = 'Simulated Running Probabilities',
        subtitle = paste('Theoretical probability =', input$p_heads)
      ) +
      theme_minimal() +
      theme(legend.position = 'none') +
      coord_cartesian(xlim = c(1, max(df$flip) * 1.05), ylim = c(0, 1))
    
    ggplotly(g, tooltip = 'text') %>%
      layout(margin = list(t = 80), showlegend=T)
  })
}

shinyApp(ui, server)