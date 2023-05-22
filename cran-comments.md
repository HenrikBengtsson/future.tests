# CRAN submission future.tests 0.7.0

on 2023-05-21

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 3.4.x     | L      |        |                 |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L M W  |   M    |                 |
| 4.2.x     | L M W  |        |                 |
| 4.3.x     | L M W  | L   W  | M1 W            |
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
── future.tests 0.7.0: OK

  Build ID:   future.tests_0.7.0.tar.gz-6c88a10b51394be8a1d22401dc24779c
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  8m 25.1s ago
  Build time: 8m 20.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.7.0: OK

  Build ID:   future.tests_0.7.0.tar.gz-05cd2e4c412149ad85b4685cb274fff9
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  8m 25.1s ago
  Build time: 6m 42.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.7.0: OK

  Build ID:   future.tests_0.7.0.tar.gz-4828b13a21fa4e53a2ce9a0710256fe3
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  8m 25.1s ago
  Build time: 8m 11.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.7.0: OK

  Build ID:   future.tests_0.7.0.tar.gz-708d237752814aa796ff611c9fb66cb1
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  8m 25.1s ago
  Build time: 3m 33.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.7.0: OK

  Build ID:   future.tests_0.7.0.tar.gz-f509a6f352ac4c76badb81fbea2782a7
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  8m 25.1s ago
  Build time: 3m 56.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
