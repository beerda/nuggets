% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dig_grid.R
\name{dig_grid}
\alias{dig_grid}
\title{Search for grid-based rules}
\usage{
dig_grid(
  x,
  f,
  condition = where(is.logical),
  xvars = where(is.numeric),
  yvars = where(is.numeric),
  na_rm = FALSE,
  min_length = 0L,
  max_length = Inf,
  min_support = 0,
  threads = 1,
  ...
)
}
\arguments{
\item{x}{a matrix or data frame with data to search in.}

\item{f}{the callback function to be executed on a data frame that is passed
to the function as the first argument. The data frame consists from two
columns (a combination of \code{xvars}/\code{yvars} columns) and from all rows
of \code{x} that satisfy the generated condition. The function must return
a list of scalar values, which will be converted into a single row
of result of final tibble.}

\item{condition}{a tidyselect expression (see
\href{https://tidyselect.r-lib.org/articles/syntax.html}{tidyselect syntax})
specifying the columns to use as condition predicates. The selected
columns must be logical or numeric. If numeric, fuzzy conditions are
considered.}

\item{xvars}{a tidyselect expression (see
\href{https://tidyselect.r-lib.org/articles/syntax.html}{tidyselect syntax})
specifying the columns of \code{x}, whose names will be used as a domain for
combinations use at the first place (xvar)}

\item{yvars}{a tidyselect expression (see
\href{https://tidyselect.r-lib.org/articles/syntax.html}{tidyselect syntax})
specifying the columns of \code{x}, whose names will be used as a domain for
combinations use at the second place (yvar)}

\item{na_rm}{a logical value indicating whether to remove rows with missing
values from sub-data before the callback function \code{f} is called}

\item{min_length}{the minimum size (the minimum number of predicates) of the
condition to be generated (must be greater or equal to 0). If 0, the empty
condition is generated in the first place.}

\item{max_length}{the maximum size (the maximum number of predicates) of the
condition to be generated. If equal to Inf, the maximum length of conditions
is limited only by the number of available predicates.}

\item{min_support}{the minimum support of a condition to trigger the callback
function for it. The support of the condition is the relative frequency
of the condition in the dataset \code{x}. For logical data, it equals to the
relative frequency of rows such that all condition predicates are TRUE on it.
For numerical (double) input, the support is computed as the mean (over all
rows) of multiplications of predicate values.}

\item{threads}{the number of threads to use for parallel computation.}

\item{...}{Further arguments, currently unused.}
}
\value{
A tibble with found rules. Each row represents a single call of
the callback function \code{f}.
}
\description{
This function creates a grid of combinations of pairs of columns specified
by \code{xvars} and \code{yvars} (see also \code{\link[=var_grid]{var_grid()}}). After that, it enumerates all
conditions created from data in \code{x} (by calling \code{\link[=dig]{dig()}}) and for each such
condition and for each row of the grid of combinations, a user-defined
function \code{f} is executed on each sub-data created from \code{x} by selecting all
rows of \code{x} that satisfy the generated condition and by selecting the
columns in the grid's row.
}
\seealso{
\code{\link[=dig]{dig()}}, \code{\link[=var_grid]{var_grid()}}, and \code{\link[=dig_correlations]{dig_correlations()}}, as it is using this
function internally
}
\author{
Michal Burda
}
