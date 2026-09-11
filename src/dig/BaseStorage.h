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
#include "Config.h"


class BaseStorage {
public:
    BaseStorage(const Config& config)
        : config(config)
    { }

protected:
    /**
     * The configuration object.
     */
    const Config& config;

    /**
     * Formats the condition (antecedent) of a chain as a string representation.
     * The condition is represented as a set of predicate names enclosed in
     * curly braces. The condition to be formatted is specified by two parts:
     * the prefix clause and the atomic predicate. The predicate IDs are
     * counted from 1 to match R's indexing convention, with index 0 reserved for
     * the empty value (i.e., no predicate).
     */
    string formatCondition(const Clause& prefix, const size_t predicate) const
    {
        if (prefix.empty() && predicate == 0) {
            return "{}";
        }

        // from now on, chain must have predicate
        IF_DEBUG(
            if (predicate == 0)
                throw invalid_argument("BaseStorage::formatCondition: chain has no predicate");
        )


        stringstream res;
        res << "{";

        if (prefix.size() == 0) {
            res << config.getChainName(predicate);
        }
        else {
            const string& name0 = config.getChainName(predicate);

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
