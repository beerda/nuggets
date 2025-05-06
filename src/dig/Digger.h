#pragma once

#include "../common.h"
#include "Config.h"
#include "ChainCollection.h"


template <typename CHAIN, typename STORAGE>
class Digger {
public:
    Digger(const Config& config, STORAGE& storage)
        : config(config), storage(storage)
    { }

    // Disable copy
    Digger(const Digger&) = delete;
    Digger& operator=(const Digger&) = delete;

    // Allow move
    Digger(Digger&&) = default;
    Digger& operator=(Digger&&) = default;

    void run(ChainCollection<CHAIN>& data)
    {
        ChainCollection<CHAIN> filteredCollection;
        for (size_t i = 0; i < data.size(); ++i) {
            if (isFrequent(data[i])) {
                filteredCollection.append(std::move(data[i]));
            }
        }

        if (config.getMinLength() <= 0) {
            // store empty condition
            storage.store(CHAIN(), filteredCollection);
        }

        if (config.getMaxLength() >= 1) {
            processChains(filteredCollection);
        }

    }

    List getResult() const
    {
        return List();
    }

private:
    const Config& config;
    STORAGE& storage;

    bool isFrequent(const CHAIN& chain) const
    {
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
                 bool onlyFoci)
    {
        size_t begin = conditionChainIndex + 1;
        if (onlyFoci && begin < parent.firstFocusIndex()) {
            begin = parent.firstFocusIndex();
        }
        target.reserve(parent.size() - begin);
        for (size_t i = begin; i < parent.size(); ++i) {
            CHAIN newChain(parent[conditionChainIndex], parent[i]);
            if (isFrequent(newChain)) {
                target.append(std::move(newChain));
            }
        }
    }

    void processChains(const ChainCollection<CHAIN>& collection)
    {
        for (size_t i = 0; i < collection.conditionCount(); ++i) {
            const CHAIN& chain = collection[i];

            ChainCollection<CHAIN> childCollection;
            if (chain.getClause().size() < config.getMaxLength()) {
                // would need conjunction with everything
                combine(childCollection, collection, i, false);
                processChains(childCollection);
            }
            else if (collection.hasFoci()) {
                // would need conjunction with foci only
                combine(childCollection, collection, i, true);
            }
            else {
                // do not need childCollection at all
            }

            storage.store(chain, childCollection);
        }
    }
};
