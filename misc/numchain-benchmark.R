library(rbenchmark)
library(nuggets)

set.seed(1234)

m <- 10^7   # rows
n <- 7      # cols

d <- matrix(runif(m * n), nrow = m, ncol = n)
colnames(d) <- letters[seq_len(n)]

fun <- function(t_norm) {
    rules <- dig_implications(d,
                              min_support = 0.001,
                              min_confidence = 0.1,
                              t_norm = t_norm)
    return(rules)
}

print(nrow(fun("goedel")))
#print(nrow(fun("goguen")))
print(nrow(fun("lukas")))

res <- benchmark(goedel = expression(fun("goedel")),
                 #goguen = expression(fun("goguen")),
                 lukas = expression(fun("lukas")),
                 replications = (rep(1, 5)))

print(res)
saveRDS(res, "misc/VectorNumChain.rds")
#saveRDS(res, "misc/BitsetNumChain.rds")
#saveRDS(res, "misc/SimdVectorNumChain.rds")

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
