#pragma once

#include "../common.h"


/**
 * Base class for representation of a predicate and the corresponding chain
 * of values.
 */
class BaseChain {
public:
    /**
     * The type of the predicate represented by this chain, i.e.,
     * where the predicate may appear (in condition (antecedent),
     * in focus (consequent), or in both positions).
     */
    enum PredicateType {
        CONDITION = 1,
        BOTH = 2, // this is because of sorting order: CONDITION, BOTH, FOCUS
        FOCUS = 3
    };

    static PredicateType createPredicateType(bool isCondition, bool isFocus)
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
     * empty formula.
     */
    BaseChain()
        : formula(),
          predicateType(CONDITION),
          sum(0)
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
    BaseChain(size_t id, PredicateType type, size_t sum)
        : formula({id}),
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
    BaseChain(const BaseChain& a, const BaseChain& b)
        : formula(a.formula.size() + 1),
          predicateType(b.predicateType),
          sum(0)
    {
        IF_DEBUG(
            if (!a.isCondition())
                throw invalid_argument("BaseChain: first chain is not a condition");

            if (a.formula.size() != b.formula.size())
                throw invalid_argument("BaseChain: formula sizes differ");

            for (size_t i = 0; i < a.formula.size() - 1; ++i) {
                if (a.formula[i] != b.formula[i])
                    throw invalid_argument("BaseChain: formula prefixes differ");
            }
        )
        formula.assign(a.formula.begin(), a.formula.end());
        formula.push_back(b.formula.back());
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
    bool operator==(const BaseChain& other) const
    {
        return (sum == other.sum)
            && (predicateType == other.predicateType)
            && (formula == other.formula);
    }

    /**
     * Comparison (inequality) operator.
     */
    bool operator!=(const BaseChain& other) const
    { return !(*this == other); }

    /**
     * Returns the formula of the chain, i.e., the vector of predicate ids.
     */
    const vector<size_t>& getFormula() const
    { return formula; }

    /**
     * Returns the sum of TRUEs (for binary data) or membership degrees (for
     * fuzzy data) of the chain.
     */
    size_t getSum() const
    { return sum; }

    /**
     * Returns the type of the predicate represented by this chain.
     */
    PredicateType getPredicateType() const
    { return predicateType; }

    /**
     * Returns TRUE if the predicate may appear in the focus (consequent),
     * i.e., if the chain is of type FOCUS or BOTH.
     */
    bool isFocus() const
    { return predicateType != CONDITION; }

    /**
     * Returns TRUE if the predicate may appear in the condition (antecedent),
     * i.e., if the chain is of type CONDITION or BOTH.
     */
    bool isCondition() const
    { return predicateType != FOCUS; }

protected:
    /**
     * The formula of the chain, i.e., the vector of predicate ids.
     */
    vector<size_t> formula;

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
    size_t sum;
};
