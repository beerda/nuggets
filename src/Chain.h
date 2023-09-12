#pragma once

#include <math.h>
#include <numeric>
#include <boost/dynamic_bitset.hpp>
#include "common.h"


class Chain {
public:
    Chain()
    { }

    Chain(doubles values)
    {
        numData.reserve(values.size());
        cachedSum = 0;
        for (R_xlen_t i = 0; i < values.size(); i++) {
            numData.push_back(values.at(i));
            cachedSum += values.at(i);
        }
    }

    Chain(logicals values)
    {
        bitData.reserve(values.size());
        cachedSum = 0;
        for (R_xlen_t i = 0; i < values.size(); i++) {
            bitData.push_back(values.at(i));
            if (values.at(i))
                cachedSum++;
        }
    }

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
                numData.push_back(1.0 * bitData[i]);
            }
        }
    }

    void combineWith(const Chain& chain)
    {
        if (size() != chain.size()) {
            throw new runtime_error("Incompatible chain lengths");

        } else if (isBitwise() && chain.isBitwise()) {
            bitData &= chain.bitData;
            numData.clear();

        } else if (isNumeric() && chain.isNumeric()) {
            for (size_t i = 0; i < numData.size(); i++) {
                numData[i] *= chain.numData[i];
            }
            bitData.clear();

        } else {
            throw new runtime_error("Incompatible chain types");
        }

        if (isBitwise()) {
            cachedSum = 1.0 * bitData.count();
        } else {
            cachedSum = accumulate(numData.begin(), numData.end(), 0.0);
        }
    }

    double getSum() const
    { return cachedSum; }

    double getSupport() const
    {
        if (empty())
            return INFINITY;
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
            printf(" %f", numData[i]);
        }
        printf("\n");
        printf("bitData:");
        for (size_t i = 0; i < bitData.size(); i++) {
            printf(" %d", bitData[i]);
        }
        printf("\n");
    }

    bool operator == (const Chain& other) const
    { return numData == other.numData && bitData == other.bitData; }

    bool operator != (const Chain& other) const
    { return !(*this == other); }

private:
    vector<double> numData;
    boost::dynamic_bitset<> bitData;
    double cachedSum;

};
