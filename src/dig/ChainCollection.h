#pragma once

#include "../common.h"
#include "BaseChain.h"


template <typename CHAIN>
class ChainCollection {
public:
    using ChainType = CHAIN;

    class Range {
    public:
        Range() = default;

        Range(vector<CHAIN>::const_iterator first,
              vector<CHAIN>::const_iterator last)
            : first(first),
              last(last)
        { }

        vector<CHAIN>::const_iterator begin() const
        { return first; }

        vector<CHAIN>::const_iterator end() const
        { return last; }

        size_t size() const
        { return std::distance(first, last); }

        bool empty() const
        { return size() == 0; }

    private:
        vector<CHAIN>::const_iterator first;
        vector<CHAIN>::const_iterator last;
    };

    ChainCollection()
        : chains(), nConditions(0), nFoci(0)
    { }

    ChainCollection(const List& data,
                    const LogicalVector& isConditionVec,
                    const LogicalVector& isFocusVec)
        : chains(), nConditions(0), nFoci(0)
    {
        chains.reserve(data.size());
        for (R_xlen_t i = 0; i < data.size(); ++i) {
            bool isCondition = isConditionVec[i];
            bool isFocus = isFocusVec[i];

            if (isCondition || isFocus) {
                if (isCondition) nConditions++;
                if (isFocus) nFoci++;
                int id = i + 1;
                BaseChain::PredicateType type = BaseChain::createPredicateType(isCondition, isFocus);
                if (Rf_isLogical(data[i])) {
                    const LogicalVector& vec = data[i];
                    chains.emplace_back(id, type, vec);
                }
                //else if (Rf_isReal(data[i])) {
                    //const NumericVector& vec = data[i];
                    //chains.emplace_back(id, BaseChain::PredicateType(type), vec);
                //}
                else {
                    throw std::invalid_argument("ChainCollection: unsupported data type");
                }
            }
        }
        sortChains();
    }

    // Disable copy
    ChainCollection(const ChainCollection&) = delete;
    ChainCollection& operator=(const ChainCollection&) = delete;

    // Allow move
    ChainCollection(ChainCollection&&) = default;
    ChainCollection& operator=(ChainCollection&&) = default;

    void reserve(size_t size)
    { chains.reserve(size); }

    size_t size() const
    { return chains.size(); }

    bool empty() const
    { return chains.empty(); }

    const CHAIN& at(size_t i) const
    { return chains.at(i); }

    const CHAIN& operator[](size_t i) const
    { return chains[i]; }

    typename vector<CHAIN>::const_iterator begin() const
    { return chains.begin(); }

    typename vector<CHAIN>::const_iterator end() const
    { return chains.end(); }

    void append(const CHAIN& a, const CHAIN& b)
    {
        IF_DEBUG(
            if (a.size() != b.size()) {
                throw std::invalid_argument("ChainCollection::append: incompatible sizes");
            }
        )
        chains.emplace_back(a, b);
    }

    Range conditions() const
    { return Range(chains.begin(), chains.begin() + nConditions); }

    Range foci() const
    { return Range(chains.end() - nFoci, chains.end()); }

private:
    vector<CHAIN> chains;
    size_t nConditions;
    size_t nFoci;

    void sortChains()
    {
        std::sort(chains.begin(), chains.end(), [](const CHAIN& a, const CHAIN& b) {
            return a.getPredicateType() < b.getPredicateType();
        });
    }
};
