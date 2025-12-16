library(tidyverse)

bias.prob = 0.033 # slider value
spins = 5000 # slider value

wheel.sim = data.frame(
  biased = rbinom(n = 1000, size = spins, prob = bias.prob),
  unbiased = rbinom(n = 1000, size = spins, prob = 1/38)
)


wheel.sim %>% 
  summarise(bias = bias.prob,
            spins = spins,
            threshold = qbinom(p = 0.95, size = spins, prob = 1/38), 
            prop = mean(biased > threshold),
            error.rate = 1-prop) 

wheel.sim %>% 
  pivot_longer(cols = c(biased, unbiased), 
               names_to = 'wheel', values_to = 'frequency') %>% 
  ggplot(aes(x=frequency, fill=wheel)) +
  geom_histogram(binwidth = 1, position = 'identity', alpha=0.5)
