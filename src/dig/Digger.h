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
#include "Cache.h"
#include "Clause.h"
#include "Config.h"
#include "ChainCollection.h"
#include "CombinatorialProgress.h"
#include "DeductionEngine.h"
#include "SearchStats.h"
#include "Selector.h"


/**
 * A class that implements the main search algorithm for discovering rules in
 * the data. It takes a chain type (CHAIN) and a storage type (STORAGE) as
 * template parameters. The CHAIN type must be a descendant of the BaseChain
 * class, and the STORAGE type must implement the store() method for storing
 * discovered rules and the getResult() method for retrieving the final results.
 * The Digger class is responsible for traversing the search space of chains,
 * applying filters and conditions, and storing the valid rules in the provided
 * storage.
 */
template <typename CHAIN, typename STORAGE>
class Digger {
public:
    /**
     * Constructs a new Digger instance with the given configuration, data, and
     * storage.
     *
     * @param config The configuration object containing search parameters.
     * @param data The input data as a List of LogicalVector or NumericVector.
     * @param isCondition A LogicalVector indicating which predicates are
     *     conditions.
     * @param isFocus A LogicalVector indicating which predicates are foci.
     * @param storage The storage object for storing discovered rules.
     */
    Digger(const Config& config,
           const List& data,
           const LogicalVector& isCondition,
           const LogicalVector& isFocus,
           STORAGE& storage)
        : storage(storage),
          config(config),
          searchStats(),
          initialCollection(data, isCondition, isFocus),
          sortedPositions(data.size() + 1),
          predicateSums(data.size() + 1),
          prefix(),
          selectorSingleton(initialCollection.focusCount()),
          cache(data.size() + 1,
                std::min(config.getMaxLength(), initialCollection.conditionCount())),
          cacheQuery(),
          deductionEngine(data.size() + 1, config.getExcluded()),
          progress(nullptr)
    {
        BLOCK_TIMER(t, "Digger::Constructor");
        prefix.reserve(std::min(config.getMaxLength(), initialCollection.conditionCount()));
        cacheQuery.reserve(std::min(config.getMaxLength(), initialCollection.conditionCount()));

        size_t index = 0;
        for (const CHAIN& chain : initialCollection) {
            size_t id = chain.getPredicate();
            sortedPositions[id] = index;
            predicateSums[id] = chain.getSum();
            index++;
        }
    }

    // Disable copy
    Digger(const Digger&) = delete;
    Digger& operator=(const Digger&) = delete;

    // Allow move
    Digger(Digger&&) = default;
    Digger& operator=(Digger&&) = default;

