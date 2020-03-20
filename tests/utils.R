message("*** Utility functions ...")

tests_root <- future.tests:::tests_root
assert_package <- future.tests:::assert_package
load_package <- future.tests:::load_package
attach_package <- future.tests:::attach_package
hpaste <- future.tests:::hpaste
is_covr <- future.tests:::is_covr
printf <- future.tests:::printf
mprintf <- future.tests:::mprintf
mprint <- future.tests:::mprint
mstr <- future.tests:::mstr
mdebug <- future.tests:::mdebug
parseCmdArgs <- future.tests:::parseCmdArgs
stop_if_not <- future.tests:::stop_if_not

message("- tests_root()")
path <- tests_root()
print(path)
stopifnot(utils::file_test("-d", path))

message("- assert_package()")
path <- assert_package("future.tests")
print(path)
stopifnot(utils::file_test("-d", path))

message("- load_package()")
res <- load_package("future.tests")
print(res)
stopifnot(isTRUE(res))

message("- attach_package()")
res <- attach_package("future.tests")
print(res)
stopifnot(isTRUE(res))

message("- is_covr()")
res <- is_covr()
print(res)
stopifnot(is.logical(res), !is.na(res))

message("- printf()")
printf("Hello %s!\n", "world")

message("- mprintf()")
mprintf("Hello")

message("- mprint()")
mprint("Hello")

message("- mstr()")
mstr("Hello")

message("- mdebug()")
options(future.tests.debug = FALSE)
mdebug("Hello")
options(future.tests.debug = TRUE)
mdebug("Hello")

message("- parseCmdArgs()")
args <- parseCmdArgs()
str(args)
stopifnot(is.list(args))

args <- parseCmdArgs(c("--cores=2"))
str(args)
stopifnot(is.list(args), args$cores == 2L)

args <- parseCmdArgs(c("--cores=2", "--cores=3"))
str(args)
stopifnot(is.list(args), args$cores == 3L)

args <- parseCmdArgs(c("--cores=-1"))
str(args)
stopifnot(is.list(args), is.null(args$cores))

args <- parseCmdArgs(c("--cores=unknown"))
str(args)
stopifnot(is.list(args), is.null(args$cores))

args <- parseCmdArgs(c("--cores=9999999"))
str(args)
stopifnot(is.list(args), is.null(args$cores))

message("* hpaste() ...")

# Some vectors
x <- 1:6
y <- 10:1
z <- LETTERS[x]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Abbreviation of output vector
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
printf("x = %s.\n", hpaste(x))
## x = 1, 2, 3, ..., 6.

printf("x = %s.\n", hpaste(x, max_head = 2))
## x = 1, 2, ..., 6.

printf("x = %s.\n", hpaste(x), max_head = 3) # Default
## x = 1, 2, 3, ..., 6.

# It will never output 1, 2, 3, 4, ..., 6
printf("x = %s.\n", hpaste(x, max_head = 4))
## x = 1, 2, 3, 4, 5 and 6.

# Showing the tail
printf("x = %s.\n", hpaste(x, max_head = 1, max_tail = 2))
## x = 1, ..., 5, 6.

# Turning off abbreviation
printf("y = %s.\n", hpaste(y, max_head = Inf))
## y = 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

## ...or simply
printf("y = %s.\n", paste(y, collapse = ", "))
## y = 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

# Change last separator
printf("x = %s.\n", hpaste(x, last_collapse = " and "))
## x = 1, 2, 3, 4, 5 and 6.

# No collapse
stopifnot(all(hpaste(x, collapse = NULL) == x))

# Empty input
stopifnot(identical(hpaste(character(0)), character(0)))

message("- stop_if_not()")
stop_if_not(TRUE)
stop_if_not(inherits(tryCatch(stop_if_not(FALSE), error = identity), "error"))

message("*** Utility functions ... DONE")
