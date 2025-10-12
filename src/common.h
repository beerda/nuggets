#pragma once

// [[Rcpp::plugins(cpp20)]]
// [[Rcpp::depends(BH)]]
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
#define UNSIGNED_CEILING(a, b)  ((a) + (b) - 1) / (b)

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




// /*
class LogStartEnd {
public:
    LogStartEnd(const std::string &what)
    { }
};
/*/
class LogStartEnd {
    std::string what;
    std::chrono::steady_clock::time_point start;

public:
    LogStartEnd(const std::string &what)
        : what(what)
    {
        start = std::chrono::steady_clock::now();
        Rcout << "BEGIN " << what << std::endl;
    }

    ~LogStartEnd()
    {
        std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
        Rcout << "END " << what << ": "  <<
            (std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() / 1000.0) <<
            "[ms]" << std::endl;
    }
};
// */
