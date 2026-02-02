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


#include "common.h"
#include "timer.h"
#include "dig/BitChain.h"
#include "dig/FloatChain.h"
#include "dig/CallbackCaller.h"
#include "dig/AssocStorage.h"
#include "dig/Config.h"
#include "dig/ChainCollection.h"
#include "dig/Digger.h"


#define BIT_CHAIN BitChain

#ifdef __arm64__
    // MacOS
    #define GOGUEN_CHAIN FloatChain<TNorm::GOGUEN>
    #define GOEDEL_CHAIN FloatChain<TNorm::GOEDEL>
    #define LUKASIEWICZ_CHAIN FloatChain<TNorm::LUKASIEWICZ>
#else
    // Linux or Windows
    #include "dig/FubitChain.h"
    #define GOGUEN_CHAIN FloatChain<TNorm::GOGUEN>
    #define GOEDEL_CHAIN FubitChain<TNorm::GOEDEL, 8>
    #define LUKASIEWICZ_CHAIN FubitChain<TNorm::LUKASIEWICZ, 8>
#endif

//include "dig/SimdChain.h"
//define GOEDEL_CHAIN SimdChain<TNorm::GOEDEL>
//define GOGUEN_CHAIN SimdChain<TNorm::GOGUEN>
//define LUKASIEWICZ_CHAIN SimdChain<TNorm::LUKASIEWICZ>

//define GOGUEN_CHAIN FubitChain<TNorm::GOGUEN, 8>


bool dataAreAllLogical(const List& data)
{
    bool allLogical = true;
    for (R_xlen_t i = 0; i < data.size(); ++i) {
        if (!Rf_isLogical(data[i])) {
            allLogical = false;
            break;
        }
    }

    return allLogical;
}


template <typename CHAIN>
List runDig(const List& data,
            const LogicalVector& isCondition,
            const LogicalVector& isFocus,
            const Function& callback,
            const Config& config)
{
    using STORAGE = CallbackCaller<CHAIN>;

    START_TIMER(t, "runDig - initialization");
    STORAGE storage(config, callback);
    Digger<CHAIN, STORAGE> digger(config, data, isCondition, isFocus, storage);
    STOP_TIMER(t);

    BLOCK_TIMER(bt, "runDig - run");
    digger.run();

    return storage.getResult();
}


// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_(const List& data,
          const CharacterVector& namesVector,
          const LogicalVector& isCondition,
          const LogicalVector& isFocus,
          const Function& callback,
          const List& confList)
{
    START_TIMER(bt, "dig_");

    bool allLogical = dataAreAllLogical(data);
    Config config(confList, namesVector);
    List result;

    if (allLogical) {
        result = runDig<BIT_CHAIN>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::GOEDEL) {
        result = runDig<GOEDEL_CHAIN>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        result = runDig<GOGUEN_CHAIN>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        result = runDig<LUKASIEWICZ_CHAIN>(data, isCondition, isFocus, callback, config);
    }

    STOP_TIMER(bt);
    CLEAR_INC_TIMERS();

    return result;
}


template <typename CHAIN>
List runDigAssoc(const List& data,
                 const LogicalVector& isCondition,
                 const LogicalVector& isFocus,
                 const Config& config)
{
    START_TIMER(t1, "runDigAssoc - initialization");
    using STORAGE = AssocStorage<CHAIN>;

    STORAGE storage(config);
    Digger<CHAIN, STORAGE> digger(config, data, isCondition, isFocus, storage);

    STOP_TIMER(t1);
    START_TIMER(t2, "runDigAssoc - run");
    digger.run();
    STOP_TIMER(t2);

    return storage.getResult();
}


// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_associations_(const List& data,
                       const CharacterVector& namesVector,
                       const LogicalVector& isCondition,
                       const LogicalVector& isFocus,
                       const List& confList)
{
    START_TIMER(bt, "dig_associations_");

    bool allLogical = dataAreAllLogical(data);
    Config config(confList, namesVector);
    List result;

    if (allLogical) {
        result = runDigAssoc<BIT_CHAIN>(data, isCondition, isFocus, config);
    }
    else if (config.getTNorm() == TNorm::GOEDEL) {
        result = runDigAssoc<GOEDEL_CHAIN>(data, isCondition, isFocus, config);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        result = runDigAssoc<GOGUEN_CHAIN>(data, isCondition, isFocus, config);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        result = runDigAssoc<LUKASIEWICZ_CHAIN>(data, isCondition, isFocus, config);
    }

    STOP_TIMER(bt);
    CLEAR_INC_TIMERS();

    return result;
}
