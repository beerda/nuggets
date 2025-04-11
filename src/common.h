#pragma once

// [[Rcpp::plugins(cpp20)]]
// [[Rcpp::depends(BH)]]
// [[Rcpp::depends(RcppThread)]]

#include <cmath>
#include <chrono>
#include <Rcpp.h>

using namespace Rcpp;
using namespace std;


// fast ceiling of positive numbers
// see: http://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
#define UNSIGNED_CEILING(a, b)  ((a) + (b) - 1) / (b)

#define EQUAL(a, b) (fabs((a) - (b)) < 1e-6)


enum TNorm {
    GOEDEL,
    GOGUEN,
    LUKASIEWICZ
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
