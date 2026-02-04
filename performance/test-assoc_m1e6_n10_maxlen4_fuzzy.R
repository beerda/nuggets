m <- 10^6
n <- 10
conf <- 0.7
supp <- 0.001

d <- matrix(runif(m * n),
            nrow = m,
            ncol = n)
colnames(d) <- letters[seq_len(n)]

# replications comes from run.R
res <- benchmark(replications = replications, {
    rules <- dig_associations(d,
                              min_support = supp,
                              min_length = 0,
                              max_length = 4,
                              min_confidence = conf,
                              contingency_table = TRUE,
                              threads = 1)
})

res
