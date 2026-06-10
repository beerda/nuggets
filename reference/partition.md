# Convert data-frame columns into Boolean or fuzzy predicates

Transform selected columns of a data frame into Boolean predicates
(logical indicator columns) or fuzzy predicates (numeric membership
degrees between 0 and 1), while leaving all unselected columns
unchanged.

The function is a general-purpose transformation utility, but it is
primarily intended as a preprocessing step for predicate-based pattern
discovery with
[`dig()`](https://beerda.github.io/nuggets/reference/dig.md) and related
functions such as
[`dig_correlations()`](https://beerda.github.io/nuggets/reference/dig_correlations.md),
[`dig_paired_baseline_contrasts()`](https://beerda.github.io/nuggets/reference/dig_paired_baseline_contrasts.md),
and
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

Depending on the type of each selected column, `partition()` creates one
or more derived columns:

- **logical** columns become predicates for `TRUE` and `FALSE`;

- **factor** columns become predicates for selected subsets of levels;

- **numeric** columns are transformed according to `.method` into dummy,
  crisp, or fuzzy predicates.

The selectors supplied in `.what` and `...` are combined using standard
tidyselect rules. Duplicate selections are removed by the selection
mechanism. Selection may be empty; in that case, `.data` is returned
unchanged as a tibble.

Generated columns are appended after the retained original columns. By
default, the original selected columns are removed (`.keep = FALSE`);
unselected columns are always preserved.

Predicate names are sanitized to make them suitable as column names.
Sanitization is applied to original column names and to individual
factor level names.

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
  .subsets = 1,
  .right = TRUE,
  .span = 1,
  .inc = 1
)
```

## Arguments

- .data:

  A data frame to be transformed.

- .what:

  A tidyselect expression selecting columns to transform.

- ...:

  Additional tidyselect expressions selecting more columns. All
  selectors from `.what` and `...` are combined using standard
  tidyselect behavior.

- .breaks:

  For numeric columns with `.method = "crisp"`, `"triangle"`, or
  `"raisedcos"`, either:

  - a single integer, interpreted as the number of output intervals
    (`"crisp"`) or fuzzy sets (`"triangle"`, `"raisedcos"`), or

  - a numeric vector of breakpoints.

  Ignored for logical columns, factor columns, and numeric columns with
  `.method = "dummy"`. If `.method != "dummy"` for a numeric column and
  `.breaks` is `NULL`, an error is raised.

- .labels:

  Optional character vector used to name numeric interval or fuzzy
  predicates. If `NULL`, labels are generated automatically.

  Used only for numeric columns with `.method = "crisp"`, `"triangle"`,
  or `"raisedcos"`. Ignored otherwise.

- .na:

  If `TRUE`, add a logical predicate `x=NA` for each transformed source
  column that contains at least one missing value.

- .keep:

  If `TRUE`, keep the original selected columns in the output. If
  `FALSE`, remove them after transformation. Unselected columns are
  always preserved.

- .method:

  Transformation method for selected numeric columns:

  - `"dummy"` – treat numeric values as ordered categories and create
    logical predicates;

  - `"crisp"` – create logical interval predicates;

  - `"triangle"` – create fuzzy predicates with linear slopes;

  - `"raisedcos"` – create fuzzy predicates with cosine-smoothed slopes.

  Ignored for logical and factor columns.

- .style:

  Method used to compute breakpoints when `.method = "crisp"` and
  `.breaks` is a single integer. Supported values correspond to methods
  in
  [`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html),
  e.g., `"equal"`, `"quantile"`, `"kmeans"`, `"sd"`, `"hclust"`,
  `"bclust"`, `"fisher"`, `"jenks"`, `"dpih"`, `"headtails"`,
  `"maximum"`, `"box"`. Defaults to `"equal"`.

  Ignored for logical columns, factor columns, numeric columns with
  `.method = "dummy"`, and numeric columns where `.breaks` is a vector.

- .style_params:

  A named list of additional parameters passed to the breakpoint
  computation method specified by `.style`.

  Used only when `.method = "crisp"` and `.breaks` is a single integer.

- .subsets:

  For factor columns, and for numeric columns with `.method = "dummy"`,
  an integer vector specifying the sizes of level subsets for which
  predicates should be created.

  For unordered factors, all subsets of the requested sizes are created.
  For ordered factors, and for numeric columns with `.method = "dummy"`,
  only subsets of consecutive values are created.

  Subset sizes equal to the total number of available levels are
  rejected, because they would produce a predicate that is always `TRUE`
  for all non-missing values.

  Ignored for logical columns and for numeric columns with
  `.method = "crisp"`, `"triangle"`, or `"raisedcos"`.

- .right:

  For numeric columns with `.method = "crisp"`, whether intervals are
  right-closed and left-open (`TRUE`) or left-closed and right-open
  (`FALSE`). Ignored otherwise.

- .span:

  For numeric columns:

  - with `.method = "crisp"`, the number of consecutive elementary
    intervals merged into one predicate;

  - with `.method = "triangle"` or `"raisedcos"`, controls whether fuzzy
    predicates are triangular (`.span = 1`) or trapezoidal
    (`.span > 1`).

  Ignored for logical columns, factor columns, and numeric columns with
  `.method = "dummy"`.

- .inc:

  For numeric columns with `.method = "crisp"`, `"triangle"`, or
  `"raisedcos"`, the number of break positions by which the construction
  window is shifted between successive predicates.

  Ignored for logical columns, factor columns, and numeric columns with
  `.method = "dummy"`.

## Value

A tibble in which selected columns have been replaced or supplemented by
generated Boolean or fuzzy predicates.

If `.keep = FALSE`, the original selected columns are removed. If
`.keep = TRUE`, they are retained. Unselected columns are always
preserved. Generated predicate columns are appended after the retained
original columns.

## Details

`partition()` converts selected variables into a predicate
representation useful for searching for relationships, associations, and
other patterns.

For logical and factor inputs, the result consists of logical columns.
For numeric inputs, the result depends on `.method`:

- `"dummy"` creates logical predicates for observed numeric values
  treated as ordered categories;

- `"crisp"` creates logical interval predicates;

- `"triangle"` and `"raisedcos"` create numeric membership degrees in
  \\\[0,1\]\\.

Missing values do not belong to ordinary generated predicates. If
`.na = TRUE` and a transformed source column contains at least one
missing value, an additional logical predicate `x=NA` is added.

For numeric inputs other than `.method = "dummy"`, `.breaks` must be
supplied. If it is a numeric vector, it is sorted automatically.

## Logical columns

A logical column `x` is expanded into two logical predicates:

- `x=T` for rows where `x` is `TRUE`;

- `x=F` for rows where `x` is `FALSE`.

Missing values are excluded from both predicates. If `.na = TRUE` and
the column contains missing values, `x=NA` is added.

For logical columns, `.breaks`, `.labels`, `.method`, `.style`,
`.style_params`, `.subsets`, `.right`, `.span`, and `.inc` are ignored.

## Factor columns

A factor column is expanded into logical predicates representing subsets
of its levels. The subset sizes are controlled by `.subsets`.

For an **unordered** factor, all subsets of the requested sizes are
created. For an **ordered** factor, only subsets formed by consecutive
levels are created.

For example, if `x` has levels `a`, `b`, `c`, `d`:

- `.subsets = 1` creates predicates for `a`, `b`, `c`, and `d`;

- `.subsets = 2` creates all pairs if `x` is unordered;

- `.subsets = 2` creates only `a,b`, `b,c`, `c,d` if `x` is ordered.

Subset sizes equal to the total number of levels are rejected, because
they would produce a predicate that is always `TRUE` for all non-missing
values.

If `.na = TRUE` and the factor contains missing values, `x=NA` is added.

For factor columns, `.breaks`, `.labels`, `.method`, `.style`,
`.style_params`, `.right`, `.span`, and `.inc` are ignored.

## Numeric columns with `.method = "dummy"`

A numeric column is treated as an ordered categorical variable with one
category for each observed value, and is then partitioned like an
ordered factor.

Thus, `.subsets = 1` creates predicates for individual values,
`.subsets = 2` creates predicates for consecutive pairs of values, and
so on.

This method can generate many predicates when the column has many
distinct values.

If `.na = TRUE` and the column contains missing values, `x=NA` is added.

For numeric columns with `.method = "dummy"`, `.breaks`, `.labels`,
`.style`, `.style_params`, `.right`, `.span`, and `.inc` are ignored.

## Crisp transformation of numeric data

For `.method = "crisp"`, a numeric column is transformed into logical
predicates representing intervals.

If `.breaks` is a single integer, it specifies the number of output
intervals. Breakpoints are computed automatically according to `.style`
and `.style_params`, and the outermost intervals are extended to `-Inf`
and `Inf`.

If `.breaks` is a numeric vector, it directly specifies the sequence of
break boundaries used to construct the interval predicates.

Supported values of `.style` correspond to methods in
[`classInt::classIntervals()`](https://r-spatial.github.io/classInt/reference/classIntervals.html):

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

The argument `.right` controls interval closure:

- if `TRUE`, intervals are left-open and right-closed, e.g. \\(1;3\]\\;

- if `FALSE`, intervals are left-closed and right-open, e.g. \\\[1;3)\\.

The argument `.span` controls how many consecutive elementary intervals
are merged into each predicate. The argument `.inc` controls by how many
break positions the construction window is shifted between successive
predicates.

With `.span = 1` and `.inc = 1`, the resulting intervals are consecutive
and non-overlapping. Larger `.span` values produce wider, overlapping
intervals; larger `.inc` values skip some possible windows.

## Fuzzy transformation of numeric data

For `.method = "triangle"` or `.method = "raisedcos"`, a numeric column
is transformed into fuzzy predicates represented by membership degrees
in \\\[0,1\]\\.

If `.breaks` is a single integer, it specifies the number of fuzzy sets.
If `.breaks` is a numeric vector, it specifies the sequence of boundary
points from which fuzzy predicates are constructed.

The argument `.span` controls shape:

- with `.span = 1`, predicates are triangular (`"triangle"`) or
  raised-cosine (`"raisedcos"`);

- with `.span > 1`, predicates are trapezoidal, with a rising edge, a
  plateau, and a falling edge.

The argument `.inc` controls by how many break positions the
construction window is shifted between successive predicates.

The method `"triangle"` uses linear slopes; `"raisedcos"` uses
cosine-smoothed slopes.

If `.breaks` includes `-Inf` or `Inf`, the corresponding boundary
predicates become open-ended.

## Author

Michal Burda

## Examples

``` r
# Logical column -> predicates for TRUE and FALSE
x <- tibble::tibble(a = c(TRUE, FALSE, NA, TRUE))
partition(x, a)
#> # A tibble: 4 × 3
#>   `a=T` `a=F` `a=NA`
#>   <lgl> <lgl> <lgl> 
#> 1 TRUE  FALSE FALSE 
#> 2 FALSE TRUE  FALSE 
#> 3 FALSE FALSE TRUE  
#> 4 TRUE  FALSE FALSE 

# Factor column -> predicates for individual levels
x <- tibble::tibble(a = factor(c("low", "medium", "high", NA)))
partition(x, a)
#> # A tibble: 4 × 4
#>   `a=high` `a=low` `a=medium` `a=NA`
#>   <lgl>    <lgl>   <lgl>      <lgl> 
#> 1 FALSE    TRUE    FALSE      FALSE 
#> 2 FALSE    FALSE   TRUE       FALSE 
#> 3 TRUE     FALSE   FALSE      FALSE 
#> 4 FALSE    FALSE   FALSE      TRUE  

# Unordered factor -> predicates for all pairs of levels
x <- tibble::tibble(a = factor(c("a", "b", "c", "a")))
partition(x, a, .subsets = 2)
#> # A tibble: 4 × 3
#>   `a=a,b` `a=a,c` `a=b,c`
#>   <lgl>   <lgl>   <lgl>  
#> 1 TRUE    TRUE    FALSE  
#> 2 TRUE    FALSE   TRUE   
#> 3 FALSE   TRUE    TRUE   
#> 4 TRUE    TRUE    FALSE  

# Ordered factor -> only consecutive subsets are created
x <- tibble::tibble(a = ordered(c("low", "medium", "high", "medium"),
                                levels = c("low", "medium", "high")))
partition(x, a, .subsets = 2)
#> # A tibble: 4 × 2
#>   `a=low,medium` `a=medium,high`
#>   <lgl>          <lgl>          
#> 1 TRUE           FALSE          
#> 2 TRUE           TRUE           
#> 3 FALSE          TRUE           
#> 4 TRUE           TRUE           

# Keep original selected columns
partition(CO2, Plant, .keep = TRUE)
#> # A tibble: 84 × 17
#>    Plant Type   Treatment   conc uptake `Plant=Qn1` `Plant=Qn2` `Plant=Qn3`
#>    <ord> <fct>  <fct>      <dbl>  <dbl> <lgl>       <lgl>       <lgl>      
#>  1 Qn1   Quebec nonchilled    95   16   TRUE        FALSE       FALSE      
#>  2 Qn1   Quebec nonchilled   175   30.4 TRUE        FALSE       FALSE      
#>  3 Qn1   Quebec nonchilled   250   34.8 TRUE        FALSE       FALSE      
#>  4 Qn1   Quebec nonchilled   350   37.2 TRUE        FALSE       FALSE      
#>  5 Qn1   Quebec nonchilled   500   35.3 TRUE        FALSE       FALSE      
#>  6 Qn1   Quebec nonchilled   675   39.2 TRUE        FALSE       FALSE      
#>  7 Qn1   Quebec nonchilled  1000   39.7 TRUE        FALSE       FALSE      
#>  8 Qn2   Quebec nonchilled    95   13.6 FALSE       TRUE        FALSE      
#>  9 Qn2   Quebec nonchilled   175   27.3 FALSE       TRUE        FALSE      
#> 10 Qn2   Quebec nonchilled   250   37.1 FALSE       TRUE        FALSE      
#> # ℹ 74 more rows
#> # ℹ 9 more variables: `Plant=Qc1` <lgl>, `Plant=Qc3` <lgl>, `Plant=Qc2` <lgl>,
#> #   `Plant=Mn3` <lgl>, `Plant=Mn2` <lgl>, `Plant=Mn1` <lgl>, `Plant=Mc2` <lgl>,
#> #   `Plant=Mc3` <lgl>, `Plant=Mc1` <lgl>

# Suppress explicit NA predicate
x <- tibble::tibble(a = c(TRUE, FALSE, NA))
partition(x, a, .na = FALSE)
#> # A tibble: 3 × 2
#>   `a=T` `a=F`
#>   <lgl> <lgl>
#> 1 TRUE  FALSE
#> 2 FALSE TRUE 
#> 3 FALSE FALSE

# Numeric data treated as ordered categories
x <- tibble::tibble(a = c(1, 2, 2, 3, 4))
partition(x, a, .method = "dummy")
#> # A tibble: 5 × 4
#>   `a=1` `a=2` `a=3` `a=4`
#>   <lgl> <lgl> <lgl> <lgl>
#> 1 TRUE  FALSE FALSE FALSE
#> 2 FALSE TRUE  FALSE FALSE
#> 3 FALSE TRUE  FALSE FALSE
#> 4 FALSE FALSE TRUE  FALSE
#> 5 FALSE FALSE FALSE TRUE 

# Numeric data treated as ordered categories with consecutive pairs
partition(x, a, .method = "dummy", .subsets = 2)
#> # A tibble: 5 × 3
#>   `a=1,2` `a=2,3` `a=3,4`
#>   <lgl>   <lgl>   <lgl>  
#> 1 TRUE    FALSE   FALSE  
#> 2 TRUE    TRUE    FALSE  
#> 3 TRUE    TRUE    FALSE  
#> 4 FALSE   TRUE    TRUE   
#> 5 FALSE   FALSE   TRUE   

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

# Crisp transformation using Lloyd algorithm for k-means breakpoints
partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "kmeans",
          .style_params = list(algorithm = "Lloyd"))
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(-Inf;300]` `conc=(300;588]`
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
#> # ℹ 2 more variables: `conc=(588;838]` <lgl>, `conc=(838;Inf]` <lgl>

# Crisp transformation with manually specified breaks
partition(CO2, conc, .method = "crisp",
          .breaks = c(-Inf, 200, 500, 800, Inf))
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(-Inf;200]` `conc=(200;500]`
#>    <ord> <fct>  <fct>       <dbl> <lgl>             <lgl>           
#>  1 Qn1   Quebec nonchilled   16   TRUE              FALSE           
#>  2 Qn1   Quebec nonchilled   30.4 TRUE              FALSE           
#>  3 Qn1   Quebec nonchilled   34.8 FALSE             TRUE            
#>  4 Qn1   Quebec nonchilled   37.2 FALSE             TRUE            
#>  5 Qn1   Quebec nonchilled   35.3 FALSE             TRUE            
#>  6 Qn1   Quebec nonchilled   39.2 FALSE             FALSE           
#>  7 Qn1   Quebec nonchilled   39.7 FALSE             FALSE           
#>  8 Qn2   Quebec nonchilled   13.6 TRUE              FALSE           
#>  9 Qn2   Quebec nonchilled   27.3 TRUE              FALSE           
#> 10 Qn2   Quebec nonchilled   37.1 FALSE             TRUE            
#> # ℹ 74 more rows
#> # ℹ 2 more variables: `conc=(500;800]` <lgl>, `conc=(800;Inf]` <lgl>

# Crisp transformation with overlapping intervals
partition(CO2, conc, .method = "crisp",
          .breaks = c(1, 3, 5, 7, 9, 11),
          .span = 2, .inc = 1)
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=(1;5]` `conc=(3;7]` `conc=(5;9]`
#>    <ord> <fct>  <fct>       <dbl> <lgl>        <lgl>        <lgl>       
#>  1 Qn1   Quebec nonchilled   16   FALSE        FALSE        FALSE       
#>  2 Qn1   Quebec nonchilled   30.4 FALSE        FALSE        FALSE       
#>  3 Qn1   Quebec nonchilled   34.8 FALSE        FALSE        FALSE       
#>  4 Qn1   Quebec nonchilled   37.2 FALSE        FALSE        FALSE       
#>  5 Qn1   Quebec nonchilled   35.3 FALSE        FALSE        FALSE       
#>  6 Qn1   Quebec nonchilled   39.2 FALSE        FALSE        FALSE       
#>  7 Qn1   Quebec nonchilled   39.7 FALSE        FALSE        FALSE       
#>  8 Qn2   Quebec nonchilled   13.6 FALSE        FALSE        FALSE       
#>  9 Qn2   Quebec nonchilled   27.3 FALSE        FALSE        FALSE       
#> 10 Qn2   Quebec nonchilled   37.1 FALSE        FALSE        FALSE       
#> # ℹ 74 more rows
#> # ℹ 1 more variable: `conc=(7;11]` <lgl>

# Crisp transformation with left-closed, right-open intervals
partition(CO2, conc, .method = "crisp", .breaks = 4, .right = FALSE)
#> # A tibble: 84 × 8
#>    Plant Type   Treatment  uptake `conc=[-Inf;321)` `conc=[321;548)`
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
#> # ℹ 2 more variables: `conc=[548;774)` <lgl>, `conc=[774;Inf)` <lgl>

# Fuzzy triangular transformation
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

# Raised-cosine fuzzy predicates
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

# Trapezoidal fuzzy predicates
partition(CO2, conc:uptake, .method = "triangle", .breaks = 3, .span = 2)
#> # A tibble: 84 × 9
#>    Plant Type   Treatment  `conc=(-Inf;95;397;698)` `conc=(95;397;698;1000)`
#>    <ord> <fct>  <fct>                         <dbl>                    <dbl>
#>  1 Qn1   Quebec nonchilled                   1                         0    
#>  2 Qn1   Quebec nonchilled                   1                         0.265
#>  3 Qn1   Quebec nonchilled                   1                         0.513
#>  4 Qn1   Quebec nonchilled                   1                         0.844
#>  5 Qn1   Quebec nonchilled                   0.658                     1    
#>  6 Qn1   Quebec nonchilled                   0.0764                    1    
#>  7 Qn1   Quebec nonchilled                   0                         0    
#>  8 Qn2   Quebec nonchilled                   1                         0    
#>  9 Qn2   Quebec nonchilled                   1                         0.265
#> 10 Qn2   Quebec nonchilled                   1                         0.513
#> # ℹ 74 more rows
#> # ℹ 4 more variables: `conc=(397;698;1000;Inf)` <dbl>,
#> #   `uptake=(-Inf;7.7;20.3;32.9)` <dbl>, `uptake=(7.7;20.3;32.9;45.5)` <dbl>,
#> #   `uptake=(20.3;32.9;45.5;Inf)` <dbl>

# Overlapping trapezoidal fuzzy predicates (Ruspini condition)
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

# Fuzzy transformation with manually specified breaks
partition(CO2, uptake,
          .method = "triangle",
          .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf))
#> # A tibble: 84 × 7
#>    Plant Type   Treatment   conc `uptake=(-Inf;7.7;28.3)` uptake=(7.7;28.3;45.…¹
#>    <ord> <fct>  <fct>      <dbl>                    <dbl>                  <dbl>
#>  1 Qn1   Quebec nonchilled    95                   0.597                   0.403
#>  2 Qn1   Quebec nonchilled   175                   0                       0.878
#>  3 Qn1   Quebec nonchilled   250                   0                       0.622
#>  4 Qn1   Quebec nonchilled   350                   0                       0.483
#>  5 Qn1   Quebec nonchilled   500                   0                       0.593
#>  6 Qn1   Quebec nonchilled   675                   0                       0.366
#>  7 Qn1   Quebec nonchilled  1000                   0                       0.337
#>  8 Qn2   Quebec nonchilled    95                   0.714                   0.286
#>  9 Qn2   Quebec nonchilled   175                   0.0485                  0.951
#> 10 Qn2   Quebec nonchilled   250                   0                       0.488
#> # ℹ 74 more rows
#> # ℹ abbreviated name: ¹​`uptake=(7.7;28.3;45.5)`
#> # ℹ 1 more variable: `uptake=(28.3;45.5;Inf)` <dbl>

# Fuzzy transformation with custom labels
partition(CO2, uptake,
          .method = "triangle",
          .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf),
          .labels = c("low", "medium", "high"))
#> # A tibble: 84 × 7
#>    Plant Type   Treatment   conc `uptake=low` `uptake=medium` `uptake=high`
#>    <ord> <fct>  <fct>      <dbl>        <dbl>           <dbl>         <dbl>
#>  1 Qn1   Quebec nonchilled    95       0.597            0.403         0    
#>  2 Qn1   Quebec nonchilled   175       0                0.878         0.122
#>  3 Qn1   Quebec nonchilled   250       0                0.622         0.378
#>  4 Qn1   Quebec nonchilled   350       0                0.483         0.517
#>  5 Qn1   Quebec nonchilled   500       0                0.593         0.407
#>  6 Qn1   Quebec nonchilled   675       0                0.366         0.634
#>  7 Qn1   Quebec nonchilled  1000       0                0.337         0.663
#>  8 Qn2   Quebec nonchilled    95       0.714            0.286         0    
#>  9 Qn2   Quebec nonchilled   175       0.0485           0.951         0    
#> 10 Qn2   Quebec nonchilled   250       0                0.488         0.512
#> # ℹ 74 more rows

# Different settings can be applied in successive calls
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
