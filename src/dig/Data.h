#pragma once

#include "DualChain.h"


class Data {
public:
    Data()
    { }

    template <typename T>
    void addChain(const T& values)
    {
        if (!chains.empty()) {
            if (((size_t) values.size()) != chains.front().size()) {
                throw new runtime_error("Condition chain sizes mismatch in Data::addChain");
            }
        }
        if (!foci.empty()) {
            if (((size_t) values.size()) != foci.front().size()) {
                throw new runtime_error("Condition chain size differs from focus chain sizes in Data::addChain");
            }
        }

        chains.push_back(DualChainType(values));
    }

    template <typename T>
    void addChains(const List& data)
    {
        for (R_xlen_t i = 0; i < data.size(); i++) {
            T col = data.at(i);
            addChain(col);
        }
    }

    template <typename T>
    void addFocus(const T& values)
    {
        if (!chains.empty()) {
            if (((size_t) values.size()) != chains.front().size()) {
                throw new runtime_error("Focus chain size differs from condition chain sizes in Data::addChain");
            }
        }
        if (!foci.empty()) {
            if (((size_t) values.size()) != foci.front().size()) {
                throw new runtime_error("Focus chain sizes mismatch in Data::addChain");
            }
        }

        foci.push_back(DualChainType(values));
    }

    template <typename T>
    void addFoci(const List& data)
    {
        for (R_xlen_t i = 0; i < data.size(); i++) {
            T col = data.at(i);
            addFocus(col);
        }
    }

    const DualChainType& getChain(size_t i) const
    { return chains.at(i); }

    const DualChainType& getFocus(size_t i) const
    { return foci.at(i); }

    size_t size() const
    { return chains.size(); }

    size_t fociSize() const
    { return foci.size(); }

    size_t nrow() const
    {
        if (!chains.empty())
            return chains.front().size();

        if (!foci.empty())
            return foci.front().size();

        return 0;
    }

private:
    vector<DualChainType> chains;
    vector<DualChainType> foci;
};
