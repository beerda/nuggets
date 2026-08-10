# Custom Pattern Search with dig()

## Introduction

[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) is the
general function behind custom pattern search in the `nuggets` package.
It searches for patterns of a custom type by generating conditions as
elementary conjunctions of predicates and by executing a user-defined
callback function on each generated condition.

This makes [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
the low-level building block behind more specialized functions such as
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
and
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md).
Use it when you want to keep the search over conditions, but define your
own evaluation logic.

This vignette focuses on how to use the
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) function:
how to write the callback function and how to control the search. For
preparation of crisp and fuzzy predicates, see
[`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md).

Examples in this vignette require loading the following packages:

``` r

library(nuggets)
library(dplyr)     # for data manipulation
```

## A Small Working Dataset

[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) expects a
matrix or data frame whose columns are logical predicates or numeric
fuzzy predicates. We will use `iris` and prepare a small crisp predicate
dataset that is rich enough for the first examples below:

``` r

crisp_iris <- iris |>
    partition(Species) |>
    partition(Sepal.Length:Petal.Width, .method = "crisp", .breaks = 3)

head(crisp_iris, n = 3)
#> # A tibble: 3 × 15
#>   `Species=setosa` `Species=versicolor` `Species=virginica`
#>   <lgl>            <lgl>                <lgl>              
#> 1 TRUE             FALSE                FALSE              
#> 2 TRUE             FALSE                FALSE              
#> 3 TRUE             FALSE                FALSE              
#>   `Sepal.Length=(-Inf;5.5]` `Sepal.Length=(5.5;6.7]` `Sepal.Length=(6.7;Inf]`
#>   <lgl>                     <lgl>                    <lgl>                   
#> 1 TRUE                      FALSE                    FALSE                   
#> 2 TRUE                      FALSE                    FALSE                   
#> 3 TRUE                      FALSE                    FALSE                   
#>   `Sepal.Width=(-Inf;2.8]` `Sepal.Width=(2.8;3.6]` `Sepal.Width=(3.6;Inf]`
#>   <lgl>                    <lgl>                   <lgl>                  
#> 1 FALSE                    TRUE                    FALSE                  
#> 2 FALSE                    TRUE                    FALSE                  
#> 3 FALSE                    TRUE                    FALSE                  
#>   `Petal.Length=(-Inf;2.97]` `Petal.Length=(2.97;4.93]`
#>   <lgl>                      <lgl>                     
#> 1 TRUE                       FALSE                     
#> 2 TRUE                       FALSE                     
#> 3 TRUE                       FALSE                     
#>   `Petal.Length=(4.93;Inf]` `Petal.Width=(-Inf;0.9]` `Petal.Width=(0.9;1.7]`
#>   <lgl>                     <lgl>                    <lgl>                  
#> 1 FALSE                     TRUE                     FALSE                  
#> 2 FALSE                     TRUE                     FALSE                  
#> 3 FALSE                     TRUE                     FALSE                  
#>   `Petal.Width=(1.7;Inf]`
#>   <lgl>                  
#> 1 FALSE                  
#> 2 FALSE                  
#> 3 FALSE
```

The commands above create crisp predicates for the four numeric columns
of `iris`, plus the three species predicates. The preparation step is
intentionally brief here; the dedicated
[`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md)
explains
[`partition()`](https://beerda.github.io/nuggets/reference/partition.md),
fuzzy predicates, and breakpoints in detail.

## A Simple `dig()` Call

The [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
function generates conditions from the selected predicates in a
recursive manner. It starts with the empty condition and adds one
predicate at a time, up to the specified `max_length`. Meanwhile, it
evaluates the generated condition and tests whether it meets the minimum
support requirement. By support we mean the relative frequency of rows
satisfying the condition. If the condition is frequent enough,
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) calls the
user-defined callback function with the generated condition and other
information. The callback can then compute any output you want. The
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) function
collects those outputs and returns them as a list.

The simplest callback function can handle just the generated condition.
In the following example, the callback generates some debug output and
returns the formatted condition:

