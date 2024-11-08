#include "common.h"


// [[Rcpp::export]]
NumericVector raisedcos_(NumericVector x, NumericVector ctx)
{
    double low = ctx[0];
    double ctr = ctx[1];
    double big = ctx[2];

    NumericVector res(x.size());
    for (int i = 0; i < x.size(); ++i) {
        if (R_IsNA(x[i])) {
            res[i] = NA_REAL;
        } else if (R_IsNaN(x[i])) {
            res[i] = NAN;
        } else if (x[i] < low || x[i] > big) {
            res[i] = 0;
        } else if (x[i] < ctr) {
            if (low == R_NegInf) {
                res[i] = 1;
            } else if (low == ctr) {
                res[i] = 0;
            } else {
                res[i] = (cos((x[i] - ctr) * M_PI / (ctr - low)) + 1) / 2;
            }
        } else if (x[i] == ctr) {
            res[i] = 1;
        } else {
            if (big == R_PosInf) {
                res[i] = 1;
            } else if (ctr == big) {
                res[i] = 0;
            } else {
                res[i] = (cos((x[i] - ctr) * M_PI / (big - ctr)) + 1) / 2;
            }
        }
    }

    return res;
}

