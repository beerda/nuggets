#include "dig/Executor.h"
#include "dig/SparseBitChain.h"

#define BCH BitsetBitChain
//#define BCH SparseBitChain

//define NCH VectorNumChain
#define NCH SimdVectorNumChain
//define NCH BitsetNumChain

// [[Rcpp::export]]
List dig_(List logData,
          List numData,
          List logFoci,
          List numFoci,
          List confList,
          Function fun)
{
    List result;
    Config config(confList);

    if (config.getTNorm() == TNorm::GOEDEL) {
        Executor<BCH, NCH<GOEDEL>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        Executor<BCH, NCH<GOGUEN>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        Executor<BCH, NCH<LUKASIEWICZ>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else
        throw new runtime_error("Unknown t-norm in C++ dig_()");

    return result;
}
