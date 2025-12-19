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


/**
 * Base class for representation of a predicate and the corresponding chain
 * of values.
 */
class BaseChain {
public:
    static inline PredicateType createPredicateType(const bool isCondition, const bool isFocus)
    {
        if (isCondition && isFocus) {
            return BOTH;
        } else if (isCondition) {
            return CONDITION;
        } else if (isFocus) {
            return FOCUS;
        } else {
            throw invalid_argument("BaseChain: predicate type is not specified");
        }
    }

    /**
     * Default constructor that creates an empty chain of type CONDITION with
     * empty clause.
     */
    BaseChain(float sum)
        : clause(),
          predicateType(CONDITION),
          sum(sum)
    { }

    /**
     * Constructor that creates a chain with the specified id, type and sum.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions)
     * @param sum The sum of TRUEs (for binary data) or membership degrees
     *     (for fuzzy data) of the chain.
     */
    BaseChain(size_t id, PredicateType type, float sum)
        : clause({ id }),
          predicateType(type),
          sum(sum)
    { }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    BaseChain(const BaseChain& a, const BaseChain& b, const bool toFocus)
        : clause(a.clause.size() + 1),
          predicateType(toFocus ? PredicateType::FOCUS : b.predicateType),
          sum(0)
    {
        IF_DEBUG(
            if (!a.isCondition())
                throw invalid_argument("BaseChain: first chain is not a condition");

            if (toFocus && b.predicateType != PredicateType::BOTH)
                throw invalid_argument("BaseChain: illegal conversion to FOCUS");

            if (a.clause.size() != b.clause.size())
                throw invalid_argument("BaseChain: clause sizes differ");

            for (size_t i = 0; i < a.clause.size() - 1; ++i) {
                if (a.clause[i] != b.clause[i])
                    throw invalid_argument("BaseChain: clause prefixes differ");
            }
        )
        clause.assign(a.clause.begin(), a.clause.end());
        clause.push_back(b.clause.back());
    }

    // Allow copy
    BaseChain(const BaseChain& other) = default;
    BaseChain& operator=(const BaseChain& other) = default;

    // Allow move
    BaseChain(BaseChain&& other) = default;
    BaseChain& operator=(BaseChain&& other) = default;

    /**
     * Comparison (equality) operator.
     */
    inline bool operator==(const BaseChain& other) const
    {
        return (sum == other.sum)
            && (predicateType == other.predicateType)
            && (clause == other.clause);
    }

    /**
     * Comparison (inequality) operator.
     */
    inline bool operator!=(const BaseChain& other) const
    { return !(*this == other); }

    /**
     * Returns the clause of the chain, i.e., the vector of predicate ids.
     */
    inline const Clause& getClause() const
    { return clause; }

    /**
     * Returns the sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     */
    inline float getSum() const
    { return sum; }

    inline vector<size_t>& getMutableDeduced()
    { return deduced; }

    inline bool deduces(const size_t id) const
    {
        bool result = std::find(deduced.begin(), deduced.end(), id) != deduced.end();
        //cout << "deducing: " << clauseAsString() << " -> " << id << ": " << (result ? "TRUE" : "FALSE") << endl;

        return result;
    }

    inline bool deducesItself() const
    {
        for (size_t predicate : clause) {
            if (deduces(predicate)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Returns the type of the predicate represented by this chain.
     */
    inline PredicateType getPredicateType() const
    { return predicateType; }

    /**
     * Returns TRUE if the predicate may appear in the focus (consequent),
     * i.e., if the chain is of type FOCUS or BOTH.
     */
    inline bool isFocus() const
    { return predicateType != CONDITION; }

    /**
     * Returns TRUE if the predicate may appear in the condition (antecedent),
     * i.e., if the chain is of type CONDITION or BOTH.
     */
    inline bool isCondition() const
    { return predicateType != FOCUS; }

    inline string clauseAsString() const
    {
        string res = "";
        bool first = true;
        for (size_t p : clause) {
            if (first) {
                first = false;
            }
            else {
                res += "&";
            }
            res += std::to_string(p);
        }

        return res;
    }

protected:
    /**
     * The clause of the chain, i.e., the vector of predicate ids.
     */
    Clause clause;

    /**
     * The type of the predicate represented by this chain, i.e.,
     * where the predicate may appear (in condition (antecedent),
     * in focus (consequent), or in both positions).
     */
    PredicateType predicateType;

    /**
     * The sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     */
    float sum;

    vector<size_t> deduced;
};
