% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/options_landscapemetrics.R
\name{options_landscapemetrics}
\alias{options_landscapemetrics}
\title{options_landscapemetrics}
\usage{
options_landscapemetrics(to_disk = NULL)
}
\arguments{
\item{to_disk}{Logical argument, if FALSE results of get_patches are hold
in memory. If true, get_patches writes temporary files and hence, does not hold everything in memory.
Can be set with a global option, e.g. \code{option(to_disk = TRUE)}. See Details.}
}
\value{
Global option to be used internally in the package
}
\description{
Sets global options for landscapemetrics
}
\details{
Landscape metrics rely on the delineation of patches. Hence, \code{get_patches} is
heavily used in \strong{landscapemetrics}. As raster can be quite big, the fact that
\code{get_patches} creates a copy of the raster for each class in a landscape becomes
a burden for computer memory. Hence, the argument \emph{to_disk} allows to
store the results of the connected labeling algorithm on disk. Furthermore,
this option can be set globally, so that every function that internally uses
\code{get_patches} can make use of that.
}
