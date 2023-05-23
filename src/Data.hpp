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
            if (((size_t) values.size()) != chains.front().size()) {
                throw new runtime_error("Chain sizes mismatch in Data::addChain");
            }
        }

        chains.push_back(Chain(values));
    }

    template <typename T>
    void addChains(list data)
    {
        for (long int i = 0; i < data.size(); i++) {
            T col = data[i];
            addChain(col);
        }
    }

    const Chain& getChain(size_t i) const
    { return chains.at(i); }

    size_t size() const
    { return chains.size(); }

    size_t nrow() const
    { return chains.front().size(); }

    size_t ncol() const
    { return size(); }

private:
    vector<Chain> chains;
};
