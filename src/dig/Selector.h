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


class Selector {
public:
    Selector(const size_t size)
        : n(0), selectedCount(0), pruned(size), constantlyTrue(false)
    { }

    // Disable move
    Selector(Selector&& other) = delete;
    Selector& operator=(Selector&& other) = delete;

    // Disable copy
    Selector(const Selector&) = delete;
    Selector& operator=(const Selector&) = delete;

    void initialize(const size_t size, const bool isConstantlyTrue)
    {
        n = size;
        selectedCount = size;
        constantlyTrue = isConstantlyTrue;
        if (!constantlyTrue) {
            fill(pruned.begin(), pruned.end(), false);
        }
    }

    void unselect(const size_t index)
    {
        if (constantlyTrue) {
            throw invalid_argument("Selector: uninitialized selector");
        }
        if (!pruned[index]) {
            selectedCount--;
        }
        pruned[index] = true;
    }

    bool isSelected(const size_t index) const
    {
        if (constantlyTrue) {
            return true;
        }
        return !pruned[index];
    }

    size_t size() const
    { return n; }

    size_t getSelectedCount() const
    { return selectedCount; }

private:
    size_t n;
    size_t selectedCount;
    vector<short> pruned;
    bool constantlyTrue;
};
