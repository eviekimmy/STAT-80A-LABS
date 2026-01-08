library(tidyverse)

run_lottery_summaries = \(seed) {

  # change these to be up to date with current lotto
  co_nums = c(4,15, 16, 22, 29, 31)
  ca_nums = c(2,5,8,17,39)
  ca_mega = 2

  set.seed(seed)
  co.draws = replicate(n = co_plays,
                      sum(sample(x = 1:40, size = 6) %in% co_nums))
  
  set.seed(seed)
  ca.draws = replicate(n = ca_plays, 
                       sum(sample(x = 1:47, size = 5) %in% ca_nums))
  mega = sample(x = 1:27, size = ca_plays, replace = T)

  list(
    data.frame(Matches = co.draws) %>% 
      summarize(
        First = sum(Matches == 6),
        Second = sum(Matches == 5),
        Third = sum(Matches == 4),
        Fourth = sum(Matches == 3),
      ),
    data.frame(Matches = ca.draws, Mega = mega) |> 
      summarize(
        First = sum(Matches == 5 & Mega == ca_mega),
        Second = sum(Matches == 5 & Mega != ca_mega),
        Third = sum(Matches == 4 & Mega == ca_mega),
      )
  )
}



# ---- Run script ----
# You can change the seed here:
input.seed = readline(prompt = 'Last 4 Digits of Student ID: ') |> as.integer()
co_plays = readline(prompt = 'Number of Plays Colorado: ') |> as.integer()
ca_plays = readline(prompt = 'Number of Plays California: ') |> as.integer()
run_lottery_summaries(seed = input.seed)





