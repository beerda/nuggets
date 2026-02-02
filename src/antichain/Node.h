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

#include <string>
#include <sstream>
#include <vector>
#include <unordered_set>
#include "../common.h"
#include "Condition.h"


class Node {
public:
    Node()
        : predicate(-1), depth(0)
    { }

    Node(const int predicate, const int depth, const unordered_set<int>& prefix)
        : predicate(predicate), depth(depth), prefix(prefix)
    { }

    inline int getPredicate() const {
        return predicate;
    }

    inline int getDepth() const {
        return depth;
    }

    inline const unordered_set<int>& getPrefix() const {
        return prefix;
    }

    inline const vector<Node>& getChildren() const {
        return children;
    }

    inline vector<Node>& getMutableChildren() {
        return children;
    }

    inline bool isRoot() const {
        return depth == 0;
    }

    inline bool isLeaf() const {
        return children.empty();
    }

    inline int getNumDescendants() const {
        int numDescendants = 0;
        for (const Node& child : children) {
            numDescendants += child.getNumDescendants() + 1;
        }
        return numDescendants;
    }

    void insertAsChildren(const Condition& condition) {
        unordered_set<int> toAdd = condition.getPredicates();
        if (!isRoot()) {
            toAdd.erase(predicate);
        }
        for (int p : prefix) {
            toAdd.erase(p);
        }

        insertAsChildren(toAdd);
    }

    void insertAsChildren(const unordered_set<int>& predicates) {
        if (!predicates.empty()) {
            unordered_set<int> newPrefix = prefix;
            if (!isRoot()) {
                newPrefix.insert(predicate);
            }

            int newPredicate = *predicates.begin();
            unordered_set<int> yetToAdd = predicates;
            yetToAdd.erase(newPredicate);

            Node child(newPredicate, depth + 1, newPrefix);
            children.push_back(child);

            children.back().insertAsChildren(yetToAdd);
        }
    }

    inline string visualize() const
    {
        stringstream ss;

        if (!isRoot()) {
            for (int i = 0; i < depth; ++i) {
                ss << "  ";
            }
            ss << predicate << endl;
        }

        for (const Node& child : children) {
            ss << child.visualize();
        }

        return ss.str();
    }

    inline bool operator==(const Node& other) const {
        return predicate == other.predicate && children == other.children;
    }

private:
    int predicate;
    int depth;
    unordered_set<int> prefix;
    vector<Node> children;
};
