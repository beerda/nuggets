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

#include <vector>
#include <unordered_map>
#include <limits>

#include "../common.h"
#include "ChainCollection.h"


template <typename CHAIN>
class TautologyTree {
public:
    /**
     * Representation of a node in the tautology tree.
     */
    struct Node {
        Node(size_t childrenSize)
            : children(childrenSize, nullptr)
        { }

        ~Node()
        {
            for (Node* child : children) {
                delete child;
            }
        }

        size_t nChildren() const
        {
            size_t result = 0;
            for (Node* child : children) {
                if (child != nullptr)
                    result++;
            }

            return result;
        }

        void storeConsequentsTo(vector<size_t>& vec) const
        { vec.insert(vec.end(), consequents.begin(), consequents.end()); }

        string toString(size_t padding) const
        {
            string res;
            string pad;
            for (size_t i = 0; i < padding; i++) {
                pad += " ";
            }

            res += pad + "consequents: ";
            for (size_t c : consequents) {
                res += to_string(c) + " ";
            }
            res += "\n";

            for (size_t i = 0; i < children.size(); ++i) {
                res += pad + "child " + to_string(i) + ":";
                if (children[i] == nullptr) {
                    res += "null\n";
                } else {
                    res += "\n" + children[i]->toString(padding + 2);
                }
            }

            return res;
        }

        vector<Node*> children;
        vector<size_t> consequents;
    };


    constexpr static size_t NULL_PREDICATE = numeric_limits<size_t>::max();

    /**
     * Constructs a new tautology tree with allowed predicates in antecedents.
     *
     * @param antecedents The vector of antecedent predicates in the order they will be
     *     enumerated by the condition generating algorithm.
     */
    TautologyTree(const vector<size_t>& antecedents, const vector<size_t>& consequents)
        : root(antecedents.size()),
          predicateToIndex(0),
          availableConsequents(consequents)
    {
        if (!antecedents.empty()) {
            predicateToIndex.resize(*max_element(antecedents.begin(), antecedents.end()) + 1,
                                    NULL_PREDICATE);
            for (size_t i = 0; i < antecedents.size(); ++i) {
                predicateToIndex[antecedents[i]] = i;
            }
        }
    }

    TautologyTree(const ChainCollection<CHAIN>& collection)
        : root(collection.conditionCount()),
          predicateToIndex(),
          availableConsequents(collection.focusCount())
    {
        size_t n = 0;
        for (size_t i = 0; i < collection.conditionCount(); ++i) {
            size_t id = collection[i].getClause().back();
            n = max(n, id);
        }
        predicateToIndex.resize(n + 1, NULL_PREDICATE);
        for (size_t i = 0; i < collection.conditionCount(); ++i) {
            predicateToIndex[collection[i].getClause().back()] = i;
        }
        for (size_t i = 0; i < collection.focusCount(); ++i) {
            availableConsequents[i] = collection[i + collection.firstFocusIndex()].getClause().back();
        }
    }

    /**
     * Adds a tautology to the tree. The antecedent may be unsorted and gets sorted.
     *
     * @param antecedent The antecedent predicates. (May be unsorted and would be sorted.)
     * @param consequent The consequent predicate.
     */
    void addTautology(vector<size_t>& antecedent, const size_t consequent)
    {
        //cout << "adding tautology: ";
        //for (size_t a : antecedent) {
            //cout << a << " ";
        //}
        //cout << " -> " << consequent;

        if (isTautologyValid(antecedent, consequent)) {
            //cout << " (added)";
            sort(antecedent.begin(), antecedent.end(), [&](size_t a, size_t b) {
                return predicateToIndex[a] < predicateToIndex[b];
            });
            put(&root, antecedent.rbegin(), antecedent.rend(), consequent);
        }

        //cout << endl;
    }

    void addTautology(const vector<size_t>& antecedent, const size_t consequent)
    {
        vector<size_t> ante(antecedent);
        addTautology(ante, consequent);
    }

    void addTautologies(const List& tautologies)
    {
        for (R_xlen_t i = 0; i < tautologies.size(); i++) {
            IntegerVector tautology = tautologies[i];
            vector<size_t> antecedent(tautology.size() - 1);
            for (R_xlen_t j = 0; j < tautology.size() - 1; j++) {
                antecedent[j] = tautology[j];
            }
            size_t consequent = tautology[tautology.size() - 1];
            addTautology(antecedent, consequent);
        }
    }

    bool empty() const
    { return root.nChildren() == 0 && root.consequents.empty(); }

    /**
     * Returns the root node of the tree.
     */
    const Node* getRoot() const
    { return &root; }

    void updateDeduction(CHAIN& chain) const
    {
        auto& deduced = chain.getMutableDeduced();
        deduced.clear();
        
        const auto& clause = chain.getClause();
        if (clause.empty()) {
            root.storeConsequentsTo(deduced);
            return;
        }

        // Iterative traversal for better cache locality
        auto beg = clause.rbegin();
        auto end = clause.rend();
        
        const Node* node = root.children[predicateToIndex[*beg]];
        if (node != nullptr) {
            get(node, beg + 1, end, deduced);
        }
    }

    string toString() const
    {
        string res;
        res += "predicateToIndex: ";
        for (size_t i = 0; i < predicateToIndex.size(); ++i) {
            res += to_string(i) + "=" + to_string(predicateToIndex[i]) + " ";
        }
        res += "\navailableConsequents: ";
        for (size_t i = 0; i < availableConsequents.size(); ++i) {
            res += to_string(availableConsequents[i]) + " ";
        }
        res += "\nroot:\n";
        res += root.toString(2);

        return res;
    }

private:
    Node root;
    vector<size_t> predicateToIndex; // mapping of predicate -> index
    vector<size_t> availableConsequents;

    bool isTautologyValid(const vector<size_t>& antecedent, const size_t consequent) const
    {
        for (size_t a : antecedent) {
            if (a >= predicateToIndex.size() || predicateToIndex[a] == NULL_PREDICATE) {
                return false;
            }
        }

        bool foundConseq = false;
        for (size_t c : availableConsequents) {
            if (c == consequent) {
                foundConseq = true;
                break;
            }
        }

        return foundConseq;
    }

    template <typename Iterator>
    void put(Node* node, Iterator b, Iterator e, const size_t consequent)
    {
        if (b == e) {
            node->consequents.push_back(consequent);
        }
        else {
            size_t predicate = *b;
            size_t index = predicateToIndex[predicate];
            if (node->children[index] == nullptr) {
                node->children[index] = new Node(index);
            }
            put(node->children[index], b + 1, e, consequent);
        }
    }

    template <typename Iterator>
    void get(const Node* node, Iterator b, Iterator e, vector<size_t>& result) const
    {
        node->storeConsequentsTo(result);
        while (b != e) {
            size_t predicate = *b;
            size_t index = predicateToIndex[predicate];
            if (index < node->children.size()) {
                const Node* child = node->children[index];
                if (child != nullptr) {
                    get(child, b + 1, e, result);
                }
            }
            b++;
        }
    }
};
