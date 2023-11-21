// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// dig_
List dig_(List logicals_data, List doubles_data, List logicals_foci, List doubles_foci, List configuration_list, Function fun);
RcppExport SEXP _nuggets_dig_(SEXP logicals_dataSEXP, SEXP doubles_dataSEXP, SEXP logicals_fociSEXP, SEXP doubles_fociSEXP, SEXP configuration_listSEXP, SEXP funSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type logicals_data(logicals_dataSEXP);
    Rcpp::traits::input_parameter< List >::type doubles_data(doubles_dataSEXP);
    Rcpp::traits::input_parameter< List >::type logicals_foci(logicals_fociSEXP);
    Rcpp::traits::input_parameter< List >::type doubles_foci(doubles_fociSEXP);
    Rcpp::traits::input_parameter< List >::type configuration_list(configuration_listSEXP);
    Rcpp::traits::input_parameter< Function >::type fun(funSEXP);
    rcpp_result_gen = Rcpp::wrap(dig_(logicals_data, doubles_data, logicals_foci, doubles_foci, configuration_list, fun));
    return rcpp_result_gen;
END_RCPP
}
// which_antichain_
IntegerVector which_antichain_(List x, IntegerVector dist);
RcppExport SEXP _nuggets_which_antichain_(SEXP xSEXP, SEXP distSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type x(xSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type dist(distSEXP);
    rcpp_result_gen = Rcpp::wrap(which_antichain_(x, dist));
    return rcpp_result_gen;
END_RCPP
}

RcppExport SEXP run_testthat_tests(void *);

static const R_CallMethodDef CallEntries[] = {
    {"_nuggets_dig_", (DL_FUNC) &_nuggets_dig_, 6},
    {"_nuggets_which_antichain_", (DL_FUNC) &_nuggets_which_antichain_, 2},
    {"run_testthat_tests", (DL_FUNC) &run_testthat_tests, 1},
    {NULL, NULL, 0}
};

RcppExport void R_init_nuggets(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
