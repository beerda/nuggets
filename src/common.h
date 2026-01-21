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

// [[Rcpp::plugins(cpp20)]]
// [[Rcpp::depends(RcppThread)]]

#include <cmath>
#include <chrono>
#include <Rcpp.h>

using namespace Rcpp;
using namespace std;


#ifndef DEBUG
//#    define DEBUG 1
#endif

#ifdef DEBUG
#    define IF_DEBUG(x) x
#else
#    define IF_DEBUG(x)
#endif


#define EQUAL(a, b) (fabs((a) - (b)) < 1e-6)
#define EQUAL100(a, b) (fabs((a) - (b)) < 0.019)
#define EQUAL1(a, b) (fabs((a) - (b)) < 1)

// fast ceiling of positive numbers
// see: http://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
#define UNSIGNED_CEILING(a, b)  (((a) + (b) - 1) / (b))

enum TNorm {
    GOEDEL,
    GOGUEN,
    LUKASIEWICZ
};

enum ArgumentType {
    ARG_LOGICAL,
    ARG_INTEGER,
    ARG_NUMERIC
};

/**
 * The type of the predicate represented by this chain, i.e.,
 * where the predicate may appear (in condition (antecedent),
 * in focus (consequent), or in both positions).
 */
enum PredicateType {
    CONDITION = 1,
    BOTH = 2, // this is because of sorting order: CONDITION, BOTH, FOCUS
    FOCUS = 3
};


//*
class LogStartEnd {
public:
    LogStartEnd(const std::string &what)
    { }
};
/*/
class LogStartEnd {
    std::string what;
    std::chrono::steady_clock::time_point start;
    inline static size_t indent = 0;

    void indentation()
    {
        for (size_t i = 0; i < indent; ++i) {
            Rcout << "  ";
        }
    }

public:
    LogStartEnd(const std::string &what)
        : what(what),
          start(std::chrono::steady_clock::now())
    {
        indentation();
        Rcout << "BEGIN " << what << std::endl;
        indent++;
    }

    ~LogStartEnd()
    {
        std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
        indent--;
        indentation();
        Rcout << "END " << what << ": "  <<
            (std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() / 1000.0) <<
            "[ms]" << std::endl;
    }
};
// */
