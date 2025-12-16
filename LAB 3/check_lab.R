# lottery_summary.R
# -----------------
# This script uses the same helper functions as your Shiny app to simulate
# Colorado and California lotteries for different numbers of simulations
# and summarize the results.

library(dplyr)
library(tibble)

# ---- Helper functions ----
simulate_california <- function(user_nums, special_num, n_sims = 1e4, seed = 123) {
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
  }
  
  tibble(main_matches, special_matches)
}

simulate_colorado <- function(user_nums, n_sims = 1e4, seed = 123) {
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
    Prize = c("1st (6 of 6)", "2nd (5 of 6)", "3rd (4 of 6)", "4th (3 of 6)"),
    Count = c(n1, n2, n3, n4)
  )
}

# ---- Batch simulation script ----
run_lottery_summaries <- function(seed = 123) {
  sim_sizes <- c(1e4, 1e5, 1e6)
  
  # Example user selections (you can edit these)
  co_nums <- c(4, 8, 15, 16, 23, 42)
  cal_nums <- c(4, 8, 15, 16, 23)
  cal_special <- 2
  
  cat("Running simulations with seed =", seed, "\n\n")
  
  # Colorado results
  co_results <- lapply(sim_sizes, function(n) {
    print(seed)
    sim_df <- simulate_colorado(user_nums = co_nums, n_sims = n, seed = seed)
    summary_tbl <- summarize_colorado(sim_df)
    summary_tbl$Simulations <- n
    summary_tbl
  }) %>%
    bind_rows() %>%
    select(Simulations, everything())  %>% 
    pivot_wider(names_from = Simulations, values_from = Count, id_cols = Prize)
  
  cat("Colorado Lottery Results:\n")
  print(co_results)
  cat("\n")
  
  # California results
  cal_results <- lapply(sim_sizes, function(n) {
    print(seed)
    sim_df <- simulate_california(user_nums = cal_nums, special_num = cal_special,
                                  n_sims = n, seed = seed)
    summary_tbl <- summarize_california(sim_df)
    summary_tbl$Simulations <- n
    summary_tbl
  }) %>%
    bind_rows() %>%
    select(Simulations, everything()) %>% 
    pivot_wider(names_from = Simulations, values_from = Count, id_cols = Prize)
  
  cat("California Lottery Results:\n")
  print(cal_results)
  cat("\n")
  
  list(Colorado = co_results, California = cal_results)
}

# ---- Run script ----
# You can change the seed here:
input.seed = readline(prompt = 'Last 4 Digits of Student ID: ')
results <- run_lottery_summaries(seed = input.seed)