``` r

simple_callback <- function(condition) {
    str(condition)
    cat("------\n")
    
    list(condition = format_condition(names(condition)))
}

simple_result <- dig(x = crisp_iris,
                     f = simple_callback,
                     condition = starts_with("Sepal"),
                     min_length = 0,
                     max_length = 2,
                     min_support = 0.2)
#>  int(0) 
#> ------
#>  Named int 8
#>  - attr(*, "names")= chr "Sepal.Width=(2.8;3.6]"
#> ------
#>  Named int [1:2] 8 5
#>  - attr(*, "names")= chr [1:2] "Sepal.Width=(2.8;3.6]" "Sepal.Length=(5.5;6.7]"
#> ------
#>  Named int [1:2] 8 4
#>  - attr(*, "names")= chr [1:2] "Sepal.Width=(2.8;3.6]" "Sepal.Length=(-Inf;5.5]"
#> ------
#>  Named int 5
#>  - attr(*, "names")= chr "Sepal.Length=(5.5;6.7]"
#> ------
#>  Named int [1:2] 5 7
#>  - attr(*, "names")= chr [1:2] "Sepal.Length=(5.5;6.7]" "Sepal.Width=(-Inf;2.8]"
#> ------
#>  Named int 4
#>  - attr(*, "names")= chr "Sepal.Length=(-Inf;5.5]"
#> ------
#>  Named int 7
#>  - attr(*, "names")= chr "Sepal.Width=(-Inf;2.8]"
#> ------
```

As you can see from the debug output issued by the
[`str()`](https://rdrr.io/r/utils/str.html) call within the callback,
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) enumerates
all conditions that can be formed from the selected predicates (in this
case, all predicates starting with “Sepal”) and that meet the minimum
support requirement. The callback receives each condition in the form of
a named integer vector, where the names are the predicate names and the
values are the column indices in the original data frame. The callback
then returns a named list with the formatted condition. All callback
results are collected into a list and returned by
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md):

``` r

str(simple_result)
#> List of 8
#>  $ :List of 1
#>   ..$ condition: chr "{}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Width=(2.8;3.6]}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Length=(5.5;6.7],Sepal.Width=(2.8;3.6]}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Length=(-Inf;5.5],Sepal.Width=(2.8;3.6]}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Length=(5.5;6.7]}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Length=(5.5;6.7],Sepal.Width=(-Inf;2.8]}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Length=(-Inf;5.5]}"
#>  $ :List of 1
#>   ..$ condition: chr "{Sepal.Width=(-Inf;2.8]}"
#>  - attr(*, "search_stats")=List of 4
#>   ..$ runtime_millis       : num 10.9
#>   ..$ computed_conjunctions: num 4
#>   ..$ cached_conjunctions  : num 0
#>   ..$ total_conjunctions   : num 4
#>  - attr(*, "class")= chr [1:2] "nugget" "list"
#>  - attr(*, "call_function")= chr "dig"
#>  - attr(*, "call_data")=List of 3
#>   ..$ nrow    : int 150
#>   ..$ ncol    : int 15
#>   ..$ colnames: chr [1:15] "Species=setosa" "Species=versicolor" "Species=virginica" "Sepal.Length=(-Inf;5.5]" ...
#>  - attr(*, "call_args")=List of 16
#>   ..$ x                            : chr "crisp_iris"
#>   ..$ condition                    : chr [1:6] "Sepal.Length=(-Inf;5.5]" "Sepal.Length=(5.5;6.7]" "Sepal.Length=(6.7;Inf]" "Sepal.Width=(-Inf;2.8]" ...
#>   ..$ focus                        : chr(0) 
#>   ..$ disjoint                     : chr [1:15] "Species" "Species" "Species" "Sepal.Length" ...
#>   ..$ excluded                     : NULL
#>   ..$ min_length                   : int 0
#>   ..$ max_length                   : int 2
#>   ..$ min_support                  : num 0.2
#>   ..$ min_focus_support            : num 0
#>   ..$ min_conditional_focus_support: num 0
#>   ..$ max_support                  : num 1
#>   ..$ filter_empty_foci            : logi FALSE
#>   ..$ t_norm                       : chr "goguen"
#>   ..$ max_results                  : int -1
#>   ..$ verbose                      : logi FALSE
#>   ..$ threads                      : int 1
```

