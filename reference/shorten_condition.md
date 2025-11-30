# Shorten predicates within conditions

This function takes a character vector of conditions and shortens the
predicates within each condition according to a specified method.

## Usage

``` r
shorten_condition(x, method = "letters")
```

## Arguments

- x:

  A character vector of conditions, each formatted as a string (e.g.,
  `"{a=1,b=100,c=3}"`).

- method:

  A character scalar specifying the shortening method. Must be one of
  `"letters"`, `"abbrev4"`, `"abbrev8"`, or `"none"`. Defaults to
  `"letters"`.

## Value

A character vector of conditions with predicates shortened according to
the specified method.

## Details

Each element of `x` must be a condition formatted as a string, e.g.
`"{a=1,b=100,c=3}"` (see
[`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md)).
The function then shortens the predicates in each condition based on the
selected `method`:

- `"letters"`: predicates are replaced with single letters from the
  English alphabet, starting with `A` for the first distinct predicate;

- `"abbrev4"`: predicates are abbreviated to at most 4 characters using
  [`base::abbreviate()`](https://rdrr.io/r/base/abbreviate.html);

- `"abbrev8"`: predicates are abbreviated to at most 8 characters using
  [`base::abbreviate()`](https://rdrr.io/r/base/abbreviate.html);

- `"none"`: no shortening is applied; predicates remain unchanged.

Predicate shortening is useful for visualization or reporting,
especially when original predicate names are long or complex. Note that
shortening is applied consistently across all conditions in `x`.

## See also

[`format_condition()`](https://beerda.github.io/nuggets/reference/format_condition.md),
[`parse_condition()`](https://beerda.github.io/nuggets/reference/parse_condition.md),
[`is_condition()`](https://beerda.github.io/nuggets/reference/is_condition.md),
[`remove_ill_conditions()`](https://beerda.github.io/nuggets/reference/remove_ill_conditions.md),
[`base::abbreviate()`](https://rdrr.io/r/base/abbreviate.html)

## Author

Michal Burda

## Examples

``` r
shorten_condition(c("{a=1,b=100,c=3}", "{a=2}", "{b=100,c=3}"),
                  method = "letters")
#> [1] "{A,B,C}" "{D}"     "{B,C}"  

shorten_condition(c("{helloWorld=1}", "{helloWorld=2}", "{c=3,helloWorld=1}"),
                  method = "abbrev4")
#> [1] "{hllW=1}"     "{hllW=2}"     "{c=3,hllW=1}"

shorten_condition(c("{helloWorld=1}", "{helloWorld=2}", "{c=3,helloWorld=1}"),
                  method = "abbrev8")
#> [1] "{hellWrld=1}"     "{hellWrld=2}"     "{c=3,hellWrld=1}"

shorten_condition(c("{helloWorld=1}", "{helloWorld=2}"),
                  method = "none")
#> [1] "{helloWorld=1}" "{helloWorld=2}"
```
