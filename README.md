

<div id="badges"><!-- pkgdown markup -->
<a href="https://CRAN.R-project.org/web/checks/check_results_future.tests.html"><img border="0" src="https://www.r-pkg.org/badges/version/future.tests" alt="CRAN check status"/></a> <a href="https://github.com/HenrikBengtsson/future.tests/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/HenrikBengtsson/future.tests/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>   <a href="https://ci.appveyor.com/project/HenrikBengtsson/future-tests"><img border="0" src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/future.tests?svg=true" alt="Build status"/></a> <a href="https://codecov.io/gh/HenrikBengtsson/future.tests"><img border="0" src="https://codecov.io/gh/HenrikBengtsson/future.tests/branch/develop/graph/badge.svg" alt="Coverage Status"/></a> <a href="https://lifecycle.r-lib.org/articles/stages.html"><img border="0" src="man/figures/lifecycle-maturing-blue.svg" alt="Life cycle: maturing"/></a>
<a href="https://www.r-consortium.org/projects/awarded-projects"><img border="0" src="man/figures/R_Consortium-logo-horizontal-white-purple-badge.svg" alt="R Consortium: ISC Project 2017-2"/></a>
</div>

# future.tests: Test Suite for 'Future API' Backends 

The **[future]** package defines the Future API which consists of a small number of functions for writing [R] code that can be evaluated either sequential or in parallel based a single setting without having to change anything in the code.  Parallelization can be done via one of many backends, e.g. via built-in multicore, multisession and cluster backends (based on the **parallel** package) or via third-party backends such as **[future.callr]** and **[future.batchtools]**.  The design motto of the Future API is:

> Write once, run anywhere

In order for such code to work regardless of which future backend the end-user choose, it is critical that the backend fully complies with the Future API.  A future backend with A 100% compliance rate guarantees that the code will work equally well there as in sequential mode.

This R package - **[future.tests]** - provides a test suite for validation that a future backend complies with the Future API.

![](man/figures/screencast.gif)


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
$ Rscript -e "future.tests::check" --args --test-plan="multisession"
$ exit_code=$?
$ [[ exit_code -eq 0 ]] || { >&2 echo "One or more tests failed"; exit 1; }
```

### Continuous Integration

We can use continuous integration (CI) services such as GitHub Action and Travis CI to automatically validate future backends via the **[future.tests]** test suite.

#### GitHub Actions

Here is an example of a `.github/workflow/future.tests.yaml` file that configures GitHub Actions to check several backends via the **future.tests** test suite via concurrent jobs.

```yaml
on: [push, pull_request]

name: future_tests

