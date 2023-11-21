#pragma once

#include <unordered_set>
#include "../common.h"


class Condition {
public:
    Condition(const IntegerVector& _predicates)
        : predicates(_predicates.begin(), _predicates.end())
    { }

    Condition(const unordered_set<int>& _predicates)
        : predicates(_predicates)
    { }

    bool hasPredicate(int predicate) const {
        return predicates.find(predicate) != predicates.end();
    }

    const unordered_set<int> getPredicates() const {
        return predicates;
    }

    int length() const {
        return predicates.size();
    }

private:
    unordered_set<int> predicates;
};
