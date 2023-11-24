#pragma once

// [[Rcpp::plugins(cpp20)]]

#include <cmath>
#include <Rcpp.h>

using namespace Rcpp;
using namespace std;


#define EQUAL(a, b) (fabs((a) - (b)) < 1e-6)


enum TNorm {
    GOEDEL,
    GOGUEN,
    LUKASIEWICZ
};
