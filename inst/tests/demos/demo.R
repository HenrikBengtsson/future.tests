if (getRversion() >= "3.2.0") {

options(future.demo.mandelbrot.nrow = 2L)
options(future.demo.mandelbrot.resolution = 50L)
options(future.demo.mandelbrot.delay = FALSE)

future.tests::context("Mandelbrot demo")
  
future.tests::along_cores({
  future.tests::along_strategies({
    demo("mandelbrot", package = "future", ask = FALSE)
  })
})

} else {
  message(" - This demo requires R (>= 3.2.0). Skipping test.")
}
