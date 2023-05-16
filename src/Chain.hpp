#pragma once

#include <cpp11.hpp>
#include <numeric>
#include <boost/dynamic_bitset.hpp>

using namespace cpp11;
using namespace std;


class Chain {
public:
    Chain(doubles values)
        : type(Type::NUMERIC)
    {
        numData.reserve(values.size());
        for (size_t i = 0; i < values.size(); i++) {
            numData.push_back(values[i]);
        }
    }

    Chain(logicals values)
        : type(Type::BITWISE)
    {
        bitData.reserve(values.size());
        for (size_t i = 0; i < values.size(); i++) {
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

private:
    enum class Type {
        BITWISE,
        NUMERIC
    };

    Type type;
    boost::dynamic_bitset<> bitData;
    vector<double> numData;
};
