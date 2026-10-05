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
