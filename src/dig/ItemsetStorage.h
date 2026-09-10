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
#include "BaseStorage.h"
#include "Clause.h"
#include "Config.h"
#include "ChainCollection.h"
#include "Pattern.h"
#include "Selector.h"


/**
 * A class applicable for STORAGE template parameter of Digger. It stores
 * discovered itemsets with basic statistics.
 */
class ItemsetStorage : public BaseStorage {
    /**
     * The initial capacity of the itemsets vector.
     */
    static constexpr size_t INITIAL_RESULT_CAPACITY = 1024;

    /**
     * A structure representing a discovered itemset.
     */
    struct Itemset {
        double chainSum;
        string items;
        int length;
    };

public:
    /**
     * Constructs a new ItemsetStorage instance with the given configuration.
     *
     * @param config The configuration object containing search parameters.
     */
    ItemsetStorage(const Config& config)
        : BaseStorage(config),
          itemsets()
    {
        size_t capacity = config.getMaxResults();
        if (capacity >= SIZE_MAX) {
            capacity = INITIAL_RESULT_CAPACITY;
        }
        itemsets.reserve(capacity);
    }

    // Disable copy
    ItemsetStorage(const ItemsetStorage&) = delete;
    ItemsetStorage& operator=(const ItemsetStorage&) = delete;

    // Allow move
    ItemsetStorage(ItemsetStorage&&) = default;
    ItemsetStorage& operator=(ItemsetStorage&&) = default;

    /**
     * Stores a discovered itemset represented by the current prefix and chain.
     *
     * @param pattern The Pattern object representing the discovered chain and its
     *     associated data.
     */
    void store(const Pattern& pattern)
    {
        Itemset itemset;
        itemset.items = formatCondition(pattern.getPrefix(), pattern.getPredicatePtr());
        itemset.length = pattern.getConditionLength();
        itemset.chainSum = pattern.getConditionSum();
        itemsets.push_back(itemset);
    }

    /**
     * Returns the number of stored itemsets.
     */
    inline size_t size() const
    { return itemsets.size(); }

    /**
     * Returns stored itemsets as a List of R vectors.
     *
     * @return A List containing itemset data vectors.
     */
    inline List getResult() const
    {
        CharacterVector itemsVec(itemsets.size());
        NumericVector supportVec(itemsets.size());
        NumericVector countVec(itemsets.size());
        IntegerVector lengthVec(itemsets.size());

        for (size_t i = 0; i < itemsets.size(); ++i) {
            const Itemset& itemset = itemsets[i];
            itemsVec[i] = itemset.items;
            supportVec[i] = itemset.chainSum / config.getNrow();
            countVec[i] = itemset.chainSum;
            lengthVec[i] = itemset.length;
        }

        return List::create(Named("itemset") = itemsVec,
                            Named("support") = supportVec,
                            Named("n") = countVec,
                            Named("length") = lengthVec);
    }

private:
    /**
     * A vector of stored itemsets.
     */
    vector<Itemset> itemsets;
};
