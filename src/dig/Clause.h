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
 * Clause is a class that represents a conjunction of predicates by storing their
 * IDs in a vector.
 */
class Clause : public vector<size_t> {
private:
    // Copy constructor is private, use clone() for public copy
    Clause(const Clause& other) = default;

public:
    /**
     * Default constructor for Clause. Initializes an empty Clause.
     */
    Clause() = default;

    // Disable copy (use clone() to copy)
    Clause& operator=(const Clause& other) = delete;

    // Allow move
    Clause(Clause&& other) = default;
    Clause& operator=(Clause&& other) = default;

    /**
     * Constructs a Clause with a specified number of predicates.
     *
     * @param n The number of predicates in the Clause.
     */
    Clause(size_t n)
        : vector<size_t>(n)
    { }

    /**
     * Constructs a Clause from an initializer list of predicate IDs.
     *
     * @param init An initializer list containing the predicate IDs.
     */
    Clause(initializer_list<size_t> init)
        : vector<size_t>(init)
    { }

    /**
     * Creates a copy of the current Clause.
     *
     * @return A new Clause that is a copy of the current Clause.
     */
    Clause clone() const
    { return Clause(*this); }

    /**
     * Comparison (equality) operator for Clause.
     *
     * @param other The other Clause to compare with.
     * @return True if the two Clauses are equal, false otherwise.
     */
    bool operator==(const Clause& other) const
    {
        if (size() != other.size())
            return false;

        for (size_t i = 0; i < size(); ++i) {
            if (operator[](i) != other.operator[](i))
                return false;
        }

        return true;
    }

    /**
     * Sorts the predicate IDs in the Clause in ascending order.
     */
    inline void sort()
    { std::sort(begin(), end()); }

    /**
     * Sorts the predicate IDs in the Clause in ascending order and removes
     * duplicate predicate IDs.
     */
    inline void sortAndUnique()
    {
        std::sort(begin(), end());
        erase(std::unique(begin(), end()), end());
    }

    /**
     * Checks if the Clause contains a specific predicate ID.
     *
     * @param predicate The predicate ID to check for.
     * @return True if the Clause contains the specified predicate ID, false otherwise.
     */
    inline bool contains(size_t predicate) const
    { return std::find(begin(), end(), predicate) != end(); }

    /**
     * Returns a string representation of the Clause in the format
     * "{predicate1,predicate2,...}".
     *
     * @return A string representation of the Clause.
     */
    inline string toString() const
    {
        stringstream res;
        res << "{";
        for (size_t i = 0; i < size(); ++i) {
            if (i > 0) {
                res << ",";
            }
            res << at(i);
        }
        res << "}";

        return res.str();
    }
};
