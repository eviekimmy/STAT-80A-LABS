library(tidyverse)

shooter.roll = function() {
  sample(1:6, size = 2, replace = T) %>% sum()
}

second.phase = function(in.seed, point = 4) {
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

global.seed = 1234
set.seed(global.seed)
data.frame(point=rep(c(4,5,6,8,9,10), each=1000), 
           seeds=sample.int(n = 1e6, size = 6000, replace = F)) %>% 
  rowwise() %>% 
  mutate(outputs = list(second.phase(in.seed = seeds, point = point)),
         win = outputs[[1]],
         duration = outputs[[2]]) %>%
  select(-outputs) %>% ungroup() -> second.phase.df

set.seed(global.seed + 5000)
data.frame(point=replicate(n=1000, expr = shooter.roll())) %>% 
  count(point) %>% 
  mutate(prop.occurs.phase1 = n / sum(n)) -> first.phase.df

second.phase.df %>% 
  summarise(.by = c(point), 
            prop.win.phase2 = mean(win)) %>% 
  full_join(first.phase.df, by='point') %>% 
  replace_na(replace = list(prop.win.phase2=1)) %>% 
  select(point, prop.occurs.phase1, prop.win.phase2) %>% 
  filter(point %in% 4:11)
