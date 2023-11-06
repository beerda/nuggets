library(nuggets)

set.seed(1234)

m <- 10^7   # rows
n <- 7      # cols

d <- matrix(runif(m * n), nrow = m, ncol = n)
colnames(d) <- letters[seq_len(n)]

system.time({
    rules <- dig_implications(d, min_support = 0.001, min_confidence = 0.1, n_threads = 2)
})


print(head(rules))
print(nrow(rules))

# Results:
#
# - VectorNumChain<GODEL>:
#         user  system elapsed
#       21.451  19.662  41.100
#
# - BitsetNumChain<GODEL>:
#         user  system elapsed
#        3.828   0.486   4.312
