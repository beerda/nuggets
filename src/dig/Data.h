#pragma once

#include "DualChain.h"


template <typename BITCHAIN, typename NUMCHAIN>
class Data {
public:
    using DualChainType = DualChain<BITCHAIN, NUMCHAIN>;

    Data(size_t rows)
        : rows(rows)
    { }

    void reserve(size_t size)
    {
        positiveChains.reserve(size);
        negativeChains.reserve(size);
        names.reserve(size);
    }

    void addUnusedChain()
    {
        DualChainType emptyChain;
        positiveChains.push_back(emptyChain);
        negativeChains.push_back(emptyChain);
        names.push_back("");
    }

    template <typename T>
    void addChain(const T& values, string name, bool isCondition, bool isFocus)
    {
        if (size_t(values.size()) != rows) {
            throw runtime_error("Chain size mismatch in Data::addChain");
        }

        names.push_back(name);

        if (isCondition) {
            condition.push_back(positiveChains.size());
        }
        if (isFocus) {
            foci.push_back(positiveChains.size());
        }

        DualChainType posChain(values);
        posChain.toNumeric();
        positiveChains.push_back(posChain);

        DualChainType negChain;
        negativeChains.push_back(negChain);
    }

    void initializeNegativeFoci()
    {
        for (size_t i = 0; i < foci.size(); ++i) {
            DualChainType negChain = positiveChains.at(foci.at(i));
            negChain.negate();
            negativeChains[foci.at(i)] = negChain;
        }
    }

    const DualChainType& getPositiveChain(size_t i) const
    {
        const DualChainType& chain = positiveChains.at(i);
        if (chain.isNull()) {
            throw runtime_error("Attempt to use null chain in Data::getPositiveChain");
        }

        return chain;
    }

    const DualChainType& getNegativeChain(size_t i) const
    {
        const DualChainType& chain = negativeChains.at(i);
        if (chain.isNull()) {
            throw runtime_error("Attempt to use null chain in Data::getNegativeChain");
        }

        return chain;
    }

    const string& getName(size_t i) const
    {
        const DualChainType& chain = positiveChains.at(i);
        if (chain.isNull()) {
            throw runtime_error("Attempt to get name of null chain in Data::getName");
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

private:
    size_t rows;
    vector<DualChainType> positiveChains;
    vector<DualChainType> negativeChains;
    vector<string> names;
    vector<int> condition;
    vector<int> foci;
};
