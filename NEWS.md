# Version 0.7.0 [2023-05-20]

## Bug Fixes

 * Tests asserting correctness of `nbrOfWorkers()` could produce an
   "invalid format '%d'; use format %f, %e, %g or %a for numeric
   objects" error when trying to produce an assertion error on
   `nbrOfWorkers()` having an incorrect value. This could happen if
   `nbrOfWorkers()` returned a non-integer value, e.g. `+Inf`.

 * Test asserting that the `workers` argument can be a function would
   not always work if testing with a hardcoded number of workers
   according to `plan()`.

 * Test asserting that the `workers` argument can be a function would
   not work if the backend's default value was non-numeric, e.g. the
   `cluster` backend defaults to the character vector
   `parallelly::availableWorkers()`.

 * Test asserting that lazy futures would be automatically launched
   and resolved relied on a legacy version of the Future API, where
   calling `resolved()` on a lazy future could leave it in a lazy
   state, which is no longer correct. A lazy future will always be
   launched if one calls `resolved()` on it.

 * Test asserting that the **ff** package worked across multiple
   futures assumed that the package is loaded automatically by the
   future, which it is not.  The could cause the test to fail for
   some future backends.


# Version 0.6.0 [2023-03-11]

## New Features

 * Now tests can be formally skipped by calling
   `future.tests::skip_test()` from within the test.  Skipped tests
   are counted and reported in the summary.
   
 * Now `check_plan()` outputs the reason for a test is being skipped.

 * Now `check_plan()` outputs also the error message, error class, the
   call, and any standard output, whenever there's is a test error.

 * Now `check_plan()` outputs also the test iteration index.

 * Add `Rscript -e future.tests::check --version`.

## Bug Fixes

 * Some tests assume that the future strategy tested has a `workers`
   argument, which is not true for all future backends.  For example,
   'sequential' does not take argument `workers`.  Previously, we
   avoided this problem by only testing if the evaluator inherited
   `multiprocess`, but that is not sufficient, e.g. upcoming
   `future.redis::redis` inherits `multiprocess`, but still does not
   have a `workers` argument.  Now we check for the `workers` argument
   instead.


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
