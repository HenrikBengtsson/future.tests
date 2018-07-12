future.tests::begin("future.tests API")

future.tests::context("Number of cores to test over")
cores <- future.tests:::seq_along_cores()
print(cores)
stopifnot(is.integer(cores), length(cores) >= 1L, !anyNA(cores),
          all(cores >= 1L))

future.tests:::max_cores(4L)
cores <- future.tests:::seq_along_cores()
print(cores)
stopifnot(max(cores) == 4L)

future.tests::context("Test of cores")
future.tests:::max_cores(4L)

res <- future.tests::along_cores({
  str({ future.tests::get_options("^(future[.]|mc[.]cores)") })
  cores <- availableCores()
  message(sprintf("- Number of cores: %d", cores))
  cores
})
str(res)
stopifnot(is.list(res), length(res) == 4L,
          all(names(res) == sprintf("cores=%d", 1:4)),
          all(unlist(res) == 1:4))

future.tests::end()
