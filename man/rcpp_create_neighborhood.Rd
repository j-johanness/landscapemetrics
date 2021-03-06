% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{rcpp_create_neighborhood}
\alias{rcpp_create_neighborhood}
\title{Create neighborhood coordinates}
\usage{
rcpp_create_neighborhood(directions)
}
\arguments{
\item{directions}{The number of directions in which cells should be connected:
4 (rook's case), 8 (queen's case), or a neighbourhood matrix.
The neighbourhood matrix should have one cell with value 0 (the focal cell),
and at least one cell with value 1 (the adjacent cells).
Cells with other values (e.g. NA) are ignored.}
}
\description{
This function creates a neighborhood coordinates matrix based on the directions parameter.
}
\keyword{internal}
