# Convert columns of a data frame to Boolean or fuzzy sets (triangular, trapezoidal, or raised-cosine)

Transform selected columns of a data frame into either dummy logical
variables or membership degrees of fuzzy sets, while leaving all
remaining columns unchanged. Each transformed column typically produces
multiple new columns in the output.

These transformations are most often used as a preprocessing step before
calling [`dig()`](https://beerda.github.io/nuggets/reference/dig.md) or
one of its derivatives, such as
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md),
[`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md),
or
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

The transformation depends on the column type:

- **logical** column `x` is expanded into two logical columns: `x=TRUE`
  and `x=FALSE`;

- **factor** column `x` with levels `l1`, `l2`, `l3` becomes three
  logical columns: `x=l1`, `x=l2`, and `x=l3`;

- **numeric** column `x` is transformed according to `.method`:

  - `.method = "dummy"`: the column is treated as a factor with one
    level per unique value, then expanded into dummy columns;

  - `.method = "crisp"`: the column is discretized into intervals
    (defined by `.breaks`, `.style`, and `.style_params`) and expanded
    into dummy columns representing those intervals;

  - `.method = "triangle"` or `.method = "raisedcos"`: the column is
    converted into one or more fuzzy sets, each represented by
    membership degrees in \\\[0,1\]\\ (triangular or raised-cosine
    shaped).

Details of numeric transformations are controlled by `.breaks`,
`.labels`, `.style`, `.style_params`, `.right`, `.span`, and `.inc`.

## Usage

``` r
partition(
  .data,
  .what = everything(),
  ...,
  .breaks = NULL,
  .labels = NULL,
  .na = TRUE,
  .keep = FALSE,
  .method = "crisp",
  .style = "equal",
  .style_params = list(),
  .right = TRUE,
  .span = 1,
  .inc = 1
)
```

## Arguments

- .data:

  A data frame to be processed.

- .what:

  A tidyselect expression (see [tidyselect
  syntax](https://tidyselect.r-lib.org/articles/syntax.html)) selecting
  the columns to transform.

- ...:

  Additional tidyselect expressions selecting more columns.

- .breaks:

  Ignored if `.method = "dummy"`. For other methods, either an integer
  (number of intervals/sets) or a numeric vector of breakpoints.

- .labels:

  Optional character vector with labels used for new column names. If
  `NULL`, labels are generated automatically.

- .na:

  If `TRUE`, adds an extra logical column for each source column
  containing `NA` values (e.g., `x=NA`).

- .keep:

  If `TRUE`, keep original columns in the output.

- .method:

  Transformation method for numeric columns: `"dummy"`, `"crisp"`,
  `"triangle"`, or `"raisedcos"`.

- .style:

  Controls how breakpoints are determined when `.breaks` is an integer.
  Values correspond to methods in
  [`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html),
  e.g., `"equal"`, `"quantile"`, `"kmeans"`, `"sd"`, `"hclust"`,
  `"bclust"`, `"fisher"`, `"jenks"`, `"dpih"`, `"headtails"`,
  `"maximum"`, `"box"`. Defaults to `"equal"`. Used only if
  `.method = "crisp"` and `.breaks` is a single integer.

- .style_params:

  A named list of parameters passed to the interval computation method
  specified by `.style`. Used only if `.method = "crisp"` and `.breaks`
  is an integer.

- .right:

  For `"crisp"`, whether intervals are right-closed and left-open
  (`TRUE`), or left-closed and right-open (`FALSE`).

- .span:

  Number of consecutive breaks forming a set. For `"crisp"`, controls
  interval width. For `"triangle"`/`"raisedcos"`, `.span = 1` produces
  triangular sets, `.span = 2` trapezoidal sets.

- .inc:

  Step size for shifting breaks when generating successive sets. With
  `.inc = 1`, all possible sets are created; larger values skip sets.

## Value

A tibble with `.data` transformed into Boolean or fuzzy predicates.

## Details

- Crisp partitioning is efficient and works well when attributes have
  distinct categories or clear boundaries.

