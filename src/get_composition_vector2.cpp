#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
Rcpp::IntegerVector rcpp_get_composition_vector2(const Rcpp::NumericVector & v)
{
    Rcpp::IntegerVector B = table(v);
    return B;
}

/*** R
library(raster)
new_r = raster(nrows = 3, ncols = 3, vals = c(rep(1, 8), 2))
plot(new_r)
new_v = as.vector(as.matrix(new_r))
rcpp_get_composition_vector2(as.matrix(new_r))

bench::mark(
    rcpp_get_composition_vector(as.matrix(podlasie_ccilc)),
    rcpp_get_composition_vector2(as.matrix(podlasie_ccilc)),
    iterations = 100,
    check = FALSE
)

*/
