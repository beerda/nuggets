% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/remove_almost_constant.R
\name{remove_almost_constant}
\alias{remove_almost_constant}
\title{Remove almost constant columns from a data frame}
\usage{
remove_almost_constant(
  .data,
  .what = everything(),
  ...,
  .threshold = 1,
  .na_rm = FALSE,
  .verbose = FALSE
)
}
\arguments{
\item{.data}{a data frame}

\item{.what}{a tidyselect expression (see
\href{https://tidyselect.r-lib.org/articles/syntax.html}{tidyselect syntax})
selecting the columns to be processed}

\item{...}{optional other tidyselect expressions selecting additional
columns to be processed}

\item{.threshold}{a numeric scalar in the range \eqn{[0, 1]} specifying the
threshold for the proportion of the most frequent value}

\item{.na_rm}{a logical scalar indicating whether to remove \code{NA} values
before computing the proportion of the most frequent value. See
\code{\link[=is_almost_constant]{is_almost_constant()}} for details of how \code{NA} values are handled.}

\item{.verbose}{a logical scalar indicating whether to print a message
about removed columns}
}
\value{
A data frame with removed all columns specified by the \code{.what}
argument that are also (almost) constant
}
\description{
Function tests all columns that are specified by the \code{.what} argument
and removes those that are almost constant. A column is considered
almost constant if the proportion of the most frequent value is greater
than the threshold specified by the \code{.threshold} argument. See
\code{\link[=is_almost_constant]{is_almost_constant()}} for details.
}
\examples{
d <- data.frame(a1 = 1:10,
                a2 = c(1:9, NA),
                b1 = "b",
                b2 = NA,
                c1 = rep(c(TRUE, FALSE), 5),
                c2 = rep(c(TRUE, NA), 5),
                d = c(rep(TRUE, 4), rep(FALSE, 4), NA, NA))
remove_almost_constant(d, .threshold = 1.0, .na_rm = FALSE)
remove_almost_constant(d, .threshold = 1.0, .na_rm = TRUE)
remove_almost_constant(d, .threshold = 0.5, .na_rm = FALSE)
remove_almost_constant(d, .threshold = 0.5, .na_rm = TRUE)
remove_almost_constant(d, a1:b2, .threshold = 0.5, .na_rm = TRUE)
}
\seealso{
\code{\link[=is_almost_constant]{is_almost_constant()}}
}
\author{
Michal Burda
}
