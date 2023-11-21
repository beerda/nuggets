#pragma once

#include "../common.h"
#include "VectorNumChain.h"
#include "BitsetNumChain.h"
#include "BitsetBitChain.h"


template <typename BITCHAIN, typename NUMCHAIN>
class DualChain {
public:
    DualChain()
    { }

    DualChain(const NumericVector& values)
        : numData(values)
    { }

    DualChain(const LogicalVector& values)
        : bitData(values)
    { }

    size_t size() const
    { return isBitwise() ? bitData.size() : numData.size(); }

    bool isBitwise() const
    { return !bitData.empty(); }

    bool isNumeric() const
    { return !numData.empty(); }

    void toNumeric()
    {
        if (isBitwise()) {
            numData.clear();
            numData.reserve(size());
            for (size_t i = 0; i < size(); i++) {
                numData.push_back(1.0 * bitData.at(i));
            }
        }
    }

    void conjunctWith(const DualChain& chain)
    {
        if (size() != chain.size()) {
            throw new runtime_error("Incompatible chain lengths");

        } else if (isBitwise() && chain.isBitwise()) {
            bitData.conjunctWith(chain.bitData);
            numData.clear();

        } else if (isNumeric() && chain.isNumeric()) {
            numData.conjunctWith(chain.numData);
            bitData.clear();

        } else {
            throw new runtime_error("Incompatible chain types");
        }
    }

    double getSum() const
    { return isBitwise() ? bitData.getSum() : numData.getSum(); }

    double getSupport() const
    {
        if (empty())
            return 1.0;
        else
            return getSum() / size();
    }

    double getValue(size_t index) const
    {
        if (isBitwise())
            return 1.0 * bitData.at(index);
        else if (isNumeric())
            return numData.at(index);
        else
            return NAN;
    }

    bool empty() const
    { return numData.empty() && bitData.empty(); }

    void print() const
    {
        printf("\n");
        printf("numData:");
        for (size_t i = 0; i < numData.size(); i++) {
            printf(" %f", numData.at(i));
        }
        printf("\n");
        printf("bitData:");
        for (size_t i = 0; i < bitData.size(); i++) {
            printf(" %d", bitData.at(i));
        }
        printf("\n");
    }

    bool operator == (const DualChain& other) const
    { return numData == other.numData && bitData == other.bitData; }

    bool operator != (const DualChain& other) const
    { return !(*this == other); }

private:
    BITCHAIN bitData;
    NUMCHAIN numData;
};


using DualChainType = DualChain<BitsetBitChain, VectorNumChain<GOGUEN>>;
