#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
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


#' @param pp The count of true positives (antecedent and consequent both true).
#'     Value must be greater or equal to zero.
#' @param pn The count of false positives (antecedent true, consequent false).
#'     Value must be greater or equal to zero.
#' @param np The count of false negatives (antecedent false, consequent true).
#'     Value must be greater or equal to zero.
#' @param nn The count of true negatives (antecedent and consequent both false).
#'     Value must be greater or equal to zero.
#' @param ... Additional arguments (currently ignored).
#' @examples
#' plot_contingency(pp = 30, pn = 10, np = 20, nn = 40)
#' @rdname plot_contingency
#' @method plot_contingency default
#' @export
plot_contingency.default <- function(pp, pn, np, nn, ...) {
    .must_be_double_scalar(pp)
    .must_be_double_scalar(pn)
    .must_be_double_scalar(np)
    .must_be_double_scalar(nn)

    .must_be_greater_eq(pp, 0)
    .must_be_greater_eq(pn, 0)
    .must_be_greater_eq(np, 0)
    .must_be_greater_eq(nn, 0)

    n <- pp + pn + np + nn
    xp <- pp + np
    xn <- pn + nn
    px <- pp + pn
    nx <- np + nn

    eps <- 0.02
    x0 <- 0
    x1 <- xp / n
    x2 <- 1

    y0 <- 0
    y1 <- np / xp
    y2 <- nn / xn
    y3 <- 1

    tick_x0 <- (x1 - x0) / 2
    tick_x1 <- x1 + eps + (x2 - x1) / 2
    tick_y0 <- y1 + eps + (y3 - y1) / 2
    tick_y1 <- (y1 - y0) / 2

    ante_expected <- nx / n + eps / 2
    cons_expected <- xp / n + eps / 2

    #                        pp        pn        np  nn
    d <- data.frame(ante = c("T"     , "T"     ,"F", "F"),
                    cons = c("T"     , "F"     ,"T", "F"),
                    xmin = c(x0      , x1 + eps, x0, x1 + eps),
                    ymin = c(y1 + eps, y2 + eps, y0, y0      ),
                    xmax = c(x1      , x2 + eps, x1, x2 + eps),
                    ymax = c(y3 + eps, y3 + eps, y1, y2      ))

    ggplot(d) +
        aes(fill = .data$ante,
            xmin = .data$xmin, xmax = .data$xmax,
            ymin = .data$ymin, ymax = .data$ymax) +
        geom_rect(color = "black") +
        geom_hline(yintercept = ante_expected, linetype = "dashed", color = "black") +
        geom_vline(xintercept = cons_expected, linetype = "dashed", color = "black") +
        scale_x_continuous(expand = expansion(mult = 0, add = 2 * eps),
                           breaks = c(tick_x0, tick_x1),
                           labels = c("T", "F")) +
        scale_y_continuous(expand = expansion(mult = 0, add = 2 * eps),
                           breaks = c(tick_y0, tick_y1),
                           labels = c("T", "F")) +
        xlab("consequent") +
        ylab("antecedent") +
        theme(legend.position = "none",
              aspect.ratio = 1,
              panel.grid = element_blank())
}
