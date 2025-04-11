#include "common.h"
#include "dig/Config.h"


// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_(List chains,
          CharacterVector namesVector,
          LogicalVector isCondition,
          LogicalVector isFocus,
          Function callback,
          List confList)
{
    LogStartEnd l("dig_");
    Config config(confList);
    List result;

    return result;
}
