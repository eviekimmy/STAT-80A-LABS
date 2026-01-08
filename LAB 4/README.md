# Preparation

This lab makes use of modal dialogs to create a Monty Hall game. The lab also makes use of conditional probability. The visual used to calculate conditional probabilities is a tree diagram. It is recommended you give an example of how to calculate conditional probabilities using this diagram.  

To understand how the logic works, it may be easier to look at `MontyHall.R` first and then see how it is implemented into the server code block in `Lab_4.qmd`. If you are editing this lab and want to make a modal dialog game, I recommend scripting it in a separate R file and then add to the server code block. 

If you do make edits, ensure that Monty chooses *neither* the winning door *nor* the first choice. 


# Using Modal Dialogs for Labs

## [reactiveValues](https://shiny.posit.co/r/reference/shiny/0.11/reactivevalues.html)

The logic for the Monty Hall game is split across multiple `observeEvent` functions and other helper functions. Therefore, creative a `reactiveValues` object will allow for these values to be referenced and updated across multiple functions. It is easier if many of the values are set to `NULL`, and then updated once a user plays the game. 

## [observeEvent](https://shiny.posit.co/r/reference/shiny/0.11/observeevent.html)

These will be used for button inputs. In particular, for buttons defined in a modal dialog. 

## modalDialog

