/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2025 Michal Burda
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 **********************************************************************/


#include "common.h"


// [[Rcpp::export]]
NumericVector raisedcos_(NumericVector x, NumericVector ctx)
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
        } else if (x[i] < low || x[i] > big) {
            res[i] = 0;
        } else if (x[i] < ctr1) {
            if (low == R_NegInf) {
                res[i] = 1;
            } else if (low == ctr1) {
                res[i] = 0;
            } else {
                res[i] = (cos((x[i] - ctr1) * M_PI / (ctr1 - low)) + 1) / 2;
            }
        } else if (x[i] <= ctr2) {
            res[i] = 1;
        } else {
            if (big == R_PosInf) {
                res[i] = 1;
            } else if (ctr2 == big) {
                res[i] = 0;
            } else {
                res[i] = (cos((x[i] - ctr2) * M_PI / (big - ctr2)) + 1) / 2;
            }
        }
    }

    return res;
}

