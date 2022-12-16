# Version 0.5.0 [2022-12-15]

## New Tests

 * Assert that none of `future()`, `run()`, `result()` and `value()`
   update the RNG state.


# Version 0.4.0 [2022-11-21]

## New Tests

 * Assert that `rm(a)` in a future expression only removes a local
   variable `a`, but never a global variable `a`.
   
 * Assert that packages **data.table** and **ff** are not affected
   when a future resets the R options on the worker when resolved.
   
 * Assert that a global that is a copy of a non-exported package
   object (e.g. `utils:::str2logical()`) is not dropped because it
   belongs to a package namespace.

 * Assert that `...` can be exported as a global to a future, and
   used as-is inside a function that does _not_ have `...` arguments.

## New Features

 * `check()` and `check_plan()` gained argument `local`, which is
   passed down to `run_test()`.

 * `check()` gained argument `envir`, which is passed down to
   `run_test()`.

## Bug Fixes

 * The TestResult class did not record whether the test was evaluated
   in a local environment or not.

 * A too strict internal assertion would give `Error in
   evaluate_expr(test$expr, envir = envir, local = FALSE, output =
   output, : identical(Sys.getenv(), old$envvars) is not TRUE` for R
   4.2.x and R-devel on MS Windows.  This was because it is not
   possible to remove environment variables on MS Windows; they can
   only be set to an empty value.
 

# Version 0.3.0 [2021-10-09]

## New Tests

 * Assert that `future()` doesn't change the RNG kind.
 
 * Assert that `future(..., conditions = character(0L))` muffles all
   conditions.

## New Features

 * For robustness, using explicit `stringsAsFactors = FALSE`
   internally.

 * `evaluate_expr()`, which is used for running all tests, now reset
   options, environment variables, the RNG kind, and the random seed
   afterward to what it was before being called.

 * Added a package vignettes.
 
## Bug Fixes

 * Tests on `resolve()` would use deprecated argument `value`.
 

# Version 0.2.1 [2020-03-19]

## CRAN Re-submission Requests

 * Update the package description to use single quotes.

 * Add example to `check()`.


# Version 0.2.0 [2020-03-13]

 * First version released on CRAN.


# Version 0.1.1 [2020-01-06]

## Bug Fixes

 * Assert that `resolved()` will launch lazy futures.


# Version 0.1.0 [2020-01-03]

## New Features

 * In non-interactive mode, `check()` will quit R with an exit code
   that reflects whether all tests passed (0) or not (1).

 * `check()` gained arguments so that it can be easily called from R
   too.


# Version 0.0.0-9000 [2017-05-16]

 * Created package stub.