As you can see, the result is a list of named lists, one for each
condition that was generated and passed to the callback. You can flatten
the result into a tibble with `dplyr`’s
[`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html):

``` r

bind_rows(simple_result)
#> # A tibble: 8 × 1
#>   condition                                      
#>   <chr>                                          
#> 1 {}                                             
#> 2 {Sepal.Width=(2.8;3.6]}                        
#> 3 {Sepal.Length=(5.5;6.7],Sepal.Width=(2.8;3.6]} 
#> 4 {Sepal.Length=(-Inf;5.5],Sepal.Width=(2.8;3.6]}
#> 5 {Sepal.Length=(5.5;6.7]}                       
#> 6 {Sepal.Length=(5.5;6.7],Sepal.Width=(-Inf;2.8]}
#> 7 {Sepal.Length=(-Inf;5.5]}                      
#> 8 {Sepal.Width=(-Inf;2.8]}
```

Note also the attributes of the result list. They contain information
about the search, such as the search statistics and the arguments that
were passed to
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md). You can
use this information for debugging or for reproducing the search later.
For example, you can obtain the vector of predicate names that were used
to generate conditions with:

``` r

attributes(simple_result)$call_args$condition
#> [1] "Sepal.Length=(-Inf;5.5]" "Sepal.Length=(5.5;6.7]" 
#> [3] "Sepal.Length=(6.7;Inf]"  "Sepal.Width=(-Inf;2.8]" 
#> [5] "Sepal.Width=(2.8;3.6]"   "Sepal.Width=(3.6;Inf]"
```

This simple example illustrates the basic workflow:

1.  choose which predicates may form conditions;
2.  set the search parameters (length, support, etc.);
3.  define a callback function that computes the desired output for each
    condition;
4.  let [`dig()`](https://beerda.github.io/nuggets/reference/dig.md)
    enumerate conditions and collect callback results.

## Condition and Focus

The simple example above only used the predicates for generating
conditions. In many cases, you will also want to evaluate other
predicates within each generated condition. For example, you may want to
know how often each species occurs within a condition. That’s where the
*foci* (plural of *focus*) come into play.

Condition and focus predicates are selected separately with the
`condition` and `focus` arguments of
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md). These
arguments accept [tidyselect
expressions](https://tidyselect.r-lib.org/reference/language.html) for
selecting columns of the input data frame `x`.

### Using Foci

Foci are predicates that are not used to generate conditions, but are
evaluated within each generated condition. You can select foci with the
`focus` argument of
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md). The
callback function can then receive information about how often each
focus occurs within the generated condition. This is useful, e.g., for
finding conditions that are strongly associated with certain foci.

For instance, let us define a callback that provides the number of
occurences of each species within each generated condition:

``` r

focus_callback <- function(condition, sum, pp) { 
    str(list(condition = condition,
             sum = sum,
             species = pp))
    cat("------\n")

    NULL
}

focus_result <- dig(x = crisp_iris,
                    f = focus_callback,
                    condition = starts_with("Sepal"),
                    focus = starts_with("Species"),
                    min_length = 2,
                    max_length = 2,
                    max_results = 1)
#> List of 3
#>  $ condition: Named int [1:2] 8 5
#>   ..- attr(*, "names")= chr [1:2] "Sepal.Width=(2.8;3.6]" "Sepal.Length=(5.5;6.7]"
#>  $ sum      : num 37
#>  $ species  : Named num [1:3] 0 20 17
#>   ..- attr(*, "names")= chr [1:3] "Species=setosa" "Species=versicolor" "Species=virginica"
#> ------
```

We have defined a callback that, besides `condition`, also receives
`sum` and `pp`. The `sum` argument provides the number of rows
satisfying the generated condition, and the `pp` argument contains the
number of rows that satisfy both the generated condition and each focus
predicate. In this case, the focus predicates are the species
predicates, so `pp` tells us how many rows of each species satisfy the
generated condition.

Also note that we are using a neat trick that is useful during
development of the callback: we set `max_results = 1` to stop the search
after the first condition that meets the criteria. This allows us to see
the output of the callback without waiting for the entire search to
complete, which can be time-consuming for large datasets or complex
conditions.

So far, our callback only prints the information to the console and
returns `NULL`. Once we understand the structure of the data we receive,
we can modify the callback to return a list of patterns, where each
pattern contains the formatted condition, a single species, the count of
data rows satisfying the condition, and the count of the species within
that condition:

``` r

focus_callback <- function(condition, sum, pp) { 
    species_names <- names(pp)
    species_counts <- as.integer(pp)

    lapply(seq_along(species_names), function(i) {
        list(condition = format_condition(names(condition)),
             species = species_names[i],
             condition_count = sum,
             species_count = species_counts[i])
    })
}
    
focus_result <- dig(x = crisp_iris,
                    f = focus_callback,
                    condition = starts_with("Sepal"),
                    focus = starts_with("Species"),
                    min_length = 0,
                    max_length = 2) 
```

The result of
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) is a list
of lists, where each inner list corresponds to a species within a
generated condition. We use `unlist(recursive = FALSE)` to flatten the
list of lists into a single list of patterns, and then
[`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html) to
convert it into a tibble for easier viewing:

