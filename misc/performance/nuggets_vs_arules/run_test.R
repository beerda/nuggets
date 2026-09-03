library(tidyverse)
library(microbenchmark)
library(arules)
library(nuggets)

run_nuggets <- function(d, settings) {
    rules <- dig_associations(d,
                               min_support = settings$min_support,
                               min_length = 1,
                               max_length = settings$max_length,
                               min_confidence = settings$min_confidence)
    #rules$rule <- paste0(rules$antecedent, "=>", rules$consequent)

    rules
}


run_arules_apriori <- function(d, settings) {
    rules <- apriori(d,
                     parameter = list(minlen = 1,
                                      maxlen = settings$max_length + 1, # nuggets does not count the consequent in max_length, but arules does
                                      supp = settings$min_support,
                                      maxtime = 0,
                                      target = "frequent itemsets"),
                     control = list(verbose = FALSE))
    rules <- ruleInduction(rules, confidence = settings$min_confidence)
    #rules <- DATAFRAME(rules)

    rules
}


run_arules_eclat <- function(d, settings) {
    rules <- eclat(d,
                   parameter = list(minlen = 1,
                                    maxlen = settings$max_length + 1, # nuggets does not count the consequent in max_length, but arules does
                                    supp = settings$min_support,
                                    #maxtime = 0, -- not available for eclat
                                    target = "frequent itemsets"),
                     control = list(verbose = FALSE))
    rules <- ruleInduction(rules, confidence = settings$min_confidence)
    #rules <- DATAFRAME(rules)

    rules
}


run_fim4r_apriori <- function(d, settings) {
    rules <- fim4r(d,
                   method = "apriori",
                   target = "rules",
                   support = settings$min_support,
                   confidence = settings$min_confidence,
                   verbose = FALSE,
                   zmin = 0,
                   zmax = settings$max_length + 1)  # nuggets does not count the consequent in max_length, but fim4r does
    #rules <- DATAFRAME(rules)

    rules
}


run_fim4r_eclat <- function(d, settings) {
    rules <- fim4r(d,
                   method = "eclat",
                   target = "rules",
                   support = settings$min_support,
                   confidence = settings$min_confidence,
                   verbose = FALSE,
                   zmin = 0,
                   zmax = settings$max_length + 1)  # nuggets does not count the consequent in max_length, but fim4r does
    #rules <- DATAFRAME(rules)

    rules
}


run_fim4r_fpgrowth <- function(d, settings) {
    rules <- fim4r(d,
                   method = "fpgrowth",
                   target = "rules",
                   support = settings$min_support,
                   confidence = settings$min_confidence,
                   verbose = FALSE,
                   zmin = 0,
                   zmax = settings$max_length + 1)  # nuggets does not count the consequent in max_length, but fim4r does
    #rules <- DATAFRAME(rules)

    rules
}


run_fim4r_relim <- function(d, settings) {
    rules <- fim4r(d,
                   method = "relim",
                   target = "frequent",
                   support = settings$min_support,
                   verbose = FALSE,
                   zmin = 0,
                   zmax = settings$max_length + 1)  # nuggets does not count the consequent in max_length, but fim4r does
    rules <- ruleInduction(rules, confidence = settings$min_confidence)
    #rules <- DATAFRAME(rules)

    rules
}


run_fim4r_sam <- function(d, settings) {
    rules <- fim4r(d,
                   method = "sam",
                   target = "frequent",
                   support = settings$min_support,
                   verbose = FALSE,
                   zmin = 0,
                   zmax = settings$max_length + 1)  # nuggets does not count the consequent in max_length, but fim4r does
    rules <- ruleInduction(rules, confidence = settings$min_confidence)
    #rules <- DATAFRAME(rules)

    rules
}


