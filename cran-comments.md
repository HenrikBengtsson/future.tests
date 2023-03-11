# CRAN submission future.tests 0.6.0

on 2023-03-11

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 3.4.x     | L      |        |                 |
| 3.6.x     | L      |        |                 |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L M W  |   M    |                 |
| 4.2.x     | L M W  | L   W  | M1 W            |
| devel     | L M W  | L      | M1 W            |

_Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows_


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "fedora-gcc-devel",
  "debian-gcc-patched", 
  "macos-highsierra-release-cran",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── future.tests 0.6.0: OK

  Build ID:   future.tests_0.6.0.tar.gz-3921eee4d9374b2aa2448fce2d4bb157
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  1h 39m 46.5s ago
  Build time: 20m 43.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.6.0: OK

  Build ID:   future.tests_0.6.0.tar.gz-0ebd4baf495341198dc7c9ae6e07bd2e
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  1h 39m 46.5s ago
  Build time: 15m 44.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.6.0: OK

  Build ID:   future.tests_0.6.0.tar.gz-e9f7df55be1f4403a7439c2d0514dea9
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  1h 39m 46.5s ago
  Build time: 19m 48.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.6.0: OK

  Build ID:   future.tests_0.6.0.tar.gz-db3bd114678647e6977b87ef00e1b121
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  1h 39m 46.5s ago
  Build time: 3m 48.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.6.0: OK

  Build ID:   future.tests_0.6.0.tar.gz-5f294a956fb74fc280754aa6b6f930ee
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  1h 39m 46.6s ago
  Build time: 4m 0.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
