# CRAN submission future.tests 0.2.1


## Resubmission on 2020-03-19

> Thanks, please write package names, software names and API names in
> single quotes (e.g. 'Future') in Title and Description.

Done

> Please add a web reference for the 'Future' API in your Description text
> in the form <http:...> or <https:...> with angle brackets for auto-linking
> and no space after 'http:' and 'https:'.

Instead of a URL, it is now clarified that the Future API is specified by the future package.

> Please replace cat() by message() or warning() in your functions (except
> for print() and summary() functions). Messages and warnings can be
> suppressed if needed.

This is a false positive; all output to the standard output is intentional by design.  The output must not go to standard error via message() and similar.

> Please add small executable examples in your Rd-files.
> If the execution requires an API key, please wrap the exmaples in
> \dontrun{}.

Added example("check"); everything else is low-level and not really meant to be used by others, yet, they need to be exported.

Thank you


## Initial submission on 2020-03-13

This is a first submission.  I've verified that it passes 'R CMD check --as-cran' on Linux, macOS, Solaris, and Windows across multiple R versions, including R 3.5.3, R 3.6.3, and R devel.

Thanks in advance


## Notes not sent to CRAN

### R CMD check --as-cran validation

The package has been verified using `R CMD check --as-cran` on:

* Platform x86_64-apple-darwin15.6.0 (64-bit) [Travis CI]:
  - R version 3.6.2 (2019-12-12)

* Platform x86_64-apple-darwin15.6.0 (64-bit) [GitHub Actions]:
  - R version 3.6.3 (2020-02-29)
  - R Under development (unstable) (2020-03-13 r77937)

* Platform x86_64-unknown-linux-gnu (64-bit) [Travis CI]:
  - R version 3.5.3 (2017-01-27) [sic!]
  - R version 3.6.2 (2017-01-27) [sic!]
  - R Under development (unstable) (2020-03-13 r77948)

* Platform x86_64-pc-linux-gnu (64-bit) [r-hub]:
  - R version 3.6.1 (2019-07-05)

* Platform x86_64-pc-linux-gnu (64-bit) [GitHub Actions]:
  - R version 3.2.5 (2016-04-14)
  - R version 3.3.3 (2017-03-06)
  - R version 3.4.4 (2018-03-15)
  - R version 3.5.3 (2019-03-11)
  - R version 3.6.3 (2020-02-29)

* Platform i686-pc-linux-gnu (32-bit):
  - R version 3.4.4 (2018-03-15)

* Platform: i386-pc-solaris2.10 (32-bit) [r-hub]
   - R version 3.6.3 Patched (2020-02-29 r77917)

* Platform x86_64-w64-mingw32 (64-bit) [GitHub Actions]:
  - R version 3.6.3 (2020-02-29)
  - R Under development (unstable) (2020-03-12 r77936)

* Platform x86_64-w64-mingw32 (64-bit) [r-hub]:
  - R Under development (unstable) (2020-03-08 r77917)

* Platform x86_64-w64-mingw32/x64 (64-bit) [Appveyor CI]:
  - R version 3.6.3 (2020-02-29)
  - R Under development (unstable) (2020-03-12 r77936)

* Platform x86_64-w64-mingw32/x64 (64-bit) [win-builder]:
  - R version 3.6.3 (2020-02-29)
  - R Under development (unstable) (2020-03-11 r77925)