run_instance <- function(settings) {
    set.seed(3345)
    d <- matrix(base::sample(x = c(T,F),
                             size = settings$rows * settings$cols,
                             replace = TRUE,
                             prob = c(settings$prob_1, 1 - settings$prob_1)),
                nrow = settings$rows,
                ncol = settings$cols)
    colnames(d) <- paste0("V", seq_len(settings$cols))

    bench_nu <- microbenchmark(res_nu <- run_nuggets(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_aa <- microbenchmark(res_aa <- run_arules_apriori(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_ae <- microbenchmark(res_ae <- run_arules_eclat(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_fa <- microbenchmark(res_fa <- run_fim4r_apriori(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_fe <- microbenchmark(res_fe <- run_fim4r_eclat(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_ff <- microbenchmark(res_ff <- run_fim4r_fpgrowth(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_fr <- microbenchmark(res_fr <- run_fim4r_relim(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")
    bench_fs <- microbenchmark(res_fs <- run_fim4r_sam(d, settings),
                               times = settings$n_repeat,
                               unit = "ns")

    time_nu <- mean(bench_nu$time)  # nanoseconds
    time_aa <- mean(bench_aa$time)
    time_ae <- mean(bench_ae$time)
    time_fa <- mean(bench_fa$time)
    time_fe <- mean(bench_fe$time)
    time_ff <- mean(bench_ff$time)
    time_fr <- mean(bench_fr$time)
    time_fs <- mean(bench_fs$time)

    #if (nrow(res_nu) != nrow(res_aa) || nrow(res_nu) != nrow(res_ae)) {
        #print(list(res_nu = nrow(res_nu), res_aa = nrow(res_aa), res_ae = nrow(res_ae)))
        #warning("Number of results differ between nuggets and arules")
    #}

    res <- data.frame(nuggets = time_nu,
                      arules_apriori = time_aa,
                      arules_eclat = time_ae,
                      fim4r_apriori = time_fa,
                      fim4r_eclat = time_fe,
                      fim4r_fpgrowth = time_ff,
                      fim4r_relim = time_fr,
                      fim4r_sam = time_fs,
                      #n_results = nrow(res_nu),
                      rows = settings$rows,
                      cols = settings$cols,
                      min_support = settings$min_support,
                      min_confidence = settings$min_confidence,
                      max_length = settings$max_length,
                      n_repeat = settings$n_repeat,
                      stringsAsFactors = FALSE)
    rownames(res) <- NULL

    res
}


bench <- function(rows, cols, prob_1) {
    grid <- expand.grid(rows = rows,
                        cols = cols,
                        min_support = 0.001,
                        min_confidence = prob_1,
                        max_length = 3,
                        n_repeat = 5,
                        prob_1 = prob_1)

    res <- NULL
    for (i in seq_len(nrow(grid))) {
        settings <- grid[i, , drop = FALSE]
        settings <- as.list(settings)
        cat("\nRunning instance ", i, " of ", nrow(grid),
            ": rows = ", settings$rows, ", cols = ", settings$cols, "\n")
        res_i <- run_instance(settings)
        res <- rbind(res, res_i)
        print(res)
    }

    res
}


cpuinfo <- function() {
    res <- readLines("/proc/cpuinfo")
    too <- min(which(res == "")) - 1
    res <- res[seq_len(too)]
    res <- gsub("\t+: ", ":", res)
    res <- strsplit(res, ":")

    result <- lapply(res, function(x) x[2])
    names(result) <- sapply(res, function(x) x[1])

    result
}


raminfo <- function() {
    res <- readLines("/proc/meminfo")
    res <- gsub(": +", ":", res)
    res <- gsub(" kB", "", res)
    res <- strsplit(res, ":")
    result <- lapply(res, function(x) as.numeric(x[2]))
    names(result) <- sapply(res, function(x) x[1])
    result
}


result <- list(cpu = cpuinfo()$`model name`,
               cache = cpuinfo()$`cache size`,
               ram = raminfo()$MemTotal / 1024 / 1024,  # in GB
               nuggets_version = as.character(packageVersion("nuggets")),
               arules_version = as.character(packageVersion("arules")),
               fim4r_version = as.character(packageVersion("fim4r")))

warmup <- bench(rows = 10^6, cols = c(30), prob_1 = 0.5)

result$dense_rows <- bench(rows = rev(c(10^3, 10^4, 10^5, 10^6, 10^7)), cols = 30, prob_1 = 0.5)
result$dense_cols <- bench(rows = 10^5, cols = c(10, 20, 30, 50, 80), prob_1 = 0.5)
result$sparse_rows <- bench(rows = rev(c(10^3, 10^4, 10^5, 10^6, 10^7)), cols = 30, prob_1 = 0.1)
result$sparse_cols <- bench(rows = 10^5, cols = c(10, 20, 30, 50, 80), prob_1 = 0.1)

saveRDS(result, "comparison-with-arules.rds")

