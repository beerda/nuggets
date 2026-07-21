/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2025 Michal Burda
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 **********************************************************************/


#pragma once

#include "../common.h"
#include "Clause.h"

#include <vector>


class DeductionEngine {
public:
    // Disable copy
    DeductionEngine(const DeductionEngine&) = delete;
    DeductionEngine& operator=(const DeductionEngine&) = delete;

    // Allow move
    DeductionEngine(DeductionEngine&&) = default;
    DeductionEngine& operator=(DeductionEngine&&) = default;

    /**
     * Constructs a new deduction engine with the given number of predicates and
     * implications.
     *
     * @param numPredicates The number of predicates in the data.
     * @param implications A list of implications, where each implication is a
     *     vector of predicate IDs, with the last ID being the consequent and
     *     the preceding IDs being the antecedent.
     */
    DeductionEngine(const size_t numPredicates, const List& implications)
        : emptyAntecedentImplications(),
          appearsIn(numPredicates),
          producedBy(numPredicates),
          consequents(implications.size()),
          needs(implications.size()),
          remaining(implications.size()),
          remainingStamp(implications.size(), 0),
          actualPredicateStamp(numPredicates, 0),
          queryId(0),
          numPredicates(numPredicates)
    {
        for (R_xlen_t i = 0; i < implications.size(); ++i) {
            IntegerVector implication = implications[i];
            Clause antecedent = createAntecedent(implication);
            needs[i] = antecedent.size();
            consequents[i] = createConsequent(implication);
            producedBy[consequents[i]].push_back(i);

            if (antecedent.empty()) {
                emptyAntecedentImplications.push_back(i);
            }

            for (size_t predicate : antecedent) {
                appearsIn[predicate].push_back(i);
            }
        }
    }

    /**
     * Checks whether the engine has any implications stored.
     *
     * @return True if the engine has no implications, false otherwise.
     */
    bool empty() const
    { return consequents.empty(); }

    /**
     * Deduces all predicates that can be inferred from the given initial
     * predicates and the implications stored in the engine.
     *
     * @param initial A vector of predicate IDs that are initially known to be true.
     * @return A vector of predicate IDs that can be deduced from the initial
     *     predicates and the implications.
     */
    Clause deduce(const vector<size_t>& initial)
    {
        queryId++;
        Clause result;
        vector<size_t> unprocessed;

        auto addPredicate = [&](size_t predicate) {
            if (actualPredicateStamp[predicate] != queryId) {
                actualPredicateStamp[predicate] = queryId;
                unprocessed.push_back(predicate);
                result.push_back(predicate);
            }
        };

        // process empty-antecedent implications
        for (size_t i : emptyAntecedentImplications) {
            addPredicate(consequents[i]);
        }

        // process the initial predicates
        for (size_t predicate : initial) {
            addPredicate(predicate);
        }

        while (!unprocessed.empty()) {
            size_t predicate = unprocessed.back();
            unprocessed.pop_back();

            // for each implication that has this predicate in its antecedent...
            for (size_t i : appearsIn[predicate]) {
                if (remainingStamp[i] != queryId) {
                    // first time this implication is processed in this query,
                    // so reset the remaining count
                    remainingStamp[i] = queryId;
                    remaining[i] = needs[i];
                }

                remaining[i]--;

                if (remaining[i] == 0) {
                    addPredicate(consequents[i]);
                }
            }
        }

        return result;
    }

