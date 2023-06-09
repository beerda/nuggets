#pragma once

#include "Argumentator.hpp"


/**
 * Prepare the 'fociSupports' argument for the R function callback.
 * The 'fociSupports' argument is a double value with supports of
 * foci combined with the condition.
 */
class FociSupportsArgumentator : public Argumentator {
public:
    FociSupportsArgumentator(const integers& foci, const Data& data)
        : foci(foci), data(data)
    { }

    void prepare(writable::list& arguments, const Task& task) const override
    {
        using namespace cpp11::literals;
        writable::strings names;
        writable::doubles supports;

        for (size_t i = 0; i < data.fociSize(); i++) {
            names.push_back(foci.names()[i]);
            Chain chain = data.getFocus(i);
            if (!task.getChain().empty()) {
                // chain is not empty when the condition is of length > 0
                chain.combineWith(task.getChain());
            }
            supports.push_back(chain.getSupport());
        }
        if (!supports.empty()) {
            supports.attr("names") = names;
        }

        arguments.push_back("foci_supports"_nm = supports);
    }

private:
    integers foci;
    const Data& data;
};
