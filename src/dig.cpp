#include "common.h"
#include "dig/BitChain.h"
#include "dig/FloatChain.h"
#include "dig/CallbackCaller.h"
#include "dig/Config.h"
#include "dig/ChainCollection.h"
#include "dig/Digger.h"


template <typename CHAIN, typename STORAGE>
List runDigger(List data,
               LogicalVector isCondition,
               LogicalVector isFocus,
               Function callback,
               const Config& config)
{
        ChainCollection<CHAIN> chains(data, isCondition, isFocus);
        STORAGE caller(config, callback);
        Digger<CHAIN, STORAGE> digger(config, caller);
        digger.run(chains);

        return caller.getResult();
}


// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_(List data,
          CharacterVector namesVector,
          LogicalVector isCondition,
          LogicalVector isFocus,
          Function callback,
          List confList)
{
    LogStartEnd l("dig_");

    bool allLogical = true;
    for (R_xlen_t i = 0; i < data.size(); ++i) {
        if (!Rf_isLogical(data[i])) {
            allLogical = false;
            break;
        }
    }

    Config config(confList, namesVector);
    List result;

    if (allLogical) {
        using CHAIN = BitChain;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::GOEDEL) {
        using CHAIN = FloatChain<TNorm::GOEDEL>;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        using CHAIN = FloatChain<TNorm::GOGUEN>;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        using CHAIN = FloatChain<TNorm::LUKASIEWICZ>;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }

    return result;
}
