m <- 10^7
n <- 10
conf <- 0.7
supp <- 0.001

d <- matrix(sample(c(T, F), m * n, replace = TRUE),
            nrow = m,
            ncol = n)
colnames(d) <- letters[seq_len(n)]

system.time({
    rules <- dig_associations(d,
                              min_support = supp,
                              min_length = 0,
                              max_length = 4,
                              min_confidence = conf,
                              contingency_table = TRUE,
                              threads = 1)
})
