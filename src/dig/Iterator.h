#pragma once

#include <vector>
#include "../common.h"


class Iterator {
public:
    Iterator()
    { }

    /**
     * Create iterator representing an empty condition (condition of length 0) that may be extended
     * with 0..n-1 predicates stored in the soFar vector
     * @param n The number of predicates to store into soFar
     */
    Iterator(size_t n)
        : current(0)
    {
        soFar.reserve(n);
        for (size_t i = 0; i < n; i++) {
            soFar.push_back(i);
        }
    }

    /**
     * Create iterator representing an empty condition (condition of length 0) that may be extended
     * @param soFar predicates for further search in sub iterators
     */
    Iterator(vector<int> soFar)
        : current(0), soFar(soFar)
    { }

    /**
     * Create an iterator
     * @param prefix the prefix of the condition (constant predicates)
     * @param n The number of predicates to store into soFar
     */
    Iterator(vector<int> prefix, size_t n)
        : current(0), prefix(prefix)
    {
        available.reserve(n);
        for (size_t i = 0; i < n; i++) {
            available.push_back(i);
        }
    }

    /**
     * Create an iterator
     * @param prefix the prefix of the condition (constant predicates)
     * @param available a vector of available predicates to be examined in this iterator
     */
    Iterator(vector<int> prefix, vector<int> available)
        : current(0), prefix(prefix), available(available)
    { }

    /**
     * Create an iterator
     * @param prefix the prefix of the condition (constant predicates)
     * @param a vector of available predicates to be examined in this iterator
     * @param soFar a vector of predicates for sub iterators
     */
    Iterator(vector<int> prefix, vector<int> available, vector<int> soFar)
        : current(0), prefix(prefix), available(available), soFar(soFar)
    { }

    /**
     * Get the actual predicate that the iterator points to
     * @return The predicate
     */
    int getCurrentPredicate() const
    {
        if (!hasPredicate())
            throw runtime_error("Attempt to get unavailable predicate");

        return available[current];
    }

    /**
     * Get the actual condition, i.e. prefix + current predicate
     * @return The condition
     */
    set<int> getCurrentCondition() const
    {
        set<int> result(prefix.begin(), prefix.end());

        if (hasPredicate()) {
            result.insert(getCurrentPredicate());
        }

        return result;
    }

    /**
     * Get the length of the condition represented by this iterator
     */
    size_t getLength() const
    { return prefix.size() + hasPredicate(); }

    /**
     * Start the enumeration of available predicates from the beginning. The internal pointer to the current predicate
     * is set to 0 and the vector of soFar predicates is cleared.
     */
    void reset()
    {
        current = 0;
        stored.clear();
        soFar.clear();
    }

    /**
     * Go to the next available predicate.
     */
    void next()
    { current++; }

    /**
     * TRUE if iterator has more predicates, i.e., if getCurrentPredicate() can be called.
     */
    bool hasPredicate() const
    { return current < available.size(); }

    /**
     * TRUE if the iterator has any predicates to be tested in sub iterators
     */
    bool hasSoFar() const
    { return !soFar.empty(); }

    /**
     * TRUE if the iterator has any predicates stored in stored vector
     */
    bool hasStored() const
    { return !stored.empty(); }

    /**
     * TRUE if the iterator has a non-empty prefix
     */
    bool hasPrefix() const
    { return !prefix.empty(); }

    /**
     * TRUE if the iterator is empty (empty prefix, available predicates, stored and soFar predicates)
     */
    bool empty() const
    { return prefix.empty() && available.empty() && soFar.empty() && stored.empty(); }

    /**
     * Get the number of predicates that are available for processing
     */
    size_t toBeProcessed() const
    { return available.size() - current; }

    /**
     * Get the prefix of the condition represented by this iterator
     */
    const vector<int> getPrefix() const
    { return prefix; }

    /**
     * Get the available predicates
     */
    const vector<int> getAvailable() const
    { return available; }

    /**
     * Get the soFar predicates
     */
    const vector<int> getSoFar() const
    { return soFar; }

    /**
     * Get the stored predicates
     */
    const vector<int> getStored() const
    { return stored; }

    /**
     * Put current predicate into soFar predicates
     */
    void putCurrentToSoFar()
    { soFar.push_back(getCurrentPredicate()); }

    /**
     * Put current predicate into stored predicates
     */
    void storeCurrent()
    { stored.push_back(getCurrentPredicate()); }

    /**
     * Compare two iterators for equality
     */
    bool operator == (const Iterator& other) const
    {
        return current == other.current
            && prefix == other.prefix
            && available == other.available
            && soFar == other.soFar
            && stored == other.stored;
    }

    /**
     * Compare two iterators for inequality
     */
    bool operator != (const Iterator& other) const
    { return !(*this == other); }

    /**
     * Convert the iterator to a string
     */
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

    /// A set of constant predicates that are part of the whole condition represented by this iterator
    vector<int> prefix;

    /// A vector of predicates available to processing (predicates to be tested by this iterator)
    vector<int> available;

    /// A vector of predicates, which will be "available" in sub iterators
    vector<int> soFar;

    /// A vector of predicates, which are processed and selected for current condition.
    /// Stored predicates do not necessarily go to sub iterations.
    /// If the iterator captures foci, stored foci are those that are connected
    /// to current condition.
    vector<int> stored;
};
