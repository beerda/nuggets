#pragma once

#include "DualChain.h"


template <typename BITCHAIN, typename NUMCHAIN>
class Data {
public:
    using DualChainType = DualChain<BITCHAIN, NUMCHAIN>;

    /**
     * Default constructor.
     */
    Data(size_t rows)
        : rows(rows),
          positiveChains(),
          negativeChains(),
          names(),
          condition(),
          foci()
    { }

    // Disable copy
    Data(const Data& other) = delete;
    Data& operator=(const Data& other) = delete;

    // Allow move
    Data(Data&& other) = default;
    Data& operator=(Data&& other) = default;

    void reserve(size_t size)
    {
        positiveChains.reserve(size);
        negativeChains.reserve(size);
        names.reserve(size);
        condition.reserve(size);
        foci.reserve(size);
    }

    void addUnusedChain()
    {
        positiveChains.emplace_back();
        negativeChains.emplace_back();
        names.emplace_back();
    }

    template <typename T>
    void addChain(const T& values, const string& name, bool isCondition, bool isFocus)
    {
        if (size_t(values.size()) != rows) {
            throw std::out_of_range("Chain size mismatch in Data::addChain");
        }

        if (isCondition) {
            condition.emplace_back(positiveChains.size());
        }
        if (isFocus) {
            foci.emplace_back(positiveChains.size());
        }

        names.emplace_back(name);
        positiveChains.emplace_back(values);
        positiveChains.back().toNumeric();

         // just put in an empty chain, which will be initialized later in initializeNegativeFoci() if needed
        negativeChains.emplace_back();
    }

    void initializeNegativeFoci()
    {
        for (size_t i = 0; i < foci.size(); ++i) {
            size_t index = foci.at(i);
            negativeChains[index] = positiveChains[index]; // copy the chain
            negativeChains[index].negate();
        }
    }

    const DualChainType& getPositiveChain(size_t i) const
    {
        const DualChainType& chain = positiveChains.at(i);
        if (chain.isNull()) {
            throw std::out_of_range("Attempt to use null chain in Data::getPositiveChain");
        }

        return chain;
    }

    const DualChainType& getNegativeChain(size_t i) const
    {
        const DualChainType& chain = negativeChains.at(i);
        if (chain.isNull()) {
            throw std::out_of_range("Attempt to use null chain in Data::getNegativeChain");
        }

        return chain;
    }

    const string& getName(size_t i) const
    {
        const DualChainType& chain = positiveChains.at(i);
        if (chain.isNull()) {
            throw std::out_of_range("Attempt to get name of null chain in Data::getName");
        }

        return names.at(i);
    }

    const vector<int>& getCondition() const
    { return condition; }

    const vector<int>& getFoci() const
    { return foci; }

    size_t size() const
    { return positiveChains.size(); }

    size_t nrow() const
    { return rows; }

    void optimizeConditionOrder()
    {
        sort(condition.begin(), condition.end(), [this](int a, int b) {
            const DualChainType& chainA = positiveChains[a];
            const DualChainType& chainB = positiveChains[b];

            if (chainA.isBitwise() > chainB.isBitwise()) {
                return true; // a goes before b because a is bitwise and b isn't
            }
            if (chainA.isBitwise() < chainB.isBitwise()) {
                return false; // b goes before a
            }

            // a goes before b if it has less 1s
            return chainA.getSum() < chainB.getSum();
        });
    }

private:
    size_t rows;
    vector<DualChainType> positiveChains;
    vector<DualChainType> negativeChains;
    vector<string> names;
    vector<int> condition;
    vector<int> foci;
};
