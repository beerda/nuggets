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

    inline const Clause& getPrefix() const
    { return prefix; }

    inline size_t getConditionLength() const
    { return prefix.size() + predicate->hasPredicate(); }

    inline bool hasPredicate() const
    { return predicate->hasPredicate(); }

    inline size_t getPredicate() const
    { return predicate->getPredicate(); }

    inline double getConditionSum() const
    { return predicate->getSum(); }

    inline size_t getFociCount() const
    { return foci.size(); }

    inline const Predicate& getFocus(size_t index) const
    { return *foci[index]; }

    inline const vector<double>& getPredicateSums() const
    { return predicateSums; }

    inline LogicalVector getIndices() const
    { return indicesFunc(); }

    inline NumericVector getWeights() const
    { return weightsFunc(); }

private:
    const Clause& prefix;
    const Predicate* predicate;
    const vector<const Predicate*>& foci;
    const vector<double>& predicateSums;
    std::function<LogicalVector()> indicesFunc;
    std::function<NumericVector()> weightsFunc;
};
