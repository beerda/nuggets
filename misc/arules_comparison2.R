library(arules)
library(nuggets)

set.seed(42344)

m <- 10^7
n <- 15
conf <- 0.5

f <- function(condition, support) {
    list(cond = format_condition(names(condition)),
         supp = support)
}

testIt <- function(m, n) {
    d <- matrix(sample(c(T,F), m * n, replace=TRUE),
                nrow = m,
                ncol = n)
    colnames(d) <- letters[seq_len(n)]
    colnames(d) <- as.character(seq_len(n))

    t1time <- 0
    t2time <- 0
    t3time <- 0
    reps <- 2
    for (x in 1:reps) {
        t3 <- system.time({
            freq <- eclat(d, parameter = list(minlen = 1,
                                              maxlen = 5,
                                              supp=0.001),
                          control = list(sparse=m,
                                         tree=FALSE,
                                         sort=0))
            rules3 <- DATAFRAME(freq)
        })

        t2 <- system.time({
            rules2 <- dig(d,
                          f = f,
                          min_support = 0.001,
                          min_length = 1,
                          max_length = 5)
        })

        t2time <- t2time + t2["elapsed"]
        t3time <- t3time + t3["elapsed"]
    }

    data.frame(nrow = m,
               ncol = n,
               eclat_time = t3time / reps,
               nuggets_time = t2time / reps)
}


#print(head(rules1))
#print(head(rules2))
#print(c(nrow(rules1), nrow(rules2)))

result <- data.frame()
for (i in 5:7) {
    for (j in 10:15) {
        result <- rbind(result, testIt(10^i, j))
        saveRDS(result, "comparison_result2.rds")
    }
}
print(result)

# **************************************************
# konverze arules transakci na matici:
#
# data("Groceries")
# as(Groceries, "matrix")
# **************************************************