jobs:
  future_tests:
    if: "! contains(github.event.head_commit.message, '[ci skip]')"    

    runs-on: ubuntu-20.04

    name: future.plan=${{ matrix.future.plan }}

    strategy:
      fail-fast: false
      matrix:
        future:
          - { plan: 'cluster'                             }
          - { plan: 'multicore'                           }
          - { plan: 'multisession'                        }
          - { plan: 'sequential'                          }
          - { plan: 'future.batchtools::batchtools_local' }
          - { plan: 'future.callr::callr'                 }

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      RSPM: https://packagemanager.rstudio.com/cran/__linux__/focal/latest
      R_REMOTES_NO_ERRORS_FROM_WARNINGS: true
      ## R CMD check
      _R_CHECK_LENGTH_1_CONDITION_: true
      _R_CHECK_LENGTH_1_LOGIC2_: true
      _R_CHECK_MATRIX_DATA_: true
      _R_CHECK_CRAN_INCOMING_: false
      ## Specific to futures
      R_FUTURE_RNG_ONMISUSE: error
      
    steps:
      - uses: actions/checkout@v2

      - uses: r-lib/actions/setup-r@master
        with:
          r-version: release

      - uses: r-lib/actions/setup-pandoc@master

      - name: Query R package dependencies
        run: |
          install.packages('remotes')
          saveRDS(remotes::dev_package_deps(dependencies = TRUE), ".github/depends.Rds", version = 2)
          writeLines(sprintf("R-%i.%i", getRversion()$major, getRversion()$minor), ".github/R-version")
        shell: Rscript {0}

      - name: Cache R packages
        uses: actions/cache@v1
        with:
          path: ${{ env.R_LIBS_USER }}
          key: ${{ runner.os }}-${{ hashFiles('.github/R-version') }}-1-${{ hashFiles('.github/depends.Rds') }}
          restore-keys: ${{ runner.os }}-${{ hashFiles('.github/R-version') }}-1-

      - name: Install R package system dependencies (Linux)
        if: runner.os == 'Linux'
        env:
          RHUB_PLATFORM: linux-x86_64-ubuntu-gcc
        run: |
          Rscript -e "remotes::install_github('r-hub/sysreqs')"
          sysreqs=$(Rscript -e "cat(sysreqs::sysreq_commands('DESCRIPTION'))")
          sudo -s eval "$sysreqs"

      - name: Install R package dependencies
        run: |
          remotes::install_deps(dependencies = TRUE)
          install.packages(".", repos=NULL, type="source")  ## needed by parallel workers
        shell: Rscript {0}
          
      - name: Install 'future.tests' and any backend R packages
        run: |
          remotes::install_cran("future.tests")
          if (grepl("::", plan <- "${{ matrix.future.plan }}") && nzchar(pkg <- sub("::.*", "", plan))) install.packages(pkg)
        shell: Rscript {0}

      - name: Session info
        run: |
          options(width = 100)
          pkgs <- installed.packages()[, "Package"]
          sessioninfo::session_info(pkgs, include_base = TRUE)
        shell: Rscript {0}
    
      - name: Check future backend '${{ matrix.future.plan }}'
        run: |
          R CMD build --no-build-vignettes --no-manual . 
          R CMD INSTALL *.tar.gz 
          Rscript -e future.tests::check --args --test-plan=${{ matrix.future.plan }}

      - name: Upload check results
        if: failure()
        uses: actions/upload-artifact@master
        with:
          name: ${{ runner.os }}-r${{ matrix.future.plan }}-results
          path: check
```


#### Travis CI

Here's an example `.travis.yaml` file that configures Travis CI to check the 'multisession' and the 'future.callr::callr' backends via the **future.tests** test suite via concurrent jobs.

```yaml
language: r
sudo: false
cache: packages
warnings_are_errors: false
r_check_args: --as-cran

matrix:
  include:
    - os: linux
      r: release
      r_packages:
        - future.tests
      script:
        - R CMD build --no-build-vignettes --no-manual .
        - R CMD INSTALL *.tar.gz
        - Rscript -e future.tests::check --args --test-plan="${BACKEND}"
      env: BACKEND='multisession'
    - os: linux
      r: release
      r_packages:
        - future.tests
      script:
        - R CMD build --no-build-vignettes --no-manual .
        - R CMD INSTALL *.tar.gz
        - Rscript -e future.tests::check --args --test-plan="${BACKEND}"
      env: BACKEND='future.callr::callr'
```



[R]: https://www.r-project.org
[future]: https://cran.r-project.org/package=future
[future.callr]: https://cran.r-project.org/package=future.callr
[future.batchtools]: https://cran.r-project.org/package=future.batchtools
[future.tests]: https://cran.r-project.org/package=future.tests

## Installation
R package future.tests is available on [CRAN](https://cran.r-project.org/package=future.tests) and can be installed in R as:
```r
install.packages("future.tests")
```


### Pre-release version

To install the pre-release version that is available in Git branch `develop` on GitHub, use:
```r
remotes::install_github("HenrikBengtsson/future.tests", ref="develop")
```
This will install the package from source.  

<!-- pkgdown-drop-below -->


## Contributing

To contribute to this package, please see [CONTRIBUTING.md](CONTRIBUTING.md).

