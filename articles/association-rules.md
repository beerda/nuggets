# Association Rules

## Introduction

**Association rules** are one of the most fundamental tools in data
mining. An association rule has the form:

> *antecedent* \\\Rightarrow\\ *consequent*

where the *antecedent* (left-hand side) is a conjunction of predicates
and the *consequent* (right-hand side) is a single predicate. The rule
expresses that whenever the antecedent conditions are satisfied, the
consequent tends to be satisfied as well.

For example:

> `middle_age & university_edu & IT_industry` \\\Rightarrow\\
> `high_income`

This rule states that middle-aged people with a university education
working in the IT industry tend to have a high income.

Association rules are evaluated using several quality measures:

- **Support**: the relative frequency of rows satisfying both the
  antecedent and the consequent. Higher support means the rule applies
  to more data.
- **Confidence**: the proportion of rows satisfying the antecedent that
  also satisfy the consequent. Higher confidence means the rule is more
  reliable.
- **Coverage**: the relative frequency of rows satisfying the
  antecedent.
- **Lift**: the ratio of the observed support to the expected support if
  the antecedent and consequent were independent. A lift greater than 1
  indicates a positive association.

The `nuggets` package supports searching for association rules in both
**crisp** (Boolean) and **fuzzy** data through the
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
function.

Before using the package, the required libraries must be loaded:

``` r

library(nuggets)
library(dplyr)    # for data manipulation
```

## Data Preparation

For this tutorial, we use the built-in `CO2` dataset, which contains
data from an experiment on the cold tolerance of the grass species
*Echinochloa crus-galli*. The dataset has 84 observations and includes
information about the plant’s origin (`Type`), treatment (`Treatment`),
ambient CO2 concentration (`conc`), and CO2 uptake rate (`uptake`).

``` r

head(CO2)
#>   Plant   Type  Treatment conc uptake
#> 1   Qn1 Quebec nonchilled   95   16.0
#> 2   Qn1 Quebec nonchilled  175   30.4
#> 3   Qn1 Quebec nonchilled  250   34.8
#> 4   Qn1 Quebec nonchilled  350   37.2
#> 5   Qn1 Quebec nonchilled  500   35.3
#> 6   Qn1 Quebec nonchilled  675   39.2
```

