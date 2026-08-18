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


/**
 * Tracks the selected elements of a fixed-size collection.
 */
class Selector {
public:
    /**
     * Creates a selector with storage for the specified number of elements.
     *
     * @param size The number of elements that may be selected.
     */
    Selector(const size_t size)
        : n(0), selectedCount(0), pruned(size), constantlyTrue(false)
    { }

    // Disable move
    Selector(Selector&& other) = delete;
    Selector& operator=(Selector&& other) = delete;

    // Disable copy
    Selector(const Selector&) = delete;
    Selector& operator=(const Selector&) = delete;

    /**
     * Initializes the selector.
     *
     * @param size The number of selected elements.
     * @param isConstantlyTrue Whether all elements should be treated as selected
     *     without tracking them individually.
     */
    inline void initialize(const size_t size, const bool isConstantlyTrue)
    {
        n = size;
        selectedCount = size;
        constantlyTrue = isConstantlyTrue;
        if (!constantlyTrue) {
            fill(pruned.begin(), pruned.end(), false);
        }
    }

    /**
     * Removes an element from the selection.
     *
     * @param index The index of the element to unselect.
     */
    inline void unselect(const size_t index)
    {
        if (constantlyTrue) {
            throw invalid_argument("Selector: uninitialized selector");
        }
        if (!pruned[index]) {
            selectedCount--;
        }
        pruned[index] = true;
    }

    /**
     * Checks whether an element is selected.
     *
     * @return TRUE if the element at the specified index is selected.
     */
    inline bool isSelected(const size_t index) const
    {
        if (constantlyTrue) {
            return true;
        }
        return !pruned[index];
    }

    /**
     * Returns the number of elements managed by the selector.
     *
     * @return The number of elements managed by the selector.
     */
    inline size_t size() const
    { return n; }

    /**
     * Returns the number of selected elements.
     *
     * @return The number of selected elements.
     */
    inline size_t getSelectedCount() const
    { return selectedCount; }

private:
    /**
     * Number of elements managed by the selector.
     */
    size_t n;

    /**
     * Number of elements that remain selected.
     */
    size_t selectedCount;

    /**
     * Flags indicating which elements have been unselected.
     */
    vector<uint8_t> pruned;

    /**
     * Whether all elements are implicitly selected.
     */
    bool constantlyTrue;
};
