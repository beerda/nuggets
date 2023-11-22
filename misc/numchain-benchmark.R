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
# - VectorNumChain<GOEDEL>:
#         user  system elapsed
#       18.226  10.253  28.474
# - BitsetNumChain<GOEDEL>:
#         user  system elapsed
#        4.296   0.551   4.846
#
# - VectorNumChain<GOGUEN>:
#         user  system elapsed
#       18.573  10.475  28.873
# - SimdNumChain<GOGUEN>:
#         user  system elapsed
#        6.593  10.501  17.005
