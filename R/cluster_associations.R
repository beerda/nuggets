#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


#' @title Cluster association rules
#'
#' @description
#' This function clusters association rules based on the selected numeric
#' attribute `by` (e.g., confidence or lift) and summarizes the clusters.
#' The clustering is performed using the k-means algorithm.
#'
#' Each cluster is represented by a label consisting of the number of rules
#' in the cluster and the most common predicates in the antecedents of those
#' rules.
#'
#' @param x A nugget of flavour `associations`, typically the output
#'   of [dig_associations()].
#' @param n The number of clusters to create. Must be a positive integer.
#' @param by A tidyselect expression (see
#'    [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'    specifying the numeric column to use for clustering.
#' @param algorithm The k-means algorithm to use. One of `"Hartigan-Wong"`
#'    (the default), `"Lloyd"`, `"Forgy"`, or `"MacQueen"`. See [stats::kmeans()]
#'    for details.
#' @param predicates_in_label The number of most common predicates to include
#'    in the cluster label. The default is 2.
#'
#' @return A tibble with one row per (cluster, consequent) pair. The columns are:
#' - `cluster`: the cluster number;
#' - `cluster_label`: a label for the cluster, consisting of the number of rules
#'     in the cluster and the most common predicates in the antecedents of those
#'     rules;
#' - `consequent`: consequents of the rules;
#' - other numeric columns from the input nugget, aggregated by mean within each
#'     cluster.
#' @author Michal Burda
#' @seealso [dig_associations()], [association_matrix()] [stats::kmeans()]
#' @examples
#' # Prepare the data
#' cars <- mtcars |>
#'     partition(cyl, vs:gear, .method = "dummy") |>
#'     partition(carb, .method = "crisp", .breaks = c(0, 3, 10)) |>
#'     partition(mpg, disp:qsec, .method = "triangle", .breaks = 3)
#'
#' # Search for associations
#' rules <- dig_associations(cars,
#'                           antecedent = everything(),
#'                           consequent = everything(),
#'                           max_length = 3,
#'                           min_support = 0.2)
#'
#' # Cluster the found rules
#' clu <- cluster_associations(rules, 10, "lift")
#'
#' # Print the number of clusters
#' length(unique(clu$cluster))
#'
#' \dontrun{
#' # Plot the clustered rules
#' library(ggplot2)
#'
#' ggplot(clu) +
#'    aes(x = cluster_label, y = consequent, color = lift, size = support) +
#'    geom_point() +
#'    xlab("predicates in antecedent groups") +
#'    scale_y_discrete(limits = rev) +
#'    theme(axis.text.x = element_text(angle = 45, hjust = 1))
#' }
#' @export
cluster_associations <- function(x,
                                 n,
                                 by,
                                 algorithm = "Hartigan-Wong",
                                 predicates_in_label = 2) {
    .must_be_nugget(x, "associations")
    .must_be_integerish_scalar(n)
    .must_be_greater_eq(n, 1)
    .must_be_enum(algorithm,
                  c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"),
                  arg = "algorithm")
    .must_be_integerish_scalar(predicates_in_label)
    .must_be_greater_eq(predicates_in_label, 1)

    by <- enquo(by)
    value_col <- eval_select(expr = by,
                             data = x,
                             allow_rename = FALSE,
                             allow_empty = TRUE, # we test for empty selection in association_matrix
                             allow_predicates = TRUE,
                             error_call = current_env())

    mat <- association_matrix(x,
                              !!by,
                              error_context = list(arg_x = "x",
                                                   arg_value = "by",
                                                   call = current_env()))
    dup <- duplicated(mat, MARGIN = 1)
    num_uniq <- sum(!dup)
    if (n >= num_uniq) {
        cli_warn(c(
            "{.fun cluster_associations}: The number of clusters {.arg n} should be less than the number of distinct data points in {.arg x}.",
            "i" = "The number of distinct data points in {.arg x} is {.val {num_uniq}}.",
            "!" = "You provided {.arg n} = {.val {n}}.",
            ">" = "{.val {num_uniq}} clusters will be created instead."
        ))
        n <- num_uniq
    }

    if (n == nrow(mat)) {
        # Each point is its own cluster; no need to run k-means
        # However, Lloyd method is known to handle that properly
        # (surprisingly, Hartigan-Wong fails in such case)
        algorithm <- "Lloyd"
    }

    # cluster and aggregate measures by clusters
    fit <- kmeans(mat, centers = n, algorithm = algorithm)
    matches <- match(x$antecedent, rownames(mat))
    clust_vec <- as.vector(fit$cluster[matches])
    aggregator <- list(cluster = clust_vec, consequent = x$consequent)
    num_cols <- vapply(x, is.numeric, logical(1))
    x_num <- x[, num_cols, drop = FALSE]
    res <- aggregate(x_num,
                     by = aggregator,
                     FUN = mean,
                     na.rm = TRUE)

    # sort result by the value of "by"
    res <- as_tibble(res)
    ord <- order(res[[names(value_col)[1]]], decreasing = TRUE)
    res <- res[ord, , drop = FALSE]

    # reassign cluster numbers accordingly to the desired order
    cluster_order <- unique(res$cluster)
    res$cluster <- match(res$cluster, cluster_order)
    clust_vec <- match(clust_vec, cluster_order)

    # get cluster sizes and tables of predicates
    split_ante <- split(x$antecedent, clust_vec, drop = TRUE)
    clust_size <- vapply(split_ante, length, integer(1))
    clust_predicates <- lapply(split_ante, function(a) {
        tab <- parse_condition(a)
        tab <- unlist(tab, use.names = FALSE)
        tab <- table(tab)
        tab <- sort(tab, decreasing = TRUE)
        tab <- as.table(tab)

        tab
    })

    # create cluster labels
    lab <- vapply(clust_predicates, function(tab) {
        k <- length(tab)
        length(tab) <- min(k, predicates_in_label)
        plus <- k - length(tab)
        if (plus > 0) {
            plus <- paste0(", +", plus, " item", if (plus > 1) "s" else "")
        } else {
            plus <- ""
        }

        paste0("{",
               paste0(names(tab), collapse = ", "),
               plus,
               "}")
    }, character(1))
    lab <- paste0(clust_size, " rules: ", lab)
    res <- add_column(res,
                      cluster_label = lab[res$cluster],
                      .after = "cluster",
                      .name_repair = "minimal")

    # ensure factors have levels in the desired order
    uniq_cluster_label <- unique(res$cluster_label)
    res$cluster_label <- factor(res$cluster_label, levels = uniq_cluster_label)
    uniq_consequent <- unique(res$consequent)
    res$consequent <- factor(res$consequent, levels = uniq_consequent)

    attr(res, "cluster_predicates") <- clust_predicates
    attr(res, "cluster_antecedents") <- split_ante
    attr(res, "cluster_size") <- clust_size
    attr(res, "consequent") <- uniq_consequent

    res
}
