future.tests::begin('Core API: demo("mandelbrot", package = "future")', package = "future")

## future.tests::skip_unless(getRversion() >= "3.2.0")

options(future.demo.mandelbrot.nrow = 2L)
options(future.demo.mandelbrot.resolution = 50L)
options(future.demo.mandelbrot.delay = FALSE)

future.tests::along_cores({
  future.tests::along_strategies({
    strategy <- plan()
    cores <- nbrOfWorkers()
    for (lazy in c(FALSE, TRUE)) {
      for (globals in c(FALSE, TRUE)) {
        if (getRversion() >= "3.2.0") {
          demo("mandelbrot", package = "future", ask = FALSE)
        } else {
          message(" - This demo requires R (>= 3.2.0). Skipping test.")
        }
      }
    }
  })
})

future.tests::end()
