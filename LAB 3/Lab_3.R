library(shiny)
library(dplyr)
library(markdown)

# ---- Helper functions ----
simulate_california <- function(user_nums, special_num, n_sims = 1e4, 
                                seed = 123, progress = NULL) {
  set.seed(seed)
  
  batch_size <- 1000
  n_batches <- ceiling(n_sims / batch_size)
  
  main_matches <- numeric(n_sims)
  special_matches <- logical(n_sims)
  
  for (i in seq_len(n_batches)) {
    start <- (i - 1) * batch_size + 1
    end <- min(i * batch_size, n_sims)
    batch_n <- end - start + 1
    
    draws_main <- replicate(batch_n, sort(sample(1:47, 5)))
    draws_special <- sample(1:27, batch_n, replace = TRUE)
    
    main_matches[start:end] <- apply(draws_main, 2, function(x) sum(x %in% user_nums))
    special_matches[start:end] <- draws_special == special_num
    
    if (!is.null(progress)) incProgress(1 / n_batches)
  }
  
  tibble(main_matches, special_matches)
}

simulate_colorado <- function(user_nums, n_sims = 1e4, seed = 123, progress = NULL) {
  set.seed(seed)
  
  batch_size <- 1000
  n_batches <- ceiling(n_sims / batch_size)
  
  matches <- numeric(n_sims)
  
  for (i in seq_len(n_batches)) {
    start <- (i - 1) * batch_size + 1
    end <- min(i * batch_size, n_sims)
    batch_n <- end - start + 1
    
    draws <- replicate(batch_n, sort(sample(1:40, 6)))
    matches[start:end] <- apply(draws, 2, function(x) sum(x %in% user_nums))
    
    if (!is.null(progress)) incProgress(1 / n_batches)
  }
  
  tibble(matches)
}

# ---- Prize summaries ----
summarize_california <- function(sim_df) {
  n1 <- sum(sim_df$main_matches == 5 & sim_df$special_matches)
  n2 <- sum(sim_df$main_matches == 5 & !sim_df$special_matches)
  n3 <- sum(sim_df$main_matches == 4 & sim_df$special_matches)
  
  tibble(
    Prize = c("1st (5 + special)", "2nd (5 only)", "3rd (4 + special)"),
    Count = c(n1, n2, n3)
  )
}

summarize_colorado <- function(sim_df) {
  n1 <- sum(sim_df$matches == 6)
  n2 <- sum(sim_df$matches == 5)
  n3 <- sum(sim_df$matches == 4)
  n4 <- sum(sim_df$matches == 3)
  
  tibble(
    Prize = c("1st (6 of 6)", "2nd (5 of 6)", "3rd (4 of 6)", '4th (3 of 6)'),
    Count = c(n1, n2, n3, n4)
  )
}

# ---- UI ----
ui <- fluidPage(
  titlePanel("Lottery Simulator: Colorado vs California"),
  sidebarLayout(
    sidebarPanel(
      h4("Instructions"),
      # Scrollable instructions box
      div(
        style = "max-height: 300px; overflow-y: auto; padding-right: 10px;",
        includeMarkdown("instructions.md")
      ),
      hr(),
      numericInput("seed_global", "Random Seed:", 123, min = 1),
      numericInput("n_sims", "Number of simulations:", value = 10000, min = 1000, step = 1000),
      helpText("Adjust the number of simulations for speed vs accuracy."),
      width = 4
    ),
    mainPanel(
      tabsetPanel(
        # --- Colorado first ---
        tabPanel("Colorado Lotto",
                 br(),
                 fluidRow(
                   column(5,
                          selectizeInput("co_nums", "Choose 6 numbers (1–42):",
                                         choices = 1:40, multiple = TRUE)
                   ),
                   column(7,
                          h4("Colorado Lottery Results"),
                          tableOutput("table_co")
                   )
                 )
        ),
        # --- California second ---
        tabPanel("California Lotto",
                 br(),
                 fluidRow(
                   column(5,
                          selectizeInput("cal_nums", "Choose 5 numbers (1–47):",
                                         choices = 1:47, multiple = TRUE),
                          numericInput("cal_special", "Special Number (1–27):",
                                       value = 1, min = 1, max = 27)
                   ),
                   column(7,
                          h4("California Lottery Results"),
                          tableOutput("table_cal")
                   )
                 )
        )
      )
    )
  )
)

# ---- SERVER ----
server <- function(input, output, session) {
  
  # ---- Reactive simulations ----
  
  co_results <- reactive({
    req(input$co_nums)
    if (length(input$co_nums) != 6) return(NULL)
    
    withProgress(message = "Running Colorado simulation...", {
      simulate_colorado(
        user_nums = as.numeric(input$co_nums),
        n_sims = input$n_sims,
        seed = input$seed_global,
        progress = shiny::getDefaultReactiveDomain()$progress
      )
    })
  })
  
  output$table_co <- renderTable({
    req(co_results())
    summarize_colorado(co_results())
  })
  
  cal_results <- reactive({
    req(input$cal_nums, input$cal_special)
    if (length(input$cal_nums) != 5) return(NULL)
    
    withProgress(message = "Running California simulation...", {
      simulate_california(
        user_nums = as.numeric(input$cal_nums),
        special_num = input$cal_special,
        n_sims = input$n_sims,
        seed = input$seed_global,
        progress = shiny::getDefaultReactiveDomain()$progress
      )
    })
  })
  
  output$table_cal <- renderTable({
    req(cal_results())
    summarize_california(cal_results())
  })
}

shinyApp(ui, server)