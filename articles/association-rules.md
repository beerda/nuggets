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
rules
#> # A tibble: 19 × 13
#>    antecedent                                             consequent            
#>    <chr>                                                  <chr>                 
#>  1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]}     
#>  2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}      
#>  3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}    
#>  4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}    
#>  5 {Type=Mississippi,conc=(200;500],uptake=(-Inf;20]}     {Treatment=chilled}   
#>  6 {Type=Mississippi,conc=(200;500],uptake=(20;35]}       {Treatment=nonchilled}
#>  7 {Type=Mississippi,uptake=(20;35]}                      {Treatment=nonchilled}
#>  8 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}    
#>  9 {Treatment=nonchilled,conc=(200;500],uptake=(20;35]}   {Type=Mississippi}    
#> 10 {Treatment=nonchilled,uptake=(35;Inf]}                 {Type=Quebec}         
#> 11 {Treatment=chilled,conc=(200;500],uptake=(-Inf;20]}    {Type=Mississippi}    
#> 12 {Treatment=chilled,uptake=(-Inf;20]}                   {Type=Mississippi}    
#> 13 {Treatment=chilled,uptake=(35;Inf]}                    {Type=Quebec}         
#> 14 {conc=(200;500],uptake=(-Inf;20]}                      {Type=Mississippi}    
#> 15 {conc=(200;500],uptake=(-Inf;20]}                      {Treatment=chilled}   
#> 16 {conc=(200;500],uptake=(35;Inf]}                       {Type=Quebec}         
#> 17 {uptake=(-Inf;20]}                                     {Type=Mississippi}    
#> 18 {uptake=(35;Inf]}                                      {Type=Quebec}         
#> 19 {conc=(500;Inf],uptake=(35;Inf]}                       {Type=Quebec}         
#>    support confidence coverage conseq_support  lift count antecedent_length
#>      <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int>
#>  1   0.143      1        0.143          0.298  3.36    12                 2
#>  2   0.107      1        0.107          0.345  2.90     9                 3
#>  3   0.226      0.905    0.25           0.357  2.53    19                 2
#>  4   0.107      1        0.107          0.357  2.8      9                 3
#>  5   0.107      1        0.107          0.5    2        9                 3
#>  6   0.107      1        0.107          0.5    2        9                 3
#>  7   0.179      0.882    0.202          0.5    1.76    15                 2
#>  8   0.131      0.917    0.143          0.357  2.57    11                 2
#>  9   0.107      0.9      0.119          0.5    1.8      9                 3
#> 10   0.167      0.933    0.179          0.5    1.87    14                 2
#> 11   0.107      1        0.107          0.5    2        9                 3
#> 12   0.226      0.864    0.262          0.5    1.73    19                 2
#> 13   0.119      1        0.119          0.5    2       10                 2
#> 14   0.107      1        0.107          0.5    2        9                 2
#> 15   0.107      1        0.107          0.5    2        9                 2
#> 16   0.143      1        0.143          0.5    2       12                 2
#> 17   0.286      0.8      0.357          0.5    1.6     24                 1
#> 18   0.286      0.96     0.298          0.5    1.92    24                 1
#> 19   0.143      0.923    0.155          0.5    1.85    12                 2
#>       pp    pn    np    nn
#>    <dbl> <dbl> <dbl> <dbl>
#>  1    12     0    13    59
#>  2     9     0    20    55
#>  3    19     2    11    52
#>  4     9     0    21    54
#>  5     9     0    33    42
#>  6     9     0    33    42
#>  7    15     2    27    40
#>  8    11     1    19    53
#>  9     9     1    33    41
#> 10    14     1    28    41
#> 11     9     0    33    42
#> 12    19     3    23    39
#> 13    10     0    32    42
#> 14     9     0    33    42
#> 15     9     0    33    42
#> 16    12     0    30    42
#> 17    24     6    18    36
#> 18    24     1    18    41
#> 19    12     1    30    41
```

The result is a tibble containing found rules with their quality
measures: `antecedent`, `consequent`, `support`, `confidence`,
`coverage`, `consequent_support`, `lift`, `length`, and the contingency
table columns (`pp`, `pn`, `np`, `nn`).

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
rules_uptake
#> # A tibble: 5 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#> 4   0.107      1        0.107          0.357  2.8      9                 3     9
#> 5   0.131      0.917    0.143          0.357  2.57    11                 2    11
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
#> 4     0    21    54
#> 5     1    19    53
```

