#pragma once

#include "Chain.hpp"


class Data {
public:
    Data()
    { }

    template <typename T>
    void addChain(const T& values)
    {
        if (chains.size() > 0) {
            if (values.size() != chains.front().size()) {
                throw new runtime_error("Chain sizes mismatch in Data::addChain");
            }
        }

        chains.push_back(Chain(values));
    }

    const Chain& getChain(size_t i) const
    { return chains.at(i); }

    size_t size() const
    { return chains.size(); }

private:
    vector<Chain> chains;
};
