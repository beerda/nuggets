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

public:
    AssocStorage(const Config& config)
        : config(config),
          antecedentVec(),
          consequentVec(),
          supportVec(),
          confidenceVec(),
          coverageVec(),
          conseqSupportVec(),
          liftVec(),
          countVec(),
          antecedentLengthVec(),
          ppVec(),
          pnVec(),
          npVec(),
          nnVec()
    {
        size_t capacity = config.getMaxResults();
        if (capacity > INITIAL_RESULT_CAPACITY)
            capacity = INITIAL_RESULT_CAPACITY;

        antecedentVec.reserve(capacity);
        consequentVec.reserve(capacity);
        supportVec.reserve(capacity);
        confidenceVec.reserve(capacity);
        coverageVec.reserve(capacity);
        conseqSupportVec.reserve(capacity);
        liftVec.reserve(capacity);
        countVec.reserve(capacity);
        antecedentLengthVec.reserve(capacity);
        ppVec.reserve(capacity);
        pnVec.reserve(capacity);
        npVec.reserve(capacity);
        nnVec.reserve(capacity);
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
        if (antecedentVec.size() >= config.getMaxResults())
            return;

        String ante = formatCondition(chain);
        for (size_t i = 0; i < collection.focusCount(); ++i) {
            if (!selector.isSelected(i))
                continue;

            const CHAIN& focus = collection[i + collection.firstFocusIndex()];
            size_t predicate = focus.getClause().back();
            string chainName = config.getChainName(predicate);
            double focusSum = focus.getSum();
            double chainSum = chain.getSum();
            double predicateSum = predicateSums[predicate];
            double conf = (chainSum > 0) ? (focusSum / chainSum) : 0.0;
            double conseqSupp = predicateSum / config.getNrow();
            double cover = chainSum / config.getNrow();
            double pp = focusSum;
            double pn = chainSum - focusSum;
            double np = predicateSum - focusSum;
            double nn = config.getNrow() - pp - pn - np;

            antecedentVec.push_back(ante);
            consequentVec.push_back("{" + chainName + "}");

            ppVec.push_back(pp);
            pnVec.push_back(pn);
            npVec.push_back(np);
            nnVec.push_back(nn);

            supportVec.push_back(focusSum / config.getNrow());
            confidenceVec.push_back(conf);
            coverageVec.push_back(cover);
            conseqSupportVec.push_back(conseqSupp);
            liftVec.push_back((cover > 0) ? (conf / conseqSupp) : 0.0);
            countVec.push_back(focusSum);
            antecedentLengthVec.push_back(chain.getClause().size());
        }
    }

    inline size_t size() const
    { return antecedentVec.size(); }

    inline List getResult() const
    {
        return List::create(Named("antecedent") = wrap(antecedentVec),
                            Named("consequent") = wrap(consequentVec),
                            Named("support") = wrap(supportVec),
                            Named("confidence") = wrap(confidenceVec),
                            Named("coverage") = wrap(coverageVec),
                            Named("conseq_support") = wrap(conseqSupportVec),
                            Named("lift") = wrap(liftVec),
                            Named("count") = wrap(countVec),
                            Named("antecedent_length") = wrap(antecedentLengthVec),
                            Named("pp") = wrap(ppVec),
                            Named("pn") = wrap(pnVec),
                            Named("np") = wrap(npVec),
                            Named("nn") = wrap(nnVec));
    }

private:
    const Config& config;
    vector<string> antecedentVec;
    vector<string> consequentVec;
    vector<double> supportVec;
    vector<double> confidenceVec;
    vector<double> coverageVec;
    vector<double> conseqSupportVec;
    vector<double> liftVec;
    vector<double> countVec;
    vector<int> antecedentLengthVec;
    vector<double> ppVec;
    vector<double> pnVec;
    vector<double> npVec;
    vector<double> nnVec;

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