- Fuzzy partitioning is recommended for modeling gradual changes or
  uncertainty, allowing smooth category transitions at a higher
  computational cost.

## Crisp transformation of numeric data

For `.method = "crisp"`, numeric columns are discretized into a set of
dummy logical variables, each representing one interval of values.

- If `.breaks` is an integer, it specifies the number of intervals into
  which the column should be divided. The intervals are determined using
  the `.style` and `.style_params` arguments, allowing not only
  equal-width but also data-driven breakpoints (e.g., quantile or
  k-means based). The first and last intervals automatically extend to
  infinity.

- If `.breaks` is a numeric vector, it specifies interval boundaries
  directly. Infinite values are allowed.

The `.style` argument defines *how* breakpoints are computed when
`.breaks` is an integer. Supported methods (from
[`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html))
include:

- `"equal"` – equal-width intervals across the column range (default);

- `"quantile"` – equal-frequency intervals (see
  [`quantile()`](https://rdrr.io/r/stats/quantile.html) for additional
  parameters that may be passed through `.style_params`; note that the
  probs parameter is set automatically and should not be included in
  `.style_params`);

- `"kmeans"` – intervals found by 1D k-means clustering (see
  [`kmeans()`](https://rdrr.io/r/stats/kmeans.html) for additional
  parameters);

- `"sd"` – intervals based on standard deviations from the mean;

- `"hclust"` – hierarchical clustering intervals (see
  [`hclust()`](https://rdrr.io/r/stats/hclust.html) for additional
  parameters);

- `"bclust"` – model-based clustering intervals (see
  [`e1071::bclust()`](https://rdrr.io/pkg/e1071/man/bclust.html) for
  additional parameters);

- `"fisher"` / `"jenks"` – Fisher–Jenks optimal partitioning;

- `"dpih"` – kernel-based density partitioning (see
  [`KernSmooth::dpih()`](https://rdrr.io/pkg/KernSmooth/man/dpih.html)
  for additional parameters);

- `"headtails"` – head/tails natural breaks;

- `"maximum"` – maximization-based partitioning;

- `"box"` – breaks at boxplot hinges.

Additional parameters for these methods can be passed through
`.style_params`, which should be a named list of arguments accepted by
the respective algorithm in
[`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html).
For example, when `.style = "kmeans"`, one can specify
`.style_params = list(algorithm = "Lloyd")` to request Lloyd's algorithm
for k-means clustering.

With `.span = 1` and `.inc = 1`, the generated intervals are consecutive
and non-overlapping. For example, with `.breaks = c(1, 3, 5, 7, 9, 11)`
and `.right = TRUE`, the intervals are \\(1;3\]\\, \\(3;5\]\\,
\\(5;7\]\\, \\(7;9\]\\, and \\(9;11\]\\. If `.right = FALSE`, the
intervals are left-closed: \\\[1;3)\\, \\\[3;5)\\, etc.

Larger `.span` values produce overlapping intervals. For example, with
`.span = 2`, `.inc = 1`, and `.right = TRUE`, intervals are \\(1;5\]\\,
\\(3;7\]\\, \\(5;9\]\\, \\(7;11\]\\.

The `.inc` argument controls how far the window shifts along `.breaks`.

- `.span = 1`, `.inc = 2` → \\(1;3\]\\, \\(5;7\]\\, \\(9;11\]\\.

- `.span = 2`, `.inc = 3` → \\(1;5\]\\, \\(9;11\]\\.

## Fuzzy transformation of numeric data

For `.method = "triangle"` or `.method = "raisedcos"`, numeric columns
are converted into fuzzy membership degrees in \\\[0,1\]\\.

- If `.breaks` is an integer, it specifies the number of fuzzy sets.

- If `.breaks` is a numeric vector, it directly defines fuzzy set
  boundaries. Infinite values produce open-ended sets.

With `.span = 1`, each fuzzy set is defined by three consecutive breaks:
membership is 0 outside the outer breaks, rises to 1 at the middle
break, then decreases back to 0 — yielding triangular or raised-cosine
sets.

With `.span > 1`, fuzzy sets use four consecutive breaks: membership
increases between the first two, remains 1 between the middle two, and
decreases between the last two — creating trapezoidal sets. Border
shapes are linear for `.method = "triangle"` and cosine for
`.method = "raisedcos"`.

The `.inc` argument defines the step between break windows:

- `.span = 1`, `.inc = 1` → \\(1;3;5)\\, \\(3;5;7)\\, \\(5;7;9)\\,
  \\(7;9;11)\\.

- `.span = 2`, `.inc = 1` → \\(1;3;5;7)\\, \\(3;5;7;9)\\,
  \\(5;7;9;11)\\.

- `.span = 1`, `.inc = 3` → \\(1;3;5)\\, \\(7;9;11)\\.

## Author

Michal Burda

## Examples

``` r
# Crisp transformation using equal-width bins
partition(CO2, conc, .method = "crisp", .breaks = 4)
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(-Inf;321]` `conc=(321;548]`
#>    <ord> <fct>  <fct>       <dbl> <lgl>             <lgl>           
#>  1 Qn1   Quebec nonchilled   16   TRUE              FALSE           
#>  2 Qn1   Quebec nonchilled   30.4 TRUE              FALSE           
#>  3 Qn1   Quebec nonchilled   34.8 TRUE              FALSE           
#>  4 Qn1   Quebec nonchilled   37.2 FALSE             TRUE            
#>  5 Qn1   Quebec nonchilled   35.3 FALSE             TRUE            
#>  6 Qn1   Quebec nonchilled   39.2 FALSE             FALSE           
#>  7 Qn1   Quebec nonchilled   39.7 FALSE             FALSE           
#>  8 Qn2   Quebec nonchilled   13.6 TRUE              FALSE           
#>  9 Qn2   Quebec nonchilled   27.3 TRUE              FALSE           
#> 10 Qn2   Quebec nonchilled   37.1 TRUE              FALSE           
#> # ℹ 74 more rows
#> # ℹ 2 more variables: `conc=(548;774]` <lgl>, `conc=(774;Inf]` <lgl>

# Crisp transformation using quantile-based bins
partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "quantile")
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(-Inf;175]` `conc=(175;350]`
#>    <ord> <fct>  <fct>       <dbl> <lgl>             <lgl>           
#>  1 Qn1   Quebec nonchilled   16   TRUE              FALSE           
#>  2 Qn1   Quebec nonchilled   30.4 TRUE              FALSE           
#>  3 Qn1   Quebec nonchilled   34.8 FALSE             TRUE            
#>  4 Qn1   Quebec nonchilled   37.2 FALSE             TRUE            
#>  5 Qn1   Quebec nonchilled   35.3 FALSE             FALSE           
#>  6 Qn1   Quebec nonchilled   39.2 FALSE             FALSE           
#>  7 Qn1   Quebec nonchilled   39.7 FALSE             FALSE           
#>  8 Qn2   Quebec nonchilled   13.6 TRUE              FALSE           
#>  9 Qn2   Quebec nonchilled   27.3 TRUE              FALSE           
#> 10 Qn2   Quebec nonchilled   37.1 FALSE             TRUE            
#> # ℹ 74 more rows
#> # ℹ 2 more variables: `conc=(350;675]` <lgl>, `conc=(675;Inf]` <lgl>

# Crisp transformation using k-means clustering for breakpoints
partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "kmeans")
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(-Inf;212]` `conc=(212;425]`
#>    <ord> <fct>  <fct>       <dbl> <lgl>             <lgl>           
#>  1 Qn1   Quebec nonchilled   16   TRUE              FALSE           
#>  2 Qn1   Quebec nonchilled   30.4 TRUE              FALSE           
#>  3 Qn1   Quebec nonchilled   34.8 FALSE             TRUE            
#>  4 Qn1   Quebec nonchilled   37.2 FALSE             TRUE            
#>  5 Qn1   Quebec nonchilled   35.3 FALSE             FALSE           
#>  6 Qn1   Quebec nonchilled   39.2 FALSE             FALSE           
#>  7 Qn1   Quebec nonchilled   39.7 FALSE             FALSE           
#>  8 Qn2   Quebec nonchilled   13.6 TRUE              FALSE           
#>  9 Qn2   Quebec nonchilled   27.3 TRUE              FALSE           
#> 10 Qn2   Quebec nonchilled   37.1 FALSE             TRUE            
#> # ℹ 74 more rows
#> # ℹ 2 more variables: `conc=(425;838]` <lgl>, `conc=(838;Inf]` <lgl>

