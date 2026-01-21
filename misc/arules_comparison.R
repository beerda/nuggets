library(tidyverse)
library(arules)
library(nuggets)

set.seed(42344)

m <- 10^6
n <- 25
conf <- 0.5

testIt <- function(m, n) {
    d <- matrix(sample(c(T,F), m * n, replace=TRUE),
                nrow = m,
                ncol = n)
    colnames(d) <- letters[seq_len(n)]

    t1time <- 0
    t2time <- 0
    t3time <- 0
    reps <- 1
    for (x in 1:reps) {
        t1 <- system.time({
            fit <- apriori(d, parameter = list(minlen = 1,
                                               maxlen = 6,
                                               supp = 0.001,
                                               maxtime = 0,
                                               target = "frequent itemsets"),
                           control = list(verbose = FALSE))
            rules1 <- DATAFRAME(fit)
        })

        t3 <- system.time({
            rules3 <- eclat(d, parameter = list(minlen = 1,
                                              maxlen = 6,
                                              target = "frequent itemsets",
                                              supp=0.001),
                          control = list(verbose = FALSE))
            rules3 <- ruleInduction(rules3, conf = conf)
            rules3 <- DATAFRAME(rules3)
        })

        t2 <- system.time({
            #f <- function(condition) list(condition = format_condition(names(condition)))
            #rules2 <- dig(d,
                          #f = f,
                          #min_support = 0.001,
                          #min_length = 1,
                          #max_length = 6,
                          #min_focus_support = 0.001)
            rules2 <- dig_associations(d,
                                       min_support = 0.001,
                                       min_length = 0,
                                       max_length = 5,
                                       min_confidence = conf)
        })

        t1time <- t1time + t1["elapsed"]
        t2time <- t2time + t2["elapsed"]
        t3time <- t3time + t3["elapsed"]
    }

    data.frame(nrow = m,
               ncol = n,
               apriori_time = t1time / reps,
               eclat_time = t3time / reps,
               nuggets_time = t2time / reps,
               apriori_count = nrow(rules1),
               eclat_count = length(rules3),
               nuggets_count = length(rules2))
}


#print(head(rules1))
#print(head(rules2))
#print(c(nrow(rules1), nrow(rules2)))

result <- NULL
#for (i in 4:7) {
for (i in 6) {
    #for (j in c(5, 10, 15, 20, 25)) {
    for (j in c(20, 25)) {
        result <- rbind(result, testIt(10^i, j))
        saveRDS(result, "comparison_result-2025-06-06.rds")
    }
    cat("\n---------------------------------------------------------------------\n")
    print(result)
}
print(result)

longResult <- result |>
    pivot_longer(cols = c("apriori_time", "eclat_time", "nuggets_time"),
             names_to = "method",
             values_to = "time")  |>
    mutate(method = dplyr::recode(method,
                     "apriori_time" = "apriori",
                     "eclat_time" = "eclat",
                     "nuggets_time" = "nuggets"),
           method = factor(method, levels = c("nuggets", "apriori", "eclat")))

ggplot(longResult) +
    aes(x = nrow, y = time, color = method) +
    geom_line() +
    scale_x_log10() +
    scale_y_log10() +
    facet_wrap(~ncol) +
    labs(title = "Comparison of apriori, eclat and nuggets",
         x = "Number of rows",
         y = "Time (seconds)",
         color = "Method") +
    theme_minimal()

ggplot(longResult) +
    aes(x = ncol, y = time, color = method) +
    geom_line() +
    scale_y_log10() +
    facet_wrap(~nrow)

fit <- lm(log(time) ~ log(nrow) + ncol + method, data = longResult)
summary(fit)
