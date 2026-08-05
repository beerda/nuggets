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
          predicateSums(data.size() + 1),
          selectorSingleton(initialCollection.focusCount()),
          cache(data.size() + 1),
          deductionEngine(data.size() + 1, config.getExcluded()),
          progress(nullptr)
    {
        BLOCK_TIMER(t, "Digger::Constructor");
        for (const CHAIN& chain : initialCollection) {
            size_t id = chain.getClause().back();
            predicateSums[id] = chain.getSum();
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
            addSumToCache(chain);
            if (isNonRedundant(emptyChain, chain)
                    && isCandidate(chain)
                    && !isDerivableFromAxioms(chain)) {
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
     * A vector that stores the sums of TRUEs (for binary data) or membership degrees
     * (for fuzzy data) for each predicate in the data. The index of the vector
     * corresponds to the predicate ID, and the value at that index represents
     * the sum of TRUEs or membership degrees for that predicate.
     * The vector is indexed from 1 to match R's indexing convention, with
     * index 0 reserved for the empty chain.
     */
    vector<double> predicateSums;

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
            addSumToCache(newChain);
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
            CHAIN newChain(conditionChain, secondChain, 0);
            searchStats.incrementCachedConjunctions();
            double sum = getSumFromCache(newChain);

            // not being in the cache means that the conjunction is redundant
            if (sum != Cache::NOT_IN_CACHE) {
                newChain.setSum(sum);
                if (isCandidate(newChain)) {
                    target.append(std::move(newChain));
                }
            }
        }
    }

    /**
     * Checks if the last predicate of the Clause stored in the given chain can
     * be derived from the initial axioms in the deduction engine. If the
     * predicate can be derived, it means that the chain is redundant and should
     * not be considered for further processing. By initial axioms we mean
     * implications with an empty antecedent.
     *
     * This check is used to filter out redundant predicates during the creation
     * of the initial collection of chains, ensuring that only non-redundant
     * chains are processed further in the search algorithm.
     *
     * @param chain The chain to be checked for derivability from the initial
     *     axioms.
     * @return true if the last predicate of the Clause in the chain can be
     *     derived from the initial axioms, false otherwise.
     */
    inline bool isDerivableFromAxioms(const CHAIN& chain)
    {
        return deductionEngine.isDerivableWithout(Clause(),
                                                  chain.getClause().back());
    }

    /**
     * If the second chain is condition-only (not both condition and focus),
     * this method checks if the last predicate of the Clause stored in the
     * second chain can be derived from initial axioms and predicates of the
     * Clause stored in the first chain.
     *
     * @param conditionChain The first chain, whose predicates are used as
     *     initial axioms for the derivation check.
     * @param secondChain The second chain to be checked for derivability.
     * @return true if the second chain is condition-only and the last predicate
     *     of the Clause in the second chain can be derived from the initial
     *     axioms and predicates of the Clause in the first chain, false
     *     otherwise.
     */
    inline bool isDerivableConditionOnly(
            const CHAIN& conditionChain, const CHAIN& secondChain)
    {
        if (secondChain.isConditionOnly()) {
            return deductionEngine.isDerivableWithout(conditionChain.getClause(),
                                                      secondChain.getClause().back());
        }

        return false;
    }

    /**
     * If the second chain is focus-only (not both condition and focus),
     * this method checks if the last predicate of the Clause stored in the
     * second chain can be derived from initial axioms and predicates of the
     * Clause stored in the first chain.
     *
     * @param conditionChain The first chain, whose predicates are used as
     *     initial axioms for the derivation check.
     * @param secondChain The second chain to be checked for derivability.
     * @return true if the second chain is focus-only and the last predicate
     *     of the Clause in the second chain can be derived from the initial
     *     axioms and predicates of the Clause in the first chain, false
     *     otherwise.
     */
    inline bool isDerivableFocusOnly(
            const CHAIN& conditionChain, const CHAIN& secondChain)
    {
        if (secondChain.isFocusOnly()) {
            return deductionEngine.isDerivableWithout(conditionChain.getClause(),
                                                      secondChain.getClause().back());
        }

        return false;
    }

    /**
     * Checks if the last predicate of the Clause stored in the given chain is
     * non-redundant with respect to the last predicate of the Clause stored in
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
        bool res = chain.getClause().size() < config.getMaxLength()
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
        bool res = chain.getClause().size() >= config.getMinLength()
            && chain.getSum() >= config.getMinSum()
            && chain.getSum() <= config.getMaxSum()
            && storage.size() < config.getMaxResults()
            && !deductionEngine.hasRedundant(chain.getClause());

        return res;
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
                if ((1.0 * focus.getSum() / chain.getSum() < config.getMinConditionalFocusSupport())
                        || deductionEngine.isDerivableWithout(chain.getClause(), focus.getClause().back())) {
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
    inline void addSumToCache(const CHAIN& chain)
    {
        BLOCK_INC_TIMER(st, t, "Digger::addSumToCache");

        Clause clause = chain.getClause().clone();
        clause.sort();
        cache.add(clause, chain.getSum());
    }

    /**
     * Retrieves the sum of the given chain from the cache. The chain is cloned and
     * sorted before being used to look up the sum in the cache to ensure that the
     * cache is indexed by a consistent representation of the chain's Clause.
     *
     * @param chain The chain whose sum is to be retrieved from the cache.
     */
    inline double getSumFromCache(const CHAIN& chain) const
    {
        BLOCK_INC_TIMER(st, t, "Digger::getSumFromCache");

        Clause clause = chain.getClause().clone();
        clause.sort();
        return cache.get(clause);
    }
};
