% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dichotomize.R
\name{dichotomize}
\alias{dichotomize}
\title{Create dummy columns from logicals or factors in a data frame}
\usage{
dichotomize(.data, what = everything(), ..., .keep = FALSE, .other = FALSE)
}
\arguments{
\item{.data}{a data frame to be processed}

\item{what}{a tidyselect expression (see
\href{https://tidyselect.r-lib.org/articles/syntax.html}{tidyselect syntax})
selecting the columns to be processed}

\item{...}{further tidyselect expressions for selecting the columns to
be processed}

\item{.keep}{whether to keep the original columns. If FALSE, the original
columns are removed from the result.}

\item{.other}{whether to put into result the rest of columns that were not
specified for dichotomization in \code{what} argument.}
}
\value{
A tibble with selected columns replaced with dummy columns.
}
\description{
Create dummy logical columns from selected columns of the data frame.
Dummy columns may be created for logical or factor columns as follows:
}
\details{
\itemize{
\item for logical column \code{col}, a pair of columns is created named \code{col=T}
and \code{col=F} where the former (resp. latter) is equal to the original
(resp. negation of the original);
\item for factor column \code{col}, a new logical column is created for each
level \code{l} of the factor \code{col} and named as \code{col=l} with a value set
to TRUE wherever the original column is equal to \code{l}.
}
}
\author{
Michal Burda
}
