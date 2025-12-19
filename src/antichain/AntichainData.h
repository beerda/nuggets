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

#include <vector>
#include "../common.h"
#include "Condition.h"


class AntichainData {
public:
    AntichainData()
    { }

    AntichainData(List data)
    {
        for (R_xlen_t i = 0; i < data.size(); ++i) {
            addCondition(data[i]);
        }
    }

    inline void addCondition(const IntegerVector& values)
    { conditions.push_back(Condition(values)); }

    inline const Condition& getCondition(const size_t i) const
    { return conditions.at(i); }

    inline size_t size() const
    { return conditions.size(); }

private:
    vector<Condition> conditions;
};
