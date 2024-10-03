#pragma once

#include "../common.h"


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
                numData.pushBack(1.0 * bitData.at(i));
            }
        }
    }

    void negate()
    {
        if (isBitwise()) {
            bitData.negate();
        }
        if (isNumeric()) {
            numData.negate();
        }
    }

    void conjunctWith(const DualChain<BITCHAIN, NUMCHAIN>& chain)
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

    float getSum() const
    { return isBitwise() ? bitData.getSum() : numData.getSum(); }

    float getSupport() const
    {
        if (empty())
            return 1.0;
        else
            return getSum() / size();
    }

    float getValue(size_t index) const
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