    /**
     * Runs the search algorithm to discover rules in the data. It filters the
     * initial collection of chains, processes child chains recursively, and
     * stores valid rules in the provided storage. The search progress is
     * displayed using a progress bar, and the search statistics are collected
     * during the execution.
     */
    void run()
    {
        searchStats.startTimer();
        START_TIMER(t, "Digger::run");

        ChainCollection<CHAIN> filteredCollection;
        filteredCollection.reserve(initialCollection.size());
        CHAIN emptyChain(config.getNrow());

        for (size_t i = 0; i < initialCollection.size(); ++i) {
            CHAIN& chain = initialCollection[i];
            addSumToCache(emptyChain, chain, chain.getSum());
            if (isNonRedundant(emptyChain, chain)
                    && isCandidate(chain)
                    && !deductionEngine.isDerivableFromAxioms(chain.getPredicate())) {
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
        searchStats.stopTimer();
    }

    /**
     * Returns the final results of the search as a List of discovered rules and
     * search statistics stored as an attribute "search_stats".
     *
     * @return A List containing the discovered rules and search statistics
     *     stored as an attribute "search_stats".
     */
    List getResult() const
    {
        List result = storage.getResult();
        result.attr("search_stats") = searchStats.asR();

        return result;
    }

private:
    /**
     * The storage object for storing discovered rules.
     */
    STORAGE& storage;

    /**
     * The configuration object containing search parameters.
     */
    const Config& config;

    /**
     * The search statistics object for collecting statistics during the search.
     */
    SearchStats searchStats;

    /**
     * The initial collection of chains to be processed. Each chain represents
     * a predicate and its associated data, which correspond to input data
     * column.
     */
    ChainCollection<CHAIN> initialCollection;

    /**
     * A vector that stores the sorted positions of predicates based on their
     * sums of TRUEs or membership degrees. The index of the vector corresponds
     * to the predicate ID, and the value at that index represents the position
     * of the predicate in the sorted order. The vector is indexed from 1 to
     * match R's indexing convention, with index 0 reserved for the empty chain.
     */
    vector<size_t> sortedPositions;

    /**
     * A vector that stores the sums of TRUEs (for binary data) or membership degrees
     * (for fuzzy data) for each predicate in the data. The index of the vector
     * corresponds to the predicate ID, and the value at that index represents
     * the sum of TRUEs or membership degrees for that predicate.
     * The vector is indexed from 1 to match R's indexing convention, with
     * index 0 reserved for the empty chain.
     */
    vector<double> predicateSums;

    /**
     * Prefix of the current condition being processed. Vector stores IDs
     * of predicates.
     */
    Clause prefix;

    /**
     * A singleton Selector object used to avoid unnecessary allocations during
     * the search process.
     */
    Selector selectorSingleton;

    /**
     * A cache object used to store computed sums of chains to avoid redundant
     * calculations during the search process. The cache is indexed by the
     * Clause object (itemset) and stores the corresponding sum of TRUEs or
     * membership degrees.
     */
    Cache cache;

    /**
     * Preallocated vector used to query the cache for sums of chains.
     * It is used to avoid unnecessary allocations.
     */
    Clause cacheQuery;

    /**
     * A deduction engine used to check whether a predicate can be derived from
     * the initial axioms. It is used to filter out redundant chains during the
     * search process. The axioms come from the config.getExcluded() list.
     */
    DeductionEngine deductionEngine;

    /**
     * A pointer to a CombinatorialProgress object used to track the progress of
     * the search process. It provides a progress bar and allows for incremental
     * updates of the search progress. The progress object is created and deleted
     * dynamically during the search process.
     */
    CombinatorialProgress* progress;

    string getPrefixAsString() const
    {
        stringstream ss;
        for (size_t p : prefix) {
            ss << p << " ";
        }
        return ss.str();
    }

    /**
     * Processes the child chains of a given chain recursively. It takes a chain
     * as a prefix and creates new chains by combining the prefix with each of
     * the remaining chains in the collection. The mehtod calls recursively
     * itself to process the child chains of each newly created chain.
     *
     * @param chain The prefix chain to be combined with the remaining chains in
     *     the collection.
     * @param collection The collection of chains to be combined with the prefix
     *     chain.
     */
    void processChildrenChains(const CHAIN& parentChain, ChainCollection<CHAIN>& collection)
    {
        if (!config.hasFilterEmptyFoci() || collection.hasFoci()) {
            if (isStorable(parentChain)) {
                BLOCK_INC_TIMER(st, t, "Digger::processChildrenChains - store");

                // return singleton selector to avoid allocations
                const Selector& selector = initializeSelectorOfStorable(parentChain, collection);
                if (isStorable(selector)) {
                    storage.store(prefix, parentChain, collection, selector, predicateSums);
                }
            }
            progress->increment(1);

            if (isExtendable(parentChain)) {
                // from here we switch to new prefix
                if (parentChain.hasPredicate()) {
                    prefix.push_back(parentChain.getPredicate());
                }

                for (size_t i = 0; i < collection.conditionCount(); ++i) {
                    ChainCollection<CHAIN> childCollection;
                    CHAIN& chain = collection[i];
                    auto batch = progress->createBatch(prefix.size() + chain.hasPredicate(),
                                                       collection.conditionCount() - i - 1);
                    {
                        BLOCK_INC_TIMER(st, t, "Digger::processChildrenChains - for loop");

                        if (isExtendable(chain)) {
                            // need conjunction of i-th chain with everything
                            combine(childCollection, collection, i, false);
                        }
                        else if (collection.hasFoci()) {
                            // need conjunction of i-th chain with foci only
                            combine(childCollection, collection, i, true);
                        }
                        else {
                            // do not need childCollection at all
                        }
                    }

                    processChildrenChains(chain, childCollection);
                }

                // backtrack to previous prefix
                if (parentChain.hasPredicate()) {
                    prefix.pop_back();
                }
            }
        }
    }

    /**
     * Take a parent chain collection and combine the condition chain at the
     * given index with other chains in the collection. The resulting chains are
     * stored in the target collection. The method can be configured to combine
     * only with foci chains or with also other chains in the collection.
     *
     * If onlyFoci is false, the selected chain is combined with all chains that
     * come after it in the collection, and also with all foci chains that come
     * before it in the collection. This ensures that all possible combinations
     * of chains are considered, while avoiding redundant combinations.
     *
     * If onlyFoci is true, the selected chain is combined with all foci.
     *
     * @param target The target collection to store the resulting chains.
     * @param parent The parent collection containing the chains to be combined.
     * @param conditionChainIndex The index of the condition chain in the parent
     *     collection to be combined with other chains.
     * @param onlyFoci A boolean flag indicating whether to combine only with foci
     *    chains (true) or with all chains in the collection (false).
     */
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

        size_t bothLen = (conditionChainIndex > parent.firstFocusIndex())
            ? conditionChainIndex - parent.firstFocusIndex() : 0;

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

    /**
     * Combines two chains by computing truth values of their conjunction and
     * storing the resulting chain in the target collection.
     *
     * @param target The target collection to store the resulting chain.
     * @param conditionChain The first chain to be combined.
     * @param secondChain The second chain to be combined.
     */
    inline void combineByConjunction(ChainCollection<CHAIN>& target,
                              const CHAIN& conditionChain,
                              const CHAIN& secondChain)
    {
        BLOCK_INC_TIMER(st, t, "Digger::combineByConjunction");

        if (isNonRedundant(conditionChain, secondChain)
                && (!isDerivableConditionOnly(conditionChain, secondChain))
                && (!isDerivableFocusOnly(conditionChain, secondChain))) {
            CHAIN newChain(conditionChain, secondChain);
            searchStats.incrementComputedConjunctions();
            addSumToCache(conditionChain, secondChain, newChain.getSum());
            if (isCandidate(newChain)) {
                target.append(std::move(newChain));
            }
        }
    }

    /**
     * Combines two chains by retrieving the sum of their conjunction from the
     * cache and storing the resulting chain in the target collection.
     *
     * @param target The target collection to store the resulting chain.
     * @param conditionChain The first chain to be combined.
     * @param secondChain The second chain to be combined.
     */
    inline void combineByCache(ChainCollection<CHAIN>& target,
                        const CHAIN& conditionChain,
                        const CHAIN& secondChain)
    {
        BLOCK_INC_TIMER(st, t, "Digger::combineByCache");

        if (isNonRedundant(conditionChain, secondChain)
                // no need to test for isDerivableConditionOnly here, because
                // the secondChain is cached and therefore not condition-only
                && (!isDerivableFocusOnly(conditionChain, secondChain))) {

            searchStats.incrementCachedConjunctions();
            double sum = getSumFromCache(conditionChain, secondChain);

            // not being in the cache means that the conjunction is redundant
            if (sum != Cache::NOT_IN_CACHE) {
                CHAIN newChain(conditionChain, secondChain, sum);
                if (isCandidate(newChain)) {
                    target.append(std::move(newChain));
                }
            }
        }
    }

    /**
     * If the second chain is condition-only (not both condition and focus),
     * this method checks if the predicate of the
     * second chain can be derived from initial axioms and predicates of the
     * prefix and the predicate of the first chain.
     *
     * @param conditionChain The first chain, whose predicates are used as
     *     initial axioms for the derivation check.
     * @param secondChain The second chain to be checked for derivability.
     * @return true if the second chain is focus-only and the predicate of the
     *     second chain can be derived from the initial axioms and predicates
     *     from the prefix and from the first chain, false otherwise.
     */
    inline bool isDerivableConditionOnly(
            const CHAIN& conditionChain, const CHAIN& secondChain)
    {
        IF_DEBUG(
            if (!conditionChain.hasPredicate())
                throw invalid_argument("Digger::isDerivableConditionOnly: first chain has no predicate");
        )

        if (secondChain.isConditionOnly()) {
            return deductionEngine.isDerivableWithout(prefix,
                                                      conditionChain.getPredicate(),
                                                      secondChain.getPredicate());
        }

        return false;
    }

    /**
     * If the second chain is focus-only (not both condition and focus),
     * this method checks if the predicate of the
     * second chain can be derived from initial axioms and predicates of the
     * prefix and the predicate of the first chain.
     *
     * @param conditionChain The first chain, whose predicates are used as
     *     initial axioms for the derivation check.
     * @param secondChain The second chain to be checked for derivability.
     * @return true if the second chain is focus-only and the predicate of the
     *     second chain can be derived from the initial axioms and predicates
     *     from the prefix and from the first chain, false otherwise.
     */
    inline bool isDerivableFocusOnly(
            const CHAIN& conditionChain, const CHAIN& secondChain)
    {
        IF_DEBUG(
            if (!conditionChain.hasPredicate())
                throw invalid_argument("Digger::isDerivableFocusOnly: first chain has no predicate");
        )

        if (secondChain.isFocusOnly()) {
            return deductionEngine.isDerivableWithout(prefix,
                                                      conditionChain.getPredicate(),
                                                      secondChain.getPredicate());
        }

        return false;
    }

    /**
     * Checks if the predicate stored in the given chain is
     * non-redundant with respect to the predicate stored in
     * the parent chain. Two predicates are considered redundant if they belong
     * to the same disjoint set, as defined in the configuration. If the parent
     * chain is empty, the method returns true, indicating that the chain is
     * non-redundant.
     *
     * @param parent The parent chain to compare against.
     * @param chain The chain to be checked for non-redundancy.
     * @return true if the last predicate of the Clause in the chain is
     *     non-redundant with respect to the last predicate of the Clause in the
     *     parent chain, false otherwise.
     */
    inline bool isNonRedundant(const CHAIN& parent, const CHAIN& chain) const
    {
        if (parent.hasPredicate()) {
            size_t pref = parent.getPredicate();
            size_t curr = chain.getPredicate();
            if (pref == curr) {
                // Filter of focus even if disjoint is not defined
                // (should never happen as we always have disjoint defined)
                return false;
            }
            if (config.hasDisjoint() && config.getDisjoint()[pref] == config.getDisjoint()[curr]) {
                // It is enough to check the last element of the prefix because
                // previous elements were already checked in parent tasks
                return false;
            }
        }

        return true;
    }

    /**
     * Checks if the given chain is a candidate for further processing.
     * A chain is considered a candidate if it is either a condition
     * chain with a sum greater than or equal to the minimum sum specified in
     * the configuration, or a focus chain with a sum greater than or equal to
     * the minimum focus sum specified in the configuration.
     *
     * @param chain The chain to be checked for candidacy.
     * @return true if the chain is a candidate for storage, false otherwise.
     */
    inline bool isCandidate(const CHAIN& chain) const
    {
        if (chain.isCondition() && chain.getSum() >= config.getMinSum()) {
            return true;
        }
        if (chain.isFocus() && chain.getSum() >= config.getMinFocusSum()) {
            return true;
        }

        return false;
    }

    /**
     * Checks if the given chain can be extended further based on its properties.
     *
     * @param chain The chain to be checked for extendability.
     * @return true if the chain can be extended further, false otherwise.
     */
    inline bool isExtendable(const CHAIN& chain) const
    {
        bool res = (prefix.size() + chain.hasPredicate()) < config.getMaxLength()
            && chain.getSum() >= config.getMinSum()
            && storage.size() < config.getMaxResults();

        return res;
    }

    /**
     * Checks if the given chain is storable based on its properties.
     *
     * @param chain The chain to be checked for storability.
     * @return true if the chain is storable, false otherwise.
     */
    inline bool isStorable(const CHAIN& chain)
    {
        if ((prefix.size() + chain.hasPredicate()) >= config.getMinLength()
                && chain.getSum() >= config.getMinSum()
                && chain.getSum() <= config.getMaxSum()
                && storage.size() < config.getMaxResults()) {
            if (chain.hasPredicate()) {
                return !deductionEngine.hasRedundant(prefix, chain.getPredicate());
            }
            else {
                return !deductionEngine.hasRedundant(prefix);
            }
        }

        return false;
    }

    /**
     * Checks if the given selector is storable based on its properties.
     *
     * @param selector The selector to be checked for storability.
     * @return true if the selector is storable, false otherwise.
     */
    inline bool isStorable(const Selector& selector) const
    { return (!config.hasFilterEmptyFoci() || selector.getSelectedCount() > 0); }

    /**
     * Initializes the singleton Selector object for the given chain and
     * collection. The selector determines which foci in the collection are
     * selected for storage based on the support, derivability and other
     * criteria.
     *
     * @param chain The chain for which the selector is being initialized.
     * @param collection The collection of chains to be used for initializing the selector.
     * @return A reference to the initialized singleton Selector object.
     */
    inline const Selector& initializeSelectorOfStorable(
            const CHAIN& chain, const ChainCollection<CHAIN>& collection)
    {
        bool constant = (config.getMinConditionalFocusSupport() <= 0.0)
                && deductionEngine.empty();

        selectorSingleton.initialize(collection.focusCount(), constant);
        if (!constant) {
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                double confidence = 1.0 * focus.getSum() / chain.getSum();

                bool mustUnselect = (confidence < config.getMinConditionalFocusSupport());
                if (!mustUnselect) {
                    if (chain.hasPredicate()) {
                        mustUnselect = deductionEngine.isDerivableWithout(prefix,
                                                                          chain.getPredicate(),
                                                                          focus.getPredicate());
                    }
                    else {
                        mustUnselect = deductionEngine.isDerivableWithout(prefix,
                                                                          focus.getPredicate());
                    }
                }

                if (mustUnselect) {
                    selectorSingleton.unselect(i);
                }
            }
        }

        return selectorSingleton;
    }

    /**
     * Adds the sum of the given chain to the cache. The chain is cloned and sorted
     * before being added to the cache to ensure that the cache is indexed by a
     * consistent representation of the chain's Clause.
     *
     * @param chain The chain whose sum is to be added to the cache.
     */
    inline void addSumToCache(const CHAIN& chain1, const CHAIN& chain2, const double sum)
    {
        BLOCK_INC_TIMER(st, t, "Digger::addSumToCache");

        IF_DEBUG(
            if (!chain2.hasPredicate())
                throw invalid_argument("Digger::addSumToCache: second chain has no predicate");
        )

        // When adding to cache, the order of predicate IDs in prefix/chain1/chain2
        // is already sorted, so we can just push_back and pop_back to avoid
        // unnecessary copying and sorting.

        size_t oldSize = prefix.size();
        if (chain1.hasPredicate()) {
            prefix.push_back(chain1.getPredicate());
        }
        prefix.push_back(chain2.getPredicate());
        cache.add(prefix, sum);
        prefix.resize(oldSize);
    }

    /**
     * Retrieves the sum of the given chain from the cache. The chain is cloned and
     * sorted before being used to look up the sum in the cache to ensure that the
     * cache is indexed by a consistent representation of the chain's Clause.
     *
     * @param chain The chain whose sum is to be retrieved from the cache.
     */
    inline double getSumFromCache(const CHAIN& chain1, const CHAIN& chain2)
    {
        IF_DEBUG(
            if (!chain1.hasPredicate())
                throw invalid_argument("Digger::getSumFromCache: first chain has no predicate");

            if (!chain2.hasPredicate())
                throw invalid_argument("Digger::getSumFromCache: second chain has no predicate");
        )

        BLOCK_INC_TIMER(st, t, "Digger::getSumFromCache");

        // When getting from cache, the order of predicate IDs in prefix/chain1
        // is already sorted, however, chain2's predicate is always unsorted,
        // so we need to insert it into the right place.

        cacheQuery.resize(prefix.size() + 2);
        prefix.push_back(chain1.getPredicate());
        size_t p2pos = sortedPositions[chain2.getPredicate()];
        size_t offset = 0;
        for (size_t i = 0; i < prefix.size(); ++i) {
            if (p2pos < sortedPositions[prefix[i]]) {
                cacheQuery[i] = chain2.getPredicate();
                offset = 1;
                p2pos = std::numeric_limits<size_t>::max(); // ensure we don't insert again
            }
            cacheQuery[i + offset] = prefix[i];
        }
        prefix.pop_back();

        return cache.get(cacheQuery);
    }
};
