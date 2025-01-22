#include "common.h"


// [[Rcpp::export]]
NumericVector triangle_(NumericVector x, NumericVector ctx)
{
    double low = ctx[0];
    double ctr1 = ctx[1];
    double ctr2 = ctx[ctx.size() - 2];
    double big = ctx[ctx.size() - 1];

    NumericVector res(x.size());
    for (int i = 0; i < x.size(); ++i) {
        if (R_IsNA(x[i])) {
            res[i] = NA_REAL;
        } else if (R_IsNaN(x[i])) {
            res[i] = NAN;
        } else if (x[i] < ctr1) {
            if (low == R_NegInf) {
                res[i] = 1;
            } else if (low == ctr1) {
                res[i] = 0;
            } else {
                res[i] = std::max(0.0, (x[i] - low) / (ctr1 - low));
            }
        } else if (x[i] <= ctr2) {
            res[i] = 1;
        } else {
            if (big == R_PosInf) {
                res[i] = 1;
            } else if (ctr2 == big) {
                res[i] = 0;
            } else {
                res[i] = std::max(0.0, (big - x[i]) / (big - ctr2));
            }
        }
    }

    return res;
}
