# ============================================================
# Check Student Simulation Results for Coin Flip Lab
# ============================================================

# Load required packages
required_packages <- c("dplyr")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
library(dplyr)

# ------------------------------------------------------------
# Function to simulate coin flips
# ------------------------------------------------------------
simulate_flips <- function(seed, n_flips, n_runs, p_heads = 0.5) {
  set.seed(as.numeric(seed))
  
  flips <- matrix(
    rbinom(n_flips * n_runs, size = 1, prob = p_heads),
    nrow = n_flips, ncol = n_runs
  )
  
  probs <- apply(flips, 2, function(x) cumsum(x) / seq_along(x))
  df <- data.frame(
    flip = rep(1:n_flips, times = n_runs),
    prob = as.vector(probs),
    run  = rep(paste0("Run ", 1:n_runs), each = n_flips)
  )
  
  return(df)
}

# ------------------------------------------------------------
# 1. Estimated probability, odds in favor, and odds against
# ------------------------------------------------------------
check_estimates <- function(seed, p_heads = 0.5) {
  flips_list <- c(1000, 5000, 10000)
  results <- lapply(flips_list, function(n_flips) {
    df <- simulate_flips(seed, n_flips = n_flips, n_runs = 1, p_heads = p_heads)
    final_prob <- tail(df$prob, 1)
    odds_in_favor <- final_prob / (1 - final_prob)
    odds_against <- (1 - final_prob) / final_prob
    
    data.frame(
      n_flips = n_flips,
      est_prob = round(final_prob, 4),
      odds_in_favor = round(odds_in_favor, 4),
      odds_against = round(odds_against, 4)
    )
  })
  
  do.call(rbind, results)
}

# ------------------------------------------------------------
# 2. Mean and range for 1000 flips at 3, 5, and 10 runs
# ------------------------------------------------------------
check_runs_summary <- function(seed, p_heads = 0.5) {
  runs_list <- c(3, 5, 10)
  results <- lapply(runs_list, function(n_runs) {
    df <- simulate_flips(seed, n_flips = 1000, n_runs = n_runs, p_heads = p_heads)
    last_probs <- df %>%
      group_by(run) %>%
      summarise(final_prob = last(prob))
    
    mean_prob <- mean(last_probs$final_prob)
    range_prob <- diff(range(last_probs$final_prob))
    min_prob <- min(last_probs$final_prob)
    max_prob <- max(last_probs$final_prob)
    
    data.frame(
      n_runs = n_runs,
      mean_prob = round(mean_prob, 4),
      range_prob = round(range_prob, 4),
      min_prob = round(min_prob, 4),
      max_prob = round(max_prob, 4)
    )
  })
  
  do.call(rbind, results)
}

# ------------------------------------------------------------
# Example usage
# ------------------------------------------------------------
student_seed <- readline(prompt = 'Last Four Digits of Studnent ID: ') %>% 
  as.integer()

cat("\n=== 1. Probability, Odds in Favor, and Odds Against ===\n")
print(check_estimates(student_seed))

cat("\n=== 2. Mean and Range for 1000 flips (3, 5, 10 runs) ===\n")
print(check_runs_summary(student_seed))