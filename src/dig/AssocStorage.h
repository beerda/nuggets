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
public:
    AssocStorage(const Config& config)
        : config(config),
          result()
    { result.reserve(1000); }

    // Disable copy
    AssocStorage(const AssocStorage&) = delete;
    AssocStorage& operator=(const AssocStorage&) = delete;

    // Allow move
    AssocStorage(AssocStorage&&) = default;
    AssocStorage& operator=(AssocStorage&&) = default;

    void store(const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<float>& predicateSums)
    {
        size_t selectedCount = selector.getSelectedCount();
        String ante = formatCondition(chain);

        StringVector antecedent(selectedCount);
        StringVector consequent(selectedCount);
        NumericVector pp(selectedCount);
        NumericVector np(selectedCount);
        NumericVector pn(selectedCount);
        NumericVector nn(selectedCount);
        NumericVector support(selectedCount);
        NumericVector confidence(selectedCount);
        NumericVector coverage(selectedCount);
        NumericVector conseq_support(selectedCount);
        NumericVector lift(selectedCount);
        NumericVector count(selectedCount);
        NumericVector antecedent_length(selectedCount);

        size_t j = 0;
        for (size_t i = 0; i < collection.focusCount(); ++i) {
            if (!selector.isSelected(i))
                continue;

            const CHAIN& focus = collection[i + collection.firstFocusIndex()];
            size_t predicate = focus.getClause().back();
            string chainName = config.getChainName(predicate);
            float focusSum = focus.getSum();
            float chainSum = chain.getSum();
            float predicateSum = predicateSums[predicate];

            antecedent[j] = ante;
            consequent[j] = string("{") + chainName + string("}");

            pp[j] = focusSum;
            pn[j] = chainSum - focusSum;
            np[j] = predicateSum - focusSum;
            nn[j] = config.getNrow() - pp[j] - pn[j] - np[j];

            support[j] = pp[j] / config.getNrow();
            confidence[j] = (chainSum > 0) ? (pp[j] / chainSum) : 0.0;
            coverage[j] = chainSum / config.getNrow();
            conseq_support[j] = predicateSum / config.getNrow();
            lift[j] = (coverage[j] > 0) ? (confidence[j] / conseq_support[j]) : 0.0;
            count[j] = pp[j];
            antecedent_length[j] = chain.getClause().size();

            j++;
        }

        DataFrame df = DataFrame::create(Named("antecedent") = antecedent,
                                         Named("consequent") = consequent,
                                         Named("support") = support,
                                         Named("confidence") = confidence,
                                         Named("coverage") = coverage,
                                         Named("conseq_support") = conseq_support,
                                         Named("lift") = lift,
                                         Named("count") = count,
                                         Named("antecedent_length") = antecedent_length,
                                         Named("pp") = pp,
                                         Named("pn") = pn,
                                         Named("np") = np,
                                         Named("nn") = nn);
        result.push_back(df);
    }

    inline size_t size() const
    { return result.size(); }

    inline List getResult() const
    {
        // Rcpp:List is tragically slow if the size is not known in advance
        List res(result.size());
        for (size_t i = 0; i < result.size(); ++i) {
            res[i] = result[i];
        }

        return res;
    }

private:
    const Config& config;
    vector<RObject> result;

    string formatCondition(const CHAIN& chain) const
    {
        const Clause& clause = chain.getClause();
        vector<string> parts(clause.size());
        for (size_t i = 0; i < clause.size(); ++i) {
            parts[i] = config.getChainName(clause[i]);
        }
        sort(parts.begin(), parts.end());

        stringstream res;
        res << "{";
        for (size_t i = 0; i < parts.size(); ++i) {
            if (i > 0)
                res << ",";
            res << parts[i];
        }
        res << "}";

        return res.str();
    }
};
