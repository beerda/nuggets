.geom_diamond_setup_data <- function(data, params) {
    items <- parse_condition(data$condition)
    formula_length <-vapply(items, length, integer(1))
    formula <- vapply(items,
                      function(x) paste(sort(x), collapse = ", "),
                      character(1))
    formula[formula == ""] <- "-"    # empty string does not work well in vector names

    if (length(unique(formula)) != length(formula)) {
        cli_abort(c("The {.var condition} contains duplicate values.",
                    "i" = "Each item in {.var condition} must be unique."))
    }

    x_dict <- rep(0, length(formula))
    x_dict <- setNames(x_dict, formula)
    for (len in unique(formula_length)) {
        idx <- which(formula_length == len)
        x_dict[sort(formula[idx])] <- seq(from = -1 * (length(idx) - 1) / 2,
                                          by = 1,
                                          length.out = length(idx))
    }

    xcoord <- x_dict[formula]
    ycoord <- max(formula_length) - formula_length
    xlabcoord <- xcoord + params$nudge_x
    ylabcoord <- ycoord + params$nudge_y

    if (is.null(data$label)) {
        data$label <- formula
    }

    if (is.null(params$linewidth) || all(is.na(params$linewidth))) {
        if (is.null(data$linewidth)) {
            data$linewidth <- 0.5
        }
    } else {
            data$linewidth <- params$linewidth
    }

    transform(data,
              formula = formula,
              linewidth_orig = data$linewidth,
              x = xcoord,
              y = ycoord,
              xlabel = xlabcoord,
              ylabel = ylabcoord,
              xmin = pmin(xcoord, xlabcoord),
              xmax = pmax(xcoord, xlabcoord),
              ymin = pmin(ycoord, ylabcoord),
              ymax = pmax(ycoord, ylabcoord))
}


.geom_diamond_create_edges <- function(data,
                                       linetype = "solid") {
    required_cols <- c("condition", "x", "y", "linewidth_orig")
    missing_cols <- setdiff(required_cols, colnames(data))
    if (length(missing_cols) > 0) {
        stop("Internal error in .geom_diamond_create_edges() - missing data column(s): ",
             paste(missing_cols, collapse = ", "))
    }

    items <- parse_condition(data$condition)
    incidence_matrix <- outer(items, items, Vectorize(function(x, y) {
        length(setdiff(x, y)) == 0
    }))
    diag(incidence_matrix) <- FALSE
    transitive_edges <- (incidence_matrix %*% incidence_matrix) > 0
    incidence_matrix <- incidence_matrix & !transitive_edges

    edges <- which(incidence_matrix, arr.ind = TRUE)
    edges <- as.data.frame(edges)
    edges$x <- data$x[edges$row]
    edges$xend <- data$x[edges$col]
    edges$y <- data$y[edges$row]
    edges$yend <- data$y[edges$col]
    edges$curvature <- (edges$y - edges$yend - 1) * ifelse(edges$xend > edges$x, -1, 1)
    edges$alpha <- NA
    edges$group <- 1
    edges$linetype <- linetype

    uniq_lw <- unique(data$linewidth_orig)
    if (length(uniq_lw) == 1) {
        edges$linewidth_orig <- uniq_lw
        edges$colour <- "#000000"
    } else {
        lw <- data$linewidth_orig[edges$row] - data$linewidth_orig[edges$col]
        abslw <- abs(lw)
        edges$linewidth <- 0.5 + 4.5 * (abslw - min(abslw)) / (max(abslw) - min(abslw))

        edges$colour[is.finite(edges$linewidth) & lw < 0] <- "#999999"
        edges$colour[is.finite(edges$linewidth) & lw > 0] <- "#cc9999"
        edges$colour[!is.finite(edges$linewidth) | lw == 0] <- "#000000"

        edges$linewidth[!is.finite(edges$linewidth)] <- 0.5
    }

    edges
}


.geom_diamond_draw_panel <- function(data,
                                     panel_params,
                                     coord,
                                     na.rm = FALSE,
                                     linetype = "solid",
                                     linewidth = 0.5,
                                     nudge_x = 0,
                                     nudge_y = 0.125) {
    edges <- .geom_diamond_create_edges(data, linetype)
    point_data <- transform(data)
    label_data <- transform(data,
                            colour = "black",
                            size = 4,
                            linewidth = 0.5,
                            fill = "white",
                            x = data$xlabel,
                            y = data$ylabel)


    c1 <- NULL
    c2 <- NULL
    c3 <- NULL
    if (sum(edges$curvature == 0) > 0) {
        c1 <- GeomCurve$draw_panel(edges[edges$curvature == 0, ],
                                   panel_params,
                                   coord,
                                   curvature = 0)
    }
    if (sum(edges$curvature > 0) > 0) {
        c2 <- GeomCurve$draw_panel(edges[edges$curvature > 0, ],
                                   panel_params,
                                   coord,
                                   curvature = 0.25,
                                   angle = 45)
    }
    if (sum(edges$curvature < 0) > 0) {
        c3 <- GeomCurve$draw_panel(edges[edges$curvature < 0, ],
                                   panel_params,
                                   coord,
                                   curvature = -0.25,
                                   angle = 45)
    }
    gList(
        c1, c2, c3,
        GeomPoint$draw_panel(point_data, panel_params, coord),
        GeomLabel$draw_panel(label_data, panel_params, coord)
    )
}


