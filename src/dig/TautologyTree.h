#pragma once

#include <vector>
#include <unordered_map>

#include "../common.h"


class TautologyTree {
public:
    /**
     * Represents a node in the tautology tree.
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

        void storeConsequentsTo(vector<int>& vec) const
        { vec.insert(vec.end(), consequents.begin(), consequents.end()); }

        string toString(int padding) const
        {
            string res;
            string pad;
            for (int i = 0; i < padding; i++) {
                pad += " ";
            }

            res += pad + "consequents: ";
            for (int c : consequents) {
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
        vector<int> consequents;
    };


    /**
     * Constructs a new tautology tree with allowed predicates in antecedents.
     *
     * @param antecedents The vector of antecedent predicates in the order they will be
     *     enumerated by the condition generating algorithm.
     */
    TautologyTree(const vector<int>& antecedents, const vector<int>& consequents)
        : root(antecedents.size()),
          availableConsequents(consequents)
    {
        if (!antecedents.empty()) {
            predicateToIndex.resize(*max_element(antecedents.begin(), antecedents.end()) + 1);
            fill(predicateToIndex.begin(), predicateToIndex.end(), -1);
            for (size_t i = 0; i < antecedents.size(); ++i) {
                predicateToIndex[antecedents[i]] = i;
            }
        }
    }

    /**
     * Adds a tautology to the tree. The antecedent may be unsorted.
     *
     * @param antecedent The antecedent predicates. (May be unsorted.)
     * @param consequent The consequent predicate.
     */
    void addTautology(const vector<int>& antecedent, const int consequent)
    {
        if (isTautologyValid(antecedent, consequent)) {
            vector<int> sortedAntecedent(antecedent);
            sortAntecedent(sortedAntecedent);
            put(&root, sortedAntecedent.rbegin(), sortedAntecedent.rend(), consequent);
        }
    }

    void addTautologies(List tautologies)
    {
        for (R_xlen_t i = 0; i < tautologies.size(); i++) {
            IntegerVector tautology = tautologies[i];
            vector<int> antecedent(tautology.size() - 1);
            for (R_xlen_t j = 0; j < tautology.size() - 1; j++) {
                antecedent[j] = tautology[j];
            }
            int consequent = tautology[tautology.size() - 1];
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

    /**
     * Deduces consequents for the antecedent given by the prefix and current predicate.
     * The prefix is expected to be sorted in the reverse order to the order of antecedents.
     * (I.e. in the order as generated by the condition generating algorithm.)
     *
     * @param prefix The prefix part of the antecedent, sorted in the reverse order.
     * @param predicate The current predicate.
     * @return The vector of consequents.
     */
    vector<int> deduceConsequentsByRevSorted(const vector<int>& prefix, int predicate) const
    {
        //cout << "\n" << toString();
        //cout << "deducing: prefix ";
        //for (int p : prefix) {
            //cout << p << " ";
        //}
        //cout << " predicate " << predicate << endl;

        vector<int> result;
        root.storeConsequentsTo(result);
        const Node* node = root.children[predicateToIndex[predicate]];
        if (node != nullptr) {
            get(node, prefix.begin(), prefix.end(), result);
        }

        return result;
    }

    string toString() const
    {
        string res;
        res += "predicateToIndex: ";
        for (size_t i = 0; i < predicateToIndex.size(); ++i) {
            res += to_string(i) + "=" + to_string(predicateToIndex[i]) + " ";
        }
        res += "\n";
        res += "root:\n";
        res += root.toString(2);

        return res;
    }

private:
    Node root;
    vector<int> predicateToIndex; // mapping of predicate -> index
    vector<int> availableConsequents;

    bool isTautologyValid(const vector<int>& antecedent, const int consequent) const
    {
        for (int a : antecedent) {
            if (a >= predicateToIndex.size() || predicateToIndex[a] == -1) {
                return false;
            }
        }

        bool foundConseq = false;
        for (int c : availableConsequents) {
            if (c == consequent) {
                foundConseq = true;
                break;
            }
        }
        if (!foundConseq) {
            return false;
        }

        return true;
    }

    void sortAntecedent(vector<int>& antecedent)
    {
        sort(antecedent.begin(), antecedent.end(), [&](int a, int b) {
            return predicateToIndex[a] < predicateToIndex[b];
        });
    }

    template <typename Iterator>
    void put(Node* node, Iterator b, Iterator e, const int consequent)
    {
        if (b == e) {
            node->consequents.push_back(consequent);
        }
        else {
            int predicate = *b;
            size_t index = predicateToIndex[predicate];
            if (node->children[index] == nullptr) {
                node->children[index] = new Node(index);
            }
            put(node->children[index], b + 1, e, consequent);
        }
    }

    template <typename Iterator>
    void get(const Node* node, Iterator b, Iterator e, vector<int>& result) const
    {
        node->storeConsequentsTo(result);
        while (b != e) {
            int predicate = *b;
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
