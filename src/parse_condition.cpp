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


using namespace Rcpp;


// helper: trim whitespace from both ends
std::string trim(const std::string &s) {
    size_t start = 0;
    while (start < s.size() && isspace(static_cast<unsigned char>(s[start])))
        start++;

    if (start == s.size())
        return "";

    size_t end = s.size() - 1;
    while (end > start && isspace(static_cast<unsigned char>(s[end])))
        end--;

    return s.substr(start, end - start + 1);
}


// helper: remove leading '{' and trailing '}' (with surrounding whitespace)
std::string remove_braces(const std::string &s) {
    std::string t = trim(s);

    if (!t.empty() && t.front() == '{')
        t.erase(t.begin());

    if (!t.empty() && t.back() == '}')
        t.pop_back();

    return trim(t);
}


// helper: split by comma (ignore surrounding spaces)
std::vector<std::string> split_commas(const std::string &s) {
    std::vector<std::string> parts;
    parts.reserve(4);  // Reserve space for typical case
    std::string current;
    for (char c : s) {
        if (c == ',') {
            std::string trimmed = trim(current);
            if (!trimmed.empty())
                parts.push_back(std::move(trimmed));

            current.clear();
        } else {
            current.push_back(c);
        }
    }

    std::string trimmed = trim(current);
    if (!trimmed.empty())
        parts.push_back(std::move(trimmed));

    return parts;
}


// [[Rcpp::export(name=".parse_condition")]]
List parse_condition(const CharacterVector& x) {
    int n = x.size();
    List out(n);

    for (int i = 0; i < n; i++) {
        if (CharacterVector::is_na(x[i])) {
            CharacterVector na_out(1, NA_STRING);
            out[i] = na_out;
            continue;
        }

        std::string s = as<std::string>(x[i]);
        std::string cleaned = remove_braces(s);
        std::vector<std::string> parts = split_commas(cleaned);
        out[i] = wrap(parts);
    }

    return out;
}
