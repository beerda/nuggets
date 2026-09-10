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
#include "Predicate.h"
#include "Clause.h"


class Pattern {
public:
    Pattern(const Clause& prefix,
            const Predicate* predicate,
            const vector<const Predicate*>& foci,
            const vector<double>& predicateSums,
            std::function<LogicalVector()> indicesFunc,
            std::function<NumericVector()> weightsFunc)
        : prefix(prefix),
          predicate(predicate),
          foci(foci),
          predicateSums(predicateSums),
          indicesFunc(indicesFunc),
          weightsFunc(weightsFunc)
    { }

    const Clause& getPrefix() const
    { return prefix; }

    bool hasPredicate() const
    { return predicate->hasPredicate(); }

    size_t getConditionLength() const
    { return prefix.size() + predicate->hasPredicate(); }

    // TODO: zkusit tohle vymazat
    const size_t* getPredicatePtr() const
    { return predicate->getPredicatePtr(); }

    size_t getPredicate() const
    { return predicate->getPredicate(); }

    double getConditionSum() const
    { return predicate->getSum(); }

    const vector<const Predicate*>& getFoci() const
    { return foci; }

    const vector<double>& getPredicateSums() const
    { return predicateSums; }

    LogicalVector getIndices() const
    { return indicesFunc(); }

    NumericVector getWeights() const
    { return weightsFunc(); }

private:
    const Clause& prefix;
    const Predicate* predicate;
    const vector<const Predicate*>& foci;
    const vector<double>& predicateSums;
    std::function<LogicalVector()> indicesFunc;
    std::function<NumericVector()> weightsFunc;
};
