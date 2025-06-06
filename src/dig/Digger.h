#pragma once

#include <algorithm>

#include "../common.h"
#include "Config.h"
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
          predicateSums(initialCollection.size() + 1),
          tree(initialCollection),
          collectionQueue()
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
        ChainCollection<CHAIN>* filteredCollection = new ChainCollection<CHAIN>();
        CHAIN emptyChain(config.getNrow());
        tree.updateDeduction(emptyChain);

        for (size_t i = 0; i < initialCollection.size(); ++i) {
            CHAIN& chain = initialCollection[i];
            if (isNonRedundant(emptyChain, chain)) {
                if (isCandidate(chain)) {
                    filteredCollection->append(std::move(chain));
                }
            }
        }

        processChildrenChains(emptyChain, filteredCollection);
        processQueued();
    }

private:
    STORAGE& storage;
    const Config& config;
    ChainCollection<CHAIN> initialCollection;
    vector<float> predicateSums;
    TautologyTree<CHAIN> tree;
    deque<ChainCollection<CHAIN>*> collectionQueue;

    void processQueued()
    {
        while (!collectionQueue.empty()) {
            ChainCollection<CHAIN>* collection = collectionQueue.front();
            collectionQueue.pop_front();
            processChains(collection);
            delete collection;
        }
    }

    void processChains(ChainCollection<CHAIN>* collection)
    {
        for (size_t i = 0; i < collection->conditionCount(); ++i) {
            ChainCollection<CHAIN>* childCollection = new ChainCollection<CHAIN>();
            CHAIN& chain = (*collection)[i];

            if (chain.isErased())
                continue;

            tree.updateDeduction(chain);
            if (chain.deducesItself())
                continue;

            if (isExtendable(chain)) {
                // need conjunction with everything
                combine(childCollection, collection, i, false);
            }
            else if (collection->hasFoci()) {
                // need conjunction with foci only
                combine(childCollection, collection, i, true);
            }
            else {
                // do not need childCollection at all
            }

            processChildrenChains(chain, childCollection);
        }
    }

    void processChildrenChains(const CHAIN& chain, ChainCollection<CHAIN>* childCollection)
    {
        bool pushed = false;
        if (!config.hasFilterEmptyFoci() || childCollection->hasFoci()) {
            if (isStorable(chain)) {
                Selector selector = createSelectorOfStorable(chain, *childCollection);
                if (isStorable(selector)) {
                    storage.store(chain, *childCollection, selector, predicateSums);
                    processTautologies(chain, *childCollection, selector);
                }
            }
            if (isExtendable(chain)) {
                collectionQueue.push_back(childCollection);
                //processChains(childCollection);
                //delete childCollection;

                pushed = true;
            }
        }

        if (!pushed)
            delete childCollection;
    }

    void combine(ChainCollection<CHAIN>* target,
                 ChainCollection<CHAIN>* parent,
                 const size_t conditionChainIndex,
                 bool onlyFoci) const
    {
        CHAIN& conditionChain = (*parent)[conditionChainIndex];

        size_t begin = conditionChainIndex + 1;
        if (onlyFoci && begin < parent->firstFocusIndex()) {
            begin = parent->firstFocusIndex();
        }

        size_t bothLen = (conditionChainIndex > parent->firstFocusIndex()) ? conditionChainIndex - parent->firstFocusIndex() : 0;

        target->reserve(parent->size() - begin + bothLen);
        for (size_t i = begin; i < parent->size(); ++i) {
            combineInternal(target, conditionChain, (*parent)[i], false);
        }
        for (size_t i = parent->firstFocusIndex(); i < conditionChainIndex; ++i) {
            combineInternal(target, conditionChain, (*parent)[i], true);
        }
    }

    void combineInternal(ChainCollection<CHAIN>* target,
                         const CHAIN& conditionChain,
                         const CHAIN& secondChain,
                         const bool toFocus) const
    {
        if (!secondChain.isErased()) {
            if (isNonRedundant(conditionChain, secondChain)) {
                CHAIN newChain(conditionChain, secondChain, toFocus);
                if (isCandidate(newChain)) {
                    target->append(std::move(newChain));
                }
            }
        }
    }

    bool isNonRedundant(const CHAIN& parent, const CHAIN& chain) const
    {
        size_t curr = chain.getClause().back();

        if (parent.getClause().size() > 0) {
            size_t pref = parent.getClause().back();

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

        if (config.hasFilterExcluded() && parent.deduces(curr)) {
            return false;
        }

        return true;
    }

    bool isCandidate(const CHAIN& chain) const
    {
        //cout << "chain.getSum() = " << chain.getSum() << " config.getMinSum() = " << config.getMinSum() << endl;
        if (chain.isCondition() && chain.getSum() >= config.getMinSum())
            return true;

        if (chain.isFocus() && chain.getSum() >= config.getMinFocusSum())
            return true;

        return false;
    }

    bool isExtendable(const CHAIN& chain) const
    {
        return chain.getClause().size() < config.getMaxLength()
            && chain.getSum() >= config.getMinSum()
            && storage.size() < config.getMaxResults();
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

    Selector createSelectorOfStorable(const CHAIN& chain, const ChainCollection<CHAIN>& collection) const
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

    void processTautologies(const CHAIN& chain,
                            ChainCollection<CHAIN>& collection,
                            const Selector& selector)
    {
        if (config.hasTautologyLimit()) {
            float chainSumReciprocal = 1.0f / chain.getSum();
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                CHAIN& focus = collection[i + collection.firstFocusIndex()];
                if (focus.getSum() * chainSumReciprocal >= config.getTautologyLimit()) {
                    tree.addTautology(chain.getClause(), focus.getClause().back());
                    focus.setErased();
                }
            }
        }
    }
};
