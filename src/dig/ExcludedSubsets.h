#pragma once

#include <vector>
#include <unordered_map>
#include <algorithm>

#include "../common.h"


class ExcludedSubsets {
public:
    using Subset = vector<int>;
    using Subsets = vector<Subset>;

    ExcludedSubsets()
    { }

    /**
     * Constructs excluded subsets from the given list of excluded subsets.
     * Constructor assumes that the list elements are integer vectors of indices
     * of the original R data columns minus 1 (i.e. 0-based). Because the indexing
     * of predicates is permuted (because of sorting that is done in Data class),
     * the permutation vector is used to map the original indices to the permuted ones
     * that are used internally in condition Iterator.
     */
    ExcludedSubsets(List excludedList, vector<size_t> permutation)
    {
        Subsets excludedVec;
        excludedVec.reserve(excludedList.size());
        for (R_xlen_t i = 0; i < excludedList.size(); i++) {
            IntegerVector vec = excludedList[i];
            if (vec.size() > 0) {
                Subset subset;
                subset.reserve(vec.size());
                for (R_xlen_t j = 0; j < vec.size(); j++) {
                    subset.push_back(permutation[vec[j]]);
                }
                sort(subset.begin(), subset.end());
                excludedVec.push_back(subset);
            }
        }
        sort(excludedVec.begin(), excludedVec.end(), CompareBySize());

        for (const Subset& subset : excludedVec) {
            for (size_t i = 0; i < subset.size(); i++) {
                int key = subset[i];
                if (map.find(key) == map.end()) {
                    map[key] = Subsets();
                }
                Subset newSubset;
                newSubset.reserve(subset.size() - 1);
                for (size_t j = 0; j < subset.size(); j++) {
                    if (i != j) {
                        newSubset.push_back(subset[j]);
                    }
                }
                map[key].push_back(newSubset);
            }
        }
    }

    /**
     * Returns TRUE iff there exists an excluded_subset that contains the predicate and
     * also all its remaining elements are present in the prefix.
     */
    bool isExcluded(const vector<int>& prefix, int predicate) const
    {
        if (map.find(predicate) == map.end()) {
            return false;
        }

        vector<int> sortedPrefix(prefix);
        sort(sortedPrefix.begin(), sortedPrefix.end());

        const Subsets& subsets = map.at(predicate);
        for (const Subset& subset : subsets) {
            if (includes(sortedPrefix.begin(), sortedPrefix.end(),
                         subset.begin(), subset.end())) {
                return true;
            }
        }

        return false;
    }

    const Subsets& getExcludedSubsets(int predicate) const
    { return map.at(predicate); }

    bool empty() const
    { return map.empty(); }

    size_t size() const
    { return map.size(); }

private:
    struct CompareBySize {
        bool operator()(const Subset& a, const Subset& b) const
        { return a.size() < b.size(); }
    };

    unordered_map<int, Subsets> map;
};