Before searching for association rules, data must be transformed into
predicates (logical or fuzzy columns). We use the
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
function for this purpose. For a detailed explanation of data
preparation techniques, see the
[`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md).

### Crisp Data Preparation

We prepare a crisp version of the dataset by transforming factors into
dummy variables and numeric columns into interval-based logical
predicates:

``` r

crisp_co2 <- CO2 |>
    select(-Plant) |>
    partition(Type, Treatment) |>
    partition(conc, .method = "crisp", .breaks = c(-Inf, 200, 500, Inf)) |>
    partition(uptake, .method = "crisp", .breaks = c(-Inf, 20, 35, Inf))

head(crisp_co2, n = 3)
#> # A tibble: 3 × 10
#>   `Type=Quebec` `Type=Mississippi` `Treatment=nonchilled` `Treatment=chilled`
#>   <lgl>         <lgl>              <lgl>                  <lgl>              
#> 1 TRUE          FALSE              TRUE                   FALSE              
#> 2 TRUE          FALSE              TRUE                   FALSE              
#> 3 TRUE          FALSE              TRUE                   FALSE              
#>   `conc=(-Inf;200]` `conc=(200;500]` `conc=(500;Inf]` `uptake=(-Inf;20]`
#>   <lgl>             <lgl>            <lgl>            <lgl>             
#> 1 TRUE              FALSE            FALSE            TRUE              
#> 2 TRUE              FALSE            FALSE            FALSE             
#> 3 FALSE             TRUE             FALSE            FALSE             
#>   `uptake=(20;35]` `uptake=(35;Inf]`
#>   <lgl>            <lgl>            
#> 1 FALSE            FALSE            
#> 2 TRUE             FALSE            
#> 3 TRUE             FALSE
```

### Fuzzy Data Preparation

For a fuzzy version, we transform numeric columns into fuzzy predicates
using triangular membership functions:

``` r

fuzzy_co2 <- CO2 |>
    select(-Plant) |>
    partition(Type, Treatment) |>
    partition(conc, .method = "triangle", .breaks = c(-Inf, 95, 500, 1000, Inf)) |>
    partition(uptake, .method = "triangle", .breaks = c(-Inf, 10, 25, 40, Inf))

head(fuzzy_co2, n = 3)
#> # A tibble: 3 × 10
#>   `Type=Quebec` `Type=Mississippi` `Treatment=nonchilled` `Treatment=chilled`
#>   <lgl>         <lgl>              <lgl>                  <lgl>              
#> 1 TRUE          FALSE              TRUE                   FALSE              
#> 2 TRUE          FALSE              TRUE                   FALSE              
#> 3 TRUE          FALSE              TRUE                   FALSE              
#>   `conc=(-Inf;95;500)` `conc=(95;500;1000)` `conc=(500;1000;Inf)`
#>                  <dbl>                <dbl>                 <dbl>
#> 1                1                    0                         0
#> 2                0.802                0.198                     0
#> 3                0.617                0.383                     0
#>   `uptake=(-Inf;10;25)` `uptake=(10;25;40)` `uptake=(25;40;Inf)`
#>                   <dbl>               <dbl>                <dbl>
#> 1                   0.6               0.4                  0    
#> 2                   0                 0.64                 0.36 
#> 3                   0                 0.347                0.653
```

## Basic Association Rule Search

The simplest use of
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
searches for all rules that meet given minimum support and confidence
thresholds.

``` r

rules <- dig_associations(crisp_co2,
                          min_support = 0.1,
                          min_confidence = 0.8)
head(rules)
#> # A tibble: 6 × 13
#>   antecedent                                             consequent            
#>   <chr>                                                  <chr>                 
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]}     
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}      
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}    
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}    
#> 5 {Type=Mississippi,conc=(200;500],uptake=(-Inf;20]}     {Treatment=chilled}   
#> 6 {Type=Mississippi,conc=(200;500],uptake=(20;35]}       {Treatment=nonchilled}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#> 4   0.107      1        0.107          0.357  2.8      9                 3     9
#> 5   0.107      1        0.107          0.5    2        9                 3     9
#> 6   0.107      1        0.107          0.5    2        9                 3     9
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
#> 4     0    21    54
#> 5     0    33    42
#> 6     0    33    42
```

The result is a tibble containing found rules with their quality
measures: `antecedent`, `consequent`, `support`, `confidence`,
`coverage`, `consequent_support`, `lift`, `length`, and the contingency
table columns (`pp`, `pn`, `np`, `nn`).

For instance, the first rule represents the following association rule:

> > Type=Quebec & conc=(500;Inf\] \\\Rightarrow\\ uptake=(35;Inf\]

## Specifying Antecedent and Consequent

In many applications, you want to constrain which predicates can appear
on each side of the rule. This is done with the `antecedent` and
`consequent` arguments, which accept
[tidyselect](https://tidyselect.r-lib.org/articles/syntax.html)
expressions.

For example, to find rules that predict the `uptake` rate from all other
variables:

``` r

rules_uptake <- dig_associations(crisp_co2,
                                 antecedent = !starts_with("uptake"),
                                 consequent = starts_with("uptake"),
                                 min_support = 0.1,
                                 min_confidence = 0.8)
head(rules_uptake, n = 3)
#> # A tibble: 3 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
```

## Using the Disjoint Argument

When data is prepared with
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
a single original variable is often expanded into multiple predicates
(e.g., `conc=(-Inf,200]` and `conc=(200,500]`). These predicates from
the same variable should not appear together in the same antecedent, as
their conjunction would be contradictory or redundant.

The `disjoint` argument prevents this. It accepts a character vector of
size equal to the number of columns in the input data such that each
unique value in the vector corresponds to a group of mutually exclusive
predicates.

By default,
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
uses
[`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md)
on the column names to create the disjoint vector automatically. This
works well for data prepared with
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md).

