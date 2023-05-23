#pragma once

#include <vector>
#include <set>
#include "common.hpp"
#include "Data.hpp"


/**
 * Task represents a single level of traversal through the search space of conditions.
 */
class Task {
public:
    Task()
    { }

    /**
     * Create task representing an empty condition (condition of length 0) that may be extended
     * with 0..n-1 predicates stored in the soFar vector
     * @param n The number of predicates to store into soFar
     */
    Task(size_t n)
        : current(0)
    {
        soFar.reserve(n);
        for (size_t i = 0; i < n; i++) {
            soFar.push_back(i);
        }
    }

    /**
     * Create task representing an empty condition (condition of length 0) that may be extended
     * @param soFar predicates for further search in sub tasks
     */
    Task(vector<int> soFar)
        : current(0), soFar(soFar)
    { }

    /**
     * Create a task
     * @param prefix the prefix of the condition (constant predicates)
     * @param available a vector of available predicates to be examined in this task
     */
    Task(set<int> prefix, vector<int> available)
        : current(0), prefix(prefix), available(available)
    { }

    /**
     * Create a task
     * @param prefix the prefix of the condition (constant predicates)
     * @param a vector of available predicates to be examined in this task
     * @param soFar a vector of predicates for sub tasks
     */
    Task(set<int> prefix, vector<int> available, vector<int> soFar)
        : current(0), prefix(prefix), available(available), soFar(soFar)
    { }

    /**
     * Get the actually processing predicate
     * @return The predicate
     */
    int getCurrentPredicate() const
    {
        if (!hasPredicate())
            throw new runtime_error("Attempt to get unavailable predicate");

        return available[current];
    }

    set<int> getCurrentCondition() const
    {
        set<int> result = getPrefix();

        if (hasPredicate()) {
            result.insert(getCurrentPredicate());
        }

        return result;
    }

    size_t getLength() const
    { return prefix.size() + hasPredicate(); }

    /**
     * Start the enumeration of available predicates from the beginning. The internal pointer to the current predicate
     * is set to 0 and the vector of soFar predicates is cleared.
     */
    void reset()
    {
        current = 0;
        soFar.clear();
    }

    /**
     * Go to the next available predicate.
     */
    void next()
    {  current++; }

    /**
     * TRUE if task has more predicates, i.e., if getCurrentPredicate() can be called.
     */
    bool hasPredicate() const
    { return current < available.size(); }

    bool hasSoFar() const
    { return !soFar.empty(); }

    bool empty() const
    { return prefix.empty() && available.empty() && soFar.empty(); }

    const set<int> getPrefix() const
    { return prefix; }

    const vector<int> getAvailable() const
    { return available; }

    const vector<int> getSoFar() const
    { return soFar; }

    void putCurrentToSoFar()
    { soFar.push_back(getCurrentPredicate()); }

    Task createChild() const
    {
        Task result;

        if (hasPredicate()) {
            set<int> newPrefix = getPrefix();
            newPrefix.insert(getCurrentPredicate());
            result = Task(newPrefix, getSoFar());
        }
        else {
            result = Task(getPrefix(), getSoFar());
        }

        if (!chain.empty()) {
            result.prefixChain = chain;
        }

        return result;
    }

    const Chain& getChain() const
    { return chain; }

    const Chain& getPrefixChain() const
    { return prefixChain; }

    void updateChain(const Data& data)
    {
        if (hasPredicate()) {
            chain = data.getChain(getCurrentPredicate());
            if (!prefixChain.empty()) {
                if (chain.isBitwise() != prefixChain.isBitwise() && chain.isNumeric() != prefixChain.isNumeric()) {
                    if (prefixChain.isBitwise()) {
                        prefixChain.toNumeric();
                    } else {
                        chain.toNumeric();
                    }
                }
                chain.combineWith(prefixChain);
            }
        }
    }

    bool operator == (const Task& other) const
    {
        return current == other.current
            && prefix == other.prefix
            && available == other.available
            && soFar == other.soFar;
    }

    bool operator != (const Task& other) const
    { return !(*this == other); }

    string toString() const
    {
        string res = "prefix";
        for (int i : getPrefix()) {
            res += " " + to_string(i);
        }
        res += " current";

        if (hasPredicate())
            res += " " + to_string(getCurrentPredicate());

        return res;
    }

private:
    /// Index of the currently processed predicate (index to the available vector)
    size_t current;

    /// A set of constant predicates that are part of the whole condition represente by this task
    set<int> prefix;

    /// A vector of available predicates (predicates to be tested by this task)
    vector<int> available;

    /// A vector of predicates, which will be "available" in sub tasks
    vector<int> soFar;

    Chain chain;

    Chain prefixChain;

};
