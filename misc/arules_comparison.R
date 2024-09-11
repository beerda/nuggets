library(arules)
library(nuggets)

set.seed(42344)

m <- 10^6
n <- 15
conf <- 0.5

testIt <- function(m, n) {
    d <- matrix(sample(c(T,F), m * n, replace=TRUE),
                nrow = m,
                ncol = n)
    colnames(d) <- letters[seq_len(n)]

    t1time <- 0
    t2time <- 0
    t3time <- 0
    reps <- 5
    for (x in 1:reps) {
        t1 <- system.time({
            fit <- apriori(d, parameter = list(minlen = 1,
                                               maxlen = 6,
                                               supp=0.001,
                                               conf = conf),
                           control = list(verbose = FALSE))
            rules1 <- DATAFRAME(fit)
        })

        t3 <- system.time({
            freq <- eclat(d, parameter = list(minlen = 1,
                                              maxlen = 6,
                                              supp=0.001),
                          control = list(verbose = FALSE))
            fit <- ruleInduction(freq, conf = conf)
            rules3 <- DATAFRAME(fit)
        })

        t2 <- system.time({
            rules2 <- dig_implications(d,
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
               eclat_count = nrow(rules3),
               nuggets_count = nrow(rules2))
}


#print(head(rules1))
#print(head(rules2))
#print(c(nrow(rules1), nrow(rules2)))

result <- data.frame()
for (i in 5:7) {
    for (j in c(5, 10, 15)) {
        result <- rbind(result, testIt(10^i, j))
        saveRDS(result, "comparison_result.rds")
        cat("\n---------------------------------------------------------------------\n")
        print(result)
    }
}
print(result)