You can also provide a custom disjoint vector:

``` r

disj <- var_names(colnames(crisp_co2))
disj
#>  [1] "Type"      "Type"      "Treatment" "Treatment" "conc"      "conc"     
#>  [7] "conc"      "uptake"    "uptake"    "uptake"

rules <- dig_associations(crisp_co2,
                          disjoint = disj,
                          min_support = 0.1,
                          min_confidence = 0.8)
head(rules, n = 3)
#> # A tibble: 3 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
```

## Controlling Rule Length

The `min_length` and `max_length` arguments control the number of
predicates in the antecedent:

``` r

# Find only rules with exactly 2 predicates in the antecedent
rules <- dig_associations(crisp_co2,
                          min_length = 2,
                          max_length = 2,
                          min_support = 0.1,
                          min_confidence = 0.8)
head(rules, n = 3)
#> # A tibble: 3 × 13
#>   antecedent                           consequent             support confidence
#>   <chr>                                <chr>                    <dbl>      <dbl>
#> 1 {Type=Quebec,conc=(500;Inf]}         {uptake=(35;Inf]}        0.143      1    
#> 2 {Treatment=chilled,Type=Mississippi} {uptake=(-Inf;20]}       0.226      0.905
#> 3 {Type=Mississippi,uptake=(20;35]}    {Treatment=nonchilled}   0.179      0.882
#>   coverage conseq_support  lift count antecedent_length    pp    pn    np    nn
#>      <dbl>          <dbl> <dbl> <dbl>             <int> <dbl> <dbl> <dbl> <dbl>
#> 1    0.143          0.298  3.36    12                 2    12     0    13    59
#> 2    0.25           0.357  2.53    19                 2    19     2    11    52
#> 3    0.202          0.5    1.76    15                 2    15     2    27    40
```

Setting `min_length = 0` generates rules with an empty antecedent, which
effectively computes the support of each consequent alone.

## Limiting the Number of Results

For large datasets, the number of possible rules can be enormous. The
`max_results` argument limits the total number of rules generated:

``` r

rules <- dig_associations(crisp_co2,
                          min_support = 0.05,
                          min_confidence = 0.6,
                          max_results = 5)
nrow(rules)
#> [1] 5
```

## Fuzzy Association Rules

When the data contains fuzzy predicates (numeric columns with values in
\[0, 1\]),
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
computes fuzzy support using a **t-norm** for conjunction. The `t_norm`
argument specifies which t-norm to use:

- `"goguen"` (default): the product t-norm - multiplies membership
  degrees
- `"goedel"`: the minimum t-norm - takes the minimum of membership
  degrees
- `"lukas"`: the Łukasiewicz t-norm = max(0, a + b - 1)

``` r

# Fuzzy rules using the product t-norm (default)
fuzzy_rules <- dig_associations(fuzzy_co2,
                                antecedent = !starts_with("uptake"),
                                consequent = starts_with("uptake"),
                                min_support = 0.05,
                                min_confidence = 0.6,
                                t_norm = "goguen")
head(fuzzy_rules, n = 3)
#> # A tibble: 3 × 13
#>   antecedent                                            consequent          
#>   <chr>                                                 <chr>               
#> 1 {Type=Quebec}                                         {uptake=(25;40;Inf)}
#> 2 {Treatment=nonchilled,Type=Quebec}                    {uptake=(25;40;Inf)}
#> 3 {Treatment=nonchilled,Type=Quebec,conc=(95;500;1000)} {uptake=(25;40;Inf)}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1  0.320       0.639    0.5            0.380  1.68 26.8                  1 26.8 
#> 2  0.177       0.709    0.25           0.380  1.87 14.9                  2 14.9 
#> 3  0.0894      0.876    0.102          0.380  2.31  7.51                 3  7.51
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1 15.2   5.03  37.0
#> 2  6.11 17.0   46.0
#> 3  1.07 24.4   51.1
```

