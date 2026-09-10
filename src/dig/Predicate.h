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


/**
 * A class representing a predicate - predicate ID and the sum of TRUEs (for
 * binary data) or membership degrees (for fuzzy data).
 */
class Predicate {
public:
    /**
     * Constructs a new Predicate instance with the given sum and predicate ID.
     *
     * @param sum The sum of TRUEs (for binary data) or membership degrees (for
     *     fuzzy data) of the chain.
     * @param predicate The predicate ID
     */
    Predicate(size_t predicate, double sum)
        : sum(sum), predicate(predicate)
    { }

    /**
     * Returns the sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     *
     * @return The sum of TRUEs or membership degrees of the chain.
     */
    inline double getSum() const
    { return sum; }

    /**
     * Returns TRUE if the chain has a predicate, i.e., if the predicate is not empty.
     *
     * @return True if the chain has a predicate, false otherwise.
     */
    inline bool hasPredicate() const
    { return predicate != 0; }

    /**
     * Returns the predicate of the chain, i.e., the last predicate of the clause.
     * (Assuming that the prefix of the clause is stored in Digger::prefix.)
     *
     * @return The last predicate of the chain.
     */
    inline const size_t& getPredicate() const
    {
        IF_DEBUG(
            if (predicate == 0)
                throw invalid_argument("Predicate: predicate is empty");
        )

        return predicate;
    }

    /**
     * Returns a pointer to the predicate of the chain, i.e., the last predicate
     * of the clause. (Assuming that the prefix of the clause is stored in
     * Digger::prefix.) If the predicate is empty, returns nullptr.
     *
     * @return A pointer to the last predicate of the chain, or nullptr if
     *     the predicate is empty.
     */
    inline const size_t* getPredicatePtr() const
    {
        if (predicate == 0)
            return nullptr;

        return &predicate;
    }

protected:
    /**
     * The sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     */
    double sum;

    /**
     * The last predicate in the condition. It forms the complete condition
     * clause together with the prefix stored in Digger::prefix.
     */
    size_t predicate;

};
