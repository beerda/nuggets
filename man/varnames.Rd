% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/varnames.R
\name{varnames}
\alias{varnames}
\title{Extract variable names from predicates}
\usage{
varnames(x)
}
\arguments{
\item{x}{A character vector of predicate names.}
}
\value{
A \verb{<varname>} part of predicate names in \code{x}.
}
\description{
The function assumes that \code{x} is a vector of predicate names, i.e., a character
vector with elements compatible with pattern \verb{<varname>=<value>}. The function
returns the \verb{<varname>} part of these elements. If the string does not
correspond to the pattern \verb{<varname>=<value>}, i.e., if the equal sign (\code{=})
is missing in the string, the whole string is returned.
}
\examples{
varnames(c("a=1", "a=2", "b=x", "b=y")) # returns c("a", "a", "b", "b")
}
\author{
Michal Burda
}
