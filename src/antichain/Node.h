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

    int getPredicate() const {
        return predicate;
    }

    int getDepth() const {
        return depth;
    }

    const unordered_set<int>& getPrefix() const {
        return prefix;
    }

    const vector<Node>& getChildren() const {
        return children;
    }

    vector<Node>& getMutableChildren() {
        return children;
    }

    bool isRoot() const {
        return depth == 0;
    }

    bool isLeaf() const {
        return children.empty();
    }

    int getNumDescendants() const {
        int numDescendants = 0;
        for (const Node& child : children) {
            numDescendants += child.getNumDescendants() + 1;
        }
        return numDescendants;
    }

    void insertAsChildren(const Condition& condition) {
        unordered_set<int> toAdd = condition.getPredicates();
        toAdd.erase(predicate);
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

    string visualize() const
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

    bool operator==(const Node& other) const {
        return predicate == other.predicate && children == other.children;
    }

private:
    int predicate;
    int depth;
    unordered_set<int> prefix;
    vector<Node> children;
};
