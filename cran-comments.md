# CRAN submission future.tests 0.3.0

on 2021-10-09

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub      | mac/win-builder |
| ------------- | ------ | ---------- | --------------- |
| 3.3.x         | L      |            |                 |
| 3.4.x         | L      |            |                 |
| 3.5.x         | L      |            |                 |
| 4.0.x         | L      | L          |                 |
| 4.1.x         | L M W  | L M M1 S W | M1 W            |
| devel         | L M W  | L        W |    W            |

*Legend: OS: L = Linux, S = Solaris, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```
> res <- rhub::check(platform = c(
  "debian-clang-devel", "debian-gcc-patched", "linux-x86_64-centos-epel",
  "macos-highsierra-release-cran", "macos-m1-bigsur-release",
  "solaris-x86-patched-ods", "windows-x86_64-devel", "windows-x86_64-release"))
> res

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-cff9ca7332f941d9a8695c2c87b54304
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  6m 6s ago
  Build time: 3m 25s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-917c4a0ae437468582ffbc55a16f15d3
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  6m 6s ago
  Build time: 3m 10.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-ec8d95e68bd5491b9897f96c878b952d
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  6m 6s ago
  Build time: 2m 42s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-cf82f2cc0d344591be6287b80fabaeab
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  6m 6s ago
  Build time: 5m 11.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-733c6f2427a541daa801308e236d1ddb
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  6m 6s ago
  Build time: 1m 33.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-3155d50067524c0f90fbc5cdede64cc2
  Platform:   Oracle Solaris 10, x86, 32 bit, R release, Oracle Developer Studio 12.6
  Submitted:  6m 6s ago
  Build time: 3m 3.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-beacf1d12038420d922ac0b1a9b06ee9
  Platform:   Windows Server 2008 R2 SP1, R-devel, 32/64 bit
  Submitted:  6m 6s ago
  Build time: 3m 36.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── future.tests 0.3.0: OK

  Build ID:   future.tests_0.3.0.tar.gz-013d6014678947ecbe0ef2dd11637fe2
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  6m 6s ago
  Build time: 3m 41.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
