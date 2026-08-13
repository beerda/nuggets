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
#include "../timer.h"


/**
 * Base class for representation of a predicate and the corresponding chain
 * of values. Descendants of this class can be used as the CHAIN template
 * parameter of Digger.
 *
 * BaseChain handles the common functionality of chains, such as storing the
 * last predicate of the clause, the sum of TRUEs or membership degrees,
 * and the predicate type (condition, focus, or both). Constructors are provided
 * for creating chains from a single predicate, combining two chains, and
 * creating an empty chain or chain with cached sum. (Chain with cached sum
 * does not contain raw data, but only the sum of TRUEs or membership degrees,
 * and as such, it is not suitable for further combination with other chains.)
 */
class BaseChain {
public:
    /**
     * Creates a predicate type based on the given boolean flags indicating
     * whether the predicate is a condition and/or a focus. If both flags are
     * false, an invalid_argument exception is thrown.
     *
     * @param isCondition A boolean flag indicating whether the predicate is
     *     a condition.
     * @param isFocus A boolean flag indicating whether the predicate is a focus.
     * @return The corresponding PredicateType based on the flags.
     */
    static inline PredicateType createPredicateType(
            const bool isCondition, const bool isFocus)
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
     * empty predicate. Predicates are indexed from 1, so 0 is used to represent
     * an empty predicate.
     *
     * @param sum The sum of TRUEs (for binary data) or membership degrees
     *     (for fuzzy data) of the chain.
     */
    BaseChain(double sum)
        : sum(sum),
          predicate(0),
          predicateType(CONDITION),
          cached(false)
    {
        IF_DEBUG(
            if (sum < 0.0)
                throw invalid_argument("BaseChain: sum cannot be negative");
        )
    }