``` r

focus_result |>
    unlist(recursive = FALSE) |>
    bind_rows() |>
    head(n = 6)
#> # A tibble: 6 × 4
#>   condition               species            condition_count species_count
#>   <chr>                   <chr>                        <dbl>         <int>
#> 1 {}                      Species=setosa                 150            50
#> 2 {}                      Species=versicolor             150            50
#> 3 {}                      Species=virginica              150            50
#> 4 {Sepal.Width=(2.8;3.6]} Species=setosa                  88            36
#> 5 {Sepal.Width=(2.8;3.6]} Species=versicolor              88            23
#> 6 {Sepal.Width=(2.8;3.6]} Species=virginica               88            29
```

### Filtering Foci

As discussed in the previous section,
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) evaluates
the focus predicates within each generated condition. You may or may not
want to keep all foci for each condition. Some patterns may require all
foci to be evaluated every time, while others may only require a subset
of foci to be considered that are sufficiently frequent within the
condition. Therefore,
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) provides
several arguments to filter foci based on their support:

- `min_focus_support`: minimum support of a focus within a condition.
  I.e., the relative frequency of rows satisfying both the condition and
  the focus must be at least this value for the focus to be kept. Foci
  with support below this threshold are filtered out.
- `min_conditional_focus_support`: minimum conditional support of a
  focus within a condition. I.e., the relative frequency of rows
  satisfying both the condition and the focus, divided by the number of
  rows satisfying the condition, must be at least this value for the
  focus to be kept. Foci with conditional support below this threshold
  are filtered out.

The focus filtering may result in some conditions having no remaining
foci. If you want to skip the callback for such conditions, set
`filter_empty_foci = TRUE`. Otherwise, the callback will be called with
empty focus information. Filtering empty foci also improves performance,
because it also stops early the evaluation of longer conditions that
would not have any remaining foci anyway.

The following example shows how this can be used to emulate
association-rule search with a custom callback. Association rules are
implications of the form “if condition then focus”. Condition is named
the *antecedent* and focus is named the *consequent*. The callback
computes the confidence of each antecedent-consequent pair, filters the
pairs based on minimum support and confidence, and returns a list of
rules:

