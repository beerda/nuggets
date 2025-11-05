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


#######################################################################
# t-norms
.goedel_tnorm <- function(...) {
    vals <- as.numeric(c(...))
    .Call('_nuggets_goedel_tnorm', vals, PACKAGE='nuggets')
}

.lukas_tnorm <- function(...) {
    vals <- as.numeric(c(...))
    .Call('_nuggets_lukas_tnorm', vals, PACKAGE='nuggets')
}

.goguen_tnorm <- function(...) {
    vals <- as.numeric(c(...))
    .Call('_nuggets_goguen_tnorm', vals, PACKAGE='nuggets')
}

.pgoedel_tnorm <- function(...) {
  elts <- list(...)
  if (length(elts) <= 0L) {
    return(NULL);
  }
  vals <- lapply(elts, as.numeric)
  res <- .Call('_nuggets_pgoedel_tnorm', vals, PACKAGE='nuggets')
  mostattributes(res) <- attributes(elts[[1L]])
  res
}

.plukas_tnorm <- function(...) {
  elts <- list(...)
  if (length(elts) <= 0L) {
    return(NULL);
  }
  vals <- lapply(elts, as.numeric)
  res <- .Call('_nuggets_plukas_tnorm', vals, PACKAGE='nuggets')
  mostattributes(res) <- attributes(elts[[1L]])
  res
}

.pgoguen_tnorm <- function(...) {
  elts <- list(...)
  if (length(elts) <= 0L) {
    return(NULL);
  }
  vals <- lapply(elts, as.numeric)
  res <- .Call('_nuggets_pgoguen_tnorm', vals, PACKAGE='nuggets')
  mostattributes(res) <- attributes(elts[[1L]])
  res
}


###########################################################
# t-conorms

.goedel_tconorm <- function(...) {
    vals <- as.numeric(c(...))
    .Call('_nuggets_goedel_tconorm', vals, PACKAGE='nuggets')
}

.lukas_tconorm <- function(...) {
    vals <- as.numeric(c(...))
    .Call('_nuggets_lukas_tconorm', vals, PACKAGE='nuggets')
}

.goguen_tconorm <- function(...) {
    vals <- as.numeric(c(...))
    .Call('_nuggets_goguen_tconorm', vals, PACKAGE='nuggets')
}

.pgoedel_tconorm <- function(...) {
  elts <- list(...)
  if (length(elts) <= 0L) {
    return(NULL);
  }
  vals <- lapply(elts, as.numeric)
  res <- .Call('_nuggets_pgoedel_tconorm', vals, PACKAGE='nuggets')
  mostattributes(res) <- attributes(elts[[1L]])
  res
}

.plukas_tconorm <- function(...) {
  elts <- list(...)
  if (length(elts) <= 0L) {
    return(NULL);
  }
  vals <- lapply(elts, as.numeric)
  res <- .Call('_nuggets_plukas_tconorm', vals, PACKAGE='nuggets')
  mostattributes(res) <- attributes(elts[[1L]])
  res
}

.pgoguen_tconorm <- function(...) {
  elts <- list(...)
  if (length(elts) <= 0L) {
    return(NULL);
  }
  vals <- lapply(elts, as.numeric)
  res <- .Call('_nuggets_pgoguen_tconorm', vals, PACKAGE='nuggets')
  mostattributes(res) <- attributes(elts[[1L]])
  res
}


###########################################################
# residua

.goedel_residuum <- function(x, y) {
    .Call('_nuggets_goedel_residuum', as.numeric(x), as.numeric(y), PACKAGE='nuggets')
}

.lukas_residuum <- function(x, y) {
    .Call('_nuggets_lukas_residuum', as.numeric(x), as.numeric(y), PACKAGE='nuggets')
}

.goguen_residuum <- function(x, y) {
    .Call('_nuggets_goguen_residuum', as.numeric(x), as.numeric(y), PACKAGE='nuggets')
}


###########################################################
# bi-residua

.goedel_biresiduum <- function(x, y) {
    .pgoedel_tnorm(.goedel_residuum(x, y), .goedel_residuum(y, x))
}

.lukas_biresiduum <- function(x, y) {
    .pgoedel_tnorm(.lukas_residuum(x, y), .lukas_residuum(y, x))
}

.goguen_biresiduum <- function(x, y) {
    .pgoedel_tnorm(.goguen_residuum(x, y), .goguen_residuum(y, x))
}


###########################################################
# negations

.invol_neg <- function(x) {
    vals <- as.numeric(c(x))
    res <- .Call('_nuggets_invol_neg', vals, PACKAGE='nuggets')
    mostattributes(res) <- attributes(x)
    return(res)
}

.strict_neg <- function(x) {
    vals <- as.numeric(c(x))
    res <- .Call('_nuggets_strict_neg', vals, PACKAGE='nuggets')
    mostattributes(res) <- attributes(x)
    return(res)
}
