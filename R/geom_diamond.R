.condition_to_items <- function(condition) {
    cond <- parse_condition(condition)
    pred <- sort(unique(unlist(cond)))
    if (length(pred) > length(LETTERS)) {
        cli_abort(c("The number of unique predicates ({length(pred)}) in {.var {condition_name}} exceeds the number of available letters ({length(LETTERS)}).",
                    "i" = "Consider using a different condition or reducing the number of unique predicates."))
    }
    predDict <- setNames(LETTERS[seq_along(pred)], pred)

    lapply(cond, function(cc) as.vector(predDict[cc]))
}


.geom_diamond_setup_data <- function(data, params) {
    items <- .condition_to_items(data$condition)
    formula_length <- unlist(lapply(items, length))
    formula <- unlist(lapply(items, paste, collapse = ""))
    if (length(unique(formula)) != length(formula)) {
        cli_abort(c("The {.var condition} column contains duplicate entries.",
                    "i" = "Each item in {.var condition} must be unique."))
    }

    formula[formula == ""] <- "-"    # empty string does not work well in vector names

    xDict <- setNames(rep(0, length(formula)), formula)
    for (len in unique(formula_length)) {
        idx <- which(formula_length == len)
        xDict[formula[idx]] <- seq(from = -1 * (length(idx) - 1) / 2,
                                          by = 1,
                                          length.out = length(idx))
    }

    transform(data,
              formula = formula,
              label = formula,
              x = xDict[formula],
              y = formula_length,
              xlabel = xDict[formula],
              ylabel = formula_length + 0.125,
              ymin = formula_length,
              ymax = formula_length + 0.125)
}


.geom_diamond_draw_panel <- function(data, panel_params, coord, na.rm = FALSE, linewidth = 1, linetype = "solid") {
    items <- .condition_to_items(data$condition)
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
    edges$alpha <- NA
    edges$colour <- "#000000"
    edges$group <- 1
    edges$linetype <- linetype
    edges$linewidth <- linewidth
    edges$curvature <- (edges$yend - edges$y - 1) * ifelse(edges$xend > edges$x, 1, -1)

    point_data <- transform(data)
    label_data <- transform(data,
                            colour = "black",
                            size = 4,
                            fill = "white",
                            x = xlabel,
                            y = ylabel)

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
    grid::gList(
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
        colour = "black",
        size = 1,
        shape = 21,
        fill = "white",
        alpha = NA,
        stroke = 1
    ),
    extra_params = c("na.rm", "linewidth", "linetype"),
    setup_data = .geom_diamond_setup_data,
    draw_key = draw_key_point,
    draw_panel = .geom_diamond_draw_panel
)


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


#' @export
geom_diamond <- function(mapping = NULL,
                         data = NULL,
                         stat = "identity",
                         position = "identity",
                         na.rm = FALSE,
                         linewidth = 0.5,
                         linetype = "solid",
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
        params = list(linewidth = linewidth,
                      linetype = linetype,
                      na.rm = na.rm,
                      ...)
    )
}
