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

#include <algorithm>

#include "../common.h"
#include "Config.h"
#include "CombinatorialProgress.h"
#include "ChainCollection.h"
#include "Selector.h"
#include "TautologyTree.h"


template <typename CHAIN, typename STORAGE>
class Digger {
public:
    Digger(const Config& config,
           const List& data,
           const LogicalVector& isCondition,
           const LogicalVector& isFocus,
           STORAGE& storage)
        : storage(storage),
          config(config),
          initialCollection(data, isCondition, isFocus),
          predicateSums(data.size() + 1),
          tree(initialCollection),
          progress(nullptr)
    {
        for (const CHAIN& chain : initialCollection) {
            size_t id = chain.getClause().back();
            predicateSums[id] = chain.getSum();
        }

        tree.addTautologies(config.getExcluded());
    }

    // Disable copy
    Digger(const Digger&) = delete;
    Digger& operator=(const Digger&) = delete;

    // Allow move
    Digger(Digger&&) = default;
    Digger& operator=(Digger&&) = default;

    void run()
    {
        ChainCollection<CHAIN> filteredCollection;
        CHAIN emptyChain(config.getNrow());
        tree.updateDeduction(emptyChain);

        for (size_t i = 0; i < initialCollection.size(); ++i) {
            CHAIN& chain = initialCollection[i];
            if (isNonRedundant(emptyChain, chain)) {
                if (isCandidate(chain)) {
                    filteredCollection.append(std::move(chain));
                }
            }
        }

        progress = new CombinatorialProgress(config.getMaxLength(),
                                             filteredCollection.conditionCount());

        // cli progress bar has to be protected from R's garbage collector
        SEXP bar = PROTECT(cli_progress_bar(progress->getTotal(),
                                            List::create(Named("name") = "searching rules")));
        progress->assignBar(bar);
        {
            auto batch = progress->createBatch(0, filteredCollection.conditionCount());
            processChildrenChains(emptyChain, filteredCollection);
        }
        delete progress;

        // free the protection from R's garbage collector
        UNPROTECT(1);
    }

private:
    STORAGE& storage;
    const Config& config;
    ChainCollection<CHAIN> initialCollection;
    vector<float> predicateSums;
    TautologyTree<CHAIN> tree;
    CombinatorialProgress* progress;

    void processChains(ChainCollection<CHAIN>& collection)
    {
        const size_t condCount = collection.conditionCount();
        for (size_t i = 0; i < condCount; ++i) {
            ChainCollection<CHAIN> childCollection;
            CHAIN& chain = collection[i];
            const auto batch = progress->createBatch(chain.getClause().size(),
                                                      condCount - i - 1);

            tree.updateDeduction(chain);
            if (UNLIKELY(chain.deducesItself()))
                continue;

            if (LIKELY(isExtendable(chain))) {
                // need conjunction with everything
                combine(childCollection, collection, i, false);
            }
            else if (collection.hasFoci()) {
                // need conjunction with foci only
                combine(childCollection, collection, i, true);
            }
            else {
                // do not need childCollection at all
            }

            processChildrenChains(chain, childCollection);
        }
    }

    void processChildrenChains(const CHAIN& chain, ChainCollection<CHAIN>& childCollection)
    {
        if (LIKELY(!config.hasFilterEmptyFoci() || childCollection.hasFoci())) {
            if (isStorable(chain)) {
                Selector selector = createSelectorOfStorable(chain, childCollection);
                if (LIKELY(isStorable(selector))) {
                    storage.store(chain, childCollection, selector, predicateSums);
                }
            }
            progress->increment(1);
            if (LIKELY(isExtendable(chain))) {
                processChains(childCollection);
            }
        }
    }

    void combine(ChainCollection<CHAIN>& target,
                 ChainCollection<CHAIN>& parent,
                 const size_t conditionChainIndex,
                 const bool onlyFoci) const
    {
        CHAIN& conditionChain = parent[conditionChainIndex];

        size_t begin = conditionChainIndex + 1;
        const size_t firstFocusIdx = parent.firstFocusIndex();
        if (onlyFoci && begin < firstFocusIdx) {
            begin = firstFocusIdx;
        }

        const size_t bothLen = (conditionChainIndex > firstFocusIdx) ? conditionChainIndex - firstFocusIdx : 0;
        const size_t parentSize = parent.size();

        target.reserve(parentSize - begin + bothLen);
        for (size_t i = begin; i < parentSize; ++i) {
            combineInternal(target, conditionChain, parent[i], false);
        }
        for (size_t i = firstFocusIdx; i < conditionChainIndex; ++i) {
            combineInternal(target, conditionChain, parent[i], true);
        }
    }

