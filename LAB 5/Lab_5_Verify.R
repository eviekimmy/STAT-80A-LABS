library(tidyverse)

# Helper functions
shooter.roll = function() {
  sample(1:6, size = 2, replace = T) %>% sum()
}

second.phase = function(in.seed, point) {
  set.seed(seed = in.seed)
  rolls = c(shooter.roll())
  i = 1
  while(!(rolls[i] %in% c(7, point))) {
    i = i+1
    rolls[i] = shooter.roll()
  }
  
  win = rolls[i] != 7
  duration = length(rolls)
  
  list(win, duration)
}

# craps outputs
phases = function(global.seed) {
  set.seed(seed = global.seed)
  data.frame(point=rep(c(4,5,6,8,9,10), each=5000), 
             seeds=sample.int(n = 1e6, size = 30000, replace = F)) %>% 
    rowwise() %>% 
    mutate(outputs = list(second.phase(in.seed = seeds, point = point)),
           win = outputs[[1]],
           duration = outputs[[2]]) %>%
    select(-outputs) %>% ungroup() -> second.phase.df
  
  set.seed(global.seed + 5000)
  data.frame(point=replicate(n=5000, expr = shooter.roll())) %>% 
    count(point) %>% 
    mutate(phase.1 = n / sum(n)) -> first.phase.df
  
  list(first=first.phase.df, second=second.phase.df)
}

table1 = function(craps.outputs) {
  
  craps.outputs$second %>% 
    filter(point %in% c(4,5,6,8,9,10)) %>% 
    summarise(.by = c(point),
              average.streak = mean(duration))
  
}

# biased wheel output
wheel.sim = function(spins, bias.prob, global.seed) {
  set.seed(global.seed)
  data.frame(
    biased = rbinom(n = 1000, size = spins, prob = bias.prob),
    unbiased = rbinom(n = 1000, size = spins, prob = 1/38)
  ) %>% 
    summarise(threshold = qbinom(p = 0.95, size = spins, prob = 1/38), 
              prop.above.threshold = mean(biased > threshold),
              error.rate = 1-prop.above.threshold) %>% 
    pivot_longer(cols = everything(), names_to = 'Metrics', values_to = 'Value')
}


table2 = function(craps.outputs) {
  
  craps.outputs$second %>% 
    summarise(.by = c(point),
              phase.2 = mean(win)) %>% 
    full_join(craps.outputs$first, by='point') %>% 
    replace_na(replace = list(phase.2=1)) %>% 
    filter(point %in% 4:11) %>% 
    mutate(phase.1.and.win = phase.1 * phase.2) %>% 
    select(point, phase.1, phase.2, phase.1.and.win) %>% 
    summarise(total.prob = sum(round(phase.1.and.win, 3)))
  
}

run.sim = function() {
  global.seed = readline('Seed: ') %>% as.integer()
  bias.prob = readline('Bias: ') %>% as.numeric()
  spins = readline('Spins: ') %>% as.integer()
  
  craps.outputs = phases(global.seed)
  
  list(
    table1(craps.outputs),
    table2(craps.outputs),
    wheel.sim(spins = spins, bias.prob = bias.prob, global.seed = global.seed)
  )
  
}

run.sim()












