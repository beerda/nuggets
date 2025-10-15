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
    std::string current;
    for (char c : s) {
        if (c == ',') {
            std::string trimmed = trim(current);
            if (!trimmed.empty())
                parts.push_back(trimmed);

            current.clear();
        } else {
            current.push_back(c);
        }
    }

    std::string trimmed = trim(current);
    if (!trimmed.empty())
        parts.push_back(trimmed);

    return parts;
}


// [[Rcpp::export(name=".parse_condition")]]
List parse_condition(CharacterVector x) {
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
