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


template <typename CHAIN>
class ChainCollection {
public:
    using ChainType = CHAIN;

    ChainCollection()
        : chains(), nConditions(0), nFoci(0)
    { }

    ChainCollection(const List& data,
                    const LogicalVector& isConditionVec,
                    const LogicalVector& isFocusVec)
        : chains(), nConditions(0), nFoci(0)
    {
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
                    chains.emplace_back(id, PredicateType(type), vec);
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

    void reserve(size_t size)
    { chains.reserve(size); }

    size_t size() const
    { return chains.size(); }

    bool empty() const
    { return chains.empty(); }

    const CHAIN& at(size_t i) const
    { return chains.at(i); }

    CHAIN& operator[](size_t i)
    { return chains[i]; }

    const CHAIN& operator[](size_t i) const
    { return chains[i]; }

    typename vector<CHAIN>::const_iterator begin() const
    { return chains.begin(); }

    typename vector<CHAIN>::const_iterator end() const
    { return chains.end(); }

    // append with move
    void append(CHAIN&& chain)
    {
        chains.push_back(std::move(chain));
        if (chains.back().isCondition()) nConditions++;
        if (chains.back().isFocus()) nFoci++;
    }

    size_t firstFocusIndex() const
    { return size() - focusCount(); }

    size_t conditionCount() const
    { return nConditions; }

    size_t focusCount() const
    { return nFoci; }

    bool hasConditions() const
    { return nConditions > 0; }

    bool hasFoci() const
    { return nFoci > 0; }

private:
    vector<CHAIN> chains;
    size_t nConditions;
    size_t nFoci;

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
