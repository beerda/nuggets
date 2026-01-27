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

#include "../common.h"


class Clause : public vector<size_t> {
public:
    Clause() = default;

    Clause(size_t n)
        : vector<size_t>(n)
    { }

    Clause(initializer_list<size_t> init)
        : vector<size_t>(init)
    { }

    Clause(const Clause& other) = default;
    Clause& operator=(const Clause& other) = default;
    Clause(Clause&& other) = default;
    Clause& operator=(Clause&& other) = default;

    bool operator==(const Clause& other) const
    {
        if (size() != other.size())
            return false;

        for (size_t i = 0; i < size(); ++i) {
            if (at(i) != other.at(i))
                return false;
        }

        return true;
    }

    inline void sort()
    { std::sort(begin(), end()); }
};
