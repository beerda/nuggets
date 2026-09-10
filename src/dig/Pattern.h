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


#pragma once

#include "../common.h"
#include "BaseChain.h"
#include "Clause.h"


class Pattern {
public:
    Pattern(const Clause& prefix,
            const BaseChain* chain,
            const vector<const BaseChain*>& foci,
            const vector<double>& predicateSums,
            std::function<LogicalVector()> indicesFunc,
            std::function<NumericVector()> weightsFunc)
        : prefix(prefix),
          chain(chain),
          foci(foci),
          predicateSums(predicateSums),
          indicesFunc(indicesFunc),
          weightsFunc(weightsFunc)
    { }

    const Clause& getPrefix() const
    { return prefix; }

    const BaseChain* getChain() const
    { return chain; }

    const vector<const BaseChain*>& getFoci() const
    { return foci; }

    const vector<double>& getPredicateSums() const
    { return predicateSums; }

    LogicalVector getIndices() const
    { return indicesFunc(); }

    NumericVector getWeights() const
    { return weightsFunc(); }

private:
    const Clause& prefix;
    const BaseChain* chain;
    const vector<const BaseChain*>& foci;
    const vector<double>& predicateSums;
    std::function<LogicalVector()> indicesFunc;
    std::function<NumericVector()> weightsFunc;
};
