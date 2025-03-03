% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/is_condition.R
\name{is_condition}
\alias{is_condition}
\title{Check whether the given list of character vectors contains a list of valid
conditions.}
\usage{
is_condition(x, data)
}
\arguments{
\item{x}{a list of character vector}

\item{data}{a matrix or a data frame}
}
\value{
a logical vector indicating whether each element of the list \code{x}
contains a character vector such that all elements of that vector
are column names of \code{data}
}
\description{
A valid condition is a character vector of predicates, where each predicate
corresponds to some column name of the related data frame. This function
checks whether the given list of character vectors \code{x}
contains only such predicates that can be found in column names of given
data frame \code{data}.
}
\details{
Note that empty character vector is considered as a valid condition too.
}
\examples{
d <- data.frame(foo = 1:5, bar = 1:5, blah = 1:5)
is_condition(list("foo"), d)
is_condition(list(c("bar", "blah"), NULL, c("foo", "bzz")), d)
}
\seealso{
\code{\link[=remove_ill_conditions]{remove_ill_conditions()}}
}
\author{
Michal Burda
}
