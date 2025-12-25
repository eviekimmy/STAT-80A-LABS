# UCSC STAT 80A Labs

## Please Read (For Teaching Assistants)

This repository contains shiny dashboards used for STAT 80A Labs in Fall 2025. This is for Teaching Assistants to use as a starting point when making labs for students. It is recommended that you go over the instructions and test each lab to ensure everything is working properly and instructions are clear. It is also important to know that the pacing of the course may differ slightly from quarter to quarter, so ensure that the material used for that week is consistent with what students have learned up to that point. Solutions will be provided for each lab in the readme's. Since some of the answers require knowing the output for specific seeds, supplementary scripts are included that should summarize their specific outputs.

## Getting Students Set Up

Students will go to [this site](https://posit.co/download/rstudio-desktop/) to install ***BOTH*** R and RStudio to run the labs. After each download, they will need to double click each file to finish the install on their computer. After students have successfully downloaded both items, show students how to download the .qmd file and render it in RStudio. Common issues from students were

- Installing R but not RStudio (or installing RStudio but not R)
- Attempting to run the lab in R instead of RStudio
- Issues with rendering because packages were not installed. (This will come up throughout the quarter as later labs use packages that have not been downloaded yet. Usually, there is a prompt for them at the top of the RStudio IDE to install any packages that they have not used yet).

It should be noted that this will take students most or all of the lab time to do. This is why Lab 1 is very short. 

## Lab Construction Basics

### YAML and Contexts

The YAML at the top of the .qmd document should have the following content:

```
---
title: "Title of Lab"
format: 
  dashboard:
    orientation: rows/columns (rows is default)
server: shiny (required)
---
```

In addition, you will need to include a setup code chunk, otherwise the document won't render

```
#| context: setup
```

Typically, this is where I load any libraries needed to run the lab, such as `tidyverse`, `plotly`, or `pracma`. Note that you ***DO NOT*** need to load `shiny`, as that is handled in the yaml. 

### Markdown/UI
Markdown is used to create the UI components. A single header # defines a page, while a level 2 ## defines a ui card. The level 3 heading ### defines components. The arrangement of these components is dependent on the *orientation* defined in the yaml. For example, if *orientation* is rows, then each ## will create a new row and each ### will create a new column within that row. If *orientation* is columns, then each ## will create a new column and each ### will create a new row within that column. Splitting UI elements into code blocks will also arrange subcomponents in a similar way. You can find more details in the [additonal resources](#additional-resources) section of the README, or by playing around with some of the .qmd files.

You can also add curly braces to adjust what kind of component you want. For example, the instructions tab is created by adding a level 1 header # and adding `{.sidebar}`. Rather than making the instructions its own page, this allows students to have the instructions visible at all times on the side while completing the lab. Another example is in lab 8, where a second level header includes `{.tabset}`. This allows for students to switch from multiple UI components so the lab is less cluttered.

Most labs have the following components:

- Side bar with the instructions (typically where the seed input is located).
- One or two pages separated by # for different parts of the lab
- Control inputs at the top of the page (numeric input, selecize input, sliders, etc.)
- Plot/table output in the lower portion of the page

### Server

In order for shiny to know how to update the tables and plots when inputs change, you need to create a server code chunk

```
#| context: server
```

A workflow that is recommended is to first sketch out a version of the lab in an r script (focusing on console inputs and outputs). Then, you can transfer your code to your server code chunk and make the necessary adjustments. These are usually pasted within a `reactive` expression:

```
#| context: server

simulation = reactive({
    your code here
})
```

Which will then be referenced when creating an output:

```
output$exmple.table = renderTable({
    req(simulation())

    simulation()
})
```

Any inputs created in your UI portion will get an ID, which you reference in your server code by using `input$input_ID`. Any plot or table outputs are handled by `output$output_ID = renderTable/renderPlot/renderPlotly/etc({})`. You can also specify different controls for the output. For example, for `renderTable`, you can control to what precision numbers are rounded to, as well as whether to display row or column names. 

When labs use a model dialog, other expressions are used like `observeEvent`, `reactiveValues`, and `show/removeModal`. These will be discussed further in labs that use these pop ups for games (see Labs 4 and 6).

## Additional Resources

You may find the following resources helpful for updating and creating labs:

1. [An example document of how to construct shiny dashboards with quarto](https://quarto.org/docs/dashboards/interactivity/shiny-r.html)
1. [Shiny Compoments you can use](https://shiny.posit.co/r/components/)
1. [How to Layout Dashboard Components](https://quarto.org/docs/dashboards/layout.html)
1. [Shinylive](https://github.com/quarto-ext/shinylive), which allows you to run shiny apps on a static website. It works by running the shiny backend in the browser using WebAssmebly (Wasm). However, it would require rewriting the labs to align with shinylive-r code blocks and may be slow depending on how much processing is needed for the simulations.