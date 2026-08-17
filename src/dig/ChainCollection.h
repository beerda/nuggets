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
#include "../timer.h"
#include "BaseChain.h"


/**
 * Collection of predicate chains used during digging.
 */
template <typename CHAIN>
class ChainCollection {
public:
    /**
     * Type of chains stored in the collection.
     */
    using ChainType = CHAIN;

    /**
     * Creates an empty chain collection.
     */
    ChainCollection()
        : chains(), nConditions(0), nFoci(0)
    { }

    /**
     * Creates chains from input data and their predicate roles.
     *
     * @param data The logical or numeric predicate vectors.
     * @param isConditionVec Whether each predicate may occur in a condition.
     * @param isFocusVec Whether each predicate may occur in a focus.
     */
    ChainCollection(const List& data,
                    const LogicalVector& isConditionVec,
                    const LogicalVector& isFocusVec)
        : chains(), nConditions(0), nFoci(0)
    {
        BLOCK_TIMER(bt, "ChainCollection::ChainCollection - load data into chains");

        if (data.size() != isConditionVec.size() || data.size() != isFocusVec.size()) {
            throw std::invalid_argument("ChainCollection: data, isCondition and isFocus vectors must have the same length");
        }
        chains.reserve(data.size());
        for (R_xlen_t i = 0; i < data.size(); ++i) {
            bool isCondition = isConditionVec[i];
            bool isFocus = isFocusVec[i];

            if (isCondition || isFocus) {
                if (isCondition) nConditions++;
                if (isFocus) nFoci++;
                int id = i + 1;
                PredicateType type = BaseChain::createPredicateType(isCondition, isFocus);
                if (Rf_isLogical(data[i])) {
                    const LogicalVector& vec = data[i];
                    chains.emplace_back(id, type, vec);
                }
                else if (Rf_isReal(data[i])) {
                    const NumericVector& vec = data[i];
                    chains.emplace_back(id, type, vec);
                }
                else {
                    throw std::invalid_argument("ChainCollection: unsupported data type");
                }
            }
        }
        sortChains();
    }

    // Disable copy
    ChainCollection(const ChainCollection&) = delete;
    ChainCollection& operator=(const ChainCollection&) = delete;

    // Allow move
    ChainCollection(ChainCollection&&) = default;
    ChainCollection& operator=(ChainCollection&&) = default;

    /**
     * Reserves storage for chains.
     *
     * @param size The number of chains to reserve storage for.
     */
    inline void reserve(const size_t size)
    { chains.reserve(size); }

    /**
     * Returns the number of chains.
     *
     * @return The number of chains.
     */
    inline size_t size() const
    { return chains.size(); }

    /**
     * Checks whether the collection has no chains.
     *
     * @return TRUE if the collection is empty.
     */
    inline bool empty() const
    { return chains.empty(); }

    /**
     * Returns the chain at the specified index with bounds checking.
     *
     * @return The chain at the specified index.
     */
    inline const CHAIN& at(const size_t i) const
    { return chains.at(i); }

    /**
     * Returns the chain at the specified index without bounds checking.
     *
     * @return The chain at the specified index.
     */
    inline CHAIN& operator[](const size_t i)
    { return chains[i]; }

    /**
     * Returns the chain at the specified index without bounds checking.
     *
     * @return The chain at the specified index.
     */
    inline const CHAIN& operator[](const size_t i) const
    { return chains[i]; }

    /**
     * Returns an iterator to the first chain.
     *
     * @return A const iterator to the first chain.
     */
    inline typename vector<CHAIN>::const_iterator begin() const
    { return chains.begin(); }

    /**
     * Returns an iterator past the last chain.
     *
     * @return A const iterator past the last chain.
     */
    inline typename vector<CHAIN>::const_iterator end() const
    { return chains.end(); }

    /**
     * Appends a chain by moving it into the collection.
     *
     * @param chain The chain to append.
     */
    void append(CHAIN&& chain)
    {
        chains.push_back(std::move(chain));
        if (chains.back().isCondition()) nConditions++;
        if (chains.back().isFocus()) nFoci++;
    }

    /**
     * Returns the index of the first focus chain.
     *
     * @return The index of the first focus chain.
     */
    inline size_t firstFocusIndex() const
    { return size() - focusCount(); }

    /**
     * Returns the number of condition chains.
     *
     * @return The number of condition chains.
     */
    inline size_t conditionCount() const
    { return nConditions; }

    /**
     * Returns the number of focus chains.
     *
     * @return The number of focus chains.
     */
    inline size_t focusCount() const
    { return nFoci; }

    /**
     * Checks whether the collection contains condition chains.
     *
     * @return TRUE if the collection contains at least one condition chain.
     */
    inline bool hasConditions() const
    { return nConditions > 0; }

    /**
     * Checks whether the collection contains focus chains.
     *
     * @return TRUE if the collection contains at least one focus chain.
     */
    inline bool hasFoci() const
    { return nFoci > 0; }

private:
    /**
     * Chains sorted by predicate type and descending sum.
     */
    vector<CHAIN> chains;

    /**
     * Number of chains that may appear in a condition.
     */
    size_t nConditions;

    /**
     * Number of chains that may appear in a focus.
     */
    size_t nFoci;

    /**
     * Sorts chains by predicate type and descending sum.
     */
    void sortChains()
    {
        std::sort(chains.begin(), chains.end(), [](const CHAIN& a, const CHAIN& b) {
            if (a.getPredicateType() == b.getPredicateType()) {
                return a.getSum() > b.getSum();
            }
            return a.getPredicateType() < b.getPredicateType();
        });
    }
};
