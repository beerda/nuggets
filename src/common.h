#pragma once

// [[Rcpp::plugins(cpp20)]]

#include <cmath>
#include <Rcpp.h>
#include "xsimd/xsimd.hpp"

using namespace Rcpp;
using namespace std;
namespace xs = xsimd;


#define EQUAL(a, b) (fabs((a) - (b)) < 1e-6)


enum TNorm {
    GOEDEL,
    GOGUEN,
    LUKASIEWICZ
};