    /**
     * Checks whether the target predicate can be deduced from the initial
     * predicates and the implications stored in the engine. If the target
     * predicate is one of the initial predicates, it is removed from the
     * initial predicates before checking.
     *
     * @param initial A vector of predicate IDs that are initially known to be true.
     * @param target The predicate ID to check for (may be present
     *     in the initial predicates).
     * @return True if the target predicate can be deduced from the initial
     *     predicates and the implications, false otherwise.
     */
    bool isDerivableWithout(const vector<size_t>& initial, const size_t target)
    {
        if (producedBy[target].empty()) {
            // no implications produce the target, so it cannot be redundant
            return false;
        }

        queryId++;
        vector<size_t> unprocessed;

        auto addPredicate = [&](size_t predicate) {
            if (actualPredicateStamp[predicate] != queryId) {
                actualPredicateStamp[predicate] = queryId;
                unprocessed.push_back(predicate);
            }
        };

        // process empty-antecedent implications
        for (size_t i : emptyAntecedentImplications) {
            if (consequents[i] == target) {
                // the target can be deduced from an empty antecedent, so it is redundant
                return true;
            }
            addPredicate(consequents[i]);
        }

        // process the initial predicates
        for (size_t predicate : initial) {
            if (predicate != target)
                addPredicate(predicate);
        }

        while (!unprocessed.empty()) {
            size_t predicate = unprocessed.back();
            unprocessed.pop_back();

            // for each implication that has this predicate in its antecedent...
            for (size_t i : appearsIn[predicate]) {
                if (remainingStamp[i] != queryId) {
                    // first time this implication is processed in this query,
                    // so reset the remaining count
                    remainingStamp[i] = queryId;
                    remaining[i] = needs[i];
                }

                remaining[i]--;

                if (remaining[i] == 0) {
                    if (consequents[i] == target) {
                        // the target can be deduced, so it is redundant
                        return true;
                    }
                    addPredicate(consequents[i]);
                }
            }
        }

        return false;
    }

    /**
     * Checks whether any of the initial predicates can be deduced from the
     * other initial predicates and the implications stored in the engine.
     *
     * @param initial A vector of predicate IDs that are initially known to be true.
     * @return True if any of the initial predicates can be deduced from the
     *    other initial predicates and the implications, false otherwise.
     */
    bool hasRedundant(const vector<size_t>& initial)
    {
        for (size_t predicate : initial) {
            if (isDerivableWithout(initial, predicate)) {
                return true;
            }
        }
        return false;
    }

private:
    /**
     * Vector of indices of implications that have an empty antecedent, i.e.,
     * needs[i] == 0. These implications can be applied immediately in any query.
     */
    vector<size_t> emptyAntecedentImplications;

    /*
     * For each predicate, a list of indices of implications that have this
     * predicate in their antecedent.
     */
    vector<vector<size_t>> appearsIn;

    /**
     * For each predicate, a list of indices of implications that have this
     * predicate as their consequent.
     */
    vector<vector<size_t>> producedBy;

    /*
     * Consequent of the i-th implication
     */
    vector<size_t> consequents;

    /*
     * Length of the antecedent of the i-th implication (how many predicates
     * are needed to deduce the consequent)
     */
    vector<size_t> needs;

    /**
     * Number of predicates satisfied in the antecedent of the i-th implication
     * in the current query. Whether the value is actual or not is determined
     * by the remaining_stamp vector.
     */
    vector<size_t> remaining;

    /**
     * For each implication, a stamp indicating whether the remaining count is
     * actual for the current query. If remainingStamp[i] == queryId,
     * then remaining[i] is actual for the current query. Otherwise, it is stale
     * and should be considered as 0.
     */
    vector<size_t> remainingStamp;

    /**
     * For each predicate, a stamp indicating whether the predicate has been
     * deduced in the current query. If actualPredicateStamp[predicate] == queryId
     * then the predicate has been deduced in the current query. Otherwise, it
     * has not been deduced yet.
     */
    vector<size_t> actualPredicateStamp;

    /**
     * The current query ID. It is incremented for each new query to avoid
     * resetting the remaining counts for all implications. Instead, we use
     * the remainingStamp vector to determine whether the remaining count is
     * actual for the current query.
     */
    size_t queryId;

    /**
     * The maximum number of predicates in the data. It makes sure that
     * predicate with ID >= numPredicates is not used in the implications.
     */
    size_t numPredicates;

    /**
     * Creates the antecedent of an implication from the given IntegerVector.
     */
    static Clause createAntecedent(const IntegerVector& implication)
    {
        Clause antecedent(implication.size() - 1);
        for (R_xlen_t j = 0; j < implication.size() - 1; j++) {
            antecedent[j] = implication[j];
        }
        antecedent.sortAndUnique();

        return antecedent;
    }

    /**
     * Creates the consequent of an implication from the given IntegerVector.
     */
    static size_t createConsequent(const IntegerVector& implication)
    { return implication[implication.size() - 1]; }
};
