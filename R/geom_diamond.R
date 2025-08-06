.condition_to_items <- function(condition) {
    cond <- parse_condition(condition)
    pred <- sort(unique(unlist(cond)))
    if (length(pred) > length(LETTERS)) {
        cli_abort(c("The number of unique predicates ({length(pred)}) exceeds the number of available letters ({length(LETTERS)}).",
                    "i" = "Consider using a different condition or reducing the number of unique predicates."))
    }
    predDict <- setNames(LETTERS[seq_along(pred)], pred)

    lapply(cond, function(cc) as.vector(predDict[cc]))
}


.geom_diamond_setup_data <- function(data, params) {
    #items <- .condition_to_items(data$condition)
    items <- parse_condition(data$condition)

    formula_length <- unlist(lapply(items, length))
    formula <- unlist(lapply(items, paste, collapse = ", "))
    if (length(unique(formula)) != length(formula)) {
        cli_abort(c("The {.var condition} column contains duplicate entries.",
                    "i" = "Each item in {.var condition} must be unique."))
    }
    formula[formula == ""] <- "-"    # empty string does not work well in vector names

    xDict <- setNames(rep(0, length(formula)), formula)
    for (len in unique(formula_length)) {
        idx <- which(formula_length == len)
        xDict[sort(formula[idx])] <- seq(from = -1 * (length(idx) - 1) / 2,
                                         by = 1,
                                         length.out = length(idx))
    }

    if (is.null(data$label)) {
        data$label <- formula
    }

    xcoord <- xDict[formula]
    ycoord <- max(formula_length) - formula_length
    xlabcoord <- xcoord + params$nudge_x
    ylabcoord <- ycoord + params$nudge_y

    transform(data,
              formula = formula,
              x = xcoord,
              y = ycoord,
              linewidth = data$fill, # store original fill value into linewidth because fill will be transformed to color constants
              xlabel = xlabcoord,
              ylabel = ylabcoord,
              xmin = pmin(xcoord, xlabcoord),
              xmax = pmax(xcoord, xlabcoord),
              ymin = pmin(ycoord, ylabcoord),
              ymax = pmax(ycoord, ylabcoord))
}

.geom_diamond_draw_panel <- function(data,
                                     panel_params,
                                     coord,
                                     na.rm = FALSE,
                                     linetype = "solid",
                                     nudge_x = 0,
                                     nudge_y = 0.125) {
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
    edges$curvature <- (edges$y - edges$yend - 1) * ifelse(edges$xend > edges$x, 1, -1)
    edges$alpha <- NA
    edges$group <- 1
    edges$linetype <- linetype
    edges$colour <- "#666666"
    edges$linewidth <- 0.5

    lw <- data$linewidth[edges$row] - data$linewidth[edges$col]
    edges$linewidth <- 0.5 + 4.5 * (abs(lw) - min(abs(lw))) / (max(abs(lw)) - min(abs(lw)))
    edges$linewidth[!is.finite(edges$linewidth)] <- 0.5

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
        size = 1,
        shape = 21,
        fill = "white",
        alpha = NA,
        stroke = 1
    ),
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
