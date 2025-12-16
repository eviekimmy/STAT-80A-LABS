# app.R
library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(markdown)

# ---- Helper: Roulette simulation ----
simulate_roulette <- function(bets, amounts, seed, n_spins = 30000) {
  
  set.seed(seed)
  wheel <- c("00", "0", as.character(1:36))
  spins <- sample(wheel, n_spins, replace = TRUE)
  
  reds <- c("1","3","5","7","9","12","14","16","18","19","21","23","25","27","30","32","34","36")
  blacks <- c("2","4","6","8","10","11","13","15","17","20","22","24","26","28","29","31","33","35")
  
  split.bets = list('1-2' = wheel[3:4], '2-3' = wheel[4:5], '4-5' = wheel[6:7], 
                    '5-6' = wheel[7:8], '7-8' = wheel[9:10], '8-9' = wheel[10:11], 
                    '10-11' = wheel[12:13], '11-12' = wheel[13:14])
  color.bets = list('Red' = reds, 'Black' = blacks)
  dozen.bets = list('1st 12' = wheel[1:12], '2nd 12' = wheel[13:24], 
                    '3rd 12' = wheel[25:36])
  
  ifelse(spins == bets[1], 35*amounts[1], -amounts[1]) -> running.straight
  ifelse(spins %in% split.bets[[bets[2]]], 17*amounts[2], -amounts[2]) -> running.split
  ifelse(spins %in% color.bets[[bets[3]]], amounts[3], -amounts[3]) -> running.color
  ifelse(spins %in% dozen.bets[[bets[4]]], 2*amounts[4], -amounts[4]) -> running.dozen
  
  running.total = running.straight + running.split + running.color + running.dozen
  
  data.frame(
    Spin = 1:n_spins, 
    Straight = running.straight %>% cummean(),
    Split = running.split %>% cummean(),
    Total = running.total %>% cummean(),
    Color = running.color %>% cummean(),
    Dozen = running.dozen %>% cummean()
  )
}

# ---- Helper: Bias experiment ----
simulate_bias <- function(bias = 0.037, n = 10000) {
  number <- as.character(0:37)
  number[38] <- '00'
  
  biased.probs <- rep((1 - bias) / 35, 38)
  biased.probs[c(2, 4, 21)] <- rep(bias, 3)
  
  experiment <- data.frame(
    biased.value = sample(x = number, size = n, prob = biased.probs, replace = TRUE),
    uniform.value = sample(x = number, size = n, replace = TRUE)
  ) %>% 
    mutate(
      biased.value = fct(biased.value, levels = number),
      uniform.value = fct(uniform.value, levels = number),
      in.bias = biased.value %in% c("2", "4", "21")
    )
  experiment
}

