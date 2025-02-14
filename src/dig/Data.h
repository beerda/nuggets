#pragma once

#include "DualChain.h"


template <typename BITCHAIN, typename NUMCHAIN>
class Data {
public:
    using DualChainType = DualChain<BITCHAIN, NUMCHAIN>;

    Data(size_t rows)
        : rows(rows)
    { }

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
    { return positiveChains.at(i); }

    const DualChainType& getNegativeChain(size_t i) const
    { return negativeChains.at(i); }

    const string& getName(size_t i) const
    { return names.at(i); }

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
