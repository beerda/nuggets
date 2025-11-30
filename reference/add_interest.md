# Add additional interest measures for association rules

**\[experimental\]**

This function calculates various additional interest measures for
association rules based on their contingency table counts.

## Usage

``` r
# S3 method for class 'associations'
add_interest(x, measures = NULL, smooth_counts = 0, p = 0.5, ...)

add_interest(x, ...)
```

## Arguments

- x:

  A nugget of flavour `associations`, typically created with
  [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
  with argument `contingency_table = TRUE`.

- measures:

  A character vector specifying which interest measures to calculate. If
  `NULL` (the default), all supported measures are calculated. See the
  Details section for the list of supported measures.

- smooth_counts:

  A non-negative numeric value specifying the amount of Laplace
  smoothing to apply to the contingency table counts before calculating
  the interest measures. Default is `0` (no smoothing). Positive values
  add the specified amount to each of the counts (`pp`, `pn`, `np`,
  `nn`), which can help avoid issues with undefined measures due to zero
  counts. Use `smooth_counts = 1` for standard Laplace smoothing. Use
  `smooth_counts = 0.5` for Haldane-Anscombe smoothing, which is often
  used for odds ratio estimation and in chi-squared tests.

- p:

  A numeric value in the range `[0, 1]` representing the conditional
  probability of the consequent being true given that the antecedent is
  true. This parameter is used in the calculation of GUHA quantifiers
  `"lci"`, `"uci"`, `"dlci"`, `"duci"`, `"lce"`, and `"uce"`. The
  default value is `0.5`.

- ...:

  Currently unused.

## Value

An S3 object which is an instance of `associations` and `nugget` classes
and which is a tibble containing all the columns of the input nugget
`x`, plus additional columns for each of the requested interest
measures.

## Details

The input nugget object must contain the columns `pp` (positive
antecedent & positive consequent), `pn` (positive antecedent & negative
consequent), `np` (negative antecedent & positive consequent), and `nn`
(negative antecedent & negative consequent), representing the counts
from the contingency table. These columns are typically produced by
[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)
when the `contingency_table` argument is set to `TRUE`.

The supported interest measures that can be calculated include:

- Founded GUHA (General Unary Hypothesis Automaton) quantifiers:

  - `"fi"` - *Founded Implication*, which equals to the `"confidence"`
    measure calculated automatically by
    [`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md).

  - `"dfi"` - *Double Founded Implication* computed as \\pp / (pp + pn +
    np)\\

  - `"fe"` - *Founded Equivalence* computed as \\(pp + nn) / (pp + pn +
    np + nn)\\

- GUHA quantifiers based on binomial tests - these measures require the
  additional parameter `p`, which represents the conditional probability
  of the consequent being true given that the antecedent is true under
  the null hypothesis. The measures are computed as one-sided p-values
  from the Clopper-Pearson confidence interval for the binomial
  proportion:

  - `"lci"` - *Lower Critical Implication* computed as
    \\\sum\_{i=pp}^{pp+pn} \frac{(pp+pn)!}{i!(pp+pn-i)!} p^i
    (1-p)^{pp+pn-i}\\

  - `"uci"` - *Upper Critical Implication* computed as
    \\\sum\_{i=0}^{pp} \frac{(pp+pn)!}{i!(pp+pn-i)!} p^i
    (1-p)^{pp+pn-i}\\

  - `"dlci"` - *Double Lower Critical Implication* computed as
    \\\sum\_{i=pp}^{pp+pn+np} \frac{(pp+pn+np)!}{i!(pp+pn+np-i)!} p^i
    (1-p)^{pp+pn+np-i}\\

  - `"duci"` - *Double Upper Critical Implication* computed as
    \\\sum\_{i=0}^{pp} \frac{(pp+pn+np)!}{i!(pp+pn+np-i)!} p^i
    (1-p)^{pp+pn+np-i}\\

  - `"lce"` - *Lower Critical Equivalence* computed as
    \\\sum\_{i=pp}^{pp+pn+np+nn}
    \frac{(pp+pn+np+nn)!}{i!(pp+pn+np+nn-i)!} p^i
    (1-p)^{pp+pn+np+nn-i}\\

  - `"uce"` - *Upper Critical Equivalence* computed as
    \\\sum\_{i=0}^{pp} \frac{(pp+pn+np+nn)!}{i!(pp+pn+np+nn-i)!} p^i
    (1-p)^{pp+pn+np+nn-i}\\

- measures adopted from the `arules` package:

  - `"added_value"` - *Added Value*, see
    <https://mhahsler.github.io/arules/docs/measures#addedvalue> for
    details

  - `"casual_confidence"` - *Casual Confidence*, see
    <https://mhahsler.github.io/arules/docs/measures#casualconfidence>
    for details

  - `"casual_support"` - *Casual Support*, see
    <https://mhahsler.github.io/arules/docs/measures#casualsupport> for
    details

  - `"centered_confidence"` - *Centered Confidence*, see
    <https://mhahsler.github.io/arules/docs/measures#centeredconfidence>
    for details

  - `"certainty"` - *Certainty Factor*, see
    <https://mhahsler.github.io/arules/docs/measures#certainty> for
    details

  - `"collective_strength"` - *Collective Strength*, see
    <https://mhahsler.github.io/arules/docs/measures#collectivestrength>
    for details

  - `"confirmed_confidence"` - *Descriptive Confirmed Confidence*, see
    <https://mhahsler.github.io/arules/docs/measures#confirmedconfidence>
    for details

  - `"conviction"` - *Conviction*, see
    <https://mhahsler.github.io/arules/docs/measures#conviction> for
    details

  - `"cosine"` - *Cosine*, see
    <https://mhahsler.github.io/arules/docs/measures#cosine> for details

  - `"counterexample"` - *Example and Counter-Example Rate*, see
    <https://mhahsler.github.io/arules/docs/measures#counterexample> for
    details

  - `"doc"` - *Difference of Confidence*, see
    <https://mhahsler.github.io/arules/docs/measures#doc> for details

  - `"gini"` - *Gini Index*, see
    <https://mhahsler.github.io/arules/docs/measures#gini> for details

  - `"imbalance"` - *Imbalance Ratio*, see
    <https://mhahsler.github.io/arules/docs/measures#imbalance> for
    details

  - `"implication_index"` - *Implication Index*, see
    <https://mhahsler.github.io/arules/docs/measures#implicationindex>
    for details

  - `"importance"` - *Importance*, see
    <https://mhahsler.github.io/arules/docs/measures#importance> for
    details

  - `"j_measure"` - *J-Measure*, see
    <https://mhahsler.github.io/arules/docs/measures#jmeasure> for
    details

  - `"jaccard"` - *Jaccard Coefficient*, see
    <https://mhahsler.github.io/arules/docs/measures#jaccard> for
    details

  - `"kappa"` - *Kappa*, see
    <https://mhahsler.github.io/arules/docs/measures#kappa> for details

  - `"kulczynski"` - *Kulczynski*, see
    <https://mhahsler.github.io/arules/docs/measures#kulczynski> for
    details

  - `"lambda"` - *Lambda*, see
    <https://mhahsler.github.io/arules/docs/measures#lambda> for details

  - `"least_contradiction"` - *Least Contradiction*, see
    <https://mhahsler.github.io/arules/docs/measures#leastcontradiction>
    for details

  - `"lerman"` - *Lerman Similarity*, see
    <https://mhahsler.github.io/arules/docs/measures#lerman> for details

  - `"leverage"` - *Leverage*, see
    <https://mhahsler.github.io/arules/docs/measures#leverage> for
    details

  - `"maxconfidence"` - *Max Confidence*, see
    <https://mhahsler.github.io/arules/docs/measures#maxconfidence> for
    details

  - `"mutual_information"` - *Mutual Information*, see
    <https://mhahsler.github.io/arules/docs/measures#mutualinformation>
    for details

  - `"odds_ratio"` - *Odds Ratio*, see
    <https://mhahsler.github.io/arules/docs/measures#oddsratio> for
    details

  - `"phi"` - *Phi Correlation Coefficient*, see
    <https://mhahsler.github.io/arules/docs/measures#phi> for details

  - `"ralambondrainy"` - *Ralambondrainy*, see
    <https://mhahsler.github.io/arules/docs/measures#ralambondrainy> for
    details

  - `"relative_risk"` - *Relative Risk*, see
    <https://mhahsler.github.io/arules/docs/measures#relativerisk> for
    details

  - `"rule_power_factor"` - *Rule Power Factor*, see
    <https://mhahsler.github.io/arules/docs/measures#rulepowerfactor>
    for details

  - `"sebag"` - *Sebag-Schoenauer*, see
    <https://mhahsler.github.io/arules/docs/measures#sebag> for details

  - `"varying_liaison"` - *Varying Rates Liaison*, see
    <https://mhahsler.github.io/arules/docs/measures#varyingliaison> for
    details

  - `"yule_q"` - *Yule's Q*, see
    <https://mhahsler.github.io/arules/docs/measures#yuleq> for details

  - `"yule_y"` - *Yule's Y*, see
    <https://mhahsler.github.io/arules/docs/measures#yuley> for details

All the above measures are primarily intended for use with binary
(logical) data. While they can be computed for numerical data as well,
their interpretations may not be meaningful in that context - users
should exercise caution when applying these measures to non-binary data.

Many measures are based on the contingency table counts, and some may be
undefined for certain combinations of counts (e.g., division by zero).
This issue can be mitigated by applying smoothing using the
`smooth_counts` argument.

## See also

[`dig_associations()`](https://beerda.github.io/nuggets/reference/dig_associations.md)

## Author

Michal Burda

## Examples

``` r
d <- partition(mtcars, .breaks = 2)
rules <- dig_associations(d,
                          antecedent = !starts_with("mpg"),
                          consequent = starts_with("mpg"),
                          min_support = 0.3,
                          min_confidence = 0.8,
                          contingency_table = TRUE)
rules <- add_interest(rules,
                   measures = c("conviction", "leverage", "jaccard"))
```