``` r

min_support <- 0.1
min_confidence <- 0.8

rule_callback <- function(condition, pp, support) {
    conf <- pp / support / nrow(crisp_iris)
    sel <- !is.na(conf) & conf >= min_confidence & !is.na(pp) & pp >= min_support
    conf <- conf[sel]
    supp <- pp[sel] / nrow(crisp_iris)

    lapply(seq_along(conf), function(i) {
        list(antecedent = format_condition(names(condition)),
             consequent = names(conf)[[i]],
             antecedent_support = support,
             rule_support = supp[[i]],
             confidence = conf[[i]]
        )
    })
}

rule_result <- dig(x = crisp_iris,
                   f = rule_callback,
                   condition = !starts_with("Species"),
                   focus = starts_with("Species"),
                   min_length = 1,
                   min_support = min_support,
                   min_focus_support = min_support,
                   min_conditional_focus_support = min_confidence,
                   filter_empty_foci = TRUE) |>
    unlist(recursive = FALSE) |>
    bind_rows() |>
    arrange(desc(confidence))

head(rule_result, n = 6)
#> # A tibble: 6 × 5
#>   antecedent                                                                    
#>   <chr>                                                                         
#> 1 {Petal.Length=(2.97;4.93],Petal.Width=(0.9;1.7],Sepal.Length=(5.5;6.7],Sepal.…
#> 2 {Petal.Width=(0.9;1.7],Sepal.Length=(5.5;6.7],Sepal.Width=(2.8;3.6]}          
#> 3 {Petal.Length=(4.93;Inf],Petal.Width=(1.7;Inf],Sepal.Length=(5.5;6.7],Sepal.W…
#> 4 {Petal.Length=(-Inf;2.97],Sepal.Length=(-Inf;5.5],Sepal.Width=(2.8;3.6]}      
#> 5 {Petal.Length=(-Inf;2.97],Petal.Width=(-Inf;0.9],Sepal.Length=(-Inf;5.5],Sepa…
#> 6 {Petal.Width=(-Inf;0.9],Sepal.Length=(-Inf;5.5],Sepal.Width=(2.8;3.6]}        
#>   consequent         antecedent_support rule_support confidence
#>   <chr>                           <dbl>        <dbl>      <dbl>
#> 1 Species=versicolor              0.12         0.12           1
#> 2 Species=versicolor              0.127        0.127          1
#> 3 Species=virginica               0.1          0.1            1
#> 4 Species=setosa                  0.24         0.24           1
#> 5 Species=setosa                  0.24         0.24           1
#> 6 Species=setosa                  0.24         0.24           1
```

This is a useful illustration of focus filtering, but association rules
already have a dedicated implementation:
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
searches for them more efficiently. For that purpose, prefer
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
and see
[`vignette("association-rules")`](https://beerda.github.io/nuggets/articles/association-rules.md).

## What the Callback Function Can Receive

As seen in the previous section, the callback function `f` may obtain
not only the generated condition, but also other information. The amount
of received information is controlled by declaring the arguments of the
callback function.
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) inspects
the callback function argument names and computes only the requested
values. This is important for performance, because some values are
expensive to compute and may not be needed for every search.

The callback function may declare any subset of the following arguments:

- `condition`: named integer vector of column indices representing the
  generated condition.
- `sum`: number of rows satisfying the condition for logical data, or
  the sum of truth degrees for fuzzy data.
- `support`: relative frequency of the condition, i.e., `sum / nrow(x)`.
- `indices`: row indices of the original dataset `x` satisfying the
  condition in crisp searches or the indices of rows with non-zero truth
  degrees in fuzzy searches.
- `weights`: per-row truth degrees of the condition in dataset `x`;
  logical (crisp) data is treated as 0/1 weights.
- `pp`, `pn`, `np`, `nn`: contingency-table entries for foci. The
  *i*-th\* entry of each vector corresponds to the *i*-th focus
  predicate. The entries are defined as follows:
  - `pp`: sum of truth degrees of rows satisfying both the condition and
    the focus (**p**ositive condition, **p**ositive focus),
  - `pn`: sum of truth degrees of rows satisfying the condition but not
    the focus, (**p**ositive condition, **n**egative focus),
  - `np`: sum of truth degrees of rows satisfying the focus but not the
    condition, (**n**egative condition, **p**ositive focus),
  - `nn`: sum of truth degrees of rows satisfying neither (**n**egative
    condition, **n**egative focus).

In practice:

- use `condition` when you need condition predicate names,
- use `support` or `sum` for condition-level filtering or ranking,
- use `indices` when you want to compute something on the original rows,
- use `weights` for custom fuzzy summaries,
- use `pp`, `pn`, `np`, and `nn` when your pattern depends on foci and
  their frequency within the condition.

Note: only declare the arguments you need. For example, if you don’t
need foci, don’t declare `pp`, `pn`, `np`, or `nn`. This will save
computation time, especially for large datasets or complex conditions.
The most expensive values to compute are `indices` and `weights`. They
require scanning the entire dataset for each generated condition. So
avoid them if not needed.

## Advanced Examples

### Example: Fixed-Variable Correlations

