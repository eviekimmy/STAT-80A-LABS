library(tidyverse)

# card initialization
spade_suit <- "\u2660"
club_suit <- "\u2663"
heart_suit <- "\u2665"
diamond_suit <- "\u2666"
card.value = c(2:10, 'J','Q','K','A')
shoe = rep(card.value, 8*4)

# code for player turn (modal dialog in lab)
player.turn = function(player, dealer, shuffle) {
  
  # print out hands (text output)
  cat('dealer: ',dealer[1,'hand'], '\n')
  cat('you: ', player$hand, '\n')
  
  # conditions that stop turn
  not.bust = min(sum(player$value.1), sum(player$value.11)) < 21
  hit = sum(player$hit) == nrow(player)
  
  # continue until player stays or busts
  while(not.bust & hit) {
    # will become select input
    action = readline('Hit? (Hit/Stay): ')
    while(!(action %in% c('Hit','Stay'))) {action = readline('Try again: ')}
    
    # add card to hand and remove from shuffle
    if(action == 'Hit') {
      player = bind_rows(player, shuffle[1,] %>% mutate(hit=T))
      shuffle = shuffle[-c(1),]
    } else {
    # condition allows for hit to be false
      player[nrow(player),"hit"] = F
    }
    # update conditions that stop turn
    not.bust = min(sum(player$value.1), sum(player$value.11)) < 21
    hit = sum(player$hit) == nrow(player)
    
    # display current hand (text output)
    cat('you: ', player$hand, '\n')
    
  }
  
  list(player=player, shuffle=shuffle)
  
}

# code for dealer turn
dealer.turn = function(dealer, shuffle) {
  
  # display hand
  cat('dealer: ',dealer[,'hand'], '\n')
  
  # dealer stops when hand is over 17
  keep.going = 
    ( sum(dealer$value.1) < 17 ) & 
    ( sum(dealer$value.11) < 17 )
  
  while(keep.going) {
    
    # add to hand and remove from shuffle
    dealer = bind_rows(dealer, shuffle[1,] %>% mutate(hit=T))
    shuffle = shuffle[-c(1),]
    keep.going = min(sum(dealer$value.1), sum(dealer$value.11)) < 17

    cat('dealer: ',dealer[,'hand'], '\n')
    
  }
  
  list(dealer=dealer, shuffle=shuffle)
}

# play one round of blackjack (modal dialog)
play.round = function(shuffle) {
  
  # initialize count and starting hands; remove cards in play from shuffle
  count = cumsum(shuffle$count)
  dealer = shuffle[c(1,3),]
  player = shuffle[c(2,4),] %>% mutate(hit=T)
  shuffle = shuffle[-c(1:4),]
  
  # if neither player or dealer have blackjack
  if(sum(dealer$value.11) < 21 & sum(player$value.11) < 21) {
    
    player.outcome = player.turn(player, dealer, shuffle)
    # shuffle updated so dealer does not take cards from player hand
    dealer.outcome = dealer.turn(dealer, player.outcome$shuffle)
  
  # if someone has blackjack
  } else {
    
    cat('dealer: ',dealer[,'hand'], '\n')
    cat('you: ', player$hand, '\n')
    player.outcome = list(player=player, shuffle=shuffle)
    dealer.outcome = list(dealer=dealer, shuffle=shuffle)
    
  }
  
  # used to determine current count after round
  cards.played = nrow(player.outcome$player) + nrow(dealer.outcome$dealer)
  
  # results to return
  list(player.outcome=player.outcome$player %>% 
         summarise(total.1 = sum(value.1), 
                   total.11 = sum(value.11)), 
       dealer=dealer.outcome$dealer %>% 
         summarise(total.1 = sum(value.1), 
                   total.11 = sum(value.11)), 
       count=count[cards.played],
       shuffle=dealer.outcome$shuffle)
  
}

# entire blackjack program (modal dialog)
black.jack = function(card.value, shoe=8) {
  
  # create shuffle
  shuffle = data.frame(hand = sample(rep(card.value, 4*shoe))) %>% 
    mutate(value.1 = case_when(hand %in% c('J','Q','K')~10,
                               hand =='A'~1,
                               .default = as.integer(hand)),
           value.11 = case_when(hand %in% c('J','Q','K')~10,
                                hand =='A'~11,
                                .default = as.integer(hand)),
           count = case_when(hand %in% paste0(2:6)~1,
                             hand %in% c('10','J','Q','K','A')~-1,
                             .default = 0))
  
  rounds = list(play.round(shuffle))
  play = as.logical(readline('Play Again? (T/F): '))
  while(is.na(play)) {play = as.logical(readline('Try again: '))}
  i=1
  while(play) {
    
    rounds = append(rounds, list(play.round(rounds[[i]]$shuffle)))
    play = as.logical(readline('Play Again? (T/F): '))
    while(is.na(play)) {play = as.logical(readline('Try again: '))}
    i = i+1
    
  }
  
  list(rounds=rounds)
}

# reactive command for "play game" button
results = black.jack(card.value=card.value, shoe=8)

# verify blackjack condition is met
# play.round(data.frame(hand=c('A','2','J','3'), 
#                       value.1 = c(1,2,10,3), value.11 = c(11,2,10,3),
#                       count=c(-1,1,-1,1)))
# a = play.round(data.frame(hand=c('9','A','3','J'),
#                       value.1 = c(9,1,3,10), value.11 = c(9,11,3,10),
#                       count=c(0,1,-1,1)))
