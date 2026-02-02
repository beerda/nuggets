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


#include <Rcpp.h>
#include <xsimd/xsimd.hpp>


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

inline double internalGoedelTnorm(int size, const std::function<double(int)>& getValue) {
#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
    using batch_type = xsimd::batch<double>;
    constexpr size_t simd_size = batch_type::size;
    
    if (size == 0) return 1.0;
    
    // Check for NA/NaN and validity in first pass
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        }
    }
    
    batch_type min_vec = batch_type(1.0);
    const int simd_step = static_cast<int>(simd_size);
    int i = 0;
    
    // Process in SIMD batches
    for (; i + simd_step <= size; i += simd_step) {
        alignas(batch_type::arch_type::alignment()) double values[simd_size];
        for (size_t j = 0; j < simd_size; ++j) {
            values[j] = getValue(i + j);
        }
        batch_type vals = batch_type::load_aligned(values);
        min_vec = xsimd::min(min_vec, vals);
    }
    
    // Horizontal minimum
    double res = xsimd::reduce_min(min_vec);
    
    // Process remaining elements (already validated in first pass)
    for (; i < size; ++i) {
        double v = getValue(i);
        if (v < res) {
            res = v;
        }
    }
    
    return res;
#else
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
#endif
}

inline double internalLukasTnorm(int size, const std::function<double(int)>& getValue) {
#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
    using batch_type = xsimd::batch<double>;
    constexpr size_t simd_size = batch_type::size;
    
    // Check for NA/NaN and validity in first pass
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        }
    }
    
    batch_type sum_vec = batch_type(0.0);
    const int simd_step = static_cast<int>(simd_size);
    int i = 0;
    
    // Process in SIMD batches
    for (; i + simd_step <= size; i += simd_step) {
        alignas(batch_type::arch_type::alignment()) double values[simd_size];
        for (size_t j = 0; j < simd_size; ++j) {
            values[j] = getValue(i + j);
        }
        batch_type vals = batch_type::load_aligned(values);
        sum_vec += vals;
    }
    
    // Horizontal sum
    double res = xsimd::reduce_add(sum_vec);
    
    // Process remaining elements (already validated in first pass)
    for (; i < size; ++i) {
        res += getValue(i);
    }
    
    // Apply Lukasiewicz formula: 1 + sum - size
    res = 1.0 + res - size;
    return res > 0 ? res : 0;
#else
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
#endif
}

inline double internalGoguenTnorm(int size, const std::function<double(int)>& getValue) {
#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
    using batch_type = xsimd::batch<double>;
    constexpr size_t simd_size = batch_type::size;
    
    if (size == 0) return 1.0;
    
    // Check for NA/NaN and validity in first pass
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        }
    }
    
    batch_type prod_vec = batch_type(1.0);
    const int simd_step = static_cast<int>(simd_size);
    int i = 0;
    
    // Process in SIMD batches
    for (; i + simd_step <= size; i += simd_step) {
        alignas(batch_type::arch_type::alignment()) double values[simd_size];
        for (size_t j = 0; j < simd_size; ++j) {
            values[j] = getValue(i + j);
        }
        batch_type vals = batch_type::load_aligned(values);
        prod_vec *= vals;
    }
    
    // Horizontal product
    double res = xsimd::reduce_mul(prod_vec);
    
    // Process remaining elements (already validated in first pass)
    for (; i < size; ++i) {
        res *= getValue(i);
    }
    
    return res;
#else
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
#endif
}

inline double internalGoedelTconorm(int size, const std::function<double(int)>& getValue) {
#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
    using batch_type = xsimd::batch<double>;
    constexpr size_t simd_size = batch_type::size;
    
    if (size == 0) return 0.0;
    
    // Check for NA/NaN and validity in first pass
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        }
    }
    
    batch_type max_vec = batch_type(0.0);
    const int simd_step = static_cast<int>(simd_size);
    int i = 0;
    
    // Process in SIMD batches
    for (; i + simd_step <= size; i += simd_step) {
        alignas(batch_type::arch_type::alignment()) double values[simd_size];
        for (size_t j = 0; j < simd_size; ++j) {
            values[j] = getValue(i + j);
        }
        batch_type vals = batch_type::load_aligned(values);
        max_vec = xsimd::max(max_vec, vals);
    }
    
    // Horizontal maximum
    double res = xsimd::reduce_max(max_vec);
    
    // Process remaining elements (already validated in first pass)
    for (; i < size; ++i) {
        double v = getValue(i);
        if (v > res) {
            res = v;
        }
    }
    
    return res;