The choice of t-norm affects how strictly the conjunction is evaluated.
The Gödel t-norm is the least strict (produces higher support values),
while the Łukasiewicz t-norm is the most strict. Note also that handling
fuzzy data is generally much more slower and memory demanding than crisp
data, especially for large datasets.

## Computing Additional Interest Measures

The
[`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
function computes additional interestingness measures for association
rules beyond the basic support, confidence, and lift. It uses the
contingency table columns (`pp`, `pn`, `np`, `nn`) that are
automatically included in the output of
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

``` r

# Add selected interest measures
rules_enriched <- rules_uptake |>
    add_interest(measures = c("conviction", "leverage", "jaccard"))
rules_enriched |>
    select(antecedent, consequent, confidence, conviction, leverage, jaccard) |>
    head(n = 3)
#> # A tibble: 3 × 6
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#>   confidence conviction leverage jaccard
#>        <dbl>      <dbl>    <dbl>   <dbl>
#> 1      1         Inf      0.100    0.48 
#> 2      1         Inf      0.0702   0.310
#> 3      0.905       6.75   0.137    0.594
```

You can compute all available measures at once by omitting the
`measures` argument:

``` r

rules_all_measures <- rules_uptake |>
    add_interest()
colnames(rules_all_measures)
#>  [1] "antecedent"           "consequent"           "support"             
#>  [4] "confidence"           "coverage"             "conseq_support"      
#>  [7] "lift"                 "count"                "antecedent_length"   
#> [10] "pp"                   "pn"                   "np"                  
#> [13] "nn"                   "cosine"               "conviction"          
#> [16] "gini"                 "rule_power_factor"    "odds_ratio"          
#> [19] "relative_risk"        "phi"                  "leverage"            
#> [22] "collective_strength"  "importance"           "imbalance"           
#> [25] "jaccard"              "kappa"                "lambda"              
#> [28] "mutual_information"   "maxconfidence"        "j_measure"           
#> [31] "kulczynski"           "certainty"            "added_value"         
#> [34] "ralambondrainy"       "sebag"                "counterexample"      
#> [37] "confirmed_confidence" "casual_support"       "casual_confidence"   
#> [40] "least_contradiction"  "centered_confidence"  "varying_liaison"     
#> [43] "yule_q"               "yule_y"               "lerman"              
#> [46] "implication_index"    "doc"                  "fi"                  
#> [49] "dfi"                  "fe"                   "lci"                 
#> [52] "dlci"                 "lce"                  "uci"                 
#> [55] "duci"                 "uce"
```

See the documentation of
[`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
for a complete list of supported quality measures:

``` r

?add_interest
```

### Smoothing

Some interest measures may be undefined when contingency table counts
are zero (e.g., division by zero). The `smooth_counts` argument applies
Laplace smoothing to the counts before computing the measures:

``` r

rules_smoothed <- rules_uptake |>
    add_interest(measures = c("odds_ratio", "conviction"),
                 smooth_counts = 0.5)
rules_smoothed |>
    select(antecedent, consequent, confidence, odds_ratio, conviction) |>
    head(n = 3)
#> # A tibble: 3 × 5
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#>   confidence odds_ratio conviction
#>        <dbl>      <dbl>      <dbl>
#> 1      1          110.       18.1 
#> 2      1           51.4      13.0 
#> 3      0.905       35.6       5.63
```

### GUHA Quantifiers

[`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
also supports GUHA (General Unary Hypothesis Automaton) quantifiers,
including statistical tests based on the binomial distribution:

``` r

rules_guha <- rules_uptake |>
    add_interest(measures = c("dfi", "fe", "lci"),
                 p = 0.5)
rules_guha |>
    select(antecedent, consequent, confidence, dfi, fe, lci) |>
    head(n = 3)
#> # A tibble: 3 × 6
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#>   confidence   dfi    fe      lci
#>        <dbl> <dbl> <dbl>    <dbl>
#> 1      1     0.48  0.845 0.000244
#> 2      1     0.310 0.762 0.00195 
#> 3      0.905 0.594 0.845 0.000111
```

The `p` parameter represents the null-hypothesis probability used in the
binomial-test-based quantifiers (`lci`, `uci`, `dlci`, `duci`, `lce`,
`uce`).

## Excluding Redundant and Entailed Rules

In real-world datasets, some rules are trivially true or nearly so — for
example, rules that follow directly from the structure of the data
(e.g., `engine_type=electric => fuel_type=electricity`). Such
near-certain rules are called **tautologies**, and are also referred to
as **implications** (because they describe an `A => C` relationship that
almost always holds) or **axioms** (because they can be assumed and used
as starting assumptions for pruning). In classical logic, a *tautology*
is strictly always true; here the term is used loosely for rules whose
confidence is very high in the data. This distinction is a matter of
logical philosophy and does not affect how the functions work.

The `excluded` argument of
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
accepts a list of known **implications (axioms)**. Each axiom is a
character vector where all elements except the last form the antecedent
and the last element is the consequent:
`c(ant1, ant2, ..., antn, cons)`. The axioms are used to prune generated
rules via the **modus ponens** inference rule:

- A rule’s consequent is excluded if it can be deduced from the rule’s
  antecedent using the axioms (possibly via a chain of axiom
  applications).
- A rule is pruned entirely if any predicate in the antecedent can be
  deduced from the remaining antecedent predicates via the axioms (it
  would be redundant).

### Finding Near-Tautologies with `dig_tautologies()`

The
[`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
function is specifically designed to find rules with very high
confidence (near-tautologies / axioms). It searches iteratively, using
rules found in earlier iterations to prune the search space in later
iterations, so that only the most concise axioms are returned.

``` r

tautologies <- dig_tautologies(crisp_co2,
                               antecedent = everything(),
                               consequent = everything(),
                               min_confidence = 0.95,
                               min_support = 0.05,
                               max_length = 2)
tautologies
#> # A tibble: 7 × 13
#>   antecedent                              consequent          support confidence
#>   <chr>                                   <chr>                 <dbl>      <dbl>
#> 1 {uptake=(35;Inf]}                       {Type=Quebec}        0.286        0.96
#> 2 {Type=Quebec,uptake=(-Inf;20]}          {conc=(-Inf;200]}    0.0714       1   
#> 3 {Type=Quebec,conc=(500;Inf]}            {uptake=(35;Inf]}    0.143        1   
#> 4 {Treatment=nonchilled,uptake=(-Inf;20]} {conc=(-Inf;200]}    0.0952       1   
#> 5 {conc=(200;500],uptake=(-Inf;20]}       {Type=Mississippi}   0.107        1   
#> 6 {conc=(200;500],uptake=(-Inf;20]}       {Treatment=chilled}  0.107        1   
#> 7 {conc=(500;Inf],uptake=(20;35]}         {Type=Mississippi}   0.0833       1   
#>   coverage conseq_support  lift count antecedent_length    pp    pn    np    nn
#>      <dbl>          <dbl> <dbl> <dbl>             <int> <dbl> <dbl> <dbl> <dbl>
#> 1   0.298           0.5    1.92    24                 1    24     1    18    41
#> 2   0.0714          0.286  3.5      6                 2     6     0    18    60
#> 3   0.143           0.298  3.36    12                 2    12     0    13    59
#> 4   0.0952          0.286  3.5      8                 2     8     0    16    60
#> 5   0.107           0.5    2        9                 2     9     0    33    42
#> 6   0.107           0.5    2        9                 2     9     0    33    42
#> 7   0.0833          0.5    2        7                 2     7     0    35    42
```

### Using Axioms to Filter Association Rules

Once axioms (near-tautologies) are identified, convert them to the
format expected by the `excluded` argument using
[`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
passing both the antecedent and the consequent columns, and pass them to
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md):

``` r

# Convert tautologies to the excluded (axioms) format
excluded_conds <- parse_condition(tautologies$antecedent,
                                  tautologies$consequent)

# Search for rules while excluding entailed patterns
rules_filtered <- dig_associations(crisp_co2,
                                   antecedent = !starts_with("uptake"),
                                   consequent = starts_with("uptake"),
                                   excluded = excluded_conds,
                                   min_support = 0.1,
                                   min_confidence = 0.8)
rules_filtered
#> # A tibble: 4 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 2 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 3 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 4 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.107      1        0.107          0.345  2.90     9                 3     9
#> 2   0.226      0.905    0.25           0.357  2.53    19                 2    19
#> 3   0.107      1        0.107          0.357  2.8      9                 3     9
#> 4   0.131      0.917    0.143          0.357  2.57    11                 2    11
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    20    55
#> 2     2    11    52
#> 3     0    21    54
#> 4     1    19    53
```

By providing known axioms, the search skips rules whose consequent can
be deduced from their antecedent, and also prunes rules that contain
redundant antecedent predicates (deducible from the remaining antecedent
predicates). This focuses the results on genuinely interesting patterns
and can run significantly faster on large datasets.

### Manually Specifying Axioms

You can also construct the `excluded` list manually. Each element is a
character vector representing an implication (axiom): all elements
except the last form the antecedent and the last element is the
consequent:

``` r

# Axiom: "Treatment=chilled => Type=Mississippi"
# Any rule whose consequent is "Type=Mississippi" and whose antecedent contains
# "Treatment=chilled" will be excluded, because the consequent is deducible
# from the antecedent via this axiom.
manual_excluded <- list(c("Treatment=chilled", "Type=Mississippi"))

rules_manual <- dig_associations(crisp_co2,
                                 antecedent = !starts_with("uptake"),
                                 consequent = starts_with("uptake"),
                                 excluded = manual_excluded,
                                 min_support = 0.1,
                                 min_confidence = 0.8)
rules_manual
#> # A tibble: 3 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.131      0.917    0.143          0.357  2.57    11                 2    11
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     1    19    53
```

This is useful when you have domain knowledge about which implications
are trivially true or undesirable, without needing to run
[`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
first.

## Summary

This vignette demonstrated how to search for association rules using the
`nuggets` package:

1.  **Data preparation** with
    [`partition()`](https://beerda.github.io/nuggets/reference/partition.md)
    transforms raw data into crisp or fuzzy predicates suitable for rule
    mining (see
    [`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md)
    for details).

2.  **Basic search** with
    [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
    finds rules meeting minimum support and confidence thresholds.

3.  **Controlling the search space**: use `antecedent`/`consequent` to
    constrain which predicates appear on each side, `disjoint` to
    prevent contradictory combinations via
    [`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md),
    and `min_length`/`max_length` to control rule complexity.

4.  **Fuzzy rules** extend the approach to graded membership using
    t-norms (`"goguen"`, `"goedel"`, `"lukas"`).

5.  **Interest measures** can be added with
    [`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md)
    to evaluate rules from multiple perspectives (conviction, leverage,
    Jaccard, GUHA quantifiers, and many more).

6.  **Excluding entailed rules** with the `excluded` argument and
    [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
    removes rules whose consequent is deducible from the antecedent via
    known axioms (near-tautologies / implications), and also prunes
    rules with redundant antecedent predicates (deducible from the
    remaining predicates). This speeds up the search and focuses results
    on genuinely interesting patterns.

For further details, consult the function documentation:
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md),
[`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md),
[`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md),
[`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
[`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md).
