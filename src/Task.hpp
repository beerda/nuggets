#pragma once

#include <vector>
#include <set>
#include "common.hpp"


/**
 * Task represents a single level of traversal through the search space of conditions.
 */
class Task {
public:
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
        return available[current];
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
        if (hasPredicate()) {
            set<int> newPrefix = getPrefix();
            newPrefix.insert(getCurrentPredicate());
            return Task(newPrefix, getSoFar());
        }
        else {
            return Task(getPrefix(), getSoFar());
        }
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

};
