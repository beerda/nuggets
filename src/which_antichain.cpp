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
#include "antichain/AntichainData.h"
#include "antichain/Tree.h"


// [[Rcpp::export]]
IntegerVector which_antichain_(List x, IntegerVector dist)
{
    if (dist.size() == 0) {
        stop("dist must have at least one element");
    }
    
    IntegerVector result;
    AntichainData data(x);
    Tree tree(dist.at(0));

    for (size_t i = 0; i < data.size(); ++i) {
        if (tree.insertIfIncomparable(data.getCondition(i))) {
            result.push_back(i + 1);
        }
    }

    return result;
}
