/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2026 Michal Burda
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
#include "Trie.h"


class TemplatingEngine {
public:
    // Disable copy
    TemplatingEngine(const TemplatingEngine&) = delete;
    TemplatingEngine& operator=(const TemplatingEngine&) = delete;

    // Allow move
    TemplatingEngine(TemplatingEngine&&) = default;
    TemplatingEngine& operator=(TemplatingEngine&&) = default;

    TemplatingEngine(const List& templates, const vector<size_t>& order)
        : trie(templates.size())
    {
        for (R_xlen_t i = 0; i < templates.size(); ++i) {
            IntegerVector tmpl = templates[i];
            Clause clause = createClause(tmpl, order);
            trie.insert(clause);
        }
        trie.initializeForQueries();
    }

    inline bool isStorable(Clause& clause) const
    { return trie.empty() || trie.contains(clause); }

    inline bool isNonRedundant(Clause& clause) const
    { return trie.empty() || trie.isPrefix(clause); }

private:
    Trie<size_t, Clause> trie;

    static Clause createClause(const IntegerVector& tmpl, const vector<size_t>& order)
    {
        Clause res(tmpl.size());
        for (R_xlen_t j = 0; j < tmpl.size(); j++) {
            res[j] = tmpl[j];
        }
        res.sortAndUnique(order);

        return res;
    }
};
