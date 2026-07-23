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


class SearchStats {
public:
    // Disable copy
    SearchStats(const SearchStats&) = delete;
    SearchStats& operator=(const SearchStats&) = delete;

    // Allow move
    SearchStats(SearchStats&&) = default;
    SearchStats& operator=(SearchStats&&) = default;

    SearchStats()
        : computedConjunctions(0),
          cachedConjunctions(0)
    { }

    inline void startTimer()
    {  start = std::chrono::steady_clock::now(); }

    inline void stopTimer()
    {  stop = std::chrono::steady_clock::now(); }

    inline void incrementComputedConjunctions()
    { computedConjunctions++; }

    inline void incrementCachedConjunctions()
    { cachedConjunctions++; }

    inline List asR() const
    {
        double runtime = std::chrono::duration_cast<std::chrono::microseconds>(stop - start).count()
                / 1000.0;

        return List::create(Named("runtime_millis") = runtime,
                            Named("computed_conjunctions") = computedConjunctions,
                            Named("cached_conjunctions") = cachedConjunctions,
                            Named("total_conjunctions") = computedConjunctions + cachedConjunctions);
    }

private:
    std::chrono::steady_clock::time_point start;
    std::chrono::steady_clock::time_point stop;
    size_t computedConjunctions;
    size_t cachedConjunctions;
};