# ---- UI ----
ui <- page_fillable(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("American Roulette Simulation"),
  withMathJax(),
  
  fluidRow(
    # Left column
    column(
      width = 4,
      card(
        card_header("Simulation Settings"),
        numericInput("seed", "Random Seed:", value = 123, min = 1),
      ),
      card(
        card_header("Instructions"),
        div(
          style = "
          max-height: 400px;     /* limit the height of the card */
          overflow-y: auto;       /* enable vertical scroll */
          padding-right: 10px;    /* add space for scrollbar */
        ",
        includeMarkdown("Instructions.md")
        )
      )
    ),
    
    # Right column with tabs
    column(
      width = 8,
      tabsetPanel(
        id = "main_tabs",
        
        # ---- TAB 1: Roulette Simulation ----
        tabPanel(
          "Roulette Simulation",
          card(
            card_header("Betting Controls"),
            
            tags$style(HTML("
              .compact-inputs .form-group {
                margin-bottom: 0.25rem;
              }
            ")),
            
            div(class = "compact-inputs",
                fluidRow(
                  column(4, tags$b("Bet Type")),
                  column(4, tags$b("Choice")),
                  column(4, tags$b("Amount ($)"))
                ),
                
                # Straight Up
                fluidRow(
                  column(4, "Straight Up"),
                  column(4, selectInput("straight_choice", NULL, 
                                        choices = c("00","0",as.character(1:36)), width="100%")),
                  column(4, numericInput("straight_amount", NULL, 0, min=0, width="100%"))
                ),
                
                # Split
                fluidRow(
                  column(4, "Split"),
                  column(4, selectInput("split_choice", NULL,
                                        choices = c("1-2","2-3","4-5","5-6","7-8","8-9","10-11","11-12"), width="100%")),
                  column(4, numericInput("split_amount", NULL, 0, min=0, width="100%"))
                ),
                
                # Color
                fluidRow(
                  column(4, "Color"),
                  column(4, selectInput("color_choice", NULL, choices = c("Red","Black"), width="100%")),
                  column(4, numericInput("color_amount", NULL, 0, min=0, width="100%"))
                ),
                
                # Dozen
                fluidRow(
                  column(4, "Dozen"),
                  column(4, selectInput("dozen_choice", NULL, 
                                        choices = c("1st 12","2nd 12","3rd 12"), width="100%")),
                  column(4, numericInput("dozen_amount", NULL, 0, min=0, width="100%"))
                )
            )
          ),
          card(
            card_header("Running Average Profit per Bet"),
            plotlyOutput("individualPlot", height = "350px")
          ),
          card(
            card_header("Running Average Profit (Combined Bets)"),
            plotlyOutput("combinedPlot", height = "350px")
          )
        ),
        
        # ---- TAB 2: Bias Detection ----
        # ---- TAB 2: Bias Detection ----
        tabPanel(
          "Bias Detection",
          card(
            card_header("Bias Settings"),
            numericInput("bias_level", "Bias Level:", min = 0, max = 0.1, value = 0.033, step = 0.001),
            numericInput("bias_n", "Number of Spins:", value = 10000, min = 10000, step = 10000)
          ),
          
          card(
            card_header("Observed Frequencies"),
            fluidRow(
              column(
                width = 6,
                plotOutput("biasPlot", height = "350px")
              ),
              column(
                width = 6,
                plotOutput("unbiasPlot", height = "350px")
              )
            )
          ),
          
          card(
            card_header("Summary Comparison"),
            tableOutput("biasSummaryTable")
          )
        )
      )
    )
  )
)

# ---- SERVER ----
server <- function(input, output, session) {
  
  # --- Simulation reactive ---
  sim_data <- reactive({
    bets <- c(input$straight_choice, input$split_choice,
              input$color_choice, input$dozen_choice)
    amounts = c(input$straight_amount, input$split_amount,
                input$color_amount, input$dozen_amount)
    simulate_roulette(bets, amounts, input$seed)
  })
  
  # --- Bias experiment reactive ---
  bias_data <- reactive({
    number <- as.character(0:37)
    number[38] <- '00'
    
    bias <- input$bias_level
    n <- input$bias_n
    
    biased.probs <- rep((1 - bias) / 35, 38)
    biased.probs[c(2, 4, 21)] <- rep(bias, 3)
    
    set.seed(NULL)
    unbiased <- sample(x = number, size = n, replace = TRUE)
    
    set.seed(input$seed)
    biased <- sample(x = number, size = n, prob = biased.probs, replace = TRUE)
    
    data.frame(
      biased.value = factor(biased, levels = number),
      unbiased.value = factor(unbiased, levels = number)
    )
  })
  
  # --- Plots ---
  output$individualPlot <- renderPlotly({
    req(sim_data())
    df <- sim_data() %>% select(-Total)
    df_long <- tidyr::pivot_longer(df, -Spin, names_to = "Bet", values_to = "AvgProfit")
    
    p <- ggplot(df_long, aes(x = Spin, y = AvgProfit, color = Bet)) +
      geom_line() +
      geom_hline(linetype='dashed', yintercept = -2/38) + 
      labs(x = "Number of Spins", y = "Running Average Profit", color = "Bet") +
      theme_minimal(base_size = 14)
    
    ggplotly(p)
  })
  
  output$combinedPlot <- renderPlotly({
    req(sim_data())
    df <- sim_data()
    
    p <- ggplot(df, aes(x = Spin, y = Total)) +
      geom_line(color = "#E74C3C") +
      labs(x = "Number of Spins", y = "Running Average Combined Profit") +
      theme_minimal(base_size = 14)
    
    ggplotly(p)
  })
  
  output$biasPlot = renderPlot({
    req(bias_data())
    df = bias_data() 
    df %>% 
      ggplot(aes(y=biased.value)) +
      geom_bar(fill='#db4d37')
  })
  
  output$unbiasPlot = renderPlot({
    req(bias_data())
    df = bias_data() 
    df %>% 
      ggplot(aes(y=unbiased.value)) +
      geom_bar(fill='#2a7fbf')
  })
  
}

shinyApp(ui, server)