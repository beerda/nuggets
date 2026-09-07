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
#include "Clause.h"
#include "Config.h"
#include "ChainCollection.h"
#include "Selector.h"


/**
 * A class applicable for STORAGE template parameter of Digger. It stores
 * discovered itemsets with basic statistics.
 */
template <typename CHAIN>
class ItemsetStorage {
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
        : itemsets(),
          config(config)
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
     * @param prefix Prefix of predicate IDs from the search recursion.
     * @param chain Current chain to be stored.
     * @param collection Unused for itemset storage.
     * @param selector Unused for itemset storage.
     * @param predicateSums Unused for itemset storage.
     */
    void store(const Clause& prefix,
               const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<double>& predicateSums)
    {
        (void) collection;
        (void) selector;
        (void) predicateSums;

        if (itemsets.size() >= config.getMaxResults())
            return;

        Itemset itemset;
        itemset.items = formatCondition(prefix, chain);
        itemset.length = prefix.size() + chain.hasPredicate();
        itemset.chainSum = chain.getSum();
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

    /**
     * The configuration object.
     */
    const Config& config;

    /**
     * Formats itemset predicates as a string representation enclosed in
     * curly braces.
     *
     * @param prefix Prefix of predicate IDs.
     * @param chain Chain holding the currently processed predicate.
     * @return Formatted itemset string.
     */
    string formatCondition(const Clause& prefix, const CHAIN& chain) const
    {
        if (prefix.empty() && !chain.hasPredicate()) {
            return "{}";
        }

        IF_DEBUG(
            if (!chain.hasPredicate())
                throw invalid_argument("ItemsetStorage: formatCondition: chain has no predicate");
        )

        stringstream res;
        res << "{";

        if (prefix.size() == 0) {
            res << config.getChainName(chain.getPredicate());
        }
        else {
            const string& name0 = config.getChainName(chain.getPredicate());

            if (prefix.size() == 1) {
                const string& name1 = config.getChainName(prefix[0]);
                if (name0 < name1) {
                    res << name0 << "," << name1;
                } else {
                    res << name1 << "," << name0;
                }
            }
            else if (prefix.size() == 2) {
                const string& name1 = config.getChainName(prefix[0]);
                const string& name2 = config.getChainName(prefix[1]);
                if (name0 <= name1) {
                    if (name1 <= name2) {
                        res << name0 << "," << name1 << "," << name2;
                    }
                    else if (name0 <= name2) {
                        res << name0 << "," << name2 << "," << name1;
                    }
                    else {
                        res << name2 << "," << name0 << "," << name1;
                    }
                }
                else {
                    if (name0 <= name2) {
                        res << name1 << "," << name0 << "," << name2;
                    }
                    else if (name1 <= name2) {
                        res << name1 << "," << name2 << "," << name0;
                    }
                    else {
                        res << name2 << "," << name1 << "," << name0;
                    }
                }
            }
            else {
                vector<string> parts;
                parts.reserve(prefix.size() + 1);
                parts.push_back(name0);
                for (size_t predicate : prefix) {
                    parts.push_back(config.getChainName(predicate));
                }
                sort(parts.begin(), parts.end());
                res << parts.front();
                for (size_t i = 1; i < parts.size(); ++i) {
                    res << "," << parts[i];
                }
            }
        }

        res << "}";

        return res.str();
    }
};