    /**
     * Constructor that creates a chain with the specified id, type and sum.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions)
     * @param sum The sum of TRUEs (for binary data) or membership degrees
     *     (for fuzzy data) of the chain.
     */
    BaseChain(size_t id, PredicateType type, double sum)
        : sum(sum),
          predicate(id),
          predicateType(type),
          cached(false)
    {
        IF_DEBUG(
            if (predicate == 0)
                throw invalid_argument("BaseChain: predicate id cannot be 0");

            if (sum < 0.0)
                throw invalid_argument("BaseChain: sum cannot be negative");
        )
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction. The stored predicate is taken from the second chain,
     * because the first chain's predicate is expected to go to Digger::prefix.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    BaseChain(const BaseChain& a, const BaseChain& b)
        : sum(0),
          predicate(b.predicate),
          predicateType(b.predicateType),
          cached(false)
    {
        IF_DEBUG(
            if (!a.isCondition())
                throw invalid_argument("BaseChain: first chain is not a condition");

            if (b.predicate == 0)
                throw invalid_argument("BaseChain: second chain has empty predicate");
        )
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction.
     *
     * @param a The first chain.
     * @param b The second chain.
     * @param sum The sum of TRUEs (for binary data) or membership degrees
     *     (for fuzzy data) of the chain.
     */
    BaseChain(const BaseChain& a, const BaseChain& b, const double sum)
        : sum(sum),
          predicate(b.predicate),
          predicateType(PredicateType::FOCUS),
          cached(true)
    {
        IF_DEBUG(
            if (!a.isCondition())
                throw invalid_argument("BaseChain: first chain is not a condition");

            if (b.predicate == 0)
                throw invalid_argument("BaseChain: second chain has empty predicate");

            if (b.predicateType != PredicateType::BOTH)
                throw invalid_argument("BaseChain: illegal conversion to FOCUS");

            if (sum < 0.0)
                throw invalid_argument("BaseChain: sum cannot be negative");
        )
    }

    // Disable copy
    BaseChain(const BaseChain& other) = delete;
    BaseChain& operator=(const BaseChain& other) = delete;

    // Allow move
    BaseChain(BaseChain&& other) = default;
    BaseChain& operator=(BaseChain&& other) = default;

    /**
     * Comparison (equality) operator.
     *
     * @param other The other BaseChain to compare with.
     * @return True if the two BaseChains are equal and false otherwise.
     */
    inline bool operator==(const BaseChain& other) const
    {
        return (sum == other.sum)
            && (predicateType == other.predicateType)
            && (predicate == other.predicate);
    }

    /**
     * Comparison (inequality) operator.
     *
     * @param other The other BaseChain to compare with.
     * @return True if the two BaseChains are not equal and false otherwise.
     */
    inline bool operator!=(const BaseChain& other) const
    { return !(*this == other); }

    /**
     * Returns the predicate of the chain, i.e., the last predicate of the clause.
     * (Assuming that the prefix of the clause is stored in Digger::prefix.)
     *
     * @return The last predicate of the chain.
     */
    inline const size_t& getPredicate() const
    {
        IF_DEBUG(
            if (predicate == 0)
                throw invalid_argument("BaseChain: predicate is empty");
        )

        return predicate;
    }

    inline bool hasPredicate() const
    { return predicate != 0; }

    /**
     * Returns the sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     *
     * @return The sum of TRUEs or membership degrees of the chain.
     */
    inline double getSum() const
    { return sum; }

    /**
     * Sets the sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     *
     * @param newSum The new sum of TRUEs or membership degrees to set for the chain.
     */
    inline void setSum(double newSum)
    {
        IF_DEBUG(
            if (newSum < 0.0)
                throw invalid_argument("BaseChain: sum cannot be negative");
        )
        sum = newSum;
    }

    /**
     * Returns the type of the predicate represented by this chain.
     *
     * @return The type of the predicate (where it may appear - in condition,
     *     focus, or in both positions).
     */
    inline PredicateType getPredicateType() const
    { return predicateType; }

    /**
      * Sets the type of the predicate represented by this chain.
      *
      * @param newType The new type of the predicate to set for the chain.
      */
    inline void setPredicateType(PredicateType newType)
    { predicateType = newType; }

    /**
     * Returns TRUE if the sum is obtained from cache instead of being computed
     * from data chains.
     *
     * @return True if the sum is obtained from cache, false otherwise.
     */
    inline bool isCached() const
    { return cached; }

    /**
     * Returns TRUE if the predicate may appear in the focus (consequent),
     * i.e., if the chain is of type FOCUS or BOTH.
     *
     * @return True if the predicate may appear in the focus, false otherwise.
     */
    inline bool isFocus() const
    { return predicateType != CONDITION; }

    /**
     * Returns TRUE if the predicate may appear in the condition (antecedent),
     * i.e., if the chain is of type CONDITION or BOTH.
     *
     * @return True if the predicate may appear in the condition, false otherwise.
     */
    inline bool isCondition() const
    { return predicateType != FOCUS; }

    /**
     * Returns TRUE if the predicate may appear only in the condition (antecedent),
     * i.e., if the chain is of type CONDITION.
     *
     * @return True if the predicate may appear only in the condition, false otherwise.
     */
    inline bool isConditionOnly() const
    { return predicateType == CONDITION; }

    /**
     * Returns TRUE if the predicate may appear only in the focus (consequent),
     * i.e., if the chain is of type FOCUS.
     *
     * @return True if the predicate may appear only in the focus, false otherwise.
     */
    inline bool isFocusOnly() const
    { return predicateType == FOCUS; }

protected:
    /**
     * The sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     */
    double sum;

    /**
     * The last predicate in the condition. It forms the complete condition
     * clause together with the prefix stored in Digger::prefix.
     */
    size_t predicate;

    /**
     * The type of the predicate represented by this chain, i.e.,
     * where the predicate may appear (in condition (antecedent),
     * in focus (consequent), or in both positions).
     */
    PredicateType predicateType;

    /**
     * Indicates whether the sum is obtained from cache instead of being
     * computed from data chains.
     */
    bool cached;
};
