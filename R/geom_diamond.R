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
    #if (is.null(data$fill)) {
        #data$linewidth <- 0
    #} else {
        #data$linewidth <- data$fill
    #}

    transform(data,
              formula = formula,
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
    required_cols <- c("condition", "x", "y", "linewidth")
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
    edges$colour <- "#666666"
    edges$linewidth <- 0.5

    lw <- data$linewidth[edges$row] - data$linewidth[edges$col]
    edges$linewidth <- 0.5 + 4.5 * (abs(lw) - min(abs(lw))) / (max(abs(lw)) - min(abs(lw)))
    edges$linewidth[!is.finite(edges$linewidth)] <- 0.5

    edges
}


.geom_diamond_draw_panel <- function(data,
                                     panel_params,
                                     coord,
                                     na.rm = FALSE,
                                     linetype = "solid",
                                     nudge_x = 0,
                                     nudge_y = 0.125) {
    edges <- .geom_diamond_create_edges(data, linetype)
    point_data <- transform(data,
                            fill = "white")
    label_data <- transform(data,
                            colour = "white",
                            size = 4,
                            #fill = "white",
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
        #labelcolour = "black",
        size = 1,
        shape = 21,
        fill = "white",
        linewidth = 0.5,
        alpha = NA,
        stroke = 1
    ),
    setup_data = .geom_diamond_setup_data,
    draw_key = draw_key_point,
    draw_panel = .geom_diamond_draw_panel
)


#scale_labelcolour_continuous <- ggplot2::scale_colour_continuous
#scale_labelcolour_discrete   <- ggplot2::scale_colour_discrete

#scale_nodecolour_continuous <- function(name = waiver(),
                                        #...,
                                        #low = "#132B43",
                                        #high = "#56B1F7",
                                        #space = "Lab",
                                        #na.value = "grey50",
                                        #aesthetics = "nodecolour")  {
    #continuous_scale(aesthetics,
                     #name = name,
                     #palette = scales::pal_seq_gradient(low, high, space),
                     #na.value = na.value,
                     #guide = guide_colourbar(available_aes = c("nodecolour")),
                     #...)
#}


#' Geom for drawing diamond plots of lattice structures
#'
#' Create a custom `ggplot2` geom for drawing diamond plots, which are used to
#' visualize lattice structures. This is particularly useful for representing
#' association rules and their ancestor–descendant relationships in a concise
#' graphical form.
#'
#' In a diamond plot, nodes (diamonds) represent items or conditions in the
#' lattice, while edges represent inclusion (subset) relationships between
#' them. The geom combines node and edge rendering with flexible aesthetic
#' options for labels and positioning.
#'
#' @details
#' Supported aesthetics:
#' - condition - character vector with condition in the format as returned by
#'   [format_condition()]. For each condition, a node is created in the plot.
#'   All values in this aesthetic must be unique.
#' - label - a label of the node. If not set, condition is used instead
#' - colour -
#' - size
#' - shape
#' - fill
#' - alpha
#' - stroke
#'
#'
#' @param mapping Aesthetic mappings, usually created with [ggplot2::aes()].
#' @param data A data frame containing the lattice structure to be plotted.
#' @param stat The statistical transformation to apply, default is `"identity"`.
#' @param position Position adjustment for the geom, default is `"identity"`.
#' @param na.rm Logical; if `TRUE`, missing values are silently removed.
#' @param linetype Line type used for edges. Defaults to `"solid"`.
#' @param nudge_x Horizontal nudge applied to label positions.
#' @param nudge_y Vertical nudge applied to label positions.
#' @param show.legend Logical; should a legend be drawn? Defaults to `FALSE`.
#' @param inherit.aes Logical; if `TRUE`, inherit default aesthetics from the
#'   plot. Defaults to `TRUE`.
#' @param ... Additional arguments passed on to [ggplot2::layer()].
#'
#' @return A `ggplot2` layer object representing a diamond plot. This layer can
#'   be added to an existing `ggplot` object.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' data("iris")
#' rules <- dig_associations(part)
#'
#' # select some rule to visualize the ancestors
#' rule <- rules[1000, , drop = FALSE]
#'
#' # prepare data for visualization of rule ancestors
#' ante <- parse_condition(rule$antecedent)[[1]]
#' cons <- parse_condition(rule$consequent)[[1]]
#' res <- dig_associations(part,
#'                        antecedent = all_of(ante),
#'                        consequent = all_of(cons),
#'                        min_length = 0,
#'                        max_length = Inf,
#'                        min_coverage = 0,
#'                        min_support = 0,
#'                        min_confidence = 0,
#'                        measures = c("lift", "conviction"),
#'                        max_results = Inf)
#'
#' # convert all columns into dummy logical variables
#' part <- partition(iris, .breaks = 3)
#'
#' # find all antecedents with Sepal for rules with consequent Species=setosa
#' rules <- dig_associations(part,
#'                          antecedent = starts_with("Sepal"),
#'                          consequent = `Species=setosa`,
#'                          min_length = 0,
#'                          max_length = Inf,
#'                          min_coverage = 0,
#'                          min_support = 0,
#'                          min_confidence = 0,
#'                          measures = c("lift", "conviction"),
#'                          max_results = Inf)
#'
#' # add abbreviated condition for labeling
#' rules$abbrev <- shorten_condition(rules$antecedent)
#'
#' # plot the lattice of rules
#' ggplot(rules) +
#'     aes(condition = antecedent,
#'         fill = confidence,
#'         linewidth = confidence,
#'         size = coverage,
#'         label = abbrev) +
#'    geom_diamond()
#' }
#'
#' @export
geom_diamond <- function(mapping = NULL,
                         data = NULL,
                         stat = "identity",
                         position = "identity",
                         na.rm = FALSE,
                         linetype = "solid",
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
                      nudge_x = nudge_x,
                      nudge_y = nudge_y,
                      na.rm = na.rm,
                      ...)
    )
}