[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md)
searches over both generated conditions and combinations of numeric
variables. A simpler custom variant can be built directly with
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) when the
two variables are fixed in advance and only the condition should vary.

Here we search for conditions under which `Sepal.Length` and
`Petal.Length` correlate strongly. The callback receives `indices`, uses
them to select the corresponding rows from the original `iris` data, and
runs [`cor.test()`](https://rdrr.io/r/stats/cor.test.html) on that
sub-data:

``` r

correlation_callback <- function(condition, support, indices) {
    if (length(indices) < 10) {
        return(NULL)
    }
    fit <- cor.test(iris$Sepal.Length[indices],
                    iris$Petal.Length[indices],
                    method = "pearson")

    list(condition = format_condition(names(condition)),
         support = support,
         correlation = unname(fit$estimate),
         p_value = fit$p.value,
         n = length(indices))
}

correlation_result <- dig(x = crisp_iris,
                          f = correlation_callback,
                          condition = everything(),
                          min_length = 1,
                          max_length = 2,
                          min_support = 0.1) |>
    bind_rows() |>
    arrange(desc(abs(correlation)))

head(correlation_result, n = 6)
#> # A tibble: 6 × 5
#>   condition                                        support correlation  p_value
#>   <chr>                                              <dbl>       <dbl>    <dbl>
#> 1 {Sepal.Width=(3.6;Inf]}                            0.1         0.949 6.98e- 8
#> 2 {Petal.Length=(4.93;Inf],Sepal.Width=(-Inf;2.8]}   0.107       0.935 1.15e- 7
#> 3 {Sepal.Width=(2.8;3.6]}                            0.587       0.930 3.63e-39
#> 4 {Petal.Width=(1.7;Inf],Sepal.Width=(-Inf;2.8]}     0.1         0.919 1.33e- 6
#> 5 {Sepal.Width=(-Inf;2.8],Species=virginica}         0.127       0.907 8.78e- 8
#> 6 {Petal.Width=(1.7;Inf]}                            0.307       0.865 8.94e-15
#>       n
#>   <int>
#> 1   150
#> 2   150
#> 3   150
#> 4   150
#> 5   150
#> 6   150
```

This example follows the same idea as
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md):

- generate conditions,
- evaluate a statistic on the sub-data induced by each condition,
- return one row per successful evaluation.

The difference is that
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) leaves the
statistic entirely in your hands. That is useful when you want to fix
the variables, apply a custom test, return additional diagnostics, or
combine several criteria in one callback.

### Example: Handling Fuzzy Data

For fuzzy searches, conditions are no longer simply satisfied or not
satisfied. Instead, each row has a truth degree in the interval
\\\[0,1\]\\. In that setting, `indices` and `weights` play different
roles:

- `indices` tell you which rows have a non-zero truth degree for the
  condition,
- `weights` tell you on scale \\\[0, 1\]\\ how strongly each row
  satisfies the condition.

The following example prepares fuzzy predicates from `iris` and then
compares an unweighted summary based on `indices` with a weighted
summary based on `weights`:

