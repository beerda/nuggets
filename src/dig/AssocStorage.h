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
#include "Config.h"
#include "ChainCollection.h"
#include "Selector.h"


template <typename CHAIN>
class AssocStorage {
    static constexpr size_t INITIAL_RESULT_CAPACITY = 1024;

    struct Rule {
        double focusSum;
        double chainSum;
        double predicateSum;
        string antecedent;
        string consequent;
        int antecedentLength;
    };

public:
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

    void store(const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<double>& predicateSums)
    {
        if (rules.size() >= config.getMaxResults())
            return;

        String ante = formatCondition(chain);
        for (size_t i = 0; i < collection.focusCount(); ++i) {
            if (!selector.isSelected(i))
                continue;

            const CHAIN& focus = collection[i + collection.firstFocusIndex()];
            size_t predicate = focus.getClause().back();
            string chainName = config.getChainName(predicate);

            Rule rule;
            rule.antecedent = ante;
            rule.consequent = "{" + chainName + "}";
            rule.antecedentLength = chain.getClause().size();
            rule.focusSum = focus.getSum();
            rule.chainSum = chain.getSum();
            rule.predicateSum = predicateSums[predicate];

            rules.push_back(rule);
        }
    }

    inline size_t size() const
    { return rules.size(); }

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
    vector<Rule> rules;
    const Config& config;

    string formatCondition(const CHAIN& chain) const
    {
        const Clause& clause = chain.getClause();
        if (clause.empty())
            return "{}";

        stringstream res;
        res << "{";

        if (clause.size() == 1) {
            res << config.getChainName(clause[0]);
        }
        else if (clause.size() == 2) {
            const string& name0 = config.getChainName(clause[0]);
            const string& name1 = config.getChainName(clause[1]);
            if (name0 < name1) {
                res << name0 << "," << name1;
            } else {
                res << name1 << "," << name0;
            }
        }
        else if (clause.size() == 3) {
            const string& name0 = config.getChainName(clause[0]);
            const string& name1 = config.getChainName(clause[1]);
            const string& name2 = config.getChainName(clause[2]);
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
            parts.reserve(clause.size());
            for (size_t predicate : clause) {
                parts.push_back(config.getChainName(predicate));
            }
            sort(parts.begin(), parts.end());
            res << parts.front();
            for (size_t i = 1; i < parts.size(); ++i) {
                res << "," << parts[i];
            }
        }

        res << "}";

        return res.str();
    }
};
