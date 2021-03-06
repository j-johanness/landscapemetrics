#' ENT (landscape level)
#'
#' @description Shannon entropy
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param base The unit in which entropy is measured.
#' The default is "log2", which compute entropy in "bits".
#' "log" and "log10" can be also used.
#'
#' @details
#' It measures a diversity (thematic complexity) of landscape classes.
#'
#' @seealso
#' \code{\link{lsm_l_condent}},
#' \code{\link{lsm_l_mutinf}},
#' \code{\link{lsm_l_joinent}},
#'
#' @return tibble
#'
#' @examples
#' lsm_l_ent(landscape)
#'
#' @aliases lsm_l_ent
#' @rdname lsm_l_ent
#'
#' @references
#' Nowosad J., TF Stepinski. 2018. Information-theoretical approach to measure
#' landscape complexity. https://doi.org/10.1101/383281
#'
#' @export
lsm_l_ent <- function(landscape, base = "log2") UseMethod("lsm_l_ent")

#' @name lsm_l_ent
#' @export
lsm_l_ent.RasterLayer <- function(landscape, base = "log2") {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_ent_calc,
                     base = base)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_l_ent
#' @export
lsm_l_ent.RasterStack <- function(landscape, base = "log2") {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_ent_calc,
                     base = base)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_l_ent
#' @export
lsm_l_ent.RasterBrick <- function(landscape, base = "log2") {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_ent_calc,
                     base = base)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_l_ent
#' @export
lsm_l_ent.stars <- function(landscape, base = "log2") {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_ent_calc,
                     base = base)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_l_ent
#' @export
lsm_l_ent.list <- function(landscape, base = "log2") {

    result <- lapply(X = landscape,
                     FUN = lsm_l_ent_calc,
                     base = base)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_l_ent_calc <- function(landscape, base){

    # convert to matrix
    if(class(landscape) != "matrix") {
        landscape <- raster::as.matrix(landscape)
    }

    cmh  <- rcpp_get_composition_vector(landscape)

    comp <- rcpp_get_entropy(cmh, base)

    tibble::tibble(
        level = "landscape",
        class = as.integer(NA),
        id = as.integer(NA),
        metric = "ent",
        value = as.double(comp)
    )
}
