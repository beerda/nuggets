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
                throw new runtime_error("Condition chain sizes mismatch in Data::addChain");
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

    template <typename T>
    void addFocus(const T& values)
    {
        if (foci.size() > 0) {
            if (((size_t) values.size()) != foci.front().size()) {
                throw new runtime_error("Focus chain sizes mismatch in Data::addChain");
            }
        }

        foci.push_back(Chain(values));
    }

    template <typename T>
    void addFoci(list data)
    {
        for (long int i = 0; i < data.size(); i++) {
            T col = data[i];
            addFocus(col);
        }
    }

    const Chain& getChain(size_t i) const
    { return chains.at(i); }

    const Chain& getFocus(size_t i) const
    { return foci.at(i); }

    size_t size() const
    { return chains.size(); }

    size_t fociSize() const
    { return foci.size(); }

    size_t nrow() const
    { return chains.front().size(); }

    size_t ncol() const
    { return size(); }

private:
    vector<Chain> chains;
    vector<Chain> foci;
};
