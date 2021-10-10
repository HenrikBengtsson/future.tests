# future.tests

## Version 0.3.0 [2021-10-09]

### New Tests

 * Assert that `future()` doesn't change the RNG kind.
 
 * Assert that `future(..., conditions = character(0L))` muffles all conditions.

### New Features

 * For robustness, using explicit stringsAsFactors=FALSE internally.

 * `evaluate_expr()`, which is used for running all tests, now reset options,
   environment variables, the RNG kind, and the random seed afterward to
   what it was before being called.

 * Added a package vignettes.
 
### Bug Fixes

 * Tests on `resolve()` would use deprecated argument `value`.
 

## Version 0.2.1 [2020-03-19]

### CRAN Re-submission Requests

 * Update the package description to use single quotes.

 * Add example to `check()`.


## Version 0.2.0 [2020-03-13]

 * First version released on CRAN.


## Version 0.1.1 [2020-01-06]

### Bug Fixes

 * Assert that `resolved()` will launch lazy futures.


## Version 0.1.0 [2020-01-03]

### New Features

 * In non-interactive mode, `check()` will quit R with an exit code that
   reflects whether all tests passed (0) or not (1).

 * `check()` gained arguments so that it can be easily called from R too.



## Version 0.0.0-9000 [2017-05-16]

 * Created package stub.
