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
#include "../timer.h"
#include "Config.h"
#include "CombinatorialProgress.h"
#include "ChainCollection.h"
#include "Selector.h"
#include "Cache.h"
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
          selectorSingleton(initialCollection.focusCount()),
          cache(data.size() + 1),
          tree(initialCollection),
          progress(nullptr)
    {
        BLOCK_TIMER(t, "Digger::Constructor");
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
        START_TIMER(t, "Digger::run");

        ChainCollection<CHAIN> filteredCollection;
        filteredCollection.reserve(initialCollection.size());

        CHAIN emptyChain(config.getNrow());
        tree.updateDeduction(emptyChain);

        for (size_t i = 0; i < initialCollection.size(); ++i) {
            CHAIN& chain = initialCollection[i];
            addSumToCache(chain);
            if (isNonRedundant(emptyChain, chain)
                    && isNonTautological(emptyChain, chain)
                    && isCandidate(chain)) {
                filteredCollection.append(std::move(chain));
            }
        }

        progress = new CombinatorialProgress(config.getMaxLength(),
                                             filteredCollection.conditionCount());

        // cli progress bar has to be protected from R's garbage collector
        SEXP bar = PROTECT(cli_progress_bar(progress->getTotal(),
                                            List::create(Named("name") = "searching rules")));
        progress->assignBar(bar);

        STOP_TIMER(t);
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
    vector<double> predicateSums;
    Selector selectorSingleton;
    Cache cache;
    TautologyTree<CHAIN> tree;
    CombinatorialProgress* progress;

    void processChildrenChains(const CHAIN& chain, ChainCollection<CHAIN>& collection)
    {
        if (!config.hasFilterEmptyFoci() || collection.hasFoci()) {

            if (isStorable(chain)) {
                BLOCK_INC_TIMER(st, t, "Digger::processChildrenChains - store");

                // return singleton selector to avoid allocations
                const Selector& selector = initializeSelectorOfStorable(chain, collection);
                if (isStorable(selector)) {
                    storage.store(chain, collection, selector, predicateSums);
                }
            }
            progress->increment(1);

            if (isExtendable(chain)) {
                for (size_t i = 0; i < collection.conditionCount(); ++i) {
                    ChainCollection<CHAIN> childCollection;

                    CHAIN& chain = collection[i];
                    auto batch = progress->createBatch(chain.getClause().size(),
                                                       collection.conditionCount() - i - 1);

                    {
                        BLOCK_INC_TIMER(st, t, "Digger::processChildrenChains - for loop");

                        tree.updateDeduction(chain);
                        if (chain.deducesItself())
                            continue;

                        if (isExtendable(chain)) {
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
                    }

                    processChildrenChains(chain, childCollection);
                }
            }
        }
    }

    void combine(ChainCollection<CHAIN>& target,
                 ChainCollection<CHAIN>& parent,
                 const size_t conditionChainIndex,
                 bool onlyFoci)
    {
        BLOCK_INC_TIMER(st, t, "Digger::combine");

        CHAIN& conditionChain = parent[conditionChainIndex];

        size_t begin = conditionChainIndex + 1;
        if (onlyFoci && begin < parent.firstFocusIndex()) {
            begin = parent.firstFocusIndex();
        }

        size_t bothLen = (conditionChainIndex > parent.firstFocusIndex()) ? conditionChainIndex - parent.firstFocusIndex() : 0;

        target.reserve(parent.size() - begin + bothLen);
        for (size_t i = begin; i < parent.size(); ++i) {
            CHAIN& secondChain = parent[i];
            if (secondChain.isCached()) {
                combineByCache(target, conditionChain, secondChain);
            }
            else {
                combineByConjunction(target, conditionChain, secondChain);
            }
        }
        for (size_t i = parent.firstFocusIndex(); i < conditionChainIndex; ++i) {
            combineByCache(target, conditionChain, parent[i]);
        }
    }

    inline void combineByConjunction(ChainCollection<CHAIN>& target,
                              const CHAIN& conditionChain,
                              const CHAIN& secondChain)
    {
        BLOCK_INC_TIMER(st, t, "Digger::combineByConjunction");

        if (isNonRedundant(conditionChain, secondChain)) {
            CHAIN newChain(conditionChain, secondChain);
            addSumToCache(newChain);
            if (isNonTautological(conditionChain, secondChain)
                    && isCandidate(newChain)) {
                target.append(std::move(newChain));
            }
        }
    }

    inline void combineByCache(ChainCollection<CHAIN>& target,
                        const CHAIN& conditionChain,
                        const CHAIN& secondChain)
    {
        BLOCK_INC_TIMER(st, t, "Digger::combineByCache");

        if (isNonRedundant(conditionChain, secondChain)
                && isNonTautological(conditionChain, secondChain)) {
            CHAIN newChain(conditionChain, secondChain, 0);
            double sum = getSumFromCache(newChain);

            // not being in cache means that the conjunction is not frequent
            if (sum != Cache::NOT_IN_CACHE) {
                newChain.setSum(sum);
                if (isCandidate(newChain)) {
                    target.append(std::move(newChain));
                }
            }
        }
    }

    inline bool isNonRedundant(const CHAIN& parent, const CHAIN& chain) const
    {
        if (parent.getClause().size() > 0) {
            size_t pref = parent.getClause().back();
            size_t curr = chain.getClause().back();

            if (pref == curr) {
                // Filter of focus even if disjoint is not defined
                // (should never happen as we always have disjoint defined)
                return false;
            }

            if (config.hasDisjoint() && config.getDisjoint()[pref] == config.getDisjoint()[curr]) {
                // It is enough to check the last element of the prefix because
                // previous elements were already checked in parent tasks
                //cout << "redundant: " << parent.clauseAsString() << " , " << chain.clauseAsString() << endl;
                return false;
            }
        }

        return true;
    }

    inline bool isNonTautological(const CHAIN& parent, const CHAIN& chain) const
    {
        if (config.hasFilterExcluded()) {
            size_t curr = chain.getClause().back();
            if (parent.deduces(curr)) {
                return false;
            }
        }

        return true;
    }

    inline bool isCandidate(const CHAIN& chain) const
    {
        //cout << "chain.getSum() = " << chain.getSum() << " config.getMinSum() = " << config.getMinSum() << endl;
        if (chain.isCondition() && chain.getSum() >= config.getMinSum())
            return true;

        if (chain.isFocus() && chain.getSum() >= config.getMinFocusSum())
            return true;

        return false;
    }

    inline bool isExtendable(const CHAIN& chain) const
    {
        return chain.getClause().size() < config.getMaxLength()
            && chain.getSum() >= config.getMinSum()
            && storage.size() < config.getMaxResults();
    }

    inline bool isStorable(const CHAIN& chain) const
    {
        return chain.getClause().size() >= config.getMinLength()
            && chain.getSum() >= config.getMinSum()
            && chain.getSum() <= config.getMaxSum()
            && storage.size() < config.getMaxResults();
    }

    inline bool isStorable(const Selector& selector) const
    { return (!config.hasFilterEmptyFoci() || selector.getSelectedCount() > 0); }

    inline const Selector& initializeSelectorOfStorable(const CHAIN& chain, const ChainCollection<CHAIN>& collection)
    {
        bool constant = config.getMinConditionalFocusSupport() <= 0.0;
        selectorSingleton.initialize(collection.focusCount(), constant);
        if (!constant) {
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                if (1.0 * focus.getSum() / chain.getSum() < config.getMinConditionalFocusSupport()) {
                    selectorSingleton.unselect(i);
                }
            }
        }

        return selectorSingleton;
    }

    inline void addSumToCache(const CHAIN& chain)
    {
        BLOCK_INC_TIMER(st, t, "Digger::addSumToCache");

        Clause clause = chain.getClause().clone();
        clause.sort();
        cache.add(clause, chain.getSum());
    }

    inline double getSumFromCache(const CHAIN& chain) const
    {
        BLOCK_INC_TIMER(st, t, "Digger::getSumFromCache");

        Clause clause = chain.getClause().clone();
        clause.sort();
        return cache.get(clause);
    }
};
