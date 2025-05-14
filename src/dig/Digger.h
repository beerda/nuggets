#pragma once

#include "../common.h"
#include "Config.h"
#include "ChainCollection.h"


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
        ChainCollection<CHAIN> filteredCollection;
        for (size_t i = 0; i < initialCollection.size(); ++i) {
            if (isCandidate(initialCollection[i])) {
                filteredCollection.append(std::move(initialCollection[i]));
            }
        }

        if (config.getMinLength() <= 0) {
            // store empty condition
            storage.store(CHAIN(config.getNrow()), filteredCollection, predicateSums);
        }

        if (config.getMaxLength() >= 1) {
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

    bool isCandidate(const CHAIN& chain) const
    {
        //cout << "chain.getSum() = " << chain.getSum() << " config.getMinSum() = " << config.getMinSum() << endl;
        if (chain.isCondition() && chain.getSum() >= config.getMinSum())
            return true;

        if (chain.isFocus()) {
            if (!config.hasFilterEmptyFoci())
                return true;

            if (chain.getSum() >= config.getMinFocusSum())
                return true;
        }

        return false;
    }

    void combine(ChainCollection<CHAIN>& target,
                 const ChainCollection<CHAIN>& parent,
                 size_t conditionChainIndex,
                 bool onlyFoci) const
    {
        size_t begin = conditionChainIndex + 1;
        if (onlyFoci && begin < parent.firstFocusIndex()) {
            begin = parent.firstFocusIndex();
        }
        target.reserve(parent.size() - begin);
        const CHAIN& conditionChain = parent[conditionChainIndex];

        for (size_t i = begin; i < parent.size(); ++i) {
            const CHAIN& secondChain = parent[i];
            CHAIN newChain(conditionChain, secondChain);
            if (isCandidate(newChain)) {
                target.append(std::move(newChain));
            }
        }
    }

    void processChains(const ChainCollection<CHAIN>& collection) const
    {
        for (size_t i = 0; i < collection.conditionCount(); ++i) {
            ChainCollection<CHAIN> childCollection;
            const CHAIN& chain = collection[i];

            if (chain.getClause().size() < config.getMaxLength()) {
                // need conjunction with everything
                combine(childCollection, collection, i, false);
                storage.store(chain, childCollection, predicateSums);
                if (!storage.isFull())
                    processChains(childCollection);
            }
            else if (collection.hasFoci()) {
                // need conjunction with foci only
                combine(childCollection, collection, i, true);
                storage.store(chain, childCollection, predicateSums);
            }
            else {
                // do not need childCollection at all
                storage.store(chain, childCollection, predicateSums);
            }

        }
    }
};
