The **[future]** package defines the Future API which consists of a small number of functions for writing [R] code that can be evaluated either sequential or in parallel based a single setting without having to change anything in the code.  Parallelization can be done via one of many backends, e.g. via built-in multicore, multisession and cluster backends (based on the **parallel** package) or via third-party backends such as **[future.callr]** and **[future.batchtools]**.  The design motto of the Future API is:

> Write once, run anywhere

In order for such code to work regardless of which future backend the end-user choose, it is critical that the backend fully complies with the [Future API Backend Specification].  A future backend with a 100% compliance rate guarantees that the code will work equally well there as in sequential mode.

This R package - **[future.tests]** - provides a test suite for validation that a future backend complies with the Future API.

![](vignettes/imgs/screencast.gif)


## Validate a Future Backend

All future backends implementing the Future API should validate that they conform to the Future API.  This can be done using the **[future.tests]** package, which provides two API for running the tests.  The tests can be performed either from within R or from outside of R from the command line making it easy to include them package tests and in Continuous Integration (CI) pipelines.

### From Within R

```r
> results <- future.tests::check(plan = "multisession")
> exit_code <- attr(results, "exit_code")
> if (exit_code != 0) stop("One or more tests failed")
```

### From Outside R

```sh
$ Rscript -e future.tests::check --args --test-plan="multisession"
$ exit_code=$?
$ [[ exit_code -eq 0 ]] || { >&2 echo "One or more tests failed"; exit 1; }
```


[R]: https://www.r-project.org
[future]: https://cran.r-project.org/package=future
[future.callr]: https://cran.r-project.org/package=future.callr
[future.batchtools]: https://cran.r-project.org/package=future.batchtools
[future.tests]: https://cran.r-project.org/package=future.tests
[Future API Backend Specification]: https://future.futureverse.org/articles/future-6-future-api-backend-specification.html
