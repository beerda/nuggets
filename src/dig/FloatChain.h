#pragma once

#include "../common.h"
#include "../AlignedVector.h"
#include "BaseChain.h"


template <TNorm TNORM>
class FloatChain : public BaseChain {
public:
    FloatChain()
        : BaseChain()
    { }

    FloatChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size(), 0.0)
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            if (vec[i]) {
                data[i] = 1.0;
                this->sum++;
            }
        }
    }

    FloatChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            data[i] = vec[i];
            this->sum += vec[i];
        }
    }

    FloatChain(const FloatChain& a, const FloatChain& b)
        : BaseChain(a, b),
          data(a.data.size())
    {
        IF_DEBUG(
            if (a.data.size() != b.data.size()) {
                throw std::invalid_argument("FloatChain: incompatible sizes");
            }
        )

        for (size_t i = 0; i < a.data.size(); ++i) {
            if constexpr (TNORM == TNorm::GOEDEL) {
                data[i] = std::min(a.data[i], b.data[i]);
            } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                data[i] = std::max(0.0, a.data[i] + b.data[i] - 1.0);
            } else if constexpr (TNORM == TNorm::GOGUEN) {
                data[i] = a.data[i] * b.data[i];
            } else {
                static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                              "Unsupported TNorm type");
            }
            sum += data[i];
        }
    }

    // Disable copy
    FloatChain(const FloatChain& other) = delete;
    FloatChain& operator=(const FloatChain& other) = delete;

    // Allow move
    FloatChain(FloatChain&& other) = default;
    FloatChain& operator=(FloatChain&& other) = default;

    bool operator==(const FloatChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    bool operator!=(const FloatChain& other) const
    { return !(*this == other); }

    float operator[](size_t index) const
    { return data[index]; }

    float at(size_t index) const
    { return data.at(index); }

    size_t size() const
    { return data.size(); }

    bool empty() const
    { return data.empty(); }

    string toString() const
    {
        stringstream res;
        res << "[n=" << data.size() << "]";
        for (size_t i = 0; i < data.size(); ++i) {
            res << data[i];
        }

        return res.str();
    }

private:
    AlignedVector<float> data;
};
