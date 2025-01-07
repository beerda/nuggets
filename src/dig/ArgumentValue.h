#pragma once

#include "../common.h"


enum ArgumentType {
    ARG_LOGICAL,
    ARG_INTEGER,
    ARG_NUMERIC
};


class ArgumentValue {
public:
    ArgumentValue(string name, ArgumentType type)
        : argumentName(name), type(type)
    { }

    string getArgumentName() const
    { return argumentName; }

    ArgumentType getType() const
    { return type; }

    bool isNamed() const
    { return !names.empty(); }

    template <typename T>
    void push_back(T value)
    { values.push_back(Value(value)); }

    template <typename T>
    void push_back(T value, string name)
    {
        vector<string>::iterator it = names.begin();
        names.insert(it + values.size(), name);
        values.push_back(Value(value));
    }

    LogicalVector asLogicalVector() const
    {
        if (type != ARG_LOGICAL)
            throw runtime_error("Cannot export Argument to LogicalVector");

        LogicalVector result(values.size());

        if (isNamed()) {
            result.names() = CharacterVector(names.begin(), names.end());
        }
        for (size_t i = 0; i < values.size(); ++i) {
            result[i] = values[i].logical;
        }

        return result;
    }

    IntegerVector asIntegerVector() const
    {
        if (type != ARG_INTEGER)
            throw runtime_error("Cannot export Argument to IntegerVector");

        IntegerVector result(values.size());

        if (isNamed()) {
            result.names() = CharacterVector(names.begin(), names.end());
        }
        for (size_t i = 0; i < values.size(); ++i) {
            result[i] = values[i].integer;
        }

        return result;
    }

    NumericVector asNumericVector() const
    {
        if (type != ARG_NUMERIC)
            throw runtime_error("Cannot export Argument to NumericVector");

        NumericVector result(values.size());

        if (isNamed()) {
            result.names() = CharacterVector(names.begin(), names.end());
        }
        for (size_t i = 0; i < values.size(); ++i) {
            result[i] = values[i].numeric;
        }

        return result;
    }

    string toString() const
    {
        stringstream ss;
        ss << argumentName << "={";
        for (size_t i = 0; i < values.size(); ++i) {
            if (isNamed()) {
                ss << names[i] << "=";
            }
            if (type == ARG_LOGICAL) {
                ss << values[i].logical << ",";
            }
            else if (type == ARG_INTEGER) {
                ss << values[i].integer << ",";
            }
            else if (type == ARG_NUMERIC) {
                ss << values[i].numeric << ",";
            }
            else {
                throw runtime_error("Unknown ArgumentType in ArgumentValue::toString()");
            }
        }
        ss << "}";

        return ss.str();
    }

private:
    union Value {
        Value(bool v)
            : logical(v)
        { }

        Value(int v)
            : integer(v)
        { }

        Value(double v)
            : numeric(v)
        { }

        bool logical;
        int integer;
        double numeric;
    };

    string argumentName;
    ArgumentType type;
    vector<string> names;
    vector<Value> values;
};


typedef vector<ArgumentValue> ArgumentValues;
