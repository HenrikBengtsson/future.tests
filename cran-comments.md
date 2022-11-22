# CRAN submission future.tests 0.4.0

on 2022-11-21

This submission fixes check errors on MS Windows.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub  | mac/win-builder |
| ------------- | ------ | ------ | --------------- |
| 3.4.x         | L      |        |                 |
| 3.6.x         | L      |        |                 |
| 4.0.x         | L      |        |                 |
| 4.1.x         | L      |        |                 |
| 4.2.x         | L M W  | L M W  | M1 W            |
| devel         | L M W  | L      |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


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
── future.tests 0.4.0: OK

  Build ID:   future.tests_0.4.0.tar.gz-56087839a7244fe2838b26e0e7d6e2ef
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  20m 7.3s ago
  Build time: 20m 4.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.4.0: OK

  Build ID:   future.tests_0.4.0.tar.gz-d34153e91faf4ae1a6cc270aeafc81fc
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  20m 7.3s ago
  Build time: 14m 46.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.4.0: OK

  Build ID:   future.tests_0.4.0.tar.gz-038d204e46e6447fb1af73511ee0d8c4
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  20m 7.3s ago
  Build time: 18m 49.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.4.0: OK

  Build ID:   future.tests_0.4.0.tar.gz-a93269329a4146f89862b6f44c19c982
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  20m 7.3s ago
  Build time: 3m 49.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.4.0: OK

  Build ID:   future.tests_0.4.0.tar.gz-589d62db07ac40de80b37ee54bb43b14
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  20m 7.3s ago
  Build time: 3m 20.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
