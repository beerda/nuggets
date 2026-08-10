library(tidyverse)
library(xlsx)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Please provide resulting RDS files to be merged.")
}

library(tidyverse)

str(args)

res <- args |>
    map(readRDS) |>
    reduce(bind_rows)
    #arrange(test, desc(gitdate))

print(res)
saveRDS(res, "result.rds")
write.xlsx(res, "result.xlsx", row.names = FALSE)
