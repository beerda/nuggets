#pragma once

#include <numeric>
#include <boost/dynamic_bitset.hpp>
#include "common.hpp"


class Chain {
public:
    Chain()
    { }

    Chain(doubles values)
        : numData(0), bitData(0)
    {
        numData.reserve(values.size());
        for (long int i = 0; i < values.size(); i++) {
            numData.push_back(values[i]);
        }
    }

    Chain(logicals values)
        : numData(0), bitData(0)
    {
        bitData.reserve(values.size());
        for (long int i = 0; i < values.size(); i++) {
            bitData.push_back(values[i]);
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
    }

    double sum() const
    {
        if (isBitwise()) {
            return 1.0 * bitData.count();
        } else {
            return accumulate(numData.begin(), numData.end(), 0.0);
        }
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

private:
    vector<double> numData;
    boost::dynamic_bitset<> bitData;

};
