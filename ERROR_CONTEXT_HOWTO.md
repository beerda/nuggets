# NA

Internal functions:

- the name must start with “.”
- the function must not be exported
- the last argument of the function may be the `error_context` object,
  which is a list of the following elements:
  - names of arguments that appear in error messages initialized with
    the call of `caller_arg()` (e.g. `arg_x = caller_arg(x)`)
  - the `call` object pointing to caller’s environment,
    `call = caller_env()`
- see `.extract_cols()` for an example

Exported functions:

- these functions may be used by the user
- the function must be exported
- the last argument of the function may be the `error_context` object,
  which is a list of the following elements:
  - names of arguments that appear in error messages initialized to a
    string constant equal to a name of the argument (e.g. `arg_x = "x"`)
  - the `call` object pointing to the current environment,
    `call = current_env()`
- see
  [`var_grid()`](https://beerda.github.io/nuggets/reference/var_grid.md)
  for an example
