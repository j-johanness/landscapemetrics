#' CAI (patch level)
#'
#' @description Core area index (Core area metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#' @param consider_boundary Logical if cells that only neighbour the landscape
#' boundary should be considered as core
#' @param edge_depth Distance (in cells) a cell has the be away from the patch
#' edge to be considered as core cell
#'
#' @details
#' \deqn{CAI = (\frac{a_{ij}^{core}} {a_{ij}}) * 100}
#' where \eqn{a_{ij}^{core}} is the core area in square meters and \eqn{a_{ij}}
#' is the area in square meters.
#'
#' CAI is a 'Core area metric'. It equals the percentage of a patch that is core area.
#' A cell is defined as core area if the cell has no neighbour with a different value
#' than itself (rook's case). It describes patch area and shape simultaneously (more core area
#' when the patch is large and the shape is rather compact, i.e. a square). Because the index is
#' relative, it is comparable among patches with different area.
#'
#'
#' \subsection{Units}{Percent}
#' \subsection{Range}{0 <= CAI <= 100}
#' \subsection{Behaviour}{CAI = 0 when the patch has no core area and
#' approaches CAI = 100 with increasing percentage of core area within a patch.}
#'
#' @seealso
#' \code{\link{lsm_p_core}},
#' \code{\link{lsm_p_area}}, \cr
#' \code{\link{lsm_c_cai_mn}},
#' \code{\link{lsm_c_cai_sd}},
#' \code{\link{lsm_c_cai_cv}},
#' \code{\link{lsm_c_cpland}}, \cr
#' \code{\link{lsm_l_cai_mn}},
#' \code{\link{lsm_l_cai_sd}},
#' \code{\link{lsm_l_cai_cv}}
#'
#' @return tibble
#'
#' @examples
#' lsm_p_cai(landscape)
#'
#' @aliases lsm_p_cai
#' @rdname lsm_p_cai
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' @export
lsm_p_cai <- function(landscape, directions, consider_boundary, edge_depth) UseMethod("lsm_p_cai")

#' @name lsm_p_cai
#' @export
lsm_p_cai.RasterLayer <- function(landscape,
                                  directions = 8,
                                  consider_boundary = FALSE,
                                  edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_cai_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_p_cai
#' @export
lsm_p_cai.RasterStack <- function(landscape,
                                  directions = 8,
                                  consider_boundary = FALSE,
                                  edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_cai_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_p_cai
#' @export
lsm_p_cai.RasterBrick <- function(landscape,
                                  directions = 8,
                                  consider_boundary = FALSE,
                                  edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_cai_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_p_cai
#' @export
lsm_p_cai.stars <- function(landscape,
                            directions = 8,
                            consider_boundary = FALSE,
                            edge_depth = 1) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_cai_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_p_cai
#' @export
lsm_p_cai.list <- function(landscape,
                           directions = 8,
                           consider_boundary = FALSE,
                           edge_depth = 1) {

    result <- lapply(X = landscape,
                     FUN = lsm_p_cai_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_p_cai_calc <- function(landscape, directions, consider_boundary, edge_depth, resolution = NULL){


    # convert to matrix
    if(class(landscape) != "matrix") {
        resolution <- raster::res(landscape)
        landscape <- raster::as.matrix(landscape)
    }

    # get patch area
    area_patch <- lsm_p_area_calc(landscape = landscape,
                                  directions = directions,
                                  resolution = resolution)

    # convert from ha to sqm
    area_patch$value <- area_patch$value * 10000

    # get core area
    core_patch <- lsm_p_core_calc(landscape,
                                  directions = directions,
                                  consider_boundary = consider_boundary,
                                  edge_depth = edge_depth,
                                  resolution = resolution)

    # calculate CAI index
    cai_patch <- core_patch$value * 10000 / area_patch$value * 100

    tibble::tibble(
        level = "patch",
        class = as.integer(area_patch$class),
        id = as.integer(area_patch$id),
        metric = "cai",
        value = as.double(cai_patch)
    )
}
