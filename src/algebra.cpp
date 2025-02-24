/*
 * File name: algebra.cpp
 * Date:      2016/01/29 10:49
 * Author:    Michal Burda
 */


#include <Rcpp.h>


using namespace Rcpp;


#define TNORM_IMPL(call) {                                     \
    if (vals.size() <= 0) {                                    \
        return NA_REAL;                                        \
    }                                                          \
    auto fun = [&vals](int i) { return vals[i]; };             \
    return call(vals.size(), fun);                             \
}                                                              \

#define PTNORM_IMPL(call) {                                    \
    if (list.size() <= 0) {                                    \
        return NumericVector(0);                               \
    }                                                          \
    int size = 0;                                              \
    for (int j = 0; j < list.size(); ++j) {                    \
        NumericVector vec = list[j];                           \
        if (vec.size() > size)                                 \
            size = vec.size();                                 \
    }                                                          \
    NumericVector result(size);                                \
    for (int j = 0; j < size; ++j) {                           \
        auto fun = [&list, &j](int i) { NumericVector vec = list[i]; return vec[j % vec.size()]; }; \
        result[j] = call(list.size(), fun);                    \
    }                                                          \
    return result;                                             \
}


inline void testInvalids(double x) {
    if ((x) < 0 || (x) > 1) {
        stop("argument out of range 0..1");
    }
}

inline double internalGoedelTnorm(int size, std::function<double(int)> getValue) {
    double res = 1.0;
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        } else if (v < res) {
            res = v;
        }
    }
    return res;
}

inline double internalLukasTnorm(int size, std::function<double(int)> getValue) {
    double res = 1.0;
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        } else {
            res += v;
        }
    }
    res -= size;
    return res > 0 ? res : 0;
}

inline double internalGoguenTnorm(int size, std::function<double(int)> getValue) {
    double res = 1.0;
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        } else {
            res = res * v;
        }
    }
    return res;
}

inline double internalGoedelTconorm(int size, std::function<double(int)> getValue) {
    double res = 0.0;
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        } else if (v > res) {
            res = v;
        }
    }
    return res;
}

inline double internalLukasTconorm(int size, std::function<double(int)> getValue) {
    double res = 0.0;
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        } else {
            res += v;
        }
    }
    return res >= 1 ? 1 : res;
}

inline double internalGoguenTconorm(int size, std::function<double(int)> getValue) {
    double res = 0.0;
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        } else {
            res = res + v - res * v;
        }
    }
    return res;
}

// [[Rcpp::export(name=".goedel.tnorm")]]
double goedel_tnorm(NumericVector vals)
{ TNORM_IMPL(internalGoedelTnorm); }

// [[Rcpp::export(name=".pgoedel.tnorm")]]
NumericVector pgoedel_tnorm(List list)
{ PTNORM_IMPL(internalGoedelTnorm); }

// [[Rcpp::export(name=".lukas.tnorm")]]
double lukas_tnorm(NumericVector vals)
{ TNORM_IMPL(internalLukasTnorm); }

// [[Rcpp::export(name=".plukas.tnorm")]]
NumericVector plukas_tnorm(List list)
{ PTNORM_IMPL(internalLukasTnorm); }

// [[Rcpp::export(name=".goguen.tnorm")]]
double goguen_tnorm(NumericVector vals)
{ TNORM_IMPL(internalGoguenTnorm); }

// [[Rcpp::export(name=".pgoguen.tnorm")]]
NumericVector pgoguen_tnorm(List list)
{ PTNORM_IMPL(internalGoguenTnorm); }

// [[Rcpp::export(name=".goedel.tconorm")]]
double goedel_tconorm(NumericVector vals)
{ TNORM_IMPL(internalGoedelTconorm); }

// [[Rcpp::export(name=".pgoedel.tconorm")]]
NumericVector pgoedel_tconorm(List list)
{ PTNORM_IMPL(internalGoedelTconorm); }

// [[Rcpp::export(name=".lukas.tconorm")]]
double lukas_tconorm(NumericVector vals)
{ TNORM_IMPL(internalLukasTconorm); }

// [[Rcpp::export(name=".plukas.tconorm")]]
NumericVector plukas_tconorm(List list)
{ PTNORM_IMPL(internalLukasTconorm); }

// [[Rcpp::export(name=".goguen.tconorm")]]
double goguen_tconorm(NumericVector vals)
{ TNORM_IMPL(internalGoguenTconorm); }

// [[Rcpp::export(name=".pgoguen.tconorm")]]
NumericVector pgoguen_tconorm(List list)
{ PTNORM_IMPL(internalGoguenTconorm); }

// [[Rcpp::export(name=".goedel.residuum")]]
NumericVector goedel_residuum(NumericVector x, NumericVector y)
{
    int n = x.size() > y.size() ? x.size() : y.size();
    NumericVector res(n);
    for (int i = 0; i < n; ++i) {
        int xi = i % x.size();
        int yi = i % y.size();
        testInvalids(x[xi]);
        testInvalids(y[yi]);
        if (NumericVector::is_na(x[xi]) || NumericVector::is_na(y[yi])) {
            res[i] = NA_REAL;
        } else if (x[xi] <= y[yi]) {
            res[i] = 1;
        } else {
            res[i] = y[yi];
        }
    }
    return res;
}

// [[Rcpp::export(name=".lukas.residuum")]]
NumericVector lukas_residuum(NumericVector x, NumericVector y)
{
    int n = x.size() > y.size() ? x.size() : y.size();
    NumericVector res(n);
    for (int i = 0; i < n; ++i) {
        int xi = i % x.size();
        int yi = i % y.size();
        testInvalids(x[xi]);
        testInvalids(y[yi]);
        if (NumericVector::is_na(x[xi]) || NumericVector::is_na(y[yi])) {
            res[i] = NA_REAL;
        } else if (x[xi] <= y[yi]) {
            res[i] = 1;
        } else {
            res[i] = 1-x[xi] + y[yi];
        }
    }
    return res;
}

// [[Rcpp::export(name=".goguen.residuum")]]
NumericVector goguen_residuum(NumericVector x, NumericVector y)
{
    int n = x.size() > y.size() ? x.size() : y.size();
    NumericVector res(n);
    for (int i = 0; i < n; ++i) {
        int xi = i % x.size();
        int yi = i % y.size();
        testInvalids(x[xi]);
        testInvalids(y[yi]);
        if (NumericVector::is_na(x[xi]) || NumericVector::is_na(y[yi])) {
            res[i] = NA_REAL;
        } else if (x[xi] <= y[yi]) {
            res[i] = 1;
        } else {
            res[i] = y[yi] / x[xi];
        }
    }
    return res;
}

// [[Rcpp::export(name=".invol.neg")]]
NumericVector invol_neg(NumericVector x)
{
    NumericVector res(x.size());
    for (int i = 0; i < x.size(); ++i) {
        testInvalids(x[i]);
        if (NumericVector::is_na(x[i])) {
            res[i] = NA_REAL;
        } else {
            res[i] = 1 - x[i];
        }
    }
    return res;
}

// [[Rcpp::export(name=".strict.neg")]]
NumericVector strict_neg(NumericVector x)
{
    NumericVector res(x.size());
    for (int i = 0; i < x.size(); ++i) {
        testInvalids(x[i]);
        if (NumericVector::is_na(x[i])) {
            res[i] = NA_REAL;
        } else if (x[i] == 0) {
            res[i] = 1;
        } else {
            res[i] = 0;
        }
    }
    return res;
}
