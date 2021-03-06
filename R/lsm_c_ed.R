#' ED (class level)
#'
#' @description Edge Density (Area and Edge metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param count_boundary Count landscape boundary as edge.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{ED = \frac{\sum \limits_{k = 1}^{m} e_{ik}} {A} * 10000}
#' where \eqn{e_{ik}} is the total edge length in meters and \eqn{A} is the total
#' landscape area in square meters.
#'
#' ED is an 'Area and Edge metric'. The edge density equals the sum of all edges of class i
#' in relation to the landscape area. The boundary of the landscape is only included in the
#' corresponding total class edge length if \code{count_boundary = TRUE}.
#' The metric describes the configuration of the landscape, e.g. because  an  aggregation
#' of the same class will result in a low edge density. The metric is standardized to the
#' total landscape area, and therefore comparisons among landscapes with different total
#' areas are possible.

#' \subsection{Units}{Meters per hectare}
#' \subsection{Range}{ED >= 0}
#' \subsection{Behaviour}{Equals ED = 0 if only one patch is present (and the landscape
#' boundary is not included) and increases, without limit, as the landscapes becomes more
#' patchy}
#'
#' @seealso
#' \code{\link{lsm_c_te}},
#' \code{\link{lsm_l_ta}}, \cr
#' \code{\link{lsm_l_ed}}
#'
#' @return tibble
#'
#' @examples
#' lsm_c_ed(landscape)
#'
#' @aliases lsm_c_ed
#' @rdname lsm_c_ed
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' @export
lsm_c_ed <- function(landscape, count_boundary, directions) UseMethod("lsm_c_ed")

#' @name lsm_c_ed
#' @export
lsm_c_ed.RasterLayer <- function(landscape,
                                 count_boundary = FALSE,
                                 directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ed_calc,
                     count_boundary = count_boundary,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_ed
#' @export
lsm_c_ed.RasterStack <- function(landscape,
                                 count_boundary = FALSE,
                                 directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ed_calc,
                     count_boundary = count_boundary,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_ed
#' @export
lsm_c_ed.RasterBrick <- function(landscape,
                                 count_boundary = FALSE,
                                 directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ed_calc,
                     count_boundary = count_boundary,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_ed
#' @export
lsm_c_ed.stars <- function(landscape,
                           count_boundary = FALSE,
                           directions = 8) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ed_calc,
                     count_boundary = count_boundary,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_ed
#' @export
lsm_c_ed.list <- function(landscape,
                          count_boundary = FALSE,
                          directions = 8) {

    result <- lapply(X = landscape,
                     FUN = lsm_c_ed_calc,
                     count_boundary = count_boundary,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_c_ed_calc <- function(landscape, count_boundary, directions, resolution = NULL) {

    # convert to matrix
    if(class(landscape) != "matrix") {
        resolution <- raster::res(landscape)
        landscape <- raster::as.matrix(landscape)
    }

    # get patch area
    area <- lsm_p_area_calc(landscape,
                            directions = directions,
                            resolution = resolution)

    # summarise to total area
    area <- sum(area$value)

    # get total edge length
    edge_class <- lsm_c_te_calc(landscape,
                                count_boundary = count_boundary,
                                directions = directions,
                                resolution = resolution)

    edge_class$value <- edge_class$value / area

    tibble::tibble(
        level = "class",
        class = as.integer(edge_class$class),
        id = as.integer(NA),
        metric = "ed",
        value = as.double(edge_class$value)
    )
}
