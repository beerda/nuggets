library(nuggets)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(DT)
library(htmltools)
library(htmlwidgets)
library(jsonlite)

data <- readRDS("iris_data.rds")

explore(data$rules, data = data$dataset)

# shinyApp(ui = ui, server = server)