#else
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
#endif
}

inline double internalLukasTconorm(int size, const std::function<double(int)>& getValue) {
#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
    using batch_type = xsimd::batch<double>;
    constexpr size_t simd_size = batch_type::size;
    
    // Check for NA/NaN and validity in first pass
    for (int i = 0; i < size; ++i) {
        double v = getValue(i);
        testInvalids(v);
        if (NumericVector::is_na(v)) {
            return NA_REAL;
        }
    }
    
    batch_type sum_vec = batch_type(0.0);
    const int simd_step = static_cast<int>(simd_size);
    int i = 0;
    
    // Process in SIMD batches
    for (; i + simd_step <= size; i += simd_step) {
        alignas(batch_type::arch_type::alignment()) double values[simd_size];
        for (size_t j = 0; j < simd_size; ++j) {
            values[j] = getValue(i + j);
        }
        batch_type vals = batch_type::load_aligned(values);
        sum_vec += vals;
    }
    
    // Horizontal sum
    double res = xsimd::reduce_add(sum_vec);
    
    // Process remaining elements (already validated in first pass)
    for (; i < size; ++i) {
        res += getValue(i);
    }
    
    return res >= 1 ? 1 : res;
#else
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
#endif
}

inline double internalGoguenTconorm(int size, const std::function<double(int)>& getValue) {
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
double goedel_tnorm(const NumericVector& vals)
{ TNORM_IMPL(internalGoedelTnorm); }

// [[Rcpp::export(name=".pgoedel.tnorm")]]
NumericVector pgoedel_tnorm(const List& list)
{ PTNORM_IMPL(internalGoedelTnorm); }

// [[Rcpp::export(name=".lukas.tnorm")]]
double lukas_tnorm(const NumericVector& vals)
{ TNORM_IMPL(internalLukasTnorm); }

// [[Rcpp::export(name=".plukas.tnorm")]]
NumericVector plukas_tnorm(const List& list)
{ PTNORM_IMPL(internalLukasTnorm); }

// [[Rcpp::export(name=".goguen.tnorm")]]
double goguen_tnorm(const NumericVector& vals)
{ TNORM_IMPL(internalGoguenTnorm); }

// [[Rcpp::export(name=".pgoguen.tnorm")]]
NumericVector pgoguen_tnorm(const List& list)
{ PTNORM_IMPL(internalGoguenTnorm); }

// [[Rcpp::export(name=".goedel.tconorm")]]
double goedel_tconorm(const NumericVector& vals)
{ TNORM_IMPL(internalGoedelTconorm); }

// [[Rcpp::export(name=".pgoedel.tconorm")]]
NumericVector pgoedel_tconorm(const List& list)
{ PTNORM_IMPL(internalGoedelTconorm); }

// [[Rcpp::export(name=".lukas.tconorm")]]
double lukas_tconorm(const NumericVector& vals)
{ TNORM_IMPL(internalLukasTconorm); }

// [[Rcpp::export(name=".plukas.tconorm")]]
NumericVector plukas_tconorm(const List& list)
{ PTNORM_IMPL(internalLukasTconorm); }

// [[Rcpp::export(name=".goguen.tconorm")]]
double goguen_tconorm(const NumericVector& vals)
{ TNORM_IMPL(internalGoguenTconorm); }

// [[Rcpp::export(name=".pgoguen.tconorm")]]
NumericVector pgoguen_tconorm(const List& list)
{ PTNORM_IMPL(internalGoguenTconorm); }

// [[Rcpp::export(name=".goedel.residuum")]]
NumericVector goedel_residuum(const NumericVector& x, const NumericVector& y)
{
    int n = 0;
    if (x.size() > 0 && y.size() > 0) {
        n = x.size() > y.size() ? x.size() : y.size();
    }
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
NumericVector lukas_residuum(const NumericVector& x, const NumericVector& y)
{
    int n = 0;
    if (x.size() > 0 && y.size() > 0) {
        n = x.size() > y.size() ? x.size() : y.size();
    }
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
NumericVector goguen_residuum(const NumericVector& x, const NumericVector& y)
{
    int n = 0;
    if (x.size() > 0 && y.size() > 0) {
        n = x.size() > y.size() ? x.size() : y.size();
    }
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
NumericVector invol_neg(const NumericVector& x)
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
NumericVector strict_neg(const NumericVector& x)
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
