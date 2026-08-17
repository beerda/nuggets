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
#include "Config.h"
#include "ChainCollection.h"
#include "Selector.h"


/**
 * A class applicable for STORAGE template parameter of Digger. It is the storage
 * for discovered association rules. For each condition/focus combination, an
 * association rule is created and stored in the rules vector. Association
 * rule is represented by an antecedent, consequent, and various statistics.
 */
template <typename CHAIN>
class AssocStorage {
    /**
     * The initial capacity of the rules vector. It is used to reserve memory for
     * the rules vector to avoid frequent reallocations during the search process.
     */
    static constexpr size_t INITIAL_RESULT_CAPACITY = 1024;

    /**
     * A structure representing an association rule.
     */
    struct Rule {
        double focusSum;
        double chainSum;
        double predicateSum;
        string antecedent;
        string consequent;
        int antecedentLength;
    };

public:
    /**
     * Constructs a new AssocStorage instance with the given configuration.
     *
     * @param config The configuration object containing search parameters.
     */
    AssocStorage(const Config& config)
        : rules(),
          config(config)
    {
        size_t capacity = config.getMaxResults();
        if (capacity >= SIZE_MAX) {
            capacity = INITIAL_RESULT_CAPACITY;
        }
        rules.reserve(capacity);
    }

    // Disable copy
    AssocStorage(const AssocStorage&) = delete;
    AssocStorage& operator=(const AssocStorage&) = delete;

    // Allow move
    AssocStorage(AssocStorage&&) = default;
    AssocStorage& operator=(AssocStorage&&) = default;

    /**
     * For given condition chain and collection of focus chains, creates
     * association rules and stores them in the rules vector. Condition chain
     * represents the antecedent of the rule, and each focus chain represents a
     * consequent.
     */
    void store(const Clause& prefix,
               const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<double>& predicateSums)
    {
        if (rules.size() >= config.getMaxResults())
            return;

        String ante = formatCondition(prefix, chain);
        for (size_t i = 0; i < collection.focusCount(); ++i) {
            if (!selector.isSelected(i))
                continue;

            const CHAIN& focus = collection[i + collection.firstFocusIndex()];
            size_t predicate = focus.getPredicate();
            string chainName = config.getChainName(predicate);

            Rule rule;
            rule.antecedent = ante;
            rule.consequent = "{" + chainName + "}";
            rule.antecedentLength = prefix.size() + chain.hasPredicate();
            rule.focusSum = focus.getSum();
            rule.chainSum = chain.getSum();
            rule.predicateSum = predicateSums[predicate];

            rules.push_back(rule);
        }
    }

    /**
     * Returns the number of stored association rules.
     */
    inline size_t size() const
    { return rules.size(); }

    /**
     * Returns the stored association rules as a List of R vectors. Each vector
     * corresponds to a property of the rules, such as antecedent, consequent,
     * support, confidence, coverage, etc. A single rule is represented by the
     * values at the same index in each vector. The list may be easily
     * transformed into a data frame in R with columns corresponding to the
     * list elements.
     *
     * @return A List containing the stored association rules as R vectors.
     */
    inline List getResult() const
    {
        CharacterVector antecedentVec(rules.size());
        CharacterVector consequentVec(rules.size());
        NumericVector supportVec(rules.size());
        NumericVector confidenceVec(rules.size());
        NumericVector coverageVec(rules.size());
        NumericVector conseqSupportVec(rules.size());
        NumericVector liftVec(rules.size());
        NumericVector countVec(rules.size());
        IntegerVector antecedentLengthVec(rules.size());
        NumericVector ppVec(rules.size());
        NumericVector pnVec(rules.size());
        NumericVector npVec(rules.size());
        NumericVector nnVec(rules.size());

        for (size_t i = 0; i < rules.size(); ++i) {
            const Rule& rule = rules[i];
            double conf = (rule.chainSum > 0) ? (rule.focusSum / rule.chainSum) : 0.0;
            double conseqSupp = rule.predicateSum / config.getNrow();

            antecedentVec[i] = rule.antecedent;
            consequentVec[i] = rule.consequent;
            supportVec[i] = rule.focusSum / config.getNrow();
            confidenceVec[i] = conf;
            coverageVec[i] = rule.chainSum / config.getNrow();
            conseqSupportVec[i] = conseqSupp;
            liftVec[i] = conf / conseqSupp;
            countVec[i] = rule.focusSum;
            antecedentLengthVec[i] = rule.antecedentLength;
            ppVec[i] = rule.focusSum;
            pnVec[i] = rule.chainSum - rule.focusSum;
            npVec[i] = rule.predicateSum - rule.focusSum;
            nnVec[i] = config.getNrow() - ppVec[i] - pnVec[i] - npVec[i];
        }

        return List::create(Named("antecedent") = antecedentVec,
                            Named("consequent") = consequentVec,
                            Named("support") = supportVec,
                            Named("confidence") = confidenceVec,
                            Named("coverage") = coverageVec,
                            Named("conseq_support") = conseqSupportVec,
                            Named("lift") = liftVec,
                            Named("count") = countVec,
                            Named("antecedent_length") = antecedentLengthVec,
                            Named("pp") = ppVec,
                            Named("pn") = pnVec,
                            Named("np") = npVec,
                            Named("nn") = nnVec);
    }

private:
    /**
     * A vector of stored association rules.
     */
    vector<Rule> rules;

    /**
     * The configuration object.
     */
    const Config& config;

    /**
     * Formats the condition (antecedent) of a chain as a string representation.
     * The condition is represented as a set of predicate names enclosed in
     * curly braces.
     */
    string formatCondition(const Clause& prefix, const CHAIN& chain) const
    {
        if (prefix.empty() && !chain.hasPredicate()) {
            return "{}";
        }

        // from now on, chain must have predicate
        IF_DEBUG(
            if (!chain.hasPredicate())
                throw invalid_argument("AssocStorage: formatCondition: chain has no predicate");
        )


        stringstream res;
        res << "{";

        if (prefix.size() == 0) {
            res << config.getChainName(chain.getPredicate());
        }
        else {
            const string& name0 = config.getChainName(chain.getPredicate());

            if (prefix.size() == 1) {
                const string& name1 = config.getChainName(prefix[0]);
                if (name0 < name1) {
                    res << name0 << "," << name1;
                } else {
                    res << name1 << "," << name0;
                }
            }
            else if (prefix.size() == 2) {
                const string& name1 = config.getChainName(prefix[0]);
                const string& name2 = config.getChainName(prefix[1]);
                if (name0 <= name1) {
                    if (name1 <= name2) {
                        res << name0 << "," << name1 << "," << name2;
                    }
                    else if (name0 <= name2) {
                        res << name0 << "," << name2 << "," << name1;
                    }
                    else {
                        res << name2 << "," << name0 << "," << name1;
                    }
                }
                else {
                    if (name0 <= name2) {
                        res << name1 << "," << name0 << "," << name2;
                    }
                    else if (name1 <= name2) {
                        res << name1 << "," << name2 << "," << name0;
                    }
                    else {
                        res << name2 << "," << name1 << "," << name0;
                    }
                }
            }
            else {
                vector<string> parts;
                parts.reserve(prefix.size() + 1);
                parts.push_back(name0);
                for (size_t predicate : prefix) {
                    parts.push_back(config.getChainName(predicate));
                }
                sort(parts.begin(), parts.end());
                res << parts.front();
                for (size_t i = 1; i < parts.size(); ++i) {
                    res << "," << parts[i];
                }
            }
        }

        res << "}";

        return res.str();
    }
};
