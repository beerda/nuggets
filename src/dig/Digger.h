#pragma once

#include "../common.h"
#include "Config.h"
#include "ChainCollection.h"
#include "Selector.h"


template <typename CHAIN, typename STORAGE>
class Digger {
public:
    Digger(const Config& config,
           const List data,
           const LogicalVector isCondition,
           const LogicalVector isFocus,
           STORAGE& storage)
        : storage(storage),
          config(config),
          initialCollection(data, isCondition, isFocus),
          predicateSums(initialCollection.size() + 1)
    {
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

    void run()
    {
        CHAIN emptyChain(config.getNrow());
        ChainCollection<CHAIN> filteredCollection;
        for (size_t i = 0; i < initialCollection.size(); ++i) {
            if (isCandidate(initialCollection[i])) {
                filteredCollection.append(std::move(initialCollection[i]));
            }
        }
        if (isStorable(emptyChain)) {
            Selector selector = createSelector(emptyChain, filteredCollection);
            if (isStorable(selector)) {
                storage.store(emptyChain, filteredCollection, selector, predicateSums);
            }
        }
        if (isExtendable(emptyChain)) {
            processChains(filteredCollection);
        }
    }

    List getResult() const
    { return List(); }

private:
    STORAGE& storage;
    const Config& config;
    ChainCollection<CHAIN> initialCollection;
    vector<float> predicateSums;

    bool isNonRedundant(const CHAIN& parent, const CHAIN& chain) const
    {
        size_t pref = parent.getClause().back();
        size_t curr = chain.getClause().back();

        if (pref == curr) {
            // Filter of focus even if disjoint is not defined
            // (should never happen as we always have disjoint defined)
            return false;
        }

        if (config.hasDisjoint()) {
            if (config.getDisjoint()[pref] == config.getDisjoint()[curr]) {
                // It is enough to check the last element of the prefix because
                // previous elements were already checked in parent tasks
                //cout << "redundant: " << parent.clauseAsString() << " , " << chain.clauseAsString() << endl;
                return false;
            }
        }

        return true;
    }

    bool isCandidate(const CHAIN& chain) const
    {
        //cout << "chain.getSum() = " << chain.getSum() << " config.getMinSum() = " << config.getMinSum() << endl;
        if (chain.isCondition() && chain.getSum() >= config.getMinSum())
            return true;

        if (chain.isFocus()) {
            if (chain.getSum() >= config.getMinFocusSum())
                return true;
        }

        return false;
    }

    bool isExtendable(const CHAIN& chain) const
    {
        return chain.getClause().size() < config.getMaxLength()
            && chain.getSum() >= config.getMinSum()
            && storage.size() < config.getMaxResults();
    }

    Selector createSelector(const CHAIN& chain, const ChainCollection<CHAIN>& collection) const
    {
        bool constant = config.getMinConditionalFocusSupport() <= 0.0f;
        Selector result(collection.focusCount(), constant);
        if (!constant) {
            float chainSumReciprocal = 1.0f / chain.getSum();
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                if (focus.getSum() * chainSumReciprocal < config.getMinConditionalFocusSupport()) {
                    result.unselect(i);
                }
            }
        }

        return result;
    }

    bool isStorable(const CHAIN& chain) const
    {
        return chain.getClause().size() >= config.getMinLength()
            && chain.getSum() >= config.getMinSum()
            && chain.getSum() <= config.getMaxSum()
            && storage.size() < config.getMaxResults();
    }

    bool isStorable(const Selector& selector) const
    { return (!config.hasFilterEmptyFoci() || selector.getSelectedCount() > 0); }

    void combine(ChainCollection<CHAIN>& target,
                 const ChainCollection<CHAIN>& parent,
                 const size_t conditionChainIndex,
                 bool onlyFoci) const
    {
        const CHAIN& conditionChain = parent[conditionChainIndex];

        size_t begin = conditionChainIndex + 1;
        if (onlyFoci && begin < parent.firstFocusIndex()) {
            begin = parent.firstFocusIndex();
        }

        size_t bothLen = (conditionChainIndex > parent.firstFocusIndex()) ? conditionChainIndex - parent.firstFocusIndex() : 0;

        target.reserve(parent.size() - begin + bothLen);
        for (size_t i = begin; i < parent.size(); ++i) {
            const CHAIN& secondChain = parent[i];
            if (isNonRedundant(conditionChain, secondChain)) {
                CHAIN newChain(conditionChain, secondChain, false);
                if (isCandidate(newChain)) {
                    target.append(std::move(newChain));
                }
            }
        }
        for (size_t i = parent.firstFocusIndex(); i < conditionChainIndex; ++i) {
            const CHAIN& secondChain = parent[i];
            if (isNonRedundant(conditionChain, secondChain)) {
                CHAIN newChain(conditionChain, secondChain, true);
                if (isCandidate(newChain)) {
                    target.append(std::move(newChain));
                }
            }
        }
    }

    void processChains(const ChainCollection<CHAIN>& collection) const
    {
        for (size_t i = 0; i < collection.conditionCount(); ++i) {
            ChainCollection<CHAIN> childCollection;
            const CHAIN& chain = collection[i];

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

            if (!config.hasFilterEmptyFoci() || childCollection.hasFoci()) {
                if (isStorable(chain)) {
                    Selector selector = createSelector(chain, childCollection);
                    if (isStorable(selector)) {
                        storage.store(chain, childCollection, selector, predicateSums);
                    }
                }
                if (isExtendable(chain)) {
                    processChains(childCollection);
                }
            }
        }
    }
};
