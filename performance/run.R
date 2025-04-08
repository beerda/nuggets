library(stringr)

repeats <- 10

# parse command line arguments -------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  stop("Please provide the commit hash of nuggets to install.")
}
if (length(args) < 2) {
  stop("Please provide the test files.")
}

githash <- args[1]
tests <- args[-1]


# obtain information about the commit ------------------------------------------
if (githash == "current") {
    gitdate <- as.character(Sys.time())
    gitmessage <- "current"
} else {
    gitdate <- system(paste("git show -s --format=%ci", githash), intern = TRUE)
    if (!is.null(attr(gitdate, "status"))) {
        stop("Invalid commit hash provided.")
    }
    gitmessage <- system(paste("git show -s --format=%s", githash), intern = TRUE)
}
gitdate <- str_remove(gitdate, "\\..*")
gitdate <- str_remove(gitdate, " \\+.*")


# install and load the correct version of nuggets ------------------------------
cat("Installing nuggets: ", githash, " (", gitdate, ")\n", sep = "")
if (githash == "current") {
    devtools::install("..")
} else {
    devtools::install_github("beerda/nuggets", ref = githash)
}

library(nuggets)


# execute tests ----------------------------------------------------------------
result <- NULL
for (test in tests) {
    cat("Executing test: ", test, "\n", sep = "")
    elapsed <- lapply(seq_len(repeats), function(i) {
        source(test)$value["elapsed"]
    })
    elapsed <- as.numeric(elapsed)
    elapsed <- mean(elapsed)
    result <- rbind(result,
                    data.frame(test = test, elapsed = elapsed))
}


# save the results -------------------------------------------------------------
result$gitdate <- gitdate
result$githash <- githash
result$gitmessage <- gitmessage

print(result)
saveRDS(result, file = paste0("results/", githash, ".rds"))
