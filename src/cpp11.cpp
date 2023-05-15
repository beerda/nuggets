// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"
#include <R_ext/Visibility.h>

// dig.cpp
list dig_(doubles_matrix<> data, list config);
extern "C" SEXP _nuggets_dig_(SEXP data, SEXP config) {
  BEGIN_CPP11
    return cpp11::as_sexp(dig_(cpp11::as_cpp<cpp11::decay_t<doubles_matrix<>>>(data), cpp11::as_cpp<cpp11::decay_t<list>>(config)));
  END_CPP11
}

extern "C" {
/* .Call calls */
extern SEXP run_testthat_tests(void *);

static const R_CallMethodDef CallEntries[] = {
    {"_nuggets_dig_",      (DL_FUNC) &_nuggets_dig_,      2},
    {"run_testthat_tests", (DL_FUNC) &run_testthat_tests, 1},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_nuggets(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
