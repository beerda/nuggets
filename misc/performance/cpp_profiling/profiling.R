library(nuggets)

#  sudo sysctl -w kernel.perf_event_paranoid=1
#  PKG_CXXFLAGS="-g -O2 -fno-omit-frame-pointer -fno-inline" R CMD INSTALL --preclean nuggets
#  export DEBUGINFOD_URLS=""
#  perf record -F 99 -e cycles:u -g --call-graph fp -o perf.data -- Rscript ./nuggets/misc/performance/cpp_profiling/profiling.R
#  perf report


set.seed(42344)

m <- 10^6
n <- 20
conf <- 0.3

d <- matrix(sample(c(T,F), m * n, replace=TRUE), nrow = m, ncol = n)
colnames(d) <- letters[seq_len(n)]

rules2 <- dig_associations(d,
                           min_support = 0.001,
                           min_length = 0,
                           max_length = 5,
                           min_confidence = conf)


Sys.sleep(2)
