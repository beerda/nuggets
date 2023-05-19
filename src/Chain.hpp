#pragma once

#include <numeric>
#include <boost/dynamic_bitset.hpp>
#include "common.hpp"


class Chain {
public:
    Chain()
    { }

    Chain(doubles values)
        : type(Type::NUMERIC), numData(0), bitData(0)
    {
        numData.reserve(values.size());
        for (long int i = 0; i < values.size(); i++) {
            numData.push_back(values[i]);
        }
    }

    Chain(logicals values)
        : type(Type::BITWISE), numData(0), bitData(0)
    {
        bitData.reserve(values.size());
        for (long int i = 0; i < values.size(); i++) {
            bitData.push_back(values[i]);
        }
    }

    size_t size() const
    {
        switch (type) {
        case Type::BITWISE:
            return bitData.size();

        case Type::NUMERIC:
            return numData.size();

        default:
            return 0;
        }
    }

    bool isBitwise() const
    { return type == Type::BITWISE; }

    void combineWith(const Chain& chain)
    {
        if (type != chain.type) {
            throw new runtime_error("Incompatible chain types");
        }
        if (size() != chain.size()) {
            throw new runtime_error("Incompatible chain lengths");
        }

        switch (type) {
        case Type::BITWISE:
            bitData &= chain.bitData;
            break;

        case Type::NUMERIC:
            for (size_t i = 0; i < numData.size(); i++) {
                numData[i] *= chain.numData[i];
            }
        }
    }

    double sum() const
    {
        switch (type) {
        case Type::BITWISE:
            return 1.0 * bitData.count();

        case Type::NUMERIC:
            return accumulate(numData.begin(), numData.end(), 0.0);

        default:
            return 0.0;
        }
    }

    void toNumeric()
    {
        if (isBitwise()) {
            numData.reserve(size());
            for (size_t i = 0; i < size(); i++) {
                numData.push_back(1.0 * bitData[i]);
            }
            bitData.clear();
            type = Type::NUMERIC;
        }
    }

    void print() const
    {
        printf("\ntype: %d\n", type);
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
    enum class Type {
        BITWISE,
        NUMERIC
    };

    Type type;
    vector<double> numData;
    boost::dynamic_bitset<> bitData;
};
