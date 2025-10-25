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


#pragma once

#include <unordered_set>
#include "../common.h"


class Condition {
public:
    Condition(const IntegerVector& _predicates)
        : predicates(_predicates.begin(), _predicates.end())
    { }

    Condition(const unordered_set<int>& _predicates)
        : predicates(_predicates)
    { }

    bool hasPredicate(int predicate) const {
        return predicates.find(predicate) != predicates.end();
    }

    const unordered_set<int> getPredicates() const {
        return predicates;
    }

    int length() const {
        return predicates.size();
    }

private:
    unordered_set<int> predicates;
};
