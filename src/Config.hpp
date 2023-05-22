#pragma once

#include "common.hpp"


class Config {
public:
    Config(list configuration)
    {
        parseArguments(configuration["arguments"]);
    }

    bool hasConditionArgument() const
    { return conditionArgument; }

private:
    bool conditionArgument = false;

    void parseArguments(strings args)
    {
        for (string s : args) {
            if (s == "condition")
                conditionArgument = true;
        }
    }
};