# Crisp transformation using Lloyd algorithm for k-means clustering for breakpoints
partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "kmeans",
          .style_params = list(algorithm = "Lloyd"))
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(-Inf;212]` `conc=(212;425]`
#>    <ord> <fct>  <fct>       <dbl> <lgl>             <lgl>           
#>  1 Qn1   Quebec nonchilled   16   TRUE              FALSE           
#>  2 Qn1   Quebec nonchilled   30.4 TRUE              FALSE           
#>  3 Qn1   Quebec nonchilled   34.8 FALSE             TRUE            
#>  4 Qn1   Quebec nonchilled   37.2 FALSE             TRUE            
#>  5 Qn1   Quebec nonchilled   35.3 FALSE             FALSE           
#>  6 Qn1   Quebec nonchilled   39.2 FALSE             FALSE           
#>  7 Qn1   Quebec nonchilled   39.7 FALSE             FALSE           
#>  8 Qn2   Quebec nonchilled   13.6 TRUE              FALSE           
#>  9 Qn2   Quebec nonchilled   27.3 TRUE              FALSE           
#> 10 Qn2   Quebec nonchilled   37.1 FALSE             TRUE            
#> # ℹ 74 more rows
#> # ℹ 2 more variables: `conc=(425;838]` <lgl>, `conc=(838;Inf]` <lgl>

# Fuzzy triangular transformation (default)
partition(CO2, conc:uptake, .method = "triangle", .breaks = 3)
#> # A tibble: 84 × 9
#>    Plant Type   Treatment  `conc=(-Inf;95;548)` `conc=(95;548;1000)`
#>    <ord> <fct>  <fct>                     <dbl>                <dbl>
#>  1 Qn1   Quebec nonchilled                1                    0    
#>  2 Qn1   Quebec nonchilled                0.823                0.177
#>  3 Qn1   Quebec nonchilled                0.658                0.342
#>  4 Qn1   Quebec nonchilled                0.437                0.563
#>  5 Qn1   Quebec nonchilled                0.106                0.894
#>  6 Qn1   Quebec nonchilled                0                    0.719
#>  7 Qn1   Quebec nonchilled                0                    0    
#>  8 Qn2   Quebec nonchilled                1                    0    
#>  9 Qn2   Quebec nonchilled                0.823                0.177
#> 10 Qn2   Quebec nonchilled                0.658                0.342
#> # ℹ 74 more rows
#> # ℹ 4 more variables: `conc=(548;1000;Inf)` <dbl>,
#> #   `uptake=(-Inf;7.7;26.6)` <dbl>, `uptake=(7.7;26.6;45.5)` <dbl>,
#> #   `uptake=(26.6;45.5;Inf)` <dbl>

# Raised-cosine fuzzy sets
partition(CO2, conc:uptake, .method = "raisedcos", .breaks = 3)
#> # A tibble: 84 × 9
#>    Plant Type   Treatment  `conc=(-Inf;95;548)` `conc=(95;548;1000)`
#>    <ord> <fct>  <fct>                     <dbl>                <dbl>
#>  1 Qn1   Quebec nonchilled               1                    0     
#>  2 Qn1   Quebec nonchilled               0.925                0.0750
#>  3 Qn1   Quebec nonchilled               0.738                0.262 
#>  4 Qn1   Quebec nonchilled               0.402                0.598 
#>  5 Qn1   Quebec nonchilled               0.0274               0.973 
#>  6 Qn1   Quebec nonchilled               0                    0.818 
#>  7 Qn1   Quebec nonchilled               0                    0     
#>  8 Qn2   Quebec nonchilled               1                    0     
#>  9 Qn2   Quebec nonchilled               0.925                0.0750
#> 10 Qn2   Quebec nonchilled               0.738                0.262 
#> # ℹ 74 more rows
#> # ℹ 4 more variables: `conc=(548;1000;Inf)` <dbl>,
#> #   `uptake=(-Inf;7.7;26.6)` <dbl>, `uptake=(7.7;26.6;45.5)` <dbl>,
#> #   `uptake=(26.6;45.5;Inf)` <dbl>

# Overlapping trapezoidal fuzzy sets (Ruspini condition)
partition(CO2, conc:uptake, .method = "triangle", .breaks = 3,
          .span = 2, .inc = 2)
#> # A tibble: 84 × 9
#>    Plant Type   Treatment  `conc=(-Inf;95;276;457)` `conc=(276;457;638;819)`
#>    <ord> <fct>  <fct>                         <dbl>                    <dbl>
#>  1 Qn1   Quebec nonchilled                    1                        0    
#>  2 Qn1   Quebec nonchilled                    1                        0    
#>  3 Qn1   Quebec nonchilled                    1                        0    
#>  4 Qn1   Quebec nonchilled                    0.591                    0.409
#>  5 Qn1   Quebec nonchilled                    0                        1    
#>  6 Qn1   Quebec nonchilled                    0                        0.796
#>  7 Qn1   Quebec nonchilled                    0                        0    
#>  8 Qn2   Quebec nonchilled                    1                        0    
#>  9 Qn2   Quebec nonchilled                    1                        0    
#> 10 Qn2   Quebec nonchilled                    1                        0    
#> # ℹ 74 more rows
#> # ℹ 4 more variables: `conc=(638;819;1000;Inf)` <dbl>,
#> #   `uptake=(-Inf;7.7;15.3;22.8)` <dbl>, `uptake=(15.3;22.8;30.4;37.9)` <dbl>,
#> #   `uptake=(30.4;37.9;45.5;Inf)` <dbl>

# Different settings per column
CO2 |>
  partition(Plant:Treatment) |>
  partition(conc,
            .method = "raisedcos",
            .breaks = c(-Inf, 95, 175, 350, 675, 1000, Inf)) |>
  partition(uptake,
            .method = "triangle",
            .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf),
            .labels = c("low", "medium", "high"))
#> # A tibble: 84 × 24
#>    `Plant=Qn1` `Plant=Qn2` `Plant=Qn3` `Plant=Qc1` `Plant=Qc3` `Plant=Qc2`
#>    <lgl>       <lgl>       <lgl>       <lgl>       <lgl>       <lgl>      
#>  1 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  2 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  3 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  4 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  5 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  6 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  7 TRUE        FALSE       FALSE       FALSE       FALSE       FALSE      
#>  8 FALSE       TRUE        FALSE       FALSE       FALSE       FALSE      
#>  9 FALSE       TRUE        FALSE       FALSE       FALSE       FALSE      
#> 10 FALSE       TRUE        FALSE       FALSE       FALSE       FALSE      
#> # ℹ 74 more rows
#> # ℹ 18 more variables: `Plant=Mn3` <lgl>, `Plant=Mn2` <lgl>, `Plant=Mn1` <lgl>,
#> #   `Plant=Mc2` <lgl>, `Plant=Mc3` <lgl>, `Plant=Mc1` <lgl>,
#> #   `Type=Quebec` <lgl>, `Type=Mississippi` <lgl>,
#> #   `Treatment=nonchilled` <lgl>, `Treatment=chilled` <lgl>,
#> #   `conc=(-Inf;95;175)` <dbl>, `conc=(95;175;350)` <dbl>,
#> #   `conc=(175;350;675)` <dbl>, `conc=(350;675;1000)` <dbl>, …
```
