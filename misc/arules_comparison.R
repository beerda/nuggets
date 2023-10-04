library(arules)
library(nuggets)

set.seed(42344)

m <- 10^7
n <- 7

d <- matrix(sample(c(T,F), m * n, replace=TRUE),
            nrow = m,
            ncol = n)
colnames(d) <- letters[seq_len(n)]


system.time({
    fit <- apriori(d, parameter = list(minlen=1, supp=0.001, conf = 0.1))
    rules1 <- DATAFRAME(fit)
})


system.time({
    rules2 <- dig_implications(d, min_support = 0.02, min_confidence = 0.1, n_threads = 2)
})

print(c(nrow(rules1), nrow(rules2)))