``` r

fuzzy_iris <- iris |>
    partition(Species) |>
    partition(Sepal.Length:Petal.Width, .method = "triangle", .breaks = 3)

head(fuzzy_iris, n = 3)
#> # A tibble: 3 × 15
#>   `Species=setosa` `Species=versicolor` `Species=virginica`
#>   <lgl>            <lgl>                <lgl>              
#> 1 TRUE             FALSE                FALSE              
#> 2 TRUE             FALSE                FALSE              
#> 3 TRUE             FALSE                FALSE              
#>   `Sepal.Length=(-Inf;4.3;6.1)` `Sepal.Length=(4.3;6.1;7.9)`
#>                           <dbl>                        <dbl>
#> 1                         0.556                        0.444
#> 2                         0.667                        0.333
#> 3                         0.778                        0.222
#>   `Sepal.Length=(6.1;7.9;Inf)` `Sepal.Width=(-Inf;2;3.2)`
#>                          <dbl>                      <dbl>
#> 1                            0                      0    
#> 2                            0                      0.167
#> 3                            0                      0    
#>   `Sepal.Width=(2;3.2;4.4)` `Sepal.Width=(3.2;4.4;Inf)`
#>                       <dbl>                       <dbl>
#> 1                     0.75                        0.250
#> 2                     0.833                       0    
#> 3                     1                           0    
#>   `Petal.Length=(-Inf;1;3.95)` `Petal.Length=(1;3.95;6.9)`
#>                          <dbl>                       <dbl>
#> 1                        0.864                       0.136
#> 2                        0.864                       0.136
#> 3                        0.898                       0.102
#>   `Petal.Length=(3.95;6.9;Inf)` `Petal.Width=(-Inf;0.1;1.3)`
#>                           <dbl>                        <dbl>
#> 1                             0                        0.917
#> 2                             0                        0.917
#> 3                             0                        0.917
#>   `Petal.Width=(0.1;1.3;2.5)` `Petal.Width=(1.3;2.5;Inf)`
#>                         <dbl>                       <dbl>
#> 1                      0.0833                           0
#> 2                      0.0833                           0
#> 3                      0.0833                           0

fuzzy_callback <- function(condition, indices, weights) {
    if (length(indices) < 20) {
        return(NULL)
    }

    list(condition = format_condition(names(condition)),
         nonzero_rows = sum(indices),
         weighted_support = sum(weights) / nrow(fuzzy_iris),
         mean_petal_length_by_indices = mean(iris$Petal.Length[indices]),
         mean_petal_length_by_weights = weighted.mean(iris$Petal.Length, weights))
}

fuzzy_result <- dig(x = fuzzy_iris,
                    f = fuzzy_callback,
                    condition = starts_with("Sepal"),
                    min_length = 1,
                    max_length = 1,
                    min_support = 0.2) |>
    bind_rows()

fuzzy_result
#> # A tibble: 4 × 5
#>   condition                     nonzero_rows weighted_support
#>   <chr>                                <int>            <dbl>
#> 1 {Sepal.Width=(2;3.2;4.4)}              148            0.694
#> 2 {Sepal.Length=(4.3;6.1;7.9)}           148            0.600
#> 3 {Sepal.Length=(-Inf;4.3;6.1)}           89            0.271
#> 4 {Sepal.Width=(-Inf;2;3.2)}              94            0.212
#>   mean_petal_length_by_indices mean_petal_length_by_weights
#>                          <dbl>                        <dbl>
#> 1                         3.78                         3.79
#> 2                         3.76                         4.08
#> 3                         2.69                         2.10
#> 4                         4.35                         4.35
```

The unweighted mean based on `indices` treats all rows with non-zero
membership equally. The weighted mean based on `weights` respects the
fuzzy truth degrees, so rows that satisfy the condition more strongly
contribute more. This is the main practical difference: `indices`
identify the relevant rows, while `weights` quantify the strength of
their membership.

## Practical Notes

- Condition predicates are used to generate conditions, while focus
  predicates are evaluated within each generated condition. Use
  `condition` and `focus` arguments to select them separately.
- The result of
  [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) is a
  list. When each callback returns one named list,
  [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
  is a convenient way to flatten it into a tibble.
- If the callback returns multiple patterns per condition, return a list
  of named lists and flatten the result afterwards.
- Use only the arguments you need in the callback function. This saves
  computation time, especially for large datasets or complex conditions.
- For fuzzy searches, use `weights` when truth degrees matter, and
  `indices` when you only need the rows with non-zero membership.

## Summary

[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) is the most
flexible search interface in `nuggets`. It lets you:

1.  generate conditions from selected predicates,
2.  optionally evaluate focus predicates within each condition,
3.  receive only the callback inputs you need,
4.  define your own pattern logic, statistics, and output format.

Use [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) when
the built-in search functions are close to what you need, but not exact.
For related material, see:

- [`vignette("data-preparation")`](https://beerda.github.io/nuggets/articles/data-preparation.md)
  for creating crisp and fuzzy predicates from raw data,
- [`vignette("association-rules")`](https://beerda.github.io/nuggets/articles/association-rules.md)
  for searching for association rules with
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md),  
- [`vignette("nuggets")`](https://beerda.github.io/nuggets/articles/nuggets.md)
  for an overview of the package and its main workflows.
