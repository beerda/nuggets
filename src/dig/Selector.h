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
    Selector(const size_t size, const bool constantlyTrue)
        : n(size), selectedCount(size), pruned(nullptr)
    {
        if (!constantlyTrue) {
            pruned = new bool[size](); // Initialize to false
        }
    }

    // Move constructor
    Selector(Selector&& other) noexcept
        : n(other.n), selectedCount(other.selectedCount), pruned(other.pruned)
    {
        other.n = 0;
        other.selectedCount = 0;
        other.pruned = nullptr;
    }


    // Move assignment operator
    Selector& operator=(Selector&& other) noexcept
    {
        if (this != &other) {
            if (pruned) {
                delete[] pruned;
            }
            n = other.n;
            selectedCount = other.selectedCount;
            pruned = other.pruned;

            other.n = 0;
            other.selectedCount = 0;
            other.pruned = nullptr;
        }

        return *this;
    }

    ~Selector()
    {
        if (pruned) {
            delete[] pruned;
        }
    }

    // Disable copy
    Selector(const Selector&) = delete;
    Selector& operator=(const Selector&) = delete;

    inline void unselect(const size_t index)
    {
        if (UNLIKELY(pruned == nullptr)) {
            throw invalid_argument("Selector: uninitialized selector");
        }
        if (LIKELY(!pruned[index])) {
            selectedCount--;
        }
        pruned[index] = true;
    }

    inline bool isSelected(const size_t index) const
    {
        if (pruned == nullptr) {
            return true;
        }
        return !pruned[index];
    }

    inline size_t size() const
    { return n; }

    inline size_t getSelectedCount() const
    { return selectedCount; }

private:
    size_t n;
    size_t selectedCount;
    bool* pruned;
};
