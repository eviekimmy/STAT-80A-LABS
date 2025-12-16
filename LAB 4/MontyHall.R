# Initialize values
door.options = c('1','2','3')
winner = sample(x = door.options, size = 1)

# Prompt user to choose door
chosen.door = readline(prompt = 'Pick a Door: ')
while (!(chosen.door %in% door.options)) {
  chosen.door = readline(prompt = 'Not valid. Try again: ')
}

# Have Monty choose empty door to open
can.open = !(door.options %in% c(chosen.door, winner))
monty = sample(x = door.options[can.open], size = 1)
cat('Monty opened', monty, '\n')

# Prompt user to switch or stay
final.choice = readline(prompt = 'Switch ? (y/n): ')
while (!(final.choice %in% c('y','n'))) {
  final.choice = readline(prompt = 'Not valid. Try again: ')
}

winnings = ifelse(final.choice == 'y', 
                  winner != chosen.door, # switch from original choice
                  winner == chosen.door) # stay with original choice

