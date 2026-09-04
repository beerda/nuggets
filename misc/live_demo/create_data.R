library(nuggets)
library(dplyr)

dataset <- partition(iris, .breaks = 3)
rules <- dig_associations(dataset) |>
    add_interest() |>
    arrange(desc(confidence))

saveRDS(list(dataset = dataset, rules = rules),
        file = "iris_data.rds")