    inline void combineInternal(ChainCollection<CHAIN>& target,
                                const CHAIN& conditionChain,
                                const CHAIN& secondChain,
                                const bool toFocus) const
    {
        if (isNonRedundant(conditionChain, secondChain)) {
            CHAIN newChain(conditionChain, secondChain, toFocus);
            if (isCandidate(newChain)) {
                target.append(std::move(newChain));
            }
        }
    }

    inline bool isNonRedundant(const CHAIN& parent, const CHAIN& chain) const
    {
        const Clause& parentClause = parent.getClause();
        const size_t curr = chain.getClause().back();

        if (LIKELY(parentClause.size() > 0)) {
            const size_t pref = parentClause.back();

            // Quick equality check first (unlikely to match)
            if (UNLIKELY(pref == curr)) {
                // Filter of focus even if disjoint is not defined
                // (should never happen as we always have disjoint defined)
                return false;
            }

            // Check disjoint constraint if enabled (unlikely to be redundant)
            if (LIKELY(config.hasDisjoint()) && UNLIKELY(config.getDisjoint()[pref] == config.getDisjoint()[curr])) {
                // It is enough to check the last element of the prefix because
                // previous elements were already checked in parent tasks
                //cout << "redundant: " << parent.clauseAsString() << " , " << chain.clauseAsString() << endl;
                return false;
            }
        }

        // Check deduction (more expensive) last - unlikely to deduce
        if (LIKELY(config.hasFilterExcluded()) && UNLIKELY(parent.deduces(curr))) {
            return false;
        }

        return true;
    }

    inline bool isCandidate(const CHAIN& chain) const
    {
        //cout << "chain.getSum() = " << chain.getSum() << " config.getMinSum() = " << config.getMinSum() << endl;
        const float sum = chain.getSum();
        if (LIKELY(chain.isCondition())) {
            return sum >= config.getMinSum();
        }
        if (chain.isFocus()) {
            return sum >= config.getMinFocusSum();
        }
        return false;
    }

    inline bool isExtendable(const CHAIN& chain) const
    {
        // Check cheapest conditions first - most likely to pass these checks
        return LIKELY(chain.getSum() >= config.getMinSum())
            && LIKELY(chain.getClause().size() < config.getMaxLength())
            && LIKELY(storage.size() < config.getMaxResults());
    }

    inline bool isStorable(const CHAIN& chain) const
    {
        // Check cheapest conditions first, then more expensive ones
        const float sum = chain.getSum();
        return LIKELY(sum >= config.getMinSum())
            && LIKELY(sum <= config.getMaxSum())
            && LIKELY(chain.getClause().size() >= config.getMinLength())
            && LIKELY(storage.size() < config.getMaxResults());
    }

    inline bool isStorable(const Selector& selector) const
    { return (!config.hasFilterEmptyFoci() || LIKELY(selector.getSelectedCount() > 0)); }

    Selector createSelectorOfStorable(const CHAIN& chain, const ChainCollection<CHAIN>& collection) const
    {
        const bool constant = config.getMinConditionalFocusSupport() <= 0.0f;
        Selector result(collection.focusCount(), constant);
        if (UNLIKELY(!constant)) {
            const float chainSumReciprocal = 1.0f / chain.getSum();
            const float minSupport = config.getMinConditionalFocusSupport();
            const size_t focusCount = collection.focusCount();
            const size_t firstFocus = collection.firstFocusIndex();
            
            for (size_t i = 0; i < focusCount; ++i) {
                const CHAIN& focus = collection[i + firstFocus];
                if (UNLIKELY(focus.getSum() * chainSumReciprocal < minSupport)) {
                    result.unselect(i);
                }
            }
        }

        return result;
    }
};