## Using the Disjoint Argument

When data is prepared with
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
a single original variable is often expanded into multiple predicates
(e.g., `conc=(-Inf,200]` and `conc=(200,500]`). These predicates from
the same variable should not appear together in the same antecedent, as
their conjunction would be contradictory or redundant. The `disjoint`
argument prevents this. By default,
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
uses
[`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md)
on the column names to create groups of mutually exclusive predicates.

You can also provide a custom disjoint vector:

``` r

disj <- var_names(colnames(crisp_co2))
head(disj)
#> [1] "Type"      "Type"      "Treatment" "Treatment" "conc"      "conc"

rules_disj <- dig_associations(crisp_co2,
                               antecedent = !starts_with("uptake"),
                               consequent = starts_with("uptake"),
                               disjoint = disj,
                               min_support = 0.1,
                               min_confidence = 0.8)
rules_disj
#> # A tibble: 5 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#> 4   0.107      1        0.107          0.357  2.8      9                 3     9
#> 5   0.131      0.917    0.143          0.357  2.57    11                 2    11
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
#> 4     0    21    54
#> 5     1    19    53
```

## Controlling Rule Length

The `min_length` and `max_length` arguments control the number of
predicates in the antecedent:

``` r

# Find only rules with exactly 2 predicates in the antecedent
rules_len2 <- dig_associations(crisp_co2,
                               antecedent = !starts_with("uptake"),
                               consequent = starts_with("uptake"),
                               min_length = 2,
                               max_length = 2,
                               min_support = 0.1,
                               min_confidence = 0.8)
rules_len2
#> # A tibble: 3 × 13
#>   antecedent                           consequent         support confidence
#>   <chr>                                <chr>                <dbl>      <dbl>
#> 1 {Type=Quebec,conc=(500;Inf]}         {uptake=(35;Inf]}    0.143      1    
#> 2 {Treatment=chilled,Type=Mississippi} {uptake=(-Inf;20]}   0.226      0.905
#> 3 {Type=Mississippi,conc=(-Inf;200]}   {uptake=(-Inf;20]}   0.131      0.917
#>   coverage conseq_support  lift count antecedent_length    pp    pn    np    nn
#>      <dbl>          <dbl> <dbl> <dbl>             <int> <dbl> <dbl> <dbl> <dbl>
#> 1    0.143          0.298  3.36    12                 2    12     0    13    59
#> 2    0.25           0.357  2.53    19                 2    19     2    11    52
#> 3    0.143          0.357  2.57    11                 2    11     1    19    53
```

Setting `min_length = 0` generates rules with an empty antecedent, which
effectively computes the support of each consequent alone.

## Limiting the Number of Results

For large datasets, the number of possible rules can be enormous. The
`max_results` argument limits the total number of rules generated:

``` r

rules_limited <- dig_associations(crisp_co2,
                                  antecedent = !starts_with("uptake"),
                                  consequent = starts_with("uptake"),
                                  min_support = 0.05,
                                  min_confidence = 0.6,
                                  max_results = 20)
rules_limited
#> # A tibble: 17 × 13
#>    antecedent                                              consequent        
#>    <chr>                                                   <chr>             
#>  1 {Treatment=nonchilled,Type=Quebec}                      {uptake=(35;Inf]} 
#>  2 {Treatment=nonchilled,Type=Quebec,conc=(200;500]}       {uptake=(35;Inf]} 
#>  3 {Treatment=nonchilled,Type=Quebec,conc=(500;Inf]}       {uptake=(35;Inf]} 
#>  4 {Treatment=chilled,Type=Quebec,conc=(500;Inf]}          {uptake=(35;Inf]} 
#>  5 {Type=Quebec,conc=(200;500]}                            {uptake=(35;Inf]} 
#>  6 {Type=Quebec,conc=(500;Inf]}                            {uptake=(35;Inf]} 
#>  7 {Treatment=nonchilled,Type=Mississippi}                 {uptake=(20;35]}  
#>  8 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]}  {uptake=(20;35]}  
#>  9 {Treatment=nonchilled,Type=Mississippi,conc=(-Inf;200]} {uptake=(-Inf;20]}
#> 10 {Treatment=nonchilled,Type=Mississippi,conc=(500;Inf]}  {uptake=(20;35]}  
#> 11 {Treatment=chilled,Type=Mississippi}                    {uptake=(-Inf;20]}
#> 12 {Treatment=chilled,Type=Mississippi,conc=(200;500]}     {uptake=(-Inf;20]}
#> 13 {Treatment=chilled,Type=Mississippi,conc=(-Inf;200]}    {uptake=(-Inf;20]}
#> 14 {Type=Mississippi,conc=(-Inf;200]}                      {uptake=(-Inf;20]}
#> 15 {Treatment=nonchilled,conc=(-Inf;200]}                  {uptake=(-Inf;20]}
#> 16 {Treatment=chilled,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#> 17 {conc=(-Inf;200]}                                       {uptake=(-Inf;20]}
#>    support confidence coverage conseq_support  lift count antecedent_length
#>      <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int>
#>  1  0.167       0.667   0.25            0.298  2.24    14                 2
#>  2  0.0952      0.889   0.107           0.298  2.99     8                 3
#>  3  0.0714      1       0.0714          0.298  3.36     6                 3
#>  4  0.0714      1       0.0714          0.298  3.36     6                 3
#>  5  0.143       0.667   0.214           0.298  2.24    12                 2
#>  6  0.143       1       0.143           0.298  3.36    12                 2
#>  7  0.179       0.714   0.25            0.345  2.07    15                 2
#>  8  0.107       1       0.107           0.345  2.90     9                 3
#>  9  0.0595      0.833   0.0714          0.357  2.33     5                 3
#> 10  0.0595      0.833   0.0714          0.345  2.41     5                 3
#> 11  0.226       0.905   0.25            0.357  2.53    19                 2
#> 12  0.107       1       0.107           0.357  2.8      9                 3
#> 13  0.0714      1       0.0714          0.357  2.8      6                 3
#> 14  0.131       0.917   0.143           0.357  2.57    11                 2
#> 15  0.0952      0.667   0.143           0.357  1.87     8                 2
#> 16  0.107       0.75    0.143           0.357  2.1      9                 2
#> 17  0.202       0.708   0.286           0.357  1.98    17                 1
#>       pp    pn    np    nn
#>    <dbl> <dbl> <dbl> <dbl>
#>  1    14     7    11    52
#>  2     8     1    17    58
#>  3     6     0    19    59
#>  4     6     0    19    59
#>  5    12     6    13    53
#>  6    12     0    13    59
#>  7    15     6    14    49
#>  8     9     0    20    55
#>  9     5     1    25    53
#> 10     5     1    24    54
#> 11    19     2    11    52
#> 12     9     0    21    54
#> 13     6     0    24    54
#> 14    11     1    19    53
#> 15     8     4    22    50
#> 16     9     3    21    51
#> 17    17     7    13    47
```

## Fuzzy Association Rules

When the data contains fuzzy predicates (numeric columns with values in
\\\[0, 1\]\\),
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
computes fuzzy support using a **t-norm** for conjunction. The `t_norm`
argument specifies which t-norm to use:

- `"goguen"` (default): the product t-norm — multiplies membership
  degrees
- `"goedel"`: the minimum t-norm — takes the minimum of membership
  degrees
- `"lukas"`: the Łukasiewicz t-norm — \\\max(0, a + b - 1)\\

``` r

# Fuzzy rules using the product t-norm (default)
fuzzy_rules <- dig_associations(fuzzy_co2,
                                antecedent = !starts_with("uptake"),
                                consequent = starts_with("uptake"),
                                min_support = 0.05,
                                min_confidence = 0.6,
                                t_norm = "goguen")
fuzzy_rules
#> # A tibble: 10 × 13
#>    antecedent                                                
#>    <chr>                                                     
#>  1 {Type=Quebec}                                             
#>  2 {Treatment=nonchilled,Type=Quebec}                        
#>  3 {Treatment=nonchilled,Type=Quebec,conc=(95;500;1000)}     
#>  4 {Treatment=chilled,Type=Quebec,conc=(95;500;1000)}        
#>  5 {Type=Quebec,conc=(95;500;1000)}                          
#>  6 {Type=Quebec,conc=(500;1000;Inf)}                         
#>  7 {Treatment=nonchilled,Type=Mississippi,conc=(95;500;1000)}
#>  8 {Treatment=chilled,Type=Mississippi}                      
#>  9 {Treatment=chilled,Type=Mississippi,conc=(-Inf;95;500)}   
#> 10 {Treatment=nonchilled,conc=(500;1000;Inf)}                
#>    consequent            support confidence coverage conseq_support  lift count
#>    <chr>                   <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>
#>  1 {uptake=(25;40;Inf)}   0.320       0.639   0.5             0.380  1.68 26.8 
#>  2 {uptake=(25;40;Inf)}   0.177       0.709   0.25            0.380  1.87 14.9 
#>  3 {uptake=(25;40;Inf)}   0.0894      0.876   0.102           0.380  2.31  7.51
#>  4 {uptake=(25;40;Inf)}   0.0723      0.708   0.102           0.380  1.87  6.07
#>  5 {uptake=(25;40;Inf)}   0.162       0.792   0.204           0.380  2.09 13.6 
#>  6 {uptake=(25;40;Inf)}   0.0929      0.963   0.0964          0.380  2.54  7.80
#>  7 {uptake=(10;25;40)}    0.0683      0.669   0.102           0.370  1.81  5.74
#>  8 {uptake=(-Inf;10;25)}  0.151       0.605   0.25            0.251  2.41 12.7 
#>  9 {uptake=(-Inf;10;25)}  0.0749      0.751   0.0996          0.251  3.00  6.29
#> 10 {uptake=(25;40;Inf)}   0.0681      0.706   0.0964          0.380  1.86  5.72
#>    antecedent_length    pp     pn    np    nn
#>                <int> <dbl>  <dbl> <dbl> <dbl>
#>  1                 1 26.8  15.2    5.03  37.0
#>  2                 2 14.9   6.11  17.0   46.0
#>  3                 3  7.51  1.07  24.4   51.1
#>  4                 3  6.07  2.51  25.8   49.6
#>  5                 2 13.6   3.57  18.3   48.5
#>  6                 2  7.80  0.300 24.1   51.8
#>  7                 3  5.74  2.84  25.3   50.1
#>  8                 2 12.7   8.29   8.35  54.6
#>  9                 3  6.29  2.08  14.8   60.9
#> 10                 2  5.72  2.38  26.2   49.7
```

Comparing different t-norms:

``` r

# Using the Goedel (minimum) t-norm
fuzzy_rules_goedel <- dig_associations(fuzzy_co2,
                                       antecedent = !starts_with("uptake"),
                                       consequent = starts_with("uptake"),
                                       min_support = 0.05,
                                       min_confidence = 0.6,
                                       t_norm = "goedel")
nrow(fuzzy_rules_goedel)
#> [1] 19
```

The choice of t-norm affects how strictly the conjunction is evaluated.
The Gödel t-norm is the least strict (produces higher support values),
while the Łukasiewicz t-norm is the most strict.

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
    select(antecedent, consequent, confidence, conviction, leverage, jaccard)
#> # A tibble: 5 × 6
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   confidence conviction leverage jaccard
#>        <dbl>      <dbl>    <dbl>   <dbl>
#> 1      1         Inf      0.100    0.48 
#> 2      1         Inf      0.0702   0.310
#> 3      0.905       6.75   0.137    0.594
#> 4      1         Inf      0.0689   0.3  
#> 5      0.917       7.71   0.0799   0.355
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

### Smoothing

Some interest measures may be undefined when contingency table counts
are zero (e.g., division by zero). The `smooth_counts` argument applies
Laplace smoothing to the counts before computing the measures:

``` r

rules_smoothed <- rules_uptake |>
    add_interest(measures = c("odds_ratio", "conviction"),
                 smooth_counts = 0.5)
rules_smoothed |>
    select(antecedent, consequent, confidence, odds_ratio, conviction)
#> # A tibble: 5 × 5
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   confidence odds_ratio conviction
#>        <dbl>      <dbl>      <dbl>
#> 1      1          110.       18.1 
#> 2      1           51.4      13.0 
#> 3      0.905       35.6       5.63
#> 4      1           48.2      12.8 
#> 5      0.917       21.0       5.54
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
    select(antecedent, consequent, confidence, dfi, fe, lci)
#> # A tibble: 5 × 6
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   confidence   dfi    fe      lci
#>        <dbl> <dbl> <dbl>    <dbl>
#> 1      1     0.48  0.845 0.000244
#> 2      1     0.310 0.762 0.00195 
#> 3      0.905 0.594 0.845 0.000111
#> 4      1     0.3   0.75  0.00195 
#> 5      0.917 0.355 0.762 0.00317
```

The `p` parameter represents the null-hypothesis probability used in the
binomial-test-based quantifiers (`lci`, `uci`, `dlci`, `duci`, `lce`,
`uce`).

## Excluding Tautologies from the Search

In real-world datasets, some rules are trivially true or nearly so — for
example, rules that follow directly from the structure of the data
(e.g., `engine_type=electric => fuel_type=electricity`). Such rules are
called **tautologies**. While technically valid, they are often
uninteresting and can clutter results or slow down the search.

The `excluded` argument of
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
allows you to specify a list of predicate combinations that should never
appear together in the antecedent of a generated rule. Any rule whose
antecedent contains all predicates from an excluded combination is
suppressed. Note that the term “tautology” here is used broadly — any
rule you consider uninteresting (regardless of whether its confidence is
exactly 1) can be excluded this way.

### Finding Tautologies with `dig_tautologies()`

The
[`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
function is specifically designed to find rules with very high
confidence. It searches iteratively, using tautologies found in earlier
iterations to prune the search space in later iterations. For a detailed
description, see the
[`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md).

``` r

disj <- var_names(colnames(crisp_co2))

tautologies <- dig_tautologies(crisp_co2,
                               antecedent = everything(),
                               consequent = everything(),
                               disjoint = disj,
                               min_confidence = 0.95,
                               min_support = 0.05,
                               max_length = 2)
tautologies
#> # A tibble: 6 × 13
#>   antecedent                              consequent          support confidence
#>   <chr>                                   <chr>                 <dbl>      <dbl>
#> 1 {uptake=(35;Inf]}                       {Type=Quebec}        0.286        0.96
#> 2 {Type=Quebec,uptake=(-Inf;20]}          {conc=(-Inf;200]}    0.0714       1   
#> 3 {Treatment=nonchilled,uptake=(-Inf;20]} {conc=(-Inf;200]}    0.0952       1   
#> 4 {conc=(200;500],uptake=(-Inf;20]}       {Type=Mississippi}   0.107        1   
#> 5 {conc=(200;500],uptake=(-Inf;20]}       {Treatment=chilled}  0.107        1   
#> 6 {conc=(500;Inf],uptake=(20;35]}         {Type=Mississippi}   0.0833       1   
#>   coverage conseq_support  lift count antecedent_length    pp    pn    np    nn
#>      <dbl>          <dbl> <dbl> <dbl>             <int> <dbl> <dbl> <dbl> <dbl>
#> 1   0.298           0.5    1.92    24                 1    24     1    18    41
#> 2   0.0714          0.286  3.5      6                 2     6     0    18    60
#> 3   0.0952          0.286  3.5      8                 2     8     0    16    60
#> 4   0.107           0.5    2        9                 2     9     0    33    42
#> 5   0.107           0.5    2        9                 2     9     0    33    42
#> 6   0.0833          0.5    2        7                 2     7     0    35    42
```

### Using Tautologies to Filter Association Rules

Once tautologies are identified, convert them to the format expected by
the `excluded` argument using
[`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
and pass them to
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md):

``` r

# Convert tautologies to the excluded format
excluded_conds <- parse_condition(tautologies$antecedent,
                                  tautologies$consequent)

# Search for rules while excluding tautological patterns
rules_filtered <- dig_associations(crisp_co2,
                                   antecedent = !starts_with("uptake"),
                                   consequent = starts_with("uptake"),
                                   disjoint = disj,
                                   excluded = excluded_conds,
                                   min_support = 0.1,
                                   min_confidence = 0.8)
rules_filtered
#> # A tibble: 5 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#> 4   0.107      1        0.107          0.357  2.8      9                 3     9
#> 5   0.131      0.917    0.143          0.357  2.57    11                 2    11
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
#> 4     0    21    54
#> 5     1    19    53
```

By excluding known tautologies, the search focuses on genuinely
interesting patterns and can run significantly faster on large datasets.

### Manually Specifying Exclusions

You can also construct the `excluded` list manually. Each element is a
character vector of predicate names that must not co-occur in the
antecedent:

``` r

# Exclude rules where "Type=Quebec" and "Treatment=chilled" appear together
manual_excluded <- list(c("Type=Quebec", "Treatment=chilled"))

rules_manual <- dig_associations(crisp_co2,
                                 antecedent = !starts_with("uptake"),
                                 consequent = starts_with("uptake"),
                                 disjoint = disj,
                                 excluded = manual_excluded,
                                 min_support = 0.1,
                                 min_confidence = 0.8)
rules_manual
#> # A tibble: 5 × 13
#>   antecedent                                             consequent        
#>   <chr>                                                  <chr>             
#> 1 {Type=Quebec,conc=(500;Inf]}                           {uptake=(35;Inf]} 
#> 2 {Treatment=nonchilled,Type=Mississippi,conc=(200;500]} {uptake=(20;35]}  
#> 3 {Treatment=chilled,Type=Mississippi}                   {uptake=(-Inf;20]}
#> 4 {Treatment=chilled,Type=Mississippi,conc=(200;500]}    {uptake=(-Inf;20]}
#> 5 {Type=Mississippi,conc=(-Inf;200]}                     {uptake=(-Inf;20]}
#>   support confidence coverage conseq_support  lift count antecedent_length    pp
#>     <dbl>      <dbl>    <dbl>          <dbl> <dbl> <dbl>             <int> <dbl>
#> 1   0.143      1        0.143          0.298  3.36    12                 2    12
#> 2   0.107      1        0.107          0.345  2.90     9                 3     9
#> 3   0.226      0.905    0.25           0.357  2.53    19                 2    19
#> 4   0.107      1        0.107          0.357  2.8      9                 3     9
#> 5   0.131      0.917    0.143          0.357  2.57    11                 2    11
#>      pn    np    nn
#>   <dbl> <dbl> <dbl>
#> 1     0    13    59
#> 2     0    20    55
#> 3     2    11    52
#> 4     0    21    54
#> 5     1    19    53
```

This is useful when you have domain knowledge about which combinations
are trivial or undesirable, without needing to run
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

6.  **Excluding tautologies** with the `excluded` argument and
    [`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md)
    removes trivial or uninteresting rules and speeds up the search.

For further details, consult the function documentation:
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md),
[`add_interest()`](https://beerda.github.io/nuggets/reference/add_interest.md),
[`dig_tautologies()`](https://beerda.github.io/nuggets/reference/dig_tautologies.md),
[`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
[`var_names()`](https://beerda.github.io/nuggets/reference/var_names.md).