GeomDiamond <- ggproto(
    "GeomDiamond",
    Geom,
    required_aes = c("condition"),
    default_aes = aes(
        label = NULL,
        colour = "black",
        size = 1,
        shape = 21,
        fill = "white",
        alpha = NA,
        stroke = 1,
        #linewidth = 0.5   # this must be commented out to prevent linewidth
                           # appear in the legend at all (because the legend is
                           # broken for it)
    ),
    setup_data = .geom_diamond_setup_data,
    draw_key = draw_key_point,
    draw_panel = .geom_diamond_draw_panel
)


#' Geom for drawing diamond plots of lattice structures
#'
#' Create a custom `ggplot2` geom for visualizing lattice structures as
#' *diamond plots*. This geom is particularly useful for displaying
#' association rules and their ancestor–descendant relationships in a clear,
#' compact graphical form.
#'
#' In a diamond plot, nodes (diamonds) represent items or conditions within
#' the lattice, while edges denote inclusion (subset) relationships between
#' them. The geom combines node and edge rendering with flexible control over
#' aesthetics such as labels, color, and size.
#'
#' @details
#' **Supported aesthetics**
#' \itemize{
#'   \item `condition` – character vector of conditions formatted with
#'     [format_condition()]. Each condition defines one node in the lattice.
#'     The hierarchy is determined by subset inclusion: a condition \eqn{X}
#'     is a descendant of \eqn{Y} if \eqn{Y \subset X}. Each condition must
#'     be unique.
#'   \item `label` – optional text label for each node. If omitted,
#'     the condition string is used.
#'   \item `colour` – border color of the node.
#'   \item `fill` – interior color of the node.
#'   \item `size` – size of nodes.
#'   \item `shape` – node shape.
#'   \item `alpha` – transparency of nodes.
#'   \item `stroke` – border line width of nodes.
#'   \item `linewidth` – edge width between parent and child nodes,
#'     computed as the difference of this aesthetic between them.
#' }
#'
#' @param mapping Aesthetic mappings, usually created with [ggplot2::aes()].
#' @param data A data frame representing the lattice structure to plot.
#' @param stat Statistical transformation to apply; defaults to `"identity"`.
#' @param position Position adjustment for the geom; defaults to `"identity"`.
#' @param na.rm Logical; if `TRUE`, missing values are silently removed.
#' @param linetype Line type for edges; defaults to `"solid"`.
#' @param nudge_x Horizontal nudge applied to labels.
#' @param nudge_y Vertical nudge applied to labels.
#' @param show.legend Logical; whether to include a legend. Defaults to `FALSE`.
#' @param inherit.aes Logical; whether to inherit aesthetics from the plot.
#'   Defaults to `TRUE`.
#' @param ... Additional arguments passed to [ggplot2::layer()].
#' @return A `ggplot2` layer object that adds a diamond lattice visualization
#'   to an existing plot.
#' @author Michal Burda
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Prepare data by partitioning numeric columns into fuzzy or crisp sets
#' part <- partition(iris, .breaks = 3)
#'
#' # Find all antecedents with "Sepal" for rules with consequent "Species=setosa"
#' rules <- dig_associations(part,
#'                           antecedent = starts_with("Sepal"),
#'                           consequent = `Species=setosa`,
#'                           min_length = 0,
#'                           max_length = Inf,
#'                           min_coverage = 0,
#'                           min_support = 0,
#'                           min_confidence = 0,
#'                           measures = c("lift", "conviction"),
#'                           max_results = Inf)
#'
#' # Add abbreviated labels for readability
#' rules$abbrev <- shorten_condition(rules$antecedent)
#'
#' # Plot the lattice of rules as a diamond diagram
#' ggplot(rules) +
#'   aes(condition = antecedent,
#'       fill = confidence,
#'       linewidth = confidence,
#'       size = coverage,
#'       label = abbrev) +
#'   geom_diamond()
#' }
#'
#' @export
geom_diamond <- function(mapping = NULL,
                         data = NULL,
                         stat = "identity",
                         position = "identity",
                         na.rm = FALSE,
                         linetype = "solid",
                         linewidth = NA,
                         nudge_x = 0,
                         nudge_y = 0.125,
                         show.legend = NA,
                         inherit.aes = TRUE,
                         ...) {
    layer(
        data = data,
        mapping = mapping,
        stat = stat,
        geom = GeomDiamond,
        position = position,
        show.legend = show.legend,
        inherit.aes = inherit.aes,
        params = list(linetype = linetype,
                      linewidth = linewidth,
                      nudge_x = nudge_x,
                      nudge_y = nudge_y,
                      na.rm = na.rm,
                      ...)
    )
}
