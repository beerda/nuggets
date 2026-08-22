library(nuggets)

dataset <- partition(iris, .breaks = 3)
rules <- dig_associations(dataset)

saveRDS(list(dataset = dataset, rules = rules),
        file = "iris_data.rds")
