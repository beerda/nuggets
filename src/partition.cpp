/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2026 Michal Burda
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
List partition_numeric_crisp_(const NumericVector& x,
                              const List& breaks,
                              const bool right)
{
    List result(breaks.size());
    for (R_xlen_t j = 0; j < breaks.size(); ++j) {
        const NumericVector& brk = breaks[j];
        if (brk.size() < 2) {
            stop("Each break must be a numeric vector of length at least 2");
        }

        double low = brk[0];
        double high = brk[brk.size() - 1];
        LogicalVector t = LogicalVector(x.size(), false);
        for (R_xlen_t i = 0; i < x.size(); ++i) {
            if (R_IsNA(x[i]) || R_IsNaN(x[i])) {
                continue;
            }
            if ((right && x[i] > low && x[i] <= high) || (!right && x[i] >= low && x[i] < high)) {
                t[i] = true;
            }
        }

        result[j] = t;
    }

    return result;
}


// [[Rcpp::export]]
List partition_numeric_fuzzy_(const NumericVector& x,
                              const List& breaks,
                              const bool triangle)
{
    List result(breaks.size());
    for (R_xlen_t j = 0; j < breaks.size(); ++j) {
        const NumericVector& brk = breaks[j];
        if (brk.size() < 2) {
            stop("Each break must be a numeric vector of length at least 2");
        }

        double low = brk[0];
        double ctr1 = brk[1];
        double ctr2 = brk[brk.size() - 2];
        double big = brk[brk.size() - 1];

        NumericVector t(x.size());
        for (R_xlen_t i = 0; i < x.size(); ++i) {
            if (R_IsNA(x[i]) || R_IsNaN(x[i])) {
                t[i] = 0;
                continue;
            }

            if (triangle) {
                if (x[i] < ctr1) {
                    if (low == R_NegInf) {
                        t[i] = 1;
                    } else if (low == ctr1) {
                        t[i] = 0;
                    } else {
                        t[i] = std::max(0.0, (x[i] - low) / (ctr1 - low));
                    }
                } else if (x[i] <= ctr2) {
                    t[i] = 1;
                } else {
                    if (big == R_PosInf) {
                        t[i] = 1;
                    } else if (ctr2 == big) {
                        t[i] = 0;
                    } else {
                        t[i] = std::max(0.0, (big - x[i]) / (big - ctr2));
                    }
                }
            }
            else { // raisedcos
                if (x[i] < low || x[i] > big) {
                    t[i] = 0;
                } else if (x[i] < ctr1) {
                    if (low == R_NegInf) {
                        t[i] = 1;
                    } else if (low == ctr1) {
                        t[i] = 0;
                    } else {
                        t[i] = (cos((x[i] - ctr1) * M_PI / (ctr1 - low)) + 1) / 2;
                    }
                } else if (x[i] <= ctr2) {
                    t[i] = 1;
                } else {
                    if (big == R_PosInf) {
                        t[i] = 1;
                    } else if (ctr2 == big) {
                        t[i] = 0;
                    } else {
                        t[i] = (cos((x[i] - ctr2) * M_PI / (big - ctr2)) + 1) / 2;
                    }
                }
            }
        }

        result[j] = t;
    }

    return result;

}
