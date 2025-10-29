# Copilot Instructions for nuggets

## Project Overview

`nuggets` is an R package providing a framework for systematic exploration of association rules, contrast patterns, emerging patterns, subgroup discovery, and conditional correlations. The package supports both crisp (Boolean) and fuzzy data, with performance-critical code implemented in C++17.

## Repository Structure

- `R/` - R source code with roxygen2 documentation
- `src/` - C++17 source code using Rcpp, RcppThread, and Boost headers
- `tests/testthat/` - Unit tests using testthat framework
- `man/` - Generated documentation (auto-generated, do not edit manually)
- `vignettes/` - Package vignettes
- `inst/` - Installed files
- `.github/workflows/` - CI/CD workflows for R CMD check, test coverage, pkgdown

## Development Setup

### Prerequisites
- R >= 4.1.0
- C++17 compatible compiler
- Required R packages: devtools, testthat, roxygen2

### Building and Testing
```r
# Install dependencies
devtools::install_deps(dependencies = TRUE)

# Build documentation
devtools::document()

# Run tests
devtools::test()

# Run R CMD check
devtools::check()

# Build package
devtools::build()
```

## Coding Standards

### R Code

1. **Documentation**: All exported functions must have complete roxygen2 documentation including:
   - `@title` and description
   - `@param` for all parameters
   - `@return` for return values
   - `@examples` with working examples
   - `@export` for exported functions

2. **Naming Conventions**:
   - Functions: snake_case (e.g., `dig_associations()`, `is_condition()`)
   - Internal functions: prefix with `.` (e.g., `.extract_cols()`)
   - Variables: snake_case

3. **Error Handling**:
   - Use `cli` package for error messages
   - The `error_context` parameter, when used, must always be the **last** argument
   - Internal functions: last argument may be `error_context` list with:
     - Argument names initialized with `caller_arg()` (e.g., `arg_x = caller_arg(x)`)
     - `call = caller_env()`
     - See `.extract_cols()` for example
   - Exported functions: last argument may be `error_context` list with:
     - Argument names as string constants (e.g., `arg_x = "x"`)
     - `call = current_env()`
     - See `var_grid()` for example
   - See `ERROR_CONTEXT_HOWTO.md` for comprehensive documentation on error handling patterns

4. **Style**:
   - Use tidyverse style conventions
   - Indent with 4 spaces
   - Use `<-` for assignment
   - Use pipe operator `|>` (base R) or `%>%` (magrittr) consistently

### C++ Code

1. **Standards**:
   - C++20 features used in code (via `// [[Rcpp::plugins(cpp20)]]` in src/common.h)
   - Note: DESCRIPTION specifies C++17 as SystemRequirements for broader compatibility
   - Use Rcpp for R/C++ interface
   - Use RcppThread for parallel processing
   - Use Boost headers (BH package)

2. **Structure**:
   - Headers in `src/*.h`
   - Implementation in `src/*.cpp`
   - Subdirectories for logical modules (e.g., `src/dig/`, `src/antichain/`)

3. **Documentation**:
   - Use Rcpp attributes for exported functions: `// [[Rcpp::export]]`
   - Add roxygen2 documentation above exported functions
   - Internal functions should have clear comments

4. **Testing**:
   - C++ unit tests use testthat framework
   - Test files: `src/test-*.cpp`
   - Tests run as part of R package tests

5. **Debug Mode**:
   - Debug flags in `src/common.h`
   - Must be disabled before release (see RELEASE_HOWTO.md)

### Testing

1. **Test Structure**:
   - Use testthat framework (edition 3)
   - Test files in `tests/testthat/` with `test-*.R` naming
   - Group related tests with `test_that()` blocks

2. **Coverage**:
   - Aim for high test coverage
   - CI runs test coverage checks automatically
   - Use `devtools::test_coverage()` locally

3. **Test Naming**:
   - Descriptive test names explaining what is being tested
   - Example: `test_that("numeric matrix", { ... })`

## Dependencies

### R Package Dependencies
- Runtime: classInt, cli, DT, fastmatch, generics, ggplot2, grid, htmltools, lifecycle, methods, purrr, Rcpp, rlang, shiny, shinyjs, shinyWidgets, stats, stringr, tibble, tidyr, tidyselect, utils
- Build/Link: BH, cli, Rcpp, RcppThread, testthat
- Suggests: arules, dplyr, testthat, xml2, withr, knitr, rmarkdown

### Adding Dependencies
- Add to appropriate field in DESCRIPTION (Imports, Suggests, LinkingTo)
- Use `usethis::use_package()` helper functions
- Document why the dependency is needed

## Release Process

See RELEASE_HOWTO.md for detailed release checklist including:
1. Update version and date in DESCRIPTION
2. Update NEWS.md
3. Disable debug in src/common.h
4. Run spell check, rhub checks, and Windows/Mac checks
5. Use `devtools::release()`

## Deprecation Process

The package uses lifecycle for function deprecation:
1. New deprecation: `deprecate_soft()` - soft warning
2. Next version: replace with `deprecate_warn()` - warning
3. Final version: replace with `deprecate_stop()` - error, remove function body
4. Remove completely in next major version

## CI/CD Workflows

- **R-CMD-check**: Runs on push/PR to main/master/devel, tests on multiple OS and R versions
- **test-coverage**: Generates coverage reports via codecov
- **pkgdown**: Builds and deploys documentation site
- **rhub**: Additional platform testing

## Interactive Features

The package includes Shiny applications for interactive exploration:
- `explore()` - Main interactive exploration function
- Located in `R/explore-*.R` files
- Use shiny, shinyjs, shinyWidgets, DT for UI components

## Documentation

- Use roxygen2 for all documentation
- Run `devtools::document()` to regenerate man/*.Rd files
- README.md is generated from README.Rmd - edit the .Rmd file
- Vignettes in `vignettes/*.Rmd`
- Package website built with pkgdown

## Common Tasks

### Adding a New Function
1. Create function in appropriate R/*.R file
2. Add roxygen2 documentation
3. Export if public function: `@export`
4. Add tests in tests/testthat/test-*.R
5. Run `devtools::document()` to update NAMESPACE and man/
6. Run `devtools::test()` and `devtools::check()`

### Adding C++ Code
1. Add source in src/*.cpp or src/subdirectory/*.cpp
2. Update src/*.h headers as needed
3. Use `// [[Rcpp::export]]` for functions exposed to R
4. Run `Rcpp::compileAttributes()` to update RcppExports.cpp/R
5. Add tests in src/test-*.cpp or tests/testthat/
6. Test compilation with `devtools::load_all()`

### Fixing a Bug
1. Add a failing test that reproduces the bug
2. Fix the code
3. Verify test passes
4. Run full test suite: `devtools::test()`
5. Run R CMD check: `devtools::check()`

## Best Practices

1. **Never edit generated files**: NAMESPACE, man/*.Rd, RcppExports.cpp/R
2. **Always run tests**: Use `devtools::test()` frequently
3. **Check the package**: Run `devtools::check()` before committing significant changes
4. **Document as you code**: Add roxygen2 comments immediately
5. **Follow error context patterns**: See ERROR_CONTEXT_HOWTO.md
6. **Use existing patterns**: Study similar functions in the codebase before implementing new features
7. **Performance matters**: Consider both R and C++ implementations for performance-critical code
8. **Support both crisp and fuzzy**: Most functions should work with both logical and numeric [0,1] data
