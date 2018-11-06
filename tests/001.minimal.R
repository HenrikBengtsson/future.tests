future.tests::begin("future.tests API")
future.tests::context("Minimal test")
future.tests::end()


## Objects
future.tests::begin("future.tests API")
future.tests::context("New object")
a <- 42L
str(future.tests:::db_state("list"))
future.tests::end()
stopifnot(!"a" %in% ls())

a <- 42L
future.tests::begin("future.tests API")
future.tests::context("Changed object")
a <- 3.14
future.tests::end()
stopifnot(identical(a, 42L))

a <- 42L
future.tests::begin("future.tests API")
future.tests::context("Dropped object")
rm(list = "a")
future.tests::end()
stopifnot(identical(a, 42L))
rm(list = "a")


## Environment variables
future.tests::begin("future.tests API")
future.tests::context("New environment variable")
Sys.setenv("future.test.a" = "42")
future.tests::end()
stopifnot(!"future.test.a" %in% Sys.getenv())

Sys.setenv("future.test.a" = "42")
future.tests::begin("future.tests API")
future.tests::context("Changed environment variable")
Sys.setenv("future.test.a" = "3.14")
future.tests::end()
stopifnot(Sys.getenv("future.test.a") == "42")

Sys.setenv("future.test.a" = "42")
future.tests::begin("future.tests API")
future.tests::context("Dropped environment variable")
Sys.unsetenv("future.test.a")
future.tests::end()
stopifnot(Sys.getenv("future.test.a") == "42")


## Options
future.tests::begin("future.tests API")
future.tests::context("New option")
options(future.test.a = 42L)
future.tests::end()
str(options())
stopifnot(!"future.test.a" %in% names(options()))

options(future.test.a = 42L)
future.tests::begin("future.tests API")
future.tests::context("Changed environment variable")
options(future.test.a = 3.14)
future.tests::end()
stopifnot(identical(getOption("future.test.a"), 42L))
options(future.test.a = NULL)

options(future.test.a = 42L)
future.tests::begin("future.tests API")
future.tests::context("Dropped environment variable")
options(future.test.a = NULL)
future.tests::end()
stopifnot(identical(getOption("future.test.a"), 42L))
options(future.test.a = NULL)
