library(tidyverse)

plan(multisession, workers = parallel::detectCores() - 1)


# card initialization
spade_suit <- "\u2660"
club_suit <- "\u2663"
heart_suit <- "\u2665"
diamond_suit <- "\u2666"
suits = c(spade_suit, club_suit, heart_suit, diamond_suit)
ranks = c('A',2:10, 'J','Q','K','A')
values = c('2'=2, '3'=3, '4'=4, '5'=5, '6'=6, '7'=7, '8'=8, '9'=9, 
           '10'=10, 'J'=11, 'Q'=12, 'K'=13, 'A'=14)

deck = str_c(rep(ranks[2:14], each=4), rep(suits, 13)) 

straight = list()
straight.flush = list()
for (i in 0:9) {
  straight = append(straight, list(str_c(ranks[1:5+i])))
  for (j in suits) {
    straight.flush = append(straight.flush, list(str_c(ranks[1:5+i], j)))
  }
}



highest.hand = function(hand) {
  
  hand.df = data.frame(hand) %>% 
    mutate(rank = str_extract(hand, "^[0-9JQKA]+"),
           suit = str_extract(hand, "[♠♣♥♦]$"),
           value = values[rank]) %>% 
    arrange(rank)
  
  suit.counts = hand.df %>% summarise(.by = suit, count=n())
  rank.counts = hand.df %>% summarise(.by = c(rank, value), count=n())
  
  # first check royal flush or straight flush
  for (i in 1:40) {
    is.straight.flush = sum(hand %in% straight.flush[[i]]) == 5
    if(is.straight.flush) {break}
  }
  
  # now, check straight
  for (j in 1:5) {
    is.straight = sum(hand.df$rank %in% straight[[j]]) == 5
    if(is.straight) {break}
  }
  
  # check flush
  is.flush = 5 %in% suit.counts$count
  
  # check quantities that rely on rank
  desc.count.rank = sort(rank.counts$count, decreasing = T)[1:2]
  is.full.house = length(rank.counts$count[rank.counts$count == 3]) > 2 | 
    (
      length(rank.counts$count[rank.counts$count == 3]) > 0 & 
        length(rank.counts$count[rank.counts$count == 2]) > 0
    )
  # is.four.kind = rank.counts$count[rank.counts$count == 4] %>% length() == 1
  is.four.kind = 4 %in% rank.counts$count
  is.three.kind = 3 %in% rank.counts$count
  is.two.pair = rank.counts$count[rank.counts$count == 2] %>% length() >= 2
  is.pair = rank.counts$count[rank.counts$count == 2] %>% length() == 1
  
  print(rank.counts$count[rank.counts$count %in% 2:3])
  
  # determine highest hand and give a score for evaluation
  # decimals for when two opponents have same hand
  if (is.straight.flush & i %in% 37:40) {
    highest.hand = 'royal flush'
    score = 10
  } else if (is.straight.flush) {
    highest.hand = 'straight flush'
    score = 9 + (i %/% 4)/10
  } else if (is.four.kind) {
    four.rank = rank.counts$rank[rank.counts$count == 4]
    highest.hand = 'four of a kind'
    score = 8 + values[four.rank] / 100
  } else if (is.full.house) {
    full.house.rank = rank.counts$rank[rank.counts$count == 3]
    highest.hand = 'full house'
    score = 7 + max(values[full.house.rank]) / 100
  } else if (is.flush) {
    highest.hand = 'flush'
    score = 6
  } else if (is.straight) {
    highest.hand = 'straight'
    score = 5 + j/100
  } else if (is.three.kind) {
    three.rank = rank.counts$rank[rank.counts$count == 3]
    highest.hand = 'three of a kind'
    score = 4 + values[three.rank] %>% max() / 100
  } else if (is.two.pair) {
    two.pair.ranks = rank.counts$rank[rank.counts$count == 2]
    highest.hand = 'two pair'
    score = 3 + values[two.pair.ranks] %>% max() / 100
  } else if (is.pair) {
    pair.rank = rank.counts$rank[rank.counts$count == 2]
    highest.hand = 'pair'
    score = 2 + values[pair.rank] / 100
  } else {
    highest.hand = 'high card'
    score = 1 + values[hand.df$rank] %>% max() / 100
  }
  
  list(highest.hand=highest.hand, score=score)
}

# highest.hand(hand)

estimate.wins = function(you) {
  
  opponent = sample(deck[!(deck %in% you)], 2)
  community = sample(deck[!(deck %in% c(you, opponent))], 3)
  
  highest.you = highest.hand(c(you, community))
  highest.opponent = highest.hand(c(opponent, community))
  
  outcome = case_when(highest.you$score > highest.opponent$score ~ 'win',
            highest.you$score < highest.opponent$score ~ 'lose',
            TRUE~'tie')
  
  list(you=highest.you$highest.hand, 
       opponent=highest.opponent$highest.hand, 
       outcome=outcome)
  
}

# replicate(n = 1000, expr = estimate.wins(c("2♠", "2♣")))

highest.hand(c("K♣",  "K♥",  "K♦" , "10♣","10♥" ,"10♦" ,"3♦" ))
highest.hand(c("K♣",  "K♥",  "K♦" , "10♣","J♥" ,"10♦" ,"3♦" ))
highest.hand(c("K♣",  "K♥",  "K♦" , "K♦","J♥" ,"10♦" ,"3♦" ))
highest.hand(c("K♣",  "K♥",  "2♥" , "2♦","J♥" ,"10♦" ,"3♦" ))

# your test hands (same as before)
test_hands = list(
  royal_flush = c("A♠","K♠","Q♠","J♠","10♠","3♦","2♣"),
  straight_flush = c("9♥","8♥","7♥","6♥","5♥","2♦","K♣"),
  four_kind = c("Q♦","Q♠","Q♥","Q♣","7♣","4♣","2♦"),
  full_house = c("10♣","10♠","10♥","K♦","K♠","3♣","4♦"),
  flush = c("2♦","6♦","9♦","J♦","Q♦","3♠","5♥"),
  straight = c("5♠","6♣","7♦","8♥","9♣","K♣","2♦"),
  three_kind = c("A♣","A♠","A♦","9♥","5♠","2♣","J♦"),
  two_pair = c("K♣","K♦","8♠","8♥","3♣","2♦","5♠"),
  one_pair = c("7♠","7♣","Q♦","9♥","5♠","3♦","2♣"),
  high_card = c("A♠","J♦","8♣","6♥","3♣","2♦","4♦")
)

# evaluate all hands
results = map(test_hands, highest.hand)

results

sim.table = future_map(1:5000, ~ estimate.wins(c("2♠", "2♣")), .progress = T) %>% 
  bind_rows()

sim.table %>% 
  summarise(.by = c(you), 
            win=mean(outcome=='win'), 
            lose=mean(outcome=='lose'),
            tie=mean(outcome=='tie'))

