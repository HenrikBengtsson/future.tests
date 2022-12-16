# CRAN submission future.tests 0.5.0

on 2022-12-15

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
── future.tests 0.5.0: OK

  Build ID:   future.tests_0.5.0.tar.gz-2214029e90654147a2042359e8ea6994
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  27m 31s ago
  Build time: 27m 25.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.5.0: OK

  Build ID:   future.tests_0.5.0.tar.gz-fae56b16b30843e2b376baf3d75e5434
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  27m 31s ago
  Build time: 20m 4.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.5.0: OK

  Build ID:   future.tests_0.5.0.tar.gz-d93d8eb2b11849f8a69967ecb5a98311
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  27m 31s ago
  Build time: 25m 59.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.5.0: OK

  Build ID:   future.tests_0.5.0.tar.gz-d2ba6a97e33d47e698efe1d7043069d1
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  27m 31s ago
  Build time: 4m 15.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.5.0: OK

  Build ID:   future.tests_0.5.0.tar.gz-cf023d02b3de4b858e60ad0ea41fc95d
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  27m 31s ago
  Build time: 3m 41s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
