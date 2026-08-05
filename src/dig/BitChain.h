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
#include "BaseChain.h"
#include "Bitset.h"


/**
 * Implementation of chain of bits. This class can be used as the CHAIN template
 * parameter of Digger. It stores a vector of bits representing TRUE/FALSE
 * values for a predicate or clause in the data. BitChain may be constructed
 * from LogicalVector only.
 */
class BitChain : public BaseChain {
public:
    /**
     * Default constructor that creates an empty chain of type CONDITION with
     * empty clause.
     *
     * @param sum The sum of TRUEs in the chain.
     */
    BitChain(double sum)
        : BaseChain(sum)
    { }

    /**
     * Constructor that creates a chain with the specified id and type from
     * a LogicalVector. The sum of TRUEs is computed from the vector and stored
     * in the chain.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate.
     * @param vec The LogicalVector from which to create the chain.
     */
    BitChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); ++i) {
            if (vec[i]) {
                data.set(i);
                this->sum++;
            }
        }
    }

    /**
     * Constructor for creating a chain from a NumericVector. This constructor
     * is not implemented and will throw an invalid_argument exception if called.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate.
     * @param vec The NumericVector from which to create the chain.
     */
    BitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    { throw std::invalid_argument("BitChain: NumericVector constructor not implemented"); }

    /**
     * Constructor that creates a chain by combining two chains with a conjunction.
     * The sum of TRUEs is computed from the conjunction of the two chains.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    BitChain(const BitChain& a, const BitChain& b)
        : BaseChain(a, b),
          data(a.data & b.data)
    { sum = data.count(); }

    /**
     * Constructor that creates a chain by combining two chains with a conjunction
     * and a specified sum of TRUEs. This constructor is used when the sum is
     * already known and does not need to be computed from the conjunction of the
     * two chains. Therefore, the chain is marked as cached.
     *
     * @param a The first chain.
     * @param b The second chain.
     * @param sum The sum of TRUEs in the conjunction of the two chains.
     */
    BitChain(const BitChain& a, const BitChain& b, const double sum)
        : BaseChain(a, b, sum),
          data()
    { }

    // Disable copy
    BitChain(const BitChain& other) = delete;
    BitChain& operator=(const BitChain& other) = delete;

    // Allow move
    BitChain(BitChain&& other) = default;
    BitChain& operator=(BitChain&& other) = default;

    /**
     * Checks if two BitChain objects are equal.
     *
     * @param other The other BitChain object to compare with.
     * @return True if the two BitChain objects are equal, false otherwise.
     */
    inline bool operator==(const BitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    /**
     * Checks if two BitChain objects are not equal.
     *
     * @param other The other BitChain object to compare with.
     * @return True if the two BitChain objects are not equal, false otherwise.
     */
    inline bool operator!=(const BitChain& other) const
    { return !(*this == other); }

    /**
     * Returns the value at the specified index in the BitChain.
     *
     * @param index The index of the value to retrieve.
     * @return The value at the specified index (true or false).
     */
    inline bool operator[](const size_t index) const
    { return data[index]; }

    /**
     * Returns the value at the specified index in the BitChain with bounds
     * checking. If the index is out of range, an exception will be thrown.
     *
     * @param index The index of the value to retrieve.
     * @return The value at the specified index (true or false).
     */
    inline bool at(const size_t index) const
    { return data.at(index); }

    /**
     * Returns the size of the BitChain, i.e., the number of true/false values
     * in the chain.
     *
     * @return The size of the BitChain.
     */
    inline size_t size() const
    { return data.size(); }

    /**
     * Checks if the BitChain is empty.
     *
     * @return True if the BitChain is empty, false otherwise.
     */
    inline bool empty() const
    { return data.empty(); }

    /**
     * Returns a string representation of the BitChain for debugging purposes.
     *
     * @return A string representation of the BitChain.
     */
    inline string toString() const
    {
        stringstream res;

        if (this->isCached()) {
            res << "[cached:" << this->getSum() << "]";
        }
        else {
            res << "[n=" << data.size() << "]";
            for (size_t i = 0; i < data.size(); ++i) {
                res << data[i];
            }
        }

        return res.str();
    }

private:
    /**
     * The underlying bitset storing the boolean values of the chain.
     */
    Bitset data;
};
