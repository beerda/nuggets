% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/is_degree.R
\name{is_degree}
\alias{is_degree}
\title{Tests whether the given argument is a numeric value from the interval
\eqn{[0,1]}}
\usage{
is_degree(x, na_rm = FALSE)
}
\arguments{
\item{x}{the value to be tested}

\item{na_rm}{whether to ignore \code{NA} values}
}
\value{
\code{TRUE} if \code{x} is a numeric vector, matrix or array with values
between 0 and 1, otherwise, \code{FALSE} is returned. If \code{na_rm} is \code{TRUE},
\code{NA} values are treated as valid values. If \code{na_rm} is \code{FALSE} and \code{x}
contains \code{NA} values, \code{FALSE} is returned.
}
\description{
Tests whether the given argument is a numeric value from the interval
\eqn{[0,1]}
}
\author{
Michal Burda
}
