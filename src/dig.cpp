#include "dig/Executor.h"
#include "dig/BitChain.h"
#include "dig/SimdVectorNumChain.h"

#define BCH BitChain
//#define BCH SparseBitChain

//define NCH VectorNumChain
#define NCH SimdVectorNumChain
//define NCH BitsetNumChain

// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_(List logData,
          List numData,
          List logFoci,
          List numFoci,
          List confList)
{
    List result;
    Config config(confList);

    if (config.getTNorm() == TNorm::GOEDEL) {
        Executor<BCH, NCH<GOEDEL>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        Executor<BCH, NCH<GOGUEN>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        Executor<BCH, NCH<LUKASIEWICZ>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci);
    }
    else
        throw new runtime_error("Unknown t-norm in C++ dig_()");

    return result;
}
