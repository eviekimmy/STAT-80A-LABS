library(tidymodels)
run = \() {

  student_seed <- readline(prompt = 'Last Four Digits of Studnent ID: ') %>% 
  as.integer()
  bias <- readline(prompt = 'Bias Level: ') %>% 
    as.numeric()
  n <- readline(prompt = 'Number of Spins: ') %>% 
    as.integer()

  number <- as.character(0:37)
  number[38] <- '00'

  biased.probs <- rep((1 - bias) / 35, 38)
  biased.probs[c(3, 5, 22)] <- rep(bias, 3)

  set.seed(NULL)
  unbiased <- sample(x = number, size = n, replace = TRUE)

  set.seed(student_seed)
  biased <- sample(x = number, size = n, prob = biased.probs, replace = TRUE)

  biased.value = factor(biased, levels = number)
  biased.value |> 
    table() |> 
    chisq.test() |> 
    tidy()
  
}

run()