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


#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom classInt classIntervals
#' @importFrom cli cli_abort
#' @importFrom cli cli_inform
#' @importFrom cli cli_warn
#' @importFrom dplyr bind_cols
#' @importFrom dplyr bind_rows
#' @importFrom fastmatch fmatch
#' @importFrom generics explore
#' @importFrom ggplot2 .data
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 draw_key_point
#' @importFrom ggplot2 element_blank
#' @importFrom ggplot2 element_text
#' @importFrom ggplot2 expansion
#' @importFrom ggplot2 Geom
#' @importFrom ggplot2 geom_bar
#' @importFrom ggplot2 geom_col
#' @importFrom ggplot2 geom_histogram
#' @importFrom ggplot2 geom_hline
#' @importFrom ggplot2 geom_point
#' @importFrom ggplot2 geom_rect
#' @importFrom ggplot2 geom_text
#' @importFrom ggplot2 geom_vline
#' @importFrom ggplot2 GeomCurve
#' @importFrom ggplot2 GeomLabel
#' @importFrom ggplot2 GeomPoint
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 ggproto
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 layer
#' @importFrom ggplot2 scale_color_continuous
#' @importFrom ggplot2 scale_x_continuous
#' @importFrom ggplot2 scale_y_continuous
#' @importFrom ggplot2 scale_y_discrete
#' @importFrom ggplot2 sec_axis
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 xlab
#' @importFrom ggplot2 ylab
#' @importFrom grid gList
#' @importFrom lifecycle deprecate_warn
#' @importFrom lifecycle deprecated
#' @importFrom methods formalArgs
#' @importFrom purrr quietly
#' @importFrom purrr safely
#' @importFrom Rcpp sourceCpp
#' @importFrom rlang caller_arg
#' @importFrom rlang caller_env
#' @importFrom rlang current_env
#' @importFrom rlang enquo
#' @importFrom rlang enquos
#' @importFrom rlang is_integer
#' @importFrom rlang is_integerish
#' @importFrom rlang is_scalar_atomic
#' @importFrom rlang is_scalar_character
#' @importFrom rlang is_scalar_double
#' @importFrom rlang is_scalar_integerish
#' @importFrom rlang is_scalar_logical
#' @importFrom rlang quo_is_null
#' @importFrom rlang warn
#' @importFrom stats aggregate
#' @importFrom stats cor.test
#' @importFrom stats kmeans
#' @importFrom stats na.omit
#' @importFrom stats pbinom
#' @importFrom stats quantile
#' @importFrom stats setNames
#' @importFrom stats t.test
#' @importFrom stats var.test
#' @importFrom stats wilcox.test
#' @importFrom stringr str_trim
#' @importFrom tibble add_column
#' @importFrom tibble as_tibble
#' @importFrom tibble is_tibble
#' @importFrom tibble tibble
#' @importFrom tibble tribble
#' @importFrom tidyr expand_grid
#' @importFrom tidyr pivot_wider
#' @importFrom tidyselect all_of
#' @importFrom tidyselect eval_select
#' @importFrom tidyselect everything
#' @importFrom tidyselect where
#' @importFrom utils citation
#' @importFrom utils packageDescription
#' @useDynLib nuggets, .registration = TRUE
## usethis namespace: end
NULL

#' @export
generics::explore
