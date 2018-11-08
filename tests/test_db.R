library(future.tests)
library(future)

tests <- load_tests()
message("Number of tests: ", length(tests))

df_tests <- do.call(rbind, tests)
print(df_tests)

tests_a <- subset_tests(tests, tags = "stdout")
df_tests <- do.call(rbind, tests_a)
print(df_tests)

tests_b <- subset_tests(tests, tags = "stdout", args = list(stdout = TRUE))
df_tests <- do.call(rbind, tests_b)
print(df_tests)

tests_c <- subset_tests(tests, args = list(stdout = TRUE))
df_tests <- do.call(rbind, tests_c)
print(df_tests)
